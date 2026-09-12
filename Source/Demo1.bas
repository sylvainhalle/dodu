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

' Number of seconds between ticks of the thermometer
Const THERMO_TICK% = 3

' Number of screen pixels per frame
' Currently, can only be an integer
Const WALKING_SPEED# = 1

Const SHOW_SURROUNDINGS = TRUE

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
Let Dodu.ScreenPos.x = Levels(0).StartPointX * BLOCK_SIZE%
Let Dodu.ScreenPos.y = (Levels(0).StartpointY - 2) * BLOCK_SIZE%
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
  Dim i, j As Integer
  For i = 0 To m.Height
    For j = 0 To m.Width
      Dim p As Point
      Select Case m.Topo(i, j)
        Case T_BLOCK_B
          Let p.x = j * BLOCK_SIZE% + m.PanX
          Let p.y = i * BLOCK_SIZE% + m.PanY
          DrawSprite BlockBlue, p, FALSE, buf
        Case T_BLOCK_W
          Let p.x = j * BLOCK_SIZE% + m.PanX
          Let p.y = i * BLOCK_SIZE% + m.PanY
          DrawSprite BlockWhite, p, FALSE, buf
        Case T_POLE
          Let p.x = j * BLOCK_SIZE% + m.PanX
          Let p.y = i * BLOCK_SIZE% + m.PanY
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

Sub MapRect (p As Player, m As LevelMap, r As Rectangle)
  Dim lp As Point
  Dim p_x, p_y As Integer
  LevelPos p, m, lp
  If p.ToLeft Then

    Let r.p1.x = CInt((lp.y + PLAYER_HEIGHT% / 2) / BLOCK_SIZE%)
    Let r.p2.y = Ceil%((lp.x + PLAYER_WIDTH% / 2) / BLOCK_SIZE%)
    Let r.p2.x = r.p1.x
    Let r.p1.y = r.p2.y - 1
  Else
    Let r.p1.y = Floor%((lp.x + PLAYER_WIDTH% / 2) / BLOCK_SIZE%)
    Let r.p1.x = CInt((lp.y + PLAYER_HEIGHT% / 2) / BLOCK_SIZE%)
    Let r.p2.y = r.p1.y + 1
    Let r.p2.x = r.p1.x

  End If
End Sub

Sub MapSurroundings (p As Player, m As LevelMap, s As Surroundings, threshold As Integer)
  Dim lp As Point
  Dim t, l, b, r As Integer
  LevelPos p, m, lp
  Let t = Floor%(lp.y / BLOCK_SIZE%) - 1
  Let b = Floor%((lp.y + PLAYER_HEIGHT%) / BLOCK_SIZE%)
  Let l = Floor%(lp.x / BLOCK_SIZE%) - 1
  Let r = Floor%((lp.x + PLAYER_WIDTH%) / BLOCK_SIZE%)
  s.Left = -1
  s.Top = -1
  s.Right = -1
  s.Bottom = -1
  If lp.y - (t + 1) * BLOCK_SIZE% < threshold Then Let s.Top = t Else Let s.Top = -1
  If PLAYER_HEIGHT% - b * BLOCK_SIZE% - lp.y < threshold Then Let s.Bottom = b Else Let s.Bottom = -1
  If lp.x - (l + 1) * BLOCK_SIZE% < threshold Then Let s.Left = l Else Let s.Left = -1
  If r * BLOCK_SIZE% - (lp.x + PLAYER_WIDTH%) < threshold Then Let s.Right = r Else Let s.Right = -1
End Sub

Function SurroundingsToString$ (s As Surroundings)
  Dim cont As String
  Let SurroundingsToString$ = "L" + Str$(s.Left) + "R" + Str$(s.Right) + "T" + Str$(s.Top) + "B" + Str$(s.Bottom)
End Function

Function CanClimb% (side As Integer, m As LevelMap, s As Surroundings)
  Select Case side
    Case K_RIGHT
      If s.Right >= 0 And s.Bottom >= 4 Then
        Let CanClimb% = IsBlockAt(s.Bottom - 1, s.Right, m) And m.Topo(s.Bottom - 2, s.Right) = " " And m.Topo(s.Bottom - 3, s.Right) = " " And m.Topo(s.Bottom - 4, s.Right) = " "
        Exit Function
      End If
    Case K_LEFT
      If s.Left >= 0 And s.Bottom >= 4 Then
        Let CanClimb% = IsBlockAt(s.Bottom - 1, s.Left, m) And m.Topo(s.Bottom - 2, s.Left) = " " And m.Topo(s.Bottom - 3, s.Left) = " " And m.Topo(s.Bottom - 4, s.Left) = " "
        Exit Function
      End If
  End Select
  Let CanClimb% = FALSE
End Function

Function CanUnclimb% (p As Point, side As Integer, m As LevelMap, s As Surroundings)
  Select Case side
    Case K_RIGHT
      If s.Left >= 0 And s.Left < M_W% - 1 And s.Bottom >= 2 And s.Bottom < M_H% Then
        If IsBlockAt(s.Bottom + 1, s.Left + 2, m) And m.Topo(s.Bottom, s.Left + 2) = " " And m.Topo(s.Bottom - 1, s.Left + 2) = " " And m.Topo(s.Bottom - 2, s.Left + 2) = " " Then
          Let CanUnclimb% = TRUE
          Exit Function
        End If
      End If
    Case K_LEFT
      If s.Right >= 2 And s.Right < M_W% - 1 And s.Bottom >= 2 And s.Bottom < M_H% Then
        If IsBlockAt(s.Bottom + 1, s.Right - 2, m) And m.Topo(s.Bottom, s.Right - 2) = " " And m.Topo(s.Bottom - 1, s.Right - 2) = " " And m.Topo(s.Bottom - 2, s.Right - 2) = " " Then
          Let CanUnclimb% = TRUE
          Exit Function
        End If
      End If
  End Select
  Let CanUnclimb% = FALSE
End Function


Function Blocked% (side As Integer, m As LevelMap, s As Surroundings)
  Dim r As Rectangle
  Select Case side
    Case K_LEFT
      If s.Left >= 0 Then
        Dim y1 As Integer
        For y1 = s.Bottom - 1 To _Max(0, s.Bottom - 3) Step -1
          If IsBlockAt(y1, s.Left, m) Then
            Let Blocked% = TRUE
            Exit Function
          End If
        Next
      End If
    Case K_RIGHT
      If s.Right >= 0 Then
        Dim y2 As Integer
        For y2 = s.Bottom - 1 To _Max(0, s.Bottom - 3) Step -1
          If IsBlockAt(y2, s.Right, m) Then
            Let Blocked% = TRUE
            Exit Function
          End If
        Next
      End If
  End Select
  Let Blocked% = FALSE
End Function

Function CanTakeBlock% (side As Integer, m As LevelMap, s As Surroundings)
  Dim r As Rectangle
  Select Case side
    Case TRUE 'Left
      If s.Left >= 0 Then
        If IsBlockAt(s.Bottom - 1, s.Left, m) And Not IsBlockAt(s.Bottom - 2, s.Left, m) Then
          Let CanTakeBlock% = TRUE
          Exit Function
        End If
      End If
    Case FALSE 'Right
      If s.Right >= 0 Then
        If IsBlockAt(s.Bottom - 1, s.Right, m) And Not IsBlockAt(s.Bottom - 2, s.Right, m) Then
          Let CanTakeBlock% = TRUE
          Exit Function
        End If
      End If
  End Select
  Let CanTakeBlock% = FALSE
End Function

Sub TakeBlock (side As Integer, m As LevelMap, s As Surroundings)
  Select Case side
    Case TRUE 'Left
      m.Topo(s.Bottom - 1, s.Left) = T_NOTHING
    Case FALSE 'Right
      m.Topo(s.Bottom - 1, s.Right) = T_NOTHING
  End Select
  Dodu.HasBlock = TRUE
End Sub

Function CanDropBlock% (side As Integer, m As LevelMap, s As Surroundings)
  Select Case side
    Case TRUE 'Left
      If s.Left >= 0 _AndAlso s.Bottom >= 0 _AndAlso s.Bottom < M_H - 2 _AndAlso (m.Topo(s.Bottom, s.Left) = " " Or m.Topo(s.Bottom - 1, s.Left) = " ") Then
        Let CanDropBlock% = TRUE
      End If
    Case FALSE 'Right
      If s.Right >= 0 _AndAlso s.Bottom >= 0 _AndAlso s.Bottom < m.Height - 2 _AndAlso m.Topo(s.Bottom, s.Right) = " " Then
        Let CanDropBlock% = TRUE
      End If
  End Select
  Let CanDropBlock% = FALSE
End Function

Sub DropBlock (lp As Point, side As Integer, m As LevelMap)
  Dim p As Point, y As Integer, start As Integer
  Select Case side
    Case TRUE 'Left
      Let p.x = Floor%(lp.x / BLOCK_SIZE%) - 1
    Case FALSE 'Right
      Let p.x = Floor%((lp.x + PLAYER_WIDTH%) / BLOCK_SIZE%) + 1
  End Select
  Let start = Floor%((lp.y + PLAYER_HEIGHT%) / BLOCK_SIZE%) - 1
  If m.Topo(start, p.x) <> T_NOTHING Then
    Exit Sub
  End If
  For y = start + 1 To M_H - 1
    Let p.y = y
    If IsBlockAt(y, p.x, m) Then
      Let m.Topo(y - 1, p.x) = T_BLOCK_W
      Let Dodu.HasBlock = FALSE
      Exit Sub
    End If
  Next
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

Sub DrawSurroundings (s As Surroundings, m As LevelMap, threshold As Integer)
  Dim v As Integer
  If s.Top >= 0 Then
    Let v = s.Top * BLOCK_SIZE% + m.PanY + (BLOCK_SIZE% - 1)
    Line (0, v)-(SCREEN_W%, v + threshold), _RGB32(255, 255, 0, 128), BF ' yellow
  End If
  If s.Bottom >= 0 Then
    Let v = s.Bottom * BLOCK_SIZE% + m.PanY
    Line (0, v)-(SCREEN_W%, v - threshold), _RGB32(255, 0, 0, 128), BF ' red
  End If
  If s.Left >= 0 Then
    Let v = s.Left * BLOCK_SIZE% + m.PanX + (BLOCK_SIZE% - 1)
    Line (v, 0)-(v + threshold, SCREEN_H%), _RGB32(255, 0, 255, 128), BF ' pink
  End If
  If s.Right >= 0 Then
    Let v = s.Right * BLOCK_SIZE% + m.PanX
    Line (v, 0)-(v - threshold, SCREEN_H%), _RGB32(0, 255, 0, 128), BF ' green
  End If
End Sub

' --------------------------
' Main loop
' --------------------------
Do
  _Limit FPS%
  ' Thermometer
  Let Dodu.ThermoTick = (Dodu.ThermoTick + 1) Mod (FPS% * THERMO_TICK%)
  If Dodu.ThermoTick = 0 Then
    Let Dodu.Temp = Dodu.Temp - 1
  End If
  If Dodu.Temp = 0 Then GoTo GameOver:
  _Dest ImgBuffer
  DrawBackground ImgBuffer
  DrawLevel 1, ImgBuffer
  DrawPlayer ImgBuffer
  DrawThermometer ImgBuffer
  Dim lp As Point
  LevelPos Dodu, Levels(0), lp
  Dim s_wide As Surroundings, s_tight As Surroundings, s_climb As Surroundings
  MapSurroundings Dodu, Levels(0), s_wide, 5
  MapSurroundings Dodu, Levels(0), s_tight, 1
  MapSurroundings Dodu, Levels(0), s_climb, -3
  'Line (r.p1.y * BLOCK_SIZE + Levels(0).PanX, r.p1.x * BLOCK_SIZE% + Levels(0).PanY)-(r.p2.y * BLOCK_SIZE% + Levels(0).PanX + BLOCK_SIZE% - 1, r.p2.x * BLOCK_SIZE% + Levels(0).PanY + BLOCK_SIZE% - 1), _RGB32(255, 0, 0), B
  If SHOW_SURROUNDINGS Then
    DrawSurroundings s_climb, Levels(0), -3
    '_PrintString (0, 48), Str$(s_wide.Right) + ",", ImgBuffer
  End If
  '_PrintString (0, 48), Str$(Dodu.IsClimbing)
  _PutImage (0, 0)-(SCREEN_W% * SCALE% - 1, SCREEN_H% * SCALE% - 1), ImgBuffer, MainScreen
  If CanDropBlock%(Dodu.ToLeft, Levels(0), s_wide) Then
    _PrintString (0, 48), "LEFT"
  ElseIf CanDropBlock%(Not Dodu.ToLeft, Levels(0), s_wide) Then
    _PrintString (0, 48), "RIGHT"
  End If
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
  If _KeyDown(K_LEFT) Then
    If Blocked(K_LEFT, Levels(0), s_climb) Then
      If CanClimb%(K_LEFT, Levels(0), s_climb) Then
        Let Dodu.IsClimbing = 11
      End If
    Else
      MovePlayer -1, 0
      If CanUnclimb%(lp, K_LEFT, Levels(0), s_wide) Then
        Let Dodu.IsFalling = 11
      End If
    End If
  ElseIf _KeyDown(K_RIGHT) Then
    If Blocked(K_RIGHT, Levels(0), s_climb) Then
      If CanClimb%(K_RIGHT, Levels(0), s_climb) Then
        Let Dodu.IsClimbing = 11
      End If
    Else
      MovePlayer 1, 0
      If CanUnclimb%(lp, K_RIGHT, Levels(0), s_wide) Then
        Let Dodu.IsFalling = 11
      End If
    End If
  ElseIf _KeyDown(K_UP) And Not Dodu.HasBlock _AndAlso CanTakeBlock%(Dodu.ToLeft, Levels(0), s_wide) Then
    TakeBlock Dodu.ToLeft, Levels(0), s_wide
  ElseIf _KeyDown(K_DOWN) And Dodu.HasBlock Then '_AndAlso CanDropBlock%(Dodu.ToLeft, Levels(0), s_wide) Then
    DropBlock lp, Dodu.ToLeft, Levels(0)
  ElseIf _KeyDown(K_ESC) Then
    GoTo Quit:
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

