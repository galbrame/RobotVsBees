/***********
* DESCRIPTION: A simple obstacle avoidance style game created in Processing 3.
*              The robot moves forward at a constant pace and can be turned
*              left or right by 'a' or 'd', respectively. The robot can also
*              jump over low walls using the spacebar. Pressing the 'enter' key
*              switches between first and third person perspectives. Which in
*              first person perspective, players can click the mouse anywhere
*              inside the canvas to use free-look. Click again to switch back
*              to fixed view.
*
*              The object of the game is to avoid the bees. Bees will turn red
*              and fly towards the robot if it gets too close. If a bee makes
*              contact with the robot, the game is over. The game starts with 5
*              bees, but players can add more bees (max 10) by pressing 'b'.
*
*              If the game ends, press any key to reset everything and play
*              again.
*
*              One potential improvement to be made is to add some sort of 
*              projectile the robot can fire at bees. This would improve 
*              gameplay by keeping the game more interesting and providing the
*              player with a scoring mechanism. The bees already have some
*              existing code to handle "dying" but time constraints prevented
*              the addition of a projectile object and its handling.
*
* AUTHOR: Megan Galbraith
*
* DATE: December 2021
***********/

import java.util.List;
import java.util.LinkedList;


//-----GLOBAL VARIABLES-----//
private PImage ground, obs, wall;
private PFont font;
private final float[] BOUNDS = {-5.0, 5.0};
private final float RADIUS = sqrt(sq(BOUNDS[0])+sq(BOUNDS[1]));
private final float PANEL_SIZE = 0.4;
private final int NUM_PANELS = 25;
private final float BOX_HEIGHT = 0.3;
private final float SPEED = 0.02;
private Robot bobert;
private char[][] map = new char[NUM_PANELS][NUM_PANELS];
private float[] position;
private float[] direction;
private float[] move;
private float vLen;
private float[] step;
private float angle, turn;
private boolean jumpUp, jumpDown;
private boolean left, right;
private boolean gameOver;
private boolean firstPerson, free;
private float[] eye;
private float[] centre;
private float[] up;
private float eyeShift = 25, centreShift = 50;
private float[] freeShift; //smoother freelook transitions
private List<Bee> bees;
private int numBees = 0, beeStartPosPtr = 0;


/******************************************
* setup
*
* DESCRIPTION: Load textures and initialize game variables.
******************************************/
void setup() {
  size(640, 640, P3D);
  frameRate(30);
  newGame();
  
  ortho(-1, 1, 1, -1, -5, 5);
  resetMatrix();
  hint(DISABLE_OPTIMIZED_STROKE);

  font = loadFont("/data/Chiller-Regular-48.vlw");
  
  textureMode(NORMAL);
  ground = loadImage("assets/Moss.jpg");
  obs = loadImage("assets/bricks.jpeg");
  wall = loadImage("assets/OvergrownBrick.jpg");
  textureWrap(REPEAT); //or else clamp is default
    
  bobert = new Robot();
  fillMap();
  
  // add bees
  for(int i = 0; i < 5; i++) {
    float x = (BEES[i][0]*PANEL_SIZE-5)+PANEL_SIZE/2.0;
    float z = (BEES[i][1]*PANEL_SIZE-5)+PANEL_SIZE/2.0;
    float[] pos = {x,0.3,z};
    Bee temp = new Bee(pos);
    bees.add(temp);
    numBees++;
  }
  beeStartPosPtr = numBees;
}


/******************************************
* draw
*
* DESCRIPTION: Main calling function that runs throughout game play.
******************************************/
void draw() {
  if(!gameOver) {
    background(0);
  
    updateCam();
    camera(eye[0], eye[1], eye[2], centre[0], centre[1], centre[2],
                    up[0], up[1], up[2]);
    perspective(-1*PI/2.0, -1.0, 0.02, 15);
  
    drawWorld();
  
    updatePosition();
    bobert.drawRobot(move, turn+HALF_PI, firstPerson);
    
    int i = 0;
    while(i < numBees) {
      Bee currB = bees.get(i);   
      float[] bPos = currB.getPos();
      boolean tooClose = false;
      float[] noMove = {0,0,0};   
      
      //check bee state change before drawing
      
      if(currB.isAlive()) {
        //check if robot is "too close" to bee without a barrier between them
        if(dist(bPos[0],bPos[2],position[0],position[2]) < 1.0 && !barrier(bPos,noMove,0.05)) {
          tooClose = true;
        }
        
        currB.drawBee(position,tooClose);
        
        //check if bee has made contact with robot
        if(hit(bPos,0.01,position,0.2))
          gameOver = true;
        
        i++;
      }
      
      //dead but not sunk below floor yet
      else if (!currB.isAlive() && currB.getPos()[1] > -1) {
        currB.drawBee(bPos, false);
      }

      //dead and gone
      else {
        bees.remove(i);
        numBees--;
      }
    }
  }
}


/******************************************
* newGame
*
* DESCRIPTION: Reset all of the parameters and begin a new game
* 
* PARAMETERS:
******************************************/
void newGame() {
  position = new float[] {0,0,0};
  direction = new float[] {0, 0, RADIUS};
  move = position;
  vLen = sqrt(sq(direction[0]-position[0])+sq(direction[2]-position[2]));
  step = new float[] {(direction[0]-position[0])/vLen*SPEED, 0, (direction[2]-position[2])/vLen*SPEED};
  angle = turn = 0;
  jumpUp = jumpDown = false;
  left = right = false;
  gameOver = false;
  firstPerson = free = false;
  eye = new float[] {0, 0.9, -0.5};
  centre = new float[] {0, 0, 2};
  up = new float[] {0, 1, 0};
  eyeShift = 25;
  centreShift = 50;
  freeShift = new float[] {0,0};
  bees = new LinkedList<Bee>();
  numBees = 0;
  
  for(int i = 0; i < 5; i++) {
    float x = (BEES[i][0]*PANEL_SIZE-5)+PANEL_SIZE/2.0;
    float z = (BEES[i][1]*PANEL_SIZE-5)+PANEL_SIZE/2.0;
    float[] pos = {x,0.3,z};
    Bee temp = new Bee(pos);
    bees.add(temp);
    numBees++;
  }
  beeStartPosPtr = numBees;
}


/******************************************
* mouseClicked
*
* DESCRIPTION: Switches between free-view and fixed camera modes.
******************************************/
void mouseClicked() {
  free = !free;
  freeShift[0] = centre[0]-(5-10.0*mouseX/height);
  freeShift[1] = centre[1]-(5-10.0*mouseY/height);
}


/******************************************
* keyPressed
*
* DESCRIPTION: Checks which key has been pressed and responds accordingly.
*              'a' and 'd' are used to turn the robot left or right, 
*              respectively. Spacebar is jump. The 'enter' or 'return' key
*              switches between first or third person view. 'b' adds more bees,
*              to a maximum of 10 bees.
******************************************/
void keyPressed() {
  //regular game play
  if(!gameOver) {
    
    //enter == switch view
    if(key == '\n') {
      firstPerson = !firstPerson;
    }
  
    //space == jump
    else if(key == ' ') {
      jumpUp = true;
    }
  
    //a == move/turn left
    else if(key == 'a') {
      left = true;
    }
  
    //d == move/turn right
    else if(key == 'd') {
      right = true;
    }
    
    //add more bees
    else if(key == 'b') {
      if(numBees < 10 && beeStartPosPtr < 20) {
        float[] pos = {
          (BEES[beeStartPosPtr][0]*PANEL_SIZE-5)+PANEL_SIZE/2.0,
          0.3,
          (BEES[beeStartPosPtr][1]*PANEL_SIZE-5)+PANEL_SIZE/2.0
        };
        Bee another = new Bee(pos);
        bees.add(another);
        numBees++;
        beeStartPosPtr++;
      }
    }
    
  }
  
  //any key = start over
  else {
    gameOver = false;
    newGame();
  }
}


/******************************************
* keyReleased
*
* DESCRIPTION: Used to smooth turning transitions for the robot (otherwise it
*              looks quick abrupt and jerky).
******************************************/
void keyReleased() {
  left = false;
  right = false;
}


/******************************************
* drawWorld
*
* DESCRIPTION: Draw the ground, world bounds, stationary obstacles, and 
*              animated obstacles.
******************************************/
void drawWorld() {
  drawGround();
  drawBounds();
}


/******************************************
* drawGround
*
* DESCRIPTION: Draw the ground.
******************************************/
void drawGround() {
  int b = 0;
  
  for(int i = 0; i < NUM_PANELS; i++) {
    float z1 = BOUNDS[0] + i*PANEL_SIZE;
    float z2 = z1 + PANEL_SIZE;
    
    for(int j = 0; j < NUM_PANELS; j++) {
      float x1 = BOUNDS[0] + j*PANEL_SIZE;
      float x2 = x1 + PANEL_SIZE;
      
      if(b < BLOCKS.length && BLOCKS[b][0] == j && BLOCKS[b][1] == i) {
        drawObstacle(b, i, j);
        b++;
      }
      
      else {
        beginShape(QUADS);
        noStroke();
        texture(ground);
        vertex(x1, 0, z1, 0, 1);
        vertex(x1, 0, z2, 1, 1);
        vertex(x2, 0, z2, 1, 0);
        vertex(x2, 0, z1, 0, 0);
        endShape();
      }
    }
  }
}


/******************************************
* drawBounds
*
* DESCRIPTION: Draws the walls surrounding the world.
******************************************/
void drawBounds() {
  
  pushMatrix();
  
  for(int i = 0; i < 4; i++) {
    for(int j = 0; j < VERTS.length; j++) {

      beginShape(QUADS);
        
      noStroke();
      texture(wall);
      
      for(int k = 0; k < VERTS[j].length; k++) {
        vertex(WALL[VERTS[j][k]][0], WALL[VERTS[j][k]][1], WALL[VERTS[j][k]][2],
                        UV[k][0], UV[k][1]);
      }
      
      endShape();
    }
    
    rotateY(HALF_PI);
  }
  popMatrix();
}


/******************************************
* drawObstacles
*
* DESCRIPTION: Draws the boxes the robot can jump over.
******************************************/
void drawObstacle(int b, int col, int row) {
  float y1 = 0, y2 = BOX_HEIGHT;
  float x1 = BOUNDS[0] + row*PANEL_SIZE;
  float x2 = x1 + PANEL_SIZE;
  float z2 = BOUNDS[0] + col*PANEL_SIZE;
  float z1 = z2 + PANEL_SIZE;
  
  float[][] block = {
    {x1,y1,z1},
    {x1,y2,z1},
    {x2,y2,z1},
    {x2,y1,z1},
    
    {x2,y1,z2},
    {x2,y2,z2},
    {x1,y2,z2},
    {x1,y1,z2}
  };
  
  //draw top regardless
  noStroke();
  fill(#808080); //grey
  beginShape(QUADS);
  for(int i = 0; i < VERTS[0].length; i++) {
    vertex(block[VERTS[0][i]][0], block[VERTS[0][i]][1], block[VERTS[0][i]][2]);
  }
  endShape();
  
  //outside of the boxes
  for(int i = 1; i < VERTS.length; i++) {
    
    beginShape();
    texture(obs);
    
    for(int j = 0; j < VERTS[i].length; j++) {
      
      //if not sharing a side with another box, draw the side
      if(BLOCKS[b][i+1] == 0) {
        vertex(block[VERTS[i][j]][0], block[VERTS[i][j]][1], block[VERTS[i][j]][2], UV[j][0], UV[j][1]);
      }
    }
    
    endShape();
  }
}


/******************************************
* updatePosition
*
* DESCRIPTION: Manage the position of the robot within the world.
******************************************/
void updatePosition() {
  final float MAX_HEIGHT = 0.4;
  final float ANGLE = PI/900;
  float temp = direction[0];

  //turn
  if(right) {
    //move "direction" pointer around circle
    if(angle < 0)
      angle *= -1;
    
    angle += ANGLE;
  }
  
  else if(left) {
    
    if (angle > 0)
      angle *= -1;
    
    angle -= ANGLE;
  }
  
  if(right || left) {
    direction[0] = (direction[0]*cos(angle) - direction[2]*sin(angle));
    direction[2] = (temp*sin(angle) + direction[2]*cos(angle));
    
    vLen = sqrt(sq(direction[0]-position[0])+sq(direction[2]-position[2]));
    step[0] = (direction[0]-position[0])/vLen * SPEED;
    step[2] = (direction[2]-position[2])/vLen * SPEED;
  }
  
  turn = -1*atan2(direction[2]-position[2], direction[0]-position[0]);
  boolean collide = barrier(move, step, 8);
  
  //walking
  if((collide && position[1] >= BOX_HEIGHT) || !collide) {
    if(move[0]+step[0] > BOUNDS[0]+0.2 && move[0]+step[0] < BOUNDS[1]-0.2) {
      move[0] += step[0];
    }
    
    if(move[2]+step[2] > BOUNDS[0]+0.2 && move[2]+step[2] < BOUNDS[1]-0.2) {
      move[2] += step[2];
    }
  }
  
  if(jumpUp) {
    if(position[1] < MAX_HEIGHT)
      position[1] += 0.015;
    else {
     jumpUp = false;
     jumpDown = true;
    }
  }
  else if(jumpDown) {
    if(position[1] - 0.015 <= 0) {
      position[1] = 0;
      jumpDown = false;
    }
    else if(collide && position[1] > BOX_HEIGHT) {
      position[1] -= 0.015;
      position[1] = max(position[1],BOX_HEIGHT);
    }
    else if(!collide)
      position[1] -= 0.015;
  }
}


/******************************************
* updateCamera
*
* DESCRIPTION: Update the camera position to follow the robot. If in first
*              person mode
******************************************/
void updateCam() {
  //first person
  if(firstPerson) {
    
    eye[0] = move[0];
    eye[1] = position[1]+0.6;
    eye[2] = move[2] + step[2]*8;
  }
  
  //third person
  else {
    eye[0] = move[0]+(-1*step[0]*eyeShift);
    eye[1] = position[1]+0.8;
    eye[2] = move[2]+(-1*step[2]*eyeShift);  
  }
  
  centre[0] = move[0]+(step[0]*centreShift);
  centre[1] = position[1];
  centre[2] = move[2]+(step[2]*centreShift);
  
  //free-look only available in first person mode
  if(firstPerson && free) {
    //constrain lateral movement
    float mX = min(max(mouseX, width/4.0), width-width/4.0);
    
    if(step[2] > 0)
      centre[0] += freeShift[0]+(5-10.0*mX/width);
    else
      centre[0] -= freeShift[0]+(5-10.0*mX/width);
    
    //vertical movement, with constraint
    centre[1] += freeShift[1]+(5-10.0*mouseY/height);
    centre[1] = max(min(centre[1], 0.9), -0.8);
  }
}


/******************************************
* barrier
*
* DESCRIPTION: Check if object is about to move into a grid square containing
*              a barrier.
* 
* PARAMETERS:
*         pos: The current (x,y,z) centre of an object.
*         mov: The next (x,y,z) centre of an object.
*         buffer: An allowable gap between the centre of the object and the
*                 edge of the barrier space.
*
* RETURNS: A boolean about whether a collision with a barrier has/will occur.
******************************************/
boolean barrier(float[] pos, float[] mov, float buffer) {
  boolean collision = false;
  int x = min((int)((pos[0]+BOUNDS[1])/PANEL_SIZE),24);
  int z = min((int)((pos[2]+BOUNDS[1])/PANEL_SIZE),24);
  int nextX = min((int)((pos[0]+BOUNDS[1]+mov[0]*buffer)/PANEL_SIZE), 24);
  int nextZ = min((int)((pos[2]+BOUNDS[1]+mov[2]*buffer)/PANEL_SIZE), 24);
    
  if(map[nextX][nextZ] == 'b')
    collision = true;
    
  if(map[x][z] == 'b')
    collision = true;
    
  return collision;
}


/******************************************
* hit
*
* DESCRIPTION: Detects if two objects are close enough to be considered a "hit."
* 
* PARAMETERS:
*         obj: Centre (x,y,z) of first object.
*         objBuff: Buffer space between obj centre and hitbox edge.
*         target: Centre (x,y,z) of second object.
*         targetBuff: Buffer space between target centre and hitbox edge.
*
* RETURNS: A boolean about whether a hit has occured or not.
******************************************/
boolean hit(float[] obj, float objBuff, float[] target, float targetBuff) {
  boolean oof = false;
  
  float dist = dist(target[0],target[2],obj[0],obj[2]);
  
  if(dist < objBuff+targetBuff)
    oof = true;
  
  return oof;
}


/******************************************
* fillMap
*
* DESCRIPTION: Fill a char grid map for collision detection. 'b' indicates a
*              barrier space while 'g' is a general space.
******************************************/
void fillMap() {
  int b = 0;
  
  for(int i = 0; i < NUM_PANELS; i++) {
    for(int j = 0; j < NUM_PANELS; j++) {
      
      if(b < BLOCKS.length) {
        
        if(BLOCKS[b][0] == j && BLOCKS[b][1] == i) {
          map[j][i] = 'b';
          b++;
        }
        else
          map[j][i] = 'g';
      }
      
      else
        map[j][i] = 'g';
    }
  }  
}




//-----GLOBAL CONSTANTS-----//
final float[][] WALL = {
    {-5.2, 0, -5},
    {-5.2, 1.5, -5},
    {5.2, 1.5, -5},
    {5.2, 0, -5},
    
    {5.2, 0, -5.2},
    {5.2, 1.5, -5.2},
    {-5.2, 1.5, -5.2},
    {-5.2, 0, -5.2}
};

final int[][] VERTS = {
     {1, 6, 5, 2}, //top
     {0, 1, 2, 3}, //front
     {7, 6, 5, 4}, //back
     {0, 7, 6, 1}, //left
     {5, 2, 3, 4} //right
};

//u,v values for texture mapping directions
  final int[][] UV = {
    {0,1},
    {1,1},
    {1,0},
    {0,0}
};


//grid position of bees
final int[][] BEES = {
      {2,2},
      {19,6},
      {22,17},
      {6,18},
      {15,22},
      {3,11},
      {23,23},
      {13,1},
      {7,7},
      {2,22},
      {15,17},
      {9,10},
      {7,2},
      {22,8},
      {9,18},
      {1,1},
      {11,10},
      {13,20},
      {8,15},
      {10,6}
};

//grid coord and side adjacency - 0="open/draw", 1="closed/don't draw" 
final int[][] BLOCKS = {
      {16,2,  0,0,0,1}, 
      {17,2,  0,0,1,1}, 
      {18,2,  0,0,1,1}, 
      {19,2,  0,0,1,0},
      {4,3,   1,0,0,0},
      {3,4,   0,0,0,1}, 
      {4,4,   0,1,1,0}, 
      {0,9,   1,0,1,1}, 
      {1,9,   1,0,1,1}, 
      {2,9,   1,0,1,0}, 
      {15,9,  1,0,0,0}, 
      {21,9,  0,0,0,1}, 
      {22,9,  0,0,1,1}, 
      {23,9,  0,0,1,0},
      {0,10,  0,1,1,1}, 
      {1,10,  0,1,1,1}, 
      {2,10,  0,1,1,0}, 
      {15,10, 1,1,0,0},
      {15,11, 0,1,0,0},
      {3,15,  0,0,0,1}, 
      {4,15,  0,0,1,1}, 
      {5,15,  0,0,1,0},
      {15,19, 1,0,0,0},
      {14,20, 1,0,0,1}, 
      {15,20, 0,1,1,1}, 
      {16,20, 0,0,1,1}, 
      {17,20, 1,0,1,0},
      {13,21, 1,0,0,1}, 
      {14,21, 0,1,1,0}, 
      {17,21, 1,1,0,0},
      {12,22, 0,0,0,1}, 
      {13,22, 0,1,1,0}, 
      {17,22, 1,1,0,0},
      {2,23,  0,0,0,1}, 
      {3,23,  1,0,1,0}, 
      {17,23, 1,1,0,0},
      {3,24,  1,1,0,0}, 
      {17,24, 1,1,0,0}
};
