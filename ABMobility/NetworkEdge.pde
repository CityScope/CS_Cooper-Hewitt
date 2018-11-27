class NetworkEdge {

  private int id;

  private Node start; 
  private Node end;
  private boolean isBidirectional;
  private float length;
  private ArrayList<NetworkEdge> connections;
  public boolean isVisible;

  public ArrayList<Agent> agents; 

  NetworkEdge(int _id, Node _start, Node _end, boolean _isBidirectional){
    id = _id;
    start = _start;
    end = _end;
    isBidirectional = _isBidirectional;
    length = dist(start.x, start.y, end.x, end.y);
    connections = new ArrayList<NetworkEdge>();
    isVisible = false;
    agents = new ArrayList<Agent>();
  }

  void draw(PGraphics p){
    if(isVisible){
      int agentsNum = agents.size();
      // float density = agentsNum / length;
      float red = min(map(agentsNum, 1, 4, 40, 255), 255);
      p.strokeWeight(10);
      p.stroke(red, 20, 20);
      p.strokeCap(p.SQUARE);
      p.line(start.x, start.y, end.x, end.y);
    }
  }

}

class NetworkEdgeManager {

  private ArrayList<NetworkEdge> edges;
  // we need this to search Nodes in O(1)
  private HashMap<Node, Integer> nodeToIndex; 
  // a hashmap that links two Nodes to one Edge
  // "aid-bid" -> edge
  private HashMap<String, NetworkEdge> idsToEdge;

  NetworkEdgeManager(){
    edges = new ArrayList<NetworkEdge>();
    nodeToIndex = new HashMap<Node, Integer>();
    idsToEdge = new HashMap<String, NetworkEdge>();
  }

  void mapNode(Node newNode){
    if(!nodeToIndex.containsKey(newNode)){
      int maxValue = nodeToIndex.size();
      nodeToIndex.put(newNode, maxValue);  
    } 
  }

  // creates and adds a Edge to it's edges collection.
  // also assigns the edge to a HashMap to be later accessed faster
  void add(Node start, Node end, boolean isBidirectional){
    int id = edges.size(); 
    NetworkEdge e = new NetworkEdge(id, start, end, isBidirectional);
    edges.add(e);
    String ids = nodesToIds(start, end);
    idsToEdge.put(ids, e);
    // if bidirectional, two keys 
    // ("aid-bid" and "bid-aid") points to one edge
    if(isBidirectional) {
      ids = nodesToIds(end, start);
      idsToEdge.put(ids, e);
    }
  }
  
  public NetworkEdge updateEdge(Agent agent, NetworkEdge oldEdge, Node newSrc, Node newDest){
    // 1. remove agent from old edge
    if(oldEdge != null){
      oldEdge.agents.remove(agent);
      if(oldEdge.agents.size() == 0) oldEdge.isVisible = false;
    }

    // 2. assignAgent to new Edge, return this edge
    NetworkEdge newEdge = idsToEdge.get(nodesToIds(newSrc, newDest));
    // TODO(Yasushi Sakai): what if null??
    newEdge.agents.add(agent);
    newEdge.isVisible = true;
    return newEdge;
  }

  // helper function to make "aid-bid" string
  private String nodesToIds(Node a, Node b){
    int idA = nodeToIndex.get(a); 
    int idB = nodeToIndex.get(b);
    return idA + "-" + idB; 
  }

  public void draw(PGraphics p){
    for(NetworkEdge e: edges){
      e.draw(p);
    }  
  }
}
