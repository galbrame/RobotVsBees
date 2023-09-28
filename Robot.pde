/***********
* DESCRIPTION: The Robot object. The robot is a simple block construct with
*              simple articulating joints. Effort was made to prevent faces
*              from visibly intersecting with each other, but resolution is
*              still low quality and the joints are essentially open space.
*
*              The robot walks through its world at a constant pace. Position
*              is managed within the game itself.
*
* AUTHOR: Megan Galbraith
*
* DATE: December 2021
***********/

class Robot {  
  
  //-----GLOBALS-----//
  private PShape head;
  private float headRot = 0;
  private boolean headClockwise = false; //control head tilting
  private boolean dominantForward = true; //control opposite limb rotation
  //[0] and [1] are constraints, [2] and [3] are curr rotation angles
  private final int UPPER = 0, LOWER = 1, LT = 2, RT = 3;
  private float[][] angles = {
        {radians(-25), radians(25), radians(-25), radians(25)}, //upper part of limb
        {radians(-45), 0, radians(-45), 0}, //lower part of limb
  };

  //global indexing arrays for colours, vertices, etc found at bottom of code

  
  
  public Robot() {
    head = loadShape("data/teapot.obj");
  }
  

  /******************************************
  * drawRobot
  *
  * DESCRIPTION: Draws all the components of the robot. If the robot is jumping,
  *              the y-axis will be taken into account. If in first person
  *              perspective, we will not draw the head or body, to avoid
  *              clipping and give a tiny performace boost.
  * 
  * PARAMETERS:
  *         pos: The current (x,y,z) of the robot.
  *         ang: The angle of the robot around the Y-axis (for turning)
  *         isFirstPerson: Draw in first person or third person perspective
  ******************************************/
  public void drawRobot(float[] pos, float ang, boolean isFirstPerson) {
    pushMatrix();
    moveRobot(pos, ang);
    
    scale(0.8); //make robot better size for platform
    //raise slightly above platform to minimize platform intersection
    translate(0, 0.02); 
    
    //avoids clipping and weirdness in first person
    if(!isFirstPerson) {
      drawTorso();
      drawHead();
    }
    
    drawArms();
    drawLegs();
    
    updateAngles();
    if(angles[1][2] <= angles[1][0] || angles[1][2] >= angles[1][1]) {
      dominantForward = !dominantForward;
    }
    
    popMatrix();
  }


  /******************************************
  * drawTorso
  *
  * DESCRIPTION: Draws the cube that makes up the robot's torso.
  ******************************************/
  private void drawTorso() {
    stroke(WHITE);
    
    beginShape(QUADS);
    for(int i = 0; i < PALETTE.length; i++) {
      fill(PALETTE[ID[(i+5)%ID[i].length+1][ID[i].length-1]]);
    
      for(int j = 0; j < ID[i].length-1; j++) {
        vertex(VS_TORSO[ID[i][j]][0], VS_TORSO[ID[i][j]][1], VS_TORSO[ID[i][j]][2]);
      }
    
    }
    endShape();
  
  }


  /******************************************
  * drawHead
  *
  * DESCRIPTION: Transforms the teapot.obj into the robot's head and makes it
  *              spin.
  ******************************************/
  private void drawHead() {
    final float FRONT = 0.6;
    final float HEAD_SPEED = PI/60;
    
    if(headClockwise)
      headRot += HEAD_SPEED;
    else
      headRot -= HEAD_SPEED;
  
    if(headRot > radians(25) || headRot < radians(-25))
      headClockwise = !headClockwise;
  
    pushMatrix();
    translate(0, VS_TORSO[0][1], 0);
    rotateZ(headRot);
    rotateY(FRONT);
    scale(0.05);
    shape(head);
    popMatrix();
  }


  /******************************************
  * drawArms
  *
  * DESCRIPTION: Draws each component of the robot's arms.
  * 
  * PARAMETERS:
  *         
  ******************************************/
  private void drawArms() {
    final float TOP_SHIFT = 0.3;
    final float BOTTOM_SHIFT = 0.33;
  
    stroke(WHITE);
  
    for(int i = 0; i < PALETTE.length; i++) {
    
      pushMatrix(); //left arm
      transform(ARM_TOP_CENTRE[0], ARM_TOP_CENTRE[1], 0, angles[UPPER][LT]);
    
      //left top
      fill(PALETTE[ID[(i+2)%ID[i].length+1][ID[i].length-1]]);
      beginShape( QUADS);
      for(int j = 0; j < ID[i].length-1; j++) {
        vertex(VS_ARM_TOP[ID[i][j]][0], VS_ARM_TOP[ID[i][j]][1], VS_ARM_TOP[ID[i][j]][2]);
      }
      endShape();
    
      //lower arm transformations
      transform(VS_ARM_BOTTOM[0][0], VS_ARM_BOTTOM[0][1], -1*VS_ARM_BOTTOM[0][2], angles[LOWER][LT]);
    
      //left lower
      fill(PALETTE[ID[(i+3)%ID[i].length+1][ID[i].length-1]]);
      beginShape(QUADS);
      for(int j = 0; j < ID[i].length-1; j++) {
        vertex(VS_ARM_BOTTOM[ID[i][j]][0], VS_ARM_BOTTOM[ID[i][j]][1], VS_ARM_BOTTOM[ID[i][j]][2]);
      }
      endShape();
      popMatrix();
    
      //right arm transformations
      pushMatrix(); 
      transform(ARM_TOP_CENTRE[0]+TOP_SHIFT, ARM_TOP_CENTRE[1], 0, angles[UPPER][RT]);
    
      //right top
      fill(PALETTE[ID[(i+2)%ID[i].length+1][ID[i].length-1]]);
      beginShape(QUADS);
      for(int j = 0; j < ID[i].length-1; j++) {
        vertex(VS_ARM_TOP[ID[i][j]][0]+TOP_SHIFT, VS_ARM_TOP[ID[i][j]][1], VS_ARM_TOP[ID[i][j]][2]);
      }
      endShape();
    
      //lower arm transformations
      transform(VS_ARM_BOTTOM[0][0]+BOTTOM_SHIFT, VS_ARM_BOTTOM[0][1], -1*VS_ARM_BOTTOM[0][2], angles[LOWER][RT]);
    
      //right lower
      fill(PALETTE[ID[(i+3)%ID[i].length+1][ID[i].length-1]]);
      beginShape(QUADS);
      for(int j = 0; j < ID[i].length-1; j++) {
        vertex(VS_ARM_BOTTOM[ID[i][j]][0]+BOTTOM_SHIFT, VS_ARM_BOTTOM[ID[i][j]][1], VS_ARM_BOTTOM[ID[i][j]][2]);
      }
      endShape();
      popMatrix();
    }
  
  }


  /******************************************
  * drawLegs
  *
  * DESCRIPTION: Draws each component of the robot's legs.
  ******************************************/
  private void drawLegs() {
    final float Y_SHIFT = 0.15; //shift verices to draw
    final float X_SHIFT = 0.2; //other parts of legs
  
    stroke(WHITE);
  
    for(int i = 0; i < PALETTE.length; i++) {
      fill(PALETTE[ID[i][ID[i].length-1]]);
    
      pushMatrix(); //whole left leg
      transform(LEG_CENTRE[0], LEG_CENTRE[1]+Y_SHIFT*1.5, 0, angles[UPPER][LT]);
    
      //left top
      beginShape(QUADS);
      for(int j = 0; j < ID[i].length-1; j++) {
        vertex(VS_LEG[ID[i][j]][0], VS_LEG[ID[i][j]][1]+Y_SHIFT, VS_LEG[ID[i][j]][2]);
      }
      endShape();
    
      transform(VS_LEG[0][0], VS_LEG[0][1], VS_LEG[0][2], QUARTER_PI+angles[LOWER][LT]);
    
      //left bottom
      beginShape(QUADS);
      for(int j = 0; j < ID[i].length-1; j++) {
        vertex(VS_LEG[ID[i][j]][0], VS_LEG[ID[i][j]][1], VS_LEG[ID[i][j]][2]);
      }
      endShape();
      popMatrix(); //whole left leg
    
    
      pushMatrix(); //whole right leg
      transform(LEG_CENTRE[0]+X_SHIFT, LEG_CENTRE[1]+Y_SHIFT*1.5, 0, angles[UPPER][RT]);
    
      //right top
      beginShape(QUADS);
      for(int j = 0; j < ID[i].length-1; j++) {
        vertex(VS_LEG[ID[i][j]][0]+X_SHIFT, VS_LEG[ID[i][j]][1]+Y_SHIFT, VS_LEG[ID[i][j]][2]);
      }
      endShape();
    
      transform(VS_LEG[0][0], VS_LEG[0][1], VS_LEG[0][2], QUARTER_PI+angles[LOWER][RT]);
    
      //right bottom
      beginShape(QUADS);
      for(int j = 0; j < ID[i].length-1; j++) {
        vertex(VS_LEG[ID[i][j]][0]+X_SHIFT, VS_LEG[ID[i][j]][1], VS_LEG[ID[i][j]][2]);
      }
      endShape();
      popMatrix(); //whole right leg
    }  
  
  }


  /******************************************
  * moveRobot
  *
  * DESCRIPTION: Translates the whole robot across the world
  * 
  * PARAMETERS:
  *         pos: The (x,y,z) coordinates of the robot in the world
  *         ang: Angle in relation to y-axis to turn robot through world
  ******************************************/
  public void moveRobot(float[] pos, float ang) {
    translate(pos[0], pos[1], pos[2]);
    rotateY(ang);
  }


  /******************************************
  * updateAngles
  *
  * DESCRIPTION: Updates all of the angles used in limb movements   
  ******************************************/
  private void updateAngles() {
    float biggest = abs(angles[0][0] - angles[0][1]);
  
    for(int i = 0; i < angles.length; i++) {
      float diff = radians(2)/abs(angles[i][0]-angles[i][1])/biggest;
    
      if(dominantForward) {
        angles[i][LT] += diff;
        angles[i][RT] -= diff;
      }
      else {
        angles[i][LT] -= diff;
        angles[i][RT] += diff;
      }
    }
  }


  /******************************************
  * transform
  *
  * DESCRIPTION: Consolidate repeated transformation calls - translate to
  *              position, rotate around the origin, then return to position.
  * 
  * PARAMETERS:
  *         x: The x coordinate in the world.
  *         y: The y coordinate in the world.
  *         z: The z coordinate in the world.
  *         ang: Desired joint articulation angle.
  ******************************************/
  private void transform(float x, float y, float z, float ang) {
    translate(x, y, z);
    rotateX(ang);
    translate(-1*x, -1*y, -1*z);
  }
  
  
  
  //-----GLOBAL INDEXING ARRAYS-----//

  private final color WHITE = #FFFFFF;
  private final color[] PALETTE = {
        #00F5FB,
        #9600FF,
        #FFF100,
        #FF00E3,
        #38FF12,
        #1900A0
  };


  private final float[][] VS_LEG = {
        //left bottom leg - everything else based on
        {-0.15, 0.15, -0.05}, //0
        {-0.05, 0.15, -0.05}, //1
        {-0.05, 0, -0.05}, //2
        {-0.15, 0, -0.05}, //3
        {-0.15, 0.15, 0.05}, //4
        {-0.05, 0.15, 0.05}, //5
        {-0.05, 0, 0.05}, //6
        {-0.15, 0, 0.05}, //7
  };

  private final float[] LEG_CENTRE = {-0.1, 0.075, 0};
  
  private final float[][] VS_TORSO = {
        {-0.1, 0.6, -0.1},
        {0.1, 0.6, -0.1},
        {0.1, 0.25, -0.1},
        {-0.1, 0.25, -0.1},
        {-0.1, 0.6, 0.1},
        {0.1, 0.6, 0.1},
        {0.1, 0.25, 0.1},
        {-0.1, 0.25, 0.1}
  };

  private final float[][] VS_ARM_TOP = {
        {-0.2, 0.55, -0.05},
        {-0.1, 0.55, -0.05},
        {-0.1, 0.45, -0.05},
        {-0.2, 0.45, -0.05},
        {-0.2, 0.55, 0.05},
        {-0.1, 0.55, 0.05},
        {-0.1, 0.45, 0.05},
        {-0.2, 0.45, 0.05}
  };

  private final float[] ARM_TOP_CENTRE = {-0.15, 0.5, 0}; 

  private final float[][] VS_ARM_BOTTOM = {
        {-0.2, 0.45, -0.05},
        {-0.13, 0.45, -0.05},
        {-0.13, 0.3, -0.05},
        {-0.2, 0.3, -0.05},
        {-0.2, 0.45, 0.05},
        {-0.13, 0.45, 0.05},
        {-0.13, 0.3, 0.05},
        {-0.2, 0.3, 0.05}
  };

  //v0, v1, v2, v3, colour index
  private final int[][] ID = new int[][] {
        {0, 1, 2, 3, 0}, //front
        {1, 5, 6, 2, 1}, //side 1
        {4, 5, 6, 7, 2}, //back
        {4, 0, 3, 7, 3}, //side 2
        {0, 1, 5, 4, 4}, //top
        {3, 2, 6, 7, 5}, //bottom

  };
} //robot class
