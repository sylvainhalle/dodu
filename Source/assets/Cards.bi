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

Dim Shared SprCard As SpriteSequence
Dim Shared SprCardsSuits(4) As SpriteSequence
Dim Shared SprCardsDigits(13) As SpriteSequence

' Playing cards

SpriteSequence_InitFile SprCard, ImgDir$ + "/cards/Card.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsSuits(0), ImgDir$ + "/cards/Hearts.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsSuits(1), ImgDir$ + "/cards/Spades.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsSuits(2), ImgDir$ + "/cards/Diamonds.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsSuits(3), ImgDir$ + "/cards/Clubs.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(0), ImgDir$ + "/cards/Digit_A.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(1), ImgDir$ + "/cards/Digit_2.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(2), ImgDir$ + "/cards/Digit_3.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(3), ImgDir$ + "/cards/Digit_4.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(4), ImgDir$ + "/cards/Digit_5.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(5), ImgDir$ + "/cards/Digit_6.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(6), ImgDir$ + "/cards/Digit_7.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(7), ImgDir$ + "/cards/Digit_8.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(8), ImgDir$ + "/cards/Digit_9.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(9), ImgDir$ + "/cards/Digit_10.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(10), ImgDir$ + "/cards/Digit_J.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(11), ImgDir$ + "/cards/Digit_Q.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprCardsDigits(12), ImgDir$ + "/cards/Digit_K.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT


' :mode=visualbasic: