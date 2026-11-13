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
Const LVL_ERASER = 15
Const LVL_HAND = 16
Const LVL_ROPE_M = 17
Const LVL_ROPE_E = 18
Const LVL_MARK = 19


Dim Shared ColorHighlight As Long, ColorHighlight2 As Long, ColorSnow As Long
If ImgMode$ = IMG_MODE_EGA Then
    Let ColorHighlight = COLOR_RED
    Let ColorHighlight2 = COLOR_YELLOW
    Let ColorSnow = COLOR_WHITE
ElseIf ImgMode$ = IMG_MODE_CGA Then
    Let ColorHighlight = COLOR_PINK
    Let ColorHighlight2 = COLOR_CYAN
    Let ColorSnow = COLOR_WHITE
ElseIf ImgMode$ = IMG_MODE_HER Then
    Let ColorHighlight = COLOR_BLACK
    Let ColorHighlight2 = COLOR_BLACK
    Let ColorSnow = COLOR_WHITE
ElseIf ImgMode$ = IMG_MODE_TI83 Then
    Let ColorHighlight = COLOR_BLACK
    Let ColorHighlight2 = COLOR_BLACK
    Let ColorSnow = COLOR_TI83
ElseIf ImgMode$ = IMG_MODE_MCGA Then
    Let ColorHighlight = COLOR_GREEN_HI
    Let ColorHighlight2 = COLOR_GREEN_MD
    Let ColorSnow = COLOR_GREEN_HI
End If

Dim Shared ImgDir As String, FntDir As String, SndDir As String
Let ImgDir$ = "/home/sylvain/Workspaces/dodu/Source/images/" + ImgMode$
Let FntDir$ = "/home/sylvain/Workspaces/dodu/Source/fonts"
Let SndDir$ = "/home/sylvain/Workspaces/dodu/Source/music"


Dim Shared FntTinyC As _Unsigned Long, FntGrape As _Unsigned Long
Let FntTinyC = _LoadFont(FntDir$ + "/TinyAndChunkyRegular.ttf", 5, "MONOSPACE DONTBLEND")
Let FntGrape = _LoadFont(FntDir$ + "/GrapeSoda.ttf", 10, "MONOSPACE DONTBLEND")

Dim DefaultOffset As Point
Let DefaultOffset = PtOrigin

'$Include:'assets/Player.bi'
'$Include:'assets/Level.bi'
'$Include:'assets/Cards.bi'
'$Include:'assets/Minimap.bi'
'$Include:'assets/Counter.bi'
'$Include:'assets/Sounds.bi'
'$Include:'assets/Backgrounds.bi'
'$Include:'assets/Fonts.bi'


' Splash screen
Dim Shared SplashScreen As SpriteSequence
If ScreenDims.x = SCREEN_GAMEBUINO_X Then
    SpriteSequence_InitFile SplashScreen, ImgDir$ + "/splash/Title.png",15, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
Else
    SpriteSequence_InitFile SplashScreen, ImgDir$ + "/splash/Title_160.png",15, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
End If

Dim Shared LifSplash As SpriteSequence
SpriteSequence_InitFile LifSplash, ImgDir$ + "/splash/LIF.png",24, 1, TRUE, FALSE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' ---------------------
' Cut scenes
' ---------------------
Dim Shared CutScenes(10) As SpriteSequence
SpriteSequence_InitFile CutScenes(0), ImgDir$ + "/cutscenes/Cutscene_0.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile CutScenes(1), ImgDir$ + "/cutscenes/Cutscene_1.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile CutScenes(2), ImgDir$ + "/cutscenes/Cutscene_2.png",4, 3, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile CutScenes(3), ImgDir$ + "/cutscenes/Cutscene_3.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' :mode=visualbasic: