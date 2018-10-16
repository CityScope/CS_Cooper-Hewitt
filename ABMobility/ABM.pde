/* ABM CLASS ------------------------------------------------------------*/

public class Universe{
   private ArrayList<World> worlds;
   HashMap<String,Integer> colorMap;
   
   Universe(){
     colorMap = new HashMap<String,Integer>();
     colorMap.put("car",#FF0000);colorMap.put("bike",#00FF00);colorMap.put("ped",#0000FF);
     worlds = new ArrayList<World>();
     worlds.add(new World(1));
     worlds.add(new World(2));
   }
   
   void InitUniverse(){
     for (World w:worlds){
       w.InitWorld();
     }
   }
   
   void run(PGraphics p){
     if(goodWorld == true){
       worlds.get(0).run(p);
     }else{
       worlds.get(1).run(p);
     }
   }
}

public class World{
  private ArrayList<ABM> models;
  private ArrayList<RoadNetwork> networks;
  
  int id;
  
  World(int _id){
    id = _id;
    
    networks = new ArrayList<RoadNetwork>();
    models = new ArrayList<ABM>();
    
    networks.add(new RoadNetwork("network/car_"+id+".geojson"));
    networks.add(new RoadNetwork("network/bike_"+id+".geojson"));
    networks.add(new RoadNetwork("network/ped_"+id+".geojson"));
    
    models.add(new ABM(networks.get(0),"car",id));
    models.add(new ABM(networks.get(1),"bike",id));
    models.add(new ABM(networks.get(2),"ped",id));
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


// ABM stands for Agent Based Model.
// Holds a pair of a single specific type of agent and a Road Network
public class ABM {
  private RoadNetwork map;
  private ArrayList<Agent> agents;
  private String type;
  private int worldId;
  public color modelColor;
  
  ABM(RoadNetwork _map, String _type, int _worldId){
    map=_map;
    agents = new ArrayList<Agent>();
    type= _type;
    worldId= _worldId;
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
      agents.add( new Agent(map,type,worldId));
    }
  } 
}

public class Agent{
  private RoadNetwork map;
  private String type;
  private int worldId;
  private color myColor;
  private PVector pos;
  private Node srcNode, destNode, toNode; // toNode is like next node
  private ArrayList<Node> path;
  private PVector dir;
  
  Agent(RoadNetwork _map, String _type, int _worldId){
    map=_map;
    type=_type;
    worldId=_worldId;
    initAgent();
  }
  
  public void initAgent(){
    boolean isAdjecent = true;
    while(srcNode == destNode || isAdjecent) {
      srcNode =  (Node) map.graph.nodes.get(int(random(map.graph.nodes.size())));
      destNode =  (Node) map.graph.nodes.get(int(random(map.graph.nodes.size())));
      isAdjecent = srcNode.connectedTo(destNode);
    }    
    
    pos = new PVector(srcNode.x,srcNode.y);
    path = null;
    dir = new PVector(0.0, 0.0);
    myColor= universe.colorMap.get(type);
  }
    
  public void draw(PGraphics p){
    p.noStroke();
    if(showWorldType == true){
      if(worldId == 1){
       p.fill(#FF0000);
      }
      if(worldId == 2){
       p.fill(#00FF00);
      }
    }
    else{
      p.fill(myColor);
    }
    
    p.ellipse(pos.x, pos.y, 5, 5);
  }
    
  // CALCULATE ROUTE --->
  private boolean calcRoute() {
    // Agent already in destination --->
    if (srcNode == destNode) {
      toNode = destNode;
      return true;
      // Next node is available --->
    }  else {
        ArrayList<Node> newPath = map.graph.aStar(srcNode, destNode);
        if ( newPath != null ) {
          path = newPath;
          toNode = path.get(path.size() - 2); // what happens if there are only two nodes?
          return true;
        }
    }
    return false;
  }
  
    public void move(float speed) {
        if (path == null){
          calcRoute();
        }
        PVector toNodePos= new PVector(toNode.x,toNode.y);
        PVector destNodePos= new PVector(destNode.x,destNode.y);
        dir = PVector.sub(toNodePos, pos);  // unnormalized direction to go
          // Arrived to node -->
          if (dir.mag() < dir.normalize().mult(speed).mag() ) {
            // Arrived to destination  --->
            if (path.indexOf(toNode) == 0 ) {  
              pos = destNodePos; // ?
              this.initAgent();
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
