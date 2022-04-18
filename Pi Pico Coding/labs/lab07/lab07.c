#include "stdio.h"
#include "math.h"
#include "pico/stdlib.h"
#include "pico/float.h"     // Required for using single-precision variables.
#include "pico/double.h"    // Required for using double-precision variables.
#include "pico/multicore.h" // Required for using multiple cores on the RP2040.
#include "hardware/dma.h"
#include "hardware/regs/addressmap.h"
#include "hardware/structs/xip_ctrl.h"

// Must declare the main assembly entry point before use.
void main_asm();
/**
 * @brief Get the XIP cache enable status by comparing the current value
 *          int ctrl with the expected value of ctrl when it is enabled
 * 
 * @return true if the XIP cache is enabled
 * @return false if the XIP Cache is disabled
 */
bool get_xip_cache_en(){
    if (xip_ctrl_hw->ctrl == XIP_CTRL_EN_BITS)return true; // Compare the current value to the default value when cache is enabled
    else return false;
}
/**
 * @brief Set the XIP Cache ON or OFF
 * 
 * @param cache_en if "True" set XIP Cache to ON else set to OFF
 * @return true to confirm User selected true
 * @return false to confirm User selected false
 */
bool set_xip_cache_en(bool cache_en){
    if (cache_en)xip_ctrl_hw->ctrl |= XIP_CTRL_EN_BITS; // Switch Cache ON 
    else xip_ctrl_hw->ctrl &= ~XIP_CTRL_EN_BITS; // Switch Cache OFF
    return cache_en; // Return the Value User requested
}
/**
 * @brief floatCalculations prints the approximates value of Pi using float data type
 * 
 * @param iter - takes the number of iteration as the input, default value here is 100000
 * @return int32_t - the time spent on running this function
 */
int32_t floatCalculations(int32_t iter){
  absolute_time_t startTimeFloat = get_absolute_time();     //    Take snapshot of timer and store
  int i = 2;
  float_t result = 1.0000;
  while(iter--){
    result = result * i * i / (i-1) / (i+1); // wallis product
    i=i+2;
  }
  result = result*2;
  printf("The Wallis Approximation in Float is %f\n",result);
  return absolute_time_diff_us(startTimeFloat, get_absolute_time());
}

/**
 * @brief doubleCalculations prints the approximate value of Pi using double data type
 * 
 * @param iter  - takes the number of iterations as input, default value here is 100000
 * @return int32_t - the time spent on running this function
 */
int32_t doubleCalculations(int32_t iter){
  absolute_time_t startTimeDouble = get_absolute_time();     //    Take snapshot of timer and store
  int i = 2;
  double_t result = 1.000000000000;
  while(iter--){
    result = result * i * i / (i-1) / (i+1); // wallis product
    i=i+2;
  }
  result = result*2;
  printf("The Wallis Approximation in Double is %lf\n",result);
  return absolute_time_diff_us(startTimeDouble, get_absolute_time());
}

/**
 * @brief This function acts as the main entry-point for core #1.
 *        A function pointer is passed in via the FIFO with one
 *        incoming int32_t used as a parameter. The function will
 *        provide an int32_t return value by pushing it back on 
 *        the FIFO, which also indicates that the result is ready.
 */
void core1_entry() {
    while (1) {
        // 
        int32_t (*func)() = (int32_t(*)()) multicore_fifo_pop_blocking();
        int32_t p = multicore_fifo_pop_blocking();
        int32_t result = (*func)(p);
        multicore_fifo_push_blocking(result);
    }
}

/**
 * @brief LAB #07 - TEMPLATE
 *        Main entry point for the code 
 *        Function to run the requested runs with 
 *        relevant constraint parameters
 * 
 * @return int      Returns exit-status zero on completion.
 */
int main() {

    const int32_t    ITER_MAX   = 100000; //number of iterations expected to perform
    stdio_init_all(); //initialising output from Pi so we can view it on PuTTy
    absolute_time_t startTime; // variables to record beginning og timing functions
    int32_t singleCoreTime, dualCoreTime, floatSingleTime, floatDoubleTime, doubleSingleTime, doubleDoubleTime; // variables to store timing data as required for the lab
    
    multicore_launch_core1(core1_entry); // Core 1 tasks function

    // Code with XIP Cache Disabled
    set_xip_cache_en(false);
    if (get_xip_cache_en())printf("Results with XIP Cache Enabled\n");
    else printf("Results with XIP Cache Disabled\n");
    // Code for XIP Cache Disabled sequential run goes here…
    // For single core run, both of the functions are run on Core 1
    startTime = get_absolute_time();     //    Take snapshot of timer and store
    printf("Results from Sequential Run\n");
    multicore_fifo_push_blocking((uintptr_t) &floatCalculations);    //    Passing the function to run on Core 1
    multicore_fifo_push_blocking(ITER_MAX);    //    Passing the variable to the function
    floatSingleTime = multicore_fifo_pop_blocking();    //    Run the single-precision Wallis approximation
    multicore_fifo_push_blocking((uintptr_t) &doubleCalculations);    //    Passing the function to run on Core 1
    multicore_fifo_push_blocking(ITER_MAX);    //    Passing the variable to the function
    doubleSingleTime = multicore_fifo_pop_blocking();    //    Run the double-precision Wallis approximation
    singleCoreTime = absolute_time_diff_us(startTime, get_absolute_time());    //    Take snapshot of timer difference and store
    printf("Time for taken for float calculations: %d\nTime taken for double calculations: %d\n", floatSingleTime, doubleSingleTime);    //    Display time taken for individual calculations to run in sequential mode
    printf("Total Time: %d\n",singleCoreTime);    //    Display time taken for application to run in sequential mode

    // Code for XIP Cache Disabled parallel run goes here…
    printf("\nResults from Parallel Run\n");
    startTime = get_absolute_time();     //    Take snapshot of timer and store
    multicore_fifo_push_blocking((uintptr_t) &floatCalculations);    //    Passing the function to run on Core 1
    multicore_fifo_push_blocking(ITER_MAX);    //    Passing the variable to the function
    doubleDoubleTime = doubleCalculations(ITER_MAX);    //    Run the double-precision Wallis approximation on one core
    floatDoubleTime = multicore_fifo_pop_blocking();    //    Run the single-precision Wallis approximation on the other core
    dualCoreTime = absolute_time_diff_us(startTime, get_absolute_time());    //    Take snapshot of timer difference and store
    printf("Time for taken for float calculations: %d\nTime taken for double calculations: %d\n", floatDoubleTime, doubleDoubleTime);    //    Display time taken for individual calculations to run in parallel mode
    printf("Total Time: %d\n",dualCoreTime);    //    Display time taken for application to run in parallel mode

    // Code with XIP Cache Enabled
    set_xip_cache_en(true);
    if (get_xip_cache_en())printf("\n\nResults with XIP Cache Enabled\n");
    else printf("Results with XIP Cache Disabled\n");
    // Code for XIP Cache Enabled sequential run goes here…
    // For single core run, both of the functions are run on Core 1
    startTime = get_absolute_time();     //    Take snapshot of timer and store
    printf("Results from Sequential Run\n");
    multicore_fifo_push_blocking((uintptr_t) &floatCalculations);    //    Passing the function to run on Core 1
    multicore_fifo_push_blocking(ITER_MAX);    //    Passing the variable to the function
    floatSingleTime = multicore_fifo_pop_blocking();    //    Run the single-precision Wallis approximation
    multicore_fifo_push_blocking((uintptr_t) &doubleCalculations);    //    Passing the function to run on Core 1
    multicore_fifo_push_blocking(ITER_MAX);    //    Passing the variable to the function
    doubleSingleTime = multicore_fifo_pop_blocking();    //    Run the double-precision Wallis approximation
    singleCoreTime = absolute_time_diff_us(startTime, get_absolute_time());    //    Take snapshot of timer difference and store
    printf("Time for taken for float calculations: %d\nTime taken for double calculations: %d\n", floatSingleTime, doubleSingleTime);    //    Display time taken for individual calculations to run in sequential mode
    printf("Total Time: %d\n",singleCoreTime);    //    Display time taken for application to run in sequential mode

    // Code for XIP Cache Enabled parallel run goes here…
    printf("\nResults from Parallel Run\n");
    startTime = get_absolute_time();     //    Take snapshot of timer and store
    multicore_fifo_push_blocking((uintptr_t) &floatCalculations);    //    Passing the function to run on Core 1
    multicore_fifo_push_blocking(ITER_MAX);    //    Passing the variable to the function
    doubleDoubleTime = doubleCalculations(ITER_MAX);    //    Run the double-precision Wallis approximation on one core
    floatDoubleTime = multicore_fifo_pop_blocking();    //    Run the single-precision Wallis approximation on the other core
    dualCoreTime = absolute_time_diff_us(startTime, get_absolute_time());    //    Take snapshot of timer difference and store
    printf("Time for taken for float calculations: %d\nTime taken for double calculations: %d\n", floatDoubleTime, doubleDoubleTime);    //    Display time taken for individual calculations to run in parallel mode
    printf("Total Time: %d\n",dualCoreTime);    //    Display time taken for application to run in parallel mode

    // Returning zero indicates everything went okay.
    return 0;
}
