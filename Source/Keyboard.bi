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
Const KEY_BACKSPACE = 8
Const KEY_ENTER = 13
Const KEY_ESC = 27
Const KEY_SPACE = 32
Const KEY_CTRL = 100306
Const KEY_ALT = 100308
Const KEY_LEFT = 19200
Const KEY_RIGHT = 19712
Const KEY_UP = 18432
Const KEY_DOWN = 20480
Const KEY_EQ = 61
Const KEY_LT = 60
Const KEY_GT = 62
Const KEY_LSHIFT = 100304
Const KEY_RSHIFT = 100303
Const KEY_END = 20224
Const KEY_INS = 20992
Const KEY_DEL = 21248

Const KEY_B_UC = 66
Const KEY_B_LC = 98
Const KEY_M_UC = 77
Const KEY_M_LC = 109
Const KEY_S_UC = 53
Const KEY_S_LC = 115

Const JOY_1 = 0
Const JOY_2 = 1
Const JOY_3 = 2
Const JOY_4 = 3

Type InputEvent
    Backspace As Integer
    Esc As Integer
    SpaceBar As Integer
    Ctrl As Integer
    KLeft As Integer
    KRight As Integer
    KTop As Integer
    KBottom As Integer
    KMUC As Integer
    KMLC As Integer
End Type

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

Dim Shared Joystick As JoystickState

'**
'* Returns TRUE if key/button k is pressed on the keyboard or the joystick.
'* k is a KEY_* code or one of the JOY_1 to JOY_4 button codes.
'**
Declare Function In_Down (k As Integer)

'**
'* Returns TRUE if the joystick state matches k. Arrow KEY_* codes are
'* mapped to the joystick axes; JOY_1 to JOY_4 to its buttons.
'**
Declare Function Joy_Down (k As Integer)

'**
'* Returns TRUE if key k is currently held down on the keyboard.
'**
Declare Function Kbd_Down (k As Integer)

'**
'* Returns TRUE if the primary action button (Enter or joystick button 1)
'* is pressed.
'**
Declare Function IsButton1% ()

'**
'* Returns TRUE if the secondary action button (Backspace or joystick
'* button 2) is pressed.
'**
Declare Function IsButton2% ()

'**
'* Returns TRUE if "left" is pressed (keyboard or joystick).
'**
Declare Function IsLeft% ()

'**
'* Returns TRUE if "right" is pressed (keyboard or joystick).
'**
Declare Function IsRight% ()

'**
'* Returns TRUE if "up" is pressed (keyboard or joystick).
'**
Declare Function IsUp% ()

'**
'* Returns TRUE if "down" is pressed (keyboard or joystick).
'**
Declare Function IsDown% ()

'**
'* Returns TRUE if Escape is pressed.
'**
Declare Function IsEsc% ()

'**
'* Returns TRUE if Enter is pressed.
'**
Declare Function IsEnter% ()

'**
'* Enumerates the input devices reported by QB64 and fills the Controllers
'* array with their id, kind (keyboard, mouse, joystick) and description.
'**
Declare Sub Kbd_FindDevices ()

'**
'* Polls pending joystick input and updates the global Joystick state
'* (axes and buttons).
'**
Declare Sub ReadJoystick ()


'**
'* Waits until the current key being pressed is released.
'**
Declare Sub Kbd_WaitRelease(fps As Integer)

' :mode=visualbasic:folding=explicit:wrap=none:
