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
$ErrorLocation:On

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
Point_Set SCREEN_DIMS, 80, 64

' Frame rate
Const FPS% = 25

' Window scaling factor
Const SCALE% = 6

' Threshold to enable block holding/dropping (px)
Const CLIMB_THRESHOLD% = 1
Const TAKE_THRESHOLD% = 5
Const DROP_THRESHOLD% = 5
Const UNCLIMB_THRESHOLD% = 5


' Number of frames between ticks of the thermometer
Const THERMO_TICK_NORMAL% = 100
Const THERMO_TICK_FAST% = 35

' Number of frames between ticks of the slip ticker
Const SLIP_TICK_NORMAL% = 2

' Location of level number
Dim Shared PT_LEVEL_NB As Point
Point_Set PT_LEVEL_NB, 4, 20

' Number of screen pixels per frame
' Currently, can only be an integer
Const WALKING_SPEED# = 1

Dim PLAY_MUSIC As Integer
Let PLAY_MUSIC = TRUE

Dim Shared SCANLINES As Integer
Let SCANLINES = FALSE

' --------------------------
' Other includes (declarations)
' --------------------------
'$Include:'Geometry.bi'
'$Include:'Ticker.bi'
'$Include:'Sprites.bi'
'$Include:'Keyboard.bi'
'$Include:'Sounds.bi'
'$Include:'Levels.bi'
'$Include:'Passwords.bi'

' --------------------------
' Levels
' --------------------------
LoadLevels
Dim Shared CURRENT_LEVEL As Integer
Let CURRENT_LEVEL = 0


' --------------------------
' Command line arguments
' --------------------------
' Video modes
Const IMG_MODE_CGA$ = "cga"
Const IMG_MODE_EGA$ = "ega"
Const IMG_MODE_HER$ = "her"

Dim Shared IMG_MODE As String
Let IMG_MODE = IMG_MODE_EGA$

Dim argc As Integer, toset As String
For argc = 1 To _CommandCount
  Select Case Command$(argc)
    Case "--nomusic"
      Let PLAY_MUSIC = FALSE
    Case "--scanlines"
      Let SCANLINES = TRUE
    Case "--level"
      Let toset = "level"
    Case "--video"
      Let toset = "video"
    Case Else
      Select Case toset
        Case "level"
          Let CURRENT_LEVEL = Val(Command$(argc)) - 1
        Case "video"
          Select Case UCase$(Command$(argc))
            Case "HER"
              Let IMG_MODE$ = IMG_MODE_HER$
            Case "CGA"
              Let IMG_MODE$ = IMG_MODE_CGA$
            Case "EGA"
              Let IMG_MODE$ = IMG_MODE_EGA$
          End Select
      End Select
  End Select
Next

' Loading assets
'$Include:'Assets.bi'

' --------------------------
' Player
' --------------------------

Type Player
  LevPos As Point
  SpriteIndex As Integer
  IsWalking As Integer
  HasBlock As Integer
  IsClimbing As Integer
  IsFalling As Integer
  ToLeft As Integer
  Temp As Integer ' 0 to 10
  ThermoTick As Ticker
  ThermoFlash As Integer
  HasMittens As Integer
  HasTuque As Integer
  SlipTick As Ticker
  SlipDir As Integer
End Type

' --------------------------
' Screen setup: 1 main screen and 1 buffer
' --------------------------
_AllowFullScreen _Off
Dim Shared MainScreen As Viewport, ImgBuffer As Viewport

' Game state
Dim Shared Dodu As Player, DoduPast As Player
Let Dodu.SpriteIndex = 0
Let Dodu.HasBlock = FALSE
Let Dodu.IsClimbing = 0
Let Dodu.Temp = 10
Let Dodu.HasMittens = FALSE
Let Dodu.HasTuque = FALSE


' --------------------------
' Main loop
' --------------------------
Let Audio.PlaySong = PLAY_MUSIC%
Let Audio.PlayEffects = TRUE

Dim Shared CURRENT_TRAJECTORY As Integer
Let CURRENT_TRAJECTORY% = -1
Dim Shared CurrentSprite As SpriteSequence

Dim Shared parallax As Point
Point_Set parallax, 2, 2

LoadPasswords
MainLoop

Sub MainLoop
  Do
    Viewport_Init MainScreen, SCREEN_DIMS, P_ORIGIN, SCREEN_DIMS, SCALE
    Viewport_Init_Default ImgBuffer, SCREEN_DIMS, SCREEN_DIMS
    Dim rst As RestorePoint
    Screen MainScreen.Buffer

    DoIntroduction rst
    If rst.Level >= 0 Then
      Let CURRENT_LEVEL = rst.Level
      Let Dodu.HasMittens = rst.HasMittens
      Let Dodu.HasTuque = rst.HasTuque
    End If
    Dim dummy As Integer
    ' Wait 1 sec
    For dummy = 0 To FPS%
      _Limit FPS%
    Next
    SoundPlayer_PlaySong Audio, 0
    Do
      Dim ws As Point
      Point_Set ws, Levels(CURRENT_LEVEL).Width * BLOCK_SIZE%, Levels(CURRENT_LEVEL).Height * BLOCK_SIZE%
      Viewport_Init MainScreen, SCREEN_DIMS, P_ORIGIN, SCREEN_DIMS, SCALE
      Let MainScreen.Scanlines = SCANLINES
      Viewport_Init_Default ImgBuffer, SCREEN_DIMS, ws
      Viewport_SetFont ImgBuffer, FNT_TINYC
      DoLevel
      SoundPlayer_PlayEffect Audio, SND_LEVELUP
      Let CURRENT_LEVEL = CURRENT_LEVEL + 1
    Loop
  Loop
End Sub

Sub DoLevel
  Dim CTRL_PRESSED As Integer, PANBACK_STEPS As Integer
  Dim panback_ticker As Ticker
  Dim dod_lastgrab As Point
  Dim sq_lastgrab As Square, sq_lastdrop As Square
  Dim center As Point, panbacktarget As Point
  Dim trjP As Point, lp As Point, moveP As Point, panP As Point

  Dim climbP As Square, takeP As Square, dropP As Square
  Dim unclimbP As Square, blockingP As Square, poleP As Square
  Dim mittensP As Square, tuqueP As Square, cookieP As Square

  Let CTRL_PRESSED = FALSE
  Let PANBACK_STEPS = 8
  Let Dodu.Temp = 10

  Ticker_Init Dodu.ThermoTick, 10, THERMO_TICK_NORMAL%, FALSE
  Ticker_Init Dodu.SlipTick, 6, SLIP_TICK_NORMAL%, FALSE
  Ticker_Init panback_ticker, PANBACK_STEPS, 1, FALSE

  Viewport_SetBackground ImgBuffer, _
    Backgrounds(Levels(CURRENT_LEVEL%).Background), parallax

  Color COLOR_PINK&, , , ImgBuffer.Buffer
  _PrintMode _KeepBackground , ImgBuffer.Buffer
  Screen MainScreen.Buffer

  Let Dodu.LevPos.x = Levels(CURRENT_LEVEL).StartPoint.col * BLOCK_SIZE%
  Let Dodu.LevPos.y = (Levels(CURRENT_LEVEL).StartPoint.row - 2) * BLOCK_SIZE%

  Square_Set sq_lastgrab, -1, -1
  Square_Set sq_lastdrop, -1, -1
  Point_Set trjP, -1, -1

  GetDoduCenter center
  Viewport_SetCenter ImgBuffer, center

  ' Force initial animation selection
  Let DoduPast.HasBlock = 10
  GetDoduSprite CurrentSprite, Dodu, DoduPast

  Do
    _Limit FPS%

    ' ---------------------------------------
    ' 1. Input and ordinary simulation
    ' ---------------------------------------

    ReadJoystick
    Viewport_Tick ImgBuffer

    ' Thermometer
    Ticker_Tick Dodu.ThermoTick

    If Dodu.ThermoTick.TickCnt = 0 Or _
       (Dodu.Temp < 3 And Dodu.ThermoTick.TickCnt Mod FPS% = 0) Then
      SoundPlayer_PlayEffect Audio, SND_THERMO%
    End If

    If Dodu.ThermoTick.TickCnt = 0 Then
      Let Dodu.Temp = Dodu.Temp - 1
    End If

    If Dodu.Temp = 0 Then
      If Dodu.HasMittens And Not Dodu.HasTuque Then
        Let Dodu.HasMittens = FALSE
        Let Dodu.Temp = 5
        Ticker_Reset Dodu.ThermoTick
      ElseIf Not Dodu.HasMittens And Dodu.HasTuque Then
        Let Dodu.HasTuque = FALSE
        Let Dodu.Temp = 5
        Ticker_Reset Dodu.ThermoTick
      ElseIf Dodu.HasMittens And Dodu.HasTuque Then
        If Dodu.HasBlock Then
          Let Dodu.HasMittens = FALSE
        Else
          Let Dodu.HasTuque = FALSE
        End If
        Let Dodu.Temp = 5
        Ticker_Reset Dodu.ThermoTick
      Else
        GoTo GameOver:
      End If
    End If

    ' Modal commands
    If _KeyDown(K_ESC) Then GoTo Quit:

    If _KeyDown(K_SPACE) Then
      DoPause
      _Continue
    End If

    If _KeyDown(K_M_UC) Or _KeyDown(K_M_LC) Then
      DoMiniMap
      _Continue
    End If

    ' ---------------------------------------
    ' 2. Calculate squares of interest
    ' ---------------------------------------

    Let lp = Dodu.LevPos

    ClimbableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), climbP
    TakeableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), takeP
    DroppableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), dropP
    UnclimbableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), unclimbP
    BlockingSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), blockingP
    PoleSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), poleP
    MittensSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), mittensP
    TuqueSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), tuqueP
    CookieSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), cookieP

    ' ---------------------------------------
    ' 3. Active movement trajectory
    ' ---------------------------------------

    If CURRENT_TRAJECTORY% >= 0 And CURRENT_TRAJECTORY% < 100 Then

      Trajectory_Tick Trajectories(CURRENT_TRAJECTORY%), trjP
      MovePlayer ImgBuffer, trjP

      If Ticker_IsFinished%(Trajectories(CURRENT_TRAJECTORY%).Ticker) Then
        Trajectory_Reset Trajectories(CURRENT_TRAJECTORY)
        Let CURRENT_TRAJECTORY% = -1
      End If

      GoTo RenderFrame:
    End If

    ' ---------------------------------------
    ' 4. Goal
    ' ---------------------------------------

    If Square_IsValid(poleP) Then Exit Sub

    ' ---------------------------------------
    ' 4'. Power-ups
    ' ---------------------------------------
    If Square_IsValid(mittensP) Then
      TakeMittens Levels(CURRENT_LEVEL), mittensP
    End If

    If Square_IsValid(tuqueP) Then
      TakeTuque Levels(CURRENT_LEVEL), tuqueP
    End If

    If Square_IsValid(cookieP) Then
      TakeCookie Levels(CURRENT_LEVEL), cookieP
    End If



    ' ---------------------------------------
    ' 5. Pan-back initiation
    ' ---------------------------------------

    If Not _KeyDown(K_CTRL) And CTRL_PRESSED = TRUE And _
       CURRENT_TRAJECTORY < 0 Then

      Let CTRL_PRESSED = FALSE
      Let CURRENT_TRAJECTORY% = TRJ_PANBACK%

      GetDoduCenter center

      Point_Set panbacktarget, _
        (center.x - ImgBuffer.Pan.x - ImgBuffer.Size.x / 2) / PANBACK_STEPS%, _
        (center.y - ImgBuffer.Pan.y - ImgBuffer.Size.y / 2) / PANBACK_STEPS%
    End If

    ' ---------------------------------------
    ' 6. Pan-back trajectory
    ' ---------------------------------------

    If CURRENT_TRAJECTORY% = TRJ_PANBACK% Then

      Ticker_Tick panback_ticker
      Viewport_MovePan ImgBuffer, panbacktarget

      If Ticker_IsFinished%(panback_ticker) Then
        Let CURRENT_TRAJECTORY% = -1
        Ticker_Reset panback_ticker
      End If

      GoTo RenderFrame:
    End If

    ' ---------------------------------------
    ' 7. Manual viewport panning
    ' ---------------------------------------

    If _KeyDown(K_CTRL) Then

      If IsLeft% Then
        Point_Set panP, -3, 0
      ElseIf IsRight% Then
        Point_Set panP, 3, 0
      ElseIf IsUp% Then
        Point_Set panP, 0, -3
      ElseIf IsDown% Then
        Point_Set panP, 0, 3
      Else
        GoTo RenderFrame:
      End If

      Viewport_MovePan ImgBuffer, panP
      Let CTRL_PRESSED = TRUE

      GoTo RenderFrame:
    End If

    ' ---------------------------------------
    ' 8. Ordinary player controls
    ' ---------------------------------------

    If IsLeft% Then

      Let Dodu.ToLeft = TRUE
      Let Dodu.SlipDir = -1

      If Square_IsValid(climbP) Then

        Let Dodu.IsWalking = TRUE
        Let CURRENT_TRAJECTORY% = TRJ_CLIMBING%
        Let Trajectories(CURRENT_TRAJECTORY%).Flipped = TRUE

      Else

        If Not Square_IsValid(blockingP) Then
          Point_Set moveP, -1, 0
          Let Dodu.IsWalking = TRUE
          MovePlayer ImgBuffer, moveP
        Else
          Let Dodu.IsWalking = FALSE
        End If

      End If

      If Square_IsValid(unclimbP) Then
        Let Dodu.IsWalking = FALSE
        Let CURRENT_TRAJECTORY% = TRJ_FALLING%
        Let Trajectories(CURRENT_TRAJECTORY%).Flipped = TRUE
      End If

    ElseIf IsRight% Then

      Let Dodu.ToLeft = FALSE
      Let Dodu.SlipDir = 1

      If Square_IsValid(climbP) Then

        Let Dodu.IsWalking = TRUE
        Let CURRENT_TRAJECTORY% = TRJ_CLIMBING%
        Let Trajectories(CURRENT_TRAJECTORY%).Flipped = FALSE

      Else

        If Not Square_IsValid(blockingP) Then
          Point_Set moveP, 1, 0
          Let Dodu.IsWalking = TRUE
          MovePlayer ImgBuffer, moveP
        Else
          Let Dodu.IsWalking = FALSE
        End If

      End If

      If Square_IsValid(unclimbP) Then
        Let Dodu.IsWalking = FALSE
        Let CURRENT_TRAJECTORY% = TRJ_FALLING%
        Let Trajectories(CURRENT_TRAJECTORY%).Flipped = FALSE
      End If

    ElseIf IsUp% And Square_IsValid(takeP) Then

      SoundPlayer_PlayEffect Audio, SND_GRAB%
      TakeBlock Levels(CURRENT_LEVEL), takeP

      Point_Set dod_lastgrab, Dodu.LevPos.x, Dodu.LevPos.y
      Let sq_lastgrab.col = takeP.col
      Let sq_lastgrab.row = takeP.row
      Let Dodu.ThermoTick.Speed = THERMO_TICK_FAST%

      Let Dodu.IsWalking = FALSE

    ElseIf IsDown% And Square_IsValid(dropP) Then

      SoundPlayer_PlayEffect Audio, SND_DROP%

      Let sq_lastdrop.col = dropP.col
      Let sq_lastdrop.row = dropP.row

      DropBlock Levels(CURRENT_LEVEL), dropP
      Let Dodu.ThermoTick.Speed = THERMO_TICK_NORMAL%

      Let Dodu.IsWalking = FALSE

    ElseIf _KeyDown(K_BACKSPACE) And _
           Square_IsValid(sq_lastgrab) And _
           Square_IsValid(sq_lastdrop) Then

      ' Undo last block
      Let Dodu.LevPos.x = dod_lastgrab.x
      Let Dodu.LevPos.y = dod_lastgrab.y

      Let CURRENT_TRAJECTORY% = TRJ_PANBACK%

      Let Levels(CURRENT_LEVEL).Topo(sq_lastdrop.col, sq_lastdrop.row) = T_NOTHING
      Let Levels(CURRENT_LEVEL).Topo(sq_lastgrab.col, sq_lastgrab.row) = T_BLOCK_W

      Square_Set sq_lastgrab, -1, -1
      Square_Set sq_lastdrop, -1, -1

      GetDoduCenter center

      Point_Set panbacktarget, _
        (center.x - ImgBuffer.Pan.x - ImgBuffer.Size.x / 2) / PANBACK_STEPS%, _
        (center.y - ImgBuffer.Pan.y - ImgBuffer.Size.y / 2) / PANBACK_STEPS%

      Let Dodu.IsWalking = FALSE
      SoundPlayer_PlayEffect Audio, SND_UNDO%

    Else

      ' No applicable control
      Let Dodu.IsWalking = FALSE

      If Dodu.SlipDir <> 0 Then
        Ticker_Tick Dodu.SlipTick
      End If

      If Not Ticker_IsFinished%(Dodu.SlipTick) Then

        If Dodu.SlipTick.TickCnt = 0 Then
          Dim slipP As Point
          Point_Set slipP, Dodu.SlipDir, 0
          MovePlayer ImgBuffer, slipP
        End If

      Else

        Let Dodu.SlipDir = 0
        Ticker_Reset Dodu.SlipTick

      End If

    End If

    ' ---------------------------------------
    ' 9. Common animation and rendering
    ' ---------------------------------------

    RenderFrame:

    ' Select a different sequence only when the player state changes.
    GetDoduSprite CurrentSprite, Dodu, DoduPast

    ' Orientation is independent of animation selection.
    Let CurrentSprite.Flipped = Dodu.ToLeft

    ' Advance exactly once per game frame.
    SpriteSequence_Tick CurrentSprite

    If Dodu.IsWalking And CurrentSprite.Ticker.TickCnt = 0 And _
       CurrentSprite.Ticker.Index Mod 2 = 0 Then
      SoundPlayer_PlayEffect Audio, SND_STEP%
    End If

    ' Draw the complete frame.
    Viewport_Clear ImgBuffer

    DrawLevel ImgBuffer, Levels(CURRENT_LEVEL)
    DrawPlayer ImgBuffer
    DrawThermometer ImgBuffer

    HighlightBlock ImgBuffer, Levels(CURRENT_LEVEL), takeP, HIGHLIGHT_COLOR&
    HighlightBlock ImgBuffer, Levels(CURRENT_LEVEL), dropP, HIGHLIGHT_COLOR&
    'HighlightBlock ImgBuffer, Levels(CURRENT_LEVEL), mittensP, COLOR_PINK&

    Viewport_Copy ImgBuffer, MainScreen
    Viewport_Display MainScreen

  Loop

  GameOver:
  DoGameOver
  End

  Quit:
  Cls
  End
End Sub

Sub DoGameOver
  SoundPlayer_StopSong Audio
  SoundPlayer_PlayEffect Audio, SND_GAMEOVER%
  'Cls
  Dim pw As Password
  GetPassword pw, CURRENT_LEVEL, Dodu.HasMittens, Dodu.HasTuque
  Viewport_Print ImgBuffer, "GAME OVER", P_ORIGIN
  Dim x As Integer, pws As String, cardP As Point
  For x = 0 To 3
    Point_Set cardP, 4 + x * 16, 20
    DisplayCard ImgBuffer, cardP, pw.Elements(x)
  Next
  Viewport_Copy ImgBuffer, MainScreen
  Viewport_Display MainScreen
  Do
    _Limit FPS%
  Loop While Not _KeyDown(K_ESC)
End Sub

Sub DoMiniMap
  Dim MapBuffer As Viewport
  Dim ws As Point
  Point_Set ws, Levels(CURRENT_LEVEL).Width * MINI_BLOCK_SIZE%, Levels(CURRENT_LEVEL).Height * MINI_BLOCK_SIZE%
  Viewport_Init_Default MapBuffer, SCREEN_DIMS, ws
  Viewport_SetBackground MapBuffer, Backgrounds(Levels(CURRENT_LEVEL).Background), P_ORIGIN
  Viewport_Clear MapBuffer
  DrawMinimap MapBuffer, Levels(CURRENT_LEVEL%)
  Viewport_Copy MapBuffer, MainScreen
  Viewport_Display MainScreen

  ' Wait until key is released
  Kbd_WaitRelease FPS%
  Do
    _Limit FPS%
    Viewport_Display MainScreen
    If _KeyDown(K_LEFT) Then
      Let MapBuffer.Pan.x = MapBuffer.Pan.x - 2
    ElseIf _KeyDown(K_RIGHT) Then
      Let MapBuffer.Pan.x = MapBuffer.Pan.x + 2
    ElseIf _KeyDown(K_M_UC) Or _KeyDown(K_M_LC) Then
      Exit Do
    End If
    Viewport_Clear MapBuffer
    DrawMinimap MapBuffer, Levels(CURRENT_LEVEL%)
    Viewport_Copy MapBuffer, MainScreen
  Loop
  Kbd_WaitRelease FPS%
End Sub

Sub DoPause
  Dim p As Point
  Point_Set p, 30, 24
  Viewport_Print ImgBuffer, " PAUSE ", p
  Viewport_Copy ImgBuffer, MainScreen
  Viewport_Display MainScreen

  ' Wait for the SPACE that invoked us to be released
  Dim k As Long
  Do
    _Limit FPS%
    k = _KeyHit
  Loop While k <> K_SPACE
End Sub

' --------------------------
' Draws a level
' --------------------------
Sub DrawLevel (v As Viewport, m As LevelMap)
  Dim col, row As Integer
  For row = 0 To m.Height
    For col = 0 To m.Width
      Dim s As Square
      Let s.col = col
      Let s.row = row
      Dim p As Point
      Square_ToPoint s, p
      Select Case m.Topo(col, row)
        Case T_BLOCK_B
          Viewport_PutSprite v, FALSE, BlockBlue, p, FALSE
        Case T_BLOCK_W
          Viewport_PutSprite v, FALSE, BlockWhite, p, FALSE
        Case T_POLE
          Viewport_PutSprite v, FALSE, Pole, p, FALSE
        Case T_COOKIE
          Viewport_PutSprite v, FALSE, Cookie, p, FALSE
        Case T_MITTENS
          Viewport_PutSprite v, FALSE, SprMittens, p, FALSE
        Case T_TUQUE
          Viewport_PutSprite v, FALSE, SprTuque, p, FALSE
      End Select
    Next
  Next
  Dim dod_p As Point
  Let dod_p = Dodu.LevPos

End Sub

Sub DrawMinimap (v As Viewport, m As LevelMap)
  Dim col, row As Integer
  For row = 0 To m.Height
    For col = 0 To m.Width
      Dim s As Square
      Let s.col = col
      Let s.row = row
      Dim p As Point
      Point_Set p, s.col * 5, s.row * 5
      Select Case m.Topo(col, row)
        Case T_BLOCK_B
          Viewport_PutSprite v, FALSE, MiniBlockBlue, p, FALSE
        Case T_BLOCK_W
          Viewport_PutSprite v, FALSE, MiniBlockWhite, p, FALSE
        Case T_POLE
          Viewport_PutSprite v, FALSE, MiniPole, p, FALSE
      End Select
    Next
  Next
  Dim dod_s As Square
  Let dod_s.col = Dodu.LevPos.x \ BLOCK_SIZE%
  Let dod_s.row = Dodu.LevPos.y \ BLOCK_SIZE%
  Dim dod_p As Point
  Point_Set dod_p, dod_s.col * MINI_BLOCK_SIZE%, (dod_s.row + 1) * MINI_BLOCK_SIZE%
  Viewport_PutSprite v, FALSE, DoduSmall, dod_p, FALSE
End Sub


' --------------------------
' Player drawing
' --------------------------
Sub DrawPlayer (v As Viewport)
  Dim s As Sprite
  CurrentSprite.Flipped = Dodu.ToLeft
  Viewport_PutSpriteSequence v, FALSE, CurrentSprite, Dodu.LevPos
End Sub

Sub DrawThermometer (v As Viewport)
  Dim p As Point
  Point_Set p, 4, 4
  Viewport_PutSprite v, TRUE, Thermometer, p, FALSE
  Dim red As Long
  Let red = THERMO_RED&
  If Dodu.Temp <= 2 Then
    If Dodu.ThermoFlash < 10 Then
      Let red = THERMO_BLUE&
    Else
      Let red = THERMO_RED&
    End If
    Let Dodu.ThermoFlash = (Dodu.ThermoFlash + 1) Mod 20
  End If
  Viewport_LineC v, TRUE, 6, 15 - Dodu.Temp, 7, 15, red, TRUE, TRUE
  Viewport_LineC v, TRUE, 5, 16, 8, 18, red, TRUE, TRUE
End Sub


Sub TakeBlock (m As LevelMap, p As Square)
  Let m.Topo(p.col, p.row) = T_NOTHING
  Let Dodu.HasBlock = TRUE
End Sub

Sub TakeTuque (m As LevelMap, p As Square)
  Let m.Topo(p.col, p.row) = T_NOTHING
  Let Dodu.HasTuque = TRUE
End Sub

Sub TakeCookie (m As LevelMap, p As Square)
  Let m.Topo(p.col, p.row) = T_NOTHING
  Let Dodu.Temp = Clamp%(Dodu.Temp + 3, 0, 10)
End Sub


Sub TakeMittens (m As LevelMap, p As Square)
  Let m.Topo(p.col, p.row) = T_NOTHING
  Let Dodu.HasMittens = TRUE
End Sub

Sub DropBlock (m As LevelMap, p As Square)
  Let m.Topo(p.col, p.row) = T_BLOCK_W
  Let Dodu.HasBlock = FALSE
End Sub

Sub MovePlayer (v As Viewport, p_to As Point)
  If p_to.x < 0 Then Dodu.ToLeft = TRUE
  If p_to.x > 0 Then Dodu.ToLeft = FALSE
  ' Otherwise, leave in its current state
  Let CurrentSprite.Flipped = Dodu.ToLeft
  Dim ScreenPos As Point
  ' Demo1.bas, MovePlayer
  Viewport_PointToScreen v, Dodu.LevPos, ScreenPos
  Let Dodu.LevPos.x = Dodu.LevPos.x + (p_to.x * WALKING_SPEED#)
  Let Dodu.LevPos.y = Dodu.LevPos.y + (p_to.y * WALKING_SPEED#)
  If p_to.x <> 0 Then
    Select Case Dodu.ToLeft
      Case FALSE ' Going right, x > 0
        If ScreenPos.x >= 20 Then
          'Let v.Pan.x = _Min(v.Pan.x + (p_to.x * WALKING_SPEED#), M_W% * BLOCK_SIZE%)
          Viewport_MovePan v, p_to
        End If
      Case TRUE ' Going left, x < 0
        If ScreenPos.x <= 10 Then
          Viewport_MovePan v, p_to
          'Let v.Pan.x = _Max(v.Pan.x + (p_to.x * WALKING_SPEED#), 0)
        End If
    End Select
  End If
  If p_to.y > 0 Then '   Going down, y > 0
    If ScreenPos.y >= 20 Then
      Viewport_MovePan v, p_to
      'Let v.Pan.y = _Min(v.Pan.y + (p_to.y * WALKING_SPEED#), M_H% * BLOCK_SIZE%)
    End If
  ElseIf p_to.y < 0 Then '  Going up, y < 0
    If ScreenPos.y <= 25 Then
      Viewport_MovePan v, p_to
      'Let v.Pan.y = _Max(v.Pan.y + (p_to.y * WALKING_SPEED#), 0)
    End If
  End If
End Sub

Sub HighlightBlock (v As Viewport, m As LevelMap, s As Square, c~&)
  If Square_IsValid(s) Then
    Dim p1 As Point, p2 As Point
    Square_ToPoint s, p1
    Point_Set p2, p1.x + BLOCK_SIZE% - 1, p1.y + BLOCK_SIZE% - 1
    Viewport_Line v, FALSE, p1, p2, c~&, TRUE, FALSE
  End If
End Sub

Sub SetFlipSprites (flipped As Integer)
  Dim x As Integer
  For x = 0 To 1
    Let DoduSprites(x).Flipped = flipped
  Next
End Sub

Sub GetDoduSprite (s As SpriteSequence, DoduNow As Player, DoduPast As Player)
  If PlayerChanged(DoduNow, DoduPast) Then
    Let s = DOD_SPRITES(Abs(DoduNow.IsWalking), _
      Abs(DoduNow.HasBlock), _
      Abs(DoduNow.HasMittens), _
      Abs(DoduNow.HasTuque))
    Let DoduPast = DoduNow
  End If
End Sub

Function PlayerChanged (p_now As Player, p_past As Player)
  Let PlayerChanged = Not (p_now.HasBlock = p_past.HasBlock And p_now.HasMittens = p_past.HasMittens And p_now.HasTuque = p_past.HasTuque And p_now.IsWalking = p_past.IsWalking)
End Function

Sub GetDoduCenter (p As Point)
  Point_Set p, Dodu.LevPos.x + (PLAYER_WIDTH% / 2), Dodu.LevPos.y + (PLAYER_HEIGHT% / 2)
End Sub

Sub DisplayCard (v As Viewport, p As Point, value As Integer)
  Dim suit As Integer, nb As Integer
  Dim p1 As Point, p2 As Point
  Let suit = value \ 13
  Let nb = value Mod 13
  Viewport_PutSprite v, FALSE, Card, p, FALSE
  Point_Set p1, p.x + 5, p.y + 9
  Viewport_PutSprite v, FALSE, Suits(suit), p1, FALSE
  Point_Set p2, p.x + 2, p.y + 2
  Viewport_PutSprite v, FALSE, Numbers(nb), p2, FALSE
End Sub

Sub DoPasswordInput (rst As RestorePoint)
  SoundPlayer_StopSong Audio
  SoundPlayer_PlaySong Audio, SNG_CARDS%
  Dim PwBuffer As Viewport, ws As Point
  Point_Set ws, SCREEN_DIMS.x, 1000
  Viewport_Init_Default PwBuffer, SCREEN_DIMS, ws
  Viewport_Clear PwBuffer
  Dim prlx As Point
  Point_Set prlx, 2, 2
  Viewport_SetBackground PwBuffer, Backgrounds(2), prlx
  Dim x As Integer, y As Integer, p As Point, q As Point
  Dim down As Point, up As Point
  Dim coord_row As Integer, coord_col As Integer
  Dim selection(4) As Integer
  Dim selindex As Integer
  Let selindex = 0
  Let coord_row = 0
  Let coord_col = 0
  Do
    _Limit FPS%

    Viewport_Clear PwBuffer
    Viewport_Tick PwBuffer

    ' Show cards
    Point_Set up, 0, -4
    Point_Set down, 0, 4
    For y = 0 To 12
      For x = 0 To 3
        Point_Set p, x * 18 + 5, y * 22
        DisplayCard PwBuffer, p, x * 13 + y
      Next
    Next

    ' Show previously selected cards
    Dim n As Integer, scr As Integer, scc As Integer
    For n = 0 To selindex - 1
      Let scr = selection(n) Mod 13
      Let scc = selection(n) \ 13
      Point_Set p, scc * 18 + 5, scr * 22
      Point_Set q, p.x + 16, p.y + 22
      Viewport_Line PwBuffer, FALSE, p, q, COLOR_YELLOW, TRUE, FALSE
    Next

    'Viewport_Print PwBuffer, Str$(selection(0)) + Str$(selection(1)) + Str$(selection(2)) + Str$(selection(3)), P_ORIGIN

    ' Show selected card
    Point_Set p, coord_col * 18 + 5, coord_row * 22
    Point_Set q, p.x + 16, p.y + 22
    Viewport_Line PwBuffer, FALSE, p, q, COLOR_RED, TRUE, FALSE

    Viewport_Copy PwBuffer, MainScreen
    Viewport_Display MainScreen

    ReadJoystick
    Dim moves As Integer: Let moves = FALSE
    If IsDown% Then
      Let coord_row = Clamp%(coord_row + 1, 0, 12)
      SoundPlayer_PlayEffect Audio, SND_TICK%
      Kbd_WaitRelease FPS%
      Let moves = TRUE
    ElseIf IsUp% Then
      Let coord_row = Clamp%(coord_row - 1, 0, 12)
      SoundPlayer_PlayEffect Audio, SND_TICK%
      Kbd_WaitRelease FPS%
      Let moves = TRUE
    ElseIf IsLeft% Then
      Let coord_col = Clamp%(coord_col - 1, 0, 3)
      SoundPlayer_PlayEffect Audio, SND_TICK%
      Kbd_WaitRelease FPS%
      Let moves = TRUE
    ElseIf IsRight% Then
      Let coord_col = Clamp%(coord_col + 1, 0, 3)
      SoundPlayer_PlayEffect Audio, SND_TICK%
      Kbd_WaitRelease FPS%
      Let moves = TRUE
    End If
    If moves Then
      Point_Set p, coord_col * 18 + 5, coord_row * 22
      Viewport_ScrollCenter PwBuffer, p, 6
    End If
    If _KeyDown(K_ENTER) Then
      Let selection(selindex) = coord_col * 13 + coord_row
      Let selindex = selindex + 1
      SoundPlayer_PlayEffect Audio, SND_TACK%
      Kbd_WaitRelease FPS%
      If selindex = 4 Then
        Screen 0
        LookupPassword rst, selection()
        If rst.Level < 0 Then
          SoundPlayer_PlayEffect Audio, SND_WRONG1%
        Else
          SoundPlayer_PlayEffect Audio, SND_LEVELUP%
        End If
        SoundPlayer_StopSong Audio
        Exit Sub
      End If
    End If
    If _KeyDown(K_SPACE) Then
      SoundPlayer_StopSong Audio
      Exit Sub
    End If
  Loop
  SoundPlayer_StopSong Audio
End Sub

Sub DoIntroduction (rst As RestorePoint)
  Dim p As Point
  Let rst.Level = -1
  Do
    _Limit FPS%
    Viewport_Clear ImgBuffer
    Point_Set p, 30, 26
    Viewport_Print ImgBuffer, "START", p
    Point_Set p, 30, 32
    Viewport_Print ImgBuffer, "PASSWORD", p
    Viewport_Copy ImgBuffer, MainScreen
    Viewport_Display MainScreen
    If _KeyDown(K_ENTER) Or _KeyDown(K_SPACE) Then
      Exit Do
    ElseIf _KeyDown(K_BACKSPACE) Then
      DoPasswordInput rst
      If rst.Level < 0 Then
        _Continue
      Else ' Valid password
        Exit Sub
      End If
    End If
  Loop
End Sub

Function IsLeft% ()
  Let IsLeft% = In_Down(K_LEFT)
End Function

Function IsRight% ()
  Let IsRight% = In_Down(K_RIGHT)
End Function

Function IsUp% ()
  Let IsUp% = In_Down(K_UP)
End Function

Function IsDown% ()
  Let IsDown% = In_Down(K_DOWN)
End Function



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
'$Include:'Passwords.bm'

' :mode=visualbasic:folding=explicit:wrap=none:
