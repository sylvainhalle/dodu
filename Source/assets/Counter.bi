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

Dim Shared SprLvlDigits(10) As SpriteSequence
SpriteSequence_InitFile SprLvlDigits(0), ImgDir$ + "/counter/Dg_0.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLvlDigits(1), ImgDir$ + "/counter/Dg_1.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLvlDigits(2), ImgDir$ + "/counter/Dg_2.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLvlDigits(3), ImgDir$ + "/counter/Dg_3.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLvlDigits(4), ImgDir$ + "/counter/Dg_4.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLvlDigits(5), ImgDir$ + "/counter/Dg_5.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLvlDigits(6), ImgDir$ + "/counter/Dg_6.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLvlDigits(7), ImgDir$ + "/counter/Dg_7.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLvlDigits(8), ImgDir$ + "/counter/Dg_8.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprLvlDigits(9), ImgDir$ + "/counter/Dg_9.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

'**
'* Draws the current level number (one or two digits) at PtLevelNb
'* on the given layer of the viewport.
'**
Declare Sub DrawLevelNumber (v As Viewport, layer As Integer)

'**
'* Draws a two-digit number n (00-99) at point p on the given layer,
'* using the level-counter digit sprites.
'**
Declare Sub DrawNumber (v As Viewport, p As Point, n As Integer, layer As Integer)

' :mode=visualbasic: