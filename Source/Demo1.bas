Option Base 0
Option _Explicit

' --------------------------
' Program constants
' --------------------------

' Booleans
Const TRUE = -1
Const FALSE = 0

' Keys
Const K_LEFT = 19200
Const K_RIGHT = 19712

' Screen dimensions
Const SCREEN_W% = 80
Const SCREEN_H% = 64

' Frame rate
Const FPS% = 25

' Window scaling factor
Const SCALE% = 6

' Number of seconds between ticks of the thermometer
Const THERMO_TICK% = 3

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
  ToLeft As Integer
  Temp As Integer ' 0 to 10
  ThermoTick As Integer
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
Let Dodu.ScreenPos.x = BLOCK_SIZE%
Let Dodu.ScreenPos.y = 0
Let Dodu.HasBlock = FALSE
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
      If m.Topo(i, j) = "@" Then
        Dim p As Point
        Let p.x = j * BLOCK_SIZE% + m.PanX
        Let p.y = i * BLOCK_SIZE% + m.PanY
        DrawSprite BlockBlue, p, FALSE, buf
      End If
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
End Sub

Sub DrawThermometer (buf As Long)
  Dim p As Point
  Let p.x = 4
  Let p.y = 4
  DrawSprite Thermometer, p, FALSE, buf
  Line (6, 15 - Dodu.Temp)-(7, 15), THERMO_RED~&, BF
  Line (5, 16)-(8, 18), THERMO_RED~&, BF
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
  LevelPos p, m, lp
  Let r.p1.y = Floor%(lp.x / BLOCK_SIZE%)
  Let r.p1.x = Floor%(lp.y / BLOCK_SIZE%)
  Let r.p2.y = Ceil%((lp.x + PLAYER_WIDTH% - 1) / BLOCK_SIZE%) - 1
  Let r.p2.x = Ceil%((lp.y + PLAYER_HEIGHT% - 1) / BLOCK_SIZE%) - 1
End Sub

Function Blocked% (side As Integer, m As LevelMap)
  Dim s As Sprite
  Let s = CharSprites(Dodu.SpriteIndex)
  Dim r As Rectangle
  MapRect Dodu, Levels(0), r
  ' Look out, points in the rect have their *line* first
  Select Case side
    Case K_LEFT
      If r.p1.y = 0 Then
        Let Blocked% = TRUE
        Exit Function
      End If
      Dim x As Integer
      For x% = r.p1.x To r.p2.x
        If m.Topo(x%, r.p1.y) = "@" Then
          Let Blocked% = TRUE
          Exit Function
        End If
      Next
      Let Blocked% = FALSE
    Case K_RIGHT
      If r.p2.y = M_W - 1 Then
        Let Blocked% = TRUE
        Exit Function
      End If
      Dim x2 As Integer
      For x2% = r.p1.x To r.p2.x
        If m.Topo(x2%, r.p2.y) = "@" Then
          Let Blocked% = TRUE
          Exit Function
        End If
      Next
      Let Blocked% = FALSE

  End Select

End Function

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
  If Dodu.Temp = 0 Then End
  _Dest ImgBuffer
  DrawBackground ImgBuffer
  DrawLevel 1, ImgBuffer
  DrawPlayer ImgBuffer
  DrawThermometer ImgBuffer
  Dim r As Rectangle
  MapRect Dodu, Levels(0), r
  _PrintString (0, 48), RectangleToString$(r), ImgBuffer
  _PutImage (0, 0)-(SCREEN_W% * SCALE% - 1, SCREEN_H% * SCALE% - 1), ImgBuffer, MainScreen
  _Display
  If _KeyDown(K_LEFT) Then
    If Blocked(K_LEFT, Levels(0)) Then _Continue
    Let Dodu.ToLeft = -1
    If Dodu.ScreenPos.x > 10 Then
      Let Dodu.ScreenPos.x = Dodu.ScreenPos.x - 1
    Else
      Let Levels(0).PanX = Levels(0).PanX + 1
    End If
  ElseIf _KeyDown(K_RIGHT) Then
    If Blocked(K_RIGHT, Levels(0)) Then _Continue
    Let Dodu.ToLeft = 0
    If Dodu.ScreenPos.x < 20 Then
      Let Dodu.ScreenPos.x = Dodu.ScreenPos.x + 1
    Else
      Let Levels(0).PanX = Levels(0).PanX - 1
    End If
  End If
Loop


'$Include:'Levels.bm'

