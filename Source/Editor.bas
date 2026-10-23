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

Option Base 0
Option _Explicit

' --------------------------
' Includes (declarations)
' --------------------------
'$IncludeOnce
'$Include:'Utils.bi'

' --------------------------
' Program constants
' --------------------------

' Screen dimensions
Dim Shared SCREEN_DIMS As Point
Point_Set SCREEN_DIMS, 320, 200
Dim Shared PALETTE_DIMS As Point
Point_Set PALETTE_DIMS, 32, 200

' Window scaling factor
Const SCALE% = 1

' Refresh rate
Const FPS% = 25

' Video modes
Const IMG_MODE_CGA$ = "cga"
Const IMG_MODE_MCGA$ = "mcga"
Const IMG_MODE_EGA$ = "ega"
Const IMG_MODE_HER$ = "her"
Const IMG_MODE_TI83$ = "ti83"
Dim Shared IMG_MODE As String
Let IMG_MODE$ = IMG_MODE_EGA$

' Colors
Const COLOR_BG& = _RGB32(128, 128, 128)

Const WALKING_SPEED# = 1
Const BLOCK_SIZE% = 11

Dim Shared PT_LEVEL_NB As Point

' --------------------------
' Other includes (declarations)
' --------------------------
'$Include:'Geometry.bi'
'$Include:'Ticker.bi'
'$Include:'Sprites.bi'
'$Include:'Sounds.bi'
'$Include:'Keyboard.bi'
'$Include:'Gameplay.bi'
'$Include:'Levels.bi'

' --------------------------
' Level data
' --------------------------
Const CURRENT_LEVEL% = 0

' Assets
'$Include:'Assets.bi'

' --------------------------
' Screen setup
' --------------------------
_AllowFullScreen _Off
Dim Shared MainScreen As Viewport, ImgBuffer As Viewport
Dim Shared LevelBuffer As Viewport, PaletteBuffer As Viewport
Viewport_Init ImgBuffer, SCREEN_DIMS, P_ORIGIN, P_ORIGIN, 1
Viewport_Init PaletteBuffer, PALETTE_DIMS, P_ORIGIN, P_ORIGIN, 1
Viewport_Init MainScreen, SCREEN_DIMS, P_ORIGIN, P_ORIGIN, SCALE%

Screen MainScreen.Buffer

Do
  _Limit FPS%
  DrawPalette
  DrawLevel
  Viewport_PutViewport ImgBuffer, TRUE, PaletteBuffer, P_ORIGIN, P_ORIGIN, PALETTE_DIMS
  Viewport_Copy ImgBuffer, MainScreen
  Viewport_Display MainScreen
Loop

Sub DrawPalette
  Viewport_Clear PaletteBuffer
  'Viewport_Line PaletteBuffer, TRUE, P_ORIGIN, PALETTE_DIMS, COLOR_BG&, TRUE, TRUE
  Viewport_LineC PaletteBuffer, TRUE, 0, 0, 32, 200, _RGB32(255, 0, 0), TRUE, TRUE
End Sub

Sub DrawLevel
End Sub
' --------------------------
' Includes (implementations)
' --------------------------
'$IncludeOnce
'$Include:'Utils.bm'
'$Include:'Geometry.bm'
'$Include:'Ticker.bm'
'$Include:'Sprites.bm'
'$Include:'Sounds.bm'
'$Include:'Keyboard.bm'
'$Include:'Levels.bm'
'$Include:'LevelMaps.bm'
'$Include:'Assets.bm'

' :mode=visualbasic:folding=explicit:wrap=none:


