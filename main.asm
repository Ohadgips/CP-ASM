IDEAL
MODEL small
STACK 100h

DATASEG
;All PrintBmp Variable
stor   	 	dw      0      ;our memory location storage
imgHeight dw 200  ;Height of image that fits screen
imgWidth dw 320   ;Width of image that fits screen
adjustCX dw ?     ;Adjusts register CX
filename db 20 dup (?) ;Generates the file's name 
filehandle dw ?  ;Handles the file
Header db 54 dup (0)  ;Read BMP file header, 54 bytes
Palette db 256*4 dup (0)  ;Enable colors
ScrLine db 320 dup (0)   ;Screen Line
Errormsg db 'Error', 13, 10, '$'   ;In case of not having all the files, Error message pops
printAdd dw ?   ;Enable to add new graphics

;Delay
seconds db 4 ;set the time for the delay

;All Pages
OpenPage db 'Open.bmp', 0   ;home image (bmp)
InfoPage db 'Info.bmp',0 ;info image  (bmp)
LevelPage db 'levels.bmp',0 ;levels image (bmp)
RightGuess db 'TrueG.bmp',0 ; guess right image (bmp)
WrongGuess db 'WrongG.bmp',0 ; guess wrong image (bmp)
ThanksForPlaying db 'Thanks.bmp',0 ; exit game image (bmp)

;Game Levels
EazyLevelOne db 'LevelE.bmp',0;  eazy level 1 image (bmp)                                        
EazyLevelTwo db 'LevelE2.bmp',0;  eazy level 2 image (bmp)                                        
EazyLevelThree db 'LevelE3.bmp',0;  eazy level 3 image (bmp)                                        
MediumLevelOne db 'LevelM.bmp',0; medium level 1 image (bmp)
MediumLevelTwo db 'LevelM2.bmp',0; medium level 2 image (bmp)
MediumLevelThree db 'LevelM3.bmp',0; medium level 3 image (bmp)
HardLevelOne db 'LevelH.bmp',0; hard level 1 image (bmp)                                        
HardLevelTwo db 'LevelH2.bmp',0; hard level 2 image (bmp)
HardLevelThree db 'LevelH3.bmp',0; hard level 3 image (bmp)

;All Guess Buttons
GuessButtonOff db 'GuessO.bmp',0 ;off guess button (bmp)
GuessButtonE db 'GuessE.bmp',0 ;on guess button eazy level (bmp)
GuessButtonM db 'GuessM.bmp',0 ;on guess button medium level (bmp)
GuessButtonH db 'GuessH.bmp',0 ;on guess button hard level (bmp)

;All Chocolates
BrownCircle db 'BrownC.bmp',0 ;  Brown circle
PinkCircle db 'PinkC.bmp',0 ;  Pink circle 
YellowCircle db 'YellowC.bmp',0 ; Yellow circle 
BrownSquare db 'BrownS.bmp',0 ; Brown Square 
PinkSquare db 'PinkS.bmp',0 ; Pink Square 
YellowSquare db 'YellowS.bmp',0 ; Yellow Square 
BrownTriangle db 'BrownT.bmp',0 ; Brown Triangle 
PinkTriangle db 'PinkT.bmp',0 ; Pink Triangle 
YellowTriangle db 'YellowT.bmp',0 ; Yellow Triangle
Cubes db 'Cube.bmp',0 ;empty board button image (bmp)

;All Keepers
OldPlaceForChocolates db ? ;keep the old place of the chocolate to delete it
ClearPlaceForChocolates db ? ;keep the place of the chocolate to delete it
LastLevel db ? ;keep the last level so it wont play the same level again                                           !!!!
LevelCount db ? ;save the active level (eazy levels 1-3, medium levels 4-6, hard levels 7-9)                                         !!!!
LevelTypeChoosen db ?;Keep the type of level the player choose (easy-1,medium-2,hard-3)
ChocolateType db ? ;keep chocolate type that clicked
BoardButtonOne db ? ;keep the chocolate in this board button
BoardButtonTwo db ? ;keep the chocolate in this board button
BoardButtonThree db ? ;keep the chocolate in this board button
BoardButtonFour db ? ;keep the chocolate in this board button
BoardButtonFive db ? ;keep the chocolate in this board button
BoardButtonSix db ? ;keep the chocolate in this board button
BoardButtonSeven db ? ;keep the chocolate in this board button
BoardButtonEight db ? ;keep the chocolate in this board button
BoardButtonNine db ? ;keep the chocolate in this board button
ButtonThatClicked db ? ;keep the button that clicked

CODESEG

;///////////////////////////////////////////////// Print Bmp ////////////////////////////////////////////////////////////////////////
;Prints the bmp file provided
;IN: ax - img offset, imgHeight (dw), imgWidth (dw), printAdd (dw)
;OUT: printed bmp file
proc PrintBmp
	push cx
	push di
	push si
	push cx
	push ax
	xor di, di
	mov di, ax
	mov si, offset filename
	
	mov cx, 20
Copy:
	mov al, [di]
	mov [si], al
	inc di
	inc si
	loop Copy
	pop ax
	pop cx
	pop si
	pop di
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitMap
	call CloseFile
	pop cx
	ret
endp PrintBmp

;in proc PrintBmp
proc OpenFile
	mov ah,3Dh
	xor al,al ;for reading only
	mov dx, offset filename
	int 21h
	jc OpenError
	mov [filehandle],ax
	ret
OpenError:
	mov dx,offset Errormsg
	mov ah,9h
	int 21h
	ret
endp OpenFile

;in proc PrintBmp
proc ReadHeader
;Read BMP file header, 54 bytes
	mov ah,3Fh
	mov bx,[filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp ReadHeader

;in proc PrintBmp
proc ReadPalette
;Read BMP file color palette, 256 colors*4bytes for each (400h)
	mov ah,3Fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette

;in proc PrintBmp
proc CopyPal
; Copy the colors palette to the video memory
; The number of the first color should be sent to port 3C8h
; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h ;port of Graphics Card
	mov al,0 ;number of first color
	;Copy starting color to port 3C8h
	out dx,al
	;Copy palette itself to port 3C9h
	inc dx
PalLoop:
	;Note: Colors in a BMP file are saved as BGR values rather than RGB.	
	mov al,[si+2] ;get red value
	shr al,2 	; Max. is 255, but video palette maximal value is 63. Therefore dividing by 4
	out dx,al ;send it to port
	mov al,[si +1];get green value
	shr al,2
	out dx,al	;send it
	mov al,[si]
	shr al,2
	out dx,al 	;send it
	add si,4	;Point to next color (There is a null chr. after every color)
	loop PalLoop
	ret 
endp CopyPal

;in proc PrintBmp
proc CopyBitMap
; BMP graphics are saved upside-down.
; Read the graphic line by line ([height] lines in VGA format),
; displaying the lines from bottom to top.
	mov ax,0A000h ;value of start of video memory
	mov es,ax	
	push ax
	push bx
	mov ax, [imgWidth]
	mov bx, 4
	div bl
	cmp ah, 0
	jne NotZero
Zero:
	mov [adjustCX], 0
	jmp Continue
NotZero:
	mov [adjustCX], 4
	xor bx, bx
    mov bl, ah
	sub [adjustCX], bx
Continue:
	pop bx
	pop ax
	mov cx, [imgHeight]	;reading the BMP data - upside down
	
PrintBMPLoop:
	push cx
	xor di, di
	push cx
	dec cx
	Multi:
		add di, 320
		loop Multi
	pop cx

    add di, [printAdd]
	mov ah, 3fh
	mov cx, [imgWidth]
	add cx, [adjustCX]
	mov dx, offset ScrLine
	int 21h
	;Copy one line into video memory
	cld	;clear direction flag - due to the use of rep
	mov cx, [imgWidth]
	mov si, offset ScrLine
	rep movsb 	;do cx times:
				;mov es:di,ds:si -- Copy single value form ScrLine to video memory
				;inc si --inc - because of cld
				;inc di --inc - because of cld
	pop cx
	loop PrintBMPLoop
	ret
endp CopyBitMap

;in proc PrintBmp
proc CloseFile
	mov ah,3Eh
	mov bx,[filehandle]
	int 21h
	ret
endp CloseFile

;enables graphics mode
;IN: X
;OUT: graphics mode enabled
;///////////////////////////////////////////////// Print Bmp Actions ////////////////////////////////////////////////////////////////

;///////////////////////////////////////////////// Home Page ////////////////////////////////////////////////////////////////////////
;print the homepage
proc HomeWindowBmp

; don't show mouse
    mov ax, 0h
    int 33h
	
	mov ax, offset OpenPage
	mov [printAdd], 0
	call PrintBmp
	call HomePage
endp HomeWindowBmp

; home page buttons check
proc HomePage

; Show mouse
mov ax,1h
int 33h

;;loop until button clicked
MouseLP :
mov ax,0003h
int 33h
shr cx, 1
cmp bx,01h
jne MouseLP

cmp cx,245
jl playbutton
cmp cx,310
jg playbutton
cmp dx,176
jl playbutton
cmp dx,194
jg playbutton
call OpeninfoBmp 

playbutton:
cmp cx,7
jl MouseLP
cmp cx,115
jg MouseLP
cmp dx,161
jl MouseLP
cmp dx,194
jg MouseLP
call OpenlevelBmp

endp HomePage
;///////////////////////////////////////////////// Home Page ////////////////////////////////////////////////////////////////////////

;///////////////////////////////////////////////// Info Page ////////////////////////////////////////////////////////////////////////
;open the info page
proc OpeninfoBmp 

; don't show mouse
    mov ax, 0h
    int 33h
	
    call CloseFile
	mov ax, offset InfoPage
	mov [printAdd], 0
	call PrintBmp
	call BackInfoPageS
endp OpeninfoBmp

;check the back button in info window
proc BackInfoPageS

; Show mouse
mov ax,1h
int 33h

;loop until button clicked
MouseBackLP:
mov ax,0003h
int 33h
shr cx, 1
cmp bx,01h
jne MouseBackLP
cmp cx,221
jl MouseBackLP
cmp cx,297
jg MouseBackLP
cmp dx,161
jl MouseBackLP
cmp dx,190
jg MouseBackLP
call HomeWindowBmp
endp BackInfoPageS
;///////////////////////////////////////////////// Info Page ////////////////////////////////////////////////////////////////////////

;///////////////////////////////////////////////// Levels Page ////////////////////////////////////////////////////////////////////////
;print the level page
proc OpenlevelBmp

; don't show mouse
    mov ax, 0h
    int 33h
	
    call CloseFile
	mov ax, offset LevelPage
	mov [printAdd], 0
	call PrintBmp
    call LevelPageButtons	
endp OpenlevelBmp

;print easy level
proc OpenEazyLevel

; don't show mouse
    mov ax,0h
    int 33h
	
    call CloseFile
	cmp [LevelCount],1
	jne EzLvl2
	mov ax, offset EazyLevelOne
	jmp EazyLevelPrint
	EzLvl2:
	cmp [LevelCount],2
	jne EzLvl3
	mov ax, offset EazyLevelTwo
	jmp EazyLevelPrint
	EzLvl3:
	mov ax, offset EazyLevelThree
	jmp EazyLevelPrint
	EazyLevelPrint:
	mov [printAdd], 0
	call PrintBmp
    call ChocolatesButtons
endp OpenEazyLevel

;print medium level
proc OpenMediumLevel

; don't show mouse
    mov ax, 0h
    int 33h
	
    call CloseFile
	cmp [LevelCount],4
	jne MediumLvl2
	mov ax, offset MediumLevelOne
	jmp EazyLevelPrint
	MediumLvl2:
	cmp [LevelCount],5
	jne MediumLvl3
	mov ax, offset MediumLevelTwo
	jmp EazyLevelPrint
	MediumLvl3:
	mov ax, offset MediumLevelThree
	jmp MediumLevelPrint
	MediumLevelPrint:
	mov [printAdd], 0
	call PrintBmp
    call ChocolatesButtons
endp OpenMediumLevel

;print hard level
proc OpenHardLevel

; don't show mouse
    mov ax,0h
    int 33h
	
    call CloseFile
	cmp [LevelCount],7
	jne HardLvl2
	mov ax, offset HardLevelOne
	jmp EazyLevelPrint
	HardLvl2:
	cmp [LevelCount],8
	jne HardLvl3
	mov ax, offset HardLevelTwo
	jmp EazyLevelPrint
	HardLvl3:
	mov ax, offset HardLevelThree
	jmp HardLevelPrint
	HardLevelPrint:
	mov [printAdd], 0
	call PrintBmp
    call ChocolatesButtons
endp OpenHardLevel

;check buttons in levels page (back,easy,medium,hard) 
proc LevelPageButtons
; Show mouse
mov ax,1h
int 33h

;loop until button clicked
MouseLevelLP:
mov ax,3h
int 33h
shr cx, 1
cmp bx,01h
jne MouseLevelLP

;back button
cmp cx,125
jl EasyButton
cmp cx,193
jg EasyButton
cmp dx,117
jl EasyButton
cmp dx,144
jg EasyButton
call HomeWindowBmp

EasyButton:
cmp cx,11
jl MediumButton
cmp cx,90
jg MediumButton
cmp dx,156
jl MediumButton
cmp dx,193
jg MediumButton
mov [LevelTypeChoosen],1
call LevelsButtonsActions

MediumButton:
cmp cx,104
jl HardButton
cmp cx,215
jg HardButton
cmp dx,156
jl HardButton
cmp dx,193
jg HardButton
mov [LevelTypeChoosen],2
call LevelsButtonsActions

HardButton:
cmp cx,229
jl MouseLevelLP
cmp cx,309
jg MouseLevelLP
cmp dx,156
jl MouseLevelLP
cmp dx,193
jg MouseLevelLP
mov [LevelTypeChoosen],3
call LevelsButtonsActions

endp LevelPageButtons

;all the kind of level actions
proc LevelsButtonsActions

;EasyActions
cmp[LevelTypeChoosen],1
jne MediumActions

;open random easy level
again:
mov ax, 40h
mov es, ax
mov ax, es:6Ch
and al, 00000011b
cmp al,0
je again
cmp al,[LastLevel]
je again
mov [LevelCount],al
mov [LastLevel],al
call OpenEazyLevel

MediumActions:
cmp[LevelTypeChoosen],2
jne HardActions

;open random medium level
again2:
mov ax, 40h
mov es, ax
mov ax, es:6Ch
and al, 00000111b
cmp al,3
jl again2
cmp al,7
jg again2
cmp al,[LastLevel]
je again2
mov [LevelCount],al
mov [LastLevel],al
call OpenMediumLevel

HardActions:

;open random hard level
again3:
mov ax, 40h
mov es, ax
mov ax, es:6Ch
and al, 00001111b
cmp al,6
jl again3
cmp al,10
jg again3
cmp al,[LastLevel]
je again3
mov [LevelCount],al
mov [LastLevel],al
call OpenHardLevel
endp LevelsButtonsActions

;///////////////////////////////////////////////// Levels Page ////////////////////////////////////////////////////////////////////////

;///////////////////////////////////////////////// Game Page Pictures ////////////////////////////////////////////////////////////////

;clear the old place the chocolate was if the player choose a new place
proc ClearOldPlace
    push ax
    push bx 
    push cx
    push dx
	mov [imgHeight],40
	mov [imgWidth],41
    mov ax, offset Cubes

;check what is the old place for the chocolate	

;OldPlaceForButtonOne:
cmp [OldPlaceForChocolates],1
jne  OldPlaceForButtonTwo
mov [printAdd],21458

OldPlaceForButtonTwo:
cmp [OldPlaceForChocolates],2
jne OldPlaceForButtonThree
mov [PrintAdd],21502

OldPlaceForButtonThree:
cmp [OldPlaceForChocolates],3
jne OldPlaceForButtonFour
mov [printAdd],21546

OldPlaceForButtonFour:
cmp [OldPlaceForChocolates],4
jne OldPlaceForButtonFive
mov [printAdd],35218

OldPlaceForButtonFive:
cmp [OldPlaceForChocolates],5
jne OldPlaceForButtonSix
mov [printAdd],35262

OldPlaceForButtonSix:
cmp [OldPlaceForChocolates],6
jne OldPlaceForButtonSeven
mov [printAdd],35306


OldPlaceForButtonSeven:
cmp [OldPlaceForChocolates],7
jne OldPlaceForButtonEight
mov [printAdd],49298

OldPlaceForButtonEight:
cmp [OldPlaceForChocolates],8
jne OldPlaceForButtonNine
mov [printAdd],49342

OldPlaceForButtonNine:
cmp [OldPlaceForChocolates],9
jne nextactions
mov [printAdd],49386


nextactions:
call PrintBmp
pop dx cx bx ax
ret
endp ClearOldPlace

;clear a chocolate from the board
proc ChosenClearOldPlace
    push ax
    push bx 
    push cx
    push dx
	mov [imgHeight],40
	mov [imgWidth],41
    mov ax, offset Cubes

;check where to clean the chocolate

;ClearPlaceForButtonOne:
cmp [ClearPlaceForChocolates],1
jne  ClearPlaceForButtonTwo
mov [printAdd],21458
jmp ClearProcNextActions

ClearPlaceForButtonTwo:
cmp [ClearPlaceForChocolates],2
jne ClearPlaceForButtonThree
mov [PrintAdd],21502
jmp ClearProcNextActions

ClearPlaceForButtonThree:
cmp [ClearPlaceForChocolates],3
jne ClearPlaceForButtonFour
mov [printAdd],21546
jmp ClearProcNextActions

ClearPlaceForButtonFour:
cmp [ClearPlaceForChocolates],4
jne ClearPlaceForButtonFive
mov [printAdd],35218
jmp ClearProcNextActions

ClearPlaceForButtonFive:
cmp [ClearPlaceForChocolates],5
jne ClearPlaceForButtonSix
mov [printAdd],35262
jmp ClearProcNextActions

ClearPlaceForButtonSix:
cmp [ClearPlaceForChocolates],6
jne ClearPlaceForButtonSeven
mov [printAdd],35306
jmp ClearProcNextActions


ClearPlaceForButtonSeven:
cmp [ClearPlaceForChocolates],7
jne ClearPlaceForButtonEight
mov [printAdd],49298
jmp ClearProcNextActions

ClearPlaceForButtonEight:
cmp [ClearPlaceForChocolates],8
jne ClearPlaceForButtonNine
mov [printAdd],49342
jmp ClearProcNextActions

ClearPlaceForButtonNine:
mov [printAdd],49386
jmp ClearProcNextActions

ClearProcNextActions:
call PrintBmp
pop dx cx bx ax
ret

endp ChosenClearOldPlace

;print a chocolate
proc OpenBmpChocolateInBoard
push ax
push bx
push cx
push dx
mov [imgHeight],40
mov [imgWidth],41

;check what chocolate to print

;BrownCircleType:
cmp [ChocolateType],1
jne PinkCircleType
mov ax,offset BrownCircle
jmp CheckPrintAdd

PinkCircleType:
cmp [ChocolateType],2
jne YellowCircleType
mov ax,offset PinkCircle
jmp CheckPrintAdd

YellowCircleType:
cmp [ChocolateType],3
jne BrownSquareType
mov ax,offset YellowCircle
jmp CheckPrintAdd

BrownSquareType:
cmp [ChocolateType],4
jne PinkSquareType
mov ax,offset BrownSquare
jmp CheckPrintAdd

PinkSquareType:
cmp [ChocolateType],5
jne YellowSquareType
mov ax,offset PinkSquare
jmp CheckPrintAdd

YellowSquareType:
cmp [ChocolateType],6
jne BrownTriangleType
mov ax,offset YellowSquare
jmp CheckPrintAdd

BrownTriangleType:
cmp [ChocolateType],7
jne PinkTriangleType
mov ax,offset BrownTriangle
jmp CheckPrintAdd

PinkTriangleType:
cmp [ChocolateType],8
jne YellowTriangleType
mov ax,offset PinkTriangle
jmp CheckPrintAdd

YellowTriangleType:
mov ax,offset YellowTriangle
jmp CheckPrintAdd

;check what place to print the chocolate
CheckPrintAdd: 

;PlaceForButtonOne:
cmp [ButtonThatClicked],1
jne  PlaceForButtonTwo
mov [printAdd],21458
jmp NextToPrint

PlaceForButtonTwo:
cmp [ButtonThatClicked],2
jne PlaceForButtonThree
mov [PrintAdd],21502
jmp NextToPrint

PlaceForButtonThree:
cmp [ButtonThatClicked],3
jne PlaceForButtonFour
mov [printAdd],21546
jmp NextToPrint

PlaceForButtonFour:
cmp [ButtonThatClicked],4
jne PlaceForButtonFive
mov [printAdd],35218
jmp NextToPrint

PlaceForButtonFive:
cmp [ButtonThatClicked],5
jne PlaceForButtonSix
mov [printAdd],35262
jmp NextToPrint

PlaceForButtonSix:
cmp [ButtonThatClicked],6
jne PlaceForButtonSeven
mov [printAdd],35306
jmp NextToPrint


PlaceForButtonSeven:
cmp [ButtonThatClicked],7
jne PlaceForButtonEight
mov [printAdd],49298
jmp NextToPrint

PlaceForButtonEight:
cmp [ButtonThatClicked],8 
jne PlaceForButtonNine
mov [printAdd],49342
jmp NextToPrint

PlaceForButtonNine:
mov [printAdd],49386
jmp NextToPrint

NextToPrint:

call PrintBmp
pop dx cx bx ax
ret

endp OpenBmpChocolateInBoard

proc GuessButtonOffBmp
push ax
push bx
push cx
push dx
mov [imgHeight],26
mov [imgWidth],98
mov ax,offset GuessButtonOff
mov [printAdd],52657
call PrintBmp
pop dx cx bx ax
ret
endp GuessButtonOffBmp

;turn on the guess button
proc GuessButtonOnBmp
push ax
push bx
push cx
push dx
mov [imgHeight],26
mov [imgWidth],98

;EazyLevelGuessButton
cmp [LevelTypeChoosen],1
jne MediumLevelGuessButton
mov ax,offset GuessButtonE
jmp NextInTheProc

MediumLevelGuessButton:
cmp [LevelTypeChoosen],2
jne HardLevelGuessButton
mov ax,offset GuessButtonM
jmp NextInTheProc

HardLevelGuessButton:
mov ax,offset GuessButtonH
jmp NextInTheProc

NextInTheProc:
mov [printAdd],52657
call PrintBmp
pop dx cx bx ax
ret
endp GuessButtonOnBmp


;///////////////////////////////////////////////// Game Page Pictures ////////////////////////////////////////////////////////////////

;///////////////////////////////////////////////// Game Page General Buttons /////////////////////////////////////////////////////////

;all the buttons in the top bar
proc ChocolatesButtons

; Show mouse
mov ax,1h
int 33h

;loop until button clicked
MouseChocolatesLP:
mov ax,3h
int 33h
shr cx, 1
cmp bx,01h
jne MouseChocolatesLP

;check the first 4 buttons in the board

;check if the player want to clean one of the chocolate from the board
cmp cx,12
jl BrownCircleButton
cmp cx,38
jg BrownCircleButton
cmp dx,15
jl BrownCircleButton
cmp dx,57
jg BrownCircleButton
call CheckWhatToDelete

BrownCircleButton:;(1)
cmp cx,42
jl PinkCircleButton
cmp cx,68
jg PinkCircleButton
cmp dx,15
jl PinkCircleButton
cmp dx,57
jg PinkCircleButton
mov [ChocolateType],1
call BoardButtons

PinkCircleButton:;(2)
cmp cx,72
jl YellowCircleButton
cmp cx,98
jg YellowCircleButton
cmp dx,15
jl YellowCircleButton
cmp dx,57
jg YellowCircleButton
mov [ChocolateType],2
call BoardButtons

YellowCircleButton:;(3)
cmp cx,102
jl Next
cmp cx,128
jg Next
cmp dx,15
jl Next
cmp dx,57
jg Next
mov [ChocolateType],3
call BoardButtons

Next:
call SecChocolatesButtons

endp ChocolatesButtons

;check the middle 3 buttons in the board
proc SecChocolatesButtons
;BrownSquareButton:(4)
cmp cx,132
jl PinkSquareButton
cmp cx,158
jg PinkSquareButton
cmp dx,15
jl PinkSquareButton
cmp dx,57
jg PinkSquareButton
mov [ChocolateType],4
call BoardButtons

PinkSquareButton:;(5)
cmp cx,162
jl YellowSquareButton
cmp cx,188
jg YellowSquareButton
cmp dx,15
jl YellowSquareButton
cmp dx,57
jg YellowSquareButton
mov [ChocolateType],5
call BoardButtons

YellowSquareButton:;(6)
cmp cx,192
jl BrownTriangleButton
cmp cx,218
jg BrownTriangleButton
cmp dx,15
jl BrownTriangleButton
cmp dx,57
jg BrownTriangleButton
mov [ChocolateType],6
call BoardButtons

BrownTriangleButton:;(7)
cmp cx,222
jl LastNext
cmp cx,248
jg LastNext
cmp dx,15
jl LastNext
cmp dx,57
jg LastNext
mov [ChocolateType],7
call BoardButtons

LastNext:
call LastChocolatesButtons
endp SecChocolatesButtons

;check the last 3 buttons in the hot bar
proc LastChocolatesButtons

;PinkTriangleButton:(8)
cmp cx,252
jl YellowTriangleButton
cmp cx,278
jg YellowTriangleButton
cmp dx,15
jl YellowTriangleButton
cmp dx,57
jg YellowTriangleButton
mov [ChocolateType],8
call BoardButtons

YellowTriangleButton:;(9)
cmp cx,282
jl GuessButtonCheck
cmp cx,308
jg GuessButtonCheck
cmp dx,15
jl GuessButtonCheck
cmp dx,57
jg GuessButtonCheck
mov [ChocolateType],9
call BoardButtons

;check if every chocolate have a place on the board
GuessButtonCheck:
cmp [BoardButtonOne],0
je SearchAgainNoGuess
cmp [BoardButtonTwo],0
je SearchAgainNoGuess
cmp [BoardButtonThree],0
je SearchAgainNoGuess
cmp [BoardButtonFour],0
je SearchAgainNoGuess
cmp [BoardButtonFive],0
je SearchAgainNoGuess
cmp [BoardButtonSix],0
je SearchAgainNoGuess
cmp [BoardButtonSeven],0
je SearchAgainNoGuess
cmp [BoardButtonEight],0
je SearchAgainNoGuess
cmp [BoardButtonNine],0
je SearchAgainNoGuess
jmp SearchGuessButton

;turn off the guess button if not all chocolate has a place on the board
SearchAgainNoGuess:
call GuessButtonOffBmp
call ChocolatesButtons

;turn on the guess button if all chocolate has a place on the board
SearchGuessButton:
call GuessButtonOnBmp
call GuessButtonMouse
endp LastChocolatesButtons

;check if the player want to guess
proc GuessButtonMouse 
cmp cx,177
jl SearchAgain
cmp cx,274
jg SearchAgain
cmp dx,164
jl SearchAgain
cmp dx,189
jg SearchAgain
call CheckTheGuesses

;if he didn't click on any of the button check again
SearchAgain:
call ChocolatesButtons
endp GuessButtonMouse

;check what chocolate to delete from the board button
proc CheckWhatToDelete
                  ;1|2|3
; Show mouse      ;4|5|6
mov ax,1h         ;7|8|9
int 33h
;loop until button clicked
ClearMouseBoardLP:
mov ax,3h
int 33h
shr cx, 1
cmp bx,01h
jne ClearMouseBoardLP

;check the first 3 buttons in the board

;ClearButton one:(1)
cmp cx,18
jl ClearButtonTwo
cmp cx,58
jg ClearButtonTwo
cmp dx,67
jl ClearButtonTwo
cmp dx,106
jg ClearButtonTwo
mov [ClearPlaceForChocolates],1
mov [BoardButtonOne],0

;dont show mouse
mov ax, 2
int 33h	
call ChosenClearOldPlace
jmp CheckNextChocolatesButton

ClearButtonTwo:;(2)
cmp cx,62
jl ClearButtonThree
cmp cx,102
jg ClearButtonThree
cmp dx,67
jl ClearButtonThree
cmp dx,106
jg ClearButtonThree
mov [ClearPlaceForChocolates],2	
mov [BoardButtonTwo],0

;dont show mouse
mov ax, 2
int 33h	
call ChosenClearOldPlace
jmp CheckNextChocolatesButton

ClearButtonThree:;(3)
cmp cx,106
jl NextClearCheck
cmp cx,146
jg NextClearCheck
cmp dx,67
jl NextClearCheck
cmp dx,106
jg NextClearCheck
mov [ClearPlaceForChocolates],3
mov [BoardButtonThree],0

;dont show mouse
mov ax, 2
int 33h	
call ChosenClearOldPlace
jmp CheckNextChocolatesButton

NextClearCheck:
call SecCheckWhatToDelete

;if he found what to clear go back to chocolate buttons proc
CheckNextChocolatesButton:
call ChocolatesButtons
endp CheckWhatToDelete

;check the middle 3 buttons in the board
proc SecCheckWhatToDelete

;ClearButtonFour:(4)
cmp cx,18
jl ClearButtonFive
cmp cx,58
jg ClearButtonFive
cmp dx,110
jl ClearButtonFive
cmp dx,150
jg ClearButtonFive
mov [ClearPlaceForChocolates],4
mov [BoardButtonFour],0

;dont show mouse
mov ax, 2
int 33h	
call ChosenClearOldPlace
jmp SecCheckNextChocolatesButton

ClearButtonFive:;(5)
cmp cx,62
jl ClearButtonSix
cmp cx,102
jg ClearButtonSix
cmp dx,110
jl ClearButtonSix
cmp dx,150
jg ClearButtonSix
mov [ClearPlaceForChocolates],5
mov [BoardButtonFive],0

;dont show mouse
mov ax, 2
int 33h	
call ChosenClearOldPlace
jmp SecCheckNextChocolatesButton

ClearButtonSix:;(6)
cmp cx,106
jl LastClearCheck
cmp cx,146
jg LastClearCheck
cmp dx,110
jl LastClearCheck
cmp dx,150
jg LastClearCheck
mov [ClearPlaceForChocolates],6
mov [BoardButtonSix],0

;dont show mouse
mov ax, 2
int 33h	
call ChosenClearOldPlace
jmp SecCheckNextChocolatesButton

LastClearCheck:
call LastCheckWhatToDelete

;if he found what to clear go back to chocolate buttons proc
SecCheckNextChocolatesButton:
call ChocolatesButtons
endp SecCheckWhatToDelete

proc LastCheckWhatToDelete
;check the last 3 buttons in the board

;ClearButtonSeven:(7)
cmp cx,18
jl ClearButtonEight
cmp cx,58
jg ClearButtonEight
cmp dx,154
jl ClearButtonEight
cmp dx,193
jg ClearButtonEight
mov [ClearPlaceForChocolates],7
mov [BoardButtonSeven],0

;dont show mouse
mov ax, 2
int 33h	
call ChosenClearOldPlace
jmp BackCheckNextChocolatesButton

ClearButtonEight:;(8)
cmp cx,62
jl ClearButtonNine
cmp cx,102
jg ClearButtonNine
cmp dx,154
jl ClearButtonNine
cmp dx,193
jg ClearButtonNine
mov [ClearPlaceForChocolates],8
mov [BoardButtonEight],0

;dont show mouse
mov ax, 2
int 33h	
call ChosenClearOldPlace
jmp BackCheckNextChocolatesButton
 
ClearButtonNine:;(9)
cmp cx,106
jl CheckAgainWhatToClear
cmp cx,146
jg CheckAgainWhatToClear
cmp dx,154
jl CheckAgainWhatToClear
cmp dx,193
jg CheckAgainWhatToClear
mov [ClearPlaceForChocolates],9
mov [BoardButtonNine],0

;dont show mouse
mov ax, 2
int 33h	
call ChosenClearOldPlace
jmp BackCheckNextChocolatesButton

;if he didn't choose a place to clear so check again
CheckAgainWhatToClear:
call CheckWhatToDelete

;if he found what to clear go back to chocolate buttons proc
BackCheckNextChocolatesButton:
call ChocolatesButtons

endp LastCheckWhatToDelete

;check board buttons to place the chocolate
proc BoardButtons

;don't show mouse 
mov ax, 2
int 33h	          ;1|2|3
                  ;4|5|6
; Show mouse      ;7|8|9
mov ax,1h         
int 33h
;loop until button clicked
MouseBoardLP:
mov ax,3h
int 33h
shr cx, 1

;check if he left clicked
cmp bx,01h
jne MouseBoardLP

;check the first 3 buttons in the board
; Button one:(1)
cmp cx,18
jl ButtonTwo
cmp cx,58
jg ButtonTwo
cmp dx,67
jl ButtonTwo
cmp dx,106
jg ButtonTwo
mov [ButtonThatClicked],1
call BoardButtonsActions


ButtonTwo:;(2)
cmp cx,62
jl ButtonThree
cmp cx,102
jg ButtonThree
cmp dx,67
jl ButtonThree
cmp dx,106
jg ButtonThree
mov [ButtonThatClicked],2	
call BoardButtonsActions

ButtonThree:;(3)
cmp cx,106
jl NextInBoard
cmp cx,146
jg NextInBoard
cmp dx,67
jl NextInBoard
cmp dx,106
jg NextInBoard
mov [ButtonThatClicked],3
call BoardButtonsActions

;if is not one of the first buttons check the next ones
NextInBoard:
call SecBoardButtons
endp BoardButtons

;check the middle 3 buttons in the board
proc SecBoardButtons
;ButtonFour:(4)
cmp cx,18
jl ButtonFive
cmp cx,58
jg ButtonFive
cmp dx,110
jl ButtonFive
cmp dx,150
jg ButtonFive
mov [ButtonThatClicked],4
call BoardButtonsActions

ButtonFive:;(5)
cmp cx,62
jl ButtonSix
cmp cx,102
jg ButtonSix
cmp dx,110
jl ButtonSix
cmp dx,150
jg ButtonSix
mov [ButtonThatClicked],5
call BoardButtonsActions


ButtonSix:;(6)
cmp cx,106
jl LastInBoard
cmp cx,146
jg LastInBoard
cmp dx,110
jl LastInBoard
cmp dx,150
jg LastInBoard
mov [ButtonThatClicked],6
call BoardButtonsActions

;if is not one of the middle buttons check the next ones
LastInBoard:
call LastBoardButtons
endp SecBoardButtons

;check the last 3 buttons in the board
proc LastBoardButtons
;ButtonSeven:(7)
cmp cx,18
jl ButtonEight
cmp cx,58
jg ButtonEight
cmp dx,154
jl ButtonEight
cmp dx,193
jg ButtonEight
mov [ButtonThatClicked],7
call BoardButtonsActions


ButtonEight:;(8)
cmp cx,62
jl ButtonNine
cmp cx,102
jg ButtonNine
cmp dx,154
jl ButtonNine
cmp dx,193
jg ButtonNine
mov [ButtonThatClicked],8
call BoardButtonsActions

 
ButtonNine:;(9)
cmp cx,106
jl BackToStart
cmp cx,146
jg BackToStart
cmp dx,154
jl BackToStart
cmp dx,193
jg BackToStart
mov [ButtonThatClicked],9
call BoardButtonsActions

;if is not one of the last buttons check again
BackToStart:
call BoardButtons
endp LastBoardButtons
;///////////////////////////////////////////////// Game Page General Buttons //////////////////////////////////////////////////////////

;///////////////////////////////////////////////// Game Page Buttons Actions //////////////////////////////////////////////////////////

;check what actions to do after he clicked one of the buttons (clear old one or only place new one)
proc BoardButtonsActions

;dont show mouse
mov ax, 2
int 33h	

;check if the chocolate had an old place
;check button one
mov al,[ChocolateType]
cmp al,[BoardButtonOne]
jne CheckIfTwo
mov [BoardButtonOne],0
mov [OldPlaceForChocolates],1
jmp ClearOld
jmp NewChocolatePlace

CheckIfTwo:
mov al,[ChocolateType]
cmp [BoardButtonTwo],al
jne CheckIfThree
mov [BoardButtonTwo],0
mov [OldPlaceForChocolates],2
jmp ClearOld
jmp NewChocolatePlace

CheckIfThree:
mov al,[ChocolateType]
cmp al,[BoardButtonThree]
jne CheckIfFour
mov [BoardButtonThree],0
mov [OldPlaceForChocolates],3
jmp ClearOld
jmp NewChocolatePlace
 
CheckIfFour:
mov al,[ChocolateType]
cmp al,[BoardButtonFour]
jne CheckIfFive
mov [BoardButtonFour],0
mov [OldPlaceForChocolates],4
jmp ClearOld
jmp NewChocolatePlace

CheckIfFive:
mov al,[ChocolateType]
cmp al,[BoardButtonFive]
jne CheckIfSix
mov [BoardButtonFive],0
mov [OldPlaceForChocolates],5
jmp ClearOld
jmp NewChocolatePlace

CheckIfSix:
mov al,[ChocolateType]
cmp al,[BoardButtonSix]
jne CheckIfSeven
mov [BoardButtonSix],0
mov [OldPlaceForChocolates],6
jmp ClearOld
jmp NewChocolatePlace

CheckIfSeven:
mov al,[ChocolateType]
cmp al,[BoardButtonSeven]
jne CheckIfEight
mov [BoardButtonSeven],0
mov [OldPlaceForChocolates],7
jmp ClearOld
jmp NewChocolatePlace

CheckIfEight:
mov al,[ChocolateType]
cmp al,[BoardButtonEight]
jne CheckIfNine
mov [BoardButtonEight],0
mov [OldPlaceForChocolates],8
jmp ClearOld
jmp NewChocolatePlace

CheckIfNine:
mov al,[ChocolateType]
cmp al,[BoardButtonNine]
jne NewChocolatePlace
mov [BoardButtonNine],0
mov [OldPlaceForChocolates],9
jmp ClearOld
jmp NewChocolatePlace

;clear old place if there is one
ClearOld:
call ClearOldPlace

;after the old place cleard
;check which board button he clicked to place the chocolate
NewChocolatePlace:

cmp [ButtonThatClicked],1
jne ActionForTwo
call OpenBmpChocolateInBoard
mov al,[ChocolateType]
mov [BoardButtonOne],al
jmp NextChocolates

ActionForTwo:
cmp [ButtonThatClicked],2
jne ActionForThree
call OpenBmpChocolateInBoard
mov al,[ChocolateType]
mov [BoardButtonTwo],al
jmp NextChocolates

ActionForThree:
cmp [ButtonThatClicked],3
jne ActionForFour
call OpenBmpChocolateInBoard
mov al,[ChocolateType]
mov [BoardButtonThree],al
jmp NextChocolates

ActionForFour:
cmp [ButtonThatClicked],4
jne ActionForFive
call OpenBmpChocolateInBoard
mov al,[ChocolateType]
mov [BoardButtonFour],al
jmp NextChocolates
 
ActionForFive:
cmp [ButtonThatClicked],5
jne ActionForSix
call OpenBmpChocolateInBoard
mov al,[ChocolateType]
mov [BoardButtonFive],al
jmp NextChocolates

ActionForSix:
cmp [ButtonThatClicked],6
jne ActionForSeven
call OpenBmpChocolateInBoard
mov al,[ChocolateType]
mov [BoardButtonSix],al
jmp NextChocolates

ActionForSeven:
cmp [ButtonThatClicked],7
jne ActionForEight
call OpenBmpChocolateInBoard
mov al,[ChocolateType]
mov [BoardButtonSeven],al
call ChocolatesButtons
jmp NextChocolates

ActionForEight:
cmp [ButtonThatClicked],8
jne ActionForNine
call OpenBmpChocolateInBoard
mov al,[ChocolateType]
mov [BoardButtonEight],al
jmp NextChocolates

ActionForNine:
cmp [ButtonThatClicked],9
jne NextChocolates
call OpenBmpChocolateInBoard
mov al,[ChocolateType]
mov [BoardButtonNine],al
jmp NextChocolates

;next turn after he placed chocolate in place
NextChocolates:
call ChocolatesButtons

endp BoardButtonsActions
;///////////////////////////////////////////////// Game Page Buttons Actions //////////////////////////////////////////////////////////

;///////////////////////////////////////////////// Guess Page /////////////////////////////////////////////////////////////////////////
;check what level he played (eazy = 1, medium = 2, hard = 3)
proc CheckTheGuesses
mov [printAdd],0
;if the level is easy
cmp [LevelTypeChoosen],1
jne MediumCheck
call CheckEazyLevel

;if the level is medium
MediumCheck:
cmp [LevelTypeChoosen],2
jne HardCheck
call CheckMediumLevel

;if the level is hard
HardCheck:
cmp [LevelTypeChoosen],3
jne Neither
call CheckHardLevel

Neither:

endp CheckTheGuesses

;check if he guessed true in the eazy level
proc CheckEazyLevel
;if he play in level eazy 1 (1) check answer
cmp [LevelCount],1
jne EazyLevel2Check

cmp [BoardButtonOne],5 ;pink Square
jne NotTrue1
cmp [BoardButtonTwo],3 ;YellowCircle
jne NotTrue1
cmp [BoardButtonThree],8 ;PinkTriangle
jne NotTrue1
cmp [BoardButtonFour],6 ;YellowSquare
jne NotTrue1
cmp [BoardButtonFive],1 ;BrownCircle
jne NotTrue1
cmp[BoardButtonSix],9 ;YellowTriangle
jne NotTrue1
cmp[BoardButtonSeven],2 ;PinkCircle
jne NotTrue1
cmp[BoardButtonEight],7 ;BrownTriangle
jne NotTrue1
cmp[BoardButtonNine],4 ;BrownSquare
jne NotTrue1
call OpenTrueGuess
NotTrue1:
call OpenWrongGuess
;if he play in level eazy 2 (2)
EazyLevel2Check:
cmp [LevelCount],2
jne EazyLevel3Check

cmp [BoardButtonOne],4 ;BrownSquare
jne NotTrue2
cmp [BoardButtonTwo],1 ;BrownCircle
jne NotTrue2
cmp [BoardButtonThree],9 ;YellowTriangle
jne NotTrue2
cmp [BoardButtonFour],5 ;pink Square
jne NotTrue2
cmp [BoardButtonFive],8 ;PinkTriangle 
jne NotTrue2
cmp[BoardButtonSix],7 ;BrownTriangle
jne NotTrue2
cmp[BoardButtonSeven],6 ;YellowSquare 
jne NotTrue2
cmp[BoardButtonEight],2 ;PinkCircle 
jne NotTrue2
cmp[BoardButtonNine],3 ;YellowCircle
jne NotTrue2
call OpenTrueGuess
NotTrue2:
call OpenWrongGuess
;if he play in level eazy 3 (3) check answer
EazyLevel3Check:
cmp [BoardButtonOne],9 ;YellowTriangle
jne NotTrue3
cmp [BoardButtonTwo],6 ;YellowSquare
jne NotTrue3
cmp [BoardButtonThree],5 ;pink Square
jne NotTrue3
cmp [BoardButtonFour],3 ;YellowCircle
jne NotTrue3
cmp [BoardButtonFive],4 ;BrownSquare
jne NotTrue3
cmp[BoardButtonSix],1 ;BrownCircle
jne NotTrue3
cmp[BoardButtonSeven],8 ;PinkTriangle
jne NotTrue3
cmp[BoardButtonEight],7 ;BrownTriangle
jne NotTrue3
cmp[BoardButtonNine],2 ;PinkCircle
jne NotTrue3
call OpenTrueGuess
NotTrue3:
call OpenWrongGuess

endp CheckEazyLevel

;check if he guessed true in the medium level
proc CheckMediumLevel
;if he play in level medium 1 (4) check answer
cmp [LevelCount],4
jne CheckMediumLevel2

cmp [BoardButtonOne],6 ;YellowSquare
jne MediumNotTrue1
cmp [BoardButtonTwo],2 ;PinkCircle
jne MediumNotTrue1
cmp [BoardButtonThree],1 ;BrownCircle
jne MediumNotTrue1
cmp [BoardButtonFour],7 ;BrownTriangle
jne MediumNotTrue1
cmp [BoardButtonFive],8 ;PinkTriangle
jne MediumNotTrue1
cmp[BoardButtonSix],4 ;BrownSquare
jne MediumNotTrue1
cmp[BoardButtonSeven],9 ;YellowTriangle
jne MediumNotTrue1
cmp[BoardButtonEight],5 ;pink Square
jne MediumNotTrue1
cmp[BoardButtonNine],3 ;YellowCircle
jne MediumNotTrue1
call OpenTrueGuess
MediumNotTrue1:
call OpenWrongGuess

;if he play in level medium 2 (5) check answer
CheckMediumLevel2:
cmp [LevelCount],5
jne CheckMediumLevel3

cmp [BoardButtonOne],4 ;BrownSquare
jne MediumNotTrue2
cmp [BoardButtonTwo],2 ;PinkCircle
jne MediumNotTrue2
cmp [BoardButtonThree],5 ;pink Square
jne MediumNotTrue2
cmp [BoardButtonFour],3 ;YellowCircle
jne MediumNotTrue2
cmp [BoardButtonFive],8 ;PinkTriangle
jne MediumNotTrue2
cmp[BoardButtonSix],1 ;BrownCircle
jne MediumNotTrue2
cmp[BoardButtonSeven],7 ;BrownTriangle
jne MediumNotTrue2
cmp[BoardButtonEight],6 ;YellowSquare
jne MediumNotTrue2
cmp[BoardButtonNine],9 ;YellowTriangle
jne MediumNotTrue2
call OpenTrueGuess
MediumNotTrue2:
call OpenWrongGuess

;if he play in level medium 3 (6) check answer
CheckMediumLevel3:
cmp [BoardButtonOne],9 ;YellowTriangle
jne MediumNotTrue3
cmp [BoardButtonTwo],2 ;PinkCircle
jne MediumNotTrue3
cmp [BoardButtonThree],8 ;PinkTriangle
jne MediumNotTrue3
cmp [BoardButtonFour],4 ;BrownSquare
jne MediumNotTrue3
cmp [BoardButtonFive],6 ;YellowSquare
jne MediumNotTrue3
cmp[BoardButtonSix],7 ;BrownTriangle
jne MediumNotTrue3
cmp[BoardButtonSeven],5 ;pink Square
jne MediumNotTrue3
cmp[BoardButtonEight],3 ;YellowCircle
jne MediumNotTrue3
cmp[BoardButtonNine],1 ;BrownCircle
jne MediumNotTrue3
call OpenTrueGuess
MediumNotTrue3:
call OpenWrongGuess

endp CheckMediumLevel

;check if he guessed true in the hard level
proc CheckHardLevel
;if he play in level hard 1 (7) check answer
cmp [LevelCount],7
jne CheckHardLevel2

cmp [BoardButtonOne],6 ;YellowSquare
jne HardNotTrue1
cmp [BoardButtonTwo],8 ;PinkTriangle
jne HardNotTrue1
cmp [BoardButtonThree],9 ;YellowTriangle
jne HardNotTrue1
cmp [BoardButtonFour],1 ;BrownCircle
jne HardNotTrue1
cmp [BoardButtonFive],5 ;pink Square
jne HardNotTrue1
cmp[BoardButtonSix],7 ;BrownTriangle
jne HardNotTrue1
cmp[BoardButtonSeven],3 ;YellowCircle
jne HardNotTrue1
cmp[BoardButtonEight],2 ;PinkCircle
jne HardNotTrue1
cmp[BoardButtonNine],4 ;BrownSquare
jne HardNotTrue1
call OpenTrueGuess
HardNotTrue1:
call OpenWrongGuess

CheckHardLevel2:
;if he play in level hard 2 (8) check answer
cmp [LevelCount],8
jne CheckHardLevel3

cmp [BoardButtonOne],1 ;BrownCircle
jne HardNotTrue2
cmp [BoardButtonTwo],4 ;BrownSquare
jne HardNotTrue2
cmp [BoardButtonThree],8 ;PinkTriangle
jne HardNotTrue2
cmp [BoardButtonFour],5 ;pink Square
jne HardNotTrue2
cmp [BoardButtonFive],9 ;YellowTriangle
jne HardNotTrue2
cmp[BoardButtonSix],6 ;YellowSquare
jne HardNotTrue2
cmp[BoardButtonSeven],2 ;PinkCircle
jne HardNotTrue2
cmp[BoardButtonEight],7 ;BrownTriangle
jne HardNotTrue2
cmp[BoardButtonNine],3 ;YellowCircle
jne HardNotTrue2
call OpenTrueGuess
HardNotTrue2:
call OpenWrongGuess

CheckHardLevel3:
;if he play in level hard 3 (9) check answer
cmp [BoardButtonOne],9 ;YellowTriangle
jne HardNotTrue3
cmp [BoardButtonTwo],6 ;YellowSquare
jne HardNotTrue3
cmp [BoardButtonThree],8 ;PinkTriangle
jne HardNotTrue3
cmp [BoardButtonFour],2 ;PinkCircle
jne HardNotTrue3
cmp [BoardButtonFive],1 ;BrownCircle
jne HardNotTrue3
cmp[BoardButtonSix],5 ;pink Square
jne HardNotTrue3
cmp[BoardButtonSeven],4 ;BrownSquare
jne HardNotTrue3
cmp[BoardButtonEight],3 ;YellowCircle
jne HardNotTrue3
cmp[BoardButtonNine],7 ;BrownTriangle
jne HardNotTrue3
call OpenTrueGuess
HardNotTrue3:
call OpenWrongGuess
endp CheckHardLevel
;open true answer page
proc OpenTrueGuess
; don't show mouse
    mov ax, 0h
    int 33h
    call CloseFile
    mov [imgHeight],200
	mov [imgWidth],320
	mov ax, offset RightGuess
	mov [printAdd],0
	call PrintBmp
	call GuessPageButtons
endp OpenTrueGuess

;open wrong answer page
proc OpenWrongGuess
; don't show mouse
    mov ax, 0h
    int 33h
    call CloseFile
	mov [imgHeight],200
	mov [imgWidth],320
	mov ax, offset WrongGuess
	mov [printAdd],0
	call PrintBmp
	call GuessPageButtons
endp OpenWrongGuess

;open the exit page (thank you gor playing)
proc OpenThanksBmp 
; don't show mouse
    mov ax, 2h
    int 33h
    call CloseFile
	mov ax, offset ThanksForPlaying
	mov [printAdd], 0
	call PrintBmp
	call ExitGame
endp OpenThanksBmp

; home page buttons check
proc GuessPageButtons
;Show mouse
mov ax,1h
int 33h
;loop until button clicked
GuessMouseLP :
mov ax,0003h
int 33h
;adjust the mouse place to graphic mode
shr cx, 1
;check if he left clicked
cmp bx,01h
jne GuessMouseLP

;check if the player wants to exit the game
;ExitButton:
cmp cx,12
jl PlayAgainButton
cmp cx,132
jg PlayAgainButton
cmp dx,160
jl PlayAgainButton
cmp dx,193
jg PlayAgainButton
call OpenThanksBmp

;check if the player wnat to play again
PlayAgainButton:
cmp cx,187
jl GuessMouseLP
cmp cx,307
jg GuessMouseLP
cmp dx,160
jl GuessMouseLP
cmp dx,193
jg GuessMouseLP
;reset all the buttons keepers
mov [BoardButtonOne],0 
mov [BoardButtonTwo],0 
mov [BoardButtonThree],0 
mov [BoardButtonFour],0 
mov [BoardButtonFive],0 
mov [BoardButtonSix],0 
mov [BoardButtonSeven],0 
mov [BoardButtonEight],0
mov [BoardButtonNine],0 
call HomeWindowBmp
endp GuessPageButtons
;///////////////////////////////////////////////// Guess Page ////////////////////////////////////////////////////////////////

;///////////////////////////////////////////////// Side Procs ////////////////////////////////////////////////////////////////
;make a delay of a second
proc WaitASecond
	mov ax, 40h
	mov es, ax
	mov ax, [es:6ch]
FirstTick:
	cmp ax, [es: 6ch]
	je FirstTick
	mov cx, 19
DelayLoop:
	mov ax, [es:6ch]
Tick:
	cmp ax, [es:6ch]
	je Tick
	loop DelayLoop
	ret
endp WaitASecond

;exit the game after 1 second
proc ExitGame
call WaitASecond
;text mode
mov ah, 0
mov al, 2
int 10h
;exit program
mov ax, 4C00h
int 21h
endp ExitGame

;switch to graphic mode
proc GraphicsMode
	push ax
	mov ax, 13h
	int 10h	
	pop ax
	ret
endp GraphicsMode

;///////////////////////////////////////////////// Side Procs ////////////////////////////////////////////////////////////////

start:	       
mov ax, @data
mov ds, ax	
	;switch to graphic mode
	call GraphicsMode
	;start the game
	call HomeWindowBmp
exit:
;exit program
	mov ax, 4c00h
	int 21h
END start