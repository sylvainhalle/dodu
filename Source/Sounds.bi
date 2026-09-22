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
	CurrentSong As _Unsigned Long
	Songs(10) As _Unsigned Long
	Effects(10) As _Unsigned Long
End Type

Declare Sub SoundPlayer_Init (sp As SoundPlayer)

Declare Sub SoundPlayer_AddSong (sp As SoundPlayer, index As Integer, ptr As _Unsigned Long, vol As Single)

Declare Sub SoundPlayer_AddEffect (sp As SoundPlayer, index As Integer, ptr As _Unsigned Long, vol As Single)

Declare Sub SoundPlayer_SetPlaySong (sp As SoundPlayer, pl As Integer)

Declare Sub SoundPlayer_SetPlayEffects (sp As SoundPlayer, pl As Integer)

Declare Sub SoundPlayer_SetSong (sp As SoundPlayer, ref As _Unsigned Long)

Declare Sub SoundPlayer_PlaySong (sp As SoundPlayer)

Declare Sub SoundPlayer_StopSong (sp As SoundPlayer)

Declare Sub SoundPlayer_PauseSong (sp As SoundPlayer)

Declare Sub SoundPlayer_ResumeSong (sp As SoundPlayer)

Declare Sub SoundPlayer_PlayEffect (sp As SoundPlayer, index As Integer)

Declare Sub SoundPlayer_SetSongVolume (sp As SoundPlayer)

' :mode=visualbasic:folding=explicit:wrap=none: