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

' Max height/width of a level
Const MAP_WIDTH% = 50
Const MAP_HEIGHT% = 50

' Symbols designating level tiles
Const TILE_NOTHING = " "
Const TILE_BLOCK_B = "@"
Const TILE_BLOCK_W = "#"
Const TILE_POLE = "!"
Const TILE_COOKIE = "c"
Const TILE_COFFEE = "f"
Const TILE_MITTENS = "m"
Const TILE_TUQUE = "t"
Const TILE_SNOW = "S"
Const TILE_SNOWSHOES = "h"
Const TILE_BEAR = "B"
Const TILE_WATER = "~"
Const TILE_ROPE = "$"
Const TILE_END = "x"
Const TILE_ENDALL = "X"
Const TILE_MARK = "^"

Type Square
    col As Integer
    row As Integer
End Type

'**
'* Sets the coordinates of a square.
'**
Declare Sub Square_Set (s As Square, col As Integer, row As Integer)

'**
'* Determines if the coordinates of a square correspond to a valid location
'* in the level map.
'**
Declare Function Square_IsValid% (s As Square)

'**
'* Returns a printable representation "[col,row]" of a square (for debugging).
'**
Declare Function Square_ToString$ (s As Square)

'**
'* Returns TRUE if either of the player's feet, at level position lp, rests
'* on a snow square.
'**
Declare Function IsPlayerInSnow (lp As Point, l As LevelMap)

'**
'* Converts the coordinate of a square in the level map to the x,y
'* coordinates of the image buffer (representing the top-left corner of the
'* corresponding box.
'**
Declare Sub Square_ToPoint (s As Square, p As Point)

Type LevelMap
    CutScene As Integer
    SongIndex As Integer
    Width As Integer
    Height As Integer
    Topo(MAP_WIDTH, MAP_HEIGHT) As String
    StartPoint As Square
    Background As Integer
    Foreground As Integer
    BackgroundParallax As Point
    BackgroundOffset As Point
    PanX As Integer
    PanY As Integer
End Type

Const SLOPE_NONE% = 0
Const SLOPE_C% = 1
Const SLOPE_L% = 2
Const SLOPE_R% = 3

'**
'* Finds the square containing the goal (pole) in level l and stores it in s.
'* s is left unchanged if the level has no goal.
'**
Declare Sub Level_GoalSquare(l As LevelMap, s As Square)

'**
'* Returns TRUE if the square (col, row) of level l contains the goal (pole).
'**
Declare Function IsGoalAt (col As Integer, row As Integer, l As LevelMap)

'**
'* Returns TRUE if the square (col, row) of level l contains something solid
'* to stand on (black block, white block or snow).
'**
Declare Function IsBlockAt (col As Integer, row As Integer, l As LevelMap)

'**
'* Returns TRUE if the square (col, row) of level l contains a white
'* (movable) block.
'**
Declare Function IsWhiteBlockAt (col As Integer, row As Integer, l As LevelMap)

'**
'* Returns TRUE if the square (col, row) of level l blocks the player from
'* walking (a block, snow or the pole).
'**
Declare Function IsObstacleAt (col As Integer, row As Integer, l As LevelMap)

'**
'* Returns TRUE if the square (col, row) of level l contains a cookie.
'**
Declare Function IsCookieAt (col As Integer, row As Integer, l As LevelMap)

'**
'* Returns TRUE if the square (col, row) of level l contains a coffee.
'**
Declare Function IsCoffeeAt (col As Integer, row As Integer, l As LevelMap)

'**
'* Returns TRUE if the square (col, row) of level l contains mittens.
'**
Declare Function IsMittenAt (col As Integer, row As Integer, l As LevelMap)

'**
'* Returns TRUE if the square (col, row) of level l contains a tuque.
'**
Declare Function IsTuqueAt (col As Integer, row As Integer, l As LevelMap)

'**
'* Returns TRUE if the square (col, row) of level l contains snow.
'**
Declare Function IsSnowAt (col As Integer, row As Integer, l As LevelMap)

'**
'* Returns the shape of the snow at square (col, row): SLOPE_C if it is
'* flanked on both sides, SLOPE_L or SLOPE_R if open on one side,
'* SLOPE_NONE otherwise.
'**
Declare Function GetSnowSlopeAt (col As Integer, row As Integer, m As LevelMap)

'**
'* Reads the next level from the DATA statements into l (background,
'* foreground, cut scene, song, parallax and map rows). Returns TRUE when
'* this was the last level (map terminated by TILE_ENDALL).
'**
Declare Function LoadLevel% (l As LevelMap)

'**
'* Loads all levels from the LevelData DATA block into the Levels array.
'**
Declare Sub LoadLevels ()

'**
'* Prints the map of level m on the text screen (for debugging).
'**
Declare Sub PrintLevel (m As LevelMap)

' --------------------------
' Level loading
' --------------------------
Dim Shared Levels(20) As LevelMap


' :mode=visualbasic:folding=explicit:wrap=none: