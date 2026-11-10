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
Dim Shared Backgrounds(11) As SpriteSequence
SpriteSequence_InitFile Backgrounds(0), ImgDir$ + "/backgrounds/Blue_1.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(1), ImgDir$ + "/backgrounds/Blue_2.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(2), ImgDir$ + "/backgrounds/Cards.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(3), ImgDir$ + "/backgrounds/Cyan_1.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(4), ImgDir$ + "/backgrounds/Cyan_2.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(5), ImgDir$ + "/backgrounds/Snow_1.png", 20, 4, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(6), ImgDir$ + "/backgrounds/Pizza_1.png", 1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(7), ImgDir$ + "/backgrounds/Pizza_2.png", 1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(8), ImgDir$ + "/backgrounds/Digits.png", 22, 14, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(9), ImgDir$ + "/backgrounds/Snow_2b.png", 1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(10), ImgDir$ + "/backgrounds/Editor.png", 1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

Dim Shared Veil As SpriteSequence
SpriteSequence_InitFile Veil, ImgDir$ + "/backgrounds/Veil.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' ---------------------
' Foregrounds
' ---------------------
Dim Shared Foregrounds(10) As SpriteSequence


' :mode=visualbasic: