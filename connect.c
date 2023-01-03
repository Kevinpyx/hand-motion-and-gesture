#include "stdio.h"
#include "stdlib.h"
#include "mex.h"
#include "MyroC.h" 

// A function that will connect the robot
// Preconditions: None, (Bluetooth is on so the robot can connect)
// Postconditions: None (connect the robot to the bluetooth)
void connect(){
   rConnect("/dev/rfcomm0");
   printf("Connected!\n"); 
}

//This is a MATLAB wrapper function for the connect command
// Will allow for MATLAB to connect to the robot
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, 
                 const mxArray *prhs[]){
  printf("Attempting to connect\n"); 
  connect(); 
  //connect(); 
}
