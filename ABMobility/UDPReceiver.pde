import hypermedia.net.*;


public class UDPReceiver{
  UDP udp;  // define the UDP object
  int PORT = 5005; 
  String HOST_IP = "localhost";
  int index;
  
  //boolean messageDelta = false;
  String[] oldSplitParts;
  String oldMessage = "";
  
  String[] splitParts;
  String messageIn = "";
  
    
  UDPReceiver(){
    udp = new UDP( this, PORT ); //from Termite desktop
    udp.listen( true );
    println("I listen to" + PORT); 
  
  }
  void receive( byte[] data, String ip, int port ) {  // <-- extended handler
    messageIn = new String( data );
    //println( "receive: \""+messageIn+"\" from "+ip+" on port "+port );
    if (!messageIn.equals(oldMessage)){
      oldMessage = messageIn;
      splitParts = messageIn.split(" ");
      universe.grid.updateGridFromUDP(messageIn);
    }
  }

}
