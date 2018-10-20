/* ABM CLASS ------------------------------------------------------------*/

public class Universe{
   private ArrayList<World> worlds;
   HashMap<String,Integer> colorMap;
   Grid grid;
   PGraphics pg;
   
   Universe(){
     colorMap = new HashMap<String,Integer>();
     colorMap.put("car",#FF0000);colorMap.put("bike",#00FF00);colorMap.put("ped",#0000FF);
     worlds = new ArrayList<World>();
     grid = new Grid();

     worlds.add(new World(1, "image/background_01.png"));
     worlds.add(new World(2, "image/background_02.png"));

     pg = createGraphics(displayWidth, displayHeight, P2D);
   }
   
   void InitUniverse(){
     for (World w:worlds){
       w.InitWorld();
     }
   }

   // TODO(Yasushi Sakai): we should probably do this using shaders
   void stitchWorlds (PGraphics p, float ratio) {
      int stitchEdge = Math.round(displayWidth * ratio);

      // we draw the bad world by default; 
      worlds.get(0).draw(p);

      // this is slow...
      World rightWorld = worlds.get(1);
      rightWorld.updateGraphics();

      rightWorld.pg.loadPixels();
      for(int i = 0; i < stitchEdge; i++){
        for(int j = 0; j < displayHeight; j++){
          int index = j * displayWidth + i;
          rightWorld.pg.pixels[index] = color(0, 0, 0, 0);
        }
      }
      rightWorld.pg.updatePixels();

      p.image(rightWorld.pg, 0, 0);
   }


   void update(){
    for(World w: worlds){
      w.update();
    }
   }
   
   void draw(PGraphics p, float slider){

    // stitchWorlds(slider);
    int stitchEdge = Math.round(displayWidth * slider);
    
    // p.image(pg, 0, 0);
    stitchWorlds(p, slider);
    p.pushStyle();
      p.stroke(255);
      p.line(stitchEdge, 0, stitchEdge, displayHeight);
    p.popStyle();
   }
   
}

public class World{
  private ArrayList<ABM> models;
  private ArrayList<RoadNetwork> networks;
  
  int id;

  PImage background;
  PGraphics pg;

  World(int _id, String _background){
    id = _id;
    background = loadImage(_background);
    
    networks = new ArrayList<RoadNetwork>();
    models = new ArrayList<ABM>();
    
    networks.add(new RoadNetwork("network/car_"+id+".geojson"));
    networks.add(new RoadNetwork("network/bike_"+id+".geojson"));
    networks.add(new RoadNetwork("network/ped_"+id+".geojson"));
    
    models.add(new ABM(networks.get(0),"car",id));
    models.add(new ABM(networks.get(1),"bike",id));
    models.add(new ABM(networks.get(2),"ped",id));

    pg = createGraphics(displayWidth, displayHeight, P2D);
  }
  
  public void InitWorld(){
    //Bad 
    if(id==1){
      models.get(0).initModel(600);
      models.get(1).initModel(200);
      models.get(2).initModel(100);
    }
    //Good
    if(id == 2){
      models.get(0).initModel(100);
      models.get(1).initModel(500);
      models.get(2).initModel(300);
    }
   
  }

  public void update(){
    // NOTE(Yasushi Sakai): using a threadpool is better?
    Thread t = new Thread(new Runnable() {
      public void run(){
        for(ABM m: models){
          m.update();
        }
      }
    });
    t.start();
  }

  public void draw(PGraphics p){
    p.background(0);
    p.image(background, 0, 0, p.width, p.height);

    for (ABM m: models){
      m.draw(p);
    }
  }

  public void updateGraphics() {
    pg.beginDraw();

    pg.background(0);
    pg.image(background, 0, 0, pg.width, pg.height);
    
    for(ABM m: models){
      m.draw(pg);
    }

    pg.endDraw();
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
  
  public void initModel(int nbAgent){
    createAgents(nbAgent);
  }


  // NOTE(Yasushi Sakai): maybe better to multithread this too.
  // but the ABM might be flattened and hold
  // mutliple models and agents.
  // Same to this version's World
  public void update(){
    for(Agent a : agents){
      a.update(1);
    }
  }
  
  public void draw(PGraphics p){
    for (Agent agent : agents) {
      agent.draw(p);
    }
  }
  
  public void createAgents(int num) {
    for (int i = 0; i < num; i++){
      agents.add(new Agent(map,type,worldId));
    }
  } 
}

public class Agent{
  private RoadNetwork map; // NOTE(Yasushi Sakai): this is a reference to the map right?
  private String type;
  private PImage[] glyph;
  private int worldId;
  private color myColor;
  private PVector pos;
  private Node srcNode, destNode, toNode; // toNode is like next node
  private ArrayList<Node> path;
  private PVector dir;
  
  Agent(RoadNetwork _map, String _type, int _worldId){
    map = _map;
    type = _type;

    // TODO(Yasushi Sakai): Previous Glyphs are faster??
    switch(type){
      case "car" :
        glyph = new PImage[1];
        glyph[0] = loadImage("image/" + type + ".gif");
      break;
      case "bike" :
        glyph = new PImage[2];
        glyph[0] = loadImage("image/" + type + "-0.gif");
        glyph[1] = loadImage("image/" + type + "-1.gif");
      break;
      case "ped" :
        glyph = new PImage[3];
        glyph[0] = loadImage("image/" + "human" + "-0.gif");
        glyph[1] = loadImage("image/" + "human" + "-1.gif");
        glyph[2] = loadImage("image/" + "human" + "-2.gif");
      break;
      default:
      break;
    }

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
    PImage img = glyph[frameCount % glyph.length];
    
    p.pushMatrix();
      p.translate(pos.x, pos.y);
      p.rotate(dir.heading() + PI * 0.5);
      p.translate(-1, 0);
      p.image(img, 0, 0, img.width * scale, img.height * scale);
    p.popMatrix();
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
  
  public void update(float speed) {
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
