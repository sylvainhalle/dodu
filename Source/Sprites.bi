' --------------------------
' Sprite functions
' --------------------------

'$IncludeOnce

' Image folder
Const IMG_DIR$ = "/home/sylvain/Workspaces/dodu/Source/images"

' Transparent color across sprites
Const PINK~& = _RGB32(255, 0, 255)

' Point type
Type Point
  x As Integer
  y As Integer
End Type

Function PointToString$ (p As Point)
  Let PointToString$ = "(" + _Trim$(Str$(p.x)) + "," + _Trim$(Str$(p.y)) + ")"
End Function

' Rectangle type
Type Rectangle
  p1 As Point
  p2 As Point
End Type

Function RectangleToString$ (r As Rectangle)
  Let RectangleToString$ = PointToString$(r.p1) + "-" + PointToString$(r.p2)
End Function

' Sprite type
Type Sprite
  Content As Long
  Width As Integer
  Height As Integer
End Type

Dim Shared CharSprites(1) As Sprite
LoadSprite "/Dodu_right_0.png", CharSprites(0)


' Blocks
Dim Shared BlockBlue As Sprite
LoadSprite "/BlockBlue.gif", BlockBlue
Dim Shared BlockWhite As Sprite
LoadSprite "/Block_white.gif", BlockWhite


' Thermometer
Dim Shared Thermometer As Sprite
LoadSprite "/Thermometer.gif", Thermometer
Const THERMO_RED~& = _RGB32(170, 0, 0)

' Background
Dim Shared Background As Long
Let Background = _LoadImage(IMG_DIR$ + "/Background.gif")

' Other constants
Const PLAYER_HEIGHT% = 33
Const PLAYER_WIDTH% = 19
Const BLOCK_SIZE% = 11

' --------------------------
' Loads a sprite and sets pink as its transparent color
' --------------------------
Sub LoadSprite (file As String, s As Sprite)
  Let s.Content = _LoadImage(IMG_DIR$ + file, 32)
  Let s.Width = _Width(s.Content)
  Let s.Height = _Height(s.Content)
  _ClearColor PINK, s.Content
End Sub

' --------------------------
' Prints a sprite
' --------------------------
Sub DrawSprite (s As Sprite, p As Point, flipped As Integer, buf As Long)
  If flipped Then
    _PutImage (p.x + s.Width - 1, p.y)-(p.x, p.y + s.Height - 1), s.Content, buf
  Else
    _PutImage (p.x, p.y)-(p.x + s.Width - 1, p.y + s.Height - 1), s.Content, buf
  End If
End Sub

' :mode=visualbasic:
