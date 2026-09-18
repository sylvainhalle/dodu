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
Const FNT_DIR$ = "/home/sylvain/Workspaces/dodu/Source/fonts"

Dim Shared FNT_TINYC As _Unsigned Long
Let FNT_TINYC = _LoadFont(FNT_DIR$ + "/TinyAndChunkyRegular.ttf", 5, "MONOSPACE")

Dim DEFAULT_OFFSET As Point
Let DEFAULT_OFFSET = P_ORIGIN

Dim Shared DoduSprites(4) As SpriteSequence

' Character
Const DOD_STATIC% = 0
Const DOD_WALKING% = 1
Const DOD_BLOCK% = 2
Const DOD_BLOCK_WALKING% = 3

Dim block_offset As Point
Point_Set block_offset, -5, 0
SpriteSequence_Init DoduSprites(DOD_STATIC%), 1, 1, TRUE
Dim sprl As Sprite
Sprite_Load sprl, IMG_DIR$ + "/Dodu_right_0.gif", DEFAULT_OFFSET, DEFAULT_OFFSET
SpriteSequence_Load DoduSprites(DOD_STATIC%), sprl, 0
Sprite_Load sprl, IMG_DIR$ + "/Dodu_right_block_0.gif", DEFAULT_OFFSET, block_offset
SpriteSequence_Init DoduSprites(DOD_BLOCK%), 1, 1, TRUE
SpriteSequence_Load DoduSprites(DOD_BLOCK%), sprl, 0

SpriteSequence_BulkLoad DoduSprites(DOD_WALKING%), IMG_DIR$ + "/Dodu_right_", 4, 2, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET
SpriteSequence_BulkLoad DoduSprites(DOD_BLOCK_WALKING%), IMG_DIR$ + "/Dodu_right_block_", 4, 2, TRUE, DEFAULT_OFFSET, block_offset

' Trajectories
Const TRJ_CLIMBING% = 0
Const TRJ_FALLING% = 1
Dim Shared Trajectories(2) As Trajectory
Dim trj As Trajectory
Trajectory_Init Trajectories(TRJ_CLIMBING%), 6, 1, FALSE, FALSE
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 0, -3, 0
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 1, -2, 1
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 0, -2, 2
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 2, -2, 3
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 2, -2, 4
Trajectory_AddCoords Trajectories(TRJ_CLIMBING%), 1,  0, 5

Trajectory_Init Trajectories(TRJ_FALLING%), 6, 1, FALSE, FALSE
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 1,  0, 0
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 1,  0, 1
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 0, 1, 2
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 0, 2, 3
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 0, 3, 4
Trajectory_AddCoords Trajectories(TRJ_FALLING%), 0, 5, 5


' Blocks
Dim Shared BlockBlue As Sprite
Sprite_Load BlockBlue, IMG_DIR$ + "/BlockBlue.gif", DEFAULT_OFFSET, DEFAULT_OFFSET
Dim Shared BlockWhite As Sprite
Sprite_Load BlockWhite, IMG_DIR$ + "/Block_white.gif", DEFAULT_OFFSET, DEFAULT_OFFSET

' Goal post
Dim Shared Pole As Sprite
Dim PoleOffset As Point, PoleOffsetFlip As Point
Point_Set PoleOffset, 1, -9
Point_Set PoleOffsetFlip, -1, -9
Sprite_Load Pole, IMG_DIR$ + "/Pole.gif", PoleOffset, PoleOffsetFlip

' Thermometer
Dim Shared Thermometer As Sprite
Sprite_Load Thermometer, IMG_DIR$ + "/Thermometer.gif", DEFAULT_OFFSET, DEFAULT_OFFSET
Const THERMO_RED~& = _RGB32(170, 0, 0)

' Background
Dim Shared Background As Sprite
Sprite_Load Background, IMG_DIR$ + "/Background.gif", DEFAULT_OFFSET, DEFAULT_OFFSET

' Other constants
Const PLAYER_HEIGHT% = 33
Const PLAYER_WIDTH% = 19
Const BLOCK_SIZE% = 11

' Music
_MIDISoundBank ("/usr/share/sounds/sf2/default-GM.sf2")

Dim Shared SND_TUNE As _Unsigned Long
Dim Shared SND_STEP As _Unsigned Long
Dim Shared SND_THERMO As _Unsigned Long
Dim Shared SND_GRAB As _Unsigned Long
Dim Shared SND_DROP As _Unsigned Long
Let SND_TUNE = _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/dod.mid")
_SndVol SND_TUNE, 0.4
Let SND_STEP = _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/step.mid")
_SndVol SND_STEP, 0.5
Let SND_THERMO = _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/thermo.mid")
Let SND_GRAB = _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/grab.mid")
Let SND_DROP = _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/drop.mid")

' :mode=visualbasic: