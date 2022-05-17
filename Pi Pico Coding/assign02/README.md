# Morse Code
This README includes information about
- Official Documentation to help you get started on setting up the environment
- Documentation of the code for an overview of all the functions.
- How to play the game

## Raspberry Pi Pico Official Documentation
- https://datasheets.raspberrypi.com/pico/pico-datasheet.pdf The link to the official datasheet that should tell you about how to set up the environment.

## Documentation [Documentation.pdf](https://github.com/apnatvar/Microprocessor-Raspberry-Pi-Pico/files/8706040/Documentation.pdf)
- C code
This is the main code that performs most of the functionality for the game. It involves matching the input, leveling up, exiting/restarting, driving the LEDs and more
- ARM code
This is call
ed by the c code, to use the interrupt handler in the Pi Pico to receive dot, dash and space from the user. This is then passed to the C code where it performs string matching.
- PIO
This is the file that is used by the C code to manipulate thr RGB LED present on the Pi Pico and set the relevant light

## How to play
Assuming you have set up the environment to execute the code (not an easy task) correctly, you can proceed with the game.
- Enter a Dot
Quickly press and release the GPIO21 button
- Enter a Dash
Press and pause for < 1sec before releasing the GPIO21 button
- Enter a Space
Do not press any button for 1 sec.

The instruction on the screen are simple, enter the options as displayed to choose that option. You will have to very quick with it, incorrect selections will ead to the program exiting. Because of the watchdog timer it will automatically restart after 8.3 seconds so you might have to wait before the game resets. 
The easier levels will have the Morse Code displayed with it, so you have to replicate the code as best as possible.
For the harder levels the morse code has to be memorised and applied correctly.
After each try, the program will display your statistics and tell you how well have you done overall for the current level.
