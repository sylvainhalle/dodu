$Debug
'$Debug
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
Const SCREEN_W% = 80
Const SCREEN_H% = 64

' Frame rate
Const FPS% = 25

' Window scaling factor
Const SCALE% = 6

' Threshold to enable block holding/dropping (px)
Const CLIMB_THRESHOLD% = 1
Const TAKE_THRESHOLD% = 3
Const DROP_THRESHOLD% = 5
Const UNCLIMB_THRESHOLD% = 5


' Number of seconds between ticks of the thermometer
Const THERMO_TICK% = 3

' Number of screen pixels per frame
' Currently, can only be an integer
Const WALKING_SPEED# = 1

Const SHOW_SURROUNDINGS = FALSE
Const PLAY_MUSIC = FALSE

' --------------------------
' Includes
' --------------------------

'$Include:'Sprites.bi'
'$Include:'Levels.bi'

' --------------------------
' Player
' --------------------------

Type Player
  ScreenPos As Point
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
Dim Shared MainScreen As Long
MainScreen = _NewImage(SCREEN_W * SCALE%, SCREEN_H * SCALE%, 32)
Screen MainScreen
_Dest MainScreen
Dim Shared ImgBuffer As Long
ImgBuffer = _NewImage(SCREEN_W, SCREEN_H, 32)

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
Let Dodu.ScreenPos.x = Levels(0).StartPoint.col * BLOCK_SIZE%
Let Dodu.ScreenPos.y = (Levels(0).StartPoint.row - 2) * BLOCK_SIZE%
Let Dodu.HasBlock = FALSE
Let Dodu.IsClimbing = 0
Let Dodu.Temp = 10

' --------------------------
' Draws the background
' --------------------------
Sub DrawBackground (buf As Long)
  _PutImage (0, 0)-(SCREEN_W, SCREEN_H), Background, buf
End Sub

' --------------------------
' Draws a level
' --------------------------
Sub DrawLevel (n As Integer, buf As Long)
  Dim m As LevelMap
  Let m = Levels(n - 1)
  Dim col, row As Integer
  For row = 0 To m.Height
    For col = 0 To m.Width
      Dim p As Point
      Let p.x = col * BLOCK_SIZE% + m.PanX
      Let p.y = row * BLOCK_SIZE% + m.PanY

      Select Case m.Topo(col, row)
        Case T_BLOCK_B
          DrawSprite BlockBlue, p, FALSE, buf
        Case T_BLOCK_W
          DrawSprite BlockWhite, p, FALSE, buf
        Case T_POLE
          DrawSprite Pole, p, FALSE, buf
      End Select
    Next
  Next
End Sub

' --------------------------
' Player drawing
' --------------------------
Sub DrawPlayer (buf As Long)
  Dim s As Sprite
  Let s = CharSprites(Dodu.SpriteIndex)
  DrawSprite s, Dodu.ScreenPos, Dodu.ToLeft, buf
  Dim p As Point
  If Dodu.HasBlock Then
    If Dodu.ToLeft Then
      Let p.x = Dodu.ScreenPos.x - 4
      Let p.y = Dodu.ScreenPos.y + 15
    Else
      Let p.x = Dodu.ScreenPos.x + 10
      Let p.y = Dodu.ScreenPos.y + 15
    End If
    DrawSprite BlockWhite, p, Dodu.ToLeft, buf
  End If
End Sub

Sub DrawThermometer (buf As Long)
  Dim p As Point
  Let p.x = 4
  Let p.y = 4
  DrawSprite Thermometer, p, FALSE, buf
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

Function Ceil% (x As Single)
  Dim z As Integer
  Let z = CInt(x)
  If z < x Then z = z + 1
  Let Ceil% = z
End Function

Function Floor% (x As Single)
  Dim z As Integer
  Let z = CInt(x)
  If z > x Then z = z - 1
  Let Floor% = z
End Function

Sub LevelPos (p As Player, m As LevelMap, pt As Point)
  Let pt.x = p.ScreenPos.x - m.PanX
  Let pt.y = p.ScreenPos.y - m.PanY
End Sub

Sub ClimbableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)
  Dim col As Integer, row As Integer

  Let p.col = -1
  Let p.row = -1

  Let col = SideColumn%(side, lp, CLIMB_THRESHOLD%)
  If col < 0 Or col >= M_W% Then Exit Sub

  Let row = Ceil%((lp.y + PLAYER_HEIGHT%) / BLOCK_SIZE%) - 1
  If row < 3 Or row >= M_H% Then Exit Sub

  ' A block must be present at foot level
  If Not IsBlockAt(col, row, m) Then Exit Sub

  ' Dodu is three blocks high: the destination column
  ' must be clear above the block
  If IsBlockAt(col, row - 1, m) Then Exit Sub
  If IsBlockAt(col, row - 2, m) Then Exit Sub
  If IsBlockAt(col, row - 3, m) Then Exit Sub

  Let p.col = col
  Let p.row = row - 1
End Sub

Sub TakeableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)
  Dim col As Integer, row As Integer

  Let p.col = -1
  Let p.row = -1

  If Dodu.HasBlock Then Exit Sub

  Let col = SideColumn%(side, lp, TAKE_THRESHOLD%)
  If col < 0 Or col >= M_W% Then Exit Sub

  Let row = Ceil%((lp.y + PLAYER_HEIGHT%) / BLOCK_SIZE%) - 1
  If row < 1 Or row >= M_H% Then Exit Sub

  ' There must be a block beside Dodu
  If Not IsBlockAt(col, row, m) Then Exit Sub

  ' And no block may be resting on it
  If IsBlockAt(col, row - 1, m) Then Exit Sub

  Let p.col = col
  Let p.row = row
End Sub

' Game state
Sub DroppableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)
  Dim col As Integer, row As Integer
  Dim r As Integer

  Let p.col = -1
  Let p.row = -1

  If Not Dodu.HasBlock Then Exit Sub

  Let col = SideColumn%(side, lp, DROP_THRESHOLD%)
  If col < 0 Or col >= M_W% Then Exit Sub

  Let row = Ceil%((lp.y + PLAYER_HEIGHT%) / BLOCK_SIZE%) - 1
  If row < 0 Or row >= M_H% Then Exit Sub

  ' If a block is already beside Dodu, try putting
  ' the carried block on top of it.
  If IsBlockAt(col, row, m) Then
    If row > 0 And Not IsBlockAt(col, row - 1, m) Then
      Let p.col = col
      Let p.row = row - 1
    End If
    Exit Sub
  End If

  ' Otherwise find the first supporting block below.
  For r = row + 1 To M_H% - 1
    If IsBlockAt(col, r, m) Then
      Let p.col = col
      Let p.row = r - 1
      Exit Sub
    End If
  Next
End Sub

Sub UnclimbableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)
  Dim col As Integer, row As Integer
  Dim r As Integer

  Let p.col = -1
  Let p.row = -1
  Let col = SideColumn%(side, lp, UNCLIMB_THRESHOLD%)
  If col < 0 Or col >= M_W% Then Exit Sub

  Let row = Ceil%((lp.y + PLAYER_HEIGHT%) / BLOCK_SIZE%)
  If row < 0 Or row >= M_H% Then Exit Sub
  If IsBlockAt(col, row, m) Then Exit Sub

  ' Otherwise find the first supporting block below.
  For r = row + 1 To M_H% - 1
    If Not IsBlockAt(col, r, m) Then
      Let p.col = col
      Let p.row = r - 1
      Exit Sub
    End If
  Next
End Sub

Sub TakeBlock (m As LevelMap, p As Square)
  Let m.Topo(p.col, p.row) = T_NOTHING
  Let Dodu.HasBlock = TRUE
End Sub

Sub DropBlock (m As LevelMap, p As Square)
  Let m.Topo(p.col, p.row) = T_BLOCK_W
  Let Dodu.HasBlock = FALSE
End Sub

Sub MovePlayer (x As Integer, y As Integer)
  If x < 0 Then Dodu.ToLeft = TRUE Else Dodu.ToLeft = FALSE
  Select Case Dodu.ToLeft
    Case FALSE ' Going right, x > 0
      If Dodu.ScreenPos.x < 20 Then
        Let Dodu.ScreenPos.x = Dodu.ScreenPos.x + (x * WALKING_SPEED#)
      Else
        Let Levels(0).PanX = Levels(0).PanX - (x * WALKING_SPEED#)
      End If
    Case TRUE ' Going left, x < 0
      If Dodu.ScreenPos.x > 10 Then
        Let Dodu.ScreenPos.x = Dodu.ScreenPos.x + (x * WALKING_SPEED#)
      Else
        Let Levels(0).PanX = Levels(0).PanX - (x * WALKING_SPEED#)
      End If
  End Select
  If y > 0 Then
    ' Going down, y > 0
    If Dodu.ScreenPos.y < 20 Then
      Let Dodu.ScreenPos.y = Dodu.ScreenPos.y + (y * WALKING_SPEED#)
    Else
      Let Levels(0).PanY = Levels(0).PanY - (y * WALKING_SPEED#)
    End If
  Else
    'Going up, y < 0
    If Dodu.ScreenPos.y > 10 Then
      Let Dodu.ScreenPos.y = Dodu.ScreenPos.y + (y * WALKING_SPEED#)
    Else
      Let Levels(0).PanY = Levels(0).PanY - (y * WALKING_SPEED#)
    End If
  End If
End Sub

Sub HighlightBlock (m As LevelMap, p As Square, c~&)
  If p.col >= 0 And p.row >= 0 Then
    Line (p.col * BLOCK_SIZE% + m.PanX, p.row * BLOCK_SIZE% + m.PanY)-((p.col + 1) * BLOCK_SIZE% - 1 + m.PanX, (p.row + 1) * BLOCK_SIZE% - 1 + m.PanY), c~&, B
  End If
End Sub

Function SideColumn% (side As Integer, lp As Point, threshold As Integer)
  Dim x As Integer, grid As Integer

  Let SideColumn% = -1
  If side Then ' left
    Let x = lp.x
    'Let grid = Floor(x / BLOCK_SIZE%) * BLOCK_SIZE%
  Else ' right
    Let x = lp.x + PLAYER_WIDTH%
    'Let grid = CInt(x / BLOCK_SIZE%) * BLOCK_SIZE%
  End If

  ' Find the nearest vertical grid line

  Let grid = CInt(x / BLOCK_SIZE%) * BLOCK_SIZE%

  ' The edge of Dodu may be on either side of that line
  If Abs(x - grid) > threshold Then Exit Function

  If side Then ' left
    Let SideColumn% = (grid \ BLOCK_SIZE%) - 1
  Else ' right
    Let SideColumn% = grid \ BLOCK_SIZE%
  End If
End Function

Sub BlockingSquare (side As Integer, lp As Point, m As LevelMap, p As Square)
  Dim x As Integer
  Dim col As Integer
  Dim feet As Integer
  Dim overlap As Integer

  Let p.col = -1
  Let p.row = -1

  ' Leading edge after the next movement
  If side Then ' left
    Let x = lp.x - WALKING_SPEED%
    Let col = Floor%((x - 1) / BLOCK_SIZE%)
    Let overlap = (col + 1) * BLOCK_SIZE% - x
  Else ' right
    Let x = lp.x + PLAYER_WIDTH% + WALKING_SPEED%
    Let col = Floor%(x / BLOCK_SIZE%)
    Let overlap = x - col * BLOCK_SIZE%
  End If

  ' Still within the permitted penetration
  If overlap <= 2 Then Exit Sub

  If col < 0 Or col >= M_W% Then Exit Sub

  Let feet = Ceil%((lp.y + PLAYER_HEIGHT%) / BLOCK_SIZE%) - 1

  ' Check the two rows alongside Dodu
  If feet >= 1 Then
    If IsBlockAt(col, feet - 1, m) Then
      Let p.col = col
      Let p.row = feet - 1
      Exit Sub
    End If
  End If

  If feet >= 2 Then
    If IsBlockAt(col, feet - 2, m) Then
      Let p.col = col
      Let p.row = feet - 2
      Exit Sub
    End If
  End If
End Sub


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

_Dest ImgBuffer
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
  _Dest ImgBuffer

  ' Squares of interest
  Dim lp As Point
  Dim climbP As Square, takeP As Square, dropP As Square, unclimbP As Square, blockingP As Square
  LevelPos Dodu, Levels(CURRENT_LEVEL), lp
  ClimbableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), climbP
  TakeableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), takeP
  DroppableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), dropP
  UnclimbableSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), unclimbP
  BlockingSquare Dodu.ToLeft, lp, Levels(CURRENT_LEVEL), blockingP

  ' Drawing
  DrawBackground ImgBuffer
  DrawLevel CURRENT_LEVEL + 1, ImgBuffer
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
  '_PrintString (0, 59), Str$(sc) + " " + Str$(blockingP.row) + "," + Str$(blockingP.col)
  _PutImage (0, 0)-(SCREEN_W% * SCALE% - 1, SCREEN_H% * SCALE% - 1), ImgBuffer, MainScreen
  _Display

  ' If player is climbing, ignore keyboard until on top of block
  If Dodu.IsClimbing > 0 Then
    Dim dir_c As Integer
    If Dodu.ToLeft = TRUE Then dir_c% = -WALKING_SPEED% Else dir_c% = WALKING_SPEED%
    MovePlayer dir_c, -1
    Let Dodu.IsClimbing = Dodu.IsClimbing - 1
    _Continue
  End If
  ' If player is falling, ignore keyboard until on top of block
  If Dodu.IsFalling > 0 Then
    Dim dir_f As Integer
    If Dodu.ToLeft = TRUE Then dir_f% = -WALKING_SPEED% Else dir_f% = WALKING_SPEED%
    MovePlayer dir_f, 1
    Let Dodu.IsFalling = Dodu.IsFalling - 1
    _Continue
  End If

  ' Is goal reached?
  If IsGoalAt(blockingP.col, blockingP.row, Levels(CURRENT_LEVEL)) Then
    GoTo Quit:
  End If

  If _KeyDown(K_LEFT) Then
    If climbP.col >= 0 And climbP.row >= 0 Then
      Let Dodu.IsClimbing = 11
    Else
      If blockingP.col < 0 Then
        MovePlayer -1, 0
      End If
    End If
    If unclimbP.col >= 0 Then
      Let Dodu.IsFalling = 11
    End If
  ElseIf _KeyDown(K_RIGHT) Then
    If climbP.col >= 0 And climbP.row >= 0 Then
      Let Dodu.IsClimbing = 11
    Else
      If blockingP.col < 0 Then 'Not IsBlocked%(bc, lp, Levels(CURRENT_LEVEL)) Then
        MovePlayer 1, 0
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
_Dest MainScreen
Cls
_PrintString (0, 48), "GAME OVER"
End

Quit:
Cls
End

'$Include:'LevelMaps.bm'

