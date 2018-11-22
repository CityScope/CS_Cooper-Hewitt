// this handles the animation when uses
// put or take a building block from the table
public class GridInteractionAnimation {

  int OFFSET = 2;
  int LINE_LENGTH = 5;
  int DURATION = 2000; // milliseconds
  int LINE_NUM = 4;

  PVector center; 
  float start; // start millis of animation
  boolean isActive;
  boolean isPut;
  
  public GridInteractionAnimation(PVector _loc){
    center = new PVector(
        _loc.x * GRID_CELL_SIZE + BUILDING_SIZE * 0.5,
        _loc.y * GRID_CELL_SIZE + BUILDING_SIZE * 0.5
        );

    start = 0.0;
    specialStart= 0.0;
    isActive = true;
    isPut = false;
  }

  void drawLine(PGraphics p, float elapsed, boolean flip){
    float t;
    if(!flip){
      t = cubicEase(min(1.0, elapsed));
    } else {
      t = 1.0 - cubicEase(min(1.0, elapsed));
    }
    float l = LINE_LENGTH * t;
    p.line(
        0,
        -(BUILDING_SIZE * 0.5 + OFFSET),
        0,
        -(BUILDING_SIZE * 0.5 + OFFSET + l)
        );
  }

  void activate(){
    isActive = true; 
    start = millis();
  }
  

  void put(){
    isPut = false;
    activate();
  }

  void take(){
    isPut = true;
    activate();
  }

  void draw(PGraphics p){
    if(!isActive) return;
    inAnimationMode = true;
    float t = (millis() - start) / DURATION;

    if(t < 0 || t > 1){
      isActive = false;
      inAnimationMode = false;
    }

    p.pushMatrix();
    p.stroke(#FFFFFF);
    p.translate(center.x, center.y);

    float unitX = BUILDING_SIZE / LINE_NUM;
    for(int r = 0; r < 4; r++){
      p.pushMatrix();
      p.rotate(PI * 0.5 * r);
      p.translate(-BUILDING_SIZE * 0.5, 0); // new line

      p.pushMatrix();
      for(int i = 0; i < LINE_NUM; i++){
        drawLine(p, t, isPut);
        p.translate(unitX, 0);
      }
      drawLine(p, t, isPut);   
      p.popMatrix();

      p.popMatrix(); // origin is back to center
    }
     
    p.popMatrix();
  }
}

/// below are utility functions for animation

final float E = 2.7182818284;

float sigmoidEase(float t){
  float x = map(t, 0.0, 1.0, -10, 10);
  return 1.0 / (1.0 + pow(E, -x));
}

float cubicEase(float t) {
  float y = curvePoint(800, 100, 0, 5, t);
  return map(y, 100.0, 0.0, 0, 1.0);
}
