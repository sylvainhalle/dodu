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

' --------------------------
' Player
' --------------------------

Type Player
  LevPos As Point
  IsWalking As Integer
  HasBlock As Integer
  IsClimbing As Integer
  IsFalling As Integer
  ToLeft As Integer
  Temp As Integer ' 0 to 10
  ThermoTick As Ticker
  ThermoFlash As Integer
  HasMittens As Integer
  HasTuque As Integer
  HasRackets As Integer
  InSnow As Integer
  SlipTick As Ticker
  SlipDir As Integer
End Type

' Game state
Dim Shared Dodu As Player, DoduPast As Player

Declare Sub TakeBlock (m As LevelMap, p As Square)
Declare Sub TakeTuque(m As LevelMap, p As Square)
Declare Sub TakeMittens (m As LevelMap, p As Square)
Declare Sub TakeCookie (m As LevelMap, p As Square)
Declare Sub TakeCoffee (m As LevelMap, p As Square)

Declare Function PlayerChanged (p_now As Player, p_past As Player)

' :mode=visualbasic:folding=explicit:wrap=none: