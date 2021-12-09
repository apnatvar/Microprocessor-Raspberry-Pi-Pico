    1	@ Start of file ValToHex.s
     2	@
     3	@ Copyright 2020 University of Dublin. All Rights Reserved.
     4	@
     5	@ Design and write an ARM assembly language program to 
     6	@ convert a 32 bit unsigned value stored in r1
     7	@ to it's hexadecimal ASCII string representation.
     8	@ Store the resulting string beginning at address 
     9	@ 0xA1000400. Your answer should contain 8 characters
    10	@ including leading zeros where appropriate, and
    11	@ should use uppercase 'A'-'F'.
    12	
    13	
    14		.text
    15	
    16	start:
    17	
    18		LDR	r1, =0xFEED1234
    19	
    20	@ Upload the code that goes between the dashed lines.
    21	@ -------------- start cut ------------------------
    22	
    23	LDR		r0, =0xA1000400
    24	MOV		r2, #0xF0000000
    25	MOV r10,#0
    26	MOV r4,#28
    27	loop:
    28	CMP		r10, #8
    29	BEQ		end
    30	ADD r10,r10,#1
    31	AND		r3,r1,r2
    32	LSR		r3,r4
    33	CMP		r3, #9
    34	ADDGT		r3,r3, #0x7
    35	ADD		r3,r3, #0x30
    36	STRB		r3,[r0],#1
    37	LSR		r2,#4
    38	SUB r4, r4, #4
    39	B			loop
    40	
    41	end:
    42	
    43	@ -------------- end cut --------------------------
    44	
    45	stop:   B	stop
    46		.data
    47		.end
    48	@
    49	@ End of file ValToHex.s
