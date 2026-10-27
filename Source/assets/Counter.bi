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

Dim Shared SPR_LVL_DIGITS(10) As SpriteSequence
SpriteSequence_InitFile SPR_LVL_DIGITS(0), IMG_DIR$ + "/counter/Dg_0.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LVL_DIGITS(1), IMG_DIR$ + "/counter/Dg_1.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LVL_DIGITS(2), IMG_DIR$ + "/counter/Dg_2.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LVL_DIGITS(3), IMG_DIR$ + "/counter/Dg_3.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LVL_DIGITS(4), IMG_DIR$ + "/counter/Dg_4.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LVL_DIGITS(5), IMG_DIR$ + "/counter/Dg_5.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LVL_DIGITS(6), IMG_DIR$ + "/counter/Dg_6.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LVL_DIGITS(7), IMG_DIR$ + "/counter/Dg_7.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LVL_DIGITS(8), IMG_DIR$ + "/counter/Dg_8.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_LVL_DIGITS(9), IMG_DIR$ + "/counter/Dg_9.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

Declare Sub DrawNumber (v As Viewport, p As Point, n As Integer)

' :mode=visualbasic: