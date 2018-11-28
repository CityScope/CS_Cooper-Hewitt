/*  ABMobility: Data-Driven Interactive Agent Based Simulation

    MIT Media Lab City Science - The Road Ahead: Reimagine Mobility
    Exhibition at the Cooper Hewitt Smithsonian Design Museum 
    12.14.18 - 03.31.19
    
    Visit https://github.com/CityScope/CS_Cooper-Hewitt 
    for license information and developers contact.
     
   @copyright: Copyright (C) 2018
   @authors:   Arnaud Grignard - Yasushi Sakai - Alex Berke
   @version:   1.0
   @legal:

    ABMobility is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    Graphics is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.
    You should have received a copy of the GNU Affero General Public License
    along with Graphics.  If not, see <http://www.gnu.org/licenses/>. */
    
import hypermedia.net.*;


public class UDPReceiver {
  UDP udp;  // define the UDP object
  int PORT = 5005; 
  String HOST_IP = "localhost";
  int index;

  //boolean messageDelta = false;
  String[] oldSplitParts;
  String oldMessage = "";

  String[] splitParts;
  String messageIn = "";


  UDPReceiver() {
    udp = new UDP( this, PORT ); //from Termite desktop
    udp.listen( true );
    if (devMode) {
      println("Listening to" + PORT);
    }
  }
  void receive( byte[] data, String ip, int port ) {  // <-- extended handler
    messageIn = new String( data );
    //println( "receive: \""+messageIn+"\" from "+ip+" on port "+port );
    if (!messageIn.equals(oldMessage)) {
      oldMessage = messageIn;
      splitParts = messageIn.split(" ");
      universe.grid.updateGridFromUDP(messageIn);
    }
  }
}
