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

Dim Shared SPR_CARD As SpriteSequence
Dim Shared SPR_CARDS_SUITS(4) As SpriteSequence
Dim Shared SPR_CARDS_DIGITS(13) As SpriteSequence

' Playing cards

SpriteSequence_InitFile SPR_CARD, IMG_DIR$ + "/cards/Card.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_SUITS(0), IMG_DIR$ + "/cards/Hearts.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_SUITS(1), IMG_DIR$ + "/cards/Spades.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_SUITS(2), IMG_DIR$ + "/cards/Diamonds.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_SUITS(3), IMG_DIR$ + "/cards/Clubs.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(0), IMG_DIR$ + "/cards/Digit_A.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(1), IMG_DIR$ + "/cards/Digit_2.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(2), IMG_DIR$ + "/cards/Digit_3.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(3), IMG_DIR$ + "/cards/Digit_4.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(4), IMG_DIR$ + "/cards/Digit_5.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(5), IMG_DIR$ + "/cards/Digit_6.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(6), IMG_DIR$ + "/cards/Digit_7.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(7), IMG_DIR$ + "/cards/Digit_8.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(8), IMG_DIR$ + "/cards/Digit_9.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(9), IMG_DIR$ + "/cards/Digit_10.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(10), IMG_DIR$ + "/cards/Digit_J.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(11), IMG_DIR$ + "/cards/Digit_Q.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_CARDS_DIGITS(12), IMG_DIR$ + "/cards/Digit_K.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT


' :mode=visualbasic: