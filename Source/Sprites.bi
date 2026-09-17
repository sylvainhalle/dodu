' Image folder
Const IMG_DIR$ = "/home/sylvain/Workspaces/dodu/Source/images"

' Transparent color across sprites
Const COLOR_PINK~& = _RGB32(255, 0, 255)

' Other useful colors
Const COLOR_RED~& = _RGB32(255, 0, 0)
Const COLOR_GREEN~& = _RGB32(0, 255, 0)
Const COLOR_YELLOW~& = _RGB32(255, 255, 0)
Const COLOR_BLACK~& = _RGB32(0, 0, 0)


'**
'* Point type. Represents a point in a two-dimensional space.
'**
Type Point
  '** The x coordinate of the point
  x As Integer
  '** The y coordinate of the point
  y As Integer
End Type

Declare Sub Point_Set (p As Point, x As Integer, y As Integer)
declare	Function Point_ToString$ (p As Point)
	
	'**
'* A bitmap to be drawn on a viewport.
'**
Type Sprite

  '** A Long pointer to the sprite's image data
  Content As Long

  '** A point representing the size of the image
  Size As Point

  '** The offset of the sprite, in pixels. This is the location where the
  '* (0,0) coordinate of the sprite should be placed.
  Offset As Point
End Type

	'** - Viewport -------------------------------------------------'

' Viewport type
Type Viewport
  Size As Point
  Pan As Point
  Scale As Single
  Buffer As Long
End Type

declare Sub Viewport_Init_Default (v As Viewport, size As Point)

declare Sub Viewport_Init (v As Viewport, size As Point, pan As Point, scale As Single)
declare Sub Viewport_PointToScreen (v As Viewport, p_src As Point, p_dest As Point)
declare Sub Viewport_Clear (v As Viewport)
Declare Sub Viewport_Line (v As Viewport, p1 As Point, p2 As Point, clr As _Unsigned Long, box As Integer, filled As Integer)
Declare Sub Viewport_Screen (v as Viewport)
Declare Sub Viewport_Display (v as Viewport)
Declare Sub Viewport_Print (v As Viewport, s As String, p As Point)
Declare Sub Viewport_PutSprite (v As Viewport, absolute As Integer, s As Sprite, p As Point, flipped As Integer)
	
	Dim Shared CharSprites(1) As Sprite
Dim DEFAULT_OFFSET As Point
Sprite_Load CharSprites(0), "/Dodu_right_0.png", DEFAULT_OFFSET

Dim Shared P_ORIGIN As Point
Point_Set P_ORIGIN, 0, 0

' Blocks
Dim Shared BlockBlue As Sprite
Sprite_Load BlockBlue, "/BlockBlue.gif", DEFAULT_OFFSET
Dim Shared BlockWhite As Sprite
Sprite_Load BlockWhite, "/Block_white.gif", DEFAULT_OFFSET

' Goal post
Dim Shared Pole As Sprite
Dim PoleOffset As Point
Point_Set PoleOffset, 1, -9
Sprite_Load Pole, "/Pole.gif", PoleOffset

' Thermometer
Dim Shared Thermometer As Sprite
Sprite_Load Thermometer, "/Thermometer.gif", DEFAULT_OFFSET
Const THERMO_RED~& = _RGB32(170, 0, 0)

' Background
Dim Shared Background As Long
Let Background = _LoadImage(IMG_DIR$ + "/Background.gif")

' Other constants
Const PLAYER_HEIGHT% = 33
Const PLAYER_WIDTH% = 19
Const BLOCK_SIZE% = 11