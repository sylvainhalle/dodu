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

' Threshold to enable block holding/dropping (px)
Const CLIMB_THRESHOLD% = 1
Const TAKE_THRESHOLD% = 5
Const DROP_THRESHOLD% = 5
Const UNCLIMB_THRESHOLD% = 5

' --------------------------
' Player
' --------------------------

Type Player
    LevPos As Point
    IsWalking As Integer
    HasBlock As Integer
    IsClimbing As Integer
    IsFalling As Integer
    IsPanting As Integer
    IsLooking As Integer
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

'**
'* Removes the block at square p from the map and gives it to the player.
'**
Declare Sub TakeBlock (m As LevelMap, p As Square)

'**
'* Removes the tuque at square p from the map and gives it to the player.
'* The tuque slows down the thermometer when the player carries no block.
'**
Declare Sub TakeTuque(m As LevelMap, p As Square)

'**
'* Removes the mittens at square p from the map and gives them to the player.
'* The mittens slow down the thermometer when the player carries a block.
'**
Declare Sub TakeMittens (m As LevelMap, p As Square)

'**
'* Removes the cookie at square p from the map and raises the player's
'* temperature by 5 (capped at 10).
'**
Declare Sub TakeCookie (m As LevelMap, p As Square)

'**
'* Removes the coffee at square p from the map and raises the player's
'* temperature by 7 (capped at 10).
'**
Declare Sub TakeCoffee (m As LevelMap, p As Square)

'**
'* Resets a player to its initial state: full temperature, no block,
'* not moving, and stopped thermometer/slip tickers.
'**
Declare Sub Player_Reset (p As Player)

'**
'* Returns TRUE if any of the state flags that affect the player's sprite
'* (walking, panting, looking, block, mittens, tuque, snow) differ between
'* p_now and p_past.
'**
Declare Function PlayerChanged (p_now As Player, p_past As Player)


' :mode=visualbasic:folding=explicit:wrap=none: