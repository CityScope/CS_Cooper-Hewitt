Drawer drawer;

float scale = 1;
public int displayWidth = int(1080*2*scale);
public int displayHeight = int(1920*scale);

public int playGroundWidth = displayWidth;
public int playGroundHeight = displayHeight;
PImage bg;
RoadNetwork roads;

void setup(){
  //fullScreen(P3D, SPAN);
  size(displayWidth, displayHeight, P3D);
  drawer = new Drawer(this);
  bg = loadImage("data/Skeleton.png");
  drawer.initSurface();
  roads = new RoadNetwork("Roads.geojson");
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
