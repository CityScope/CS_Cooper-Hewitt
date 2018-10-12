/* ABM CLASS ------------------------------------------------------------*/
public class World{
  private ArrayList<ABM> models;
  private ArrayList<RoadNetwork> networks;
  HashMap<String,Integer> colorMap;
  
  
  World(){
    
    colorMap = new HashMap<String,Integer>();
    colorMap.put("car",#FF0000);colorMap.put("bike",#00FF00);colorMap.put("ped",#0000FF);
    
    networks = new ArrayList<RoadNetwork>();
    models = new ArrayList<ABM>();
    
    networks.add(new RoadNetwork("car.geojson"));
    networks.add(new RoadNetwork("bike.geojson"));
    networks.add(new RoadNetwork("ped.geojson"));
    
    models.add(new ABM(networks.get(0),"car"));
    models.add(new ABM(networks.get(1),"bike"));
    models.add(new ABM(networks.get(2),"ped"));
  }
  
  public void InitWorld(){
    models.get(0).initModel();
    models.get(1).initModel();
    models.get(2).initModel();
  }
  
  public void run(PGraphics p){
    for (ABM m: models){
      m.run(p);
    }
  }
}


public class ABM {
  private RoadNetwork map;
  private ArrayList<Agent> agents;
  private String type;
  public color modelColor;
  
  ABM(RoadNetwork _map, String _type){
    map=_map;
    agents = new ArrayList<Agent>();
    type= _type;    
  }
  
  public void initModel(){
    createAgents(500);
  }
  
  public void run(PGraphics p){
    for (Agent agent : agents) {
      agent.move(1);
      agent.draw(p);
    }
  }
  
  public void createAgents(int num) {
    for (int i = 0; i < num; i++){
      agents.add( new Agent(map,type));
    }
  } 
}

public class Agent{
  private RoadNetwork map;
  private String type;
  private color myColor;
  private PVector pos;
  private Node srcNode, destNode, toNode;
  private ArrayList<Node> path;
  private PVector dir;
  
  Agent(RoadNetwork _map, String _type){
    map=_map;
    type=_type;
    initAgent();
  }
  
  
  public void initAgent(){
    srcNode =  (Node) map.graph.nodes.get(int(random(map.graph.nodes.size())));
    destNode =  (Node) map.graph.nodes.get(int(random(map.graph.nodes.size())));
    pos= new PVector(srcNode.x,srcNode.y);
    path=null;
    dir = new PVector(0.0, 0.0);
    myColor= world.colorMap.get(type);
  }
    
  public void draw(PGraphics p){
    p.noStroke();
    p.fill(myColor);
    p.ellipse(pos.x, pos.y, 5, 5);
  }
    
  // CALCULATE ROUTE --->
  private boolean calcRoute(Node origin, Node dest) {
    // Agent already in destination --->
    if (origin == dest) {
      toNode=dest;
      return true;
      // Next node is available --->
    }  else {
        ArrayList<Node> newPath = map.graph.aStar( origin, dest);
        if ( newPath != null ) {
          path = newPath;
          toNode = path.get( path.size()-2 );
          return true;
        }
    }
    return false;
  }
  
    public void move(float speed) {
        if (path == null){
          calcRoute( srcNode, destNode );
        }
        PVector toNodePos= new PVector(toNode.x,toNode.y);
        PVector destNodePos= new PVector(destNode.x,destNode.y);
        dir = PVector.sub(toNodePos, pos);  // Direction to go
          // Arrived to node -->
          if ( dir.mag() < dir.normalize().mult(speed).mag() ) {
            // Arrived to destination  --->
            if ( path.indexOf(toNode) == 0 ) {  
              pos = destNodePos;
              srcNode =  (Node) map.graph.nodes.get(int(random(map.graph.nodes.size())));
              destNode =  (Node) map.graph.nodes.get(int(random(map.graph.nodes.size())));
              pos= new PVector(srcNode.x, srcNode.y);
              path=null;
              dir = new PVector(0.0, 0.0);
              // Not destination. Look for next node --->
            } else {  
              srcNode = toNode;
              toNode = path.get( path.indexOf(toNode)-1 );
            }
            // Not arrived to node --->
          } else {
            //distTraveled += dir.mag();
            pos.add( dir );
            //posDraw = PVector.add(pos, dir.normalize().mult(type.getStreetOffset()).rotate(HALF_PI));
          } 
  }  
}
