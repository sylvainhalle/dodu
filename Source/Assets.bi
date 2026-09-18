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

' DependsOn: 'Sprites.bi'

Const IMG_DIR$ = "/home/sylvain/Workspaces/dodu/Source/images"

Dim Shared CharSprites(1) As Sprite
Dim DEFAULT_OFFSET As Point
Let DEFAULT_OFFSET = P_ORIGIN

' Character
Sprite_Load CharSprites(0), IMG_DIR$ + "/Dodu_right_0.png", DEFAULT_OFFSET

' Blocks
Dim Shared BlockBlue As Sprite
Sprite_Load BlockBlue, IMG_DIR$ + "/BlockBlue.gif", DEFAULT_OFFSET
Dim Shared BlockWhite As Sprite
Sprite_Load BlockWhite, IMG_DIR$ + "/Block_white.gif", DEFAULT_OFFSET

' Goal post
Dim Shared Pole As Sprite
Dim PoleOffset As Point
Point_Set PoleOffset, 1, -9
Sprite_Load Pole, IMG_DIR$ + "/Pole.gif", PoleOffset

' Thermometer
Dim Shared Thermometer As Sprite
Sprite_Load Thermometer, IMG_DIR$ + "/Thermometer.gif", DEFAULT_OFFSET
Const THERMO_RED~& = _RGB32(170, 0, 0)

' Background
Dim Shared Background As Sprite
Sprite_Load Background, IMG_DIR$ + "/Background.gif", DEFAULT_OFFSET

' Other constants
Const PLAYER_HEIGHT% = 33
Const PLAYER_WIDTH% = 19
Const BLOCK_SIZE% = 11

' :mode=visualbasic: