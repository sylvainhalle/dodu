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

' Dimensions
Const PLAYER_HEIGHT% = 33
Const PLAYER_WIDTH% = 19
Const BLOCK_SIZE% = 11
Const MINI_BLOCK_SIZE% = 6

Const SPR_NOT_WALKING = 0
Const SPR_WALKING = 1
Const SPR_NO_TUQUE = 0
Const SPR_TUQUE = 1
Const SPR_NOT_TIRED = 0
Const SPR_TIRED = 1
Const SPR_FREEZING = 2
Const SPR_PANTING = 3
Const SPR_LOOKING_THERMO = 4
Const SPR_LOOKING_THERMO_UP = 5
Const SPR_NO_BLOCK = 0
Const SPR_BLOCK = 1
Const SPR_NO_MITTENS = 0
Const SPR_MITTENS = 1
Const SPR_B_NOT_PANTING = 0
Const SPR_B_PANTING = 1

' 1st coordinate: 0 = not walking, 1 = walking
' 2nd coordinate: 0 = no tuque, 1 = with tuque
Dim Shared SPR_DOD_TUQUE(2, 2) As SpriteSequence, TUQUE_OFFSET As Point
Point_Set TUQUE_OFFSET, 0, -11
SpriteSequence_InitFile SPR_DOD_TUQUE(0, 0), IMG_DIR$ + "/player/NoTuque.png", 4, 2, FALSE, TRUE, TUQUE_OFFSET, TUQUE_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_TUQUE(0, 1), IMG_DIR$ + "/player/Tuque.png", 4, 2, FALSE, TRUE, TUQUE_OFFSET, TUQUE_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_TUQUE(1, 0), IMG_DIR$ + "/player/NoTuque.png", 4, 2, TRUE, TRUE, TUQUE_OFFSET, TUQUE_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_TUQUE(1, 1), IMG_DIR$ + "/player/Tuque.png", 4, 2, TRUE, TRUE, TUQUE_OFFSET, TUQUE_OFFSET, COLOR_TRANSPARENT

' 1st coordinate: 0 = not walking, 1 = walking
' 2nd coordinate: 0 = normal, 1 = tired, 2 = freezing, 3 = panting
Dim Shared SPR_DOD_HEAD(2, 6) As SpriteSequence, HEAD_OFFSET As Point
Point_Set HEAD_OFFSET, 0, 0
SpriteSequence_InitFile SPR_DOD_HEAD(0, 0), IMG_DIR$ + "/player/Head_idle.png", 15, 3, TRUE, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_HEAD(0, 1), IMG_DIR$ + "/player/Head_tired.png", 4, 2, FALSE, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_HEAD(0, 2), IMG_DIR$ + "/player/Head_freezing.png", 4, 2, TRUE, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_HEAD(0, 3), IMG_DIR$ + "/player/Head_panting.png", 2, 10, TRUE, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_HEAD(0, 4), IMG_DIR$ + "/player/Head_looking_mid.png", 2, 1, FALSE, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_HEAD(0, 5), IMG_DIR$ + "/player/Head_looking_up.png", 2, 1, FALSE, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_HEAD(1, 0), IMG_DIR$ + "/player/Head.png", 4, 2, TRUE, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_HEAD(1, 1), IMG_DIR$ + "/player/Head_tired.png", 4, 2, TRUE, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_HEAD(1, 2), IMG_DIR$ + "/player/Head_freezing.png", 4, 2, TRUE, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_HEAD(1, 3), IMG_DIR$ + "/player/Head_panting.png", 2, 10, TRUE, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT

' 1st coordinate: 0 = not walking, 1 = walking
' 2nd coordinate: 0 = no block, 1 = has block
' 3rd coordinate: 0 = no mittens, 1 = with mittens
' 4th coordinate: 0 = not panting, 1 = panting
Dim Shared SPR_DOD_BODY(2, 2, 2, 2) As SpriteSequence, BODY_OFFSET_NOBLOCK As Point, BODY_OFFSET_BLOCK As Point
Point_Set BODY_OFFSET_NOBLOCK, 0, 13
Point_Set BODY_OFFSET_BLOCK, 0, 12
SpriteSequence_InitFile SPR_DOD_BODY(0, 0, 0, 0), IMG_DIR$ + "/player/Body_noblock_nomittens.png", 4, 2, FALSE, TRUE, BODY_OFFSET_NOBLOCK, BODY_OFFSET_NOBLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(0, 1, 0, 0), IMG_DIR$ + "/player/Body_block_nomittens.png", 4,  2, FALSE, TRUE, BODY_OFFSET_BLOCK, BODY_OFFSET_BLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(0, 0, 1, 0), IMG_DIR$ + "/player/Body_noblock_mittens.png", 4,  2, FALSE, TRUE, BODY_OFFSET_NOBLOCK, BODY_OFFSET_NOBLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(0, 1, 1, 0), IMG_DIR$ + "/player/Body_block_mittens.png", 4,  2, FALSE, TRUE, BODY_OFFSET_BLOCK, BODY_OFFSET_BLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(1, 0, 0, 0), IMG_DIR$ + "/player/Body_noblock_nomittens.png", 4, 2, TRUE, TRUE, BODY_OFFSET_NOBLOCK, BODY_OFFSET_NOBLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(1, 1, 0, 0), IMG_DIR$ + "/player/Body_block_nomittens.png", 4,  2, TRUE, TRUE, BODY_OFFSET_BLOCK, BODY_OFFSET_BLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(1, 0, 1, 0), IMG_DIR$ + "/player/Body_noblock_mittens.png", 4,  2, TRUE, TRUE, BODY_OFFSET_NOBLOCK, BODY_OFFSET_NOBLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(1, 1, 1, 0), IMG_DIR$ + "/player/Body_block_mittens.png", 4,  2, TRUE, TRUE, BODY_OFFSET_BLOCK, BODY_OFFSET_BLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(0, 0, 0, 1), IMG_DIR$ + "/player/Body_noblock_nomittens_panting.png", 2, 10, TRUE, TRUE, BODY_OFFSET_NOBLOCK, BODY_OFFSET_NOBLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(0, 1, 0, 1), IMG_DIR$ + "/player/Body_block_nomittens_panting.png", 2,  10, TRUE, TRUE, BODY_OFFSET_BLOCK, BODY_OFFSET_BLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(0, 0, 1, 1), IMG_DIR$ + "/player/Body_noblock_mittens_panting.png", 2,  10, TRUE, TRUE, BODY_OFFSET_NOBLOCK, BODY_OFFSET_NOBLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(0, 1, 1, 1), IMG_DIR$ + "/player/Body_block_mittens_panting.png", 2,  10, TRUE, TRUE, BODY_OFFSET_BLOCK, BODY_OFFSET_BLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(1, 0, 0, 1), IMG_DIR$ + "/player/Body_noblock_nomittens_panting.png", 2, 10, TRUE, TRUE, BODY_OFFSET_NOBLOCK, BODY_OFFSET_NOBLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(1, 1, 0, 1), IMG_DIR$ + "/player/Body_block_nomittens_panting.png", 2,  10, TRUE, TRUE, BODY_OFFSET_BLOCK, BODY_OFFSET_BLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(1, 0, 1, 1), IMG_DIR$ + "/player/Body_noblock_mittens_panting.png", 2,  10, TRUE, TRUE, BODY_OFFSET_NOBLOCK, BODY_OFFSET_NOBLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(1, 1, 1, 1), IMG_DIR$ + "/player/Body_block_mittens_panting.png", 2,  10, TRUE, TRUE, BODY_OFFSET_BLOCK, BODY_OFFSET_BLOCK, COLOR_TRANSPARENT

' Trajectories
Const TRJ_CLIMBING% = 0
Const TRJ_CLIMBING_SNOW% = 1
Const TRJ_UNCLIMBING% = 2
Const TRJ_PANTING% = 3
Const TRJ_LOOKING_THERMO% = 4
Const TRJ_FALLING% = 5
Const TRJ_PANBACK% = 100

Dim Shared Trajectories(6) As Trajectory
Dim trj As Trajectory
Trajectory_Init Trajectories(TRJ_CLIMBING%), 6, 1, FALSE, FALSE
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 0, -3, 0
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 1, -2, 1
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 0, -2, 2
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 2, -2, 3
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 2, -2, 4
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 1,  0, 5

Trajectory_Copy Trajectories(TRJ_CLIMBING_SNOW%), Trajectories(TRJ_CLIMBING%)
Let Trajectories(TRJ_CLIMBING_SNOW%).Ticker.Speed = 4

Trajectory_Init Trajectories(TRJ_UNCLIMBING%), 6, 1, FALSE, FALSE
Trajectory_AddCoords Trajectories(TRJ_UNCLIMBING%), 1,  0, 0
Trajectory_AddCoords Trajectories(TRJ_UNCLIMBING%), 1,  0, 1
Trajectory_AddCoords Trajectories(TRJ_UNCLIMBING%), 0, 1, 2
Trajectory_AddCoords Trajectories(TRJ_UNCLIMBING%), 0, 2, 3
Trajectory_AddCoords Trajectories(TRJ_UNCLIMBING%), 0, 3, 4
Trajectory_AddCoords Trajectories(TRJ_UNCLIMBING%), 0, 5, 5

Trajectory_Init Trajectories(TRJ_FALLING%), 6, 1, FALSE, FALSE
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 0,  1, 0
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 0,  1, 1
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 0, 1, 2
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 0, 2, 3
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 0, 2, 4
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 0, 4, 5

Trajectory_Init Trajectories(TRJ_PANTING%), 1, 40, FALSE, FALSE
Trajectory_AddCoords Trajectories(TRJ_PANTING%), 0,  0, 0

Trajectory_Init Trajectories(TRJ_LOOKING_THERMO%), 1, 12, FALSE, FALSE
Trajectory_AddCoords Trajectories(TRJ_LOOKING_THERMO%), 0,  0, 0



' :mode=visualbasic: