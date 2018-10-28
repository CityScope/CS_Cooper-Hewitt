  public class Grid {
  private ArrayList<Building> buildings; // all the building (24)
  private ArrayList<Building> buildingsOnGrid; // Building present on the grid
  public HashMap<Integer,PVector> gridMap;
  
  Table table;
   Grid(){
     buildings = new ArrayList<Building>();
     buildingsOnGrid = new ArrayList<Building>();
     gridMap = new HashMap<Integer,PVector>();
     gridMap.put(0,new PVector(1,1));gridMap.put(1,new PVector(3,1));gridMap.put(2,new PVector(6,1));gridMap.put(3,new PVector(8,1));gridMap.put(4,new PVector(11,1));gridMap.put(5,new PVector(13,1));
     gridMap.put(6,new PVector(1,4));gridMap.put(7,new PVector(3,4));gridMap.put(8,new PVector(6,4));gridMap.put(9,new PVector(8,4));gridMap.put(10,new PVector(11,4));gridMap.put(11,new PVector(13,4));
     gridMap.put(12,new PVector(1,7));gridMap.put(13,new PVector(3,7));gridMap.put(14,new PVector(6,7));gridMap.put(15,new PVector(8,7));gridMap.put(16,new PVector(11,7));gridMap.put(17,new PVector(13,7));
     gridMap.put(18,new PVector(-1,-1));gridMap.put(19,new PVector(-1,-1));gridMap.put(20,new PVector(-1,-1));gridMap.put(21,new PVector(-1,-1));gridMap.put(22,new PVector(-1,-1));gridMap.put(23,new PVector(-1,-1));
          
     table = loadTable("block/Cooper Hewitt Buildings - Building Blocks.csv", "header");
     for (TableRow row : table.rows()) {
       buildings.add(new Building(gridMap.get(row.getInt("id")-1),row.getInt("id")-1,row.getInt("R"),row.getInt("O"),row.getInt("A")));
     }
     
     for (int i=0;i<=18;i++){
       buildingsOnGrid.add(new Building(gridMap.get(i),i+1,0,0,0));
     }
   }
   
   public void draw(PGraphics p){
     for (Building b: buildingsOnGrid){
       if(b.loc.x!=-1){
         b.draw(p);
       }
     }
   }
   
   public void updateGridFromUDP(String message){
    println("message" + message);
    JSONObject json = parseJSONObject(message); 
    JSONArray grids = json.getJSONArray("grid");
    for(int i=0; i < grids.size(); i++) { 
      buildingsOnGrid.get(i).id = grids.getJSONArray(i).getInt(0);
      buildingsOnGrid.get(i).nbR = buildings.get(grids.getJSONArray(i).getInt(0)).nbR;
      buildingsOnGrid.get(i).nbO = buildings.get(grids.getJSONArray(i).getInt(0)).nbO;
      buildingsOnGrid.get(i).nbA = buildings.get(grids.getJSONArray(i).getInt(0)).nbA;
    }
   }

}

public class Building{
  int size = int((SIMULATION_WIDTH/16)*scale);
  PVector loc;
  int id;
  int nbR;
  int nbO;
  int nbA;
  boolean isActive;
  Building(PVector _loc, int _id, int _nbR, int _nbO, int _nbA){
    loc = _loc;
    id = _id;
    nbR= _nbR;
    nbO= _nbO;
    nbA= _nbA;
  }
  
  public void draw (PGraphics p){
    p.rectMode(CORNER);
    p.fill(#666666);
    p.stroke(#000000);
    p.rect (loc.x*size, loc.y*size, size*2.0, size*2.0);
    p.fill(#666666);
    p.textAlign(CENTER); 
    p.textSize(10); 
    p.text("id:" + id + " R:" + nbR + " 0:" + nbO + " A:" + nbA, loc.x*size+size, loc.y*size+size*2.25);
  }
}
