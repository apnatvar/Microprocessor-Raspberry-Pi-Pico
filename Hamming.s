     1	@ Start of file Hamming.s
     2	@
     3	@ Copyright 2020 University of Dublin. All Rights Reserved.
     4	@
     5	@ Design and write an assembly language program that 
     6	@ generates a 12-bit Hamming Code in R0 from an 8-bit value in R1.
     7	@ 
     8	
     9	
    10		.text
    11	
    12	start:
    13	
    14		LDR	r1, =0xAC
    15	
    16	
    17	@ Upload the code that goes between the dashed lines.
    18	@ -------------- start cut ------------------------
    19	
    20	LDR r2, =0x1
    21	AND r2,r1,r2
    22	LDR r3, =0x2
    23	AND r3,r1,r3
    24	MOV r3,r3,LSR #1
    25	LDR r4, =0x4
    26	AND r4,r1,r4
    27	MOV r4,r4,LSR #2
    28	LDR r5, =0x8
    29	AND r5,r1,r5
    30	MOV r5,r5,LSR #3
    31	LDR r6, =0x10
    32	AND r6,r1,r6
    33	MOV r6,r6,LSR #4
    34	LDR r7, =0x20
    35	AND r7,r1,r7
    36	MOV r7,r7,LSR #5
    37	LDR r8, =0x40
    38	AND r8,r1,r8
    39	MOV r8,r8,LSR #6
    40	LDR r9, =0x80
    41	AND r9,r1,r9
    42	MOV r9,r9,LSR #7
    43	EOR r2,r2,r3
    44	EOR r5,r5,r6
    45	EOR r2,r2,r5
    46	EOR r13,r2,r8
    47	LDR r2, =0x1
    48	AND r2,r1,r2
    49	LDR r5, =0x8
    50	AND r5,r1,r5
    51	MOV r5,r5,LSR #3
    52	EOR r2,r2,r4
    53	EOR r5,r5,r7
    54	EOR r2,r2,r5
    55	EOR r10,r2,r8
    56	LDR r2, =0x1
    57	AND r2,r1,r2
    58	LDR r5, =0x8
    59	AND r5,r1,r5
    60	MOV r5,r5,LSR #3
    61	EOR r3,r3,r4
    62	EOR r5,r5,r9
    63	EOR r11,r3,r5
    64	LDR r3, =0x2
    65	AND r3,r1,r3
    66	MOV r3,r3,LSR #1
    67	LDR r5, =0x8
    68	AND r5,r1,r5
    69	MOV r5,r5,LSR #3
    70	EOR r6,r6,r7
    71	EOR r8,r8,r9
    72	EOR r12,r6,r8
    73	LDR r6, =0x10
    74	AND r6,r1,r6
    75	MOV r6,r6,LSR #4
    76	LDR r8, =0x40
    77	AND r8,r1,r8
    78	MOV r8,r8,LSR #6
    79	MOV r10,r10,LSL #1
    80	MOV r11,r11,LSL #3
    81	MOV r12,r12,LSL #7
    82	MOV r2,r2,LSL #2
    83	MOV r3,r3,LSL #4
    84	MOV r4,r4,LSL #5
    85	MOV r5,r5,LSL #6
    86	MOV r6,r6,LSL #8
    87	MOV r7,r7,LSL #9
    88	MOV r8,r8,LSL #10
    89	MOV r9,r9,LSL #11
    90	ORR r1,r13,r10
    91	ORR r1,r1,r2
    92	ORR r1,r1,r11
    93	ORR r1,r1,r3
    94	ORR r1,r1,r4
    95	ORR r1,r1,r5
    96	ORR r1,r1,r12
    97	ORR r1,r1,r6
    98	ORR r1,r1,r7
    99	ORR r1,r1,r8
   100	ORR r1,r1,r9
   101	MOV r0, r1
   102	
   103	@ -------------- end cut --------------------------
   104	
   105	stop:   B	stop
   106		.data
   107		.end
   108	@
   109	@ End of file Hamming.s
