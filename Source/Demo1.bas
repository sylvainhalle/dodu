Option Base 0
Option _Explicit
$ErrorLocation:On

' --------------------------
' Program constants
' --------------------------

' Booleans
Const TRUE = -1
Const FALSE = 0

' Keys
Const K_ESC = 27
Const K_LEFT = 19200
Const K_RIGHT = 19712
Const K_UP = 18432
Const K_DOWN = 20480

' Screen dimensions
Dim SCREEN_DIMS As Point
Point_Set SCREEN_DIMS, 80, 64

' Frame rate
Const FPS% = 25

' Window scaling factor
Const SCALE% = 6
Dim WINDOW_DIMS As Point
Point_Set WINDOW_DIMS, SCREEN_DIMS.x * SCALE%, SCREEN_DIMS.y * SCALE%

' Threshold to enable block holding/dropping (px)
Const CLIMB_THRESHOLD% = 1
Const TAKE_THRESHOLD% = 3
Const DROP_THRESHOLD% = 5
Const UNCLIMB_THRESHOLD% = 8


' Number of seconds between ticks of the thermometer
Const THERMO_TICK% = 3

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
  ThermoTick As Integer
  ThermoFlash As Integer
End Type

' --------------------------
' Screen setup: 1 main screen and 1 buffer
' --------------------------
Dim Shared MainScreen As Viewport, ImgBuffer As Viewport
Viewport_Init MainScreen, WINDOW_DIMS, P_ORIGIN, 1
Viewport_Init_Default ImgBuffer, SCREEN_DIMS
Viewport_SetFont MainScreen, FNT_TINYC
Viewport_SetFont ImgBuffer, FNT_TINYC

' --------------------------
' Level loading
' --------------------------
Dim Shared Levels(1) As LevelMap
' L1
Restore L1
LoadLevel Levels(0)

' Game state
Dim Shared Dodu As Player
Let Dodu.SpriteIndex = 0
Let Dodu.LevPos.x = Levels(0).StartPoint.col * BLOCK_SIZE%
Let Dodu.LevPos.y = (Levels(0).StartPoint.row - 2) * BLOCK_SIZE%
Let Dodu.HasBlock = FALSE
Let Dodu.IsClimbing = 0
Let Dodu.Temp = 10


' --------------------------
' Main loop
' --------------------------
Dim snd As Long
If PLAY_MUSIC Then
  _SndPlay SND_TUNE
End If

Dim CURRENT_LEVEL As Integer
Let CURRENT_LEVEL = 0
Dim Shared CURRENT_SPRITE As Integer
Let CURRENT_SPRITE% = DOD_STATIC%
Dim Shared CURRENT_TRAJECTORY As Integer
Let CURRENT_TRAJECTORY% = -1

Dim trjP As Point
Point_Set trjP, -1, -1
Screen MainScreen.Buffer
Do
  _Limit FPS%
  ' Thermometer
  Let Dodu.ThermoTick = (Dodu.ThermoTick + 1) Mod (FPS% * THERMO_TICK%)
  If Dodu.ThermoTick = 0 Or (Dodu.Temp < 3 And (Dodu.ThermoTick = 0 Or Dodu.ThermoTick = 12)) Then
    _SndPlay SND_THERMO
  End If
  If Dodu.ThermoTick = 0 Then
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
  DrawBackground ImgBuffer
  DrawLevel ImgBuffer, Levels(CURRENT_LEVEL)
  DrawPlayer ImgBuffer
  DrawThermometer ImgBuffer
  If CURRENT_TRAJECTORY% >= 0 Then
    Viewport_Print ImgBuffer, NbFormat$(Trajectories(CURRENT_TRAJECTORY%).Flipped) + " " + Point_ToString(trjP), P_ORIGIN
  End If

  If _KeyDown(K_ESC) Then
    GoTo Quit:
  End If

  'HighlightBlock ImgBuffer, Levels(CURRENT_LEVEL), takeP, COLOR_YELLOW
  HighlightBlock ImgBuffer, Levels(CURRENT_LEVEL), climbP, COLOR_RED
  'HighlightBlock ImgBuffer, Levels(CURRENT_LEVEL), dropP, COLOR_GREEN
  HighlightBlock ImgBuffer, Levels(CURRENT_LEVEL), unclimbP, COLOR_PINK
  HighlightBlock ImgBuffer, Levels(CURRENT_LEVEL), blockingP, COLOR_YELLOW
  Viewport_Copy ImgBuffer, MainScreen

  If (CURRENT_SPRITE% = DOD_WALKING% Or CURRENT_SPRITE% = DOD_BLOCK_WALKING%) And DoduSprites(CURRENT_SPRITE%).Ticker.TickCnt = 0 And DoduSprites(CURRENT_SPRITE%).Ticker.Index Mod 2 = 0 Then
    _SndPlay SND_STEP
  End If

  ' If a trajectory is playing, ignore keybord input
  If CURRENT_TRAJECTORY% >= 0 Then
    Trajectory_Tick Trajectories(CURRENT_TRAJECTORY%), trjP
    MovePlayer ImgBuffer, trjP
    If Ticker_Finished%(Trajectories(CURRENT_TRAJECTORY%).Ticker) Then
      'Let Dodu.ToLeft = Trajectories(CURRENT_TRAJECTORY%).Flipped
      Trajectory_Reset Trajectories(CURRENT_TRAJECTORY)
      Let CURRENT_TRAJECTORY% = -1
    End If
    _Continue
  End If

  Dim to_p As Point

  ' Is goal reached?
  If Square_IsValid(poleP) Then
    GoTo Quit:
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
    _SndPlay SND_GRAB
    TakeBlock Levels(CURRENT_LEVEL), takeP

  ElseIf _KeyDown(K_DOWN) And Square_IsValid(dropP) Then
    _SndPlay SND_DROP
    DropBlock Levels(CURRENT_LEVEL), dropP

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
_PrintString (0, 48), "GAME OVER"
End

Quit:
Cls
End

' --------------------------
' Draws the background
' --------------------------
Sub DrawBackground (v As Viewport)
  Viewport_Clear v
  Viewport_PutSprite v, TRUE, Background, P_ORIGIN, FALSE
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
  Dim red As _Unsigned Long
  Let red = THERMO_RED~&
  If Dodu.Temp <= 2 Then
    If Dodu.ThermoFlash < 10 Then
      Let red = _RGB32(85, 0, 170)
    Else
      Let red = THERMO_RED~&
    End If
    Let Dodu.ThermoFlash = (Dodu.ThermoFlash + 1) Mod 20
  End If
  Line (6, 15 - Dodu.Temp)-(7, 15), red, BF
  Line (5, 16)-(8, 18), red, BF
End Sub


Sub TakeBlock (m As LevelMap, p As Square)
  Let m.Topo(p.col, p.row) = T_NOTHING
  Let Dodu.HasBlock = TRUE
End Sub

Sub DropBlock (m As LevelMap, p As Square)
  Let m.Topo(p.col, p.row) = T_BLOCK_W
  Let Dodu.HasBlock = FALSE
End Sub

Sub MovePlayer (v As Viewport, p_to As Point) '(x As Integer, y As Integer)
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

' --------------------------
' Includes (implementations)
' --------------------------
'$IncludeOnce
'$Include:'Utils.bm'
'$Include:'Geometry.bm'
'$Include:'Sprites.bm'
'$Include:'Levels.bm'
'$Include:'LevelMaps.bm'

