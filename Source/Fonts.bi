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

'**
'* Loads a bitmap font from an image file. The image must contain a
'* 16x16 grid of glyphs, ordered by ASCII code; color 0 is transparent.
'**
Declare Sub BitmapFont_LoadFile (b As BitmapFont, filename As String)

'**
'* Initializes a bitmap font from an already-loaded image handle h
'* (same 16x16 glyph grid layout as BitmapFont_LoadFile).
'**
Declare Sub BitmapFont_LoadHandle (b As BitmapFont, h As Long)

'**
'* Draws a single character c of font f at point p on the given layer
'* of the viewport.
'**
Declare Sub BitmapFont_WriteCharacter (v As Viewport, f As BitmapFont, p As Point, c As String, layer As Integer)

'**
'* Draws string s at point p on the given layer of the viewport, using
'* font f recolored with color clr (palette index 1 of the font image).
'**
Declare Sub BitmapFont_WriteString (v As Viewport, f As BitmapFont, p As Point, s As String, clr As Long, layer As Integer)

' :mode=visualbasic: