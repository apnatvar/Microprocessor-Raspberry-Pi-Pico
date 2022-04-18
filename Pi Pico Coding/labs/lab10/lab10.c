#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include "hardware/pio.h"
#include "hardware/clocks.h"
#include "hardware/watchdog.h"
#include "ws2812.pio.h"
#include "morse_code.h"
#include <string.h>
#define IS_RGBW true        // Will use RGBW format
#define NUM_PIXELS 1        // There is 1 WS2812 device in the chain
#define WS2812_PIN 28       // The GPIO pin that the WS2812 connected to
#define NUM_WORDS 2
// Declare the main assembly code entry point.
extern void main_asm();
void game_start();
void switch_level();
void word_challenge();
//                    SDK functions that are called from main_asm()
///////////////////////////////////////////////////////////////////////////////

//function called by assembly to get the current timestamp
uint32_t  asm_get_time(){
    return time_us_32();
}
// Initialise a GPIO pin â€“ see SDK for detail on gpio_init()
void asm_gpio_init(uint pin) {
    gpio_init(pin);
}
// Set direction of a GPIO pin â€“ see SDK for detail on gpio_set_dir()
void asm_gpio_set_dir(uint pin, bool out) {
    gpio_set_dir(pin, out);
}
// Get the value of a GPIO pin â€“ see SDK for detail on gpio_get()
bool asm_gpio_get(uint pin) {
    return gpio_get(pin);
}
// Set the value of a GPIO pin â€“ see SDK for detail on gpio_put()
void asm_gpio_put(uint pin, bool value) {
    gpio_put(pin, value);
}
// Enable falling-edge interrupt â€“ see SDK for detail on gpio_set_irq_enabled()
void asm_gpio_set_irq_fall(uint pin) {
    gpio_set_irq_enabled(pin, GPIO_IRQ_EDGE_FALL, true);
}
// Enable Rising-edge interrupt
void asm_gpio_set_irq_rise(uint pin){
    gpio_set_irq_enabled(pin, GPIO_IRQ_EDGE_RISE, true);
}

void asm_watchdog_reset(){              //to reset the watchdog timer
    watchdog_update();
}
//////////////////////////////////////////////////////////////////////////////////////////


//                          C WRAPPER FOR USING THE RGB LED

//////////////////////////////////////////////////////////////////////////////
/**
 * @brief Wrapper function used to call the underlying PIO
 *        function that pushes the 32-bit RGB colour value
 *        out to the LED serially using the PIO0 block. The
 *        function does not return until all of the data has
 *        been written out.
 * 
 * @param pixel_grb The 32-bit colour value generated by urgb_u32()
 */

static inline void put_pixel(uint32_t pixel_grb) {
    pio_sm_put_blocking(pio0, 0, pixel_grb << 8u);
}
/**
 * @brief Function to generate an unsigned 32-bit composit GRB
 *        value by combining the individual 8-bit paramaters for
 *        red, green and blue together in the right order.
 * 
 * @param r     The 8-bit intensity value for the red component
 * @param g     The 8-bit intensity value for the green component
 * @param b     The 8-bit intensity value for the blue component
 * @return uint32_t Returns the resulting composit 32-bit RGB value
 */
static inline uint32_t urgb_u32(uint8_t r, uint8_t g, uint8_t b) {
    return  ((uint32_t) (r) << 8)  |
            ((uint32_t) (g) << 16) |
            (uint32_t) (b);
}

void light_green()                                          // Function which Turns the RGB LED green
{
    put_pixel(urgb_u32(0x00, 0x7F, 0x00));                  //GREEN  When there are 3 lives are left
}
void light_blue()                                          // Function which Turns the RGB LED blue
{
    put_pixel(urgb_u32(0x00, 0x00, 0x7F));                  //BLUE   When game isnt in progress
}
void light_yellow()                                          // Function which Turns the RGB LED yellow
{
    put_pixel(urgb_u32(0x7F, 0x7F, 0x00));                  //YELLOW When there are 2 lives are left
}
void light_orange()                                          // Function which Turns the RGB LED orange
{
    put_pixel(urgb_u32(0x7F, 0x40, 0x00));                 //ORANGE When there is 1 life left
}
void light_red()                                           // Function which Turns the RGB LED red
{
   put_pixel(urgb_u32(0x7F, 0x00, 0x00));                  //RED    to denote game over
}

void light_off(){
   put_pixel(urgb_u32(0x00, 0x00, 0x00));                 //turn off the rgb
}

//Function for changing the light when the Lives change
void life_to_color(int a){
    if(a==3){
        light_green();
    }
    else if(a==2){
        light_yellow();
    }
    else if(a==1){
        light_orange();
    }
    else if(a==0){
        light_red();
    }
}
void lives_up() // no of lives go upto 3 and lights get updated--TO BE COMPLETED
{
}

void lives_down(){  // no of lives go down till 0 and lights get updated-- TO BE COMPLETED

}
///////////////////////////////////////////////////////////////////////////////

//                              C code to get the data from assembly
////////////////////////////////////////////////////////////////////////////////////
int lives=3;                        //The number of lives 
int tries=0;                        //The number of successive correct answers
char input[20];
int ind = 0;

void add_input(int sample){
        if (sample == 0){
            input[ind] = '.';
            ind++;
        }
        else if (sample == 1){
            input[ind] = '_';
            ind++;
        }
        else if (sample == 2){
            input[ind] = 'S';
            ind++;
        }
        else if (sample == 3){
            input[ind] = '\0';
            ind++;
        }
    printf("%s\n",input);
}
void clear(int i){
    ind=i;
}

/**
 * @brief compare each location of two charachter arrays
 * until the '\0' charachter is reached
 * 
 * @param arr_1 
 * @param arr_2 
 * @return int: 1 if values are equel, 0 otherwise 
 */
int char_cmp(char* arr_1, char* arr_2){
  char c_1, c_2;
  for (int i = 0; i < 5; i++){
    c_1 = arr_1[i];
    c_2 = arr_2[i];
    if (c_1 != c_2) return 0;
    if (c_1 == '\0') return 1;
  }
  return 0;
};

/**
 * @brief Handler code for level 1 and 2, prints expected user input and calls main_asm() to take it.
 * checks if the user input returned by main_asm() is correct
 * 
 * @param print_morse 1 if morse code is to be printed (level 1), 0 if morse code is not to be printed (level 2)
 */

/*
* @brief A Function to decode the input pattern to an applicable alphanumeric letter,
* If it isnt an applicable pattern, then it decodes to ?
*/
void decode_letter(){
    int j;
    int flag=-1;
    for(j=0;j<36;j++){
        if((strcmp(letter_table[j],input))==0){
            if(j>9){
                printf("\nDECODED TO : %c\n",((j-10) + 'A'));
            }
            else{
                printf("\nDECODED TO : %c\n",(j +'0'));
            }
            flag++;
        }
    }
    if(flag<0){
        printf("\nDECODED TO : ?\n");
    }
}

void charachter_challenge(int print_morse){
    //decide on and print expected letter
    printf("\nCHALLENGE STARTED\n");
    int l = rand()% 36;                     // Generate random number between 0 and 25 tto represent number in the alphabet
    if(l>9){
    printf("Input: %c\n",((l-10) + 'A'));        // print the letter in the alphabet represented by the number
    }
    else{
    printf("Input: %c\n",(l + '0'));        // print the letter in the alphabet represented by the number
    }
    if (print_morse){
        printf("Expected Morse: ");
        for(int i = 0; i < 5; i++){
            if (letter_table[l][i] == '\0') break;
            printf("%c", letter_table[l][i]);
        }
    }  

    main_asm();                            //Writes the DOTS, DASHES SPACES and /0 into the array
    decode_letter();
    if(char_cmp(input, letter_table[l]))
    {
    printf("Success"); 
    if(lives<3){                          
            lives++;                      //If lives are less than 3, then it gives a life up
            life_to_color(lives);
            tries++;                      //The number of consecutive correct answers go up
        }

    else{
            tries++;                     //The number of consecutive correct answers go up
        }
    
    //If the number of times that the correct pattern is input is less than 5
    if(tries<5){
        charachter_challenge(print_morse);
    }
    //If the number of times that the correct pattern is input is 5
    if(tries==5){
        if(print_morse==1){
        charachter_challenge(0);          
            }

        else if(print_morse==0){
            word_challenge(1);
            }
        }
    }
    else
    {
        printf("Failed\n");                            
        tries=0;                                     //The number of consecutive correct answers go to 0 when a pattern is wrong
        if(lives>0){
           lives--; 
           life_to_color(lives);
        }
        if(lives==0){
            printf("GAME OVER");
            life_to_color(lives);
        }
    }
}

void word_challenge(int show_morse){
  int l = rand()% NUM_WORDS;            // Generate random number between 0 and 2 to represent word from list

  // print the expected word
  printf("Input: ");
  for(int i = 0; i<5; i++){
    if (word_table[l][i] == '\0') break;
    printf("%c", word_table[l][i]); 
  }

  printf("\n");
  // If on level 3, print out the required morse code
  if(show_morse){
    for(int i = 0; i<5; i++){
      if (word_table[l][i] == '\0') break;
      int c = word_table[l][i] - 'A';
      for(int j = 0; j < 5; j++){
        if (letter_table[c][j] == '\0') break;
        printf("%c", letter_table[c][j]); 
      }
      printf("S");
    }
  }
}


//////////////////////////////////////////////////////////////////
//                              Gameplay Part
char lvl1[4]={'.','\0'};
char lvl2[4]={'.','.','\0'};
char lvl3[4]={'.','.','.','\0'};
char lvl4[5]={'.','.','.','.','\0'};

void level1(){       //Function for Level-1(Match Characters with right sequence given)
lives=3;             //Reset the the lives to 3 for the stat of a new level
tries=0;             //Reset the the correct consecutive sequence  to 0 for the stat of a new level
charachter_challenge(1);
}
void level2(){       //Function for Level-2(Match Characters without the right sequence given)
lives=3;             //Reset the the lives to 3 for the stat of a new level
tries=0;             //Reset the the correct consecutive sequence  to 0 for the stat of a new level
charachter_challenge(0);
}
void level3(){       //Function for Level-3(Match Words with right sequence given)
lives=3;             //Reset the the lives to 3 for the stat of a new level
tries=0;             //Reset the the correct consecutive sequence  to 0 for the stat of a new level
word_challenge(1);
}
void level4(){      //Function for Level-4(Match Words without the right sequence given)
lives=3;             //Reset the the lives to 3 for the stat of a new level
tries=0;             //Reset the the correct consecutive sequence  to 0 for the stat of a new level
word_challenge(0);
}

void switch_level(int num){     // Switch case for choosing the level
    switch(num){
        case 1: light_green();
                level1();
                break;
        case 2: light_green();
                level2();
                break;
        case 3: light_green();
                level3();
                break;
        case 4: light_green();
                level4();
                break;
        default:printf("------------------Invalid input for the level------------------\n Try Again\n");
                game_start();
                break;
    }
}



void welcome(){     //Printing out the welcome message
light_blue();
printf("-------------------------------------------------\n");
printf("--                MORSE CODE GAME              --\n");
printf("--       USE GP-21 T0 INPUT THE SEQUENCE       --\n");
printf("--                 Level-1:'.'                 --\n");
printf("--                 Level-2:'..'                --\n");
printf("--                 Level-3:'...'               --\n");
printf("--                 Level-4:'....'              --\n");
printf("-------------------------------------------------\n");
printf("\nINPUT THE LEVEL:\n");
main_asm();
}

void game_start(){
    //light_blue();
    //welcome();
    printf("ENTER THE MORSE CODE OF THE LEVEL YOU WANT:\n");
    //watchdog_enable(8000000,1);                 //Enable the watchdog timer
    /*
    main_asm();                                 //Jump into the ASM code to get the level
    printf("\n%s\n",input);
  //  int cmp=strcmp(input,lvl1);
  */
    //switch_level(1);                              // function to choose the level
    //main_asm();
    level1();
}

// Main entry point of the application
int main() {
    stdio_init_all();                           // Initialise all basic IO
    // Initialise the PIO interface with the WS2812 code
    PIO pio = pio0;
    uint offset = pio_add_program(pio, &ws2812_program);
    ws2812_program_init(pio, 0, offset, WS2812_PIN, 800000, IS_RGBW);
    // initialize srand for pseudo-random intiger generation
    //welcome();
    //charachter_challenge(1);
    main_asm();
    game_start();
    return 0;                                   //Application return code
}
