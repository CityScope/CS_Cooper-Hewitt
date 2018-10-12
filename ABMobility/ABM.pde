/* ABM CLASS ------------------------------------------------------------*/
public class ABM {
  private RoadNetwork map;
  private ArrayList<Agent> agents;
  
  ABM(RoadNetwork _map){
    map=_map;
    agents = new ArrayList<Agent>();
  }
  
  public void initModel(){
    createAgents(5000);
  }
  
  public void run(PGraphics p){
    for (Agent agent : agents) {
      agent.move(1);
      agent.draw(p);
    }
  }
  
  public void createAgents(int num) {
    for (int i = 0; i < num; i++){
      agents.add( new Agent(map));
    }
  } 
}

public class Agent{
  private RoadNetwork map;
  private PVector pos;
  private Node srcNode, destNode, toNode;
  private ArrayList<Node> path;
  private PVector dir;
  
  Agent(RoadNetwork _map){
    map=_map;
    initAgent();
  }
  
  
  public void initAgent(){
    srcNode =  (Node) map.graph.nodes.get(int(random(map.graph.nodes.size())));
    destNode =  (Node) map.graph.nodes.get(int(random(map.graph.nodes.size())));
    pos= new PVector(srcNode.x,srcNode.y);
    path=null;
    dir = new PVector(0.0, 0.0);
  }
    
  public void draw(PGraphics p){
    p.noStroke();
    p.fill(255,0,0);
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
