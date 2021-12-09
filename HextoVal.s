     1	@ Start of file HexToVal.s
     2	@
     3	@ Copyright 2020 University of Dublin. All Rights Reserved.
     4	@
     5	@ Design and write an ARM assembly language program that
     6	@ will convert an ASCII representation of a hexadecimal
     7	@ value to a value. TestStr is a NULL-terminated string 
     8	@ in memory and the converted value should be stored in 
     9	@ register r0. TestStr will contain a maximum of 8
    10	@ characters and may use both upper and lower case
    11	@ charaters.
    12	
    13	
    14		.text
    15	
    16	start:
    17	
    18	@ Upload the code that goes between the dashed lines.
    19	@ -------------- start cut ------------------------
    20	
    21		MOV		r0,#0
    22		LDR		r1, =TestStr
    23		MOV		r3,#0
    24		
    25	loop:
    26		LDRB		r2, [r1], #1
    27		CMP		r2, #0
    28		BEQ		end
    29		
    30		MOV		r0, r0, LSL #4
    31		
    32		SUB		r2, r2, #0x30
    33		
    34		CMP 		r2, #9
    35		SUBGT		r2, r2, #0x7
    36		
    37		CMP		r2, #15
    38		SUBGT		r2, r2, #0x20
    39		
    40		ORR		r0,r0,r2
    41		B			loop
    42		
    43	end:
    44	 
    45	
    46	
    47	@ -------------- end cut --------------------------
    48	
    49	stop:   B	stop
    50		.data
    51	TestStr:	.asciz	"123aBc12"
    52		.end
    53	@
    54	@ End of file HexToVal.s
