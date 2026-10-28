'-----------------------------------------------------------------------------
'    Dodu, an old-school QuickBasic game
'    Copyright (C) 1994-2026  Sylvain Hallé
'
'    This program is free software: you can redistribute it and/or modify
'    it under the terms of the GNU General Public License as published by
'    the Free Software Foundation, either version 3 of the License, or
'    (at your option) any later version.
'
'    This program is distributed in the hope that it will be useful,
'    but WITHOUT ANY WARRANTY; without even the implied warranty of
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'    GNU General Public License for more details.
'
'    You should have received a copy of the GNU General Public License
'    along with this program.  If not, see <https://www.gnu.org/licenses/>.
'-----------------------------------------------------------------------------

Dim Shared SPR_LEVEL(15) As SpriteSequence

' Blocks
SpriteSequence_InitFile SPR_LEVEL(LVL_BLOCK_B), IMG_DIR$ + "/level/BlockBlue.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LEVEL(LVL_BLOCK_W), IMG_DIR$ + "/level/BlockWhite.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LEVEL(LVL_WATER), IMG_DIR$ + "/level/Water.png",11, 3, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
Dim Coffset As Point
Point_Set Coffset, 0, -14
SpriteSequence_InitFile SPR_LEVEL(LVL_SNOW_C), IMG_DIR$ + "/level/Snow_C.png",7, 2, TRUE, TRUE, Coffset, Coffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LEVEL(LVL_SNOW_L), IMG_DIR$ + "/level/Snow_L.png",6, 2, TRUE, TRUE, Coffset, Coffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LEVEL(LVL_SNOW_R), IMG_DIR$ + "/level/Snow_R.png",6, 2, TRUE, TRUE, Coffset, Coffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LEVEL(LVL_SNOW_M), IMG_DIR$ + "/level/Snow_M.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Goal post
Dim PoleOffset As Point, PoleOffsetFlip As Point
Point_Set PoleOffset, 1, -9
Point_Set PoleOffsetFlip, -1, -9
SpriteSequence_InitFile SPR_LEVEL(LVL_POLE), IMG_DIR$ + "/level/Pole.png",5, 3, TRUE, TRUE, PoleOffset, PoleOffsetFlip, COLOR_TRANSPARENT

' Cookie
Dim CookieOffset As Point
Point_Set CookieOffset, 2, 2
SpriteSequence_InitFile SPR_LEVEL(LVL_COOKIE), IMG_DIR$ + "/level/Cookie.png",8, 3, TRUE, TRUE, CookieOffset, CookieOffset, COLOR_TRANSPARENT

' Coffee
Dim Shared Coffee As SpriteSequence
Dim CoffeeOffset As Point
Point_Set CoffeeOffset, 1, 1
SpriteSequence_InitFile SPR_LEVEL(LVL_COFFEE), IMG_DIR$ + "/level/Coffee.png",4, 3, TRUE, TRUE, CoffeeOffset, CoffeeOffset, COLOR_TRANSPARENT

' Mittens
Dim Shared SprMittens As SpriteSequence
Dim SprMittensOffset As Point
Point_Set SprMittensOffset, -2, 2
SpriteSequence_InitFile SPR_LEVEL(LVL_MITTENS), IMG_DIR$ + "/level/Mittens.png",1, 1, TRUE, TRUE, SprMittensOffset, SprMittensOffset, COLOR_TRANSPARENT

' Tuque
Dim Shared SprTuque As SpriteSequence
Dim SprTuqueOffset As Point
Point_Set SprTuqueOffset, 1, -3
SpriteSequence_InitFile SPR_LEVEL(LVL_TUQUE), IMG_DIR$ + "/level/Tuque.png",1, 1, TRUE, TRUE, SprTuqueOffset, SprTuqueOffset, COLOR_TRANSPARENT

' Thermometer
Dim Shared Thermometer As SpriteSequence
SpriteSequence_InitFile SPR_LEVEL(LVL_THERMO), IMG_DIR$ + "/level/Thermometer.png",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

Dim Shared THERMO_RED&, THERMO_BLUE&, HIGHLIGHT_COLOR&
If IMG_MODE = IMG_MODE_CGA$ Then
	Let THERMO_RED& = COLOR_PINK&
	Let THERMO_BLUE& = COLOR_BLACK&
	Let HIGHLIGHT_COLOR& = COLOR_BLACK&
ElseIf IMG_MODE = IMG_MODE_EGA$ Then
	Let THERMO_RED& = _RGB32(170, 0, 0)
	Let THERMO_BLUE& = _RGB32(85, 0, 170)
	Let HIGHLIGHT_COLOR& = COLOR_YELLOW&
Else
	Let THERMO_RED& = COLOR_BLACK%
	Let THERMO_BLUE& = COLOR_BLACK%
	Let HIGHLIGHT_COLOR& = COLOR_BLACK&
End If

' :mode=visualbasic: