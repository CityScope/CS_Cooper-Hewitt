State state = new State();
Drawer drawer;

float SCALE = 1.0;
public final int SIMULATION_WIDTH = 2128;
public final int SIMULATION_HEIGHT = 1330;
public final int GRID_CELL_SIZE = int((SIMULATION_WIDTH/16)*SCALE);
public final int BUILDING_SIZE = int((SIMULATION_WIDTH/16)*SCALE*2);

public int DISPLAY_WIDTH = int(SIMULATION_WIDTH * SCALE);
public int DISPLAY_HEIGHT = int(SIMULATION_HEIGHT * SCALE);

public int playGroundWidth = DISPLAY_WIDTH;
public int playGroundHeight = DISPLAY_HEIGHT;

public boolean INIT_AGENTS_FROM_DATAFILE = true;
public final String SIMULATED_POPULATION_DATA_FILEPATH = "data/simPop.csv";
public final int NUM_AGENTS_PER_WORLD = 1000;


Universe universe;
boolean showBuilding = true;
boolean showBackground = true;
boolean showGlyphs = true;
boolean showNetwork = false;
boolean showAgent = true;
boolean showZombie = false;
boolean dynamicSlider = true;
boolean showCollisionPotential = false;
boolean showConnectionBetweenAgentAndBuilding = false;
boolean showRemaninginAgentAndBuilding = false;
boolean animatedGlyph = false;
boolean devMode = false;
UDPReceiver udpR;

void settings() {
  fullScreen(P3D, SPAN);
}

void setup() {
  drawer = new Drawer(this);
  drawer.initSurface();
  universe = new Universe();
  universe.InitUniverse();
  udpR = new UDPReceiver();
  if(!devMode){
    drawer.ks.load();
  }
  frameRate(30);
} 

void draw() {
  drawScene();
}

/* Draw ------------------------------------------------------ */
void drawScene() {
  background(0);
  drawer.drawSurface();
}

void keyPressed() {
  switch(key) { 
  case 'k':
    drawer.ks.toggleCalibration();
    break;  
  case 'l':
    drawer.ks.load();
    break; 
  case 's':
    drawer.ks.save();
    break;
  case 'c':
    showCollisionPotential=!showCollisionPotential;
    break;
  case 'b':
    showBuilding= !showBuilding;
    break;
  case 't':
    universe.grid.resetAnimation(); 
    break;
  case ' ':
    showBackground=!showBackground;
    break;
  case 'g':
    showGlyphs = !showGlyphs;
    break;
  case 'a':
    animatedGlyph = !animatedGlyph;
    break;
  case 'n':
    showNetwork = !showNetwork;
    break;
  case 'd':
    dynamicSlider = !dynamicSlider;
    break;
  case 'z':
    showZombie=!showZombie;
    break;
  }

  if (key == CODED) {
    switch (keyCode) {
    case LEFT:
      state.slider = max(state.slider - 0.05, 0); 
      break;
    case RIGHT:
      state.slider = max(state.slider + 0.05, 0); 
      break;
    }
  }
}
