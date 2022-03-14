    1	@ Start of file Arithmetic1.s
     2	@
     3	@ Copyright 2020 University of Dublin. All Rights Reserved.
     4	@
     5	@ Write an arm program to evaluate 4 * x * x + 3 * x
     6	@ assume x is in r1 and store result in r0
     7	@ 
     8	
     9	
    10		.text
    11	
    12	start:
    13	
    14	        MOV     r1, #0x8 
    15	
    16	
    17	@ Upload the code that goes between the dashed lines.
    18	@ -------------- start cut ------------------------
    19	
    20	MUL	r2, r1, r1
    21	MOV	r3, #0x4
    22	MUL	r4, r2, r3
    23	MOV	r5, #0x3
    24	MUL	r6, r1, r5
    25	ADD		r0, r4, r6
    26	
    27	@ -------------- end cut --------------------------
    28	
    29	stop:   B	stop
    30		.data
    31		.end
    32	@
    33	@ End of file Arithmetic1.s
