// SimulationVisual.pde
// UCI Robocup Rescue 2013 

import java.io.File;

private int SWIDTH = 700;                   // Screen Width
private int SHEIGHT = 700;                  // Screen Height
private int BUFFER = 100;                   // Spacing between window edge and map
public static int TILE_SIZE;                // Dimension of map tiles
private int FRAMERATE = 150;                // Higher means faster, lower is slower
private Robot[] r;                          // List of all robots

private BufferedReader reader;  
private File input;

public int dimension = 0;                  // Width of map (tiles)
private int[][][] mainMap;

private boolean started = false;
private boolean simulationComplete = false;
private boolean mapInitialized = false;
private boolean paused = false;

private int[][] bcoordst;                 // Button coordinates top
private int[][] bcoordsb;                 // Button coordinates bottom

// Colors (RGB)
private int[] unexplored = {        // -1
  224, 224, 244
};
private int[] wall = {              // 0
  0, 0, 0
};
private int[] open = {              // 1
  65, 105, 225
};
private int[] openAndVisited = {    // 2
  111, 136, 219
};
private int[] victim = {            // 5
  255, 255, 0
};

void setup() {
  size(SWIDTH, SHEIGHT);
  background(50);
  frameRate(FRAMERATE);
  noStroke();
  drawButtons();
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("Select a file to begin", SWIDTH/2, SHEIGHT/2);
}

void startSimulation(File f) {
  if (f == null)
    return;
  input = f;
  reader = createReader(input.getAbsolutePath());
  if (reader == null) {
    System.out.println("Error opening file...");
  } 
  loadMap();
  drawMap();
  started = true;
}

void initializeMap(int d) {
  dimension = d;
  TILE_SIZE = (SWIDTH - (2*BUFFER))/dimension; 
  mainMap = new int[dimension][dimension][3];
  r = new Robot[5];
  r[0] = null;
  r[1] = new Robot(dimension, dimension, 1);
  r[2] = new Robot(dimension, dimension, 2);
  r[3] = new Robot(dimension, dimension, 3);
  r[4] = new Robot(dimension, dimension, 4);
  mapInitialized = true;
  background(50);
  drawButtons();
}

void loadMap() {
  String line = null;
  String[] cols;
  int row = 0;
  try {
    do {
      line = reader.readLine();
      if (line == null) 
        simulationComplete = true;
      else {
        cols = splitTokens(line.trim(), ";");
        if (!mapInitialized)
          initializeMap(cols.length);
        for (int i = 0; i<(cols.length); i++) 
          mainMap[row][i] = int(splitTokens(cols[i], " "));
        row++;
      }
    }
    while ( (row < dimension) && !simulationComplete);
    reader.readLine(); // skip blank line
  } 
  catch (IOException e) {
    System.out.println("Error reading the file, exiting...");
    exit();
  }
  catch (NullPointerException e) {
    System.out.println("File not found, exiting...");
    exit();
  }
}

void printMaptoConsole() {
  for (int i = 0; i<dimension; i++) {
    for (int j = 0; j<dimension-1; j++)
      System.out.print(mainMap[i][j][0]+ " " + mainMap[i][j][1]+ " " + mainMap[i][j][2]+ " " +", ");
    System.out.println(mainMap[i][dimension-1][0]+ " " + mainMap[i][dimension-1][1]+ " " + mainMap[i][dimension-1][2]);
  }
}

void drawMap() {
  int robot;
  for (int i = 0; i<dimension; i++) {
    for (int j = 0; j<dimension; j++) {
      if (mainMap[i][j][2] == -1)
        fill(unexplored[0], unexplored[1], unexplored[2]);
      else if (mainMap[i][j][2] == 0)
        fill(wall[0], wall[1], wall[2]);
      else if (mainMap[i][j][2] == 1)
        fill(open[0], open[1], open[2]);
      else if (mainMap[i][j][2] == 2)
        fill(openAndVisited[0], openAndVisited[1], openAndVisited[2]);
      else if (mainMap[i][j][2] == 5)
        fill(victim[0], victim[1], victim[2]);
      rect((BUFFER+(j*TILE_SIZE)), (BUFFER+(i*TILE_SIZE)), TILE_SIZE, TILE_SIZE);
      robot = mainMap[i][j][0];
      if (robot > 0 ) {
        r[robot].update(j, i, mainMap[i][j][2], mainMap[i][j][1]);
        r[robot].move((BUFFER + (TILE_SIZE/2) + (j*TILE_SIZE)), (BUFFER + (TILE_SIZE/2) + (i*TILE_SIZE)));
      }
    }
  }
}

void restartSimulation(File f) {
  if (f == null)
    return;
  mapInitialized = false;
  simulationComplete = false;
  paused = false;
  r[1].stopMoving();
  r[2].stopMoving();
  r[3].stopMoving();
  r[4].stopMoving();
  try {
    reader.close();
  }
  catch (IOException e)
  {
    System.out.println("Error closing file, exiting...");
    exit();
  }
  startSimulation(f);
}

void replayMap(int id) {
  simulationComplete = true;
  r[1].stopMoving();
  r[2].stopMoving();
  r[3].stopMoving();
  r[4].stopMoving();
  for (int i = 0; i<dimension; i++) {
    for (int j = 0; j<dimension; j++) {
      if (mainMap[i][j][2] == -1)
        fill(unexplored[0], unexplored[1], unexplored[2]);
      else if (mainMap[i][j][2] == 0)
        fill(wall[0], wall[1], wall[2]);
      else if (mainMap[i][j][2] == 1)
        fill(open[0], open[1], open[2]);
      else if (mainMap[i][j][2] == 2)
        fill(openAndVisited[0], openAndVisited[1], openAndVisited[2]);
      else if (mainMap[i][j][2] == 5)
        fill(victim[0], victim[1], victim[2]);
      rect((BUFFER+(j*TILE_SIZE)), (BUFFER+(i*TILE_SIZE)), TILE_SIZE, TILE_SIZE);
    }
  }
  r[id].startReplay();
}

void drawButtons() {
  int bwidth = ((SWIDTH-(2*BUFFER))/5);
  int bx = BUFFER;
  int byt = (BUFFER/2) - 20;
  String[] btextt = {
    "Select File", "Restart", "", ""
  };
  bcoordst = new int[btextt.length][2];
  int bwt = ((SWIDTH-(2*BUFFER))- (btextt.length-1)*10)/btextt.length;
  int byb = SHEIGHT - (BUFFER/2) - 20;
  String[] btextb = {
    "1", "2", "3", "4", "Exit"
  };
  bcoordsb = new int[btextb.length][2];
  int bwb = ((SWIDTH-(2*BUFFER)) - (btextb.length-1)*10)/btextb.length;
  textAlign(CENTER, CENTER);
  textSize(20);
  for (int i = 0; i<btextt.length; i++) {
    bcoordst[i][0] = bx + i*(bwt+10);
    bcoordst[i][1] = bx + i*(bwt+10)+bwt;
    fill(255);
    rect(bcoordst[i][0], byt, bwt, 40);
    fill(50);
    text(btextt[i], bcoordst[i][0]+(bwt/2), byt+20);
  }
  for (int i = 0; i<btextb.length; i++) {
    bcoordsb[i][0] = bx + i*(bwb+10);
    bcoordsb[i][1] = bx + i*(bwb+10)+bwb;
    fill(255);
    rect(bcoordsb[i][0], byb, bwb, 40);
    fill(50);
    text(btextb[i], bcoordsb[i][0]+(bwb/2), byb+20);
  }
  triangle(bcoordst[2][0]+(bwt/2)-10, byt+10, bcoordst[2][0]+(bwt/2)-10, byt+30, bcoordst[2][0]+(bwt/2)+10, byt+20);
  rect(bcoordst[3][0]+(bwt/2)-10, byt+10, 8, 20);
  rect(bcoordst[3][0]+(bwt/2)+2, byt+10, 8, 20);
}

void mousePressed() {
  if (mouseY>32 && mouseY<72) {
    if ((mouseX>bcoordst[0][0] && mouseX<bcoordst[0][1]) && started)             // Select File once simulation has started
      selectInput("Select a file to simulate...", "restartSimulation");
    else if (mouseX>bcoordst[0][0] && mouseX<bcoordst[0][1])                     // Select File
      selectInput("Select a file to simulate...", "startSimulation");
    else if (mouseX>bcoordst[1][0] && mouseX<bcoordst[1][1])                     // Restart
      restartSimulation(input);
    else if (mouseX>bcoordst[2][0] && mouseX<bcoordst[2][1])                     // Play
      paused = false;
    else if (mouseX>bcoordst[3][0] && mouseX<bcoordst[3][1])                     // Pause
      paused = true;
  }
  else if (mouseY<668 && mouseY>628) {
    if (mouseX>bcoordsb[0][0] && mouseX<bcoordsb[0][1])
      replayMap(1);
    else if (mouseX>bcoordsb[1][0] && mouseX<bcoordsb[1][1])
      replayMap(2);
    else if (mouseX>bcoordsb[2][0] && mouseX<bcoordsb[2][1])
      replayMap(3);
    else if (mouseX>bcoordsb[3][0] && mouseX<bcoordsb[3][1])
      replayMap(4);
    else if (mouseX>bcoordsb[4][0] && mouseX<bcoordsb[4][1])
      exit();
  }
}

void animateAll() {
  for (int i = 1; i<r.length; i++)
    r[i].animate();
}

Boolean robotsMoving() {
  return (r[1].isMoving() || r[2].isMoving() || r[3].isMoving() || r[4].isMoving());
}

void draw() {
  if (!paused && started) {
    if (mapInitialized && robotsMoving()) {
      animateAll();
    }
    else if (!simulationComplete) {
      loadMap();
      drawMap();
    }
  }
}

