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

Type Password
    Elements(4) As Integer
End Type

Type RestorePoint
    Level As Integer
    HasMittens As Integer
    HasTuque As Integer
End Type

Dim Shared Passwords(20, 4) As Password

'**
'* Loads the password table (4 symbols for each level and each
'* mittens/tuque combination) from the PWS DATA block.
'**
Declare Sub LoadPasswords ()

'**
'* Stores in p the password for the given level and power-up combination
'* (hasmittens, hastuque).
'**
Declare Sub GetPassword (p As Password, level As Integer, hasmittens As Integer, hastuque As Integer)

'**
'* Finds the level and power-ups matching the 4 symbols in selection(),
'* in any order. Sets rp.Level to -1 if no password matches.
'**
Declare Sub LookupPassword (rp As RestorePoint, selection() As Integer)

' :mode=visualbasic:folding=explicit:wrap=none: