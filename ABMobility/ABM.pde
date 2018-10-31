/* ABM CLASS ------------------------------------------------------------*/

public class Universe {
  // This is a universe with two alternatives for future worlds.
   private World world1;
   private World world2;
   // Booleans manage threading of world updates.
   private boolean updatingWorld1;
   private boolean updatingWorld2;
   HashMap<String,Integer> colorMap;
   HashMap<String, PImage[]> glyphsMap;
   Grid grid;

   PShader s;
   PGraphics pg;
   
   Universe(){
     colorMap = new HashMap<String,Integer>();
     colorMap.put("car",#FF0000);colorMap.put("bike",#00FF00);colorMap.put("ped",#0000FF);
     // Create the glyphs and hold in map
     PImage[] carGlyph = new PImage[1];
     carGlyph[0] = loadImage("image/car.gif");
     PImage[] bikeGlyph = new PImage[2];
     bikeGlyph[0] = loadImage("image/bike-0.gif");
     bikeGlyph[1] = loadImage("image/bike-1.gif");
     PImage[] pedGlyph = new PImage[3];
     pedGlyph[0] = loadImage("image/human-0.gif");
     pedGlyph[1] = loadImage("image/human-1.gif");
     pedGlyph[2] = loadImage("image/human-2.gif");
     glyphsMap = new HashMap<String, PImage[]>();
     glyphsMap.put("car", carGlyph);
     glyphsMap.put("bike", bikeGlyph);
     glyphsMap.put("ped", pedGlyph);

     grid = new Grid();
     world1 = new World(1, "image/background_01.png", glyphsMap);
     world2 = new World(2, "image/background_02.png", glyphsMap);
     updatingWorld1 = false;
     updatingWorld2 = false;

      s = loadShader("mask.glsl");
      s.set("width", float(displayWidth));
      s.set("height", float(displayHeight));
      s.set("left", world1.pg);
      s.set("right", world2.pg);
      s.set("divPoint", state.slider);
     pg = createGraphics(displayWidth, displayHeight, P2D);
   }
   
   void InitUniverse(){
     world1.InitWorld();
     world2.InitWorld();
   }

   void update() {
    // Update the worlds and models + agents they contain
    // in separate threads than the main thread which draws
    // the graphics.
    if (!updatingWorld1) {
      updatingWorld1 = true;
      Thread t1 = new Thread(new Runnable() {
        public void run(){
          world1.update();
          updatingWorld1 = false;
        }
      });
      t1.start();
    }
    if (!updatingWorld2) {
      updatingWorld2 = true;
      Thread t2 = new Thread(new Runnable() {
        public void run(){
          world2.update();
          updatingWorld2 = false;
        }
      });
      t2.start();
    }
   }

   void updateGraphics(float slider){
    world1.updateGraphics();
    world2.updateGraphics();

    s.set("divPoint", slider);
    pg.beginDraw();
    pg.shader(s);
    pg.rect(0, 0, pg.width, pg.height);
    pg.endDraw();
   }
   
   void draw(PGraphics p, float slider){
    int stitchEdge = Math.round(displayWidth * slider);
    p.image(pg, 0, 0);
    // draw the center line
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

  World(int _id, String _background, HashMap<String, PImage[]> _glyphsMap){
    id = _id;
    background = loadImage(_background);
    
    networks = new ArrayList<RoadNetwork>();
    models = new ArrayList<ABM>();
    
    //FIXME : temporary remove the broken graph
    /*networks.add(new RoadNetwork("network/simple_and_complex_network/car_1.geojson","car"));
    networks.add(new RoadNetwork("network/simple_and_complex_network/car_1.geojson","bike"));
    networks.add(new RoadNetwork("network/simple_and_complex_network/car_1.geojson","ped"));*/
    
    networks.add(new RoadNetwork("network/Complex_network/car_"+id+".geojson","car"));
    networks.add(new RoadNetwork("network/Complex_network/bike_"+id+".geojson","bike"));
    networks.add(new RoadNetwork("network/Complex_network/ped_"+id+".geojson","ped"));
    
    models.add(new ABM(networks.get(0),"car",id, _glyphsMap));
    models.add(new ABM(networks.get(1),"bike",id, _glyphsMap));
    models.add(new ABM(networks.get(2),"ped",id, _glyphsMap));

    pg = createGraphics(displayWidth, displayHeight, P2D);
  }
  
  public void InitWorld(){
    //Bad 
    if(id==1){
      models.get(0).initModel(400);
      models.get(1).initModel(250);
      models.get(2).initModel(150);
    }
    //Good
    if(id == 2){
      models.get(0).initModel(50);
      models.get(1).initModel(250);
      models.get(2).initModel(400);
    }
   
  }

  public void update(){
    for(ABM m: models){
      m.update();
    }
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
    if(showBackground){
      pg.image(background, 0, 0, pg.width, pg.height);
    }
    
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
  private HashMap<String, PImage[]> glyphsMap;
  private ArrayList<Agent> agents;
  private String type;
  private int worldId;
  public color modelColor;
  
  ABM(RoadNetwork _map, String _type, int _worldId, HashMap<String, PImage[]> _glyphsMap){
    map=_map;
    glyphsMap = _glyphsMap;
    agents = new ArrayList<Agent>();
    type= _type;
    worldId= _worldId;
  }
  
  public void initModel(int nbAgent){
    agents.clear();
    createAgents(nbAgent);
  }


  // NOTE(Yasushi Sakai): maybe better to multithread this too.
  // but the ABM might be flattened and hold
  // mutliple models and agents.
  // Same to this version's World
  public void update(){
    for(Agent a : agents){
      a.update();
    }
  }
  
  public void draw(PGraphics p){
    if(showNetwork){
      map.draw(p); 
    }
    for (Agent agent : agents) {
      agent.draw(p,showGlyphs);
    }
  }
  
  public void createAgents(int num) {
    for (int i = 0; i < num; i++){
      agents.add(new Agent(map, type, glyphsMap));
    }
  } 
}
