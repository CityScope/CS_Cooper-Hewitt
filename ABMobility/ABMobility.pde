State state = new State();
Drawer drawer;

float scale = 0.5;
public final int SIMULATION_WIDTH = 2128;
public final int SIMULATION_HEIGHT = 1330;

public int displayWidth = int(SIMULATION_WIDTH * scale);
public int displayHeight = int(SIMULATION_HEIGHT * scale);

public int playGroundWidth = displayWidth;
public int playGroundHeight = displayHeight;

PImage bg;
Universe universe;
boolean showWorldType= false;
UDPReceiver udpR;

void setup(){

  // global state holder (an exuse for trivial dynamic global variables)
  State state = new State();

  //fullScreen(P3D, SPAN);
  size(displayWidth, displayHeight, P3D);
  drawer = new Drawer(this);
  bg = loadImage("data/image/background_0.png");
  drawer.initSurface();
  universe = new Universe();
  universe.InitUniverse();
  udpR = new UDPReceiver();
} 

void draw(){
  drawScene();
}

/* Draw ------------------------------------------------------ */
void drawScene() {
  background(0);
  drawer.drawSurface();
}

void keyPressed() {
  switch(key) {
    //Keystone trigger  
  case 'k':
    drawer.ks.toggleCalibration();
    break;  
  case 'l':
    drawer.ks.load();
    break; 
  case 's':
    drawer.ks.save();
    break;
  case 'z':
    state.slider = 0; 
  break;
  case 'x':
    state.slider = max(state.slider - 0.05, 0); 
  break;
  case 'c':
    state.slider = 0.5;
  break;
  case 'v':
    state.slider = min(state.slider + 0.05, 1);
  break;
  case 'b':
    state.slider = 1;
  break;
  case 'w':
    showWorldType=!showWorldType;
  break;
  }
}
