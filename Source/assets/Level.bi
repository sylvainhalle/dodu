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

Dim Shared SprLevel(24) As SpriteSequence
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

'**
'* Draws the thermometer showing the player's temperature on the given
'* layer. The mercury flashes blue and red when the temperature is 2 or less.
'**
Declare Sub DrawThermometer (v As Viewport, layer As Integer)

' Blocks
SpriteSequence_InitFile SprLevel(LVL_BLOCK_B), ImgDir$ + "/level/BlockBlue.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_BLOCK_W), ImgDir$ + "/level/BlockWhite.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_WATER), ImgDir$ + "/level/Water.png",11, 3, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
Dim Coffset As Point, Moffset As Point
Point_Set Coffset, 0, -11

SpriteSequence_InitFile SprLevel(LVL_SNOW_C), ImgDir$ + "/level/Snow_C.png",7, 2, TRUE, TRUE, Coffset, Coffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_SNOW_L), ImgDir$ + "/level/Snow_L.png",6, 2, TRUE, TRUE, Coffset, Coffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_SNOW_R), ImgDir$ + "/level/Snow_R.png",6, 2, TRUE, TRUE, Coffset, Coffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_SNOW_M), ImgDir$ + "/level/Snow_M.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_ROPE_M), ImgDir$ + "/level/Rope_M.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_ROPE_E), ImgDir$ + "/level/Rope_E.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_ROPE_H), ImgDir$ + "/level/Rope_H.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

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

' Hook (item)
Dim SprHookOffset As Point
Point_Set SprHookOffset, 0, -3
SpriteSequence_InitFile SprLevel(LVL_HOOK_ITEM), ImgDir$ + "/level/Hook_Item.png",1, 1, TRUE, TRUE, SprHookOffset, SprHookOffset, COLOR_TRANSPARENT

' Hook on ice block
Dim SprBlockHookOffset As Point, SprBlockHookOffsetRev As Point
Point_Set SprBlockHookOffset, 0, -5
Point_Set SprBlockHookOffsetRev, 0, -5
SpriteSequence_InitFile SprLevel(LVL_BLOCK_HOOK_L), ImgDir$ + "/level/BlockBlue_hook_L.png",1, 1, TRUE, TRUE, SprBlockHookOffset, SprBlockHookOffsetRev, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLevel(LVL_BLOCK_HOOK_R), ImgDir$ + "/level/BlockBlue_hook_R.png",1, 1, TRUE, TRUE, SprBlockHookOffset, SprBlockHookOffsetRev, COLOR_TRANSPARENT

' Ropes
Dim Shared SprThrownRope(3) As SpriteSequence
Dim SprRopeOffset1 As Point, SprRopeOffset1Rev As Point
Dim SprRopeOffset2 As Point, SprRopeOffset2Rev As Point
Dim SprRopeOffset3 As Point, SprRopeOffset3Rev As Point
Point_Set SprRopeOffset1, -27, -33
Point_Set SprRopeOffset1Rev, -6, -33
Point_Set SprRopeOffset2, -38, -33
Point_Set SprRopeOffset2Rev, -6, -33
Point_Set SprRopeOffset3, -49, -33
Point_Set SprRopeOffset3Rev, -6, -33
SpriteSequence_InitFile SprThrownRope(0), ImgDir$ + "/level/Hook_Thrown_1.png",20, 1, TRUE, FALSE, SprRopeOffset1, SprRopeOffset1Rev, COLOR_TRANSPARENT
SpriteSequence_InitFile SprThrownRope(1), ImgDir$ + "/level/Hook_Thrown_2.png",20, 1, TRUE, FALSE, SprRopeOffset2, SprRopeOffset2Rev, COLOR_TRANSPARENT
SpriteSequence_InitFile SprThrownRope(2), ImgDir$ + "/level/Hook_Thrown_3.png",20, 1, TRUE, FALSE, SprRopeOffset3, SprRopeOffset3Rev, COLOR_TRANSPARENT

' Coordinate 1 = length of rope - 1
' Coordinate 2 = pulled from the hook or the other end
Dim Shared SprPulledRope(3, 2) As SpriteSequence
Dim SprPullOffset1 As Point, SprPullOffset1Rev As Point
Dim SprPullOffset2 As Point, SprPullOffset2Rev As Point
Dim SprPullOffset3 As Point, SprPullOffset3Rev As Point
Point_Set SprPullOffset1, -6, -33
Point_Set SprPullOffset1Rev, -27, -33
Point_Set SprPullOffset2, -6, -33
Point_Set SprPullOffset2Rev, -38, -33
Point_Set SprPullOffset3, -6, -33
Point_Set SprPullOffset3Rev, -44, -33
SpriteSequence_InitFile SprPulledRope(0, 0), ImgDir$ + "/level/NoHook_Retrieved_2.png",6, 4, TRUE, FALSE, SprPullOffset1, SprPullOffset1Rev, COLOR_TRANSPARENT
SpriteSequence_InitFile SprPulledRope(0, 1), ImgDir$ + "/level/Hook_Retrieved_2.png",6, 4, TRUE, FALSE, SprPullOffset1Rev, SprPullOffset1, COLOR_TRANSPARENT
SpriteSequence_InitFile SprPulledRope(1, 0), ImgDir$ + "/level/NoHook_Retrieved_2.png",6, 4, TRUE, FALSE, SprPullOffset2, SprPullOffset2Rev, COLOR_TRANSPARENT
SpriteSequence_InitFile SprPulledRope(1, 1), ImgDir$ + "/level/Hook_Retrieved_2.png",6, 4, TRUE, FALSE, SprPullOffset2Rev, SprPullOffset2, COLOR_TRANSPARENT
SpriteSequence_InitFile SprPulledRope(2, 0), ImgDir$ + "/level/NoHook_Retrieved_3.png",6, 4, TRUE, FALSE, SprPullOffset3, SprPullOffset3Rev, COLOR_TRANSPARENT
SpriteSequence_InitFile SprPulledRope(2, 1), ImgDir$ + "/level/Hook_Retrieved_3.png",6, 4, TRUE, FALSE, SprPullOffset3Rev, SprPullOffset3, COLOR_TRANSPARENT

' Thermometer colors
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