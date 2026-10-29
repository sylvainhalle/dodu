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

Type BitmapFont
	Content As Long
	Width As Integer
	Height As Integer
End Type

Declare Sub BitmapFont_LoadFile (b As BitmapFont, filename As String)

Declare Sub BitmapFont_LoadHandle (b As BitmapFont, h As Long)

Declare Sub BitmapFont_WriteCharacter (v As Viewport, f As BitmapFont, p As Point, c As String)

Declare Sub BitmapFont_WriteString (v As Viewport, f As BitmapFont, p As Point, s As String, clr As Long)

' :mode=visualbasic: