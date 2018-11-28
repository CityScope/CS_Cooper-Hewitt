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
    
State state = new State();
Drawer drawer;

float SCALE = 1.0;
public final int SIMULATION_WIDTH = 2128;
public final int SIMULATION_HEIGHT = 1330;
public final int GRID_CELL_SIZE = int((SIMULATION_WIDTH/16)*SCALE);
public final int BUILDING_SIZE = int((SIMULATION_WIDTH/16)*SCALE*2);

public int DISPLAY_WIDTH = int(SIMULATION_WIDTH * SCALE);
public int DISPLAY_HEIGHT = int(SIMULATION_HEIGHT * SCALE);

public int playGroundWidth = DISPLAY_WIDTH;
public int playGroundHeight = DISPLAY_HEIGHT;

public boolean INIT_AGENTS_FROM_DATAFILE = true;
public final String SIMULATED_POPULATION_DATA_FILEPATH = "data/simPop.csv";
public final int NUM_AGENTS_PER_WORLD = 1000;


Universe universe;
boolean showBuilding = true;
boolean showBackground = true;
boolean showGlyphs = true;
boolean showNetwork = false;
boolean showAgent = true;
boolean showZombie = false;
boolean dynamicSlider = true;
boolean showCollisionPotential = false;
boolean showCongestionVis = true;
boolean showConnectionBetweenAgentAndBuilding = false;
boolean showRemaninginAgentAndBuilding = false;
boolean animatedGlyph = false;
boolean devMode = false;
UDPReceiver udpR;

void settings() {
  fullScreen(P3D, SPAN);
}

void setup() {
  drawer = new Drawer(this);
  drawer.initSurface();
  universe = new Universe();
  universe.InitUniverse();
  udpR = new UDPReceiver();
  if(!devMode){
    drawer.ks.load();
  }
  frameRate(30);
} 

void draw() {
  drawScene();
}

/* Draw ------------------------------------------------------ */
void drawScene() {
  background(0);
  drawer.drawSurface();
}

void keyPressed() {
  switch(key) { 
  case 'k':
    drawer.ks.toggleCalibration();
    break;  
  case 'l':
    drawer.ks.load();
    break; 
  case 's':
    drawer.ks.save();
    break;
  case 'c':
    showCollisionPotential=!showCollisionPotential;
    break;
  case 'x':
    showCongestionVis = !showCongestionVis;
    break;
  case 'b':
    showBuilding= !showBuilding;
    break;
  case 'g':
    showGlyphs = !showGlyphs;
    break;
  case 'n':
    showNetwork = !showNetwork;
    break;
  case 'z':
    showZombie=!showZombie;
    break;
  case ' ':
    showBackground=!showBackground;
    break;
  }

  if (key == CODED) {
    switch (keyCode) {
    case LEFT:
      state.slider = max(state.slider - 0.05, 0); 
      break;
    case RIGHT:
      state.slider = max(state.slider + 0.05, 0); 
      break;
    }
  }
}
