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

// this handles the animation when uses
// put or take a building block from the table
public class GridInteractionAnimation {

  int OFFSET = 2;
  int LINE_LENGTH = 5;
  int DURATION = 8000; // milliseconds
  int LINE_NUM = 4;

  PVector center; 
  float start; // start millis of animation
  boolean isActive;
  boolean isPut;
  int blockId=-1;

  public GridInteractionAnimation(PVector _loc) {
    center = new PVector(
      _loc.x * GRID_CELL_SIZE + BUILDING_SIZE * 0.5, 
      _loc.y * GRID_CELL_SIZE + BUILDING_SIZE * 0.5
      );

    start = 0.0;
    isActive = true;
    isPut = false;
  }
  
  void dynamicSquare(PGraphics p, float t, color c) {
    p.fill(c,20);
    p.stroke(c,100);
    p.rect(center.x, center.y, BUILDING_SIZE+t*100, BUILDING_SIZE+t*100);
    p.fill(c,20);
    p.stroke(c, 100);
    p.rect(center.x, center.y, BUILDING_SIZE+BUILDING_SIZE*0.25+t*100, BUILDING_SIZE+BUILDING_SIZE*0.25+t*100);
    p.fill(c,20);
    p.stroke(c, 100);
    p.rect(center.x, center.y, BUILDING_SIZE+BUILDING_SIZE*0.5+t*100, BUILDING_SIZE+BUILDING_SIZE*0.5+t*100);
    p.rect(center.x, center.y, BUILDING_SIZE+t*100, BUILDING_SIZE+t*100);
  }

  void minimalLine(PGraphics p, float t) {
    p.pushMatrix();
    p.stroke(#FFFFFF);
    p.translate(center.x, center.y);

    float unitX = BUILDING_SIZE / LINE_NUM;
    for (int r = 0; r < 4; r++) {
      p.pushMatrix();
      p.rotate(PI * 0.5 * r);
      p.translate(-BUILDING_SIZE * 0.5, 0); // new line

      p.pushMatrix();
      for (int i = 0; i < LINE_NUM; i++) {
        drawLine(p, t, isPut);
        p.translate(unitX, 0);
      }
      drawLine(p, t, isPut);   
      p.popMatrix();

      p.popMatrix(); // origin is back to center
    }

    p.popMatrix();
  }

  void drawLine(PGraphics p, float elapsed, boolean flip) {
    float t;
    if (!flip) {
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

  void activate() {
    isActive = true; 
    start = millis();
  }


  void put(int _blockId) {
    isPut = false;
    activate();
    blockId=_blockId;
  }

  void take() {
    isPut = true;
    activate();
  }

  void draw(PGraphics p) {
    if (!isActive) return;
    float t = (millis() - start) / DURATION;
    if (isPut == false) {
      showConnectionBetweenAgentAndBuilding = true;
      showRemaninginAgentAndBuilding = true;
      if(t<0.2){
        dynamicSquare(p, pow(t, t), #FFFFFF);
      }else{
      }
      if(t>0.4){
        showConnectionBetweenAgentAndBuilding = false;
      }
    }

    if (t < 0 || t > 1) {
      isActive = false;
      showConnectionBetweenAgentAndBuilding = false;
      showRemaninginAgentAndBuilding = false;
    }
  }
}

/// below are utility functions for animation

final float E = 2.7182818284;

float sigmoidEase(float t) {
  float x = map(t, 0.0, 1.0, -10, 10);
  return 1.0 / (1.0 + pow(E, -x));
}

float cubicEase(float t) {
  float y = curvePoint(800, 100, 0, 5, t);
  return map(y, 100.0, 0.0, 0, 1.0);
}
