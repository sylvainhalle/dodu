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
' Block dimensions
Const BLOCK_SIZE% = 11

' Screen dimensions
Dim Shared SCREEN_DIMS As Point
Point_Set SCREEN_DIMS, 320, 200
Dim Shared LEVEL_DIMS As Point
Point_Set LEVEL_DIMS, 288, 200
Dim Shared LEVEL_TOPLEFT As Point
Point_Set LEVEL_TOPLEFT, 32, 0
Dim Shared PALETTE_DIMS As Point
Point_Set PALETTE_DIMS, 32, 200
Const PALETTE_BTN_SIZE = 6
Dim Shared P_COORDS1 As Point, P_COORDS2 As Point
Point_Set P_COORDS1, 3, 188
Point_Set P_COORDS2, 19, 188

' World size
Dim Shared WORLD_SIZE As Point
Point_Set WORLD_SIZE, 30 * BLOCK_SIZE%, 30 * BLOCK_SIZE%

' Window scaling factor
Const SCALE% = 3

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
Const COLOR_BTN& = _RGB32(192, 192, 192)
Const COLOR_GRID& = _RGB32(64, 64, 64)
Const COLOR_CURSOR& = _RGB32(255, 255, 0)

Const WALKING_SPEED# = 1

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

Dim Shared PALETTE_BUTTONS(16) As Integer
Let PALETTE_BUTTONS(0) = LVL_HAND
Let PALETTE_BUTTONS(1) = LVL_ERASER
Let PALETTE_BUTTONS(2) = LVL_PLAYER
Let PALETTE_BUTTONS(3) = LVL_BLOCK_B
Let PALETTE_BUTTONS(4) = LVL_BLOCK_W
Let PALETTE_BUTTONS(5) = LVL_POLE
Let PALETTE_BUTTONS(6) = LVL_MITTENS
Let PALETTE_BUTTONS(7) = LVL_TUQUE
Let PALETTE_BUTTONS(8) = LVL_COFFEE
Let PALETTE_BUTTONS(9) = LVL_COOKIE
Let PALETTE_BUTTONS(10) = LVL_WATER
Let PALETTE_BUTTONS(11) = LVL_SNOW

Dim Shared PALETTE_SHORTCUTS(16) As String
Let PALETTE_SHORTCUTS(0) = "H"
Let PALETTE_SHORTCUTS(1) = " "
Let PALETTE_SHORTCUTS(2) = "*"
Let PALETTE_SHORTCUTS(3) = "@"
Let PALETTE_SHORTCUTS(4) = "#"
Let PALETTE_SHORTCUTS(5) = "!"
Let PALETTE_SHORTCUTS(6) = "m"
Let PALETTE_SHORTCUTS(7) = "t"
Let PALETTE_SHORTCUTS(8) = "f"
Let PALETTE_SHORTCUTS(9) = "c"
Let PALETTE_SHORTCUTS(10) = "~"
Let PALETTE_SHORTCUTS(11) = "S"

Dim Shared LVL_SPRITES(30, 30) As SpriteSequence
Dim Shared SPRITE_LEVEL(2, 30, 30) As SpriteSequence
ResetLevelSprites

' --------------------------
' Screen setup
' --------------------------
_AllowFullScreen _Off

Dim Shared CurrentSquare As Square
Dim Shared MainScreen As Viewport, ImgBuffer As Viewport
Dim Shared LevelBuffer As Viewport, PaletteBuffer As Viewport
Viewport_Init ImgBuffer, SCREEN_DIMS, SCREEN_DIMS, P_ORIGIN, 1
Viewport_Init PaletteBuffer, PALETTE_DIMS, PALETTE_DIMS, P_ORIGIN, 1
Viewport_Init LevelBuffer, LEVEL_DIMS, WORLD_SIZE, P_ORIGIN, 1
Viewport_Init MainScreen, SCREEN_DIMS, P_ORIGIN, P_ORIGIN, SCALE%

Screen MainScreen.Buffer

' State variables
Dim keyb As Integer
Dim Shared selection As Integer
Let selection = 3
Do
  _Limit FPS%
  DrawPalette
  DrawLevel
  Viewport_PutViewport ImgBuffer, TRUE, PaletteBuffer, P_ORIGIN, P_ORIGIN, PALETTE_DIMS
  Viewport_PutViewport ImgBuffer, TRUE, LevelBuffer, LEVEL_TOPLEFT, P_ORIGIN, LEVEL_DIMS
  'Viewport_Print ImgBuffer, Levels(CURRENT_LEVEL).Topo(CurrentSquare.col, CurrentSquare.row), P_ORIGIN
  Viewport_Copy ImgBuffer, MainScreen
  _PrintString (1, 1), Levels(CURRENT_LEVEL).Topo(CurrentSquare.col, CurrentSquare.row), MainScreen.Buffer
  _PrintString (1, 16), PALETTE_SHORTCUTS(selection), MainScreen.Buffer
  Viewport_Display MainScreen

  If keyb Then
    Kbd_WaitRelease FPS%
    Let keyb = FALSE
  End If

  If IsEsc% Then
    End
  End If

  If IsLeft% Then
    Let keyb = TRUE
    If CurrentSquare.col > 0 Then
      Let CurrentSquare.col = CurrentSquare.col - 1
    End If
  End If

  If IsRight% Then
    Let keyb = TRUE
    If CurrentSquare.col < 29 Then
      Let CurrentSquare.col = CurrentSquare.col + 1
    End If
  End If

  If IsUp% Then
    Let keyb = TRUE
    If CurrentSquare.row > 0 Then
      Let CurrentSquare.row = CurrentSquare.row - 1
    End If
  End If

  If IsDown% Then
    Let keyb = TRUE
    If CurrentSquare.row < 29 Then
      Let CurrentSquare.row = CurrentSquare.row + 1
    End If
  End If

  If IsEnter% Then
    Let keyb = TRUE
    ApplyToSquare
  End If

  ' Are we switching to a new selection?
  Dim i As Integer, khit As Long
  Let khit = _KeyHit
  For i = 0 To 11
    If khit = Asc(PALETTE_SHORTCUTS(i)) Or khit = Asc(LCase$(PALETTE_SHORTCUTS(i))) Then
      Dim s As Integer
      Let selection = i
      Exit For
    End If
  Next

Loop

Function IndexOf% (e As String)
  Dim i As Integer
  Let IndexOf% = -1
  For i = 0 To 11
    If PALETTE_SHORTCUTS(i) = e Then
      Let IndexOf% = i
      Exit Function
    End If
  Next
End Function

Sub ResetLevelSprites
  Dim col As Integer, row As Integer
  For col = 0 To 29
    For row = 0 To 29
      Let Levels(CURRENT_LEVEL%).Topo(col, row) = " "
    Next
  Next
End Sub

Sub ApplyToSquare
  Let Levels(CURRENT_LEVEL).Topo(CurrentSquare.col, CurrentSquare.row) = PALETTE_SHORTCUTS(selection)
  If PALETTE_SHORTCUTS(selection) = T_NOTHING Then
    ClearSpriteSquare CurrentSquare
  Else
    SetSpriteSquare Levels(CURRENT_LEVEL), FALSE, CurrentSquare.col, CurrentSquare.row, PALETTE_SHORTCUTS(selection)
  End If
End Sub



Sub DrawPalette
  Viewport_Clear PaletteBuffer
  Viewport_Line PaletteBuffer, TRUE, P_ORIGIN, PALETTE_DIMS, COLOR_BG&, TRUE, TRUE
  Dim p As Point, i As Integer, x As Integer, y As Integer
  'Buttons
  For i = 0 To 16
    Let x = 2 + (i Mod 2) * 10
    Let y = (i \ 2) * 10 + 10
    Viewport_LineC PaletteBuffer, TRUE, x, y, x + 7, y + 7, COLOR_BTN&, TRUE, TRUE
    Point_Set p, x + 1, y + 1
    Viewport_PutSpriteSequence PaletteBuffer, TRUE, SPR_MINIMAP(PALETTE_BUTTONS(i)), p, FALSE
    If i = selection Then
      Viewport_LineC PaletteBuffer, TRUE, x, y, x + 7, y + 7, COLOR_CURSOR&, TRUE, FALSE
    End If
  Next
  ' Coordinates
  DrawNumber PaletteBuffer, P_COORDS1, CurrentSquare.col
  DrawNumber PaletteBuffer, P_COORDS2, CurrentSquare.row
End Sub

Sub DrawLevel
  Viewport_Clear LevelBuffer
  Dim col As Integer, row As Integer
  For col = 0 To 29
    For row = 0 To 29
      Viewport_LineC LevelBuffer, FALSE, col * BLOCK_SIZE% - 1, row * BLOCK_SIZE%, col * BLOCK_SIZE% + 1, row * 11, COLOR_GRID&, FALSE, FALSE
      Viewport_LineC LevelBuffer, FALSE, col * BLOCK_SIZE%, row * BLOCK_SIZE% - 1, col * BLOCK_SIZE%, row * BLOCK_SIZE% + 1, COLOR_GRID&, FALSE, FALSE
    Next
  Next
  For row = 29 To 0 Step -1
    For col = 0 To 29
      Dim s As Square
      Let s.col = col
      Let s.row = row
      If SPRITE_LEVEL(FALSE, col, row).Content <> -1 Then
        Dim p As Point
        Square_ToPoint s, p
        Viewport_PutSpriteSequence LevelBuffer, FALSE, SPRITE_LEVEL(FALSE, col, row), p, FALSE
      End If
    Next
  Next
  Viewport_LineC LevelBuffer, FALSE, CurrentSquare.col * BLOCK_SIZE%, CurrentSquare.row * BLOCK_SIZE%, (CurrentSquare.col + 1) * BLOCK_SIZE% - 1, (CurrentSquare.row + 1) * BLOCK_SIZE% - 1, COLOR_CURSOR&, TRUE, FALSE
End Sub

Sub SetSpriteSquare (m As LevelMap, isfront As Integer, col As Integer, row As Integer, e As String)
  If Not isfront Then
    Select Case e
      Case T_BLOCK_B
        SpriteSequence_Copy SPRITE_LEVEL(Abs(isfront), col, row), SPR_LEVEL(LVL_BLOCK_B)
      Case T_BLOCK_W
        SpriteSequence_Copy SPRITE_LEVEL(Abs(isfront), col, row), SPR_LEVEL(LVL_BLOCK_W)
      Case T_POLE
        SpriteSequence_Copy SPRITE_LEVEL(Abs(isfront), col, row), SPR_LEVEL(LVL_POLE)
      Case T_COOKIE
        SpriteSequence_Copy SPRITE_LEVEL(Abs(isfront), col, row), SPR_LEVEL(LVL_COOKIE)
      Case T_COFFEE
        SpriteSequence_Copy SPRITE_LEVEL(Abs(isfront), col, row), SPR_LEVEL(LVL_COFFEE)
      Case T_MITTENS
        SpriteSequence_Copy SPRITE_LEVEL(Abs(isfront), col, row), SPR_LEVEL(LVL_MITTENS)
      Case T_TUQUE
        SpriteSequence_Copy LVL_SPRITES(col, row), SPR_LEVEL(LVL_TUQUE)
      Case T_WATER
        SpriteSequence_Copy LVL_SPRITES(col, row), SPR_LEVEL(LVL_WATER)
      Case T_SNOW
        If Dodu.HasRackets Then
          PrepareSnow m, col, row, FALSE
        End If
    End Select
  Else
    If e = T_SNOW And Not Dodu.HasRackets Then
      PrepareSnow m, col, row, TRUE
    End If
  End If
  SpriteSequence_Start LVL_SPRITES(col, row)
End Sub


Sub ClearSpriteSquare (s As Square)
  Let SPRITE_LEVEL(0, s.col, s.row).Content = -1
  Let SPRITE_LEVEL(1, s.col, s.row).Content = -1
End Sub

Sub PrepareSnow (m As LevelMap, col As Integer, row As Integer, front As Integer)
  Dim hastop As Integer
  Let hastop = (row > 0 _AndAlso m.Topo(col, row - 1) = T_SNOW) _OrElse row = 0
  If hastop Then
    SpriteSequence_Copy SPRITE_LEVEL(Abs(front), col, row), SPR_LEVEL(LVL_SNOW_M)
  Else
    Select Case GetSnowSlopeAt(col, row, m)
      Case L_SLOPE_C
        SpriteSequence_Copy SPRITE_LEVEL(Abs(front), col, row), SPR_LEVEL(LVL_SNOW_C)
      Case L_SLOPE_L
        SpriteSequence_Copy SPRITE_LEVEL(Abs(front), col, row), SPR_LEVEL(LVL_SNOW_L)
      Case L_SLOPE_R
        SpriteSequence_Copy SPRITE_LEVEL(Abs(front), col, row), SPR_LEVEL(LVL_SNOW_R)
    End Select
  End If
  SpriteSequence_Stop SPRITE_LEVEL(Abs(front), col, row)
  Let SPRITE_LEVEL(Abs(front), col, row).OnEnd = SPSQ_RESET%
  Let SPRITE_LEVEL(Abs(front), col, row).Ticker.Loop = FALSE
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


