
final int PLOT_SIZE = 50;

class Plot {

  int id;
  int buildingId;
  int rotation;
  Rectangle r;
  boolean isSelected;

  public Plot(int _id){
    id = _id;
    buildingId = -1;
    rotation = 0;

    int x_index = id % 6 + 1;
    for(int i = 0; i < 2; i++){
      if(id % 6 > 1 + i * 2) {
        x_index ++;
      }
    }

    int y_index = (id / 6) * 2 + 1;

    r = new Rectangle(
        x_index * PLOT_SIZE,
        y_index * PLOT_SIZE,
        PLOT_SIZE
        );

    isSelected = false;
  }

  public void setSelected(boolean select){
    isSelected = select;
  }

  public boolean isInside(int x, int y){
      return r.isInside(x, y); 
  }

  public void setBuildingId (int _bId){
    buildingId = _bId;
  }

  public void draw() {
    if(isSelected){
      stroke(0, 255, 255);
    } else {
      stroke(255); 
    }
    r.draw();

    PVector c = r.center();

    text(buildingId, c.x, c.y);
  }

}
class Rectangle {
  PVector start;
  PVector end;
  PVector size;

  public Rectangle (float sx, float sy, float ex, float ey){
    start = new PVector(sx, sy);
    end = new PVector(ex, ey);
    size = PVector.sub(end, start);
  }

  public Rectangle (float sx, float sy, float s){
    start = new PVector(sx, sy);
    size = new PVector(s, s);
    end = PVector.add(start, size);
  }

  public boolean isInside(float x, float y){
    return (x >= start.x && x <= end.x && y >= start.y && y <= end.y);
  }

  public PVector center(){
    return new PVector(start.x + size.x * 0.5, start.y + size.y * 0.5);
  }
  
  public void draw() {
    rect(start.x + 1 , start.y + 1, size.x - 2, size.y - 2);
  }
}
