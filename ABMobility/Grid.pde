
// There are set locations on the grid where buildings
// can be placed.
public final int BUILDING_LOCATIONS = 18;

public final int PHYSICAL_BUILDINGS_COUNT = 24;
// There are 'virtual buildings' in 'zombie land'.
// These buildings do not have physical representations and can
// never be placed on the grid.  They are permenantly in zombie land.
// Utility: Agents assigned to a residence or office in zombie buildings
// always go in or out of 'zombie land'.
public final int VIRTUAL_ZOMBIE_BUILDING_ID = PHYSICAL_BUILDINGS_COUNT + 1;

public class Grid {
  // The buildings array is indexed by the ids of the buildings it holds.
  // i.e. it maps Building.id --> Building for buildings 0...24
  private ArrayList<Building> buildings;
  private ArrayList<GridInteractionAnimation> gridAnimation;
  public HashMap<Integer, PVector> gridMap;
  HashMap<PVector, Integer> gridQRcolorMap;
  public PVector zombieLandLocation;
  Table table;
  int currentBlockAnimated;
  int currentGridAnimated;

  Grid() {

    zombieLandLocation = new PVector(-1, -1);

    // initialize buildings
    buildings = new ArrayList<Building>();
    gridMap = new HashMap<Integer, PVector>();
    gridMap.put(0, new PVector(1, 1));
    gridMap.put(1, new PVector(3, 1));
    gridMap.put(2, new PVector(6, 1));
    gridMap.put(3, new PVector(8, 1));
    gridMap.put(4, new PVector(11, 1));
    gridMap.put(5, new PVector(13, 1));
    gridMap.put(6, new PVector(1, 4));
    gridMap.put(7, new PVector(3, 4));
    gridMap.put(8, new PVector(6, 4));
    gridMap.put(9, new PVector(8, 4));
    gridMap.put(10, new PVector(11, 4));
    gridMap.put(11, new PVector(13, 4));
    gridMap.put(12, new PVector(1, 7));
    gridMap.put(13, new PVector(3, 7));
    gridMap.put(14, new PVector(6, 7));
    gridMap.put(15, new PVector(8, 7));
    gridMap.put(16, new PVector(11, 7));
    gridMap.put(17, new PVector(13, 7));
    gridMap.put(18, zombieLandLocation);
    gridMap.put(19, zombieLandLocation);
    gridMap.put(20, zombieLandLocation);
    gridMap.put(21, zombieLandLocation);
    gridMap.put(22, zombieLandLocation);
    gridMap.put(23, zombieLandLocation);

    gridQRcolorMap = new HashMap<PVector, Integer>();
    gridQRcolorMap.put(gridMap.get(0), #888888);
    gridQRcolorMap.put(gridMap.get(1), #888888);
    gridQRcolorMap.put(gridMap.get(2), #CCCCCC);
    gridQRcolorMap.put(gridMap.get(3), #CCCCCC);
    gridQRcolorMap.put(gridMap.get(4), #888888);
    gridQRcolorMap.put(gridMap.get(5), #888888);
    gridQRcolorMap.put(gridMap.get(6), #888888);
    gridQRcolorMap.put(gridMap.get(7), #888888);
    gridQRcolorMap.put(gridMap.get(8), #CCCCCC);
    gridQRcolorMap.put(gridMap.get(9), #CCCCCC);
    gridQRcolorMap.put(gridMap.get(10), #999999);
    gridQRcolorMap.put(gridMap.get(11), #888888);
    gridQRcolorMap.put(gridMap.get(12), #888888);
    gridQRcolorMap.put(gridMap.get(13), #888888);
    gridQRcolorMap.put(gridMap.get(14), #CCCCCC);
    gridQRcolorMap.put(gridMap.get(15), #CCCCCC);
    gridQRcolorMap.put(gridMap.get(16), #777777);
    gridQRcolorMap.put(gridMap.get(17), #888888);

    table = loadTable("block/Cooper Hewitt Buildings - Building Blocks.csv", "header");
    for (TableRow row : table.rows()) {
      // initialize buildings from data
      int id = row.getInt("id");
      int loc = id;  // initial location is same as building id
      int capacityR = row.getInt("R");
      int capacityO = row.getInt("O");
      int capacityA = row.getInt("A");
      Building b = new Building(gridMap.get(loc), id, capacityR, capacityO, capacityA);
      buildings.add(b);
    }

    gridAnimation = new ArrayList<GridInteractionAnimation>();

    // is there a reason not using a simple for loop?
    int i = 0;
    for (Building b : buildings) {
      gridAnimation.add(new GridInteractionAnimation(b.loc));
      i += 1;
      if (i >= 18) {
        break;
      }
    }
  }

  public void draw(PGraphics p) {

    // Draw grid animations (if they occured)
    for (GridInteractionAnimation ga : gridAnimation) {
      ga.draw(p);
    }
    // Draw buildings
    for (Building b : buildings) {
      if (b.loc != zombieLandLocation) {
        b.draw(p);
      }
    }
    // Draw building block locations (this is redundant with the b.draw(p) but it's to be sure to display the -1 block)
    drawBuildingBlocks(p);
  }

  public void drawBuildingBlocks(PGraphics p) {
    /* Lights up location where building block goes.
     This is important to provide the scanner enough light to scan
     whether or not a building is in the location.
     */
    for (int i=0; i<BUILDING_LOCATIONS; i++) {
      PVector loc = gridMap.get(i);
      p.fill(universe.grid.gridQRcolorMap.get(loc)); 
      p.stroke(universe.grid.gridQRcolorMap.get(loc));
      p.rect(loc.x*GRID_CELL_SIZE+BUILDING_SIZE/2, loc.y*GRID_CELL_SIZE+BUILDING_SIZE/2, BUILDING_SIZE*0.8, BUILDING_SIZE*0.8);
    }
  }

  public void updateGridFromUDP(String message) {
    // Take account of which buildings we have not seen in 
    // the incoming message.
    int[] buildingIdsFromData = new int[PHYSICAL_BUILDINGS_COUNT];
    for (int i=0; i<PHYSICAL_BUILDINGS_COUNT; i++) {
      buildingIdsFromData[i] = 0;
    }

    JSONObject json = parseJSONObject(message); 

    // parseJSONObject returns null if unparsable (processing docs)
    if (json == null) return;

    JSONArray grids = json.getJSONArray("grid"); // maps building location --> Building
    if (grids == null) return;

    for (int i=0; i < grids.size(); i++) {
      int buildingId;
      try {
        buildingId = grids.getJSONArray(i).getInt(0);
      } 
      catch (Exception e) {
        // getInt(n) returns an exception, different from getJSONArray
        // if getJSONArray(i) is null, we will catch this.
        // I should return, not break
        return;
      }

      if ((buildingId >= 0) && (buildingId < PHYSICAL_BUILDINGS_COUNT)) {
        Building building = buildings.get(buildingId);

        // building with buildingId is on the table
        if (building.loc == zombieLandLocation) {
          // building was previously not on table - it has just been put on table.
          gridAnimation.get(i).put(buildingId);
          currentBlockAnimated = buildingId;
          currentGridAnimated= i;
        }

        building.loc = gridMap.get(i);
        // Record that the building is on the grid
        buildingIdsFromData[buildingId] = 1;
      } else {
        if (!gridAnimation.get(i).isPut) {
          gridAnimation.get(i).take();
        }
      }
    }

    for (int buildingId=0; buildingId<PHYSICAL_BUILDINGS_COUNT; buildingId++) {
      if (buildingIdsFromData[buildingId] == 0) {
        Building building = buildings.get(buildingId);
        building.loc = zombieLandLocation;
      }
    }

    if (dynamicSlider) {
      JSONArray sliders = json.getJSONArray("slider");
      if (sliders == null) return;
      try {
        state.slider = 1.0 - sliders.getFloat(0);
      } 
      catch (Exception e) {
        return;
      }
    }
  }

  public boolean isBuildingInCurrentGrid(int id) {
    for (Building b : buildings) {
      if (b.id == id) {
        return (b.loc != zombieLandLocation);
      }
    }
    return false;
  }

  public PVector getBuildingCenterPosistionPerId(int id) {
    PVector buildingLoc = getBuildingLocationById(id);
    return new PVector(buildingLoc.x*GRID_CELL_SIZE + BUILDING_SIZE/2, buildingLoc.y*GRID_CELL_SIZE + BUILDING_SIZE/2);
  }

  public PVector getBuildingLocationById(int id) {
    if (id < buildings.size()) {
      return buildings.get(id).loc;
    }
    return zombieLandLocation;
  }

  public void resetAnimation() {
    for (GridInteractionAnimation ga : gridAnimation) {
      ga.take();
    }
  }
}
