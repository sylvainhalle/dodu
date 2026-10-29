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

' Music
_MIDISoundBank ("/usr/share/sounds/sf2/default-GM.sf2")

Dim Shared Audio As SoundPlayer
SoundPlayer_Init Audio

Const SNG_SONG1 = 0
Const SNG_SONG2 = 1
Const SNG_SONG3 = 2
Const SNG_CARDS = 3
Const SNG_CUTSCENE1 = 4
Const SNG_BIERE = 5
Const SNG_PASTORAL = 6
Const SNG_BRUBECK = 7

SoundPlayer_AddSong Audio, SNG_SONG1, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/dod_fixed.mid", "STREAM"), 0.4
SoundPlayer_AddSong Audio, SNG_SONG2, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/yaya.mid", "STREAM"), 0.4
SoundPlayer_AddSong Audio, SNG_SONG3, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/pizza.mid", "STREAM"), 0.4
SoundPlayer_AddSong Audio, SNG_CARDS, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/cards.mid", "STREAM"), 0.4
SoundPlayer_AddSong Audio, SNG_CUTSCENE1, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/cutscene1.mid", "STREAM"), 0.5
Let Audio.Loops(SNG_CUTSCENE1) = FALSE
SoundPlayer_AddSong Audio, SNG_BIERE, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/biere_q.mid", "STREAM"), 0.4
SoundPlayer_AddSong Audio, SNG_PASTORAL, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/lullaby.mid", "STREAM"), 0.4
'SoundPlayer_AddSong Audio, SNG_PASTORAL, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/lullaby.mid"), 0.4

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
Const SND_STEP_SNOW% = 13

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
SoundPlayer_AddEffect Audio, SND_STEP_SNOW%, _SndOpen("/home/sylvain/Workspaces/dodu/Source/music/step_snow.mid"), 0.4

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