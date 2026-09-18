'-----------------------------------------------------------------------------
'    Dodu, an old-school QuickBasic game
'    Copyright (C) 2026  Sylvain Hallé
'
'    This program is free software: you can redistribute it and/or modify
'    it under the terms of the GNU General Public License as published by
'    the Free Software Foundation, either version 3 of the License, or
'    (at your option) any later version.
'
'    This program is distributed in the hope that it will be useful,
'    but WITHOUT ANY WARRANTY; without even the implied warranty of
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'    GNU General Public License for more details.
'
'    You should have received a copy of the GNU General Public License
'    along with this program.  If not, see <https://www.gnu.org/licenses/>.
'-----------------------------------------------------------------------------

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
'* Sets the coordinates of p2 as s * those of p1.
'**
Declare Function Point_Scale (p2 As Point, s as Single, p1 As Point)

'**
'* Checks if a point is valid.
'**
Declare Function Point_IsValid (p As Point)

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
  
  '** The offset of the sprite, in pixels. This is the location where the
  '* (0,0) coordinate of the sprite should be placed when flipped.
  OffsetFlip As Point
End Type

'**
'* Loads a sprite and sets pink as its transparent color
'**
Declare Sub Sprite_Load (s As Sprite, file As String, offset As Point, offsetflip AS Point)

'**
'* Copies the content of a sprite into another one.
'**
Declare Sub Sprite_Copy (dst As Sprite, src As Sprite)

' }}}

'**
'** - Ticker --------------------------------------------------- {{{
'**

Type Ticker
	Length As Integer
	Index As Integer
	Loop As Integer
	Speed As Integer
	TickCnt As Integer
End Type

Declare Sub Ticker_Init (t As Ticker, l As Integer, speed As Integer, isloop As Integer)

Declare Sub Ticker_Tick (t As Ticker)

Declare Sub Ticker_Reset (t As Ticker)

Declare Function Ticker_Finished% (t As Ticker)

'**
'** - Sprite sequence------------------------------------------- {{{
'**
Type SpriteSequence
	Ticker As Ticker
	Sprites(10) As Sprite
	Flipped As Integer
End Type

'**
'* Initializes a new sprite sequence.
'**
Declare Sub SpriteSequence_Init (s As SpriteSequence, l As Integer, spd As Integer, isloop As Integer)

'**
'* Advances the sprite sequence by one tick.
'**
Declare Sub SpriteSequence_Tick (s As SpriteSequence)

'**
'* Identifies the current sprite in the sequence.
'**
Declare Sub SpriteSequence_Current (s as SpriteSequence, spr as Sprite)

'**
'* Loads a sprite at a given index in the sequence.
'**
Declare Sub SpriteSequence_Load (s As SpriteSequence, spr As Sprite, index As Integer)

declare Sub SpriteSequence_SetFlip (s As SpriteSequence, flipped As Integer)

declare Sub SpriteSequence_PutSprite (s As SpriteSequence, v as Viewport, absolute As Integer, p As Point)

Type Trajectory
	Ticker As Ticker
	Points(10) As Point
	Flipped As Integer
End Type

Declare Sub Trajectory_Init (t As Trajectory, l As Integer, speed As Integer, flipped As Integer, isloop As Integer)

Declare Sub Trajectory_AddPoint (t as Trajectory, p As Point)

Declare Sub Trajectory_AddCoords (t As Trajectory, x as Integer, y as Integer)

Declare Sub Trajectory_Tick (t As Trajectory, p as Point)

Declare Sub Trajectory_Reset (t As Trajectory)

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

'**
'* Puts the current sprite of a sprite sequence at a location on the viewport.
'**
Declare Sub Viewport_PutSpriteSequence (v As Viewport, absolute As Integer, s As SpriteSequence, p As Point)


'**
'* Sets the font for a viewport.
'**
Declare Sub Viewport_SetFont (v as Viewport, font as _Unsigned Long)

' }}}

' :mode=visualbasic:folding=explicit:wrap=none: