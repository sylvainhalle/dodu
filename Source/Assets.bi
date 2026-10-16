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

' DependsOn: 'Sprites.bi'
' DependsOn: 'Sound.bi'

Const LVL_PLAYER = 0
Const LVL_BLOCK_B = 1
Const LVL_BLOCK_W = 2
Const LVL_POLE = 3
Const LVL_MITTENS = 4
Const LVL_TUQUE = 5
Const LVL_COFFEE = 6
Const LVL_COOKIE = 7
Const LVL_WATER = 8
Const LVL_SNOW = 9
Const LVL_SNOW_L = 10
Const LVL_SNOW_C = 11
Const LVL_SNOW_R = 12
Const LVL_SNOW_M = 13
Const LVL_THERMO = 14

Declare Sub DrawLevelNumber (v As Viewport)

Declare Sub DrawThermometer (v As Viewport)

Const COLOR_TRANSPARENT = _RGB32(52, 52, 52) ' Hex: 343434
Const COLOR_GREEN_HI = _RGB32(0, 255, 0)
Const COLOR_GREEN_MD = _RGB32(0, 170, 0)
Const COLOR_GREEN_LO = _RGB32(0, 85, 0)

Dim Shared COLOR_HIGHLIGHT As Long, COLOR_HIGHLIGHT2 As Long, COLOR_SNOW As Long
If IMG_MODE$ = IMG_MODE_EGA Then
	Let COLOR_HIGHLIGHT = COLOR_RED
	Let COLOR_HIGHLIGHT2 = COLOR_YELLOW
	Let COLOR_SNOW = COLOR_WHITE
ElseIf IMG_MODE$ = IMG_MODE_CGA Then
	Let COLOR_HIGHLIGHT = COLOR_PINK
	Let COLOR_HIGHLIGHT2 = COLOR_CYAN
	Let COLOR_SNOW = COLOR_WHITE
ElseIf IMG_MODE$ = IMG_MODE_HER Then
	Let COLOR_HIGHLIGHT = COLOR_BLACK
	Let COLOR_HIGHLIGHT2 = COLOR_BLACK
	Let COLOR_SNOW = COLOR_WHITE
ElseIf IMG_MODE$ = IMG_MODE_MCGA Then
	Let COLOR_HIGHLIGHT = COLOR_GREEN_HI
	Let COLOR_HIGHLIGHT2 = COLOR_GREEN_MD
	Let COLOR_SNOW = COLOR_GREEN_HI
End If

Dim Shared IMG_DIR As String, FNT_DIR As String, SND_DIR As String
Let IMG_DIR$ = "/home/sylvain/Workspaces/dodu/Source/images/" + IMG_MODE$
Let FNT_DIR$ = "/home/sylvain/Workspaces/dodu/Source/fonts"
Let SND_DIR$ = "/home/sylvain/Workspaces/dodu/Source/music"


Dim Shared FNT_TINYC As _Unsigned Long, FNT_GRAPE As _Unsigned Long
Let FNT_TINYC = _LoadFont(FNT_DIR$ + "/TinyAndChunkyRegular.ttf", 5, "MONOSPACE DONTBLEND")
Let FNT_GRAPE = _LoadFont(FNT_DIR$ + "/GrapeSoda.ttf", 10, "MONOSPACE DONTBLEND")

Dim DEFAULT_OFFSET As Point
Let DEFAULT_OFFSET = P_ORIGIN

'$Include:'assets/Player.bi'
'$Include:'assets/Level.bi'
'$Include:'assets/Cards.bi'
'$Include:'assets/Minimap.bi'
'$Include:'assets/Counter.bi'
'$Include:'assets/Sounds.bi'
'$Include:'assets/Backgrounds.bi'

' Splash screen
Dim Shared SplashScreen As SpriteSequence
SpriteSequence_InitFile SplashScreen, IMG_DIR$ + "/splash/Title.png",15, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

Dim Shared LifSplash As SpriteSequence
SpriteSequence_InitFile LifSplash, IMG_DIR$ + "/splash/LIF.png",24, 1, TRUE, FALSE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' ---------------------
' Cut scenes
' ---------------------
Dim Shared CutScenes(10) As SpriteSequence
SpriteSequence_InitFile CutScenes(0), IMG_DIR$ + "/cutscenes/Cutscene_0.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile CutScenes(1), IMG_DIR$ + "/cutscenes/Cutscene_1.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile CutScenes(2), IMG_DIR$ + "/cutscenes/Cutscene_2.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' :mode=visualbasic: