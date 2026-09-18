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

declare Sub ClimbableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)
declare Sub TakeableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)
declare Sub DroppableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)
declare Sub UnclimbableSquare (side As Integer, lp As Point, m As LevelMap, p As Square)
declare Function SideColumn% (side As Integer, lp As Point, threshold As Integer)
declare Sub BlockingSquare (side As Integer, lp As Point, m As LevelMap, p As Square)
declare Sub PoleSquare (side As Integer, lp As Point, m As LevelMap, p As Square)

' :mode=visualbasic:folding=explicit:wrap=none: