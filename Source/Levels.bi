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

' Max height/width of a level
Const M_W% = 30
Const M_H% = 30

' Symbols designating level tiles
Const T_NOTHING = " "
Const T_BLOCK_B = "@"
Const T_BLOCK_W = "#"
Const T_POLE = "!"
Const T_COOKIE = "*"

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
Declare Function Square_IsValid% (s as Square)

'**
'* Converts the coordinate of a square in the level map to the x,y
'* coordinates of the image buffer (representing the top-left corner of the
'* corresponding box.
'**
Declare Sub Square_ToPoint (s as Square, p as Point)

Type LevelMap
  Width As Integer
  Height As Integer
  'Topo(M_W%, M_H%) As String
  Topo(30, 30) As String
  StartPoint As Square
  PanX As Integer
  PanY As Integer
End Type

Declare Function IsGoalAt (col As Integer, row As Integer, l As LevelMap)
Declare Function IsBlockAt (col As Integer, row As Integer, l As LevelMap)
Declare Function IsWhiteBlockAt (col As Integer, row As Integer, l As LevelMap)
Declare Function IsObstacleAt (col As Integer, row As Integer, l As LevelMap)
Declare Sub LoadLevels ()
Declare Sub LoadLevel (l As LevelMap)
Declare Sub PrintLevel (m As LevelMap)

' --------------------------
' Level loading
' --------------------------
Dim Shared Levels(6) As LevelMap


' :mode=visualbasic:folding=explicit:wrap=none: