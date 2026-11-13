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


$Console

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

' Window scaling factor
Const SCALE% = 3

' Refresh rate
Const FPS% = 25

' Colors
Const COLOR_BG& = _RGB32(83, 83, 255)
Const COLOR_BTN& = _RGB32(192, 192, 192)
Const COLOR_GRID& = _RGB32(64, 64, 64, 128)
Const COLOR_CURSOR& = _RGB32(255, 255, 0)

Const WALKING_SPEED# = 1

Dim Shared PtLevelNb As Point
Dim Shared PtUnit As Point
Point_Set PtUnit, 1, 1

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
Dim Shared WorldSize As Point
Point_Set WorldSize, MAP_WIDTH * BLOCK_SIZE, MAP_HEIGHT * BLOCK_SIZE

Point_Set ScreenDims, 512, 342
Dim Shared LevelDims As Point
Point_Set LevelDims, ScreenDims.x - PALETTE_WIDTH, ScreenDims.y - TOPBAR_HEIGHT
Dim Shared LevelTopLeft As Point
Point_Set LevelTopLeft, PALETTE_WIDTH, TOPBAR_HEIGHT + 1
Dim Shared PaletteTopLeft As Point, PaletteBotRight As Point
Point_Set PaletteTopLeft, 0, TOPBAR_HEIGHT + 1
Point_Set PaletteBotRight, PALETTE_WIDTH, ScreenDims.y
Const PALETTE_BTN_SIZE = 6
Dim Shared PtCoords1 As Point, PtCoords2 As Point
Point_Set PtCoords1, 3, PaletteBotRight.y - 22
Point_Set PtCoords2, 19, PaletteBotRight.y - 22

Const GUI_BUTTON_SIZE = 17
Dim Shared GuiIconButtonSize As Point
Point_Set GuiIconButtonSize, 11, 11

Const DEFAULT_FILENAME$ = "Untitled.lvl"


' --------------------------
' Level data
' --------------------------
Dim Shared CurrentLevel As Integer ' The editor always works on level slot 0

' Assets
'$Include:'Assets.bi'

' GUI
$ExeIcon:'/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Game_Icon.ico'

Dim Shared GuiTopBar(3) As SpriteSequence
SpriteSequence_InitFile GuiTopBar(0), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/TopBar_L.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT
SpriteSequence_InitFile GuiTopBar(1), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/TopBar_C.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT
SpriteSequence_InitFile GuiTopBar(2), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/TopBar_R.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT
Dim Shared GuiButton(3) As SpriteSequence
SpriteSequence_InitFile GuiButton(0), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_L.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT
SpriteSequence_InitFile GuiButton(1), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_C.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT
SpriteSequence_InitFile GuiButton(2), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_R.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT

Dim Shared GuiTopBarDodu As SpriteSequence
SpriteSequence_InitFile GuiTopBarDodu, "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Dodu_Icon.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT

Dim Shared GuiToolBar(4) As SpriteSequence
SpriteSequence_InitFile GuiToolBar(0), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_New.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT
SpriteSequence_InitFile GuiToolBar(1), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_Load.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT
SpriteSequence_InitFile GuiToolBar(2), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_Save.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT
SpriteSequence_InitFile GuiToolBar(3), "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_Undo.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT

Dim Shared GuiButtonIcon As SpriteSequence
SpriteSequence_InitFile GuiButtonIcon, "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Btn_Icon.png", 1, 1, FALSE, FALSE, PtOrigin, PtOrigin, COLOR_TRANSPARENT

Dim Shared PaletteButtons(16) As Integer
Let PaletteButtons(0) = LVL_HAND
Let PaletteButtons(1) = LVL_ERASER
Let PaletteButtons(2) = LVL_MARK
Let PaletteButtons(3) = LVL_BLOCK_B
Let PaletteButtons(4) = LVL_BLOCK_W
Let PaletteButtons(5) = LVL_POLE
Let PaletteButtons(6) = LVL_MITTENS
Let PaletteButtons(7) = LVL_TUQUE
Let PaletteButtons(8) = LVL_COFFEE
Let PaletteButtons(9) = LVL_COOKIE
Let PaletteButtons(10) = LVL_WATER
Let PaletteButtons(11) = LVL_SNOW_C
Let PaletteButtons(12) = LVL_ROPE_M

Dim Shared PaletteShortcuts(16) As String
Let PaletteShortcuts(0) = "H"
Let PaletteShortcuts(1) = " "
Let PaletteShortcuts(2) = "^"
Let PaletteShortcuts(3) = "@"
Let PaletteShortcuts(4) = "#"
Let PaletteShortcuts(5) = "!"
Let PaletteShortcuts(6) = "m"
Let PaletteShortcuts(7) = "t"
Let PaletteShortcuts(8) = "f"
Let PaletteShortcuts(9) = "c"
Let PaletteShortcuts(10) = "~"
Let PaletteShortcuts(11) = "S"
Let PaletteShortcuts(12) = "$"

Dim Shared LvlSprites(MAP_WIDTH, MAP_HEIGHT) As SpriteSequence
Dim Shared SpriteLevel(IMG_DEPTH, MAP_WIDTH, MAP_HEIGHT) As SpriteSequence
Dim Shared ClipboardLevel As LevelMap
Dim Shared ClipboardTopLeft As Square, ClipboardBotRight As Square
ResetLevelSprites

Let CFG_NEIGHBORS = FALSE

'Other assets
'Dim Shared ICN_MUSIC As SpriteSequence
'Dim Shared ICN_BG As SpriteSequence
'SpriteSequence_InitFile ICN_MUSIC, "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Music.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT
'SpriteSequence_InitFile ICN_BG, "/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Image.png", 1, 1, FALSE, FALSE, P_ORIGIN, P_ORIGIN, COLOR_TRANSPARENT


' --------------------------
' Screen setup
' --------------------------
_AllowFullScreen _Off

Dim Shared CurrentBg
Let CurrentBg = 10

Dim Shared MainScreen As Viewport, ImgBuffer As Viewport
Dim Shared LevelBuffer As Viewport, PaletteBuffer As Viewport
Viewport_Init ImgBuffer, ScreenDims, ScreenDims, PtOrigin, 1, 1
Dim Shared PaletteDims As Point
Point_Set PaletteDims, PaletteBotRight.x - PaletteTopLeft.x, PaletteBotRight.y - PaletteTopLeft.y
Viewport_Init PaletteBuffer, PaletteDims, PaletteDims, PtOrigin, 1, 1
Viewport_Init LevelBuffer, LevelDims, WorldSize, PtOrigin, 1, IMG_DEPTH
Viewport_Init MainScreen, ScreenDims, PtOrigin, PtOrigin, SCALE, 1
Let MainScreen.Scanlines = 1
Viewport_SetBackground LevelBuffer, Backgrounds(CurrentBg), PtUnit

' Initial screen setup
Screen MainScreen.Layers(0).Buffer
_Title "The Dodu Level Editor"
_Icon SprLevel(LVL_BLOCK_B).Content

Dim Shared sel_topleft As Square, sel_botright As Square
Square_Set sel_topleft, 0, 0
Square_Set sel_botright, 0, 0

Dim Shared UndoHead As Integer
Let UndoHead = 0

Dim lvln As Integer
For lvln = 0 To UNDO_LEVELS
    Let Levels(lvln).Height = MAP_HEIGHT
    Let Levels(lvln).Width = MAP_WIDTH
Next

Dim Shared selection As Integer
Let selection = 3
Dim Shared Dirty As Integer
Let Dirty = FALSE
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
    _ScreenMove _Middle
    Dim keyb As Integer
    Let filename = DEFAULT_FILENAME

    Dim khit As Long, shift As Integer, ctrl As Integer, alt As Integer, msinput As Integer, mousex As Integer, mousey As Integer
    Do
        _Limit FPS
        Let khit = _KeyHit
        Let shift = _KeyDown(KEY_LSHIFT) Or _KeyDown(KEY_RSHIFT)
        Let ctrl = _KeyDown(KEY_CTRL)
        Let alt = _KeyDown(KEY_ALT)
        Do While _MouseInput
            Let mousex = _MouseX \ SCALE
            Let mousey = _MouseY \ SCALE
        Loop
        'Viewport_Clear MainScreen
        'Viewport_Clear LevelBuffer
        TickAll
        DrawPalette
        DrawLevelGrid
        Viewport_PutViewport ImgBuffer, TRUE, PaletteBuffer, PaletteTopLeft, PtOrigin, PaletteDims, EYE_NONE
        Viewport_PutViewport ImgBuffer, TRUE, LevelBuffer, LevelTopLeft, PtOrigin, LevelDims, EYE_NONE
        DrawTopBar
        Dim undop As Point
        Point_Set undop, PALETTE_WIDTH + 2, TOPBAR_HEIGHT + 2
        BitmapFont_WriteString ImgBuffer, SfFont, undop, Str$(UndoHead) + " " + Levels(CurrentLevel).Topo(sel_topleft.col, sel_topleft.row), COLOR_BLACK, 0
        'BitmapFont_WriteString ImgBuffer, SF_FONT, undop, Str$(mousex) + " " + Str$(mousey), COLOR_BLACK, 0
        Viewport_Copy ImgBuffer, MainScreen, EYE_NONE
        Viewport_Display MainScreen, EYE_NONE

        If keyb Then
            Kbd_WaitRelease FPS
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
            ApplyToSquare sel_topleft, sel_botright, PaletteShortcuts(selection)
        End If

        If Kbd_Down(KEY_INS) Then
            Let keyb = TRUE
            If ctrl Then
                CopyRegion
            ElseIf shift Then
                PasteRegion TRUE
            End If
        End If

        If Kbd_Down(KEY_DEL) And shift Then
            Let keyb = TRUE
            CutRegion
        End If

        If Kbd_Down(KEY_BACKSPACE) Then
            Let keyb = TRUE
            ApplyUndo
        End If

        If (Kbd_Down(KEY_S_UC) Or Kbd_Down(KEY_S_LC)) And ctrl Then
            Let keyb = TRUE
            DoSave
        End If

        If Kbd_Down(KEY_B_LC) Then
            Let keyb = TRUE
            ToggleBackground 1
        End If

        If Kbd_Down(KEY_B_UC) Then
            Let keyb = TRUE
            ToggleBackground -1
        End If

        If Kbd_Down(KEY_LT) Then
            Let keyb = TRUE
            ToggleMusic -1
        End If

        If Kbd_Down(KEY_GT) Then
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
            If khit = Asc(PaletteShortcuts(i)) Or khit = Asc(LCase$(PaletteShortcuts(i))) Then
                Dim s As Integer
                Let selection = i
                Exit For
            End If
        Next

    Loop
End Sub

Sub ToggleBackground (direction As Integer)
    Let CurrentBg = (CurrentBg + direction) Mod 11
    Viewport_SetBackground LevelBuffer, Backgrounds(CurrentBg), PtOrigin
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
    If InRect(x, y, 0, 0, ScreenDims.x, TOPBAR_HEIGHT) Then
        HandleClickBar x, y
    ElseIf InRect(x, y, 0, TOPBAR_HEIGHT, PALETTE_WIDTH, ScreenDims.y) Then
        HandleClickPalette x, y - TOPBAR_HEIGHT
    ElseIf InRect(x, y, PALETTE_WIDTH + 1, TOPBAR_HEIGHT, ScreenDims.x, ScreenDims.y) Then
        HandleClickLevel x - (PALETTE_WIDTH + 1), y - TOPBAR_HEIGHT
    End If
End Sub

Sub HandleClickBar (x As Single, y As Single)
    ' Do nothing for the moment
End Sub

Sub CopyLevel (ifrom As Integer, ito As Integer)
    Dim col As Integer, row As Integer
    For col = 0 To MAP_WIDTH - 1
        For row = 0 To MAP_HEIGHT - 1
            Let Levels(ito).Topo(col, row) = Levels(ifrom).Topo(col, row)
        Next
    Next
End Sub

Sub HandleClickPalette (x As Single, y As Single)
    Dim i As Integer, x1 As Integer, y1 As Integer
    For i = 0 To 16
        Let x1 = 2 + (i Mod 2) * GuiIconButtonSize.x
        Let y1 = (i \ 2) * GuiIconButtonSize.y
        If InRect(x, y, x1, y1, x1 + GuiIconButtonSize.x, y1 + GuiIconButtonSize.y) Then
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
    If Dirty Then
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
    For col = 0 To MAP_WIDTH - 1
        For row = 0 To MAP_HEIGHT - 1
            Square_Set s, col, row
            ClearSpriteSquare s
            For lev = 0 To UNDO_LEVELS
                Let Levels(lev).Topo(col, row) = TILE_NOTHING
            Next
        Next
    Next
    Let filename = DEFAULT_FILENAME
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
    Viewport_PutSpriteSequence ImgBuffer, TRUE, GuiTopBar(0), p, FALSE, 0
    Point_Set p, ScreenDims.x - 6, 0
    Viewport_PutSpriteSequence ImgBuffer, TRUE, GuiTopBar(2), p, FALSE, 0
    Viewport_LineC ImgBuffer, TRUE, 6, 0, ScreenDims.x - 7, TOPBAR_HEIGHT, COLOR_WHITE, TRUE, TRUE, 0
    Point_Set p, 5, 5
    BitmapFont_WriteString ImgBuffer, SfFont, p, "The Dodu Level Editor " + Chr$(250) + " " + filename, COLOR_BLACK, 0
    Point_Set p, ScreenDims.x - 20, 1
    Viewport_PutSpriteSequence ImgBuffer, TRUE, GuiTopBarDodu, p, FALSE, 0
End Sub

Sub CopyRegion
    Dim col As Integer, row As Integer
    For col = 0 To MAP_WIDTH - 1
        For row = 0 To MAP_HEIGHT - 1
            Let ClipboardLevel.Topo(col, row) = Levels(CurrentLevel).Topo(col, row)
        Next
    Next
    ReorderPoints
    Square_Set ClipboardTopLeft, sel_topleft.col, sel_topleft.row
    Square_Set ClipboardBotRight, sel_botright.col, sel_botright.row
    'Square_Set sel_botright, sel_topleft.col, sel_topleft.row
End Sub

Sub DoSave
    Dim outfile As String
    If filename = DEFAULT_FILENAME Then
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
    Let contents = contents + "Data " + _Trim$(Str$(CurrentBg)) + ", 0, -1, 0" + Chr$(13)
    Let contents = contents + "Data 2, 2" + Chr$(13)
    Let contents = contents + "Data 0, 0" + Chr$(13)
    Dim lc As String
    For row = topleft.row To botright.row
        Let contents = contents + "Data " + Chr$(34)
        For col = topleft.col To botright.col
            Let lc = Levels(CurrentLevel).Topo(col, row)
            If lc = TILE_MARK Then Let lc = "*"
            Let contents = contents + lc
        Next
        Let contents = contents + Chr$(34) + Chr$(13)
    Next
    Let contents = contents + "Data " + Chr$(34) + TILE_END + Chr$(34)
    _WriteFile outfile, contents
    Let filename = outfile
End Sub

Sub ConvexEnvelope (topleft As Square, botright As Square)
    Dim row As Integer, col As Integer
    Square_Set topleft, 0, 0
    Square_Set botright, MAP_WIDTH - 1, MAP_HEIGHT - 1
    Dim min As Integer, max As Integer
    Let min = MAP_WIDTH: Let max = 0
    For row = 0 To MAP_HEIGHT - 1
        For col = 0 To MAP_WIDTH - 1
            If Levels(CurrentLevel).Topo(col, row) <> " " Then
                Let min = _Min(min, col)
                Let max = _Max(max, col)
            End If
        Next
    Next
    Let topleft.col = min
    Let botright.col = max
    Let min = MAP_HEIGHT: Let max = 0
    For col = 0 To MAP_WIDTH - 1
        For row = 0 To MAP_HEIGHT - 1
            If Levels(CurrentLevel).Topo(col, row) <> " " Then
                Let min = _Min(min, row)
                Let max = _Max(max, row)
            End If
        Next
    Next
    Let topleft.row = min
    Let botright.row = max
End Sub

Sub DoLoad
    If Dirty Then
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
    Let Dirty = FALSE
    DoNew
    Dim contents As String
    Let contents = _ReadFile$(infile)
    Dim idx As Integer, idxn As Integer
    Let idx = 1
    Dim file_lines(MAP_HEIGHT) As String, k As Integer, bgset As Integer
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
                Let CurrentBg = Val(Mid$(s_line, 6, 1))
                Let bgset = TRUE
            End If
            _Continue
        End If
        Let file_lines(k) = Mid$(s_line, 7, Len(s_line) - 7)
        Let k = k + 1
    Loop
    Level_LoadLevelArray CurrentLevel, file_lines(), k
    Viewport_SetBackground LevelBuffer, Backgrounds(CurrentBg), PtOrigin
    Dim p As Point
    Square_ToPoint sel_topleft, p
    Viewport_SetCenter LevelBuffer, p
    Let filename = infile
    Let UndoHead = 0
End Sub

Sub Level_LoadLevelArray (index As Integer, lines() As String, length As Integer)
    Let UndoHead = 0
    Let Levels(index).Height = length
    Let Levels(index).Width = Len(lines(0))
    ' Center level on map
    Dim offset As Square, cell As String
    Square_Set offset, (MAP_WIDTH - Levels(index).Width) \ 2, (MAP_HEIGHT - Levels(index).Height) \ 2
    Dim s As Square
    Dim col As Integer, row As Integer
    For row = 0 To Levels(index).Height - 1
        For col = 0 To Levels(index).Width - 1
            Square_Set s, col + offset.col, row + offset.row
            Let cell = Mid$(lines(row), col, 1)
            If cell = "*" Then Let cell = TILE_MARK
            Let Levels(CurrentLevel).Topo(col + offset.col, row + offset.row) = cell
            SetSpriteSquare Levels(CurrentLevel), FALSE, s.col, s.row, cell
            SpriteSequence_Start SpriteLevel(0, s.col, s.row)
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
    Viewport_PutSpriteSequence v, TRUE, GuiButton(0), p, FALSE, 0
    For x = p.x + 3 To p.x + 3 + Len(text) * SfFont.Width
        Point_Set p2, x, p.y
        Viewport_PutSpriteSequence v, TRUE, GuiButton(1), p2, FALSE, 0
    Next
    Point_Set p2, p.x + 3 + Len(text) * SfFont.Width, p.y
    Viewport_PutSpriteSequence v, TRUE, GuiButton(2), p2, FALSE, 0
    Point_Set p2, p.x + 3, p.y + 3
    BitmapFont_WriteString v, SfFont, p2, text, COLOR_BLACK, 0
End Sub

Sub DrawIconButton (v As Viewport, p As Point, icn As SpriteSequence)
    Viewport_PutSpriteSequence v, TRUE, GuiButtonIcon, p, FALSE, 0
End Sub

Sub MoveRegion (delta_col As Integer, delta_row As Integer)
    CreateUndoSnapshot
    ReorderPoints
    CutRegion
    Let sel_topleft.col = Clamp%(0, sel_topleft.col + delta_col, MAP_WIDTH - 1)
    Let sel_topleft.row = Clamp%(0, sel_topleft.row + delta_row, MAP_HEIGHT - 1)
    Let sel_botright.col = Clamp%(0, sel_botright.col + delta_col, MAP_WIDTH - 1)
    Let sel_botright.row = Clamp%(0, sel_botright.row + delta_row, MAP_HEIGHT - 1)
    PasteRegion FALSE
End Sub

Sub CreateUndoSnapshot
    If UndoHead = UNDO_LEVELS Then
        'Move all them one level down
        Dim l As Integer
        For l = 2 To UNDO_LEVELS
            CopyLevel l, l - 1
        Next
    Else
        Let UndoHead = UndoHead + 1
    End If
    Dim col As Integer, row As Integer
    For col = 0 To MAP_WIDTH - 1
        For row = 0 To MAP_HEIGHT - 1
            Let Levels(UndoHead).Topo(col, row) = Levels(CurrentLevel).Topo(col, row)
        Next
    Next
End Sub

Sub CutRegion
    CreateUndoSnapshot
    CopyRegion
    Dim col As Integer, row As Integer, s As Square
    For col = ClipboardTopLeft.col To ClipboardBotRight.col
        For row = ClipboardTopLeft.row To ClipboardBotRight.row
            Let Levels(CurrentLevel).Topo(col, row) = " "
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
    Square_Set offset, sel_topleft.col - ClipboardTopLeft.col, sel_topleft.row - ClipboardTopLeft.row
    For col = ClipboardTopLeft.col To ClipboardBotRight.col
        For row = ClipboardTopLeft.row To ClipboardBotRight.row
            If Within(col + offset.col, 0, MAP_WIDTH - 1) And Within(row + offset.row, 0, MAP_HEIGHT - 1) Then
                Let Levels(CurrentLevel).Topo(col + offset.col, row + offset.row) = ClipboardLevel.Topo(col, row)
                SetSpriteSquare Levels(CurrentLevel), FALSE, col + offset.col, row + offset.row, ClipboardLevel.Topo(col, row)
                SpriteSequence_Start SpriteLevel(0, col + offset.col, row + offset.row)
            End If
        Next
    Next
End Sub


Sub MoveSquareFocus (hor As Integer, ver As Integer, shift As Integer)
    If shift Then
        Let sel_botright.col = Clamp%(sel_botright.col + hor, 0, MAP_WIDTH - 1)
        Let sel_botright.row = Clamp%(sel_botright.row + ver, 0, MAP_HEIGHT - 1)
        'If sel_botright.row = sel_topleft.row And ver < 0 Then
        '  Let sel_botright.row = sel_botright.row - 1
        'End If
        'If sel_botright.col = sel_topleft.col And hor < 0 Then
        '  Let sel_botright.col = sel_botright.col - 1
        'End If
    Else
        Let sel_topleft.col = Clamp%(sel_topleft.col + hor, 0, MAP_WIDTH - 1)
        Let sel_topleft.row = Clamp%(sel_topleft.row + ver, 0, MAP_HEIGHT - 1)
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
        If PaletteShortcuts(i) = e Then
            Let IndexOf% = i
            Exit Function
        End If
    Next
End Function

Sub ResetLevelSprites
    Dim col As Integer, row As Integer, s As Square
    For col = 0 To MAP_WIDTH - 1
        For row = 0 To MAP_HEIGHT - 1
            Let Levels(CurrentLevel%).Topo(col, row) = " "
            Square_Set s, col, row
            ClearSpriteSquare s
        Next
    Next
    Let Levels(CurrentLevel%).Width = MAP_WIDTH
    Let Levels(CurrentLevel%).Height = MAP_HEIGHT
End Sub

Sub ApplyToSquare (topleft As Square, botright As Square, sel As String)
    Let Dirty = TRUE
    Dim col As Integer, row As Integer, s As Square
    ReorderPoints
    For col = topleft.col To botright.col
        For row = topleft.row To botright.row
            Square_Set s, col, row
            Let Levels(CurrentLevel).Topo(col, row) = PaletteShortcuts(selection)
            If PaletteShortcuts(selection) = TILE_NOTHING Then
                ClearSpriteSquare s
            Else
                PrintConsole Levels(CurrentLevel).Topo(col, row)
                SetSpriteSquare Levels(CurrentLevel), FALSE, col, row, sel
                SpriteSequence_Start SpriteLevel(0, col, row)
            End If
        Next
    Next
End Sub

Sub ApplyUndo
    If UndoHead = 0 Then Exit Sub ' Nothing to undo on the stack
    Dim s As Square
    Dim col As Integer, row As Integer
    For col = 0 To MAP_WIDTH - 1
        For row = 0 To MAP_HEIGHT - 1
            Let Levels(CurrentLevel%).Topo(col, row) = Levels(UndoHead).Topo(col, row)
            Square_Set s, col, row
            If Levels(CurrentLevel%).Topo(col, row) = " " Then
                ClearSpriteSquare s
            Else
                ApplyToSquare s, s, Levels(UndoHead%).Topo(col, row)
            End If
        Next
    Next
    Let UndoHead = _Max(0, UndoHead - 1)
End Sub

Sub DrawPalette
    Viewport_Clear PaletteBuffer
    Viewport_Line PaletteBuffer, TRUE, PtOrigin, PaletteDims, COLOR_BG, TRUE, TRUE, 0
    Dim p As Point, i As Integer, x As Integer, y As Integer
    'Buttons
    For i = 0 To 16
        Let x = 2 + (i Mod 2) * GuiIconButtonSize.x
        Let y = (i \ 2) * GuiIconButtonSize.y
        Point_Set p, x, y
        Viewport_PutSpriteSequence PaletteBuffer, TRUE, GuiButtonIcon, p, FALSE, 0
        Point_Set p, x + 2, y + 2
        Viewport_PutSpriteSequence PaletteBuffer, TRUE, SprMinimap(PaletteButtons(i)), p, FALSE, 0
    Next
    For i = 0 To 16
        If i = selection Then
            Let x = 2 + (i Mod 2) * GuiIconButtonSize.x
            Let y = (i \ 2) * GuiIconButtonSize.y
            Viewport_LineC PaletteBuffer, TRUE, x, y, x + GuiIconButtonSize.x, y + GuiIconButtonSize.y, COLOR_CURSOR, TRUE, FALSE, 0
            Exit For
        End If
    Next

    For i = 0 To 3
        Point_Set p, 5, 100 + i * 17
        Viewport_PutSpriteSequence PaletteBuffer, TRUE, GuiToolBar(i), p, FALSE, 0
    Next
    'PointSet
    'Viewport_PutSpriteSequence PaletteBuffer, TRUE, ICN_MUSIC, , p, FALSE
    ' Coordinates

    DrawNumber PaletteBuffer, PtCoords1, sel_topleft.col, 0
    DrawNumber PaletteBuffer, PtCoords2, sel_topleft.row, 0
End Sub

Sub DrawLevelGrid
    Viewport_Clear LevelBuffer
    Dim col As Integer, row As Integer
    For col = 0 To MAP_WIDTH - 1
        For row = 0 To MAP_HEIGHT - 1
            Viewport_LineC LevelBuffer, FALSE, col * BLOCK_SIZE - 1, row * BLOCK_SIZE, col * BLOCK_SIZE + 1, row * BLOCK_SIZE, COLOR_GRID, FALSE, FALSE, 0
            Viewport_LineC LevelBuffer, FALSE, col * BLOCK_SIZE, row * BLOCK_SIZE - 1, col * BLOCK_SIZE, row * BLOCK_SIZE + 1, COLOR_GRID, FALSE, FALSE, 0
        Next
    Next
    DrawLevel LevelBuffer, Levels(CurrentLevel), FALSE
    Viewport_LineC LevelBuffer, FALSE, _Min(sel_topleft.col, sel_botright.col) * BLOCK_SIZE, _Min(sel_topleft.row, sel_botright.row) * BLOCK_SIZE, (_Max(sel_topleft.col, sel_botright.col) + 1) * BLOCK_SIZE - 1, (_Max(sel_topleft.row, sel_botright.row) + 1) * BLOCK_SIZE - 1, COLOR_CURSOR, TRUE, FALSE, IMG_DEPTH - 1
End Sub

Sub TickAll
    Viewport_Tick LevelBuffer
    Dim row As Integer, col As Integer
    For row = 0 To MAP_HEIGHT - 1
        For col = 0 To MAP_WIDTH - 1
            SpriteSequence_Tick SpriteLevel(0, col, row)
            SpriteSequence_Tick SpriteLevel(1, col, row)
        Next
    Next
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


