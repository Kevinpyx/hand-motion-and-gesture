#include "stdio.h"
#include "stdlib.h"
#include "mex.h"
#include "MyroC.h"

//This function will allow for us to move the robot in the directions we want
// to move it, 
// Preconditions: motion : an int representing the direction of the motion
//                speed : an int representing how fast the robot will move
//                dur : an int representing how long the motion will be
// Postconditions: none, the robot will be move
void move(int motion,  double speed, double dur ){
  switch (motion){
  case 0: rForward(speed, dur); break;
  case 1: rTurnLeft(speed, (.25 * dur)); rForward(speed, dur); break;
  case 2: rBackward(speed, dur);  break;
  case 3: rTurnRight(speed, (.25 * dur)); rForward(speed, dur); break;
  default: printf("The Robot was unable to move, please try again"); 
  }
  
}

// A mex function for getting the input values from our array
// and feeding them to the move function
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, 
                 const mxArray *prhs[]){
  
  //Converts our string to a number
  // 0 : Forward
  // 1 : Left
  // 2 : Back
  // 3 : Right 
  int motion_direction = (int) mxGetScalar(prhs[0]); 
  double speed = mxGetScalar(prhs[1]);
  double duration = mxGetScalar(prhs[2]);
  
  move(motion_direction, speed, duration); 
  
}
