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

Dim Shared SprMinimap(19) As SpriteSequence

' Player
SpriteSequence_InitFile SprMinimap(LVL_PLAYER), ImgDir$ + "/minimap/Player.png", 1,  1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' Blocks
SpriteSequence_InitFile SprMinimap(LVL_BLOCK_B), ImgDir$ + "/minimap/BlockBlue.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprMinimap(LVL_BLOCK_W), ImgDir$ + "/minimap/BlockWhite.gif",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprMinimap(LVL_WATER), ImgDir$ + "/minimap/Water.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprMinimap(LVL_ROPE_M), ImgDir$ + "/minimap/Rope_M.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT
SpriteSequence_InitFile SprMinimap(LVL_ROPE_E), ImgDir$ + "/minimap/Rope_E.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' Pole
Dim MiniPoleOffset As Point, MiniPoleOffsetFlip As Point
Point_Set MiniPoleOffset, 1, -2
Point_Set MiniPoleOffsetFlip, 1, 2
SpriteSequence_InitFile SprMinimap(LVL_POLE), ImgDir$ + "/minimap/Pole.gif",1, 1, TRUE, TRUE, MiniPoleOffset, MiniPoleOffsetFlip, COLOR_TRANSPARENT

' Cookie
SpriteSequence_InitFile SprMinimap(LVL_COOKIE), ImgDir$ + "/minimap/Cookie.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' Coffee
SpriteSequence_InitFile SprMinimap(LVL_COFFEE), ImgDir$ + "/minimap/Coffee.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' Mittens
SpriteSequence_InitFile SprMinimap(LVL_MITTENS), ImgDir$ + "/minimap/Mitten.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' Tuque
SpriteSequence_InitFile SprMinimap(LVL_TUQUE), ImgDir$ + "/minimap/Tuque.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' Snow
SpriteSequence_InitFile SprMinimap(LVL_SNOW_C), ImgDir$ + "/minimap/Snow_C.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' Eraser
SpriteSequence_InitFile SprMinimap(LVL_ERASER), ImgDir$ + "/minimap/Eraser.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' Hand
SpriteSequence_InitFile SprMinimap(LVL_HAND), ImgDir$ + "/minimap/Hand.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' Mark
SpriteSequence_InitFile SprMinimap(LVL_MARK), ImgDir$ + "/minimap/Mark.png",1, 1, TRUE, TRUE, DefaultOffset, DefaultOffset, COLOR_TRANSPARENT

' :mode=visualbasic: