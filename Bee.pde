/***********
* DESCRIPTION: The Bee class. Bees are non-playable characters that exist
*              within the game world. If left alone, they happily float in
*              small circles wherever they spawn. However, if the player gets
*              too close, the bee will get angry and chase after the player.
*
* AUTHOR: Megan Galbraith
*
* DATE: December 2021
***********/

class Bee {
  
  //-----GLOBALS-----//
  private PImage beeSkin, happyBee, angryBee, deadBee, beeBum;
  private final float HOME_RADIUS = 0.12; //space happy bee floats within
  private float[] homePos, beePos;
  private float rot = 0; //bee circling angle
  private float angR = radians(10), angL = -1*radians(10); //wing flapping
  private float deathAng = 0;
  private boolean flap = true;
  private boolean up; //bee bobs up and down as it circles
  private boolean stop = true, dead = false, exists = true;
  
  //global indexing arrays for vertices, etc found at bottom of code
  
  
  /******************************************
  * Bee
  *
  * DESCRIPTION: Constructor
  * 
  * PARAMETERS:
  *         pos: The starting position of the bee.
  ******************************************/
  public Bee(float[] pos) {
    beeSkin = loadImage("assets/beeSkin.png");
    happyBee = loadImage("assets/happyBee.png");
    angryBee = loadImage("assets/angryBee.png");
    deadBee = loadImage("assets/deadBee.png");
    beeBum = loadImage("assets/beeBum.png");
    
    homePos = pos;
    beePos = new float[] {homePos[0]+HOME_RADIUS,homePos[1],homePos[2]+HOME_RADIUS};
  }
  
  
  /******************************************
  * drawBee
  *
  * DESCRIPTION: Draw the bee based on its position and state.
  * 
  * PARAMETERS:
  *         target: Position (x,y,z) of something bee is chasing.
  *         isAngry: Boolean to trigger attack mode and angry tinting.
  ******************************************/
  public void drawBee(float[] target, boolean isAngry) {
    pushMatrix();
    
    if(dead)
      deathThroes();
    else if(isAngry)
      attack(target);
    else
      moveBee();
    
    textureMode(NORMAL);
    textureWrap(REPEAT);
    drawBody(isAngry);
    drawFace(isAngry);
    
    popMatrix();
  }
  
  
  /******************************************
  * drawBody
  *
  * DESCRIPTION: Draw the bee body and do texture mapping.
  * 
  * PARAMETERS:
  *         isAngry: Boolean to trigger attack mode and angry tinting.
  ******************************************/
  private void drawBody(boolean isAngry) {
    if(isAngry)
      tint(200,0,0);
    
    //body
    for(int i = 1; i < INDEX.length; i++) {
      beginShape(QUADS);
      noStroke();
      
      if(i < 5)
        texture(beeSkin);
      else
        texture(beeBum);
      
      for(int j = 0; j < INDEX[i].length; j++) {
        vertex(VERTS[INDEX[i][j]][0], VERTS[INDEX[i][j]][1], VERTS[INDEX[i][j]][2],
                  UV[j][0], UV[j][1]);
      }
      
      endShape();
    }
    
    drawWing();
    noTint();
  }
  
  
  /******************************************
  * drawWing
  *
  * DESCRIPTION: Draw the bee wing.
  ******************************************/
  private void drawWing() {
    final float MIN_ANG = radians(10), MAX_ANG = radians(60);
    float diff = radians(25)/(MAX_ANG-MIN_ANG);
    stroke(255,255,255);
    fill(153,217,234);
    
    if(flap) {
      angR += diff;
      angL -= diff;
    }
    else {
      angR -= diff;
      angL += diff;
    }
    
    if(angR >= MAX_ANG || angR <= MIN_ANG)
      flap = !flap;
    
    for(int i = 0; i < WING_IND.length; i++) {
      pushMatrix();
      
      if(!dead) {
        translate(WINGS[0][0], WINGS[0][1],WINGS[0][2]);
        rotateX(angL);
        translate(-1*WINGS[0][0], -1*WINGS[0][1],-1*WINGS[0][2]);
      }
      else {
        translate(WINGS[0][0], WINGS[0][1],WINGS[0][2]);
        rotateX(MAX_ANG);
        translate(-1*WINGS[0][0], -1*WINGS[0][1],-1*WINGS[0][2]);
      }
        
      
      beginShape();
      for(int j = 0; j < WING_IND[i].length; j++) {
        vertex(WINGS[WING_IND[i][j]][0], WINGS[WING_IND[i][j]][1], WINGS[WING_IND[i][j]][2]);
      }
      endShape();
      popMatrix();
      
      pushMatrix();
      
      if(!dead) {
        translate(WINGS[0][0], WINGS[0][1],WINGS[0][2]+0.01);
        rotateX(angR);
        translate(-1*WINGS[0][0], -1*WINGS[0][1],-1*(WINGS[0][2]+0.01));
      }
      else {
        translate(WINGS[0][0], WINGS[0][1],WINGS[0][2]+0.01);
        rotateX(-1*MAX_ANG);
        translate(-1*WINGS[0][0], -1*WINGS[0][1],-1*(WINGS[0][2]+0.01));
      }
      
      beginShape();
      for(int j = 0; j < WING_IND[i].length; j++) {
        vertex(WINGS[WING_IND[i][j]][0], WINGS[WING_IND[i][j]][1], WINGS[WING_IND[i][j]][2]+0.01);
      }
      endShape();
      popMatrix();
    }
  }
  
  
  /******************************************
  * drawFace
  *
  * DESCRIPTION: Draw the bee's face and do texture mapping.
  * 
  * PARAMETERS:
  *         isAngry: Boolean to add angry tint.
  ******************************************/
  private void drawFace(boolean isAngry) {
    beginShape(QUADS);
    noStroke();
    
    if(dead)
      texture(deadBee);
    else if(isAngry) {
      tint(200,0,0);
      texture(angryBee); 
    }
    else
      texture(happyBee);
      
    
    for(int i = 0; i < INDEX[0].length; i++) {
      vertex(VERTS[INDEX[0][i]][0], VERTS[INDEX[0][i]][1], VERTS[INDEX[0][i]][2],
                UV[i][0], UV[i][1]);
    }
    
    noTint();
    endShape();
  }
  
  
  /******************************************
  * moveBee
  *
  * DESCRIPTION: Regular happy bee movements - lazy circles while floating
  *              up and down.
  ******************************************/
  private void moveBee() {
    final float RADS = radians(2); 
    
    if(!stop) {
      homePos[0] = beePos[0];
      homePos[2] = beePos[2];
      stop = true;
    }
        
    float tempX = beePos[0];
     
    floaty();
      
    beePos[0] = homePos[0] + (tempX-homePos[0])*cos(RADS) - (beePos[2]-homePos[2])*sin(RADS);
    beePos[2] = homePos[2] + (tempX-homePos[0])*sin(RADS) + (beePos[2]-homePos[2])*cos(RADS);
            
    rot -= RADS;
    if(rot <= -1*TWO_PI)
      rot += TWO_PI;
            
    translate(beePos[0], beePos[1], beePos[2]);
    rotateY(rot);
  }
  
  
  /******************************************
  * floaty
  *
  * DESCRIPTION: Float a happy bee up and down (angry bees just come right
  *              for you).
  ******************************************/
  private void floaty() {
    float minY = 0.25, maxY = 0.4;
    
    if(up)
      beePos[1] += 0.01;
    else
      beePos[1] -= 0.01;
    
    if(beePos[1] > maxY)
      up = false;
    if(beePos[1] < minY)
      up = true;
  }
  
  
  /******************************************
  * attack
  *
  * DESCRIPTION: Bee attack movements. The bee heads straight towards the
  *              target.
  * 
  * PARAMETERS:
  *         target: Coordinates (x, y, z) of object bee is attacking.
  ******************************************/
  public void attack(float[] target) {
    final float ANG = radians(5);
    float attackAng = atan2(target[0]-homePos[0], target[2]-homePos[2]);

    stop = false;
        
    if(rot != attackAng) {
      if(abs(attackAng-rot) > ANG || abs(attackAng+rot) > ANG) {
        if(degrees(attackAng) > degrees(rot))
          rot += ANG;
        else
          rot -= ANG;
      }
      else
        rot = attackAng;
    }
    
    float vLen = sqrt(sq(target[0]-beePos[0])+sq(target[2]-beePos[2]));
    
    beePos[0] += (target[0]-beePos[0])/vLen * 0.01;
    beePos[2] += (target[2]-beePos[2])/vLen * 0.01;
    
    translate(beePos[0],beePos[1],beePos[2]);
    rotateY(rot);
  }
  
  
   /******************************************
  * deathThroes
  *
  * DESCRIPTION: If the bee dies, it rolls onto its back and slowly sinks
  *              towards the floor.
  ******************************************/
  private void deathThroes() {
    //rolls over
    if(deathAng <= PI) {
      deathAng += radians(5);
    }
    
    //sinks to floor
    else {
      if(beePos[1] >= -0.2)
        beePos[1] -= 0.01;
      else
        exists = false;
    }
    
    translate(beePos[0],beePos[1],beePos[2]);
    rotateX(deathAng);
  }
  
  
   /******************************************
  * die
  *
  * DESCRIPTION: The bee is killed.
  ******************************************/
  public void die() {
    dead = true;
  }


   /******************************************
  * isAlive
  *
  * DESCRIPTION: When we need to know if the bee is still alive and can fly/
  *              attack things.
  * 
  * RETURNS: A boolean whether bee is alive or not.
  ******************************************/
  public boolean isAlive() {
    return !dead;
  }
  
  
  /*****
  * Get the bee's position
  *****/
  /******************************************
  * getPos
  *
  * DESCRIPTION: Find the current position of the bee.
  * 
  * RETURNS: An array of the [x, y, z] coordinates of the bee.
  ******************************************/
  public float[] getPos() {
    return beePos;
  }
  
  

  //-----GLOBAL INDEXING ARRAYS-----//

  private final float[][] VERTS = {
        {-0.05,0,-0.05},
        {-0.05,0.1,-0.05},
        {0.05,0.1,-0.05},
        {0.05,0,-0.05},
        
        {-0.05,0,0.05},
        {-0.05,0.1,0.05},
        {0.05,0.1,0.05},
        {0.05,0,0.05},
        
        {0.09,0.05,0} //stinger
  };
  
  private final int[][] INDEX = {
        {4,5,1,0}, //face
        {0,1,2,3}, //body
        {1,5,6,2},
        {7,6,5,4},
        {4,0,3,7},
        {3,2,6,7}
  };
  
  private final float[][] WINGS = {
        {0,0.08,0},
        {-0.025,0.17,0},
        {0.025,0.17,0},
        
        {0,0.08,-0.005},
        {-0.025,0.17,-0.005},
        {0.025,0.17,-0.005},
  };
  
  private final int[][] WING_IND = {
        {0,1,2},
        {3,4,5},
        {3,0,1,4},
        {5,2,1,4},
        {3,0,2,5}
  };
  
  private final int[][] UV = {
        {1,1},
        {1,0},
        {0,0},
        {0,1}
  };
}
