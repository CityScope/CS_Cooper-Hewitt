// this handles the animation when uses
// put or take a building block from the table
public class GridInteractionAnimation {

  int OFFSET = 2;
  int LINE_LENGTH = 5;
  int DURATION = 3000; // milliseconds
  int LINE_NUM = 4;

  PVector center; 
  float start; // start millis of animation
  boolean isActive;
  boolean isPut;
  ParticleSystem ps;
  
  public GridInteractionAnimation(PVector _loc){
    center = new PVector(
        _loc.x * GRID_CELL_SIZE + BUILDING_SIZE * 0.5,
        _loc.y * GRID_CELL_SIZE + BUILDING_SIZE * 0.5
        );

    start = 0.0;
    isActive = true;
    isPut = false;
    ps = new ParticleSystem(center,#FFFFFF);
  }
  
  void runParticleSystem(PGraphics p){
    for(int i=0;i<=20;i++){
      ps.addParticle();
    }
    
    ps.run(p);
  }
  
  void dynamicSquare(PGraphics p,float t,color c){
    p.noFill();
    p.stroke(c);
    p.rect(center.x, center.y, BUILDING_SIZE+t*100, BUILDING_SIZE+t*100);
    p.stroke(c,70);
    p.rect(center.x, center.y, BUILDING_SIZE+BUILDING_SIZE*0.25+t*100, BUILDING_SIZE+BUILDING_SIZE*0.25+t*100);
    p.stroke(c,100);
    p.rect(center.x, center.y, BUILDING_SIZE+BUILDING_SIZE*0.5+t*100, BUILDING_SIZE+BUILDING_SIZE*0.5+t*100);
    p.rect(center.x, center.y, BUILDING_SIZE+t*100, BUILDING_SIZE+t*100);
  }
  
  void minimalLine(PGraphics p, float t){
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
    float t = (millis() - start) / DURATION;
    if(isPut == false){
      inAnimationMode = true;
      dynamicSquare(p,pow(t,t),#FFFFFF);
      runParticleSystem(p);     
      minimalLine(p,t);
    }
    
    if(t < 0 || t > 1){
      isActive = false;
      inAnimationMode = false;
    }


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

class Particle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  color c;

  Particle(PVector l, color _c) {
    acceleration = new PVector(random(-0.1, 0.1),random(-0.1,0.1));
    velocity = new PVector(random(-5,5),random(-5,5));
    location = l.get();
    lifespan = 255.0;
    c= _c;
  }

  void run(PGraphics p) {
    update();
    display(p);
  }

  // Method to update location
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    lifespan -= 5;
  }

  // Method to display
  void display(PGraphics p) {
    if(universe.grid.gridAnimation.get(universe.grid.currentGridAnimated).center.x < state.slider * SIMULATION_WIDTH){
      c= #FFFFFF;
    }else{
      c= #FF0000;
    }
    p.stroke(c,lifespan);
    p.fill(c,lifespan);
    p.ellipse(location.x,location.y,10*SCALE,10*SCALE);  
  }
  
  void applyForce(PVector force){
    acceleration.add(force);
  }
  
  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}

// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  color c;

  ParticleSystem(PVector _location, color _c) {
    origin = _location;
    particles = new ArrayList<Particle>();
    c = _c;
  }

  void addParticle() {
      particles.add(new Particle(origin,c));
  }
  
  void applyForce(PVector force){
    for(Particle p : particles){
      p.applyForce(force);
    }
  } 

  void run(PGraphics _p) {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run(_p);
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}
