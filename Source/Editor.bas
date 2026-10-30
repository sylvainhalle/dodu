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
Const TOPBAR_HEIGHT = 16
Const PALETTE_WIDTH = 26
Dim Shared SCREEN_DIMS As Point
Point_Set SCREEN_DIMS, 320, 200
Dim Shared LEVEL_DIMS As Point
Point_Set LEVEL_DIMS, SCREEN_DIMS.x - PALETTE_WIDTH, SCREEN_DIMS.y - TOPBAR_HEIGHT
Dim Shared LEVEL_TOPLEFT As Point
Point_Set LEVEL_TOPLEFT, PALETTE_WIDTH, TOPBAR_HEIGHT + 1
Dim Shared PALETTE_TOPLEFT As Point, PALETTE_BOTRIGHT As Point
Point_Set PALETTE_TOPLEFT, 0, TOPBAR_HEIGHT + 1
Point_Set PALETTE_BOTRIGHT, PALETTE_WIDTH, 200
Const PALETTE_BTN_SIZE = 6
Dim Shared P_COORDS1 As Point, P_COORDS2 As Point
Point_Set P_COORDS1, 3, PALETTE_BOTRIGHT.y - 22
Point_Set P_COORDS2, 19, PALETTE_BOTRIGHT.y - 22

Const GUI_BUTTON_SIZE = 17
Dim Shared GUI_ICON_BUTTON_SIZE As Point
Point_Set GUI_ICON_BUTTON_SIZE, 11, 11

' Window scaling factor
Const SCALE% = 4

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
Const COLOR_BG& = _RGB32(83, 83, 255)
Const COLOR_BTN& = _RGB32(192, 192, 192)
Const COLOR_GRID& = _RGB32(64, 64, 64, 128)
Const COLOR_CURSOR& = _RGB32(255, 255, 0)

Const WALKING_SPEED# = 1

Dim Shared PT_LEVEL_NB As Point
Dim Shared P_UNIT As Point
Point_Set P_UNIT, 1, 1

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
'$Include:'Fonts.bi'

' World size
Dim Shared WORLD_SIZE As Point
Point_Set WORLD_SIZE, M_W * BLOCK_SIZE%, M_H * BLOCK_SIZE%

' --------------------------
' Level data
' --------------------------
Const CURRENT_LEVEL% = 0

' Assets
'$Include:'Assets.bi'

' GUI
Dim Shared GUI_TOPBAR(3) As SpriteSequence
SpriteSequence_InitFile GUI_TOPBAR(0), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/TopBar_L.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT
SpriteSequence_InitFile GUI_TOPBAR(1), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/TopBar_C.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT
SpriteSequence_InitFile GUI_TOPBAR(2), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/TopBar_R.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT
Dim Shared GUI_BUTTON(3) As SpriteSequence
SpriteSequence_InitFile GUI_BUTTON(0), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_L.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT
SpriteSequence_InitFile GUI_BUTTON(1), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_C.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT
SpriteSequence_InitFile GUI_BUTTON(2), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_R.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT

Dim Shared GUI_TOPBAR_DODU As SpriteSequence
SpriteSequence_InitFile GUI_TOPBAR_DODU, "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Dodu_Icon.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT

Dim Shared GUI_TOOLBAR(4) As SpriteSequence
SpriteSequence_InitFile GUI_TOOLBAR(0), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_New.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT
SpriteSequence_InitFile GUI_TOOLBAR(1), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_Load.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT
SpriteSequence_InitFile GUI_TOOLBAR(2), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_Save.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT
SpriteSequence_InitFile GUI_TOOLBAR(3), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_Undo.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT

Dim Shared GUI_BUTTON_ICON As SpriteSequence
SpriteSequence_InitFile GUI_BUTTON_ICON, "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_Icon.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT

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
Let PALETTE_SHORTCUTS(11) = "s"

Dim Shared LVL_SPRITES(M_W, M_H) As SpriteSequence
Dim Shared SPRITE_LEVEL(2, M_W, M_H) As SpriteSequence
Dim Shared COPY_LEVEL As LevelMap
Dim Shared COPY_TOPLEFT As Square, COPY_BOTRIGHT As Square
ResetLevelSprites

' --------------------------
' Screen setup
' --------------------------
_AllowFullScreen _Off

Dim Shared MainScreen As Viewport, ImgBuffer As Viewport
Dim Shared LevelBuffer As Viewport, PaletteBuffer As Viewport
Viewport_Init ImgBuffer, SCREEN_DIMS, SCREEN_DIMS, P_ORIGIN, 1
Dim Shared PALETTE_DIMS As Point
Point_Set PALETTE_DIMS, PALETTE_BOTRIGHT.x - PALETTE_TOPLEFT.x, PALETTE_BOTRIGHT.y - PALETTE_TOPLEFT.y
'Print PALETTE_DIMS.x
'Print PALETTE_DIMS.y
'Dim dummy As String
'Input dummy$
Viewport_Init PaletteBuffer, PALETTE_DIMS, PALETTE_DIMS, P_ORIGIN, 1
Viewport_Init LevelBuffer, LEVEL_DIMS, WORLD_SIZE, P_ORIGIN, 1
Viewport_Init MainScreen, SCREEN_DIMS, P_ORIGIN, P_ORIGIN, SCALE%
Viewport_SetBackground LevelBuffer, Backgrounds(10), P_UNIT

Screen MainScreen.Buffer

' State variables
Dim keyb As Integer
Dim Shared selection As Integer
Let selection = 3
Dim Shared DIRTY As Integer
Let DIRTY = FALSE

Dim Shared sel_topleft As Square, sel_botright As Square
Square_Set sel_topleft, 0, 0
Square_Set sel_botright, 0, 0

Dim Shared UNDO_HEAD As Integer
Let UNDO_HEAD = 0

Dim lvln As Integer
For lvln = 0 To 11
  Let Levels(lvln).Height = M_H
  Let Levels(lvln).Width = M_W
Next

Dim khit As Long, shift As Integer, ctrl As Integer, msinput As Integer, mousex As Integer, mousey As Integer
Do
  _Limit FPS%
  Let khit = _KeyHit
  Let shift = _KeyDown(K_LSHIFT) Or _KeyDown(K_RSHIFT)
  Let ctrl = _KeyDown(K_CTRL)
  Do While _MouseInput
    Let mousex = _MouseX \ SCALE
    Let mousey = _MouseY \ SCALE
  Loop
  'Viewport_Clear MainScreen
  'Viewport_Clear LevelBuffer
  TickAll
  DrawPalette
  DrawLevel
  Viewport_PutViewport ImgBuffer, TRUE, PaletteBuffer, PALETTE_TOPLEFT, P_ORIGIN, PALETTE_DIMS
  Viewport_PutViewport ImgBuffer, TRUE, LevelBuffer, LEVEL_TOPLEFT, P_ORIGIN, LEVEL_DIMS
  DrawTopBar
  Dim undop As Point
  Point_Set undop, PALETTE_WIDTH + 2, TOPBAR_HEIGHT + 2
  'BitmapFont_WriteString ImgBuffer, SF_FONT, undop, Str$(UNDO_HEAD) + " " + Str$(UNDO_TAIL), COLOR_BLACK
  BitmapFont_WriteString ImgBuffer, SF_FONT, undop, Str$(mousex) + " " + Str$(mousey), COLOR_BLACK
  Viewport_Copy ImgBuffer, MainScreen
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
    If Not ctrl Then
      MoveSquareFocus -1, 0, shift
    Else
      MoveRegion -1, 0
    End If
  End If

  If IsRight% Then
    Let keyb = TRUE
    If Not ctrl Then
      MoveSquareFocus 1, 0, shift
    Else
      MoveRegion 1, 0

    End If
  End If

  If IsUp% Then
    Let keyb = TRUE
    If Not ctrl Then
      MoveSquareFocus 0, -1, shift
    Else
      MoveRegion 0, -1

    End If
  End If

  If IsDown% Then
    Let keyb = TRUE
    If Not ctrl Then
      MoveSquareFocus 0, 1, shift
    Else
      MoveRegion 0, 1

    End If
  End If

  If IsEnter% Then
    Let keyb = TRUE
    CreateUndoSnapshot
    ApplyToSquare sel_topleft, sel_botright, PALETTE_SHORTCUTS(selection)
  End If

  If Kbd_Down(K_INS) Then
    Let keyb = TRUE
    If ctrl Then
      CopyRegion
    ElseIf shift Then
      PasteRegion
    End If
  End If

  If Kbd_Down(K_DEL) And shift Then
    Let keyb = TRUE
    CutRegion
  End If

  If Kbd_Down(K_BACKSPACE) Then
    Let keyb = TRUE
    ApplyUndo
  End If

  If (Kbd_Down(K_S_UC) Or Kbd_Down(K_S_LC)) And ctrl Then
    DoSave
  End If

  If _MouseButton(1) Then
    HandleClick mousex, mousey
  End If

  ' Are we switching to a new selection?
  Dim i As Integer
  For i = 0 To 11
    If khit = Asc(PALETTE_SHORTCUTS(i)) Or khit = Asc(LCase$(PALETTE_SHORTCUTS(i))) Then
      Dim s As Integer
      Let selection = i
      Exit For
    End If
  Next

Loop

Sub HandleClick (x As Single, y As Single)
  If InRect(x, y, 0, 0, 320, TOPBAR_HEIGHT) Then
    HandleClickBar x, y
  ElseIf InRect(x, y, 0, TOPBAR_HEIGHT, PALETTE_WIDTH, 200) Then
    HandleClickPalette x, y - TOPBAR_HEIGHT
  ElseIf InRect(x, y, PALETTE_WIDTH + 1, TOPBAR_HEIGHT, 320, 200) Then
    HandleClickLevel x - (PALETTE_WIDTH + 1), y - TOPBAR_HEIGHT
  End If
End Sub

Sub HandleClickBar (x As Single, y As Single)
  ' Do nothing for the moment
End Sub

Sub CopyLevel (ifrom As Integer, ito As Integer)
  Dim col As Integer, row As Integer
  For col = 0 To M_W - 1
    For row = 0 To M_H - 1
      Let Levels(ito).Topo(col, row) = Levels(ifrom).Topo(col, row)
    Next
  Next
End Sub

Sub HandleClickPalette (x As Single, y As Single)
  Dim i As Integer, x1 As Integer, y1 As Integer
  For i = 0 To 16
    Let x1 = 2 + (i Mod 2) * GUI_ICON_BUTTON_SIZE.x
    Let y1 = (i \ 2) * GUI_ICON_BUTTON_SIZE.y + GUI_ICON_BUTTON_SIZE.y
    If InRect(x, y, x1, y1, x1 + GUI_ICON_BUTTON_SIZE.x, y1 + GUI_ICON_BUTTON_SIZE.y) Then
      Let selection = i
      Exit Sub
    End If
  Next
  For i = 0 To 3
    If InRect(x, y, 5, 100 + i * GUI_BUTTON_SIZE, 5 + GUI_BUTTON_SIZE, 100 + i * GUI_BUTTON_SIZE + GUI_BUTTON_SIZE) Then
      Select Case i
        Case 0
          DoNew
        Case 1
          DoLoad
        Case 2
          DoSave
        Case 3
          ApplyUndo
      End Select
    End If
  Next
End Sub

Sub DoNew
End Sub

Sub HandleClickLevel (x As Single, y As Single)
  Dim col As Integer, row As Integer
  Let col = x \ BLOCK_SIZE
  Let row = y \ BLOCK_SIZE
  SetSquareFocus col, row
End Sub

Function InRect% (x As Single, y As Single, x1 As Single, y1 As Single, x2 As Single, y2 As Single)
  Let InRect% = x >= x1 _AndAlso x <= x2 _AndAlso y >= y1 _AndAlso y <= y2
End Function

Sub DrawTopBar
  Dim p As Point
  Point_Set p, 0, 0
  Viewport_PutSpriteSequence ImgBuffer, TRUE, GUI_TOPBAR(0), p, FALSE
  Point_Set p, 314, 0
  Viewport_PutSpriteSequence ImgBuffer, TRUE, GUI_TOPBAR(2), p, FALSE
  Viewport_LineC ImgBuffer, TRUE, 6, 0, 313, TOPBAR_HEIGHT, COLOR_WHITE, TRUE, TRUE
  Point_Set p, 5, 5
  BitmapFont_WriteString ImgBuffer, SF_FONT, p, "The Dodu Level Editor", COLOR_BLACK
  Point_Set p, 300, 1
  Viewport_PutSpriteSequence ImgBuffer, TRUE, GUI_TOPBAR_DODU, p, FALSE
End Sub

Sub CopyRegion
  Dim col As Integer, row As Integer
  For col = 0 To M_W - 1
    For row = 0 To M_H - 1
      Let COPY_LEVEL.Topo(col, row) = Levels(CURRENT_LEVEL).Topo(col, row)
    Next
  Next
  ReorderPoints
  Square_Set COPY_TOPLEFT, sel_topleft.col, sel_topleft.row
  Square_Set COPY_BOTRIGHT, sel_botright.col, sel_botright.row
  Square_Set sel_botright, sel_topleft.col, sel_topleft.row
End Sub

Sub DoSave
  Dim outfile As String
  Let outfile = _SaveFileDialog$("Save level", "", "*.lvl", "Level files")
  If outfile = "" Then Exit Sub
  'Find convex envelope of level
  Dim topleft As Square, botright As Square
  Dim contents As String, col As Integer, row As Integer
  Square_Set botright, M_W, M_H
  Dim min As Integer, max As Integer
  Let min = M_W: Let max = 0
  For row = 0 To M_H - 1
    For col = 0 To M_W - 1
      If Levels(CURRENT_LEVEL).Topo(col, row) <> " " Then
        Let min = _Min(min, col)
        Let max = _Max(max, col)
      End If
    Next
  Next
  Let topleft.col = min
  Let botright.col = max
  Let min = M_H: Let max = 0
  For col = 0 To M_W - 1
    For row = 0 To M_H - 1
      If Levels(CURRENT_LEVEL).Topo(col, row) <> " " Then
        Let min = _Min(min, row)
        Let max = _Max(max, row)
      End If
    Next
  Next
  Let topleft.row = min
  Let botright.row = max
  Let contents = contents + "' Level generated by The Dodu Level Editor" + Chr$(13) + Chr$(13)
  For row = topleft.row To botright.row
    Let contents = contents + "Data " + Chr$(34)
    For col = topleft.col To botright.col
      Let contents = contents + Levels(CURRENT_LEVEL).Topo(col, row)
    Next
    Let contents = contents + Chr$(34) + Chr$(13)
  Next
  Let contents = contents + "Data " + Chr$(34) + "x" + Chr$(34)
  _WriteFile outfile, contents
End Sub

Sub DoLoad
  If DIRTY Then
    Dim result As Long
    Let result = _MessageBox("File modified", "File has been modified. Save changes?", "yesnocancel", "question")
    Select Case result
      Case 0 'Cancel
        Exit Sub
      Case 1 ' Yes
        DoSave
    End Select
  End If
  Dim infile As String
  Let infile = _OpenFileDialog$("Open level", "", "*.lvl", "Level files")
End Sub


Sub DrawButton (v As Viewport, p As Point, text As String)
  Dim x As Integer, p2 As Point
  Viewport_PutSpriteSequence v, TRUE, GUI_BUTTON(0), p, FALSE
  For x = p.x + 3 To p.x + 3 + Len(text) * SF_FONT.Width
    Point_Set p2, x, p.y
    Viewport_PutSpriteSequence v, TRUE, GUI_BUTTON(1), p2, FALSE
  Next
  Point_Set p2, p.x + 3 + Len(text) * SF_FONT.Width, p.y
  Viewport_PutSpriteSequence v, TRUE, GUI_BUTTON(2), p2, FALSE
  Point_Set p2, p.x + 3, p.y + 3
  BitmapFont_WriteString v, SF_FONT, p2, text, COLOR_BLACK
End Sub

Sub DrawIconButton (v As Viewport, p As Point, icn As SpriteSequence)
  Viewport_PutSpriteSequence v, TRUE, GUI_BUTTON_ICON, p, FALSE
End Sub

Sub MoveRegion (delta_col As Integer, delta_row As Integer)
  CreateUndoSnapshot
  ReorderPoints
  CutRegion
  Let sel_topleft.col = Clamp%(0, sel_topleft.col + delta_col, M_W - 1)
  Let sel_topleft.row = Clamp%(0, sel_topleft.row + delta_row, M_H - 1)
  Let sel_botright.col = Clamp%(0, sel_botright.col + delta_col, M_W - 1)
  Let sel_botright.row = Clamp%(0, sel_botright.row + delta_row, M_H - 1)
  PasteRegion
End Sub

Sub CreateUndoSnapshot
  If UNDO_HEAD = 11 Then
    'Move all them one level down
    Dim l As Integer
    For l = 2 To 11
      CopyLevel l, l - 1
    Next
  Else
    Let UNDO_HEAD = UNDO_HEAD + 1
  End If
  Dim col As Integer, row As Integer
  For col = 0 To M_W - 1
    For row = 0 To M_H - 1
      Let Levels(UNDO_HEAD).Topo(col, row) = Levels(CURRENT_LEVEL).Topo(col, row)
    Next
  Next
End Sub

Sub CutRegion
  CreateUndoSnapshot
  ReorderPoints
  Dim col As Integer, row As Integer, s As Square
  For col = 0 To M_W - 1
    For row = 0 To M_H - 1
      Let COPY_LEVEL.Topo(col, row) = Levels(CURRENT_LEVEL).Topo(col, row)
    Next
  Next
  Square_Set COPY_TOPLEFT, sel_topleft.col, sel_topleft.row
  Square_Set COPY_BOTRIGHT, sel_botright.col, sel_botright.row
  Let Levels(CURRENT_LEVEL).Topo(col, row) = " "
  For col = 0 To COPY_BOTRIGHT.col - COPY_TOPLEFT.col
    For row = 0 To COPY_BOTRIGHT.row - COPY_TOPLEFT.row
      Let Levels(CURRENT_LEVEL).Topo(sel_topleft.col + col, sel_topleft.row + row) = " "
      Square_Set s, sel_topleft.col + col, sel_topleft.row + row
      ClearSpriteSquare s
    Next
  Next
End Sub


Sub PasteRegion
  CreateUndoSnapshot
  ReorderPoints
  Dim col As Integer, row As Integer
  For col = 0 To COPY_BOTRIGHT.col - COPY_TOPLEFT.col
    For row = 0 To COPY_BOTRIGHT.row - COPY_TOPLEFT.row
      Let Levels(CURRENT_LEVEL).Topo(sel_topleft.col + col, sel_topleft.row + row) = COPY_LEVEL.Topo(COPY_TOPLEFT.col + col, COPY_TOPLEFT.row + row)
      SetSpriteSquare Levels(CURRENT_LEVEL), FALSE, sel_topleft.col + col, sel_topleft.row + row, COPY_LEVEL.Topo(COPY_TOPLEFT.col + col, COPY_TOPLEFT.row + row)
      SpriteSequence_Start SPRITE_LEVEL(0, sel_topleft.col + col, sel_topleft.row + row)
    Next
  Next
End Sub


Sub MoveSquareFocus (hor As Integer, ver As Integer, shift As Integer)
  If shift Then
    Let sel_botright.col = Clamp%(sel_botright.col + hor, 0, M_W - 1)
    Let sel_botright.row = Clamp%(sel_botright.row + ver, 0, M_H - 1)
    'If sel_botright.row = sel_topleft.row And ver < 0 Then
    '  Let sel_botright.row = sel_botright.row - 1
    'End If
    'If sel_botright.col = sel_topleft.col And hor < 0 Then
    '  Let sel_botright.col = sel_botright.col - 1
    'End If
  Else
    Let sel_topleft.col = Clamp%(sel_topleft.col + hor, 0, M_W - 1)
    Let sel_topleft.row = Clamp%(sel_topleft.row + ver, 0, M_H - 1)
    Let sel_botright.col = sel_topleft.col
    Let sel_botright.row = sel_topleft.row
  End If
End Sub

Sub SetSquareFocus (col As Integer, row As Integer)
  Let sel_topleft.col = col
  Let sel_topleft.row = row
  Let sel_botright.col = sel_topleft.col
  Let sel_botright.row = sel_topleft.row
End Sub

Sub ReorderPoints
  Dim mincol As Integer, maxcol As Integer
  Dim minrow As Integer, maxrow As Integer
  Let minrow = _Min(sel_topleft.row, sel_botright.row)
  Let maxrow = _Max(sel_topleft.row, sel_botright.row)
  Let mincol = _Min(sel_topleft.col, sel_botright.col)
  Let maxcol = _Max(sel_topleft.col, sel_botright.col)
  Square_Set sel_topleft, mincol, minrow
  Square_Set sel_botright, maxcol, maxrow

End Sub

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
  For col = 0 To M_W - 1
    For row = 0 To M_H - 1
      Let Levels(CURRENT_LEVEL%).Topo(col, row) = " "
    Next
  Next
End Sub

Sub ApplyToSquare (topleft As Square, botright As Square, sel As String)
  Let DIRTY = TRUE
  Dim col As Integer, row As Integer, s As Square
  ReorderPoints
  For col = topleft.col To botright.col
    For row = topleft.row To botright.row
      Square_Set s, col, row
      Let Levels(CURRENT_LEVEL).Topo(col, row) = PALETTE_SHORTCUTS(selection)
      If PALETTE_SHORTCUTS(selection) = T_NOTHING Then
        ClearSpriteSquare s
      Else
        SetSpriteSquare Levels(CURRENT_LEVEL), FALSE, col, row, sel
        SpriteSequence_Start SPRITE_LEVEL(0, col, row)
      End If
    Next
  Next
End Sub

Sub ApplyUndo
  If UNDO_HEAD = 0 Then Exit Sub ' Nothing to undo on the stack
  Dim s As Square
  Dim col As Integer, row As Integer
  For col = 0 To M_W - 1
    For row = 0 To M_H - 1
      Let Levels(CURRENT_LEVEL%).Topo(col, row) = Levels(UNDO_HEAD).Topo(col, row)
      Square_Set s, col, row
      If Levels(CURRENT_LEVEL%).Topo(col, row) = " " Then
        ClearSpriteSquare s
      Else
        ApplyToSquare s, s, Levels(CURRENT_LEVEL%).Topo(col, row)
      End If
    Next
  Next
  Let UNDO_HEAD = _Max(0, UNDO_HEAD - 1)
End Sub

Sub DrawPalette
  Viewport_Clear PaletteBuffer
  Viewport_Line PaletteBuffer, TRUE, P_ORIGIN, PALETTE_DIMS, COLOR_BG&, TRUE, TRUE
  Dim p As Point, i As Integer, x As Integer, y As Integer
  'Buttons
  For i = 0 To 16
    Let x = 2 + (i Mod 2) * GUI_ICON_BUTTON_SIZE.x
    Let y = (i \ 2) * GUI_ICON_BUTTON_SIZE.y
    Point_Set p, x, y
    Viewport_PutSpriteSequence PaletteBuffer, TRUE, GUI_BUTTON_ICON, p, FALSE
    Point_Set p, x + 2, y + 2
    Viewport_PutSpriteSequence PaletteBuffer, TRUE, SPR_MINIMAP(PALETTE_BUTTONS(i)), p, FALSE
    If i = selection Then
      Viewport_LineC PaletteBuffer, TRUE, x, y, x + GUI_ICON_BUTTON_SIZE.x, y + GUI_ICON_BUTTON_SIZE.y, COLOR_CURSOR&, TRUE, FALSE
    End If
  Next
  For i = 0 To 3
    Point_Set p, 5, 100 + i * 17
    Viewport_PutSpriteSequence PaletteBuffer, TRUE, GUI_TOOLBAR(i), p, FALSE
  Next

  ' Coordinates
  DrawNumber PaletteBuffer, P_COORDS1, sel_topleft.col
  DrawNumber PaletteBuffer, P_COORDS2, sel_topleft.row
End Sub

Sub DrawLevel
  Viewport_Clear LevelBuffer
  Dim col As Integer, row As Integer
  For col = 0 To M_W - 1
    For row = 0 To M_H - 1
      Viewport_LineC LevelBuffer, FALSE, col * BLOCK_SIZE% - 1, row * BLOCK_SIZE%, col * BLOCK_SIZE% + 1, row * 11, COLOR_GRID&, FALSE, FALSE
      Viewport_LineC LevelBuffer, FALSE, col * BLOCK_SIZE%, row * BLOCK_SIZE% - 1, col * BLOCK_SIZE%, row * BLOCK_SIZE% + 1, COLOR_GRID&, FALSE, FALSE
    Next
  Next
  For row = M_H - 1 To 0 Step -1
    For col = 0 To M_W - 1
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
  Viewport_LineC LevelBuffer, FALSE, _Min(sel_topleft.col, sel_botright.col) * BLOCK_SIZE%, _Min(sel_topleft.row, sel_botright.row) * BLOCK_SIZE%, (_Max(sel_topleft.col, sel_botright.col) + 1) * BLOCK_SIZE% - 1, (_Max(sel_topleft.row, sel_botright.row) + 1) * BLOCK_SIZE% - 1, COLOR_CURSOR&, TRUE, FALSE
End Sub

Sub TickAll
  Viewport_Tick LevelBuffer
  Dim row As Integer, col As Integer
  For row = 0 To M_H - 1
    For col = 0 To M_W - 1
      SpriteSequence_Tick SPRITE_LEVEL(0, col, row)
      SpriteSequence_Tick SPRITE_LEVEL(1, col, row)
    Next
  Next
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
        SpriteSequence_Copy SPRITE_LEVEL(Abs(isfront), col, row), SPR_LEVEL(LVL_TUQUE)
      Case T_WATER
        SpriteSequence_Copy SPRITE_LEVEL(Abs(isfront), col, row), SPR_LEVEL(LVL_WATER)
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
'$Include:'Fonts.bm'
'$Include:'Assets.bm'

' :mode=visualbasic:folding=explicit:wrap=none:


