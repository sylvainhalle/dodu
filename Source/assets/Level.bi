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

Const LAYER_THERMO% = 2

Dim Shared SprLevel(20) As SpriteSequence
Dim Shared CFG_NEIGHBORS As Integer
Let CFG_NEIGHBORS = FALSE

' --------------------------
' Depth settings
' --------------------------
Const IMG_DEPTH% = 4
Const DEPTH_BACKGROUND% = 0
Const DEPTH_POLE% = 1
Const DEPTH_ROPE% = 1
Const DEPTH_WATER% = 1
Const DEPTH_PLAYER% = 2
Const DEPTH_LEVEL% = 2
Const DEPTH_CARDS% = 2
Const DEPTH_MARK% = 2
Const DEPTH_SNOW_BACK% = 1
Const DEPTH_SNOW_FRONT% = 3
Const DEPTH_CONTROLS% = 3

Declare Sub PrepareLevel (m As LevelMap, isfront As Integer)
Declare Sub DrawLevel (v As Viewport, m As LevelMap, isfront As Integer)
Declare Sub SetSpriteSquare (m As LevelMap, isfront As Integer, col As Integer, row As Integer, e As String)
Declare Sub ClearSpriteSquare (s As Square)
Declare Sub PrepareRope (m As LevelMap, col As Integer, row As Integer)
Declare Sub PrepareSnow (m As LevelMap, col As Integer, row As Integer, hasrackets As Integer)
Declare Sub DrawPlayer (v As Viewport, seqs() As SpriteSequence)
Declare Sub DrawMinimap (v As Viewport, m As LevelMap)
Declare Sub HighlightBlock (v As Viewport, m As LevelMap, s As Square, c~&)
Declare Sub DropBlock (m As LevelMap, p As Square)
Declare Sub SelectSnowSprite (m As LevelMap, col As Integer, row As Integer, hasrackets As Integer)

' Blocks
SpriteSequence_InitFile SprLevel(LVL_BLOCK_B), ImgDir$ + "/level/BlockBlue.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_BLOCK_W), ImgDir$ + "/level/BlockWhite.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_WATER), ImgDir$ + "/level/Water.png",11, 3, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
Dim Coffset As Point
Point_Set Coffset, 0, -11
SpriteSequence_InitFile SprLevel(LVL_SNOW_C), ImgDir$ + "/level/Snow_C.png",7, 2, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_SNOW_L), ImgDir$ + "/level/Snow_L.png",6, 2, TRUE, TRUE, Coffset, Coffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_SNOW_R), ImgDir$ + "/level/Snow_R.png",6, 2, TRUE, TRUE, Coffset, Coffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_SNOW_M), ImgDir$ + "/level/Snow_M.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_ROPE_M), ImgDir$ + "/level/Rope_M.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_ROPE_E), ImgDir$ + "/level/Rope_E.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' Goal post
Dim PoleOffset As Point, PoleOffsetFlip As Point
Point_Set PoleOffset, 1, -9
Point_Set PoleOffsetFlip, -1, -9
SpriteSequence_InitFile SprLevel(LVL_POLE), ImgDir$ + "/level/Pole.png",5, 3, TRUE, TRUE, PoleOffset, PoleOffsetFlip, COLOR_TRANSPARENT

' Cookie
Dim CookieOffset As Point
Point_Set CookieOffset, 2, 2
SpriteSequence_InitFile SprLevel(LVL_COOKIE), ImgDir$ + "/level/Cookie.png",8, 3, TRUE, TRUE, CookieOffset, CookieOffset, COLOR_TRANSPARENT

' Coffee
Dim Shared Coffee As SpriteSequence
Dim CoffeeOffset As Point
Point_Set CoffeeOffset, 1, 1
SpriteSequence_InitFile SprLevel(LVL_COFFEE), ImgDir$ + "/level/Coffee.png",4, 3, TRUE, TRUE, CoffeeOffset, CoffeeOffset, COLOR_TRANSPARENT

' Mittens
Dim Shared SprMittens As SpriteSequence
Dim SprMittensOffset As Point
Point_Set SprMittensOffset, -2, 2
SpriteSequence_InitFile SprLevel(LVL_MITTENS), ImgDir$ + "/level/Mittens.png",1, 1, TRUE, TRUE, SprMittensOffset, SprMittensOffset, COLOR_TRANSPARENT

' Tuque
Dim Shared SprTuque As SpriteSequence
Dim SprTuqueOffset As Point
Point_Set SprTuqueOffset, 1, -3
SpriteSequence_InitFile SprLevel(LVL_TUQUE), ImgDir$ + "/level/Tuque.png",1, 1, TRUE, TRUE, SprTuqueOffset, SprTuqueOffset, COLOR_TRANSPARENT

' Thermometer
SpriteSequence_InitFile SprLevel(LVL_THERMO), ImgDir$ + "/level/Thermometer.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' Mark
SpriteSequence_InitFile SprLevel(LVL_MARK), ImgDir$ + "/level/Mark.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT


Dim Shared ThermoRed&, ThermoBlue&, HighlightColor&
If ImgMode = IMG_MODE_CGA Then
    Let ThermoRed& = COLOR_PINK
    Let ThermoBlue& = COLOR_BLACK
    Let HighlightColor& = COLOR_BLACK
ElseIf ImgMode = IMG_MODE_EGA Then
    Let ThermoRed& = _RGB32(170, 0, 0)
    Let ThermoBlue& = _RGB32(85, 0, 170)
    Let HighlightColor& = COLOR_YELLOW
Else
    Let ThermoRed& = COLOR_BLACK
    Let ThermoBlue& = COLOR_BLACK
    Let HighlightColor& = COLOR_BLACK
End If

' :mode=visualbasic: