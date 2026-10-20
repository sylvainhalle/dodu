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

' ---------------------
' Backgrounds
' ---------------------
Dim Shared Backgrounds(10) As SpriteSequence
SpriteSequence_InitFile Backgrounds(0), IMG_DIR$ + "/backgrounds/Blue_1.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(1), IMG_DIR$ + "/backgrounds/Blue_2.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(2), IMG_DIR$ + "/backgrounds/Cards.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(3), IMG_DIR$ + "/backgrounds/Cyan_1.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(4), IMG_DIR$ + "/backgrounds/Cyan_2.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(5), IMG_DIR$ + "/backgrounds/Snow_1.png", 20, 4, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(6), IMG_DIR$ + "/backgrounds/Pizza_1.png", 1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(7), IMG_DIR$ + "/backgrounds/Pizza_2.png", 1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(8), IMG_DIR$ + "/backgrounds/Digits.png", 22, 14, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(9), IMG_DIR$ + "/backgrounds/Snow_2b.png", 1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

Dim Shared Veil As SpriteSequence
SpriteSequence_InitFile Veil, IMG_DIR$ + "/backgrounds/Veil.png",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' ---------------------
' Foregrounds
' ---------------------
Dim Shared Foregrounds(10) As SpriteSequence


' :mode=visualbasic: