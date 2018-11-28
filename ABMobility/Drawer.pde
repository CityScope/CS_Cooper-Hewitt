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
    
import deadpixel.keystone.*;

public class Drawer {
  Keystone ks;
  int nbProjector = 2;
  CornerPinSurface[] surface = new CornerPinSurface[nbProjector];
  PGraphics offscreenSurface;
  PGraphics subSurface;

  Drawer(PApplet parent) {
    ks = new Keystone(parent);
    offscreenSurface = createGraphics(playGroundWidth, playGroundHeight, P2D);
  }

  void initSurface() {
    for (int i=0; i<nbProjector; i++) {
      surface[i] = ks.createCornerPinSurface((int)playGroundWidth/nbProjector, (int)playGroundHeight, 50);
    }
    subSurface = createGraphics(playGroundWidth/nbProjector, playGroundHeight, P2D);
  }

  void drawSurface() {
    universe.updateGraphics(state.slider);
    offscreenSurface.beginDraw();
    offscreenSurface.clear();
    offscreenSurface.background(0);
    drawTableBackGround(offscreenSurface);
    offscreenSurface.rectMode(CENTER);
    offscreenSurface.stroke(#FF0000);
    offscreenSurface.noFill();
    offscreenSurface.rect(playGroundWidth/2, playGroundHeight/2, 2128*SCALE, 1330*SCALE);
    universe.update();
    universe.draw(offscreenSurface, state.slider);
    if (showBuilding) {
      universe.grid.draw(offscreenSurface);
    }
    offscreenSurface.endDraw();
    for (int i=0; i<nbProjector; i++) {
      subSurface.beginDraw();
      subSurface.clear();
      subSurface.image(offscreenSurface, -(playGroundWidth/nbProjector)*i, 0);
      subSurface.endDraw();
      surface[i].render(subSurface);
    }
  }

  void drawTableBackGround(PGraphics p) {
    p.fill(125);
  }
}
