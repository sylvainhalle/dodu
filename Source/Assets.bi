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
' DependsOn: 'Sound.bi'

Const IMG_MODE$ = "cga"
Dim Shared COLOR_TRANSPARENT AS Long
If IMG_MODE$ = "cga" Then
	let COLOR_TRANSPARENT = _RGB32(85, 170, 255)
Else
	let COLOR_TRANSPARENT = COLOR_PINK&
End If

Const IMG_DIR$ = "/home/sylvain/Workspaces/dodu/Source/images/" + IMG_MODE$
Const FNT_DIR$ = "/home/sylvain/Workspaces/dodu/Source/fonts"
Const SND_DIR$ = "/home/sylvain/Workspaces/dodu/Source/music"

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
Sprite_Load sprl, IMG_DIR$ + "/Dodu_right_0.gif", DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_Load DoduSprites(DOD_STATIC%), sprl, 0
Sprite_Load sprl, IMG_DIR$ + "/Dodu_right_block_0.gif", DEFAULT_OFFSET, block_offset, COLOR_TRANSPARENT
SpriteSequence_Init DoduSprites(DOD_BLOCK%), 1, 1, TRUE
SpriteSequence_Load DoduSprites(DOD_BLOCK%), sprl, 0

SpriteSequence_BulkLoad DoduSprites(DOD_WALKING%), IMG_DIR$ + "/Dodu_right_", 4, 2, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_BulkLoad DoduSprites(DOD_BLOCK_WALKING%), IMG_DIR$ + "/Dodu_right_block_", 4, 2, TRUE, DEFAULT_OFFSET, block_offset, COLOR_TRANSPARENT

Dim Shared DoduSmall As Sprite
Sprite_Load DoduSmall, IMG_DIR$ + "/DoduSmall.gif", DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Trajectories
Const TRJ_CLIMBING% = 0
Const TRJ_FALLING% = 1
Const TRJ_PANBACK% = 100
Dim Shared Trajectories(3) As Trajectory
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
Sprite_Load BlockBlue, IMG_DIR$ + "/BlockBlue.gif", DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
Dim Shared BlockWhite As Sprite
Sprite_Load BlockWhite, IMG_DIR$ + "/BlockWhite.gif", DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
Dim Shared MiniBlockBlue As Sprite
Sprite_Load MiniBlockBlue, IMG_DIR$ + "/MiniBlockBlue.gif", DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
Dim Shared MiniBlockWhite As Sprite
Sprite_Load MiniBlockWhite, IMG_DIR$ + "/MiniBlockWhite.gif", DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Goal post
Dim Shared Pole As Sprite
Dim PoleOffset As Point, PoleOffsetFlip As Point
Point_Set PoleOffset, 1, -9
Point_Set PoleOffsetFlip, -1, -9
Sprite_Load Pole, IMG_DIR$ + "/Pole.gif", PoleOffset, PoleOffsetFlip, COLOR_TRANSPARENT
Dim Shared MiniPole As Sprite
Dim MiniPoleOffset As Point, MiniPoleOffsetFlip As Point
Point_Set MiniPoleOffset, 1, -2
Point_Set MiniPoleOffsetFlip, 1, 2
Sprite_Load MiniPole, IMG_DIR$ + "/MiniPole.gif", MiniPoleOffset, MiniPoleOffsetFlip, COLOR_TRANSPARENT

' Thermometer
Dim Shared Thermometer As Sprite
Sprite_Load Thermometer, IMG_DIR$ + "/Thermometer.gif", DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

Dim Shared THERMO_RED&, THERMO_BLUE&, HIGHLIGHT_COLOR&
If IMG_MODE = "cga" Then
	Let THERMO_RED& = COLOR_PINK&
	Let THERMO_BLUE& = COLOR_BLACK&
	Let HIGHLIGHT_COLOR& = COLOR_BLACK&
Else
	Let THERMO_RED& = _RGB32(170, 0, 0)
	Let THERMO_BLUE& = _RGB32(85, 0, 170)
	Let HIGHLIGHT_COLOR& = COLOR_YELLOW&
End If

' Background
Dim Shared Background As Sprite
Sprite_Load Background, IMG_DIR$ + "/Background.gif", DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_BLACK

' Other constants
Const PLAYER_HEIGHT% = 33
Const PLAYER_WIDTH% = 19
Const BLOCK_SIZE% = 11
Const MINI_BLOCK_SIZE% = 6

' Music
_MIDISoundBank ("/usr/share/sounds/sf2/default-GM.sf2")

Dim Shared Audio As SoundPlayer
SoundPlayer_Init Audio

SoundPlayer_AddSong Audio, 0, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/dod_fixed.mid"), 0.4
SoundPlayer_AddSong Audio, 1, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/yaya.mid"), 0.4

Const SND_STEP% = 0
Const SND_THERMO% = 1
Const SND_GRAB% = 2
Const SND_DROP% = 3

SoundPlayer_AddEffect Audio, SND_STEP%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/step.mid"), 0.4
SoundPlayer_AddEffect Audio, SND_THERMO%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/thermo.mid"), 1
SoundPlayer_AddEffect Audio, SND_GRAB%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/grab.mid"), 1
SoundPlayer_AddEffect Audio, SND_DROP%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/drop.mid"), 1

'**
'* Sets the song volume to a low level.
'**
Declare Sub Audio_SongLow

'**
'* Sets the song volume to a normal level.
'**
Declare Sub Audio_SongNormal

'**
'* Pauses the currently playing song.
'**
Declare Sub Audio_SongPause

'**
'* Resumes the playback of the current song.
'**
Declare Sub Audio_SongResume

' :mode=visualbasic: