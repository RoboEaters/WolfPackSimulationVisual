// Robot.pde
// SimuationVisual
// UCI RoboCup Rescue 2013

class Robot {
  private int tileSize = SimulationVisual.TILE_SIZE;
  private int[][][] map;                // Map that only tracks this robot's positions
  private String identity;              // Identifier
  private int role;                     // Current role
  
  private Boolean moving = false;       // Is in the process of animating
  private Boolean replaying = false;  // In the middle of a replay
  private Boolean initialized = false;  // Has been given an initial position

  private int xCurr = -1;               // X Current coordinate
  private int yCurr = -1;               // Y Current coordinate
  private int xFinal = -1;              // X Destination coordinate
  private int yFinal = -1;              // Y Destination coordinate

  private ArrayList<Integer> xCoords = new ArrayList<Integer>();
  private ArrayList<Integer> yCoords = new ArrayList<Integer>();
  private ArrayList<Integer> roles = new ArrayList<Integer>();

  private int replayPosition = 0;

  int[][] roleColor = {
    {
      0, 0, 255  // Head
    }
    , {
      0, 255, 0  // Flanker
    }
    , {
      0, 255, 0  // Flanker
    }
    , {
      255, 0, 0  // Rear
    }
  };

  Robot(int dx, int dy, int n) {
    map = new int[dy][dx][3];
    identity = n + "";
    for (int i = 0; i<dy; i++)
      for (int j = 0; j<dx; j++) {
        map[i][j][0] = n;  // Identifier
        map[i][j][1] = -1;   // Role
        map[i][j][2] = -1;  // Square Type
      }
  }

  void update(int px, int py, int t, int r) {
    map[py][px][1] = r;
    map[py][px][2] = t;
    role = r;
    roles.add(r);
    initialized = true;
  }

  void move(int x, int y) {
    moving = true;
    xFinal = x;
    yFinal = y;
    xCoords.add(x);
    yCoords.add(y);
  }

  void animate() {
    if (!initialized)
      return;
    if (replaying)
      replay();
    if ((yCurr==yFinal) && (xCurr==xFinal)) {
      moving = false;
      if (replaying)
        replayPosition++;
    }
    else if ((xCurr==-1) && (yCurr ==-1)) {
      xCurr = xFinal;
      yCurr = yFinal;
      moving = false;
    }
    else if ((xFinal != xCurr) || (yFinal != yCurr)) {
      if (xFinal != xCurr) {
        if (xFinal > xCurr) 
          xCurr = xCurr + 1;
        else if (xFinal < xCurr) 
          xCurr = xCurr - 1;
      }
      if (yFinal != yCurr) {
        if (yFinal > yCurr) 
          yCurr = yCurr + 1;
        else if (yFinal < yCurr) 
          yCurr = yCurr - 1;
      }
    }
    fill(roleColor[role-1][0], roleColor[role-1][1], roleColor[role-1][2]);
    ellipse(xCurr, yCurr, tileSize*0.6, tileSize*0.6);
    textAlign(CENTER, CENTER);
    textSize(tileSize*0.5);
    fill(0);
    text(identity, xCurr, yCurr);
  }

  void startReplay() {
    if (roles.size() < 2) {
      replaying = false;
      return;
    }
    replaying = true;
    xCurr = xCoords.get(0);
    yCurr = yCoords.get(0);
    replayPosition++;
  }

  void replay() {
    if (replayPosition == roles.size()) {
      replaying = false;
      replayPosition = 0;
      return;
    }
    role = roles.get(replayPosition);
    move(xCoords.get(replayPosition), yCoords.get(replayPosition));
  }

  int[][][] getMap() {
    return map;
  }

  String getIdentity() {
    return identity;
  }

  Boolean isMoving() {
    return (moving || replaying);
  }

  void stopMoving() {
    moving = false;
  }
}

