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

' Devices
Dim Shared DeviceCount As Integer
Let DeviceCount = _Devices

' Keys
Const K_BACKSPACE = 8
Const K_ENTER = 13
Const K_ESC = 27
Const K_SPACE = 32
Const K_CTRL = 100306
Const K_LEFT = 19200
Const K_RIGHT = 19712
Const K_UP = 18432
Const K_DOWN = 20480
Const K_M_UC = 77
Const K_M_LC = 109
Const J_1 = 0
Const J_2 = 1
Const J_3 = 2
Const J_4 = 3

' This part adapted from
' https://www.qb64tutorial.com/lesson21

Const KBD_CONTROLLER = 1 '               controller is a keyboard
Const MOUSE_CONTROLLER = 2 '             controller is a mouse
Const JPAD_CONTROLLER = 3 '              controller is a joystick/game pad

Type TYPE_CONTROLLER '                   CONTROLLER PROPERTIES
  id As Integer '                      device id number of controller (1 to _DEVICES)
  Kind As Integer '                    the type of controller         (1, 2, or 3)
  Buttons As Integer '                 controller buttons
  Axis As Integer '                    controller Axis
  Wheels As Integer '                  controller wheels
  Description As String * 20 '         description of controller
End Type

ReDim Shared Controllers(0) As TYPE_CONTROLLER ' controller information array

Type JoystickState
	Active As _Byte
	H As Single
	V As Single
	Buttons(4) As Long
End Type

Dim Shared JOYSTICK As JoystickState

Declare Function In_Down% (k As Integer)
Declare Function Joy_Down% (k As Integer)
Declare Function Kbd_Down% (k As Integer)

Declare Sub Kbd_FindDevices ()



'**
'* Waits until the current key being pressed is released.
'**
Declare Sub Kbd_WaitRelease(fps As Integer)

' :mode=visualbasic:folding=explicit:wrap=none:
