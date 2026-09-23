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

Declare Function Ceil% (x As Single)
Declare Function Floor% (x As Single)
Declare Function NbFormat$ (x As Integer)

'**
'* Force int to be between a min and a max, when greater - clamp 
'* it between min and max
'* https://qb64phoenix.com/forum/showthread.php?tid=1336&pid=12112#pid12112
'**
Declare Function Clamp% (value%, minimum%, maximum%)

' :mode=visualbasic:folding=explicit:wrap=none:
