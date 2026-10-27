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

Dim Shared SPR_MINIMAP(17) As SpriteSequence

' Player
SpriteSequence_InitFile SPR_MINIMAP(LVL_PLAYER), IMG_DIR$ + "/minimap/Player.gif", 1,  1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Blocks
SpriteSequence_InitFile SPR_MINIMAP(LVL_BLOCK_B), IMG_DIR$ + "/minimap/BlockBlue.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_MINIMAP(LVL_BLOCK_W), IMG_DIR$ + "/minimap/BlockWhite.gif",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_MINIMAP(LVL_WATER), IMG_DIR$ + "/minimap/Water.png",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Pole
Dim MiniPoleOffset As Point, MiniPoleOffsetFlip As Point
Point_Set MiniPoleOffset, 1, -2
Point_Set MiniPoleOffsetFlip, 1, 2
SpriteSequence_InitFile SPR_MINIMAP(LVL_POLE), IMG_DIR$ + "/minimap/Pole.gif",1, 1, TRUE, TRUE, MiniPoleOffset, MiniPoleOffsetFlip, COLOR_TRANSPARENT

' Cookie
SpriteSequence_InitFile SPR_MINIMAP(LVL_COOKIE), IMG_DIR$ + "/minimap/Cookie.png",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Coffee
SpriteSequence_InitFile SPR_MINIMAP(LVL_COFFEE), IMG_DIR$ + "/minimap/Coffee.png",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Mittens
SpriteSequence_InitFile SPR_MINIMAP(LVL_MITTENS), IMG_DIR$ + "/minimap/Mitten.png",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Tuque
SpriteSequence_InitFile SPR_MINIMAP(LVL_TUQUE), IMG_DIR$ + "/minimap/Tuque.png",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Snow
SpriteSequence_InitFile SPR_MINIMAP(LVL_SNOW_C), IMG_DIR$ + "/minimap/Snow_C.png",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Eraser
SpriteSequence_InitFile SPR_MINIMAP(LVL_ERASER), IMG_DIR$ + "/minimap/Eraser.png",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Eraser
SpriteSequence_InitFile SPR_MINIMAP(LVL_HAND), IMG_DIR$ + "/minimap/Hand.png",1, 1, TRUE, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' :mode=visualbasic: