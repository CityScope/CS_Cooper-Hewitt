
public class Building {
  int size = BUILDING_SIZE;
  PVector loc;
  int id;
  // Buildings have given capacities for:
  // R (residential)
  // O (office)
  // A (amenity)
  int capacityR;
  int capacityO;
  int capacityA;
  boolean isActive;

  Building(PVector _loc, int _id, int _capacityR, int _capacityO, int _capacityA) {
    loc = _loc;
    id = _id;
    capacityR = _capacityR;
    capacityO = _capacityO;
    capacityA = _capacityA;
  }

  public void draw (PGraphics p) {
    p.fill(universe.grid.gridQRcolorMap.get(loc));    
    p.stroke(#000000);
    p.rect (loc.x*GRID_CELL_SIZE+size/2, loc.y*GRID_CELL_SIZE+size/2, size*0.9, size*0.9);
    if (devMode) {
      p.textAlign(CENTER);
      p.textSize(20*SCALE);
      if (id!=-1) {
        p.fill(#666666);
        p.text("id:" + id + " R:" + capacityR + " 0:" + capacityO + " A:" + capacityA, loc.x*GRID_CELL_SIZE+size/2, loc.y*GRID_CELL_SIZE+size*1.25);
      } else {
        p.fill(#660000);
        p.text("id:" + -1, loc.x*GRID_CELL_SIZE+size/2, loc.y*GRID_CELL_SIZE+size*1.25);
      }
    }
  }
}
