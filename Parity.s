     1	@ Start of file Parity.s
     2	@
     3	@ Copyright 2020 University of Dublin. All Rights Reserved.
     4	@
     5	@ Design and write an assembly language program that 
     6	@ will calculate the parity bit for a 7 bit value stored in r0. 
     7	@ 
     8	@ The program should then store the computed parity bit 
     9	@ in bit 7 of r0. Assume even parity.
    10	@ 
    11	@ Using even parity, the parity bit of a value is set such that the 
    12	@ number of set bits (1's) in a value is always even.
    13	@ 
    14	
    15	
    16		.text
    17	
    18	start:
    19	
    20		LDR	r0, =0x16
    21	
    22	
    23	@ Upload the code that goes between the dashed lines.
    24	@ -------------- start cut ------------------------
    25	
    26	LDR R2, =0x1
    27	AND R1, R0, R9
    28	
    29	LDR R2, =0x2
    30	AND R3, R0, R2
    31	LSR R3, #1
    32	EOR R1, R1, R3
    33	
    34	LDR R2, =0x4
    35	AND R4, R0, R2
    36	LSR R4, #2
    37	EOR R1, R1, R4
    38	
    39	LDR R2, =0x8
    40	AND R5, R0, R2
    41	LSR R5, #3
    42	EOR R1, R1, R5
    43	
    44	LDR R2, =0x10
    45	AND R6, R0, R2
    46	LSR R6, #4
    47	EOR R1, R1, R6
    48	
    49	LDR R2, =0x20
    50	AND R7, R0, R2
    51	LSR R7, #5
    52	EOR R1, R1, R7
    53	
    54	LDR R2, =0x40
    55	AND R8, R0, R2
    56	LSR R8, #6
    57	EOR R1, R1, R8
    58	
    59	LSL R1, #7
    60	
    61	ORR R0, R0, R1
    62	
    63	@ -------------- end cut --------------------------
    64	
    65	stop:   B	stop
    66		.data
    67		.end
    68	@
    69	@ End of file Parity.s
