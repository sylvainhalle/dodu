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

'**
'** - Ticker --------------------------------------------------- {{{
'**

Type Ticker
	Length As Integer
	Index As Integer
	Loop As Integer
	Speed As Integer
	TickCnt As Integer
End Type

Declare Sub Ticker_Init (t As Ticker, l As Integer, speed As Integer, isloop As Integer)

Declare Sub Ticker_Tick (t As Ticker)

Declare Sub Ticker_Reset (t As Ticker)

Declare Function Ticker_IsRunning% (t As Ticker)

Declare Function Ticker_IsFinished% (t As Ticker)

' :mode=visualbasic: