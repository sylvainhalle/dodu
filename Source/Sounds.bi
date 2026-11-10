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

Type SoundPlayer
    PlaySong As Integer
    PlayEffects As Integer
    CurrentSong As Long
    Songs(10) As Long
    Loops(10) As Integer
    Effects(20) As Long
End Type

'**
'* Initializes a sound player: songs and effects enabled, every song set
'* to loop.
'**
Declare Sub SoundPlayer_Init (sp As SoundPlayer)

'**
'* Registers the song handle ptr at slot index, with volume vol (0 to 1).
'**
Declare Sub SoundPlayer_AddSong (sp As SoundPlayer, index As Integer, ptr As _Unsigned Long, vol As Single)

'**
'* Registers the sound effect handle ptr at slot index, with volume vol
'* (0 to 1).
'**
Declare Sub SoundPlayer_AddEffect (sp As SoundPlayer, index As Integer, ptr As _Unsigned Long, vol As Single)

'**
'* Enables or disables music. Disabling stops the song currently playing.
'**
Declare Sub SoundPlayer_SetPlaySong (sp As SoundPlayer, pl As Integer)

'**
'* Enables or disables sound effects.
'**
Declare Sub SoundPlayer_SetPlayEffects (sp As SoundPlayer, pl As Integer)

'**
'* Starts the song at slot index (looping or not, according to its setting),
'* if music is enabled.
'**
Declare Sub SoundPlayer_PlaySong (sp As SoundPlayer, index As Integer)

'**
'* Stops the song currently playing.
'**
Declare Sub SoundPlayer_StopSong (sp As SoundPlayer)

'**
'* Pauses the song currently playing.
'**
Declare Sub SoundPlayer_PauseSong (sp As SoundPlayer)

'**
'* Resumes the song that was paused.
'**
Declare Sub SoundPlayer_ResumeSong (sp As SoundPlayer)

'**
'* Plays the sound effect at slot index, if effects are enabled.
'**
Declare Sub SoundPlayer_PlayEffect (sp As SoundPlayer, index As Integer)

'**
'* Sets the volume (0 to 1) of the song currently playing.
'**
Declare Sub SoundPlayer_SetSongVolume (sp As SoundPlayer, v As Single)

'**
'* Returns TRUE if a song is loaded and not paused.
'**
Declare Function SoundPlayer_IsPlayingSong% (sp As SoundPlayer)

' :mode=visualbasic:folding=explicit:wrap=none: