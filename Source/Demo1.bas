Option Base 0
Option _Explicit
$ErrorLocation:On

' --------------------------
' Program constants
' --------------------------

' Booleans
Const TRUE = -1
Const FALSE = 0

' Screen dimensions
Dim Shared SCREEN_DIMS As Point
Point_Set SCREEN_DIMS, 80, 64

' Frame rate
Const FPS% = 25

' Window scaling factor
Const SCALE% = 6
Dim Shared WINDOW_DIMS As Point
Point_Set WINDOW_DIMS, SCREEN_DIMS.x * SCALE%, SCREEN_DIMS.y * SCALE%

' Threshold to enable block holding/dropping (px)
Const CLIMB_THRESHOLD% = 1
Const TAKE_THRESHOLD% = 5
Const DROP_THRESHOLD% = 5
Const UNCLIMB_THRESHOLD% = 5


' Number of frames between ticks of the thermometer
Const THERMO_TICK_NORMAL% = 100
Const THERMO_TICK_FAST% = 35

' Location of level number
Dim Shared PT_LEVEL_NB As Point
Point_Set PT_LEVEL_NB, 4, 20

' Number of screen pixels per frame
' Currently, can only be an integer
Const WALKING_SPEED# = 1

Const PLAY_MUSIC = FALSE

' --------------------------
' Includes (declarations)
' --------------------------
'$IncludeOnce
'$Include:'Utils.bi'
'$Include:'Geometry.bi'
'$Include:'Sprites.bi'
'$Include:'Keyboard.bi'
'$Include:'Sounds.bi'
'$Include:'Assets.bi'
'$Include:'Levels.bi'

' --------------------------
' Player
' --------------------------

Type Player
  LevPos As Point
  SpriteIndex As Integer
  HasBlock As Integer
  IsClimbing As Integer
  IsFalling As Integer
  ToLeft As Integer
  Temp As Integer ' 0 to 10
  ThermoTick As Ticker
  ThermoFlash As Integer
End Type

' --------------------------
' Screen setup: 1 main screen and 1 buffer
' --------------------------
_AllowFullScreen _Off
Dim Shared MainScreen As Viewport, ImgBuffer As Viewport
Viewport_Init MainScreen, WINDOW_DIMS, P_ORIGIN, 1
Viewport_Init_Default ImgBuffer, SCREEN_DIMS
Viewport_SetFont ImgBuffer, FNT_GRAPE
Color COLOR_PINK&, , , ImgBuffer.Buffer
_PrintMode _KeepBackground , ImgBuffer.Buffer

' --------------------------
' Level loading
' --------------------------
Dim Shared Levels(2) As LevelMap
' L1
Restore L1
LoadLevel Levels(0)
' L2
Restore L2
LoadLevel Levels(1)
' L3
Restore L3
LoadLevel Levels(2)



' Game state
Dim Shared Dodu As Player
Let Dodu.SpriteIndex = 0
Let Dodu.HasBlock = FALSE
Let Dodu.IsClimbing = 0
Let Dodu.Temp = 10


' --------------------------
' Main loop
' --------------------------
Let Audio.PlaySong = PLAY_MUSIC%
Let Audio.PlayEffects = TRUE
SoundPlayer_PlaySong Audio, 0

Dim Shared CURRENT_LEVEL As Integer
Let CURRENT_LEVEL = 0

Dim Shared CURRENT_SPRITE As Integer
Let CURRENT_SPRITE% = DOD_STATIC%
Dim Shared CURRENT_TRAJECTORY As Integer
Let CURRENT_TRAJECTORY% = -1

Screen MainScreen.Buffer
Dim parallax As Point
Point_Set parallax, 2, 2
Viewport_SetBackground ImgBuffer, Background, parallax

Do
  DoLevel
  SoundPlayer_PlayEffect Audio, SND_LEVELUP
  Let CURRENT_LEVEL = CURRENT_LEVEL + 1
Loop

Sub DoLevel
  Dim CTRL_PRESSED As Integer, PANBACK_STEPS As Integer
  Let CTRL_PRESSED = FALSE
  Let Dodu.Temp = 10
  Let PANBACK_STEPS = 8
  Dim panback_ticker As Ticker

  Ticker_Init Dodu.ThermoTick, 10, THERMO_TICK_NORMAL%, FALSE

  Ticker_Init panback_ticker, PANBACK_STEPS, 1, FALSE
  Let Dodu.LevPos.x = Levels(CURRENT_LEVEL).StartPoint.col * BLOCK_SIZE%
  Let Dodu.LevPos.y = (Levels(CURRENT_LEVEL).StartPoint.row - 2) * BLOCK_SIZE%
  Dim dod_lastgrab As Point
  Dim sq_lastgrab As Square, sq_lastdrop As Square
  Square_Set sq_lastgrab, -1, -1
  Square_Set sq_lastdrop, -1, -1
  Dim center As Point, panbacktarget As Point
  GetDoduCenter center
  Viewport_SetCenter ImgBuffer, center

  Dim trjP As Point
  Point_Set trjP, -1, -1
  Do
    _Limit FPS%
    Viewport_Clear ImgBuffer
    ' Thermometer
    Ticker_Tick Dodu.ThermoTick
    If Dodu.ThermoTick.TickCnt = 0 Or (Dodu.Temp < 3 And Dodu.ThermoTick.TickCnt Mod FPS% = 0) Then
      SoundPlayer_PlayEffect Audio, SND_THERMO%
    End If
    If Dodu.ThermoTick.TickCnt = 0 Then
      Let Dodu.Temp = Dodu.Temp - 1
    End If
    If Dodu.Temp = 0 Then GoTo GameOver:

    ' Squares of interest
    Dim lp As Point
    Let lp = Dodu.LevPos
    Dim climbP As Square, takeP As Square, dropP As Square, unclimbP As Square, blockingP As Square, poleP As Square
    ClimbableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), climbP
    TakeableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), takeP
    DroppableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), dropP
    UnclimbableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), unclimbP
    BlockingSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), blockingP
    PoleSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), poleP

    ' Drawing
    DrawLevel ImgBuffer, Levels(CURRENT_LEVEL)
    DrawPlayer ImgBuffer
    DrawThermometer ImgBuffer
    Viewport_Print ImgBuffer, _Trim$(NbFormat$(CURRENT_LEVEL% + 1)), PT_LEVEL_NB

    If _KeyDown(K_ESC) Then
      GoTo Quit:
    End If

    If _KeyDown(K_SPACE) Then
      DoPause
      _Continue
    End If

    If _KeyDown(K_M_UC) Or _KeyDown(K_M_LC) Then
      DoMiniMap
      _Continue
    End If


    HighlightBlock ImgBuffer, Levels(CURRENT_LEVEL), takeP, HIGHLIGHT_COLOR&
    HighlightBlock ImgBuffer, Levels(CURRENT_LEVEL), dropP, HIGHLIGHT_COLOR&
    Viewport_Clear MainScreen
    Viewport_Copy ImgBuffer, MainScreen
    _Display

    If (CURRENT_SPRITE% = DOD_WALKING% Or CURRENT_SPRITE% = DOD_BLOCK_WALKING%) And DoduSprites(CURRENT_SPRITE%).Ticker.TickCnt = 0 And DoduSprites(CURRENT_SPRITE%).Ticker.Index Mod 2 = 0 Then
      SoundPlayer_PlayEffect Audio, SND_STEP%
    End If

    ' If a trajectory is playing, ignore keybord input
    If CURRENT_TRAJECTORY% >= 0 And CURRENT_TRAJECTORY% < 100 Then
      Trajectory_Tick Trajectories(CURRENT_TRAJECTORY%), trjP
      MovePlayer ImgBuffer, trjP
      If Ticker_Finished%(Trajectories(CURRENT_TRAJECTORY%).Ticker) Then
        Trajectory_Reset Trajectories(CURRENT_TRAJECTORY)
        Let CURRENT_TRAJECTORY% = -1
      End If
      _Continue
    End If

    Dim to_p As Point

    ' Is goal reached?
    If Square_IsValid(poleP) Then
      Exit Sub
    End If

    If Not _KeyDown(K_CTRL) And CTRL_PRESSED = TRUE And CURRENT_TRAJECTORY < 0 Then
      Let CTRL_PRESSED = FALSE
      Let CURRENT_TRAJECTORY% = TRJ_PANBACK%
      GetDoduCenter center
      Point_Set panbacktarget, (center.x - ImgBuffer.Pan.x - ImgBuffer.Size.x / 2) / PANBACK_STEPS%, (center.y - ImgBuffer.Pan.y - ImgBuffer.Size.y / 2) / PANBACK_STEPS%
    End If

    If CURRENT_TRAJECTORY% = TRJ_PANBACK% Then
      Ticker_Tick panback_ticker
      Let ImgBuffer.Pan.x = ImgBuffer.Pan.x + panbacktarget.x
      Let ImgBuffer.Pan.y = ImgBuffer.Pan.y + panbacktarget.y
      If Ticker_Finished%(panback_ticker) Then
        Let CURRENT_TRAJECTORY% = -1
        Ticker_Reset panback_ticker
      End If
      _Continue
    End If

    If _KeyDown(K_CTRL) Then
      If _KeyDown(K_LEFT) Then
        ImgBuffer.Pan.x = ImgBuffer.Pan.x - 3
        Let CTRL_PRESSED = TRUE
        _Continue
      ElseIf _KeyDown(K_RIGHT) Then
        ImgBuffer.Pan.x = ImgBuffer.Pan.x + 3
        _Continue
      ElseIf _KeyDown(K_UP) Then
        ImgBuffer.Pan.y = ImgBuffer.Pan.y - 3
        Let CTRL_PRESSED = TRUE
        _Continue
      ElseIf _KeyDown(K_DOWN) Then
        ImgBuffer.Pan.y = ImgBuffer.Pan.y + 3
        Let CTRL_PRESSED = TRUE
        _Continue
      End If
    End If

    If _KeyDown(K_LEFT) Then
      Let Dodu.ToLeft = TRUE
      Dim klp As Point
      If Square_IsValid(climbP) Then
        Let CURRENT_SPRITE = GetDoduSprite%(TRUE, Dodu.HasBlock)
        Let CURRENT_TRAJECTORY% = TRJ_CLIMBING%
        Let Dodu.ToLeft = TRUE
        Let Trajectories(CURRENT_TRAJECTORY%).Flipped = TRUE
        Let DoduSprites(CURRENT_SPRITE).Flipped = TRUE
      Else
        If Not Square_IsValid(blockingP) Then
          Point_Set klp, -1, 0
          Let CURRENT_SPRITE = GetDoduSprite%(TRUE, Dodu.HasBlock)
          MovePlayer ImgBuffer, klp
        End If
      End If
      If Square_IsValid(unclimbP) Then
        Let CURRENT_SPRITE = GetDoduSprite%(FALSE, Dodu.HasBlock)
        Let CURRENT_TRAJECTORY% = TRJ_FALLING%
        Let Trajectories(CURRENT_TRAJECTORY%).Flipped = TRUE
        Let DoduSprites(CURRENT_SPRITE).Flipped = TRUE
      End If

    ElseIf _KeyDown(K_RIGHT) Then
      Let Dodu.ToLeft = FALSE
      Dim krp As Point
      If Square_IsValid(climbP) Then
        Let CURRENT_SPRITE = GetDoduSprite%(TRUE, Dodu.HasBlock)
        Let CURRENT_TRAJECTORY% = TRJ_CLIMBING%
        Let Trajectories(CURRENT_TRAJECTORY%).Flipped = FALSE
        Let DoduSprites(CURRENT_SPRITE).Flipped = FALSE
      Else
        If Not Square_IsValid(blockingP) Then
          Point_Set krp, 1, 0
          Let CURRENT_SPRITE = GetDoduSprite%(TRUE, Dodu.HasBlock)
          MovePlayer ImgBuffer, krp
        End If
      End If
      If Square_IsValid(unclimbP) Then
        Let CURRENT_SPRITE = GetDoduSprite%(FALSE, Dodu.HasBlock)
        Let CURRENT_TRAJECTORY% = TRJ_FALLING%
        Let Trajectories(CURRENT_TRAJECTORY%).Flipped = FALSE
        Let DoduSprites(CURRENT_SPRITE).Flipped = FALSE
      End If

    ElseIf _KeyDown(K_UP) And Square_IsValid(takeP) Then
      SoundPlayer_PlayEffect Audio, SND_GRAB%
      TakeBlock Levels(CURRENT_LEVEL), takeP
      Point_Set dod_lastgrab, Dodu.LevPos.x, Dodu.LevPos.y
      Let sq_lastgrab.col = takeP.col
      Let sq_lastgrab.row = takeP.row
      Let Dodu.ThermoTick.Speed = THERMO_TICK_FAST%

    ElseIf _KeyDown(K_DOWN) And Square_IsValid(dropP) Then
      SoundPlayer_PlayEffect Audio, SND_DROP%
      Let sq_lastdrop.col = dropP.col
      Let sq_lastdrop.row = dropP.row
      DropBlock Levels(CURRENT_LEVEL), dropP
      Let Dodu.ThermoTick.Speed = THERMO_TICK_NORMAL%

      ' Undo last block if possible
    ElseIf _KeyDown(K_BACKSPACE) And Square_IsValid(sq_lastgrab) Then
      Let Dodu.LevPos.x = dod_lastgrab.x
      Let Dodu.LevPos.y = dod_lastgrab.y
      Let CURRENT_TRAJECTORY% = TRJ_PANBACK%
      Let Levels(CURRENT_LEVEL).Topo(sq_lastdrop.col, sq_lastdrop.row) = T_NOTHING
      Let Levels(CURRENT_LEVEL).Topo(sq_lastgrab.col, sq_lastgrab.row) = T_BLOCK_W
      Square_Set sq_lastgrab, -1, -1
      Square_Set sq_lastdrop, -1, -1
      GetDoduCenter center
      Point_Set panbacktarget, (center.x - ImgBuffer.Pan.x - ImgBuffer.Size.x / 2) / PANBACK_STEPS%, (center.y - ImgBuffer.Pan.y - ImgBuffer.Size.y / 2) / PANBACK_STEPS%
      SoundPlayer_PlayEffect Audio, SND_UNDO%

    Else ' No key
      Let CURRENT_SPRITE% = GetDoduSprite%(FALSE, Dodu.HasBlock)

    End If

    ' Unless he is climbing/falling, Dodu can always flip sides
    If CURRENT_TRAJECTORY% < 0 Then
      If _KeyDown(K_LEFT) Then
        Let Dodu.ToLeft = TRUE
      End If
      If _KeyDown(K_RIGHT) Then
        Let Dodu.ToLeft = FALSE
      End If
    End If

  Loop

  GameOver:
  _Dest MainScreen.Buffer
  Cls
  _PrintString (0, 48), "GAME OVER" ' Ought to be better
  End

  Quit:
  Cls
  End
End Sub

Sub DoMiniMap
  Dim MapBuffer As Viewport
  Viewport_Init_Default MapBuffer, SCREEN_DIMS
  Viewport_SetBackground MapBuffer, Background, P_ORIGIN
  Viewport_Clear MapBuffer
  DrawMinimap MapBuffer, Levels(CURRENT_LEVEL%)
  Viewport_Copy MapBuffer, MainScreen
  _Display

  ' Wait until key is released
  Kbd_WaitRelease FPS%
  Do
    _Limit FPS%
    _Display
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
  _Display

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
  DoduSprites(CURRENT_SPRITE).Flipped = Dodu.ToLeft
  Viewport_PutSpriteSequence v, FALSE, DoduSprites(CURRENT_SPRITE), Dodu.LevPos
  SpriteSequence_Tick DoduSprites(CURRENT_SPRITE)
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

Sub DropBlock (m As LevelMap, p As Square)
  Let m.Topo(p.col, p.row) = T_BLOCK_W
  Let Dodu.HasBlock = FALSE
End Sub

Sub MovePlayer (v As Viewport, p_to As Point)
  If p_to.x < 0 Then Dodu.ToLeft = TRUE
  If p_to.x > 0 Then Dodu.ToLeft = FALSE
  ' Otherwise, leave in its current state
  Let DoduSprites(CURRENT_SPRITE%).Flipped = Dodu.ToLeft
  Dim ScreenPos As Point
  ' Demo1.bas, MovePlayer
  Viewport_PointToScreen v, Dodu.LevPos, ScreenPos
  Let Dodu.LevPos.x = Dodu.LevPos.x + (p_to.x * WALKING_SPEED#)
  Let Dodu.LevPos.y = Dodu.LevPos.y + (p_to.y * WALKING_SPEED#)
  If p_to.x <> 0 Then
    Select Case Dodu.ToLeft
      Case FALSE ' Going right, x > 0
        If ScreenPos.x >= 20 Then
          Let v.Pan.x = _Min(v.Pan.x + (p_to.x * WALKING_SPEED#), M_W% * BLOCK_SIZE%)
        End If
      Case TRUE ' Going left, x < 0
        If ScreenPos.x <= 10 Then
          Let v.Pan.x = _Max(v.Pan.x + (p_to.x * WALKING_SPEED#), 0)
        End If
    End Select
  End If
  If p_to.y > 0 Then '   Going down, y > 0
    If ScreenPos.y >= 20 Then
      Let v.Pan.y = _Min(v.Pan.y + (p_to.y * WALKING_SPEED#), M_H% * BLOCK_SIZE%)
    End If
  ElseIf p_to.y < 0 Then '  Going up, y < 0
    If ScreenPos.y <= 10 Then
      Let v.Pan.y = _Max(v.Pan.y + (p_to.y * WALKING_SPEED#), 0)
    End If
  End If
End Sub

Sub HighlightBlock (v As Viewport, m As LevelMap, s As Square, c~&)
  If Square_IsValid(s) Then
    Dim p1 As Point, p2 As Point
    Square_ToPoint s, p1
    Point_Set p2, p1.x + BLOCK_SIZE% - 1, p1.y + BLOCK_SIZE% - 1
    Viewport_Line v, p1, p2, c~&, TRUE, FALSE
  End If
End Sub

Sub SetFlipSprites (flipped As Integer)
  Dim x As Integer
  For x = 0 To 1
    Let DoduSprites(x).Flipped = flipped
  Next
End Sub

Function GetDoduSprite% (walking As Integer, hasBlock As Integer)
  If walking Then
    If hasBlock Then
      Let GetDoduSprite% = DOD_BLOCK_WALKING%
    Else
      Let GetDoduSprite% = DOD_WALKING%
    End If
  Else
    If hasBlock Then
      Let GetDoduSprite% = DOD_BLOCK%
    Else
      Let GetDoduSprite% = DOD_STATIC%
    End If
  End If
End Function

Sub GetDoduCenter (p As Point)
  Point_Set p, Dodu.LevPos.x + (PLAYER_WIDTH% / 2), Dodu.LevPos.y + (PLAYER_HEIGHT% / 2)
End Sub

' --------------------------
' Includes (implementations)
' --------------------------
'$IncludeOnce
'$Include:'Utils.bm'
'$Include:'Geometry.bm'
'$Include:'Sprites.bm'
'$Include:'Sounds.bm'
'$Include:'Keyboard.bm'
'$Include:'Levels.bm'
'$Include:'LevelMaps.bm'

