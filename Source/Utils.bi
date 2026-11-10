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

' Booleans
Const FALSE = 0
Const TRUE = Not FALSE

'**
'* Returns the smallest integer greater than or equal to x.
'**
Declare Function Ceil% (x As Single)

'**
'* Returns the largest integer less than or equal to x.
'**
Declare Function Floor% (x As Single)

'**
'* Formats x as a string, left-padded with a space when it is a single digit.
'**
Declare Function NbFormat$ (x As Integer)

'**
'* Returns TRUE if min <= x <= max.
'**
Declare Function Within% (x As Integer, min As Integer, max As Integer)

'**
'* Waits for secs seconds while running a _Limit loop at units iterations
'* per second.
'**
Declare Sub DummyWait (secs As Single, units As Integer)

'**
'* Force int to be between a min and a max, when greater - clamp
'* it between min and max
'* https://qb64phoenix.com/forum/showthread.php?tid=1336&pid=12112#pid12112
'**
Declare Function Clamp% (value%, minimum%, maximum%)

'**
'* Returns TRUE if array a() contains value v.
'**
Declare Function Array_Contains% (a() As Integer, v As Integer)

'**
'* Prints s to the console window, then restores the current destination.
'**
Declare Sub PrintConsole (s As String)

'**
'* If CountTo is 0, returns the number of occurrences of Search in Content;
'* otherwise returns the position of occurrence number CountTo (0 if absent).
'* From https://qb64phoenix.com/forum/showthread.php?tid=3629&pid=34029
'**
Declare Function String.Find& (Content As String, Search As String, CountTo As Long)

'**
'* Returns content$ with every occurrence of from$ replaced by to$.
'**
Declare Function String.Replace$ (content$, from$, to$)

Declare CustomType Library
    '**
    '* C library rename(): renames file oldpath to newpath (null-terminated
    '* strings). Returns 0 on success.
    '**
    Function rename& (ByVal oldpath As _Offset, ByVal newpath As _Offset)
End Declare

Declare CustomType Library
    '**
    '* C library: returns a pointer to errno.
    '**
    Function __errno_location%& ()
End Declare

Declare Library
    '**
    '* C library perror(): prints message followed by the last system error.
    '**
    Sub perror (message As String)
End Declare

' :mode=visualbasic:folding=explicit:wrap=none:
