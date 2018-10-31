
public class Agent {
  private RoadNetwork map;
  private String mobilityType;
  private PImage[] glyph;
  private PVector pos;
  private Node srcNode, destNode, toNode; // toNode is like next node
  private ArrayList<Node> path;
  private PVector dir;
  private float speed;
  
  Agent(RoadNetwork _map){
    map = _map;
    // TODO(aberke): move this
    setupMobilityType();
    initAgent();
  }
  
  public void initAgent(){
    do {
      srcNode =  (Node) map.graph.nodes.get(int(random(map.graph.nodes.size())));
      destNode =  (Node) map.graph.nodes.get(int(random(map.graph.nodes.size())));
    } while (srcNode == destNode);    
    
    pos = new PVector(srcNode.x, srcNode.y);
    path = null;
    dir = new PVector(0.0, 0.0);
  }
  
  
  public void initAgentInsideBuilding(){
    do {
      srcNode =  map.getNodeInsideROI(universe.grid.getBuildingCenterPosistionPerId(int(random(18))),2*int((SIMULATION_WIDTH/16)*scale)).get(0);
      destNode =  map.getNodeInsideROI(universe.grid.getBuildingCenterPosistionPerId(int(random(18))),2*int((SIMULATION_WIDTH/16)*scale)).get(0);
    } while (srcNode == destNode);    
    
    pos = new PVector(srcNode.x,srcNode.y);
    path = null;
    dir = new PVector(0.0, 0.0);
  }


  public void draw(PGraphics p, boolean glyphs){
    if (glyphs && (glyph.length > 0)) {
      PImage img = glyph[frameCount % glyph.length];
      if (img != null) {
        p.pushMatrix();
        p.translate(pos.x, pos.y);
        p.rotate(dir.heading() + PI * 0.5);
        p.translate(-1, 0);
        p.image(img, 0, 0, img.width * scale, img.height * scale);
        p.popMatrix();
      }
    } else {
      p.noStroke();
      p.fill(universe.colorMap.get(mobilityType));
      p.ellipse(pos.x, pos.y, 10*scale, 10*scale);
    }
  }

  private String chooseMobilityType() {
    /* Agent makes a choice about which mobility
     * mode type to use for route.
     * This is based on activityBased model.
    */
    // TODO(aberke): Use decision tree code from activityBased model.
    // decision will be based on a agent path + attributes from simPop.csv.
    // Currently randomly selects between car/bike/ped.
    String[] mobilityTypes = {"car", "bike", "ped"};
    int choice = int(random(3));
    return mobilityTypes[choice];
  }

  private void setupMobilityType() {
    mobilityType = chooseMobilityType();
    // TODO(Yasushi Sakai): Previous Glyphs are faster??
    switch(mobilityType) {
      case "car" :
        glyph = new PImage[1];
        glyph[0] = loadImage("image/" + mobilityType + ".gif");
        speed = 1.0;// + random(-0.3,0.3);
      break;
      case "bike" :
        glyph = new PImage[2];
        glyph[0] = loadImage("image/" + mobilityType + "-0.gif");
        glyph[1] = loadImage("image/" + mobilityType + "-1.gif");
        speed = 1.0;// + random(-0.15,0.15);
      break;
      case "ped" :
        glyph = new PImage[3];
        glyph[0] = loadImage("image/" + "human" + "-0.gif");
        glyph[1] = loadImage("image/" + "human" + "-1.gif");
        glyph[2] = loadImage("image/" + "human" + "-2.gif");
        speed = 1.0;// + random(-0.05,0.05);
      break;
      default:
      break;
    }     
  }


  private boolean calcRoute() {
    if (srcNode == destNode) {
      // Agent already in destination
      toNode = destNode;
      return true;
    } else {
      // Next node is available
      ArrayList<Node> newPath = map.graph.aStar(srcNode, destNode);
      if ( newPath != null ) {
        path = newPath;
        toNode = path.get(path.size() - 2); // what happens if there are only two nodes?
        return true;
      }
    }
    return false;
  }
  
  public void update() {
    if (path == null){
      // Agent must get its path and choose a mobility type for its route.
      calcRoute();
      setupMobilityType();
    }
    PVector toNodePos = new PVector(toNode.x, toNode.y);
    PVector destNodePos = new PVector(destNode.x, destNode.y);
    dir = PVector.sub(toNodePos, pos);  // unnormalized direction to go
    
    if (dir.mag() <= dir.normalize().mult(speed).mag()) {
      // Arrived to node
      if (path.indexOf(toNode) == 0) {  
        // Arrived to destination
        pos = destNodePos;
        this.initAgentInsideBuilding();
      } else {
        // Not destination. Look for next node.
        srcNode = toNode;
        toNode = path.get(path.indexOf(toNode) - 1);
      }
    } else {
      // Not arrived to node
      pos.add(dir);
    }
  }
}
