import hypermedia.net.*;
import controlP5.*;

int SIMULATION_PORT = 5005; 
int UNITY_PORT = 7777; 
String LOCALHOST = "localhost"; 
String BAD_COMPUTER_IP = "192.168.1.102";
//IP Address of the PC in which this App is running

UDP udp;
//Create UDP object for recieving
private ArrayList<String> strings;

ArrayList<Plot> plots;
Rectangle tableRect;

ControlP5 gui;
float slider;
boolean send;
int lastSend;
int sendInterval;
int selectedPId; // plot Id
int selectedBId; // block Id

PFont font;

void setup(){
  size(600, 700);
  udp = new UDP(this);  
  
  gui = new ControlP5(this);

  gui.addSlider("slider")
    .setPosition(50, 50)
    .setSize(500, 15)
    .setRange(1.0, 0.0)
    .setValue(0.5);

  RadioButton r = gui.addRadioButton("selectedBId")
    .setPosition(50, 525)
    .setSize(15, 15)
    .setItemsPerRow(9)
    .setSpacingColumn(17);

  gui.addButton("randomize")
    .setPosition(350, 525)
    .setSize(50, 50);

  gui.addButton("preset")
    .setPosition(425, 525)
    .setSize(50, 50);

  gui.addButton("resetPlots")
    .setPosition(500, 525)
    .setSize(50, 50);

  for(int i = -1;i < 24; i++){
    r.addItem(i + "", i);
  }

  gui.addSlider("sendInterval")
    .setPosition(50, 600)
    .setSize(380, 15)
    .setRange(50, 3000)
    .setValue(1000);

  send = false;
  gui.addToggle("send")
    .setPosition(500, 600)
    .setSize(50, 50)
    .setValue(false);

  plots = new ArrayList<Plot>();
  for(int i=0; i < 18; i++){
    plots.add(new Plot(i));
  }

  tableRect = new Rectangle(0, 0, 500, 350);

  font = createFont("Arial", 10);
  textFont(font);
  textAlign(CENTER, CENTER);

  lastSend = millis();
}

void selectedBId(int bId){
  println("selected BId: ", bId);
  Plot p = plots.get(selectedPId);
  p.buildingId = bId;
}

void resetPlots(){
  for(Plot p: plots){
    p.reset();
  }
}

void preset(){
  for(Plot p: plots){
    p.reset();
    p.sameAsId();
  }
}

// you will need to first "resetPlots"
// wait for sendInterval and then push.
void randomize() {
  IntList buildingIds = new IntList();
  for(int i=0;i < 25;i++){
    buildingIds.append(i);
  }
  buildingIds.shuffle();
  for(int i=0; i< 18; i++){
    Plot p = plots.get(i);
    p.buildingId = buildingIds.get(i);
    p.rotation = int(random(0,4));
  }
}

void draw() {
  if((millis() - lastSend) > sendInterval && send){
    JSONObject compiled = compileJson();
    println(compiled.toString());
    udp.send(compiled.toString(), LOCALHOST, SIMULATION_PORT);
    udp.send(compiled.toString(), BAD_COMPUTER_IP, UNITY_PORT);
    lastSend = millis();
    background(0, 0, 255);
  } else {
    int b =int(map(millis() - lastSend, 0, sendInterval, 50, 255));
    background(0, 0, b);
  }

  pushMatrix();
  translate(50, 75);
  noFill();
  stroke(0);
  // tableRect.draw();
  for(Plot p: plots){
    p.draw();
  }
  popMatrix();

}

void mousePressed() {
  int x = mouseX - 50;
  int y = mouseY - 150;
  if(tableRect.isInside(x, y)){
    for(Plot p: plots){
      if(p.isInside(x, y)){
        p.setSelected(true);
        selectedPId = p.id;
      } else {
        p.setSelected(false);
      }
    }
  }
}

JSONObject compileJson () {
  JSONObject data = new JSONObject();
  JSONArray grid = new JSONArray();

  for(int i = 0; i < 18; i++){
    Plot p = plots.get(i);
    JSONArray cell = new JSONArray();
    cell.setInt(0, p.buildingId);
    cell.setInt(1, p.rotation);
    grid.setJSONArray(i, cell); 
  }

  // slider is a array
  JSONArray sliderArray = new JSONArray();
  sliderArray.setFloat(0, slider);

  data.setJSONArray("grid", grid);
  data.setJSONArray("slider", sliderArray);

  return data;
}
