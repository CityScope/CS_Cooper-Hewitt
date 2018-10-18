public class Grid {
  private ArrayList<Building> buildings;
   Grid(){
     buildings = new ArrayList<Building>();
     
     buildings.add(new Building(new PVector(1,1),1));
     buildings.add(new Building(new PVector(3,1),2));
     buildings.add(new Building(new PVector(6,1),3));
     buildings.add(new Building(new PVector(8,1),4));
     buildings.add(new Building(new PVector(11,1),5));
     buildings.add(new Building(new PVector(13,1),6));
     
     buildings.add(new Building(new PVector(1,4),7));
     buildings.add(new Building(new PVector(3,4),8));
     buildings.add(new Building(new PVector(6,4),9));
     buildings.add(new Building(new PVector(8,4),10));
     buildings.add(new Building(new PVector(11,4),11));
     buildings.add(new Building(new PVector(13,4),12));
     
     buildings.add(new Building(new PVector(1,7),13));
     buildings.add(new Building(new PVector(3,7),14));
     buildings.add(new Building(new PVector(6,7),15));
     buildings.add(new Building(new PVector(8,7),16));
     buildings.add(new Building(new PVector(11,7),17));
     buildings.add(new Building(new PVector(13,7),18));
   
   }
   
   public void draw(PGraphics p){
     for (Building b: buildings){
       b.draw(p);
     }
   }
   
   
   public void updateGridFromUDP(String message){
     println("ok I receive a new grid let's update it");
     String[] list = split(message, ',');
     for (int i=0;i<=buildings.size()-1;i++){
       buildings.get(i).id = int(list[i]);
     }
   }
}

public class Building{
  int size = int((SIMULATION_WIDTH/16)*scale);
  PVector loc;
  int id;
  Building(PVector _loc, int _id){
    loc = _loc;
    id = _id;
  }
  
  public void draw (PGraphics p){
    p.rectMode(CORNER);
    p.fill(#FFFFFF);
    p.stroke(#000000);
    p.rect (loc.x*size, loc.y*size, size*2, size*2);
    p.fill(#AAAAAA);
    p.textAlign(CENTER); 
    p.textSize(30); 
    p.text(id, loc.x*size+size, loc.y*size+size);
  }
}
