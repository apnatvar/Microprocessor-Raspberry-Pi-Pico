# Specify the name of the executable.
add_executable(lab10)

# Specify the source files to be compiled.
target_sources(lab10 PRIVATE lab10.c lab10.S)


# Generate the PIO header file from the PIO source file.
pico_generate_pio_header(lab10 ${CMAKE_CURRENT_LIST_DIR}/ws2812.pio)

# Pull in commonly used features.
target_link_libraries(lab10 PRIVATE pico_stdlib hardware_pio)

# Create map/bin/hex file etc.
pico_add_extra_outputs(lab10)

# Add the URL via pico_set_program_url.
apps_auto_set_url(lab10)
