import ai.pathfinder.*;

public class RoadNetwork {
  private PVector size;
  private float scale;
  private PVector[] bounds;  // [0] Left-Top  [1] Right-Bottom
  private Pathfinder graph;
  /* <--- CONSTRUCTOR ---> */
  RoadNetwork(String GeoJSONfile) {

    ArrayList<Node> nodes = new ArrayList<Node>();
    
    // Load file -->
    JSONObject JSON = loadJSONObject(GeoJSONfile);
    JSONArray JSONlines = JSON.getJSONArray("features");
    
     // Set map bounds -->
    setBoundingBox(JSONlines);
    
    // Import all nodes -->
    Node prevNode = null;
    for(int i=0; i<JSONlines.size(); i++) {
      
      JSONObject props = JSONlines.getJSONObject(i).getJSONObject("properties");
      boolean oneWay = props.isNull("oneway") ? false : props.getBoolean("oneway");
      
      JSONArray points = JSONlines.getJSONObject(i).getJSONObject("geometry").getJSONArray("coordinates");

      for(int j = 0; j<points.size(); j++) {
           // Point coordinates to XY screen position -->
        PVector pos = toXY(points.getJSONArray(j).getFloat(0), points.getJSONArray(j).getFloat(1));
        
        // Node already exists (same X and Y pos). Connect  -->
        Node existingNode = nodeExists(pos.x, pos.y, nodes);

        if(existingNode != null){
          if(j > 0){
            prevNode.connect(existingNode);
            if(!oneWay){
              existingNode.connect(prevNode);
            }
          }
          prevNode = existingNode;
        } else {
          Node newNode = new Node(pos.x, pos.y);
          if(j > 0){
            if(!oneWay){
              prevNode.connectBoth(newNode);
            } else {
              prevNode.connect(newNode);
            }
          }
          nodes.add(newNode);
          prevNode = newNode;
        }
      }
    }
    graph = new Pathfinder(nodes); 
  }
    
    
   // RETURN EXISTING NODE (SAME COORDINATES) IF EXISTS -->
  private Node nodeExists(float x, float y, ArrayList<Node> nodes) {
    for(Node node : nodes) {
      if(node.x == x && node.y == y) {
        return node;
      }
    }
    return null;
  }
  
  // FIND NODES BOUNDS -->
  public void setBoundingBox(JSONArray JSONlines) {
    // float minLat = Float.MAX_VALUE,
    //       minLng = Float.MAX_VALUE,
    //       maxLat = -Float.MAX_VALUE,
    //       maxLng = -Float.MAX_VALUE;
    // for(int i=0; i<JSONlines.size(); i++) {
    //   JSONArray points = JSONlines.getJSONObject(i).getJSONObject("geometry").getJSONArray("coordinates");
    //   for(int j=0; j<points.size(); j++) {
    //     float Lat = points.getJSONArray(j).getFloat(1);
    //     float Lng = points.getJSONArray(j).getFloat(0);
    //     if( Lat < minLat ) minLat = Lat;
    //     if( Lat > maxLat ) maxLat = Lat;
    //     if( Lng < minLng ) minLng = Lng;
    //     if( Lng > maxLng ) maxLng = Lng;
    //   }
    // }

    float minLng = 0;
    float minLat = 0;
    float maxLng = 1;
    float maxLat = 1;
    
    // Conversion to Mercator projection -->
    // PVector coordsTL = toWebMercator(minLat, minLng);
    // PVector coordsBR = toWebMercator(maxLat, maxLng);
    // this.bounds = new PVector[] { coordsTL, coordsBR };
    this.bounds = new PVector[] {new PVector(minLng, minLat), new PVector(maxLng, maxLat)};
    
    // Resize map keeping ratio -->
    // float mapRatio = (coordsBR.x - coordsTL.x) / (coordsBR.y - coordsTL.y);
    float mapRatio = 1.6 / 1.0;
    // this.size = mapRatio < 1 ? new PVector( height * mapRatio, height ) : new PVector( width , width / mapRatio ) ;
    this.size = new PVector(SIMULATION_WIDTH * 0.5, SIMULATION_HEIGHT * 0.5);
    
    println("Bounding Box" + "size" + this.size + "scale" + this.scale);
  }

  
  // LAT, LNG COORDINATES TO XY SCREEN POINTS -->
  // private PVector toXY(float lat, float lng) {
  //   PVector projectedPoint = toWebMercator(lat, lng);
  //   return new PVector(
  //     map(projectedPoint.x, bounds[0].x, bounds[1].x, 0, size.x),
  //     map(projectedPoint.y, bounds[0].y, bounds[1].y, size.y, 0)
  //   );
  // }

  private PVector toXY(float x, float y) {
    return new PVector(
      map(x, this.bounds[0].x, this.bounds[1].x, 0, size.x),
      map(y, this.bounds[0].y, this.bounds[1].y, size.y, 0)
    );
  }
  
  public void draw(PGraphics p){    
    for(int i = 0; i < graph.nodes.size(); i++){
      Node tempN = (Node)graph.nodes.get(i);
      for(int j = 0; j < tempN.links.size(); j++){
        p.stroke(#AAAAAA); p.strokeWeight(1);
        p.line(tempN.x, tempN.y, ((Connector)tempN.links.get(j)).n.x, ((Connector)tempN.links.get(j)).n.y);
      }
    }  
  }
} 
