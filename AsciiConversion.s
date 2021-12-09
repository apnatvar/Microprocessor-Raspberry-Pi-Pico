     1	@ Start of file AsciiConversion.s
     2	@
     3	@ Copyright 2020 University of Dublin. All Rights Reserved.
     4	@
     5	@ A sequence of seven ASCII symbols, each in the range '0' . . . '9', can 
     6	@ represent an unsigned value in the range 0 . . . 9,999,999 in text form. 
     7	@ 
     8	@ Design and write an ARM assembly language program that will convert such 
     9	@ a sequence to the value represented by the symbols. 
    10	@ 
    11	@ Assume that the seven byte-size ASCII symbols will be stored in R1 to R7, 
    12	@ with the most significant digit stored in R7. 
    13	@ 
    14	@ Store the result of the conversion in R0.
    15	@ 
    16	@ For example, given the following sequence of ASCII symbols
    17	@         '1', '0', '3', '4', '2', '7', '9'
    18	@ your program should store the value 1,034,279 (0x000FC827) in R0.
    19	@ 
    20	
    21	
    22		.text
    23	
    24	start:
    25	
    26		LDR	R7, ='1'
    27		LDR	R6, ='0'
    28		LDR	R5, ='3'
    29		LDR	R4, ='4'
    30		LDR	R3, ='2'
    31		LDR	R2, ='7'
    32		LDR	R1, ='9'
    33	
    34	
    35	@ Upload the code that goes between the dashed lines.
    36	@ -------------- start cut ------------------------
    37	
    38	LDR R8, =1
    39	LDR R9, = 10
    40	SUB R7, R7, R6
    41	SUB R5, R5, R6
    42	SUB R4, R4, R6
    43	SUB R3, R3, R6
    44	SUB R2, R2, R6
    45	SUB R1, R1, R6
    46	SUB R6, R6, R6
    47	
    48	LDR R0, =0
    49	
    50	MUL R10, R1, R8
    51	MUL R8, R9
    52	ADD R0, R0, R10
    53	
    54	MUL R10, R2, R8
    55	MUL R8, R9
    56	ADD R0, R0, R10
    57	
    58	MUL R10, R3, R8
    59	MUL R8, R9
    60	ADD R0, R0, R10
    61	
    62	MUL R10, R4, R8
    63	MUL R8, R9
    64	ADD R0, R0, R10
    65	
    66	MUL R10, R5, R8
    67	MUL R8, R9
    68	ADD R0, R0, R10
    69	
    70	MUL R10, R6, R8
    71	MUL R8, R9
    72	ADD R0, R0, R10
    73	
    74	MUL R10, R7, R8
    75	MUL R8, R9
    76	ADD R0, R0, R10
    77	
    78	
    79	@ -------------- end cut --------------------------
    80	
    81	stop:   B	stop
    82		.data
    83		.end
    84	@
    85	@ End of file AsciiConversion.s
