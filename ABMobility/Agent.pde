/*  ABMobility: Data-Driven Interactive Agent Based Simulation

    MIT Media Lab City Science - The Road Ahead: Reimagine Mobility
    Exhibition at the Cooper Hewitt Smithsonian Design Museum 
    12.14.18 - 03.31.19
    
    Visit https://github.com/CityScope/CS_Cooper-Hewitt 
    for license information and developers contact.
     
   @copyright: Copyright (C) 2018
   @authors:   Arnaud Grignard - Yasushi Sakai - Alex Berke
   @version:   1.0
   @legal:

    ABMobility is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    Graphics is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.
    You should have received a copy of the GNU Affero General Public License
    along with Graphics.  If not, see <http://www.gnu.org/licenses/>. */
    
// Mobility motifs are sequences of 'types' of places to go.
// These types correspond to building blocks on the gridwhere these
// types of activity take place.
public final String RESIDENTIAL = "R";
public final String OFFICE = "O";
public final String AMENITY = "A";

public class Agent {

  // Networks is a mapping from network name to RoadNetwork.
  // e.g. "car" --> RoadNetwork, ... etc
  private HashMap<String, RoadNetwork> networks;
  private HashMap<String, PImage[]> glyphsMap;
  private RoadNetwork map;  // Curent network used for mobility type.
  private NetworkEdge edge; // Current edge that it's sitting on
  private int worldId;  // 1=Bad world; 2=Good world

  private int residentialBlockId;
  private int officeBlockId;
  private int amenityBlockId;
  private int householdIncome;
  private int occupationType;
  private int age;

  // Agents have mobility motifs that determine their trips
  // mobility motifs are made up of sequences of:
  // R (residential)
  // O (office)
  // A (amenity)
  // The sequence represents the agent's daily mobility patterns
  private String mobilityMotif;
  private String[] mobilitySequence;
  // ms keeps track of where agent is in their mobility sequence.
  // The value cycles through the indicies of the mobilitySequenceArray.
  private int ms;

  // Variables specific to trip within mobility motif sequence.
  private int srcBlockId;  // source block for current trip
  private int destBlockId;  // destination block for current trip
  // Keeps track of destination location so that if block is moved, destination can update
  private PVector destBlockLocation;
  private String mobilityType;
  private PImage[] glyph;
  private PVector pos;
  private Node srcNode, destNode, toNode;  // toNode is like next node
  private ArrayList<Node> path;  // Path is a list of nodes from destNode to toNode.  e.g. [destNode, node, node, ..., toNode]
  private int pathIndex; // Keeps track of index that agent has traveled in path.  Moves from back of path to front.  i.e. destNode -> toNode
  private PVector dir;
  private float speed;
  private float maxSpeed;
  private boolean isZombie;
  private color myColor;


  Agent(HashMap<String, RoadNetwork> _networks, HashMap<String, PImage[]> _glyphsMap, int _worldId, 
    int _residentialBlockId, int _officeBlockId, int _amenityBlockId, 
    String _mobilityMotif, 
    int _householdIncome, int _occupationType, int _age) {
    networks = _networks;
    glyphsMap = _glyphsMap;
    worldId = _worldId;
    residentialBlockId = _residentialBlockId;
    officeBlockId = _officeBlockId;
    amenityBlockId = _amenityBlockId;
    mobilityMotif = _mobilityMotif;
    householdIncome = _householdIncome;
    occupationType = _occupationType;
    age = _age;
    isZombie = false;
  }


  public void initAgent() {
    // Set up mobility sequence.  The agent travels through this sequence.
    ms = 0;
    switch(mobilityMotif) {
    case "ROR" :
      mobilitySequence = new String[] {"R", "O"};
      break;
    case "RAAR" :
      mobilitySequence = new String[] {"R", "A", "A"};
      break;
    case "RAOR" :
      mobilitySequence = new String[] {"R", "A", "O"};
      break;
    case "RAR" :
      mobilitySequence = new String[] {"R", "A"};
      break;
    case "ROAOR" :
      mobilitySequence = new String[] {"R", "O", "A", "O"};
      break;
    case "ROAR" :
      mobilitySequence = new String[] {"R", "O", "A"};
      break;
    case "ROOR" :
      mobilitySequence = new String[] {"R", "O", "O"};
      break;
    default:
      mobilitySequence = new String[] {"R", "O"};
      break;
    }

    destBlockId = -1;
    setupNextTrip();
  }


  public void setupNextTrip() {
    // destination block < 0 before the first trip (right after agent is initialized).
    if (destBlockId < 0) {
      srcBlockId = getBlockIdByType(mobilitySequence[ms]);
    } else {
      // The destination block becomes the source block for the next trip.
      srcBlockId = destBlockId;
    }

    ms = (ms + 1) % mobilitySequence.length;
    String destType = mobilitySequence[ms];
    destBlockId = getBlockIdByType(destType);

    // Determine whether this agent 'isZombie': is going to or from 'zombie land'
    boolean srcOnGrid = universe.grid.isBuildingInCurrentGrid(srcBlockId);
    boolean destOnGrid = universe.grid.isBuildingInCurrentGrid(destBlockId);
    isZombie = !(srcOnGrid && destOnGrid);

    // Mobility choice partly determined by distance
    // agent must travel, so it is determined after zombieland
    // status is determined.
    setupMobilityType();

    destBlockLocation = universe.grid.getBuildingLocationById(destBlockId);

    // Get the nodes on the graph
    // Note the graph is specific to mobility type and was chosen when mobility type was set up.
    srcNode = getNodeByBlockId(srcBlockId);
    destNode = getNodeByBlockId(destBlockId);

    calcRoute();
  }


  public Node getNodeByBlockId(int blockId) {
    if (universe.grid.isBuildingInCurrentGrid(blockId)) {
      return map.getRandomNodeInsideROI(universe.grid.getBuildingCenterPosistionPerId(blockId), BUILDING_SIZE);
    } else {
      return map.getRandomNodeInZombieLand();
    }
  }


  private void calcRoute() {
    pos = new PVector(srcNode.x, srcNode.y);
    path = null;
    dir = new PVector(0.0, 0.0);

    if (srcNode == destNode) {
      // Agent already in destination
      toNode = destNode;
      pathIndex = 0;
      return;
    }
    // Next node is available
    ArrayList<Node> newPath = map.graph.aStar(srcNode, destNode);
    if ( newPath != null ) {
      path = newPath;
      pathIndex = path.size() - 2; // what happens if there are only two nodes?
      toNode = path.get(pathIndex);
      // only update when we are in car and bad
      if (mobilityType.equals("car") && worldId==1){
        edge = map.edgeManager.updateEdge(this, edge, srcNode, toNode);
      }
    }
  }


  public int getBlockIdByType(String type) {
    int blockId = 0;
    if (type == RESIDENTIAL) {
      blockId = residentialBlockId;
    } else if (type == OFFICE) {
      blockId = officeBlockId;
    } else if (type == AMENITY) {
      blockId = amenityBlockId;
    }
    return blockId;
  }


