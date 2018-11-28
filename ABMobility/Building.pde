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
  String type;
  boolean isActive;

  Building(PVector _loc, int _id, int _capacityR, int _capacityO, int _capacityA, String _type) {
    loc = _loc;
    id = _id;
    capacityR = _capacityR;
    capacityO = _capacityO;
    capacityA = _capacityA;
    type = _type;
  }

  public void draw (PGraphics p) {
    p.fill(universe.grid.gridQRcolorMap.get(loc));    
    p.stroke(#000000);
    p.rect (loc.x*GRID_CELL_SIZE+size/2, loc.y*GRID_CELL_SIZE+size/2, size*0.8, size*0.8);
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
