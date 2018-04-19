Red [
	Title:   "OTP Generator Library"
	Author:  "PlanetSizeCpu"
	File: 	 %otplib.red
	Version: 0.1.6
	Usage:  {
		Use with do / include and call otpGet function with integer parameters
		#blocks, #lines/block, #columns, #symbols/block,
		#random symbol ascii max value (1-254), #offset to add to value
	}
	History: [
		0.1.0 "28-08-2016"	"First version."
		0.1.1 "15-09-2016"	"Added range & offset parameters."
		0.1.2 "21-02-2017"	"Positive parameters check "
		0.1.3 "29-03-2017"	"Syntax adjustements"
		0.1.4 "29-05-2017"	"Loop starts at 1"
		0.1.5 "06-10-2017"	"Added coder/decoder functions"
		0.1.6 "10-10-2017"	"solved omitting code of last otp char"
		0.1.7 "17-01-2018"	"fixed decoder return string name"
		]
]

; At start compute a time-related integer for feeding randomize func 
Timx: split (form now/time) ":"
Thou: to integer! first  Timx
Tmin: to integer! second Timx
Tsec: to integer! third  Timx
Tpow: ( Tsec * Tmin * Thou ) * (now/year * now/day)
random/seed Tpow
NewLine: make char! 10 
Hole: make char! 216

; One Time Pad computation function
otpGet: function [ BlqMax LinMax ColMax SymMax SymRng SymOst] 
[ 
	Space: " "
	LineString: ""
	BlockString: ""
	OtpString: ""
	clear OtpString
	either (BlqMax < 0) or (LinMax < 1) or (ColMax < 1) or (SymMax < 1) or (SymRng < 1) [print "OTPGET: Bad argument! " return OtpString] []

	; Block Processing Loop
	Blq: 1
	while [Blq <= BlqMax] [
		Blq: Blq + 1
		
		; Line Processing Loop
		Lin: 1
		while [Lin <= LinMax] [
			Lin: Lin + 1
	
			; Column Processing Loop
			Col: 1
			while [Col <= ColMax] [
				Col: Col + 1
				
				; Symbol Processing Loop
				Sym: 1
				while [Sym <= SymMax] [
					Sym: Sym + 1
					
					; Compute random symbol in range 
				    Chr: make char! otpGetCharRnd SymRng SymOst
					
					; That occurs at the end of a symbol
					append LineString Chr					
				]
				
				; That occurs at the end of a column
				append LineString Space
			]
			
			; That occurs at the end of a line
			append BlockString LineString
			append BlockString newline
			clear LineString
		]
		
		; That occurs at the end of a block
		append OtpString BlockString 
		append OtpString NewLine
		clear BlockString
	]
	
	; That occurs at the end of the otp
	return OtpString
]

; Random symbol computation function + offset mapping
otpGetCharRnd: function [Range Offset] [

	; Compute random number in range
	Value: random/secure Range

	; Add desired Offset 
	Value: Value + Offset
		
	return Value
]

; One Time Pad text coding function
otpCode: function [ClrText OtpText][
	CodeText: copy ""
	CodeInd: 1
	CodeMax: length? OtpText
	CodeMax: add CodeMax 1
	foreach Ltr ClrText [
		Chr: copy ""
		while [Ltr <> Chr] [
			if CodeInd > CodeMax [break]
			Chr: OtpText/(CodeInd)
			either Chr = NewLine [append CodeText NewLine][append CodeText " "]
			CodeInd: add CodeInd 1
		]
		if CodeInd > CodeMax [break]
		append CodeText Hole
	]
	return CodeText
]

; One Time Pad text decoding function
otpDeCode: func [CypherText OtpText][
	ClrText: copy ""
	Ltr: copy ""
	CodeInd: 0
	foreach Ltr CypherText [
		either Ltr = Hole [append ClrText OtpText/(CodeInd)] [CodeInd: add CodeInd 1]
	]
	return ClrText
]