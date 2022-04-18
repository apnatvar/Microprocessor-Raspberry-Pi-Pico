/**
 * @brief LAB #01 - TEMPLATE
 *        Main entry point for the code.
 * 
 * @return int      Returns exit-status zero on completion.
 
int main() {

    // Returning zero indicates everything went okay.
    return 0;
}*/
/*void setup() {
  // put your setup code here, to run once:
  Serial1.begin(115200);
  Serial1.println("Hello, Raspberry Pi Pico!");
}

void loop() {
  // put your main code here, to run repeatedly:
  delay(1); // this speeds up the simulation
}*/
#include "pico/stdlib.h"

/**
 * @brief EXAMPLE - BLINK_C
 *        Simple example to initialise the built-in LED on
 *        the Raspberry Pi Pico and then flash it forever. 
 * 
 * @return int  Application return code (zero for success).
 */

void whileFunction(uint Pin,uint Delay){
    gpio_put(Pin,1);
    sleep_ms(Delay);
    gpio_put(Pin,0);
    sleep_ms(Delay);
    whileFunction(Pin,Delay);
}
int main() {

    // Specify the PIN number and sleep delay
    const uint LED_PIN   =  25;
    const uint LED_DELAY = 500;

    // Setup the LED pin as an output.
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);
    whileFunction(LED_PIN, LED_DELAY);
    // Do forever...
    /*while (true) {

        // Toggle the LED on and then sleep for delay period
        gpio_put(LED_PIN, 1);
        sleep_ms(LED_DELAY);

        // Toggle the LED off and then sleep for delay period
        gpio_put(LED_PIN, 0);
        sleep_ms(LED_DELAY);

    }

    // Should never get here due to infinite while-loop.*/
    return 0;

}


