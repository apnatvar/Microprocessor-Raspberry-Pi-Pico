    1	@ Start of file Hamming2.s
     2	@
     3	@ Copyright 2020 University of Dublin. All Rights Reserved.
     4	@
     5	@ Design and write an assembly language program that will detect and correct single 
     6	@ bit errors in a 12-bit Hamming Code in R0. Your program should begin by clearing 
     7	@ and then re-calculating the check bits using the same assembly language program 
     8	@ that was used to generate the original Hamming Code. Your program should then 
     9	@ compare the original and re-calculated values and should finally correct any 
    10	@ single bit error and store the correct 8 bit number in R0.
    11	@ 
    12	
    13	
    14		.text
    15	
    16	start:
    17	
    18		LDR	r0, =0xb6b
    19	
    20	
    21	@ Upload the code that goes between the dashed lines.
    22	@ -------------- start cut ------------------------
    23	
    24	ldr r1, =0x1
    25	and r1,r1,r0
    26	ldr r2, =0x2
    27	and r2,r2,r0
    28	mov r2,r2,lsr #1
    29	ldr r3, =0x4
    30	and r3,r3,r0
    31	mov r3,r3,lsr #2
    32	ldr r4, =0x8
    33	and r4,r4,r0
    34	mov r4,r4,lsr #3
    35	ldr r5, =0x10
    36	and r5,r5,r0
    37	mov r5,r5,lsr #4
    38	ldr r6, =0x20
    39	and r6,r6,r0
    40	mov r6,r6,lsr #5
    41	ldr r7, =0x40
    42	and r7,r7,r0
    43	mov r7,r7,lsr #6
    44	ldr r8, =0x80
    45	and r8,r8,r0
    46	mov r8,r8,lsr #7
    47	ldr r9, =0x100
    48	and r9,r9,r0
    49	mov r9,r9,lsr #8
    50	ldr r10, =0x200
    51	and r10,r10,r0
    52	mov r10,r10,lsr #9
    53	ldr r11, =0x400
    54	and r11,r11,r0
    55	mov r11,r11,lsr #10
    56	ldr r12, =0x800
    57	and r12,r12,r0
    58	mov r12,r12,lsr #11	
    59	
    60	mov r13,r5 
    61	mov r5,r3
    62	mov r3,r4 
    63	mov r4,r8 
    64	mov r8,r7
    65	mov r7,r6
    66	mov r6,r13
    67	
    68	eor r13,r5,r6
    69	eor r14,r8,r9
    70	eor r5,r13,r14
    71	eor r13,r5,r11
    72	ldr r5, =0x4
    73	and r5,r5,r0
    74	mov r5,r5,lsr #2
    75	eor r5,r5,r7
    76	eor r14,r8,r10
    77	eor r5,r5,r14
    78	eor r5,r5,r11
    79	mov r14,r5 
    80	mov r5,r13 
    81	eor r6,r6,r7
    82	eor r13,r8,r12
    83	eor r7,r6,r13 
    84	mov r6,r14 	
    85	
    86	eor r8,r9,r10
    87	eor r11,r11,r12
    88	eor r8,r8,r11 	
    89	
    90	eor r9,r1,r5
    91	eor r10,r2,r6
    92	eor r11,r3,r7
    93	eor r12,r4,r8
    94	mov r10,r10, lsl #1
    95	mov r11,r11, lsl #2
    96	mov r12,r12, lsl #3
    97	orr r9,r9,r10
    98	orr r9,r9,r11
    99	orr r9,r9,r12
   100	sub r9,r9,#0x1
   101	mov r10,#0x1
   102	lsl r10,r9	
   103	eor r0,r0,r10	
   104	
   105	ldr r1, =0x1
   106	and r1,r1,r0
   107	ldr r2, =0x2
   108	and r2,r2,r0
   109	mov r2,r2,lsr #1
   110	ldr r3, =0x4
   111	and r3,r3,r0
   112	mov r3,r3,lsr #2
   113	ldr r4, =0x8
   114	and r4,r4,r0
   115	mov r4,r4,lsr #3
   116	ldr r5, =0x10
   117	and r5,r5,r0
   118	mov r5,r5,lsr #4
   119	ldr r6, =0x20
   120	and r6,r6,r0
   121	mov r6,r6,lsr #5
   122	ldr r7, =0x40
   123	and r7,r7,r0
   124	mov r7,r7,lsr #6
   125	ldr r8, =0x80
   126	and r8,r8,r0
   127	mov r8,r8,lsr #7
   128	ldr r9, =0x100
   129	and r9,r9,r0
   130	mov r9,r9,lsr #8
   131	ldr r10, =0x200
   132	and r10,r10,r0
   133	mov r10,r10,lsr #9
   134	ldr r11, =0x400
   135	and r11,r11,r0
   136	mov r11,r11,lsr #10
   137	ldr r12, =0x800
   138	and r12,r12,r0
   139	mov r12,r12,lsr #11	
   140	
   141	mov r5,r5,lsl #1
   142	mov r6,r6,lsl #2
   143	mov r7,r7,lsl #3
   144	mov r9,r9,lsl #4
   145	mov r10,r10,lsl #5
   146	mov r11,r11,lsl #6
   147	mov r12,r12,lsl #7	
   148	orr r5,r5,r6
   149	orr r5,r5,r7
   150	orr r5,r5,r8
   151	orr r5,r5,r9
   152	orr r5,r5,r10
   153	orr r5,r5,r11
   154	orr r5,r5,r12
   155	mov r0,r5
   156	
   157	@ -------------- end cut --------------------------
   158	
   159	stop:   B	stop
   160		.data
   161		.end
   162	@
   163	@ End of file Hamming2.s
