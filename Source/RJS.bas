Type Axis_Type
  Active As _Byte
  X As Integer
  Y As Integer
  Vert As Single
  Hort As Single
  Angle As Single
End Type
ReDim Shared As Axis_Type JoyStick(0)

Do
  Cls
  ReadJoyStick
  Print Time$
  For i = 1 To UBound(JoyStick)
    If JoyStick(i).Active Then
      Print Using "STICK # ACTIVE:"; i
      Print "Hort:", JoyStick(i).Hort, "Vert:", JoyStick(i).Vert
      Print "X:", JoyStick(i).X, "Y:", JoyStick(i).Y
      Print "Angle:", JoyStick(i).Angle
    End If
  Next
  _Limit 30
  _Display
Loop

Sub ReadJoyStick
  Static d, LA
  If d = 0 Then d = _Devices
  If d < 3 Then Exit Sub '3 is joystick.  Without one, then there's no reason to waste effort doing anything else.
  If LA = 0 Then LA = _LastAxis(3): ReDim JoyStick(1 To 3) As Axis_Type
  If LA = 0 Then Exit Sub 'if there's no axis on your joystick, I don't know how to read it!
  Dim axis(LA) As Single
  Do
    di = _DeviceInput
    Select Case di
      Case 3 'We have joystick input
        For a = 1 To LA: axis(a) = Int(100 * _Axis(a)) / 100: Next 'read the input on each axis
        JoyStick(1).Hort = axis(1): JoyStick(1).Vert = axis(2) 'left pad is axis 1 and 2
        'axis 3 is the botton left/right buttons on the front of my joystick
        'right-pad seems to be mapped backwards to the other axis??!!
    End Select
  Loop Until di = 0
  For j = 1 To 1
    If Abs(JoyStick(j).Vert) <= .01 Then JoyStick(j).Vert = 0 'remove some natural drift from the keypad
    If Abs(JoyStick(j).Hort) <= .01 Then JoyStick(j).Hort = 0 'my joystick seldom resets back to perfect 0
    ' the code below here gives me a simple X/Y value for left/right, up/down of _TRUE/_FALSE
    'I personally find it easier for my 2-d style games to process than having to use frational results.
    'Feel free to change the threshold as necessary for your own uses.  0.4 works fine for cardinal directions and diagionals for my use.
    If Abs(JoyStick(j).Vert) > 0.4 Then JoyStick(j).Y = Sgn(JoyStick(j).Vert) Else JoyStick(j).Y = 0
    If Abs(JoyStick(j).Hort) > 0.4 Then JoyStick(j).X = Sgn(JoyStick(j).Hort) Else JoyStick(j).X = 0
    'the angle here is just like the one we learned in school with 0/360 to the right, 90 up, 180 left, and 270 down
    'Tweak this as needed so it fits the coordinate system of your own stuff as desired.
    JoyStick(j).Angle = _Atan2(JoyStick(j).Hort, JoyStick(j).Vert)
    JoyStick(j).Angle = (_R2D(JoyStick(j).Angle) + 270) Mod 360
    'And below here is what determines if a joystick was active or not
    If JoyStick(j).Vert = 0 And JoyStick(j).Hort = 0 Then JoyStick(j).Active = _FALSE Else JoyStick(j).Active = _TRUE
  Next
End Sub

