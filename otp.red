Red [	
	Title:   "OTP Generator"
	Author:  "PlanetSizeCpu"
	File: 	 %otp.red
	Version: Under Development see below
	Needs:	 'View
	Usage:  {
		Use it for one-time-pad or password automatic generation
	}
	History: [
		0.1.0 "28-08-2016"  "First version."
		0.1.1 "02-09-2016"  "Added coding behavior sliders."
		0.1.2 "03-09-2016"  "Added action buttons."
		0.1.3 "05-09-2016"  "Added font type/size controls."
		0.1.4 "09-09-2016"  "Added symbol mode controls."
		0.1.5 "15-09-2016"  "Added info screen."
		0.1.6 "27-09-2016"  "Minor screen adjust"
		0.1.7 "25-10-2016"  "Copy-to-Clipboard function added"
		0.1.8 "18-01-2017"  "Area1 changed to base type to avoid flicker"
		0.1.9 "27-04-2017"  "write-clipboard implemented to CopyDoc func"
		0.2.0 "01-06-2017"  "#Symbol multiplyer slider act over #symbols" 
		0.2.1 "13-06-2017"  "#Symbol multiplyer slider act over #lines"
		0.2.2 "03-07-2017"  "Added +1 to sliders data avoiding 0 values"
		0.2.3 "19-07-2017"  "Added hand cursor to COPY button"
		0.2.4 "01-10-2017"  "Added coder tabs"
		0.2.5 "06-10-2017"  "Added coder/decoder"
		0.2.6 "19-10-2017"  "Fixed coder call break related overflow"
		0.2.7 "02-02-2018"  "Reactions code block moved & upgraded"
		0.2.8 "20-04-2018"  "Add paste button & code"
		0.2.9 "27-04-2018"  "Fixed start button misshandling"
		0.3.0 "06-07-2018"  "Add copy buttons on tabs"
		0.3.1 "03-01-2019"  "Add font selection & remove old choices"
	]
]

; Load/include otp library
either system/state/interpreted? [do %otplib.red][#include %otplib.red]
	
; Default values
; recycle
BlqPtr: 5
LinPtr: 5
ColPtr: 5
SymPtr: 5
SymMul: 10   ; # Symbol multiplyer
SymRng: 90   ; Range of ASCII symbols that ends with "z"
SymOst: 32   ; Offset to ASCII keyboard symbols that start with space
DefFnt: "Consolas"
NewFnt: object!
DefVer: "------------ Version 0.3.1 -----------"

;
; SCREEN BLOCKS DEFINITIONS
;
; Info screen layout
infoScreen: [
	title "About"
	size 220x240
	origin 10x5
	text bold "OTP Generator  by  Planet Size CPU" return
	text bold DefVer return
	text bold "       planetsizecpu@gmail.com    " return
	text bold "                   Powered by     " return
	text bold "RED Lang @ Full Stack Technologies" return
	text bold "              www.red-lang.org    " return
	button 200x25 bold "Visit HQ" on-click [ browse http://red-lang.org ] 
]

; Screen tabs
mainTabs: [ "OTP" [
	; --- OTP tab ---
	origin 5x0
	
	; Behavior controls
	group-box 435x164 [
		space 5x10
		text bold "BLOCKS " blk: slider 160x25 50%
		mod1: radio bold "AlphaMix" para [align: 'right] data on on-down [SymRng: 90 SymOst: 32]
		return
		text bold "LINES  " lin: slider 160x25 50%
		mod2: radio bold "Numbers" on-down [SymRng: 10 SymOst: 47]
		return
		text bold "COLUMNS" col: slider 160x25 50% 
		mod3: radio bold "Capital" on-down [SymRng: 26 SymOst: 64]
		return
		text bold "SYMBOLS" sym: slider 160x25 50%
		mod4: radio bold "LowCase" on-down [SymRng: 26 SymOst: 96] 
		at 400x20 mul: slider 25x110 10%
		pad 40x5 text bold "#Sym²"
	]
	return
	
	; Font controls
	group-box 435x90 [
		space 25x10
		fnt1: radio bold "Console" data on on-down [Area1/Font/Name: "Consolas"] 
		fnt2: button bold "Font" on-click [NewFnt: request-font	either none? NewFnt [][Area1/Font: NewFnt Area1/Font/Color: white Area1/color: blue fnt1/data: false sty2/data: false]]
		sty1: check bold "Bold" [either face/data [Area1/font/style: 'bold ] [Area1/Font/Style: none] ]
		sty2: check bold "Reverse" [either face/data [Area1/Color: white Area1/Font/Color: blue] [Area1/Color: blue Area1/Font/Color: white] ]
		return
		text bold "SIZE" siz: slider 200x25 50% return
	]
	return
	
	; Action buttons
	btn1: button 75x40 bold "COMPUTE" on-click [btn3/Text: "START" Area1/rate: none CycleDoc] 
	btn2: button 75x40 bold "COPY" on-click [CopyDoc] cursor hand
	btn3: button 75x40 bold "PASTE" on-click [PasteDoc] cursor hand
	btn4: button 75x40 bold "STOP" on-click  [either Area1/rate [btn4/Text: "START" Area1/rate: none ] [btn4/Text: "STOP" Area1/rate: 10] ]
	btn5: button 75x40 bold "ABOUT" on-click [view infoScreen] 
	return
  
	; Otp area1
	Area1: base 435x390 rate 15 blue font [
        name: DefFnt
        size: 12
        color: white
		] para [align: 'center wrap?: yes] on-time [CycleDoc]	
	]

	; --- Key tab ---
	"Key" [
	origin 5x10
	SourceTxt: field 350x40  green font [
        name: DefFnt
        size: 20
        color: black
		]	
	button 70x40 "CODE" [pan/selected: 3 Area3/text: otpCode SourceTxt/text Area2/text]		
	return
	Area2: area 435x600 blue font [
        name: DefFnt
        size: 12
        color: white
		] para [wrap?: no ]
	return
	button 70x40 "Copy" [CopyKey]
	]
		
	; --- Coder-Decoder tab ---
	"Coder" [
	origin 5x10
	DeCodeTxt: field 350x40  red font [
        name: DefFnt
        size: 20
        color: black
		]	
	button 70x40 "DECODE" [DeCodeTxt/text: otpDeCode Area3/text Area2/text]		
	return
	Area3: area 435x600 blue font [
        name: DefFnt
        size: 12
        color: white
		] para [wrap?: yes]
		return
	button 70x40 "Copy" [CopyCoder]
	]
]

; Main screen layout
mainScreen: layout [
	title "OTP" 
	size 450x750
	at 0x0 pan: tab-panel 449x749 mainTabs on-change [if event/picked > 1 [btn4/Text: "START" Area1/rate: none]]

	; Reactions
	react [BlqPtr: to integer! (blk/data * 10) + 1
		   ColPtr: to integer! (col/data * 10) + 1
		   SymMul: to integer! (mul/data * 100)  
		   LinPtr: to integer! (lin/data * SymMul) + 1
		   SymPtr: to integer! (sym/data * SymMul) + 1
		   Area1/Font/Size: (to integer! siz/data * 20)
		   Area2/Font/Size: (to integer! siz/data * 20)
		   Area3/Font/Size: (to integer! siz/data * 20)]	
]

;
; SCRIPT FUNCTIONS DEFINITION
;
; Cycle current otp
CycleDoc: does [
	clear Area1/text
	TmpOtp: otpGet BlqPtr LinPtr ColPtr SymPtr SymRng SymOst
	Area1/text: TmpOtp
	Area2/text: TmpOtp
]

; Copy to clipboard current otp
CopyDoc: does [
	TmpOtp: Area1/text
	write-clipboard TmpOtp
	prin TmpOtp
	]
	
; Paste on current otp from clipboard (otp or formatted text)
; CAUTION, CLIPBOARD DOES NOT HANDLE CR/NL PROPERLY
PasteDoc: does [
	Area1/text: read-clipboard
	]

; Copy to clipboard current key otp (encoded string)
CopyKey: does [
	TmpKey: Area2/text
	write-clipboard TmpKey
	prin TmpKey
	]	

	
; Paste on Key tab from clipboard (otp or formatted text)
; CLIPBOARD DOES NOT HANDLE CR/NL PROPERLY SO WE NO LOGER USE IT HERE
PasteKey: does [
	clear Area2/text
	Area2/text: read-clipboard
	]
	
; Copy to clipboard current coder (encoded string)
CopyCoder: does [
	TmpCoder: Area3/text
	write-clipboard TmpCoder
	prin TmpCoder
	]	

; Paste on coder from clipboard (encoded string) 
; CLIPBOARD DOES NOT HANDLE CR/NL PROPERLY SO WE NO LOGER USE IT HERE
PasteCoder: does [
	clear Area3/text
	Area3/text: read-clipboard
	]
	

;
; RUN CODE, ALL DONE BY VIEW & RATE 	
;
view mainScreen
