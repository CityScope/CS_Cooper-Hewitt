import hypermedia.net.*;
import controlP5.*;

int PORT = 5005;
String HOST_IP = "localhost"; 
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
  udp= new UDP(this);  
  // udp.log(true);
  // udp.listen(true);
  
  gui = new ControlP5(this);

  gui.addSlider("slider")
    .setPosition(50, 50)
    .setSize(500, 50)
    .setRange(0.0, 1.0)
    .setValue(0.5);

  RadioButton r = gui.addRadioButton("selectedBId")
    .setPosition(50, 525)
    .setSize(15, 15)
    .setItemsPerRow(10)
    .setSpacingColumn(15);
  
  for(int i = -1;i < 24; i++){
    r.addItem(i + "", i);
  }

  gui.addSlider("sendInterval")
    .setPosition(50, 600)
    .setSize(380, 50)
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

void draw() {

  if((millis() - lastSend) > sendInterval && send){
    JSONObject compiled = compileJson();
    // println(compiled.toString());
    udp.send(compiled.toString(), HOST_IP, PORT);
    println("sent."); 
    lastSend = millis();
    background(0, 0, 255);
  } else {
    int b =int(map(millis() - lastSend, 0, sendInterval, 50, 255));
    background(0, 0, b);
  }

  pushMatrix();
  translate(50, 150);
  noFill();
  stroke(0);
  //  rect(0, 0, 500, 350);
  tableRect.draw();
  for(Plot p: plots){
    p.draw();
  }
  popMatrix();

}

void mousePressed() {
  // udp.send(s,HOST_IP,PORT);
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
    cell.setInt(1, 0);
    grid.setJSONArray(i, cell); 
  }

  // slider is a array
  
  JSONArray sliderArray = new JSONArray();
  sliderArray.setFloat(0, slider);

  data.setJSONArray("grid", grid);
  data.setJSONArray("slider", sliderArray);

  return data;
}
