Type Axis_Type
    Active As _Byte
    X As Integer
    Y As Integer
    Vert As Single
    Hort As Single
    Angle As Single
End Type
ReDim Shared As Axis_Type Joystick(0)

Do
    Cls
    ReadJoyStick
    Print Time$
    For i = 1 To UBound(Joystick)
        If Joystick(i).Active Then
            Print Using "STICK # ACTIVE:"; i
            Print "Hort:", Joystick(i).Hort, "Vert:", Joystick(i).Vert
            Print "X:", Joystick(i).X, "Y:", Joystick(i).Y
            Print "Angle:", Joystick(i).Angle
        End If
    Next
    _Limit 30
    _Display
Loop

Sub ReadJoyStick
    Static d, LA
    If d = 0 Then d = _Devices
    If d < 3 Then Exit Sub '3 is joystick.  Without one, then there's no reason to waste effort doing anything else.
    If LA = 0 Then LA = _LastAxis(3): ReDim Joystick(1 To 3) As Axis_Type
    If LA = 0 Then Exit Sub 'if there's no axis on your joystick, I don't know how to read it!
    Dim axis(LA) As Single
    Do
        di = _DeviceInput
        Select Case di
            Case 3 'We have joystick input
                For a = 1 To LA: axis(a) = Int(100 * _Axis(a)) / 100: Next 'read the input on each axis
                Joystick(1).Hort = axis(1): Joystick(1).Vert = axis(2) 'left pad is axis 1 and 2
                'axis 3 is the botton left/right buttons on the front of my joystick
                'right-pad seems to be mapped backwards to the other axis??!!
        End Select
    Loop Until di = 0
    For j = 1 To 1
        If Abs(Joystick(j).Vert) <= .01 Then Joystick(j).Vert = 0 'remove some natural drift from the keypad
        If Abs(Joystick(j).Hort) <= .01 Then Joystick(j).Hort = 0 'my joystick seldom resets back to perfect 0
        ' the code below here gives me a simple X/Y value for left/right, up/down of _TRUE/_FALSE
        'I personally find it easier for my 2-d style games to process than having to use frational results.
        'Feel free to change the threshold as necessary for your own uses.  0.4 works fine for cardinal directions and diagionals for my use.
        If Abs(Joystick(j).Vert) > 0.4 Then Joystick(j).Y = Sgn(Joystick(j).Vert) Else Joystick(j).Y = 0
        If Abs(Joystick(j).Hort) > 0.4 Then Joystick(j).X = Sgn(Joystick(j).Hort) Else Joystick(j).X = 0
        'the angle here is just like the one we learned in school with 0/360 to the right, 90 up, 180 left, and 270 down
        'Tweak this as needed so it fits the coordinate system of your own stuff as desired.
        Joystick(j).Angle = _Atan2(Joystick(j).Hort, Joystick(j).Vert)
        Joystick(j).Angle = (_R2D(Joystick(j).Angle) + 270) Mod 360
        'And below here is what determines if a joystick was active or not
        If Joystick(j).Vert = 0 And Joystick(j).Hort = 0 Then Joystick(j).Active = _False Else Joystick(j).Active = _True
    Next
End Sub

