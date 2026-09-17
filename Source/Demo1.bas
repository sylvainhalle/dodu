Option Base 0
Option _Explicit

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

Const SHOW_SURROUNDINGS = FALSE
Const PLAY_MUSIC = FALSE

' --------------------------
' Includes (declarations)
' --------------------------
'$IncludeOnce
'$Include:'Utils.bi'
'$Include:'Geometry.bi'
'$Include:'Sprites.bi'
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

Type Surroundings
  Top As Integer
  Bottom As Integer
  Left As Integer
  Right As Integer
End Type

' --------------------------
' Screen setup: 1 main screen and 1 buffer
' --------------------------
Dim Shared MainScreen As Viewport, ImgBuffer As Viewport
Viewport_Init_Default MainScreen, SCREEN_DIMS
Viewport_Init_Default ImgBuffer, SCREEN_DIMS

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
  '_MIDISoundBank ("/home/sylvain/Downloads/FluidR3_GM.sf2")
  _MIDISoundBank ("/usr/share/sounds/sf2/default-GM.sf2")
  snd = _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/yaya.mid")
  _SndPlay (snd)
End If

Dim CURRENT_LEVEL As Integer
Let CURRENT_LEVEL = 0

' Font
_Font _LoadFont("/home/sylvain/Workspaces/dodu/Source/fonts/TinyAndChunkyRegular.ttf", 5, "MONOSPACE")

Do
  _Limit FPS%
  ' Thermometer
  Let Dodu.ThermoTick = (Dodu.ThermoTick + 1) Mod (FPS% * THERMO_TICK%)
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
  DrawLevel ImgBuffer, CURRENT_LEVEL + 1
  DrawPlayer ImgBuffer
  DrawThermometer ImgBuffer

  If _KeyDown(K_ESC) Then
    GoTo Quit:
  End If

  ' Unless he is climbing/falling, Dodu can always flip sides
  If Not Dodu.IsClimbing And Not Dodu.IsFalling Then
    If _KeyDown(K_LEFT) Then
      Let Dodu.ToLeft = TRUE
    End If
    If _KeyDown(K_RIGHT) Then
      Let Dodu.ToLeft = FALSE
    End If
  End If

  'HighlightBlock Levels(CURRENT_LEVEL), takeP, COLOR_YELLOW
  'HighlightBlock Levels(CURRENT_LEVEL), climbP, COLOR_RED
  'HighlightBlock Levels(CURRENT_LEVEL), dropP, COLOR_GREEN
  'HighlightBlock Levels(CURRENT_LEVEL), unclimbP, PINK~&
  HighlightBlock Levels(CURRENT_LEVEL), climbP, COLOR_RED
  '_PrintString (0, 59), Str$(sc) + " " + Str$(blockingP.row) + "," + Str$(blockingP.col)
  '_PutImage (0, 0)-(SCREEN_DIMS.x * SCALE% - 1, SCREEN_DIMS.h * SCALE% - 1), 0, 0
  Viewport_Display MainScreen

  ' If player is climbing, ignore keyboard until on top of block
  Dim to_p As Point
  If Dodu.IsClimbing > 0 Then
    Dim dir_c As Integer
    If Dodu.ToLeft = TRUE Then dir_c% = -WALKING_SPEED% Else dir_c% = WALKING_SPEED%
    Point_Set to_p, dir_c, -1
    MovePlayer ImgBuffer, to_p
    Let Dodu.IsClimbing = Dodu.IsClimbing - 1
    _Continue
  End If
  ' If player is falling, ignore keyboard until on top of block
  If Dodu.IsFalling > 0 Then
    Dim dir_f As Integer
    If Dodu.ToLeft = TRUE Then dir_f% = -WALKING_SPEED% Else dir_f% = WALKING_SPEED%
    Point_Set to_p, dir_f, 1
    Let Dodu.IsFalling = Dodu.IsFalling - 1
    _Continue
  End If

  ' Is goal reached?
  If poleP.col >= 0 And poleP.row >= 0 Then
    GoTo Quit:
  End If

  If _KeyDown(K_LEFT) Then
    Dim klp As Point
    If climbP.col >= 0 And climbP.row >= 0 Then
      Let Dodu.IsClimbing = 11
    Else
      If blockingP.col < 0 Then
        Point_Set klp, -1, 0
        MovePlayer ImgBuffer, klp
      End If
    End If
    If unclimbP.col >= 0 Then
      Let Dodu.IsFalling = 11
    End If
  ElseIf _KeyDown(K_RIGHT) Then
    Dim krp As Point
    If climbP.col >= 0 And climbP.row >= 0 Then
      Let Dodu.IsClimbing = 11
    Else
      If blockingP.col < 0 Then
        Point_Set krp, 1, 0
        MovePlayer ImgBuffer, krp
      End If
    End If
    If unclimbP.col >= 0 Then
      Let Dodu.IsFalling = 11
    End If
  ElseIf _KeyDown(K_UP) And takeP.col >= 0 Then
    TakeBlock Levels(CURRENT_LEVEL), takeP
  ElseIf _KeyDown(K_DOWN) And dropP.col >= 0 Then
    DropBlock Levels(CURRENT_LEVEL), dropP
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
  '_PutImage (0, 0)-(SCREEN_W, SCREEN_H), Background, buf
End Sub

' --------------------------
' Draws a level
' --------------------------
Sub DrawLevel (v As Viewport, n As Integer)
  Dim m As LevelMap
  Let m = Levels(n - 1)
  Dim col, row As Integer
  For row = 0 To m.Height
    For col = 0 To m.Width
      Dim p As Point
      Point_Set p, col * BLOCK_SIZE%, row * BLOCK_SIZE%
      Select Case m.Topo(col, row)
        Case T_BLOCK_B
          Viewport_PutSprite v, FALSE, BlockBlue, p, FALSE
        Case T_BLOCK_W
          Viewport_PutSprite v, FALSE, BlockBlue, p, FALSE
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
  Let s = CharSprites(Dodu.SpriteIndex)
  Viewport_PutSprite v, FALSE, s, Dodu.LevPos, Dodu.ToLeft
  Dim p As Point
  If Dodu.HasBlock Then
    If Dodu.ToLeft Then
      Point_Set p, Dodu.LevPos.x - 4, Dodu.LevPos.y + 15
    Else
      Point_Set p, Dodu.LevPos.x + 10, Dodu.LevPos.y + 15
    End If
    Viewport_PutSprite v, FALSE, BlockWhite, p, Dodu.ToLeft
  End If
End Sub

Sub DrawThermometer (v As Viewport)
  Dim p As Point
  Point_Set p, 4, 4
  Viewport_PutSprite v, FALSE, Thermometer, p, FALSE
  Dim red As _Unsigned Long
  Let red = THERMO_RED~&
  If Dodu.Temp <= 2 Then
    If Dodu.ThermoFlash < 10 Then
      red = _RGB32(85, 0, 170)
    Else
      red = THERMO_RED~&
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
  If p_to.x < 0 Then Dodu.ToLeft = TRUE Else Dodu.ToLeft = FALSE
  Dim ScreenPos As Point
  Viewport_PointToScreen v, p_to, ScreenPos
  Select Case Dodu.ToLeft
    Case FALSE ' Going right, x > 0
      If ScreenPos.x < 20 Then
        Let Dodu.LevPos.x = Dodu.LevPos.x + (p_to.x * WALKING_SPEED#)
      Else
        Let Levels(0).PanX = Levels(0).PanX - (p_to.x * WALKING_SPEED#)
      End If
    Case TRUE ' Going left, x < 0
      If ScreenPos.x > 10 Then
        Let Dodu.LevPos.x = Dodu.LevPos.x + (p_to.x * WALKING_SPEED#)
      Else
        Let Levels(0).PanX = Levels(0).PanX - (p_to.x * WALKING_SPEED#)
      End If
  End Select
  If p_to.y > 0 Then
    ' Going down, y > 0
    If ScreenPos.y < 20 Then
      Let Dodu.LevPos.y = Dodu.LevPos.y + (p_to.y * WALKING_SPEED#)
    Else
      Let Levels(0).PanY = Levels(0).PanY - (p_to.y * WALKING_SPEED#)
    End If
  Else
    'Going up, y < 0
    If ScreenPos.y > 10 Then
      Let Dodu.LevPos.y = Dodu.LevPos.y + (p_to.y * WALKING_SPEED#)
    Else
      Let Levels(0).PanY = Levels(0).PanY - (p_to.y * WALKING_SPEED#)
    End If
  End If
End Sub

Sub HighlightBlock (m As LevelMap, p As Square, c~&)
  If p.col >= 0 And p.row >= 0 Then
    Line (p.col * BLOCK_SIZE% + m.PanX, p.row * BLOCK_SIZE% + m.PanY)-((p.col + 1) * BLOCK_SIZE% - 1 + m.PanX, (p.row + 1) * BLOCK_SIZE% - 1 + m.PanY), c~&, B
  End If
End Sub

' --------------------------
' Includes (implementations)
' --------------------------
'$IncludeOnce
'$Include:'Utils.bm'
'$Include:'Geometry.bm'
'$Include:'Sprites.bm'
'$Include:'Levels.bm'
'$Include:'LevelMaps.bm'

