import hypermedia.net.*;

int PORT = 9877;
String HOST_IP = "localhost"; //IP Address of the PC in which this App is running
UDP udp; //Create UDP object for recieving
private ArrayList<String> strings;


void setup(){
  udp= new UDP(this);  
  udp.log(true);
  udp.listen(true);
  noLoop();
  strings = new ArrayList<String> ();
  strings.add("{\"grid\":[[-1,-1],[-1,-1],[-1,-1],[19,3],[-1,-1],[-1,-1],[-1,-1],[-1,-1],[-1,-1],[19,3],[-1,-1],[-1,-1],[-1,-1],[-1,-1],[-1,-1],[-1,-1],[-1,-1],[-1,-1]]}");
  strings.add("{\"grid\":[[0,0],[1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0],[9,0],[10,0],[11,0],[12,0],[13,0],[14,0],[15,0],[16,0],[17,0]]}");
  strings.add("{\"grid\":[[17,0],[16,0],[15,0],[14,0],[13,0],[12,0],[11,0],[10,0],[9,0],[8,0],[7,0],[6,0],[5,0],[4,0],[3,0],[2,0],[1,0],[0,0]]}");
}

//process events
void draw() {;}

void receive(byte[] data){
  println("Processing received an unexpected message");   
}

void mousePressed() {
    String s = strings.get(int(random(3)));
    println("sending " + s + " to " + HOST_IP + " port:" + PORT);
    udp.send(s,HOST_IP,PORT);
}