  public void draw(PGraphics p, boolean glyphs) {
    if (worldId==1) {
      myColor = universe.colorMapBad.get(mobilityType);
    } else {
      myColor=universe.colorMapGood.get(mobilityType);
    }
    p.fill(myColor);
    if (showRemaninginAgentAndBuilding) {
      if (residentialBlockId == universe.grid.currentBlockAnimated || officeBlockId ==  universe.grid.currentBlockAnimated || amenityBlockId == universe.grid.currentBlockAnimated) {    
        if (universe.grid.gridAnimation.get(universe.grid.currentGridAnimated).center.x < state.slider * SIMULATION_WIDTH) {
          p.fill(#FF0000);
          p.stroke(#FF0000);
        } else {
          p.fill(#FFFFFF);
          p.stroke(#FFFFFF);
        }
        PImage img = animatedGlyph ? glyph[frameCount % glyph.length] : glyph[0];
        if (img != null) {
          p.pushMatrix();
          p.translate(pos.x, pos.y);
          p.rotate(dir.heading() + PI * 0.5);
          p.translate(-1, 0);
          p.image(img, 0, 0, img.width * SCALE, img.height * SCALE);
          p.popMatrix();
        }
        if(showConnectionBetweenAgentAndBuilding){
          p.stroke(myColor,100);
          p.strokeWeight(1);
          p.line(pos.x, pos.y, universe.grid.gridAnimation.get(universe.grid.currentGridAnimated).center.x, universe.grid.gridAnimation.get(universe.grid.currentGridAnimated).center.y);
          p.noStroke();
        } 
      }

    } 
      if (pos == null || path == null) {  // in zombie land.
        return;
      }
      if (glyphs && (glyph.length > 0)) {
        PImage img = animatedGlyph ? glyph[frameCount % glyph.length] : glyph[0];
        if (img != null) {
          p.pushMatrix();
          p.translate(pos.x, pos.y);
          p.rotate(dir.heading() + PI * 0.5);
          p.translate(-1, 0);
          if (showRemaninginAgentAndBuilding){
             p.tint(255,80);
             p.image(img, 0, 0, img.width * SCALE, img.height * SCALE);
             p.tint(255,255);
          }else{
            p.tint(255,255);
            p.image(img, 0, 0, img.width * SCALE, img.height * SCALE);
          }
          p.popMatrix();
        }
      } else {
        p.noStroke();
        p.ellipse(pos.x, pos.y, 10*SCALE, 10*SCALE);
      }

      if (showZombie & isZombie) {
        p.fill(#CC0000);
        p.ellipse(pos.x, pos.y, 10*SCALE, 10*SCALE);
      }

      if (showCollisionPotential) {
        if (worldId==2) {
          for (Agent a : universe.world2.agents) {
            float dist = pos.dist(a.pos);
            if (dist<40) {
              p.stroke(lerpColor(universe.colorMapGood.get(mobilityType), universe.colorMapGood.get(a.mobilityType), 0.5));
              p.strokeWeight(1);
              p.line(pos.x, pos.y, a.pos.x, a.pos.y);
              p.noStroke();
            }
          }
        }
      }
    
  }

  // DRAW AGENT PATH TO DESTINATION --->
  public void drawPath(PGraphics p, color c) {
    if (path != null) {
      for (int i=1; i<path.size(); i++) {
        PVector iNodePos = new PVector(path.get(i).x, path.get(i).y), 
          iPrevNodePos = new PVector(path.get(i-1).x, path.get(i-1).y), 
          toNodePos = new PVector(toNode.x, toNode.y);
        //int weight = i <= path.indexOf(toNode) ? 3 : 1;  // Already traveled route is thiner than remaining route --->
        p.stroke(c); 
        p.strokeWeight(1); 
        p.noFill();
        p.line( iNodePos.x, iNodePos.y, iPrevNodePos.x, iPrevNodePos.y );
        //p.strokeWeight(3);  // Route from pos to next node is always thicker --->
        //  p.line( pos.x, pos.y, toNodePos.x, toNodePos.y );
      }
    }
  }

  private String chooseMobilityType() {
    /* Agent makes a choice about which mobility
     * mode type to use for route.
     * This is based on activityBased model.
     */
    // TODO(aberke): Use decision tree code from activityBased model.
    // Decision will be based on a agent path + attributes from simPop.csv.
    // Currently randomly selects between car/bike/ped based on dummy
    // probability distributions.

    // How likely agent is to choose one mode of mobility over another depends
    // on whether agent is in 'bad' vs 'good' world.
    // It also depends on how far an agent must travel.  Agents from 'zombieland'
    // are traveling further and more likely to take a car.
    String[] mobilityTypes = {"car", "bike", "ped"};
    float[] mobilityChoiceProbabilities;
    if (worldId == 1) {
      // Bad world dummy probabilities:
      if (isZombie) {
        mobilityChoiceProbabilities = new float[] {0.9, 0.1, 0};
      } else {
        mobilityChoiceProbabilities = new float[] {0.7, 0.2, 0.1};
      }
    } else {
      // Good world dummy probabilities:
      if (isZombie) {
        mobilityChoiceProbabilities = new float[] {0.3, 0.4, 0.3};
      } else {
        mobilityChoiceProbabilities = new float[] {0.1, 0.5, 0.4};
      }
    }

    // Transform the probability distribution into an array to randomly sample from.
    String[] mobilityChoiceDistribution = new String[100];
    int m = 0;
    for (int i=0; i<mobilityTypes.length; i++) {
      for (int p=0; p<int(mobilityChoiceProbabilities[i]*100); p++) {
        mobilityChoiceDistribution[m] = mobilityTypes[i];
        m++;
      }
    }
    // Take random sample from distribution.
    int choice = int(random(100));
    return mobilityChoiceDistribution[choice];
  }

  private void setupMobilityType() {
    mobilityType = chooseMobilityType();
    map = networks.get(mobilityType);
    glyph = glyphsMap.get(mobilityType);
    if(mobilityType.equals("car")){
      if (worldId == 2){
        glyph= glyphsMap.get("pev");
      }
    }

    switch(mobilityType) {
    case "car" :
      maxSpeed = SCALE*1.4+ random(-SCALE*0.6, SCALE*0.6);
      break;
    case "bike" :
      maxSpeed = SCALE*0.6+ random(-0.3*SCALE, 0.3*SCALE);
      break;
    case "ped" :
      maxSpeed = SCALE*0.4 + random(-0.1*SCALE, 0.1*SCALE);
      break;
    default:
      break;
    }
  }


  public void update() {
    // Check if the agent's destination block has been moved
    PVector currDestBlockLocation = universe.grid.getBuildingLocationById(destBlockId);
    if (currDestBlockLocation != destBlockLocation) {
      // The destination block has been moved!  Update the route.
      destBlockLocation = currDestBlockLocation;
      destNode = getNodeByBlockId(destBlockId);
      calcRoute();
    }

    if (path == null) { // in zombie land
      return;
    }

    PVector toNodePos = new PVector(toNode.x, toNode.y);
    PVector destNodePos = new PVector(destNode.x, destNode.y);
    dir = PVector.sub(toNodePos, pos);  // unnormalized direction to go
    updateSpeed();
    if (dir.mag() <= dir.normalize().mult(speed).mag()) {
      // Arrived to toNode
      if (pathIndex == 0) {  
        // Arrived to destination
        pos = destNodePos;
        this.setupNextTrip();
      } else {
        // Not destination. Look for next node.
        srcNode = toNode;
        pathIndex -= 1;
        toNode = path.get(pathIndex);
        if(mobilityType.equals("car") && worldId==1){
          edge = map.edgeManager.updateEdge(this, edge, srcNode, toNode);
        }
      }
    } else {
      // Not arrived to node
      pos.add(dir);
    }
  }

  void updateSpeed() {
    // from observation, e.density ranges from 0.14831 to 517.9554;
    if(edge != null) {
      float coef = map(edge.density, 0.14, 10, 0.1, 1.0);
      // do we liner? sigmoid? 
      float adjustedSpeed = cubicEase(coef) * maxSpeed;
      // float adjustedSpeed = coef * maxSpeed;
      if(edge.agents.size() > 4){
        adjustedSpeed = adjustedSpeed * 0.4 + (adjustedSpeed * 0.6 / edge.agents.size());
      }
      adjustedSpeed = min(max(adjustedSpeed, maxSpeed * 0.2), maxSpeed);
      speed = adjustedSpeed;
    } else {
      speed = maxSpeed;      
    }
  }

}
