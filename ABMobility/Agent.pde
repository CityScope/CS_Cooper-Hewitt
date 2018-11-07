
public class Agent {

  // Networks is a mapping from network name to RoadNetwork.
  // e.g. "car" --> RoadNetwork, ... etc
  private HashMap<String, RoadNetwork> networks;
  private HashMap<String, PImage[]> glyphsMap;
  private RoadNetwork map;  // Curent network used for mobility type.
  private int worldId;  // 1=Bad world; 2=Good world
  // TODO(arnaud+aberke): create proper zombie land nodes.
  // For now, if an agent's residential or office block is not on the table,
  // agent does nothing.
  private int residentialBlockId;
  private int officeBlockId;
  private String mobilityMotif;
  private int householdIncome;
  private int occupationType;
  private int age;
  private String mobilityType;
  private PImage[] glyph;
  private PVector pos;
  private Node srcNode, destNode, toNode;  // toNode is like next node
  private ArrayList<Node> path;
  private PVector dir;
  private float speed;

  private int homeBuildingId;
  private int workBuildingId;
  

  Agent(HashMap<String, RoadNetwork> _networks, HashMap<String, PImage[]> _glyphsMap, int _worldId,
        int _residentialBlockId, int _officeBlockId, String _mobilityMotif,
        int _householdIncome, int _occupationType, int _age){
    networks = _networks;
    glyphsMap = _glyphsMap;
    worldId = _worldId;
    residentialBlockId = _residentialBlockId;
    officeBlockId = _officeBlockId;
    mobilityMotif = _mobilityMotif;
    householdIncome = _householdIncome;
    occupationType = _occupationType;
    age = _age;
  }
  
  
  public void initAgent() {
    setupMobilityType(); 
    if(universe.grid.isBuildingInCurrentGrid(residentialBlockId)){
      srcNode =  map.getRandomNodeInsideROI(universe.grid.getBuildingCenterPosistionPerId(residentialBlockId),2*int((SIMULATION_WIDTH/16)*scale));
    }
    else{  
      srcNode = map.getRandomNodeInZombieLand();
    }
    
    if(universe.grid.isBuildingInCurrentGrid(officeBlockId)){
      destNode =  map.getRandomNodeInsideROI(universe.grid.getBuildingCenterPosistionPerId(officeBlockId),2*int((SIMULATION_WIDTH/16)*scale));
    }
    else{  
      destNode = map.getRandomNodeInZombieLand();
    }
        
    pos = new PVector(srcNode.x,srcNode.y);
    path = null;
    dir = new PVector(0.0, 0.0);
    
    calcRoute();
  }


  public void draw(PGraphics p, boolean glyphs) {
    if (pos == null || path == null) {  // in zombie land.
      return;
    }
    if (glyphs && (glyph.length > 0)) {
      //PImage img = glyph[frameCount % glyph.length];
      PImage img = glyph[0];
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
    // Decision will be based on a agent path + attributes from simPop.csv.
    // Currently randomly selects between car/bike/ped based on dummy
    // probability distributions.

    // How likely agent is to choose one mode of mobility over another depends
    // on whether agent is in 'bad' vs 'good' world.
    String[] mobilityTypes = {"car", "bike", "ped"};
    float[] mobilityChoiceProbabilities;
    if (worldId == 1) {
      // Bad world dummy probabilities:
      mobilityChoiceProbabilities = new float[] {0.7, 0.2, 0.1};
    } else {
      // Good world dummy probabilities:
      mobilityChoiceProbabilities = new float[] {0.1, 0.5, 0.4};
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

    switch(mobilityType) {
      case "car" :
        speed = 0.7+ random(-0.3,0.3);
      break;
      case "bike" :
        speed = 0.3+ random(-0.15,0.15);
      break;
      case "ped" :
        speed = 0.2 + random(-0.05,0.05);
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
    if (path == null) { // in zombie land
      return;
    }
    PVector toNodePos = new PVector(toNode.x, toNode.y);
    PVector destNodePos = new PVector(destNode.x, destNode.y);
    dir = PVector.sub(toNodePos, pos);  // unnormalized direction to go
    
    if (dir.mag() <= dir.normalize().mult(speed).mag()) {
      // Arrived to node
      if (path.indexOf(toNode) == 0) {  
        // Arrived to destination
        pos = destNodePos;
        this.initAgent();
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
