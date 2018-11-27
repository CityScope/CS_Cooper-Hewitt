import ai.pathfinder.*;

public class RoadNetwork {
  private PVector size;
  private PVector[] bounds;  // [0] Left-Top  [1] Right-Bottom
  private Pathfinder graph;
  private String type;
  private int worldId;

  // There are nodes in 'zombie land'.
  // They are out of bounds of the map.  Agents come in and out of the
  // perimeter of the grid/world via zombie land nodes.
  private ArrayList<Node> zombieLandNodes;


  /* <--- CONSTRUCTOR ---> */
  RoadNetwork(String GeoJSONfile, String _type, int _worldId) {

    ArrayList<Node> nodes = new ArrayList<Node>();

    // Load file -->
    JSONObject JSON = loadJSONObject(GeoJSONfile);
    JSONArray JSONlines = JSON.getJSONArray("features");

    // Set map bounds -->
    setBoundingBox(JSONlines);

    type=_type;
    worldId=_worldId;

    // Import all nodes -->
    Node prevNode = null;
    for (int i=0; i<JSONlines.size(); i++) {

      JSONObject props = JSONlines.getJSONObject(i).getJSONObject("properties");
      boolean oneWay = props.isNull("oneway") ? false : props.getBoolean("oneway");

      JSONArray points = JSONlines.getJSONObject(i).getJSONObject("geometry").getJSONArray("coordinates");

      for (int j = 0; j<points.size(); j++) {
        // Point coordinates to XY screen position -->
        PVector pos = toXY(points.getJSONArray(j).getFloat(0), points.getJSONArray(j).getFloat(1));

        // Node already exists (same X and Y pos). Connect  -->
        Node existingNode = nodeExists(pos.x, pos.y, nodes);

        if (existingNode != null) {
          if (j > 0) {
            prevNode.connect(existingNode);
            if (!oneWay) {
              existingNode.connect(prevNode);
            }
          }
          prevNode = existingNode;
        } else {
          Node newNode = new Node(pos.x, pos.y);
          if (j > 0) {
            if (!oneWay) {
              prevNode.connectBoth(newNode);
            } else {
              prevNode.connect(newNode);
            }
          }
          nodes.add(newNode);
          prevNode = newNode;
        }
      }
      graph = new Pathfinder(nodes);
    }

    setupZombieLandNodes();
  }

  // RETURN EXISTING NODE (SAME COORDINATES) IF EXISTS -->
  private Node nodeExists(float x, float y, ArrayList<Node> nodes) {
    for (Node node : nodes) {
      if (node.x == x && node.y == y) {
        return node;
      }
    }
    return null;
  }

  // FIND NODES BOUNDS -->
  public void setBoundingBox(JSONArray JSONlines) {

    float minLng = 0;
    float minLat = 0;
    float maxLng = 1;
    float maxLat = 1;

    this.bounds = new PVector[] {new PVector(minLng, minLat), new PVector(maxLng, maxLat)};

    // Resize map keeping ratio -->
    float mapRatio = 1.6 / 1.0;
    this.size = new PVector(DISPLAY_WIDTH, DISPLAY_HEIGHT);
  }

  private PVector toXY(float x, float y) {
    return new PVector(
      map(x, this.bounds[0].x, this.bounds[1].x, 0, size.x), 
      map(y, this.bounds[0].y, this.bounds[1].y, size.y, 0)
      );
  }

  private void setupZombieLandNodes() {
    zombieLandNodes = new ArrayList<Node>();
    Node node; 
    for (int i=0; i<graph.nodes.size(); i++) {
      node = (Node) graph.nodes.get(i);
      if (node.x<0 || node.x>DISPLAY_WIDTH || node.y<0 || node.y>DISPLAY_HEIGHT) {
        zombieLandNodes.add(node);
      }
    }
  }

  public void draw(PGraphics p) {    
    for (int i = 0; i < graph.nodes.size(); i++) {
      Node tempN = (Node)graph.nodes.get(i);
      for (int j = 0; j < tempN.links.size(); j++) {
        if (showGlyphs) {
          p.stroke(universe.colorMapBW.get(type));
        } else {
          if (worldId==1) {
            p.stroke(universe.colorMapBad.get(type));
          } else {
            p.stroke(universe.colorMapGood.get(type));
          }
        }
        p.line(tempN.x, tempN.y, ((Connector)tempN.links.get(j)).n.x, ((Connector)tempN.links.get(j)).n.y);
      }
    }
  }

  public ArrayList<Node> getNodeInsideROI(PVector pos, int size) {
    ArrayList<Node> tmp = new ArrayList<Node>();
    Node tmpNode; 
    for (int i=0; i<graph.nodes.size(); i++) {
      tmpNode = (Node) graph.nodes.get(i);
      if (((tmpNode.x>pos.x-size/2) && (tmpNode.x)<pos.x+size/2) &&
        ((tmpNode.y>pos.y-size/2) && (tmpNode.y)<pos.y+size/2))
      {
        tmp.add(tmpNode);
      }
    }
    return tmp;
  }

  public Node getRandomNodeInsideROI(PVector pos, int size) {
    ArrayList<Node> tmp = new ArrayList<Node>();
    Node tmpNode; 
    for (int i=0; i<graph.nodes.size(); i++) {

      tmpNode = (Node) graph.nodes.get(i);
      if (((tmpNode.x>pos.x-size/2) && (tmpNode.x)<pos.x+size/2) &&
        ((tmpNode.y>pos.y-size/2) && (tmpNode.y)<pos.y+size/2))
      {
        tmp.add(tmpNode);
      }
    } 
    return tmp.get(int(random(tmp.size())));
  }

  public Node getRandomNodeInZombieLand() {
    return zombieLandNodes.get(int(random(zombieLandNodes.size())));
  }
} 

