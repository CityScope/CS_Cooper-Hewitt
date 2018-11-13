  public class Grid {
  private ArrayList<Building> buildings; // all the building (24)
  private ArrayList<Building> buildingsOnGrid; // Building present on the grid
  public HashMap<Integer,PVector> gridMap;
  HashMap<PVector,Integer> gridQRcolorMap;
  
  Table table;
   Grid(){
     buildings = new ArrayList<Building>();
     buildingsOnGrid = new ArrayList<Building>();
     gridMap = new HashMap<Integer,PVector>();
     gridMap.put(0,new PVector(1,1));gridMap.put(1,new PVector(3,1));gridMap.put(2,new PVector(6,1));gridMap.put(3,new PVector(8,1));gridMap.put(4,new PVector(11,1));gridMap.put(5,new PVector(13,1));
     gridMap.put(6,new PVector(1,4));gridMap.put(7,new PVector(3,4));gridMap.put(8,new PVector(6,4));gridMap.put(9,new PVector(8,4));gridMap.put(10,new PVector(11,4));gridMap.put(11,new PVector(13,4));
     gridMap.put(12,new PVector(1,7));gridMap.put(13,new PVector(3,7));gridMap.put(14,new PVector(6,7));gridMap.put(15,new PVector(8,7));gridMap.put(16,new PVector(11,7));gridMap.put(17,new PVector(13,7));
     gridMap.put(18,new PVector(-1,-1));gridMap.put(19,new PVector(-1,-1));gridMap.put(20,new PVector(-1,-1));gridMap.put(21,new PVector(-1,-1));gridMap.put(22,new PVector(-1,-1));gridMap.put(23,new PVector(-1,-1));
          
     gridQRcolorMap = new HashMap<PVector,Integer>();
     gridQRcolorMap.put(gridMap.get(0),#888888);gridQRcolorMap.put(gridMap.get(1),#888888);gridQRcolorMap.put(gridMap.get(2),#CCCCCC);gridQRcolorMap.put(gridMap.get(3),#CCCCCC);gridQRcolorMap.put(gridMap.get(4),#888888);gridQRcolorMap.put(gridMap.get(5),#888888);
     gridQRcolorMap.put(gridMap.get(6),#888888);gridQRcolorMap.put(gridMap.get(7),#888888);gridQRcolorMap.put(gridMap.get(8),#CCCCCC);gridQRcolorMap.put(gridMap.get(9),#CCCCCC);gridQRcolorMap.put(gridMap.get(10),#888888);gridQRcolorMap.put(gridMap.get(11),#888888);
     gridQRcolorMap.put(gridMap.get(12),#888888);gridQRcolorMap.put(gridMap.get(13),#888888);gridQRcolorMap.put(gridMap.get(14),#CCCCCC);gridQRcolorMap.put(gridMap.get(15),#CCCCCC);gridQRcolorMap.put(gridMap.get(16),#888888);gridQRcolorMap.put(gridMap.get(17),#888888);
     
     table = loadTable("block/Cooper Hewitt Buildings - Building Blocks.csv", "header");
     for (TableRow row : table.rows()) {
       buildings.add(new Building(gridMap.get(row.getInt("id")),row.getInt("id"),row.getInt("R"),row.getInt("O"),row.getInt("A")));
     }
     
     for (int i=0;i<=18;i++){
       buildingsOnGrid.add(new Building(gridMap.get(i),i,0,0,0));
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
    //println("message" + message);
    JSONObject json = parseJSONObject(message); 
    JSONArray grids = json.getJSONArray("grid");
    for(int i=0; i < grids.size(); i++) {
      if(grids.getJSONArray(i).getInt(0) !=-1){
        buildingsOnGrid.get(i).id = grids.getJSONArray(i).getInt(0);
        buildingsOnGrid.get(i).nbR = buildings.get(grids.getJSONArray(i).getInt(0)).nbR;
        buildingsOnGrid.get(i).nbO = buildings.get(grids.getJSONArray(i).getInt(0)).nbO;
        buildingsOnGrid.get(i).nbA = buildings.get(grids.getJSONArray(i).getInt(0)).nbA;
      }
      else{
        buildingsOnGrid.get(i).id = -1;
        buildingsOnGrid.get(i).nbR = -1;
        buildingsOnGrid.get(i).nbO = -1;
        buildingsOnGrid.get(i).nbA = -1;
      }
    }
    if(dynamicSlider){
      JSONArray sliders = json.getJSONArray("slider");
      state.slider=sliders.getFloat(0);
    }
    
    
    if(isBuildingInCurrentGrid(20)){
      showGlyphs = false;
    }else{
      showGlyphs =true;
    }
    if(isBuildingInCurrentGrid(21)){
      showNetwork = true;
    }else{
      showNetwork =false;
    }
    if(isBuildingInCurrentGrid(22)){
      showAgent = true;
    }else{
      showAgent =false;
    }
    
   }
   
   public boolean isBuildingInCurrentGrid(int id){
     for (Building b: buildingsOnGrid){
       if (b.id == id){
         return true;
       }
     }
     return false;
   }
   
   public PVector getBuildingCenterPosistionPerId(int id){
     return new PVector(buildings.get(id).loc.x*GRID_CELL_SIZE + buildings.get(id).size/2 ,buildings.get(id).loc.y*GRID_CELL_SIZE +buildings.get(id).size/2);
   }

}

public class Building{
  int size = BUILDING_SIZE;
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
    //p.rectMode(CORNER);
    p.fill(universe.grid.gridQRcolorMap.get(loc));    
    p.stroke(#000000);
    p.rect (loc.x*GRID_CELL_SIZE+size/2, loc.y*GRID_CELL_SIZE+size/2, size*0.9, size*0.9);
    p.textAlign(CENTER); 
    p.textSize(10);
    if(id!=-1){ 
      p.fill(#666666);
      p.text("id:" + int(id ) + " R:" + nbR + " 0:" + nbO + " A:" + nbA, loc.x*GRID_CELL_SIZE+size/2, loc.y*GRID_CELL_SIZE+size*1.25);} 
    else {
      p.fill(#660000);
      p.text("id:" + -1 , loc.x*GRID_CELL_SIZE+size/2, loc.y*GRID_CELL_SIZE+size*1.25);
    }
  }
}
