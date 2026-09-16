' --------------------------
' Sprite functions
' --------------------------

'$IncludeOnce

' Image folder
Const IMG_DIR$ = "/home/sylvain/Workspaces/dodu/Source/images"

' Transparent color across sprites
Const PINK~& = _RGB32(255, 0, 255)

' Other useful colors
const COLOR_RED~& = _RGB32(255, 0, 0)
const COLOR_GREEN~& = _RGB32(0, 255, 0)
const COLOR_YELLOW~& = _RGB32(255, 255, 0)

' Point type
Type Point
  x As Integer
  y As Integer
End Type

' Viewport type
Type Viewport
	Position as Point
	
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
  ' A Long pointer to the sprite's image data
  Content As Long
  ' The width of the sprite, in pixels
  Width As Integer
  ' The height of the sprite, in pixels
  Height As Integer
  ' The offset of the sprite, in pixels. This is the location where the
  ' (0,0) coordinate of the sprite should be placed.
  Offset As Point
End Type

Dim Shared CharSprites(1) As Sprite
LoadSprite "/Dodu_right_0.png", CharSprites(0), 0, 0


' Blocks
Dim Shared BlockBlue As Sprite
LoadSprite "/BlockBlue.gif", BlockBlue, 0, 0
Dim Shared BlockWhite As Sprite
LoadSprite "/Block_white.gif", BlockWhite, 0, 0

' Goal post
Dim Shared Pole As Sprite
LoadSprite "/Pole.gif", Pole, 1, -9

' Thermometer
Dim Shared Thermometer As Sprite
LoadSprite "/Thermometer.gif", Thermometer, 0, 0
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
Sub LoadSprite (file As String, s As Sprite, offset_x as Integer, offset_y as Integer)
  Let s.Content = _LoadImage(IMG_DIR$ + file, 32)
  Let s.Width = _Width(s.Content)
  Let s.Height = _Height(s.Content)
  Dim p as Point
  let p.x = offset_x
  let p.y = offset_y
  let s.Offset = p
  _ClearColor PINK, s.Content
End Sub

' --------------------------
' Prints a sprite
' --------------------------
Sub DrawSprite (s As Sprite, p As Point, flipped As Integer, buf As Long)
  If flipped Then
    _PutImage (p.x + s.Offset.x + s.Width - 1, p.y + s.Offset.y)-(p.x + s.Offset.x, p.y + s.Offset.y + s.Height - 1), s.Content, buf
  Else
    _PutImage (p.x + s.Offset.x, p.y + s.Offset.y)-(p.x + s.Offset.x + s.Width - 1, p.y + s.Offset.y + s.Height - 1), s.Content, buf
  End If
End Sub

' :mode=visualbasic:
