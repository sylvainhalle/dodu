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

'**
'* Denotes an interval of pixels.
'**
Type Interval
	iFrom As Integer
	iTo As Integer
End Type

Declare Function Interval_ToString$(i As Interval)

Declare Sub GroundFootprint(side As Integer, lp As Point, threshold As Integer, interval As Integer)

Declare Function IsSupported% (i As Interval, row As Integer, m As LevelMap)

'**
'* Calculates the vertical line ofo the grid closest to the player.
'**
Declare Function SideColumn% (side As Integer, lp As Point, threshold As Integer)

'**
'* Determines if a square can be climbed on.
'**
Declare Sub ClimbableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Determines if a square can be grabbed.
'**
Declare Sub TakeableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Determines if a block can be dropped in a square.
'**
Declare Sub DroppableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Determines if a square can be "unclimbed".
'**
Declare Sub UnclimbableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Determines if a square can block the player from walking.
'**
Declare Sub BlockingSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Determines if a square contains the goal.
'**
Declare Sub PoleSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Determines if a square contains mittens.
'**
Declare Sub MittensSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Determines if a square contains a tuque.
'**
Declare Sub TuqueSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Determines if a square contains a cookie.
'**
Declare Sub CookieSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Determines if a square contains a coffee. Sets p to (-1, -1) if not.
'**
Declare Sub CoffeeSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Calculates the square of interaction with the character.
'**
Declare Sub FeetSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Determines if the square under the player's feet contains snow. Sets p
'* to (-1, -1) if not.
'**
Declare Sub SnowSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Calculates the square that can be the target for throwing the hook. Sets p
'* to (-1, -1) if not.
'**
Declare Sub ThrowSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Calculates the square that can be the target for pulling the rope. Sets p
'* to (-1, -1) if not.
'**
Declare Sub PullSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

'**
'* Returns TRUE if the player at level position lp is standing on a block
'* (checks both feet against the row directly below the player).
'**
Declare Function IsOnGround% (lp As Point, m As LevelMap)

' :mode=visualbasic:folding=explicit:wrap=none: