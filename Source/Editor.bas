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
Const PAN_MOVE_INCREMENT = BLOCK_SIZE

Const UNDO_LEVELS = 11

' Screen dimensions
Const TOPBAR_HEIGHT = 16
Const PALETTE_WIDTH = 26
Dim Shared SCREEN_DIMS As Point
Point_Set SCREEN_DIMS, 512, 342
Dim Shared LEVEL_DIMS As Point
Point_Set LEVEL_DIMS, SCREEN_DIMS.x - PALETTE_WIDTH, SCREEN_DIMS.y - TOPBAR_HEIGHT
Dim Shared LEVEL_TOPLEFT As Point
Point_Set LEVEL_TOPLEFT, PALETTE_WIDTH, TOPBAR_HEIGHT + 1
Dim Shared PALETTE_TOPLEFT As Point, PALETTE_BOTRIGHT As Point
Point_Set PALETTE_TOPLEFT, 0, TOPBAR_HEIGHT + 1
Point_Set PALETTE_BOTRIGHT, PALETTE_WIDTH, SCREEN_DIMS.y
Const PALETTE_BTN_SIZE = 6
Dim Shared P_COORDS1 As Point, P_COORDS2 As Point
Point_Set P_COORDS1, 3, PALETTE_BOTRIGHT.y - 22
Point_Set P_COORDS2, 19, PALETTE_BOTRIGHT.y - 22

Const GUI_BUTTON_SIZE = 17
Dim Shared GUI_ICON_BUTTON_SIZE As Point
Point_Set GUI_ICON_BUTTON_SIZE, 11, 11

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
$ExeIcon:'/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Game_Icon.ico'

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
Let PALETTE_BUTTONS(2) = LVL_MARK
Let PALETTE_BUTTONS(3) = LVL_BLOCK_B
Let PALETTE_BUTTONS(4) = LVL_BLOCK_W
Let PALETTE_BUTTONS(5) = LVL_POLE
Let PALETTE_BUTTONS(6) = LVL_MITTENS
Let PALETTE_BUTTONS(7) = LVL_TUQUE
Let PALETTE_BUTTONS(8) = LVL_COFFEE
Let PALETTE_BUTTONS(9) = LVL_COOKIE
Let PALETTE_BUTTONS(10) = LVL_WATER
Let PALETTE_BUTTONS(11) = LVL_SNOW_C
Let PALETTE_BUTTONS(12) = LVL_ROPE_M

Dim Shared PALETTE_SHORTCUTS(16) As String
Let PALETTE_SHORTCUTS(0) = "H"
Let PALETTE_SHORTCUTS(1) = " "
Let PALETTE_SHORTCUTS(2) = "^"
Let PALETTE_SHORTCUTS(3) = "@"
Let PALETTE_SHORTCUTS(4) = "#"
Let PALETTE_SHORTCUTS(5) = "!"
Let PALETTE_SHORTCUTS(6) = "m"
Let PALETTE_SHORTCUTS(7) = "t"
Let PALETTE_SHORTCUTS(8) = "f"
Let PALETTE_SHORTCUTS(9) = "c"
Let PALETTE_SHORTCUTS(10) = "~"
Let PALETTE_SHORTCUTS(11) = "s"
Let PALETTE_SHORTCUTS(12) = "$"

Dim Shared LVL_SPRITES(M_W, M_H) As SpriteSequence
Dim Shared SPRITE_LEVEL(2, M_W, M_H) As SpriteSequence
Dim Shared COPY_LEVEL As LevelMap
Dim Shared COPY_TOPLEFT As Square, COPY_BOTRIGHT As Square
ResetLevelSprites

'Other assets
'Dim Shared ICN_MUSIC As SpriteSequence
'Dim Shared ICN_BG As SpriteSequence
'SpriteSequence_InitFile ICN_MUSIC, "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Music.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT
'SpriteSequence_InitFile ICN_BG, "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Image.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT


' --------------------------
' Screen setup
' --------------------------
_AllowFullScreen _Off

Dim Shared CURRENT_BG
Let CURRENT_BG = 10

Dim Shared MainScreen As Viewport, ImgBuffer As Viewport
Dim Shared LevelBuffer As Viewport, PaletteBuffer As Viewport
Viewport_Init ImgBuffer, SCREEN_DIMS, SCREEN_DIMS, P_ORIGIN, 1, 1
Dim Shared PALETTE_DIMS As Point
Point_Set PALETTE_DIMS, PALETTE_BOTRIGHT.x - PALETTE_TOPLEFT.x, PALETTE_BOTRIGHT.y - PALETTE_TOPLEFT.y
Viewport_Init PaletteBuffer, PALETTE_DIMS, PALETTE_DIMS, P_ORIGIN, 1, 1
Viewport_Init LevelBuffer, LEVEL_DIMS, WORLD_SIZE, P_ORIGIN, 1, 1
Viewport_Init MainScreen, SCREEN_DIMS, P_ORIGIN, P_ORIGIN, SCALE%, 1
Let MainScreen.Scanlines = 1
Viewport_SetBackground LevelBuffer, Backgrounds(CURRENT_BG), P_UNIT

Screen MainScreen.Layers(0).Buffer

_Title "The Dodu Level Editor"
_Icon SPR_LEVEL(LVL_BLOCK_B).Content


Dim Shared sel_topleft As Square, sel_botright As Square
Square_Set sel_topleft, 0, 0
Square_Set sel_botright, 0, 0

Dim Shared UNDO_HEAD As Integer
Let UNDO_HEAD = 0

Dim lvln As Integer
For lvln = 0 To UNDO_LEVELS
  Let Levels(lvln).Height = M_H
  Let Levels(lvln).Width = M_W
Next

Dim Shared selection As Integer
Let selection = 3
Dim Shared DIRTY As Integer
Let DIRTY = FALSE
Dim Shared filename As String
Dim Shared songindex As Integer
Let songindex = -1
Dim Shared dummy As String

MainLoop
Cls
End


Sub MainLoop
  ' --------------------------
  ' State variables
  ' --------------------------
  Dim keyb As Integer
  Let filename = "Untitled.lvl"

  Dim khit As Long, shift As Integer, ctrl As Integer, alt As Integer, msinput As Integer, mousex As Integer, mousey As Integer
  Do
    _Limit FPS%
    Let khit = _KeyHit
    Let shift = _KeyDown(K_LSHIFT) Or _KeyDown(K_RSHIFT)
    Let ctrl = _KeyDown(K_CTRL)
    Let alt = _KeyDown(K_ALT)
    Do While _MouseInput
      Let mousex = _MouseX \ SCALE
      Let mousey = _MouseY \ SCALE
    Loop
    'Viewport_Clear MainScreen
    'Viewport_Clear LevelBuffer
    TickAll
    DrawPalette
    DrawLevel
    Viewport_PutViewport ImgBuffer, TRUE, PaletteBuffer, PALETTE_TOPLEFT, P_ORIGIN, PALETTE_DIMS, EYE_NONE
    Viewport_PutViewport ImgBuffer, TRUE, LevelBuffer, LEVEL_TOPLEFT, P_ORIGIN, LEVEL_DIMS, EYE_NONE
    DrawTopBar
    Dim undop As Point
    Point_Set undop, PALETTE_WIDTH + 2, TOPBAR_HEIGHT + 2
    BitmapFont_WriteString ImgBuffer, SF_FONT, undop, Str$(UNDO_HEAD) + " " + Levels(CURRENT_LEVEL).Topo(sel_topleft.col, sel_topleft.row), COLOR_BLACK, 0
    'BitmapFont_WriteString ImgBuffer, SF_FONT, undop, Str$(mousex) + " " + Str$(mousey), COLOR_BLACK, 0
    Viewport_Copy ImgBuffer, MainScreen, EYE_NONE
    Viewport_Display MainScreen, EYE_NONE

    If keyb Then
      Kbd_WaitRelease FPS%
      Let keyb = FALSE
    End If

    If IsEsc% Then
      Cls
      End
    End If

    If IsLeft% Then
      Let keyb = TRUE
      If Not ctrl And Not alt Then
        MoveSquareFocus -1, 0, shift
      ElseIf alt And Not ctrl Then
        MoveRegion -1, 0
      ElseIf ctrl And Not alt Then
        PanLevel -1, 0
      End If
    End If

    If IsRight% Then
      Let keyb = TRUE
      If Not ctrl And Not alt Then
        MoveSquareFocus 1, 0, shift
      ElseIf alt And Not ctrl Then
        MoveRegion 1, 0
      ElseIf ctrl And Not alt Then
        PanLevel 1, 0
      End If
    End If

    If IsUp% Then
      Let keyb = TRUE
      If Not ctrl And Not alt Then
        MoveSquareFocus 0, -1, shift
      ElseIf alt And Not ctrl Then
        MoveRegion 0, -1
      ElseIf ctrl And Not alt Then
        PanLevel 0, -1
      End If
    End If

    If IsDown% Then
      Let keyb = TRUE
      If Not ctrl And Not alt Then
        MoveSquareFocus 0, 1, shift
      ElseIf alt And Not ctrl Then
        MoveRegion 0, 1
      ElseIf ctrl And Not alt Then
        PanLevel 0, 1
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
        PasteRegion TRUE
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
      Let keyb = TRUE
      DoSave
    End If

    If Kbd_Down(K_B_LC) Then
      Let keyb = TRUE
      ToggleBackground 1
    End If

    If Kbd_Down(K_B_UC) Then
      Let keyb = TRUE
      ToggleBackground -1
    End If

    If Kbd_Down(K_LT) Then
      Let keyb = TRUE
      ToggleMusic -1
    End If

    If Kbd_Down(K_GT) Then
      Let keyb = TRUE
      ToggleMusic 1
    End If

    'if Kbd_Down(K_EQ) then
    '  TogglePlayMusic
    'endif

    If _MouseButton(1) Then
      HandleClick mousex, mousey
      _Continue
    End If

    ' Are we switching to a new selection?
    Dim i As Integer
    For i = 0 To 12
      If khit = Asc(PALETTE_SHORTCUTS(i)) Or khit = Asc(LCase$(PALETTE_SHORTCUTS(i))) Then
        Dim s As Integer
        Let selection = i
        Exit For
      End If
    Next

  Loop
End Sub

Sub ToggleBackground (direction As Integer)
  Let CURRENT_BG = (CURRENT_BG + direction) Mod 11
  Viewport_SetBackground LevelBuffer, Backgrounds(CURRENT_BG), P_ORIGIN
End Sub

Sub ToggleMusic (direction As Integer)
  If songindex = -1 Then
    Let songindex = 0
  Else
    Let songindex = (songindex + direction) Mod 7
  End If
  SoundPlayer_StopSong Audio
  SoundPlayer_SetPlaySong Audio, songindex
End Sub

Sub PanLevel (deltax As Integer, deltay As Integer)
  Dim p As Point
  Point_Set p, LevelBuffer.Pan.x + deltax * PAN_MOVE_INCREMENT, LevelBuffer.Pan.y + deltay * PAN_MOVE_INCREMENT
  'Viewport_MovePan LevelBuffer, p
  Viewport_ScrollPan LevelBuffer, p, 5
End Sub

Sub HandleClick (x As Single, y As Single)
  If InRect(x, y, 0, 0, SCREEN_DIMS.x, TOPBAR_HEIGHT) Then
    HandleClickBar x, y
  ElseIf InRect(x, y, 0, TOPBAR_HEIGHT, PALETTE_WIDTH, SCREEN_DIMS.y) Then
    HandleClickPalette x, y - TOPBAR_HEIGHT
  ElseIf InRect(x, y, PALETTE_WIDTH + 1, TOPBAR_HEIGHT, SCREEN_DIMS.x, SCREEN_DIMS.y) Then
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
    Let y1 = (i \ 2) * GUI_ICON_BUTTON_SIZE.y
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
          Exit Sub
        Case 1
          DoLoad
          Exit Sub
        Case 2
          DoSave
          Exit Sub
        Case 3
          ApplyUndo
          Exit Sub
      End Select
    End If
  Next
End Sub

Sub DoNew
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
  Dim col As Integer, row As Integer, lev As Integer, s As Square
  For col = 0 To M_W - 1
    For row = 0 To M_H - 1
      Square_Set s, col, row
      ClearSpriteSquare s
      For lev = 0 To UNDO_LEVELS
        Let Levels(lev).Topo(col, row) = T_NOTHING
      Next
    Next
  Next
  Let filename = "Untitled.lvl"
End Sub

Sub HandleClickLevel (x As Single, y As Single)
  Dim col As Integer, row As Integer
  Let col = (x + LevelBuffer.Pan.x) \ BLOCK_SIZE
  Let row = (y + LevelBuffer.Pan.y) \ BLOCK_SIZE
  SetSquareFocus col, row
End Sub

Function InRect% (x As Single, y As Single, x1 As Single, y1 As Single, x2 As Single, y2 As Single)
  Let InRect% = x >= x1 _AndAlso x <= x2 _AndAlso y >= y1 _AndAlso y <= y2
End Function

Sub DrawTopBar
  Dim p As Point
  Point_Set p, 0, 0
  Viewport_PutSpriteSequence ImgBuffer, TRUE, GUI_TOPBAR(0), p, FALSE, 0
  Point_Set p, SCREEN_DIMS.x - 6, 0
  Viewport_PutSpriteSequence ImgBuffer, TRUE, GUI_TOPBAR(2), p, FALSE, 0
  Viewport_LineC ImgBuffer, TRUE, 6, 0, SCREEN_DIMS.x - 7, TOPBAR_HEIGHT, COLOR_WHITE, TRUE, TRUE, 0
  Point_Set p, 5, 5
  BitmapFont_WriteString ImgBuffer, SF_FONT, p, "The Dodu Level Editor " + Chr$(250) + " " + filename, COLOR_BLACK, 0
  Point_Set p, SCREEN_DIMS.x - 20, 1
  Viewport_PutSpriteSequence ImgBuffer, TRUE, GUI_TOPBAR_DODU, p, FALSE, 0
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
  'Square_Set sel_botright, sel_topleft.col, sel_topleft.row
End Sub

Sub DoSave
  Dim outfile As String
  If filename = "Untitled.lvl" Then
    Let outfile = _SaveFileDialog$("Save level", "", "*.lvl", "Level files")
  Else
    Let outfile = filename
  End If
  If outfile = "" Then Exit Sub
  'Find convex envelope of level
  Dim topleft As Square, botright As Square
  ConvexEnvelope topleft, botright
  Dim contents As String, col As Integer, row As Integer
  Let contents = contents + "' Level generated by The Dodu Level Editor" + Chr$(13) + Chr$(13)
  Let contents = contents + "Data " + _Trim$(Str$(CURRENT_BG)) + ", 0, -1, 0" + Chr$(13)
  Let contents = contents + "Data 2, 2" + Chr$(13)
  Let contents = contents + "Data 0, 0" + Chr$(13)
  Dim lc As String
  For row = topleft.row To botright.row
    Let contents = contents + "Data " + Chr$(34)
    For col = topleft.col To botright.col
      Let lc = Levels(CURRENT_LEVEL).Topo(col, row)
      If lc = T_MARK Then Let lc = "*"
      Let contents = contents + lc
    Next
    Let contents = contents + Chr$(34) + Chr$(13)
  Next
  Let contents = contents + "Data " + Chr$(34) + T_END + Chr$(34)
  _WriteFile outfile, contents
  Let filename = outfile
End Sub

Sub ConvexEnvelope (topleft As Square, botright As Square)
  Dim row As Integer, col As Integer
  Square_Set topleft, 0, 0
  Square_Set botright, M_W - 1, M_H - 1
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
  If infile = "" Then Exit Sub
  Let DIRTY = FALSE
  DoNew
  Dim contents As String
  Let contents = _ReadFile$(infile)
  Dim idx As Integer, idxn As Integer
  Let idx = 1
  Dim file_lines(M_H) As String, k As Integer, bgset As Integer
  Let bgset = FALSE
  Do While idx > 0
    Let idxn = InStr(idx, contents, Chr$(13))
    If idx = idxn Then
      Let idx = idxn + 1
      _Continue
    End If
    If idxn = 0 Then
      Exit Do
    End If
    Dim s_line As String
    Let s_line = _Trim$(Mid$(contents, idx, idxn - idx + 1))
    Let idx = idxn + 1
    If s_line = "" Then _Continue
    If Mid$(s_line, 1, 4) <> "Data" Then _Continue
    If Mid$(s_line, 6, 1) <> Chr$(34) Then
      If Not bgset Then
        Let CURRENT_BG = Val(Mid$(s_line, 6, 1))
        Let bgset = TRUE
      End If
      _Continue
    End If
    Let file_lines(k) = Mid$(s_line, 7, Len(s_line) - 7)
    Let k = k + 1
  Loop
  Level_LoadLevelArray CURRENT_LEVEL, file_lines(), k
  Viewport_SetBackground LevelBuffer, Backgrounds(CURRENT_BG), P_ORIGIN
  Dim p As Point
  Square_ToPoint sel_topleft, p
  Viewport_SetCenter LevelBuffer, p
  Let filename = infile
  Let UNDO_HEAD = 0
End Sub

Sub Level_LoadLevelArray (index As Integer, lines() As String, length As Integer)
  Let UNDO_HEAD = 0
  Let Levels(index).Height = length
  Let Levels(index).Width = Len(lines(0))
  ' Center level on map
  Dim offset As Square, cell As String
  Square_Set offset, (M_W - Levels(index).Width) \ 2, (M_H - Levels(index).Height) \ 2
  Dim s As Square
  Dim col As Integer, row As Integer
  For row = 0 To Levels(index).Height - 1
    For col = 0 To Levels(index).Width - 1
      Square_Set s, col + offset.col, row + offset.row
      Let cell = Mid$(lines(row), col, 1)
      If cell = "*" Then Let cell = T_MARK
      Let Levels(CURRENT_LEVEL).Topo(col + offset.col, row + offset.row) = cell
      SetSpriteSquare Levels(CURRENT_LEVEL), FALSE, s.col, s.row, cell
      SpriteSequence_Start SPRITE_LEVEL(0, s.col, s.row)
    Next
  Next
  'Square_Set sel_topleft, offset.col + Levels(index).Width \ 2, offset.row + Levels(index).Height \ 2
  'Square_Set sel_botright, offset.col + Levels(index).Width \ 2, offset.row + Levels(index).Height \ 2
  SetSquareFocus offset.col + Levels(index).Width \ 2, offset.row + Levels(index).Height \ 2
  Dim p As Point
  Square_ToPoint sel_topleft, p
  Viewport_SetCenter LevelBuffer, p
End Sub



Sub DrawButton (v As Viewport, p As Point, text As String)
  Dim x As Integer, p2 As Point
  Viewport_PutSpriteSequence v, TRUE, GUI_BUTTON(0), p, FALSE, 0
  For x = p.x + 3 To p.x + 3 + Len(text) * SF_FONT.Width
    Point_Set p2, x, p.y
    Viewport_PutSpriteSequence v, TRUE, GUI_BUTTON(1), p2, FALSE, 0
  Next
  Point_Set p2, p.x + 3 + Len(text) * SF_FONT.Width, p.y
  Viewport_PutSpriteSequence v, TRUE, GUI_BUTTON(2), p2, FALSE, 0
  Point_Set p2, p.x + 3, p.y + 3
  BitmapFont_WriteString v, SF_FONT, p2, text, COLOR_BLACK, 0
End Sub

Sub DrawIconButton (v As Viewport, p As Point, icn As SpriteSequence)
  Viewport_PutSpriteSequence v, TRUE, GUI_BUTTON_ICON, p, FALSE, 0
End Sub

Sub MoveRegion (delta_col As Integer, delta_row As Integer)
  CreateUndoSnapshot
  ReorderPoints
  CutRegion
  Let sel_topleft.col = Clamp%(0, sel_topleft.col + delta_col, M_W - 1)
  Let sel_topleft.row = Clamp%(0, sel_topleft.row + delta_row, M_H - 1)
  Let sel_botright.col = Clamp%(0, sel_botright.col + delta_col, M_W - 1)
  Let sel_botright.row = Clamp%(0, sel_botright.row + delta_row, M_H - 1)
  PasteRegion FALSE
End Sub

Sub CreateUndoSnapshot
  If UNDO_HEAD = UNDO_LEVELS Then
    'Move all them one level down
    Dim l As Integer
    For l = 2 To UNDO_LEVELS
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
  CopyRegion
  Dim col As Integer, row As Integer, s As Square
  For col = COPY_TOPLEFT.col To COPY_BOTRIGHT.col
    For row = COPY_TOPLEFT.row To COPY_BOTRIGHT.row
      Let Levels(CURRENT_LEVEL).Topo(col, row) = " "
      Square_Set s, col, row
      ClearSpriteSquare s
    Next
  Next
End Sub


Sub PasteRegion (dosnapshot As Integer)
  If dosnapshot Then
    CreateUndoSnapshot
  End If
  ReorderPoints
  Dim col As Integer, row As Integer, offset As Square
  Square_Set offset, sel_topleft.col - COPY_TOPLEFT.col, sel_topleft.row - COPY_TOPLEFT.row
  For col = COPY_TOPLEFT.col To COPY_BOTRIGHT.col
    For row = COPY_TOPLEFT.row To COPY_BOTRIGHT.row
      If Within(col + offset.col, 0, M_W - 1) And Within(row + offset.row, 0, M_H - 1) Then
        Let Levels(CURRENT_LEVEL).Topo(col + offset.col, row + offset.row) = COPY_LEVEL.Topo(col, row)
        SetSpriteSquare Levels(CURRENT_LEVEL), FALSE, col + offset.col, row + offset.row, COPY_LEVEL.Topo(col, row)
        SpriteSequence_Start SPRITE_LEVEL(0, col + offset.col, row + offset.row)
      End If
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
  For i = 0 To 12
    If PALETTE_SHORTCUTS(i) = e Then
      Let IndexOf% = i
      Exit Function
    End If
  Next
End Function

Sub ResetLevelSprites
  Dim col As Integer, row As Integer, s As Square
  For col = 0 To M_W - 1
    For row = 0 To M_H - 1
      Let Levels(CURRENT_LEVEL%).Topo(col, row) = " "
      Square_Set s, col, row
      ClearSpriteSquare s
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
        ApplyToSquare s, s, Levels(UNDO_HEAD%).Topo(col, row)
      End If
    Next
  Next
  Let UNDO_HEAD = _Max(0, UNDO_HEAD - 1)
End Sub

Sub DrawPalette
  Viewport_Clear PaletteBuffer
  Viewport_Line PaletteBuffer, TRUE, P_ORIGIN, PALETTE_DIMS, COLOR_BG&, TRUE, TRUE, 0
  Dim p As Point, i As Integer, x As Integer, y As Integer
  'Buttons
  For i = 0 To 16
    Let x = 2 + (i Mod 2) * GUI_ICON_BUTTON_SIZE.x
    Let y = (i \ 2) * GUI_ICON_BUTTON_SIZE.y
    Point_Set p, x, y
    Viewport_PutSpriteSequence PaletteBuffer, TRUE, GUI_BUTTON_ICON, p, FALSE, 0
    Point_Set p, x + 2, y + 2
    Viewport_PutSpriteSequence PaletteBuffer, TRUE, SPR_MINIMAP(PALETTE_BUTTONS(i)), p, FALSE, 0
  Next
  For i = 0 To 16
    If i = selection Then
      Let x = 2 + (i Mod 2) * GUI_ICON_BUTTON_SIZE.x
      Let y = (i \ 2) * GUI_ICON_BUTTON_SIZE.y
      Viewport_LineC PaletteBuffer, TRUE, x, y, x + GUI_ICON_BUTTON_SIZE.x, y + GUI_ICON_BUTTON_SIZE.y, COLOR_CURSOR&, TRUE, FALSE, 0
      Exit For
    End If
  Next

  For i = 0 To 3
    Point_Set p, 5, 100 + i * 17
    Viewport_PutSpriteSequence PaletteBuffer, TRUE, GUI_TOOLBAR(i), p, FALSE, 0
  Next
  'PointSet
  'Viewport_PutSpriteSequence PaletteBuffer, TRUE, ICN_MUSIC, , p, FALSE
  ' Coordinates

  DrawNumber PaletteBuffer, P_COORDS1, sel_topleft.col, 0
  DrawNumber PaletteBuffer, P_COORDS2, sel_topleft.row, 0
End Sub

Sub DrawLevel
  Viewport_Clear LevelBuffer
  Dim col As Integer, row As Integer
  For col = 0 To M_W - 1
    For row = 0 To M_H - 1
      Viewport_LineC LevelBuffer, FALSE, col * BLOCK_SIZE% - 1, row * BLOCK_SIZE%, col * BLOCK_SIZE% + 1, row * BLOCK_SIZE%, COLOR_GRID&, FALSE, FALSE, 0
      Viewport_LineC LevelBuffer, FALSE, col * BLOCK_SIZE%, row * BLOCK_SIZE% - 1, col * BLOCK_SIZE%, row * BLOCK_SIZE% + 1, COLOR_GRID&, FALSE, FALSE, 0
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
        Viewport_PutSpriteSequence LevelBuffer, FALSE, SPRITE_LEVEL(FALSE, col, row), p, FALSE, 0
      End If
    Next
  Next
  Viewport_LineC LevelBuffer, FALSE, _Min(sel_topleft.col, sel_botright.col) * BLOCK_SIZE%, _Min(sel_topleft.row, sel_botright.row) * BLOCK_SIZE%, (_Max(sel_topleft.col, sel_botright.col) + 1) * BLOCK_SIZE% - 1, (_Max(sel_topleft.row, sel_botright.row) + 1) * BLOCK_SIZE% - 1, COLOR_CURSOR&, TRUE, FALSE, 0

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
      Case T_MARK
        SpriteSequence_Copy SPRITE_LEVEL(Abs(isfront), col, row), SPR_LEVEL(LVL_MARK)
      Case T_SNOW
        If Dodu.HasRackets Then
          PrepareSnow m, col, row, FALSE
        End If
      Case T_ROPE
        PrepareRope m, col, row
    End Select
  Else
    If e = T_SNOW And Not Dodu.HasRackets Then
      PrepareSnow m, col, row, TRUE
    End If
  End If
  SpriteSequence_Start LVL_SPRITES(col, row)
End Sub

Sub PrepareRope (m As LevelMap, col As Integer, row As Integer)
  If (row < M_H - 1 _AndAlso m.Topo(col, row + 1) <> T_ROPE) _OrElse row = M_H - 1 Then
    SpriteSequence_Copy SPRITE_LEVEL(0, col, row), SPR_LEVEL(LVL_ROPE_E)
  Else
    SpriteSequence_Copy SPRITE_LEVEL(0, col, row), SPR_LEVEL(LVL_ROPE_M)
  End If
  If row > 0 _AndAlso m.Topo(col, row - 1) = T_ROPE Then
    SpriteSequence_Copy SPRITE_LEVEL(0, col, row - 1), SPR_LEVEL(LVL_ROPE_M)
  End If
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


