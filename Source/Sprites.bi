

' Colors
Const COLOR_RED~& = _RGB32(255, 0, 0)
Const COLOR_GREEN~& = _RGB32(0, 255, 0)
Const COLOR_YELLOW~& = _RGB32(255, 255, 0)
Const COLOR_BLACK~& = _RGB32(0, 0, 0)
Const COLOR_PINK~& = _RGB32(255, 0, 255)

' Transparent color across sprites
Const COLOR_TRANSPARENT~& = COLOR_PINK~&

'**
'** - Point ------------------------------------------------- {{{
'**

'**
'* Point type. Represents a point in a two-dimensional space.
'**
Type Point
  '** The x coordinate of the point
  x As Integer
  '** The y coordinate of the point
  y As Integer
End Type

'**
'* Sets the coordinates of a point.
'**
Declare Sub Point_Set (p As Point, x As Integer, y As Integer)

'**
'* Returns the coordinates of a point as a string
'* @param p The point
'* @return The coordinates as a string
'**
Declare	Function Point_ToString$ (p As Point)

'**
'* A instance of the point (0,0).
'**
Dim Shared P_ORIGIN As Point: Point_Set P_ORIGIN, 0, 0

' }}}

'**
'** - Sprite ------------------------------------------------- {{{
'**

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

'**
'* Loads a sprite and sets pink as its transparent color
'**
Declare Sub Sprite_Load (s As Sprite, file As String, offset As Point)
' }}}

'**
'** - Viewport ------------------------------------------------- {{{
'**

' Viewport type
Type Viewport
  Size As Point
  Pan As Point
  Scale As Single
  Buffer As Long
End Type

'**
'* Initializes a new viewport with default scale and pan.
'**
Declare Sub Viewport_Init_Default (v As Viewport, size As Point)

'**
'* Initializes a new viewport.
'**
Declare Sub Viewport_Init (v As Viewport, size As Point, pan As Point, scale As Single)

'**
'* Calculates the physical coordinates of a point in the buffer
'* where the viewport is displayed.
'**
Declare Sub Viewport_PointToScreen (v As Viewport, p_src As Point, p_dest As Point)

'**
'* Clears the content of the viewport.
'**
Declare Sub Viewport_Clear (v As Viewport)

'**
'* Equivalent of the LINE command for a viewport.
'**
Declare Sub Viewport_Line (v As Viewport, p1 As Point, p2 As Point, clr As _Unsigned Long, box As Integer, filled As Integer)

'**
'* Equivalent of the SCREEN command for a viewport.
'**
Declare Sub Viewport_Screen (v as Viewport)

'**
'* Copies the buffer of a viewport into another one
'**
Declare Sub Viewport_Copy (src As Viewport, dst As Viewport)

'**
'* Prints text in the viewport.
'**
Declare Sub Viewport_Print (v As Viewport, s As String, p As Point)

'**
'* Puts a sprite at a location on the viewport.
'**
Declare Sub Viewport_PutSprite (v As Viewport, absolute As Integer, s As Sprite, p As Point, flipped As Integer)

' }}}

' :mode=visualbasic:folding=explicit:wrap=none: