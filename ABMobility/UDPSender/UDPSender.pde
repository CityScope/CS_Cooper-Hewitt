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
  strings.add("1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18");
  strings.add("3,2,1,5,4,6,8,7,9,10,11,13,12,15,14,18,16,17");
  strings.add("2,1,3,5,4,6,8,7,9,10,11,12,13,15,16,16,18,17");
  strings.add("2,1,3,4,6,5,9,7,8,11,10,12,16,15,13,16,18,17");
}

//process events
void draw() {;}

void receive(byte[] data){
  println("Processing received an unexpected message");   
}

void mousePressed() {
    String s = strings.get(int(random(2)));
    println("sending " + s + " to " + HOST_IP + " port:" + PORT);
    udp.send(s,HOST_IP,PORT);
}
