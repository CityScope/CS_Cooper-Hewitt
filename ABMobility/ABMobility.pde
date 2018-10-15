Drawer drawer;

float scale = 0.5;
public final int SIMULATION_WIDTH = 2128;
public final int SIMULATION_HEIGHT = 1330;

public int displayWidth = int(SIMULATION_WIDTH * scale);
public int displayHeight = int(SIMULATION_HEIGHT * scale);

public int playGroundWidth = displayWidth;
public int playGroundHeight = displayHeight;
PImage bg;
World world;

void setup(){
  //fullScreen(P3D, SPAN);
  size(displayWidth, displayHeight, P3D);
  drawer = new Drawer(this);
  bg = loadImage("data/background_0.png");
  drawer.initSurface();
  world = new World();
  world.InitWorld();
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
  }
}
