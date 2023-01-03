#include "stdio.h"
#include "stdlib.h"
#include "mex.h"
#include "MyroC.h" 

// A function that will disconnect the robot
// Preconditions: None (other than the robot has been connected
// Postconditions: None (Will disconnect the robot from the bluetooth)
void disconnect(){
   rBeep(.5, 1400);
   rBeep(.5, 1200); 
   rBeep(.5, 1400);
   rBeep(.5, 1100);
   rDisconnect();
   printf("Disconnected!\n"); 
}

// This will be a wrapper function for our rDisconnect
// It will allow for MATLAB to disconnect the robot 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, 
                 const mxArray *prhs[]){
  printf("Attempting to disconnect\n"); 
  disconnect(); 
}
