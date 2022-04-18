#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "pico/stdlib.h"
#include "pico/float.h"     // Required for using single-precision variables.
#include "pico/double.h"    // Required for using double-precision variables.
/**
 * @brief floatCalculations approximates the value of Pi using float data type
 * 
 * @param iter - takes the number of iteration as the input, default value here is 100000
 * @return float - the closest approximation of Pi
 */
float floatCalculations(int iter){
  int i = 2;
  float result = 1.0;
  while(iter--){
    result = result * i * i / (i-1) / (i+1);//wallis product
    i=i+2;
  }
  return result*2;
}
/**
 * @brief doubleCalculations approximates the value of Pi using double data type
 * 
 * @param iter  - takes the number of iterations as input, default value here is 100000
 * @return double - the closest approximation of Pi
 */
double doubleCalculations(int iter){
  int i = 2;
  double result = 1.0;
  while(iter--){
    result = result * i * i / (i-1) / (i+1);//wallis product
    i=i+2;
  }
  return result*2;
}
/**
 * @brief LAB #02 - TEMPLATE
 *        Main entry point for the code.
 * 
 * @return int      Returns exit-status zero on completion.
 */
int main() {
    stdio_init_all();
    int iterations = 100000; //recommended value
    float compareTo = 3.14159265359; //recommended value
    float floatResult = floatCalculations(iterations);
    double doubleResult = doubleCalculations(iterations);
    float floatError = abs(floatResult - compareTo) * 100 / compareTo;  //error calculation in %
    double doubleError = abs(doubleResult - compareTo) * 100 / compareTo; //error calculation in%
    printf("The result in float is %f and the error is %f%%\n",floatResult, floatError);
    printf("The result in double is %f and the error is %f%%\n",doubleResult, doubleError);
    // Returning zero indicates everything went okay.
    return 0;
}
