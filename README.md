# Robot vs Bees Game
A basic obstacle avoidance game, created for a computer graphics assignment. The robot will move forward at a constant rate until it meets an obstacle or bee. Contact with a bee will end the game, so avoid the bees! Bees will happily float within the world until the robot comes within a certain distance. The robot can try to run away from bees or leap over short walls to escape.

The robot moves around an (x,z) plane and jumps using the y-axis.

Note: This was my first attempt at a 3D game in Processing, and as such, creating a more accurate hit box for contact with odd angles, etc. was a bit beyond my scope. I do not intend to go back and improve it at this time.

![robot vs bees basic game play](/readme_img/rVSb_basic.gif)


# Build Notes
This game was built on the following machine specs:
* Processing Version: 3.5.4
* OS: Windows 10
* Graphics Hardware: Intel(R) UHD Graphics 620


# Folder Structure
* /assets contains all of the textures for the game
* /data contains the imported 3D teapot object (robot's head)


# Game Play
* Contact with a bee will end the game. Run away or leap over obstacles to escape. 
* NOTE: If you get a little hung up on an obstacle, jumping usually gets you free.
* KEYS:
    * Directional: 'a' turns the robot left, 'd' turns the robot right
    * SPACEBAR makes the robot jump
    * ENTER switches between first and third person
    * Clicking in the screen while in first person switches to free-look camera mode; clicking again returns to fixed camera
    * Pressing 'b' will add another bee, to a maximum of 10 bees
* If the game ends, press any key to restart

![robot vs bees perspective changes](/readme_img/rVSb_perspective.gif)


# How to Run
1. Copy all files to a local folder
    * NOTE: The folder **MUST** be named `RobotVsBees` for Processing to run it
2. Open Processing (Processing 3.5.4 or higher)
3. In Processing, go to File > Open... and navigate to your /RobotVsBees folder
4. Select `RobotVsBees.pde` and click 'Open'
5. Click the 'run' (play) button.
6. Enjoy!


# Acknowledgements
* Teapot head: teapot.obj modified from files at https://free3d.com/3d-model/teapot-glass-58146.html by rito-kun
* Moss.jpg from https://www.textures.com/download/Moss0021/8998
* OvergrownBrick.jpeg from https://www.textures.com/download/BrickOldOvergrown0008/53532
* bricks.jpg from https://www.textures.com/download/BrickOldOvergrown0027/52638
* All bee textures made by me in Microsoft Paint
