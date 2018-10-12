Drawer drawer;

float scale = 0.5;
public int displayWidth = int(2128*scale);
public int displayHeight = int(1330*scale);

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
  println(frameRate);
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
