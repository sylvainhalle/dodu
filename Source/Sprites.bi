'-----------------------------------------------------------------------------
'    Dodu, an old-school QuickBasic game
'    Copyright (C) 1994-2026  Sylvain Hallé
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

' --------------------------
' Video modes
' --------------------------
Const IMG_MODE_CGA$ = "cga"
Const IMG_MODE_MCGA$ = "mcga"
Const IMG_MODE_EGA$ = "ega"
Const IMG_MODE_HER$ = "her"
Const IMG_MODE_TI83$ = "ti83"
Dim Shared ImgMode As String
Let ImgMode = IMG_MODE_EGA ' EGA by default

' --------------------------
' Screen dimensions
' --------------------------
Const SCREEN_GAMEBUINO_X% = 80
Const SCREEN_GAMEBUINO_Y% = 64
Const SCREEN_PC_X% = 160
Const SCREEN_PC_Y% = 120
Dim Shared ScreenDims As Point
Point_Set ScreenDims, SCREEN_GAMEBUINO_X, SCREEN_GAMEBUINO_Y
Dim Shared ScreenActualDims As Point
Point_Set ScreenActualDims, ScreenDims.x, ScreenDims.y

' --------------------------
' Colors
' --------------------------
Const COLOR_BLACK& = _RGB32(0, 0, 0)
Const COLOR_WHITE& = _RGB32(255, 255, 255)
Const COLOR_RED& = _RGB32(255, 0, 0)
Const COLOR_GREEN& = _RGB32(0, 255, 0)
Const COLOR_YELLOW& = _RGB32(255, 255, 0)
Const COLOR_BLACK& = _RGB32(0, 0, 0)
Const COLOR_PINK& = _RGB32(255, 0, 255)
Const COLOR_CYAN& = _RGB32(0, 255, 255)
Const COLOR_DARKGREEN& = _RGB32(0, 128, 0)
Const COLOR_TI83& = _RGB32(151, 166, 99)
Const COLOR_TI83_SCANLINE& = _RGB32(151, 166, 99, 128)
Const COLOR_TRANSPARENT = _RGB32(52, 52, 52) ' Hex: 343434
Const COLOR_GREEN_HI = _RGB32(0, 255, 0)
Const COLOR_GREEN_MD = _RGB32(0, 170, 0)
Const COLOR_GREEN_LO = _RGB32(0, 85, 0)

' --------------------------
' Scanline settings
' --------------------------
Dim Shared Scanlines As Integer
Let Scanlines = FALSE
Dim Shared ScanlineColor As Long
Let ScanlineColor = _RGB32(0, 0, 0, 56)
Dim Shared ScanlineWidth As Integer
Let ScanlineWidth = 1

' Sprite mode (32 = software, 33 = hardware)
Const SPRITE_MODE% = 32

' Mode when loading sprites (257 = paletted)
Const IMAGE_MODE% = 257

' --------------------------
' Stereoscopic flags
' --------------------------
Dim Shared CfgStereoscopic As Integer
Let CfgStereoscopic = FALSE
Const LAYER_DIVERGENCE = 0.5
Const EYE_SEP = 10
Dim Shared CfgStereoTempfile As String, CfgStereoOutfile As String
Dim Shared CfgStereoTempfileC As String * 32, CfgStereoOutfileC As String * 32
Let CfgStereoTempfile = ""
Let CfgStereoOutfile = ""

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
'* Sets the coordinates of p1 by s.
'**
Declare Sub Point_Scale (p As Point, s As Single)


'**
'* Returns the coordinates of a point as a string
'* @param p The point
'* @return The coordinates as a string
'**
Declare	Function Point_ToString$ (p As Point)

'**
'* Translates a point.
'**
Declare Sub Point_Add (p1 As Point, vector As Point)

'**
'* Translates a point.
'**
Declare Sub Point_Subtract (p1 As Point, vector As Point)

'**
'* A instance of the point (0,0).
'**
Dim Shared PtOrigin As Point: Point_Set PtOrigin, 0, 0

' }}}

'**
'** - Sprite sequence------------------------------------------- {{{
'**

Const SPSQ_KEEP = 0
Const SPSQ_RESET = 1

Type SpriteSequence
    Content As Long
    Ticker As Ticker
    Size As Point
    Flipped As Integer
    OffsetR As Point
    OffsetL As Point
    Animate As Integer
    OnEnd As Integer
End Type

'**
'* Initializes a new sprite sequence.
'**
Declare Sub SpriteSequence_Init (s As SpriteSequence, content As Long, frames As Integer, spd As Integer, animate As Integer, isloop As Integer, offsetL As Point, offsetR As Point, clr As _Unsigned Long)

'**
'* Initializes a sprite sequence from an image file (see SpriteSequence_Init
'* for the other parameters). Raises error 97 if the file cannot be loaded.
'**
Declare Sub SpriteSequence_InitFile (s As SpriteSequence, filename As String, frames As Integer, spd As Integer, animate As Integer, isloop As Integer, offsetL As Point, offsetR As Point, clr As _Unsigned Long)

'**
'* Advances the sprite sequence by one tick.
'**
Declare Sub SpriteSequence_Tick (s As SpriteSequence)

'**
'* Starts the animation of a sprite sequence from its first frame, unless it
'* is already running.
'**
Declare Sub SpriteSequence_Start (s As SpriteSequence)

'**
'* Stops the animation of a sprite sequence on its current frame.
'**
Declare Sub SpriteSequence_Stop (s As SpriteSequence)

'**
'* Duplicates a sprite sequence. Note that the duplicate will share the
'* same reference to the bitmap as its original.
'**
Declare Sub SpriteSequence_Copy (target As SpriteSequence, source As SpriteSequence)

'**
'* Identifies the current sprite in the sequence.
'**
Declare Sub SpriteSequence_Current (s As SpriteSequence, p1 As Point, p2 As Point)

'**
'* Returns TRUE if the animation of a non-looping sequence has ended.
'**
Declare Function SpriteSequence_IsFinished% (s As SpriteSequence)

'**
'* Returns the width of one frame of the sequence.
'**
Declare Function SpriteSequence_Width% (s As SpriteSequence)

'**
'* Returns the height of the sequence's frames.
'**
Declare Function SpriteSequence_Height% (s As SpriteSequence)

Type Trajectory
    Ticker As Ticker
    Points(10) As Point
    Flipped As Integer
End Type

'**
'* Initializes a trajectory of l points, advancing every speed ticks.
'* If flipped is TRUE, x displacements are mirrored.
'**
Declare Sub Trajectory_Init (t As Trajectory, l As Integer, speed As Integer, flipped As Integer, isloop As Integer)

'**
'* Sets point number index of the trajectory to p (a displacement).
'**
Declare Sub Trajectory_AddPoint (t As Trajectory, p As Point, index As Integer)

'**
'* Copies trajectory src into dst.
'**
Declare Sub Trajectory_Copy (dst As Trajectory, src As Trajectory)

'**
'* Sets point number index of the trajectory to (x, y).
'**
Declare Sub Trajectory_AddCoords (t As Trajectory, x As Integer, y As Integer, index As Integer)

'**
'* Stores in p the current displacement of the trajectory (mirrored if the
'* trajectory is flipped), then advances it by one tick.
'**
Declare Sub Trajectory_Tick (t As Trajectory, p As Point)

'**
'* Starts (or resumes) a trajectory.
'**
Declare Sub Trajectory_Start (t As Trajectory)

'**
'* Rewinds a trajectory to its first point and stops it.
'**
Declare Sub Trajectory_Reset (t As Trajectory)

'**
'** - Viewport ------------------------------------------------- {{{
'**

' Scanline settings
Const SCANLINES_NONE = 0
Const SCANLINES_VERT = 1
Const SCANLINES_GRID = 2

' Layer type
Type ViewportLayer
    Buffer As Long
    Divergence As Integer
End Type

Const MAX_LAYERS = 5

' Eye settings
Const EYE_LEFT = -1
Const EYE_NONE = 0
Const EYE_RIGHT = 1

' Viewport type
Type Viewport
    Size As Point
    Pan As Point
    WorldSize As Point
    Scale As Single
    Layers(MAX_LAYERS) As ViewportLayer
    Depth As Integer
    Background As SpriteSequence
    BackgroundPanRatio As Point
    BackgroundOffset As Point
    Foreground As SpriteSequence
    ForegroundPanRatio As Point
    Scanlines As Integer
    ScanlineWidth As Integer
    ScanlineColor As Long
    PanTick As Ticker
    PanTarget As Point
    PanAmount As Point
    FadeInTicker As Ticker
    FadeOutTicker As Ticker
End Type

'**
'* Initializes a new viewport with default scale and pan.
'**
Declare Sub Viewport_Init_Default (v As Viewport, size As Point, ws As Point, depth As Integer)

'**
'* Initializes a new viewport.
'**
Declare Sub Viewport_Init (v As Viewport, size As Point, ws As Point, pan As Point, scale As Single, depth As Integer)

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
'* Starts the animation of the viewport's background and foreground.
'**
Declare Sub Viewport_Start (v As Viewport)

'**
'* Cancels any fade-in or fade-out in progress on the viewport.
'**
Declare Sub Viewport_Reset (v As Viewport)

'**
'* Sets the background for the viewport.
'**
Declare Sub Viewport_SetBackground (v As Viewport, s As SpriteSequence, ratio As Point)

'**
'* Sets the foreground for the viewport.
'**
Declare Sub Viewport_SetForeground (v As Viewport, s As SpriteSequence, ratio As Point)

'**
'* Tiles the viewport's background over layer 0, taking into account its
'* offset, parallax ratio and the horizontal shift divergence (used for
'* stereoscopic rendering).
'**
Declare Sub Viewport_DrawBackground (v As Viewport, divergence As Integer)

'**
'* Equivalent of the LINE command for a viewport.
'**
Declare Sub Viewport_Line (v As Viewport, absolute As Integer, p1 As Point, p2 As Point, clr As Long, box As Integer, filled As Integer, layer As Integer)

'**
'* Equivalent of the LINE command for a viewport.
'**
Declare Sub Viewport_LineC (v As Viewport, absolute As Integer, x1 As Integer, y1 As Integer, x2 As Integer, y2 As Integer, clr As Long, box As Integer, filled As Integer, layer As Integer)

'**
'* Equivalent of the SCREEN command for a viewport.
'**
Declare Sub Viewport_Screen (v As Viewport)

'**
'* Copies the buffer of a viewport into another one
'**
Declare Sub Viewport_Copy (src As Viewport, dst As Viewport, eye As Integer)

'**
'* Prints text in the viewport.
'**
Declare Sub Viewport_Print (v As Viewport, s As String, p As Point, layer As Integer)


'**
'* Puts the contents of a viewport in another viewport.
'**
Declare Sub Viewport_PutViewport (dst As Viewport, absolute As Integer, src As Viewport, p As Point, p1 As Point, p2 As Point, eye As Integer)

'**
'* Puts the current sprite of a sprite sequence at a location on the viewport.
'**
Declare Sub Viewport_PutSpriteSequence (v As Viewport, absolute As Integer, s As SpriteSequence, p As Point, flipped As Integer, layer As Integer)

'**
'* Sets the font for a viewport.
'**
Declare Sub Viewport_SetFont (v As Viewport, font As _Unsigned Long)

'**
'* Sets a point as the center of the viewport
'**
Declare Sub Viewport_SetCenter (v As Viewport, p As Point)

'**
'* Changes the panning of the viewport.
'**
Declare Sub Viewport_MovePan (v As Viewport, p As Point)

'**
'* Changes the panning of the viewport, by progressively moving it towards
'* a target point.
'* @param v The viewport on which to apply the operation
'* @param target The target pan point to reach
'* @param nbframes The total number of frames to reach the target
'**
Declare Sub Viewport_ScrollPan (v As Viewport, target As Point, nbframes As Integer)

'**
'* Scrolls the viewport over nbframes frames so that p ends up at its
'* center (clamped to the world boundaries).
'**
Declare Sub Viewport_ScrollCenter (v As Viewport, p As Point, nbframes As Integer)

'**
'* Stops any scrolling in progress.
'**
Declare Sub Viewport_StopPan (v As Viewport)

'**
'* Displays the current viewport
'**
Declare Sub Viewport_Display (v As Viewport, eye As Integer)

'**
'* Ticks the viewport.
'**
Declare Sub Viewport_Tick (v As Viewport)

'**
'* Starts a fade-in from black lasting numticks ticks.
'**
Declare Sub Viewport_FadeIn (v As Viewport, numticks As Integer)

'**
'* Starts a fade-out to black lasting numticks ticks.
'**
Declare Sub Viewport_FadeOut (v As Viewport, numticks As Integer)

'**
'* Asks the viewport to wait a number of frames.
'**
Declare Sub Viewport_Wait (src As Viewport, dst As Viewport, dur As Single, fps As Integer)

' }}}

' :mode=visualbasic:folding=explicit:wrap=none:


