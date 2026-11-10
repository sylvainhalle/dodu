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
    Running As Integer
    Length As Integer
    Index As Integer
    Loop As Integer
    Speed As Integer
    TickCnt As Integer
End Type

'**
'* Initializes and starts a ticker counting l steps, advancing one step
'* every speed ticks. If isloop is TRUE, it restarts at 0 after the last step.
'**
Declare Sub Ticker_Init (t As Ticker, l As Integer, speed As Integer, isloop As Integer)

'**
'* Advances a running ticker by one tick.
'**
Declare Sub Ticker_Tick (t As Ticker)

'**
'* Rewinds a ticker to step 0 and stops it.
'**
Declare Sub Ticker_Reset (t As Ticker)

'**
'* Starts (or resumes) a ticker.
'**
Declare Sub Ticker_Start (t As Ticker)

'**
'* Stops a ticker on its current step.
'**
Declare Sub Ticker_Stop (t As Ticker)

'**
'* Copies ticker src into dst.
'**
Declare Sub Ticker_Copy (dst As Ticker, src As Ticker)

'**
'* Returns TRUE if the ticker is running.
'**
Declare Function Ticker_IsRunning% (t As Ticker)

'**
'* Returns TRUE if the ticker is stopped (e.g. a non-looping ticker that
'* reached its last step).
'**
Declare Function Ticker_IsFinished% (t As Ticker)

' :mode=visualbasic: