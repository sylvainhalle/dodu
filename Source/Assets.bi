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

' DependsOn: 'Sprites.bi'
' DependsOn: 'Sound.bi'

Const COLOR_TRANSPARENT = _RGB32(52, 52, 52)

Dim Shared COLOR_HIGHLIGHT As Long, COLOR_HIGHLIGHT2 As Long
If IMG_MODE$ = IMG_MODE_EGA Then
	Let COLOR_HIGHLIGHT = COLOR_RED
	Let COLOR_HIGHLIGHT2 = COLOR_YELLOW
ElseIf IMG_MODE$ = IMG_MODE_CGA Then
	Let COLOR_HIGHLIGHT = COLOR_PINK
	Let COLOR_HIGHLIGHT2 = COLOR_CYAN
ElseIf IMG_MODE$ = IMG_MODE_HER Then
	Let COLOR_HIGHLIGHT = COLOR_WHITE
	Let COLOR_HIGHLIGHT2 = COLOR_WHITE
End If

Dim Shared IMG_DIR As String, FNT_DIR As String, SND_DIR As String
Let IMG_DIR$ = "/home/sylvain/Workspaces/dodu/Source/images/" + IMG_MODE$
Let FNT_DIR$ = "/home/sylvain/Workspaces/dodu/Source/fonts"
Let SND_DIR$ = "/home/sylvain/Workspaces/dodu/Source/music"

Dim Shared FNT_TINYC As _Unsigned Long, FNT_GRAPE As _Unsigned Long
Let FNT_TINYC = _LoadFont(FNT_DIR$ + "/TinyAndChunkyRegular.ttf", 5, "MONOSPACE DONTBLEND")
Let FNT_GRAPE = _LoadFont(FNT_DIR$ + "/GrapeSoda.ttf", 10, "MONOSPACE DONTBLEND")

Dim DEFAULT_OFFSET As Point
Let DEFAULT_OFFSET = P_ORIGIN


Dim Shared SPR_DOD_TUQUE(2) As SpriteSequence, TUQUE_OFFSET As Point
Point_Set TUQUE_OFFSET, 0, -11
SpriteSequence_InitFile SPR_DOD_TUQUE(0), IMG_DIR$ + "/refactored/NoTuque.png", 4, 2, TRUE, TUQUE_OFFSET, TUQUE_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_TUQUE(1), IMG_DIR$ + "/refactored/Tuque.png", 4, 2, TRUE, TUQUE_OFFSET, TUQUE_OFFSET, COLOR_TRANSPARENT


Dim Shared SPR_DOD_HEAD(2) As SpriteSequence, HEAD_OFFSET As Point
Point_Set HEAD_OFFSET, 0, 0
SpriteSequence_InitFile SPR_DOD_HEAD(0), IMG_DIR$ + "/refactored/Head.png", 4, 2, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_HEAD(1), IMG_DIR$ + "/refactored/Head_tired.png", 4, 2, TRUE, HEAD_OFFSET, HEAD_OFFSET, COLOR_TRANSPARENT

Dim Shared SPR_DOD_BODY(2, 2) As SpriteSequence, BODY_OFFSET_NOBLOCK As Point, BODY_OFFSET_BLOCK As Point
Point_Set BODY_OFFSET_NOBLOCK, 0, 13
Point_Set BODY_OFFSET_BLOCK, 0, 12
SpriteSequence_InitFile SPR_DOD_BODY(0, 0), IMG_DIR$ + "/refactored/Body_noblock_nomittens.png", 4, 2, TRUE, BODY_OFFSET_NOBLOCK, BODY_OFFSET_NOBLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(1, 0), IMG_DIR$ + "/refactored/Body_block_nomittens.png", 4,  2, TRUE, BODY_OFFSET_BLOCK, BODY_OFFSET_BLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(0, 1), IMG_DIR$ + "/refactored/Body_noblock_mittens.png", 4,  2, TRUE, BODY_OFFSET_NOBLOCK, BODY_OFFSET_NOBLOCK, COLOR_TRANSPARENT
SpriteSequence_InitFile SPR_DOD_BODY(1, 1), IMG_DIR$ + "/refactored/Body_block_mittens.png", 4,  2, TRUE, BODY_OFFSET_BLOCK, BODY_OFFSET_BLOCK, COLOR_TRANSPARENT

Dim Shared DoduSmall As SpriteSequence
SpriteSequence_InitFile DoduSmall, IMG_DIR$ + "/DoduSmall.gif", 1,  1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

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

' Splash screen
Dim Shared SplashScreen As SpriteSequence
SpriteSequence_InitFile SplashScreen, IMG_DIR$ + "/Splash.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Blocks
Dim Shared BlockBlue As SpriteSequence
SpriteSequence_InitFile BlockBlue, IMG_DIR$ + "/BlockBlue.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
Dim Shared BlockWhite As SpriteSequence
SpriteSequence_InitFile BlockWhite, IMG_DIR$ + "/BlockWhite.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
Dim Shared MiniBlockBlue As SpriteSequence
SpriteSequence_InitFile MiniBlockBlue, IMG_DIR$ + "/MiniBlockBlue.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
Dim Shared MiniBlockWhite As SpriteSequence
SpriteSequence_InitFile MiniBlockWhite, IMG_DIR$ + "/MiniBlockWhite.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
Dim Shared SnowC As SpriteSequence
Dim Coffset As Point
Point_Set Coffset, 0, -12
SpriteSequence_InitFile SnowC, IMG_DIR$ + "/Snow_C.gif",1, 1, TRUE, Coffset, Coffset, COLOR_TRANSPARENT
Dim Shared SnowL As SpriteSequence
SpriteSequence_InitFile SnowL, IMG_DIR$ + "/Snow_L.gif",1, 1, TRUE, Coffset, Coffset, COLOR_TRANSPARENT
Dim Shared SnowR As SpriteSequence
SpriteSequence_InitFile SnowR, IMG_DIR$ + "/Snow_R.gif",1, 1, TRUE, Coffset, Coffset, COLOR_TRANSPARENT
Dim Shared SnowM As SpriteSequence
SpriteSequence_InitFile SnowM, IMG_DIR$ + "/Snow_M.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Goal post
Dim Shared Pole As SpriteSequence
Dim PoleOffset As Point, PoleOffsetFlip As Point
Point_Set PoleOffset, 1, -9
Point_Set PoleOffsetFlip, -1, -9
SpriteSequence_InitFile Pole, IMG_DIR$ + "/Pole.gif",1, 1, TRUE, PoleOffset, PoleOffsetFlip, COLOR_TRANSPARENT
Dim Shared MiniPole As SpriteSequence
Dim MiniPoleOffset As Point, MiniPoleOffsetFlip As Point
Point_Set MiniPoleOffset, 1, -2
Point_Set MiniPoleOffsetFlip, 1, 2
SpriteSequence_InitFile MiniPole, IMG_DIR$ + "/MiniPole.gif",1, 1, TRUE, MiniPoleOffset, MiniPoleOffsetFlip, COLOR_TRANSPARENT

' Cookie
Dim Shared Cookie As SpriteSequence
Dim CookieOffset As Point
Point_Set CookieOffset, 2, 2
SpriteSequence_InitFile Cookie, IMG_DIR$ + "/refactored/Cookie.png",8, 3, TRUE, CookieOffset, CookieOffset, COLOR_TRANSPARENT

' Mittens
Dim Shared SprMittens As SpriteSequence
Dim SprMittensOffset As Point
Point_Set SprMittensOffset, -2, 2
SpriteSequence_InitFile SprMittens, IMG_DIR$ + "/Mittens.gif",1, 1, TRUE, SprMittensOffset, SprMittensOffset, COLOR_TRANSPARENT

' Tuque
Dim Shared SprTuque As SpriteSequence
Dim SprTuqueOffset As Point
Point_Set SprTuqueOffset, 1, -3
SpriteSequence_InitFile SprTuque, IMG_DIR$ + "/Tuque.gif",1, 1, TRUE, SprTuqueOffset, SprTuqueOffset, COLOR_TRANSPARENT

' Thermometer
Dim Shared Thermometer As SpriteSequence
SpriteSequence_InitFile Thermometer, IMG_DIR$ + "/Thermometer.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

Dim Shared THERMO_RED&, THERMO_BLUE&, HIGHLIGHT_COLOR&
If IMG_MODE = IMG_MODE_CGA$ Then
	Let THERMO_RED& = COLOR_PINK&
	Let THERMO_BLUE& = COLOR_BLACK&
	Let HIGHLIGHT_COLOR& = COLOR_BLACK&
ElseIf IMG_MODE = IMG_MODE_EGA$ Then
	Let THERMO_RED& = _RGB32(170, 0, 0)
	Let THERMO_BLUE& = _RGB32(85, 0, 170)
	Let HIGHLIGHT_COLOR& = COLOR_YELLOW&
Else
	Let THERMO_RED& = COLOR_BLACK%
	Let THERMO_BLUE& = COLOR_BLACK%
	Let HIGHLIGHT_COLOR& = COLOR_BLACK&
End If

' Playing cards
Dim Shared Card As SpriteSequence
SpriteSequence_InitFile Card, IMG_DIR$ + "/Sprite_Card.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
Dim Shared Suits(4) As SpriteSequence
SpriteSequence_InitFile Suits(0), IMG_DIR$ + "/Sprite_Hearts.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Suits(1), IMG_DIR$ + "/Sprite_Spades.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Suits(2), IMG_DIR$ + "/Sprite_Diamonds.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Suits(3), IMG_DIR$ + "/Sprite_Clubs.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
Dim Shared Numbers(13) As SpriteSequence
SpriteSequence_InitFile Numbers(0), IMG_DIR$ + "/Digit_A.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(1), IMG_DIR$ + "/Digit_2.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(2), IMG_DIR$ + "/Digit_3.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(3), IMG_DIR$ + "/Digit_4.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(4), IMG_DIR$ + "/Digit_5.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(5), IMG_DIR$ + "/Digit_6.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(6), IMG_DIR$ + "/Digit_7.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(7), IMG_DIR$ + "/Digit_8.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(8), IMG_DIR$ + "/Digit_9.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(9), IMG_DIR$ + "/Digit_10.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(10), IMG_DIR$ + "/Digit_J.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(11), IMG_DIR$ + "/Digit_Q.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Numbers(12), IMG_DIR$ + "/Digit_K.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

Dim Shared LevelDigits(10) As SpriteSequence
SpriteSequence_InitFile LevelDigits(0), IMG_DIR$ + "/Dg_0.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile LevelDigits(1), IMG_DIR$ + "/Dg_1.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile LevelDigits(2), IMG_DIR$ + "/Dg_2.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile LevelDigits(3), IMG_DIR$ + "/Dg_3.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile LevelDigits(4), IMG_DIR$ + "/Dg_4.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile LevelDigits(5), IMG_DIR$ + "/Dg_5.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile LevelDigits(6), IMG_DIR$ + "/Dg_6.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile LevelDigits(7), IMG_DIR$ + "/Dg_7.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile LevelDigits(8), IMG_DIR$ + "/Dg_8.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile LevelDigits(9), IMG_DIR$ + "/Dg_9.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' ---------------------
' Cut scenes
' ---------------------
Dim Shared CutScenes(10) As SpriteSequence
SpriteSequence_InitFile CutScenes(0), IMG_DIR$ + "/Cutscene_0.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile CutScenes(1), IMG_DIR$ + "/Cutscene_1.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile CutScenes(2), IMG_DIR$ + "/Cutscene_2.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT


' ---------------------
' Backgrounds
' ---------------------
Dim Shared Backgrounds(10) As SpriteSequence
SpriteSequence_InitFile Backgrounds(0), IMG_DIR$ + "/Background.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(1), IMG_DIR$ + "/Background2.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(2), IMG_DIR$ + "/Background_Cards.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(3), IMG_DIR$ + "/Background3.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(4), IMG_DIR$ + "/Background4.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT
SpriteSequence_InitFile Backgrounds(5), IMG_DIR$ + "/Background_5.gif",1, 1, TRUE, DEFAULT_OFFSET, DEFAULT_OFFSET, COLOR_TRANSPARENT

' Other constants
Const PLAYER_HEIGHT% = 33
Const PLAYER_WIDTH% = 19
Const BLOCK_SIZE% = 11
Const MINI_BLOCK_SIZE% = 6

' Music
_MIDISoundBank ("/usr/share/sounds/sf2/default-GM.sf2")

Dim Shared Audio As SoundPlayer
SoundPlayer_Init Audio

Const SNG_SONG1 = 0
Const SNG_SONG2 = 1
Const SNG_CARDS = 2
Const SNG_CUTSCENE1 = 3

SoundPlayer_AddSong Audio, SNG_SONG1, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/dod_fixed.mid"), 0.4
SoundPlayer_AddSong Audio, SNG_SONG2, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/yaya.mid"), 0.4
SoundPlayer_AddSong Audio, SNG_CARDS, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/cards.mid"), 0.4
SoundPlayer_AddSong Audio, SNG_CUTSCENE1, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/cutscene1.mid"), 0.6


Const SND_STEP% = 0
Const SND_THERMO% = 1
Const SND_GRAB% = 2
Const SND_DROP% = 3
Const SND_LEVELUP% = 4
Const SND_UNDO% = 5
Const SND_GAMEOVER% = 6
Const SND_TICK% = 7
Const SND_TACK% = 8
Const SND_WRONG1% = 9
Const SND_COOKIE% = 10
Const SND_POWERUP% = 11
Const SND_POWERDOWN% = 12

SoundPlayer_AddEffect Audio, SND_STEP%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/step.mid"), 0.4
SoundPlayer_AddEffect Audio, SND_THERMO%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/thermo.mid"), 1
SoundPlayer_AddEffect Audio, SND_GRAB%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/grab.mid"), 1
SoundPlayer_AddEffect Audio, SND_DROP%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/drop.mid"), 1
SoundPlayer_AddEffect Audio, SND_LEVELUP%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/levelup.mid"), 0.7
SoundPlayer_AddEffect Audio, SND_UNDO%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/undo.mid"), 0.7
SoundPlayer_AddEffect Audio, SND_GAMEOVER%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/gameover.mid"), 0.5
SoundPlayer_AddEffect Audio, SND_TICK%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/tick.mid"), 0.7
SoundPlayer_AddEffect Audio, SND_TACK%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/tack.mid"), 0.7
SoundPlayer_AddEffect Audio, SND_WRONG1%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/wrong.mid"), 1
SoundPlayer_AddEffect Audio, SND_COOKIE%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/cookie.mid"), 1
SoundPlayer_AddEffect Audio, SND_POWERUP%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/powerup.mid"), 1
SoundPlayer_AddEffect Audio, SND_POWERDOWN%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/powerdown.mid"), 1

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