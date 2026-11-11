$Debug
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

Option Base 0
Option _Explicit
$ErrorLocation:On

' --------------------------
' Includes (declarations)
' --------------------------
'$IncludeOnce
'$Include:'Utils.bi'

Dim dummy As String

' --------------------------
' Program constants
' --------------------------

' Screen dimensions

' Frame rate
Const FPS% = 25

' Window scaling factor
Const SCALE% = 6


' Number of frames between ticks of the thermometer
Const THERMO_TICK_NORMAL% = 100
Const THERMO_TICK_NORMAL_TUQUE% = 150
Const THERMO_TICK_FAST% = 35
Const THERMO_TICK_FAST_MITTENS% = 70
Const THERMO_TICK_STEPS% = 10
Const SLIP_TICK_STEPS% = 6

' Number of frames between ticks of the slip ticker
Const SLIP_TICK_NORMAL% = 2

' Number of steps when panning back
Const PANBACK_STEPS% = 8

' Number of *seconds* of the pan at the start of a level
Const INIT_SCROLL_DURATION% = 3

' Location of level number
Dim Shared PtLevelNb As Point
Point_Set PtLevelNb, 2, 20

Dim Shared PtUnit As Point
Point_Set PtUnit, 1, 1

' Number of screen pixels per frame
' Currently, can only be an integer
Const WALKING_SPEED# = 1
Const WALKING_SPEED_SNOW# = 0.3

Dim Shared WalkingTicker As Ticker
Ticker_Init WalkingTicker, Ceil%(1 / WALKING_SPEED), 1, TRUE

Dim PlayMusic As Integer
Let PlayMusic = TRUE

Dim Shared CfgCutscenes As Integer
Let CfgCutscenes = TRUE

Dim Shared CfgSplash As Integer
Let CfgSplash = TRUE

Dim Shared CfgThermo As Integer
Let CfgThermo = TRUE

' --------------------------
' Other includes (declarations)
' --------------------------
'$Include:'Geometry.bi'
'$Include:'Ticker.bi'
'$Include:'Sprites.bi'
'$Include:'Fonts.bi'
'$Include:'Keyboard.bi'
'$Include:'Sounds.bi'
'$Include:'Levels.bi'
'$Include:'Gameplay.bi'
'$Include:'Passwords.bi'

' --------------------------
' Levels
' --------------------------
LoadLevels
Dim Shared CurrentLevel As Integer, LastLevel As Integer
Dim Shared LastTuque As Integer, LastMittens As Integer
Let CurrentLevel = 0
Let LastLevel = -1
Let LastTuque = FALSE
Let LastMittens = FALSE

' --------------------------
' Depth settings
' --------------------------
Const IMG_DEPTH% = 4
Const DEPTH_BACKGROUND% = 0
Const DEPTH_POLE% = 1
Const DEPTH_ROPE% = 1
Const DEPTH_WATER% = 1
Const DEPTH_PLAYER% = 2
Const DEPTH_LEVEL% = 2
Const DEPTH_CARDS% = 2
Const DEPTH_SNOW_BACK% = 1
Const DEPTH_SNOW_FRONT = 3
Const DEPTH_CONTROLS% = 3

' --------------------------
' Command line arguments
' --------------------------

Let Dodu.HasBlock = FALSE
Let Dodu.IsClimbing = 0
Let Dodu.Temp = 10
Let Dodu.HasMittens = FALSE
Let Dodu.HasTuque = FALSE

Dim argc As Integer, toset As String
For argc = 1 To _CommandCount
    Select Case Command$(argc)
        Case "--nomusic"
            Let PlayMusic = FALSE
        Case "--nocutscenes"
            Let CfgCutscenes = FALSE
        Case "--nosplash"
            Let CfgSplash = FALSE
        Case "--nothermo"
            Let CfgThermo = FALSE
        Case "--tuque"
            Let Dodu.HasTuque = TRUE
        Case "--mittens"
            Let Dodu.HasMittens = TRUE
        Case "--scanlines"
            Let toset = "scanlines"
        Case "--level"
            Let toset = "level"
        Case "--video"
            Let toset = "video"
        Case "--width"
            Let toset = "width"
        Case "--height"
            Let toset = "height"
        Case "--outfile"
            Let toset = "outfile"
        Case "--screen"
            Let toset = "screen"
        Case "--stereo"
            Let CfgStereoscopic = TRUE
        Case Else
            Select Case toset
                Case "level"
                    Let CurrentLevel = Val(Command$(argc)) - 1
                Case "width"
                    Point_Set ScreenDims, Val(Command$(argc)) - 1, ScreenDims.y
                Case "height"
                    Point_Set ScreenDims, ScreenDims.x, Val(Command$(argc)) - 1
                Case "outfile"
                    Let CfgStereoTempfile = Command$(argc) + ".tmp.jpg"
                    Let CfgStereoOutfile = Command$(argc) + ".jpg"
                    Let CfgStereoTempfileC = CfgStereoTempfile + Chr$(0)
                    Let CfgStereoOutfileC = CfgStereoOutfile + Chr$(0)
                Case "video"
                    Select Case UCase$(Command$(argc))
                        Case "HER"
                            Let ImgMode$ = IMG_MODE_HER
                        Case "MCGA"
                            Let ImgMode$ = IMG_MODE_MCGA
                        Case "CGA"
                            Let ImgMode$ = IMG_MODE_CGA
                        Case "EGA"
                            Let ImgMode$ = IMG_MODE_EGA
                        Case "TI83"
                            Let ImgMode$ = IMG_MODE_TI83
                            Let Scanlines = SCANLINES_GRID
                            Let ScanlineWidth = 3
                            Let ScanlineColor = COLOR_TI83_SCANLINE
                    End Select
                Case "screen"
                    Select Case UCase$(Command$(argc))
                        Case "GAMEBUINO"
                            Point_Set ScreenDims, SCREEN_GAMEBUINO_X, SCREEN_GAMEBUINO_Y
                        Case "PC"
                            Point_Set ScreenDims, SCREEN_PC_X, SCREEN_PC_Y
                    End Select
                Case "scanlines"
                    Select Case UCase$(Command$(argc))
                        Case "NONE"
                            Let Scanlines = SCANLINES_NONE
                        Case "VERT"
                            Let Scanlines = SCANLINES_VERT
                        Case "GRID"
                            Let Scanlines = SCANLINES_GRID
                    End Select
            End Select
    End Select
Next

' Do we enlarge to handle two images?
If CfgStereoscopic Then
    Point_Set ScreenActualDims, ScreenDims.x * 2 + EYE_SEP, ScreenDims.y
Else
    Point_Set ScreenActualDims, ScreenDims.x, ScreenDims.y
End If

' Loading assets
'$Include:'Assets.bi'

' Application icon
$ExeIcon:'/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Game_Icon.ico'
_Icon _LoadImage("/home/sylvain/Workspaces/dodu/Source/images/ega/gui/Game_Icon.ico")
_Title "Dodu!"

' --------------------------
' Screen setup: 1 main screen and 1 buffer
' --------------------------
_AllowFullScreen _Off
Dim Shared MainScreen As Viewport, ImgBuffer As Viewport

' --------------------------
' Main loop
' --------------------------
Let Audio.PlaySong = PlayMusic%
Let Audio.PlayEffects = TRUE

Dim Shared CurrentTrajectory As Integer
Let CurrentTrajectory% = -1
Dim Shared CurrentSprite(3) As SpriteSequence

Dim Shared parallax As Point
Point_Set parallax, 2, 2

Dim Shared SpriteLevel(IMG_DEPTH, MAP_WIDTH, MAP_HEIGHT) As SpriteSequence

LoadPasswords
MainLoop
$Console


Sub MainLoop
    Do
        Viewport_Init MainScreen, ScreenActualDims, PtOrigin, ScreenActualDims, SCALE, 1
        Let MainScreen.ScanlineWidth = ScanlineWidth
        Viewport_Init_Default ImgBuffer, ScreenDims, ScreenDims, IMG_DEPTH
        Dim rst As RestorePoint
        Screen MainScreen.Layers(0).Buffer
        PrintConsole Point_ToString(ScreenActualDims)
        Let MainScreen.Scanlines = Scanlines
        Let MainScreen.ScanlineWidth = ScanlineWidth
        Let MainScreen.ScanlineColor = ScanlineColor
        If CfgSplash Then
            DoLifSplash
        End If
        DoIntroduction rst
        If rst.Level >= 0 Then
            Let CurrentLevel = rst.Level
            Let Dodu.HasMittens = rst.HasMittens
            Let Dodu.HasTuque = rst.HasTuque
        End If

        Viewport_FadeOut MainScreen, Ceil%(0.3 * FPS)
        Viewport_Wait ImgBuffer, MainScreen, 2, FPS
        Do
            If Levels(CurrentLevel).CutScene >= 0 And CfgCutscenes Then
                SoundPlayer_StopSong Audio
                DoCutScene Levels(CurrentLevel).CutScene
                SoundPlayer_StopSong Audio
            End If
            If Not SoundPlayer_IsPlayingSong(Audio) Then
                SoundPlayer_PlaySong Audio, Levels(CurrentLevel).SongIndex
            End If
            Dim ws As Point
            Point_Set ws, Levels(CurrentLevel).Width * BLOCK_SIZE, Levels(CurrentLevel).Height * BLOCK_SIZE

            Viewport_Init_Default ImgBuffer, ScreenDims, ws, IMG_DEPTH
            Viewport_SetFont ImgBuffer, FntTinyC
            DoLevel
            If Levels(CurrentLevel + 1).CutScene < 0 Then
                SoundPlayer_PlayEffect Audio, SND_LEVELUP
            Else
                Viewport_Wait ImgBuffer, MainScreen, 0.7, FPS
            End If
            Let LastLevel = CurrentLevel
            Let CurrentLevel = CurrentLevel + 1
            Let LastMittens = Dodu.HasMittens
            Let LastTuque = Dodu.HasTuque
        Loop
    Loop
End Sub

Sub DoLevel
    Let CurrentTrajectory = -1
    Dim CtrlPressed As Integer
    Dim panback_ticker As Ticker
    Dim dod_lastgrab As Point
    Dim sq_lastgrab As Square, sq_lastdrop As Square
    Dim center As Point, panbacktarget As Point
    Dim trjP As Point, lp As Point, moveP As Point, panP As Point

    Dim climbP As Square, takeP As Square, dropP As Square
    Dim unclimbP As Square, blockingP As Square, poleP As Square
    Dim mittensP As Square, tuqueP As Square, cookieP As Square
    Dim coffeeP As Square, snowP As Square, feetP As Square

    Let CtrlPressed = FALSE
    Player_Reset Dodu
    Player_Reset DoduPast
    Let DoduPast.IsWalking = TRUE
    Let DoduPast.InSnow = TRUE
    GetDoduSprite CurrentSprite(), Dodu, DoduPast

    Ticker_Init Dodu.ThermoTick, THERMO_TICK_STEPS, THERMO_TICK_NORMAL, FALSE
    Ticker_Init Dodu.SlipTick, SLIP_TICK_STEPS, SLIP_TICK_NORMAL, FALSE
    Ticker_Init panback_ticker, PANBACK_STEPS, 1, FALSE

    Viewport_SetBackground ImgBuffer, _
        Backgrounds(Levels(CurrentLevel%).Background), Levels(CurrentLevel%).BackgroundParallax

    'Color COLOR_WHITE&, , , ImgBuffer.Buffer
    '_PrintMode _KeepBackground , ImgBuffer.Buffer
    Screen MainScreen.Layers(0).Buffer

    Let Dodu.LevPos.x = Levels(CurrentLevel).StartPoint.col * BLOCK_SIZE
    Let Dodu.LevPos.y = (Levels(CurrentLevel).StartPoint.row - 2) * BLOCK_SIZE

    PrepareLevel Levels(CurrentLevel), FALSE ' Back
    PrepareLevel Levels(CurrentLevel), TRUE ' Front

    Square_Set sq_lastgrab, -1, -1
    Square_Set sq_lastdrop, -1, -1
    Point_Set trjP, -1, -1

    ' Force initial animation selection
    Let DoduPast.HasBlock = 10
    Let DoduPast.IsWalking = 10

    ' ---------------------------------------
    ' 0. Initial pan
    ' ---------------------------------------
    GetDoduCenter center
    Viewport_StopPan ImgBuffer
    Dim target_s As Square, target_p As Point
    Level_GoalSquare Levels(CurrentLevel%), target_s
    Square_ToPoint target_s, target_p
    Viewport_Clear ImgBuffer
    _Dest MainScreen.Layers(0).Buffer
    Cls
    DrawLevel ImgBuffer, Levels(CurrentLevel%), FALSE
    Viewport_SetCenter ImgBuffer, target_p
    DrawThermometer ImgBuffer, DEPTH_CONTROLS
    DrawLevelNumber ImgBuffer, DEPTH_CONTROLS
    Viewport_FadeIn MainScreen, Ceil%(0.5 * FPS)
    'Viewport_Wait ImgBuffer, MainScreen, 0.8, FPS%
    Viewport_ScrollCenter ImgBuffer, center, INIT_SCROLL_DURATION * FPS
    Do
        _Limit FPS
        Viewport_Clear ImgBuffer
        DrawLevel ImgBuffer, Levels(CurrentLevel%), FALSE
        DrawPlayer ImgBuffer, CurrentSprite()
        DrawLevel ImgBuffer, Levels(CurrentLevel%), TRUE
        DrawThermometer ImgBuffer, DEPTH_CONTROLS
        DrawLevelNumber ImgBuffer, DEPTH_CONTROLS
        Viewport_Tick ImgBuffer
        Viewport_Copy ImgBuffer, MainScreen, EYE_LEFT
        Viewport_Copy ImgBuffer, MainScreen, EYE_RIGHT
        Viewport_Tick MainScreen
        Viewport_Display MainScreen, EYE_NONE
        If IsEsc% Or IsEnter% Then
            Ticker_Stop ImgBuffer.PanTick
            Exit Do
        End If
    Loop Until Ticker_IsFinished%(ImgBuffer.PanTick)

    Viewport_SetCenter ImgBuffer, center
    Dim hasfallen As Integer
    Dim lastClimbIndex As Integer, lastUnclimbIndex As Integer, lastFallIndex As Integer

    Do
        _Limit FPS

        ' ---------------------------------------
        ' 1. Input and ordinary simulation
        ' ---------------------------------------

        ReadJoystick
        Viewport_Tick ImgBuffer

        ' Thermometer
        If CfgThermo Then
            Ticker_Tick Dodu.ThermoTick

            If Dodu.ThermoTick.TickCnt = 0 Or _
                    (Dodu.Temp < 3 And Dodu.ThermoTick.TickCnt Mod FPS = 0) Then
                SoundPlayer_PlayEffect Audio, SND_THERMO
            End If

            If Dodu.ThermoTick.TickCnt = 0 Then
                Let Dodu.Temp = Dodu.Temp - 1
                If CurrentTrajectory < 0 Then
                    Let CurrentTrajectory = TRJ_LOOKING_THERMO
                    Let Dodu.IsLooking = TRUE
                End If
            End If

            If Dodu.Temp = 0 Then
                If Dodu.HasMittens And Not Dodu.HasTuque Then
                    SoundPlayer_PlayEffect Audio, SND_POWERDOWN
                    Let Dodu.HasMittens = FALSE
                    Let Dodu.Temp = 5
                    If Dodu.HasBlock Then
                        Let Dodu.ThermoTick.Speed = THERMO_TICK_FAST
                    Else
                        Let Dodu.ThermoTick.Speed = THERMO_TICK_NORMAL
                    End If
                    Ticker_Reset Dodu.ThermoTick
                ElseIf Not Dodu.HasMittens And Dodu.HasTuque Then
                    SoundPlayer_PlayEffect Audio, SND_POWERDOWN
                    Let Dodu.HasTuque = FALSE
                    Let Dodu.Temp = 5
                    If Dodu.HasBlock Then
                        Let Dodu.ThermoTick.Speed = THERMO_TICK_FAST
                    Else
                        Let Dodu.ThermoTick.Speed = THERMO_TICK_NORMAL
                    End If
                    Ticker_Reset Dodu.ThermoTick
                ElseIf Dodu.HasMittens And Dodu.HasTuque Then
                    SoundPlayer_PlayEffect Audio, SND_POWERDOWN
                    If Dodu.HasBlock Then
                        Let Dodu.HasMittens = FALSE
                        Let Dodu.ThermoTick.Speed = THERMO_TICK_FAST
                    Else
                        Let Dodu.HasTuque = FALSE
                        Let Dodu.ThermoTick.Speed = THERMO_TICK_NORMAL
                    End If
                    Let Dodu.Temp = 5
                    Ticker_Reset Dodu.ThermoTick
                Else
                    GoTo GameOver:
                End If
            End If
        End If

        ' Modal commands
        If _KeyDown(KEY_ESC) Then GoTo Quit:

        If _KeyDown(KEY_SPACE) Then
            DoPause
            _Continue
        End If

        If _KeyDown(KEY_M_UC) Or _KeyDown(KEY_M_LC) Then
            DoMiniMap
            _Continue
        End If

        ' ---------------------------------------
        ' 2. Calculate squares of interest
        ' ---------------------------------------

        Let lp = Dodu.LevPos

        ' Must update orientation of Dodu *before* calculating the squares
        If IsLeft% Then
            Let Dodu.ToLeft = TRUE
        ElseIf IsRight% Then
            Let Dodu.ToLeft = FALSE
        End If

        ClimbableSquare Dodu.ToLeft, lp, Levels(CurrentLevel), climbP
        TakeableSquare Dodu.ToLeft, lp, Levels(CurrentLevel), takeP
        DroppableSquare Dodu.ToLeft, lp, Levels(CurrentLevel), dropP
        UnclimbableSquare Dodu.ToLeft, lp, Levels(CurrentLevel), unclimbP
        BlockingSquare Dodu.ToLeft, lp, Levels(CurrentLevel), blockingP
        PoleSquare Dodu.ToLeft, lp, Levels(CurrentLevel), poleP
        MittensSquare Dodu.ToLeft, lp, Levels(CurrentLevel), mittensP
        TuqueSquare Dodu.ToLeft, lp, Levels(CurrentLevel), tuqueP
        CookieSquare Dodu.ToLeft, lp, Levels(CurrentLevel), cookieP
        CoffeeSquare Dodu.ToLeft, lp, Levels(CurrentLevel), coffeeP
        SnowSquare Dodu.ToLeft, lp, Levels(CurrentLevel), snowP
        FeetSquare Dodu.ToLeft, lp, Levels(CurrentLevel), feetP

        If CurrentTrajectory% = TRJ_CLIMBING_SNOW Then
            Let Dodu.InSnow = TRUE
        Else
            If IsPlayerInSnow(Dodu.LevPos, Levels(CurrentLevel)) Then
                Let Dodu.InSnow = TRUE
                Let WalkingTicker.Speed = Ceil%(1 / WALKING_SPEED_SNOW)
                If Dodu.IsWalking _AndAlso Square_IsValid(snowP) Then
                    SpriteSequence_Start SpriteLevel(0, snowP.col, snowP.row)
                    SpriteSequence_Start SpriteLevel(1, snowP.col, snowP.row)
                End If
            Else
                Let Dodu.InSnow = FALSE
                Let WalkingTicker.Speed = Ceil%(1 / WALKING_SPEED)
            End If
        End If

        ' ---------------------------------------
        ' 3. Active movement trajectory
        ' ---------------------------------------

        If CurrentTrajectory% >= 0 And CurrentTrajectory% < 100 Then
            Tick_Trajectory trjP

            MovePlayer ImgBuffer, trjP

            If Ticker_IsFinished%(Trajectories(CurrentTrajectory%).Ticker) Then
                Select Case CurrentTrajectory
                    Case TRJ_UNCLIMBING
                        Let lastUnclimbIndex = Trajectories(CurrentTrajectory).Ticker.Index
                    Case TRJ_CLIMBING
                        Let lastClimbIndex = Trajectories(CurrentTrajectory).Ticker.Index
                    Case TRJ_FALLING
                        Let lastFallIndex = Trajectories(CurrentTrajectory).Ticker.Index
                End Select
                If Not (CurrentTrajectory% = TRJ_UNCLIMBING Or CurrentTrajectory% = TRJ_FALLING) Then
                    Let CurrentTrajectory% = -1
                    Let Dodu.IsPanting = FALSE
                    Let Dodu.IsLooking = FALSE
                Else
                    If Not IsOnGround%(Dodu.LevPos, Levels(CurrentLevel)) Then
                        Let CurrentTrajectory% = -1
                        '   Not reached the ground: fall
                        Initiate_Trajectory TRJ_FALLING, Dodu.ToLeft
                        Let hasfallen = TRUE
                    Else
                        Let CurrentTrajectory% = -1
                        Let Dodu.IsPanting = FALSE
                        Let Dodu.IsLooking = FALSE
                    End If
                End If
                GoTo RenderFrame:
            End If
        End If

        ' ---------------------------------------
        ' 4. Goal
        ' ---------------------------------------

        If Square_IsValid(poleP) Then Exit Sub

        ' ---------------------------------------
        ' 4'. Power-ups
        ' ---------------------------------------
        If Square_IsValid(mittensP) Then
            TakeMittens Levels(CurrentLevel), mittensP
            SoundPlayer_PlayEffect Audio, SND_POWERUP
        End If

        If Square_IsValid(tuqueP) Then
            TakeTuque Levels(CurrentLevel), tuqueP
            SoundPlayer_PlayEffect Audio, SND_POWERUP
        End If

        If Square_IsValid(cookieP) Then
            TakeCookie Levels(CurrentLevel), cookieP
            SoundPlayer_PlayEffect Audio, SND_COOKIE
        End If

        If Square_IsValid(coffeeP) Then
            TakeCoffee Levels(CurrentLevel), coffeeP
            SoundPlayer_PlayEffect Audio, SND_COOKIE
        End If



        ' ---------------------------------------
        ' 5. Pan-back initiation
        ' ---------------------------------------

        If Not _KeyDown(KEY_CTRL) And CtrlPressed = TRUE And _
                CurrentTrajectory < 0 Then

            Let CtrlPressed = FALSE
            Let CurrentTrajectory% = TRJ_PANBACK
            Ticker_Reset panback_ticker
            Ticker_Start panback_ticker

            GetDoduCenter center

            Point_Set panbacktarget, _
                (center.x - ImgBuffer.Pan.x - ImgBuffer.Size.x / 2) / PANBACK_STEPS, _
                (center.y - ImgBuffer.Pan.y - ImgBuffer.Size.y / 2) / PANBACK_STEPS
        End If

        ' ---------------------------------------
        ' 6. Pan-back trajectory
        ' ---------------------------------------

        If CurrentTrajectory% = TRJ_PANBACK Then

            Ticker_Tick panback_ticker
            Viewport_MovePan ImgBuffer, panbacktarget

            If Ticker_IsFinished%(panback_ticker) Then
                Let CurrentTrajectory% = -1
                Ticker_Reset panback_ticker
            End If

            GoTo RenderFrame:
        End If

        ' ---------------------------------------
        ' 7. Manual viewport panning
        ' ---------------------------------------

        If _KeyDown(KEY_CTRL) Then

            If IsLeft% Then
                Point_Set panP, -3, 0
            ElseIf IsRight% Then
                Point_Set panP, 3, 0
            ElseIf IsUp% Then
                Point_Set panP, 0, -3
            ElseIf IsDown% Then
                Point_Set panP, 0, 3
            Else
                GoTo RenderFrame:
            End If

            Viewport_MovePan ImgBuffer, panP
            Let CtrlPressed = TRUE

            GoTo RenderFrame:
        End If

        ' ---------------------------------------
        ' 8. Ordinary player controls
        ' ---------------------------------------

        Dim slopetype As Integer
        Let slopetype = SLOPE_NONE
        If Square_IsValid(feetP) Then
            Let slopetype = GetSnowSlopeAt(feetP.col, feetP.row, Levels(CurrentLevel%))
        End If

        If IsLeft% Then

            Let Dodu.ToLeft = TRUE
            Let Dodu.SlipDir = -1

            If Square_IsValid(climbP) Then

                Let Dodu.IsWalking = TRUE
                If slopetype = SLOPE_R Or slopetype = SLOPE_R Or slopetype = SLOPE_C Then
                    Initiate_Trajectory TRJ_CLIMBING_SNOW, TRUE
                    SpriteSequence_Start SpriteLevel(0, climbP.col, climbP.row)
                    SpriteSequence_Start SpriteLevel(1, climbP.col, climbP.row)
                Else
                    Initiate_Trajectory TRJ_CLIMBING, TRUE
                End If

            Else

                If Not Square_IsValid(blockingP) Then
                    Point_Set moveP, -1, 0
                    Let Dodu.IsWalking = TRUE
                    Ticker_Tick WalkingTicker
                    MovePlayer ImgBuffer, moveP
                Else
                    Let Dodu.IsWalking = FALSE
                End If

            End If

            If Square_IsValid(unclimbP) Then
                Let Dodu.IsWalking = FALSE
                Initiate_Trajectory TRJ_UNCLIMBING, TRUE
            End If

        ElseIf IsRight% Then

            Let Dodu.ToLeft = FALSE
            Let Dodu.SlipDir = 1

            If Square_IsValid(climbP) Then

                Let Dodu.IsWalking = TRUE
                If slopetype = SLOPE_R Or slopetype = SLOPE_R Or slopetype = SLOPE_C Then
                    Initiate_Trajectory TRJ_CLIMBING_SNOW, FALSE
                    SpriteSequence_Start SpriteLevel(0, climbP.col, climbP.row)
                    SpriteSequence_Start SpriteLevel(1, climbP.col, climbP.row)
                Else
                    Initiate_Trajectory TRJ_CLIMBING, FALSE
                End If
            Else

                If Not Square_IsValid(blockingP) Then
                    Point_Set moveP, 1, 0
                    Let Dodu.IsWalking = TRUE
                    Ticker_Tick WalkingTicker
                    MovePlayer ImgBuffer, moveP
                Else
                    Let Dodu.IsWalking = FALSE
                End If

            End If

            If Square_IsValid(unclimbP) Then
                Let Dodu.IsWalking = FALSE
                Initiate_Trajectory TRJ_UNCLIMBING, FALSE
            End If

        ElseIf IsUp% And Square_IsValid(takeP) Then

            SoundPlayer_PlayEffect Audio, SND_GRAB
            TakeBlock Levels(CurrentLevel), takeP

            Point_Set dod_lastgrab, Dodu.LevPos.x, Dodu.LevPos.y
            Let sq_lastgrab.col = takeP.col
            Let sq_lastgrab.row = takeP.row
            If Dodu.HasMittens Then
                Let Dodu.ThermoTick.Speed = THERMO_TICK_FAST_MITTENS
            Else
                Let Dodu.ThermoTick.Speed = THERMO_TICK_FAST
            End If

            Let Dodu.IsWalking = FALSE

        ElseIf IsDown% And Square_IsValid(dropP) Then

            SoundPlayer_PlayEffect Audio, SND_DROP

            Let sq_lastdrop.col = dropP.col
            Let sq_lastdrop.row = dropP.row

            DropBlock Levels(CurrentLevel), dropP
            If Dodu.HasTuque Then
                Let Dodu.ThermoTick.Speed = THERMO_TICK_NORMAL_TUQUE
            Else
                Let Dodu.ThermoTick.Speed = THERMO_TICK_NORMAL
            End If
            Let Dodu.IsWalking = FALSE

        ElseIf _KeyDown(KEY_BACKSPACE) And _
                Square_IsValid(sq_lastgrab) And _
                Square_IsValid(sq_lastdrop) Then

            ' Undo last block
            Let Dodu.LevPos.x = dod_lastgrab.x
            Let Dodu.LevPos.y = dod_lastgrab.y

            Let CurrentTrajectory% = TRJ_PANBACK

            Let Levels(CurrentLevel).Topo(sq_lastdrop.col, sq_lastdrop.row) = TILE_NOTHING
            Let Levels(CurrentLevel).Topo(sq_lastgrab.col, sq_lastgrab.row) = TILE_BLOCK_W

            Square_Set sq_lastgrab, -1, -1
            Square_Set sq_lastdrop, -1, -1

            GetDoduCenter center

            Point_Set panbacktarget, _
                (center.x - ImgBuffer.Pan.x - ImgBuffer.Size.x / 2) / PANBACK_STEPS, _
                (center.y - ImgBuffer.Pan.y - ImgBuffer.Size.y / 2) / PANBACK_STEPS

            Let Dodu.IsWalking = FALSE
            SoundPlayer_PlayEffect Audio, SND_UNDO

        Else

            ' No applicable control
            Let Dodu.IsWalking = FALSE

            If Dodu.SlipDir <> 0 Then
                Ticker_Start Dodu.SlipTick
                Ticker_Tick Dodu.SlipTick
            End If

            If Ticker_IsRunning%(Dodu.SlipTick) Then

                If Dodu.SlipTick.TickCnt = 0 Then
                    Dim slipP As Point
                    Point_Set slipP, Dodu.SlipDir, 0
                    MovePlayer ImgBuffer, slipP
                End If

            Else

                Let Dodu.SlipDir = 0
                Ticker_Reset Dodu.SlipTick

            End If

        End If

        ' ---------------------------------------
        ' 9. Common animation and rendering
        ' ---------------------------------------

        RenderFrame:

        If DoduPast.InSnow And (Not Dodu.InSnow Or (DoduPast.IsWalking And Not Dodu.IsWalking And CurrentTrajectory <> TRJ_PANTING)) Then
            Initiate_Trajectory TRJ_PANTING, Dodu.ToLeft
            Let Dodu.IsPanting = TRUE
            Let Dodu.IsWalking = FALSE
        End If

        GetDoduSprite CurrentSprite(), Dodu, DoduPast

        ' Advance exactly once per game frame.
        SpriteSequence_Tick CurrentSprite(0)
        SpriteSequence_Tick CurrentSprite(1)
        SpriteSequence_Tick CurrentSprite(2)

        If Dodu.IsWalking And CurrentSprite(2).Ticker.TickCnt = 0 And _
                CurrentSprite(2).Ticker.Index Mod 2 = 0 Then
            If Dodu.InSnow Then
                SoundPlayer_PlayEffect Audio, SND_STEP_SNOW
            Else
                SoundPlayer_PlayEffect Audio, SND_STEP
            End If
        End If

        ' Draw the complete frame.
        Viewport_Clear ImgBuffer

        DrawLevel ImgBuffer, Levels(CurrentLevel), FALSE
        TickLevel Levels(CurrentLevel)
        DrawPlayer ImgBuffer, CurrentSprite()
        DrawLevel ImgBuffer, Levels(CurrentLevel), TRUE
        DrawThermometer ImgBuffer, IMG_DEPTH - 1
        DrawLevelNumber ImgBuffer, IMG_DEPTH - 1

        HighlightBlock ImgBuffer, Levels(CurrentLevel), takeP, HighlightColor&
        HighlightBlock ImgBuffer, Levels(CurrentLevel), dropP, HighlightColor&
        HighlightBlock ImgBuffer, Levels(CurrentLevel), climbP, COLOR_PINK
        Viewport_Copy ImgBuffer, MainScreen, EYE_LEFT
        Viewport_Copy ImgBuffer, MainScreen, EYE_RIGHT
        Viewport_Display MainScreen, EYE_NONE
        Viewport_Tick ImgBuffer
        Viewport_Tick MainScreen

    Loop

    GameOver:
    DoGameOver
    End

    Quit:
    SoundPlayer_StopSong Audio
    Cls
    End
End Sub

Sub DoLifSplash
    Viewport_PutSpriteSequence ImgBuffer, TRUE, LifSplash, PtOrigin, FALSE, 0
    Viewport_FadeIn MainScreen, Ceil%(0.5 * FPS)
    Viewport_Wait ImgBuffer, MainScreen, 0.7, FPS
    SpriteSequence_Start LifSplash
    SoundPlayer_PlaySong Audio, SNG_LIF
    Do
        _Limit FPS
        SpriteSequence_Tick LifSplash
        Viewport_PutSpriteSequence ImgBuffer, TRUE, LifSplash, PtOrigin, FALSE, 0
        Viewport_Copy ImgBuffer, MainScreen, EYE_LEFT
        Viewport_Copy ImgBuffer, MainScreen, EYE_RIGHT
        Viewport_Display MainScreen, EYE_NONE
    Loop Until SpriteSequence_IsFinished(LifSplash)
    Viewport_Wait ImgBuffer, MainScreen, 2, FPS
    Viewport_FadeOut MainScreen, Ceil%(0.5 * FPS)
    Viewport_Wait ImgBuffer, MainScreen, 0.5, FPS
    Viewport_Clear MainScreen
    Viewport_Display MainScreen, EYE_NONE
    SoundPlayer_StopSong Audio
End Sub

Sub DoGameOver
    SoundPlayer_StopSong Audio
    SoundPlayer_PlayEffect Audio, SND_GAMEOVER
    'Cls
    Dim pw As Password
    GetPassword pw, CurrentLevel, LastMittens, LastTuque
    Viewport_PutSpriteSequence ImgBuffer, TRUE, Veil, PtOrigin, FALSE, 1
    Viewport_Print ImgBuffer, "GAME OVER", PtOrigin, 2
    Dim x As Integer, pws As String, cardP As Point
    For x = 0 To 3
        Point_Set cardP, 6 + x * 17, 20
        DisplayCard ImgBuffer, TRUE, cardP, pw.Elements(x)
    Next
    Viewport_Copy ImgBuffer, MainScreen, EYE_LEFT
    Viewport_Copy ImgBuffer, MainScreen, EYE_RIGHT
    Viewport_Display MainScreen, EYE_NONE
    Do
        _Limit FPS
    Loop While Not _KeyDown(KEY_ESC)
End Sub

Sub DoCutScene (nb As Integer)

    Viewport_Reset ImgBuffer
    Viewport_Reset MainScreen
    Viewport_SetBackground ImgBuffer, CutScenes(nb), PtOrigin
    Viewport_Clear ImgBuffer
    Viewport_Copy ImgBuffer, MainScreen, EYE_LEFT
    Viewport_Copy ImgBuffer, MainScreen, EYE_RIGHT

    '_PrintMode _KeepBackground , ImgBuffer.Buffer
    Viewport_FadeIn MainScreen, Ceil%(0.5 * FPS)
    'Screen MainScreen.Buffer

    SoundPlayer_PlaySong Audio, SNG_CUTSCENE1

    Dim ps As Ticker
    Ticker_Init ps, 7, FPS, FALSE
    Viewport_Start ImgBuffer
    Viewport_Start MainScreen
    Viewport_Wait ImgBuffer, MainScreen, 0.7, FPS
    Do
        _Limit FPS
        Ticker_Tick ps
        Viewport_Clear ImgBuffer
        Viewport_Tick ImgBuffer
        Viewport_Copy ImgBuffer, MainScreen, EYE_LEFT
        Viewport_Copy ImgBuffer, MainScreen, EYE_RIGHT
        Viewport_Display MainScreen, EYE_NONE
        If IsEsc% Or IsEnter% Then
            Exit Do
        End If
    Loop Until Ticker_IsFinished(ps)
    Viewport_FadeOut MainScreen, Ceil%(0.5 * FPS)
    Viewport_Wait ImgBuffer, MainScreen, 0.5, FPS
    Viewport_Clear ImgBuffer
    Viewport_Clear MainScreen
    Viewport_Display MainScreen, EYE_NONE
End Sub

Sub DoMiniMap
    Dim MapBuffer As Viewport
    Dim ws As Point
    Point_Set ws, Levels(CurrentLevel).Width * MINI_BLOCK_SIZE, Levels(CurrentLevel).Height * MINI_BLOCK_SIZE
    Viewport_Init_Default MapBuffer, ScreenDims, ws, IMG_DEPTH
    Viewport_SetBackground MapBuffer, Backgrounds(Levels(CurrentLevel).Background), PtOrigin
    Viewport_Clear MapBuffer
    DrawMinimap MapBuffer, Levels(CurrentLevel%)
    Viewport_Copy MapBuffer, MainScreen, EYE_LEFT
    Viewport_Copy MapBuffer, MainScreen, EYE_RIGHT
    Viewport_Display MainScreen, EYE_NONE

    ' Wait until key is released
    Kbd_WaitRelease FPS
    Do
        _Limit FPS
        Viewport_Display MainScreen, EYE_NONE
        If _KeyDown(KEY_LEFT) Then
            Let MapBuffer.Pan.x = MapBuffer.Pan.x - 2
        ElseIf _KeyDown(KEY_RIGHT) Then
            Let MapBuffer.Pan.x = MapBuffer.Pan.x + 2
        ElseIf _KeyDown(KEY_UP) Then
            Let MapBuffer.Pan.y = MapBuffer.Pan.y - 2
        ElseIf _KeyDown(KEY_DOWN) Then
            Let MapBuffer.Pan.y = MapBuffer.Pan.y + 2

        ElseIf _KeyDown(KEY_M_UC) Or _KeyDown(KEY_M_LC) Or _KeyDown(KEY_ESC) Then
            Exit Do
        End If
        Viewport_Clear MapBuffer
        DrawMinimap MapBuffer, Levels(CurrentLevel%)
        Viewport_Copy MapBuffer, MainScreen, EYE_NONE
    Loop
    Kbd_WaitRelease FPS
End Sub

Sub DoPause
    Dim p As Point
    Point_Set p, 30, 24
    Viewport_Print ImgBuffer, " PAUSE ", p, 0
    Viewport_Copy ImgBuffer, MainScreen, EYE_NONE
    Viewport_Display MainScreen, EYE_NONE

    ' Wait for the SPACE that invoked us to be released
    Dim k As Long
    Do
        _Limit FPS
        k = _KeyHit
    Loop While k <> KEY_SPACE
End Sub
' --------------------------
' Ticks animations
' --------------------------
Sub TickLevel (m As LevelMap)
    Dim col As Integer, row As Integer, layer As Integer
    For layer = 0 To IMG_DEPTH - 1
        For col = 0 To m.Width - 1
            For row = 0 To m.Height - 1
                SpriteSequence_Tick SpriteLevel(layer, col, row)
            Next
        Next
    Next
End Sub

Sub PrepareLevel (m As LevelMap, isfront As Integer)
    Dim col, row As Integer, layer As Integer
    For layer = 0 To IMG_DEPTH - 1
        For row = 0 To m.Height
            For col = 0 To m.Width
                Let SpriteLevel(layer, col, row).Content = -1
            Next
        Next
        For row = 0 To m.Height
            For col = 0 To m.Width
                Dim s As Square
                Let s.col = col
                Let s.row = row
                SetSpriteSquare m, layer, col, row, m.Topo(col, row)
            Next
        Next
    Next
End Sub


' --------------------------
' Draws a level
' --------------------------
Sub DrawLevel (v As Viewport, m As LevelMap, isfront As Integer)

    Dim col, row As Integer, layer As Integer
    For layer = 0 To IMG_DEPTH - 1
        For row = m.Height To 0 Step -1
            For col = 0 To m.Width
                Dim s As Square
                Let s.col = col
                Let s.row = row
                If SpriteLevel(layer, col, row).Content <> -1 Then
                    Dim p As Point
                    Square_ToPoint s, p
                    Viewport_PutSpriteSequence v, FALSE, SpriteLevel(layer, col, row), p, FALSE, layer
                End If
            Next
        Next
    Next
End Sub

Sub PrepareSnow (m As LevelMap, col As Integer, row As Integer, hasrackets As Integer)
    Select Case GetSnowSlopeAt(col, row, m)
        Case SLOPE_NONE
            SpriteSequence_Copy SpriteLevel(DEPTH_SNOW_FRONT, col, row), SprLevel(LVL_SNOW_M)
        Case SLOPE_C
            SpriteSequence_Copy SpriteLevel(DEPTH_SNOW_FRONT, col, row), SprLevel(LVL_SNOW_C)
        Case SLOPE_L
            SpriteSequence_Copy SpriteLevel(DEPTH_SNOW_FRONT, col, row), SprLevel(LVL_SNOW_L)
        Case SLOPE_R
            SpriteSequence_Copy SpriteLevel(DEPTH_SNOW_FRONT, col, row), SprLevel(LVL_SNOW_R)
    End Select
    SpriteSequence_Stop SpriteLevel(DEPTH_SNOW_FRONT, col, row)
    Let SpriteLevel(DEPTH_SNOW_FRONT, col, row).OnEnd = SPSQ_RESET
    Let SpriteLevel(DEPTH_SNOW_FRONT, col, row).Ticker.Loop = FALSE
End Sub

Sub DrawMinimap (v As Viewport, m As LevelMap)
    Dim col, row As Integer
    For row = 0 To m.Height
        For col = 0 To m.Width
            Dim s As Square
            Let s.col = col
            Let s.row = row
            Dim p As Point
            Point_Set p, s.col * 5, s.row * 5
            Select Case m.Topo(col, row)
                Case TILE_BLOCK_B
                    Viewport_PutSpriteSequence v, FALSE, SprMinimap(LVL_BLOCK_B), p, FALSE, 0
                Case TILE_BLOCK_W
                    Viewport_PutSpriteSequence v, FALSE, SprMinimap(LVL_BLOCK_W), p, FALSE, 0
                Case TILE_POLE
                    Viewport_PutSpriteSequence v, FALSE, SprMinimap(LVL_POLE), p, FALSE, 0
                Case TILE_COOKIE
                    Viewport_PutSpriteSequence v, FALSE, SprMinimap(LVL_COOKIE), p, FALSE, 0
                Case TILE_COFFEE
                    Viewport_PutSpriteSequence v, FALSE, SprMinimap(LVL_COFFEE), p, FALSE, 0
                Case TILE_WATER
                    Viewport_PutSpriteSequence v, FALSE, SprMinimap(LVL_WATER), p, FALSE, 0
                Case TILE_SNOW
                    Viewport_PutSpriteSequence v, FALSE, SprMinimap(LVL_SNOW), p, FALSE, 0
            End Select
        Next
    Next
    Dim dod_s As Square
    Let dod_s.col = Dodu.LevPos.x \ BLOCK_SIZE
    Let dod_s.row = Dodu.LevPos.y \ BLOCK_SIZE
    Dim dod_p As Point
    Point_Set dod_p, dod_s.col * MINI_BLOCK_SIZE, (dod_s.row + 1) * MINI_BLOCK_SIZE
    Viewport_PutSpriteSequence v, FALSE, SprMinimap(LVL_PLAYER), dod_p, FALSE, 0
End Sub


' --------------------------
' Player drawing
' --------------------------
Sub DrawPlayer (v As Viewport, seqs() As SpriteSequence)
    Dim s As SpriteSequence
    Viewport_PutSpriteSequence v, FALSE, seqs(0), Dodu.LevPos, seqs(0).Flipped, DEPTH_PLAYER
    Viewport_PutSpriteSequence v, FALSE, seqs(1), Dodu.LevPos, seqs(1).Flipped, DEPTH_PLAYER
    Viewport_PutSpriteSequence v, FALSE, seqs(2), Dodu.LevPos, seqs(2).Flipped, DEPTH_PLAYER
End Sub


Sub ClearSpriteSquare (s As Square)
    Let SpriteLevel(DEPTH_LEVEL, s.col, s.row).Content = -1
End Sub

Sub SetSpriteSquare (m As LevelMap, isfront As Integer, col As Integer, row As Integer, e As String)
    If Not isfront Then
        Select Case e
            Case TILE_BLOCK_B
                SpriteSequence_Copy SpriteLevel(DEPTH_LEVEL, col, row), SprLevel(LVL_BLOCK_B)
            Case TILE_BLOCK_W
                SpriteSequence_Copy SpriteLevel(DEPTH_LEVEL, col, row), SprLevel(LVL_BLOCK_W)
            Case TILE_POLE
                SpriteSequence_Copy SpriteLevel(DEPTH_POLE, col, row), SprLevel(LVL_POLE)
            Case TILE_COOKIE
                SpriteSequence_Copy SpriteLevel(DEPTH_LEVEL, col, row), SprLevel(LVL_COOKIE)
            Case TILE_COFFEE
                SpriteSequence_Copy SpriteLevel(DEPTH_LEVEL, col, row), SprLevel(LVL_COFFEE)
            Case TILE_MITTENS
                SpriteSequence_Copy SpriteLevel(DEPTH_LEVEL, col, row), SprMittens
            Case TILE_TUQUE
                SpriteSequence_Copy SpriteLevel(DEPTH_LEVEL, col, row), SprTuque
            Case TILE_WATER
                SpriteSequence_Copy SpriteLevel(DEPTH_WATER, col, row), SprLevel(LVL_WATER)
            Case TILE_SNOW
                PrepareSnow m, col, row, Dodu.HasRackets
            Case TILE_ROPE
                PrepareRope m, col, row
        End Select
    Else
        If e = TILE_SNOW And Not Dodu.HasRackets Then
            PrepareSnow m, col, row, TRUE
        End If
    End If
End Sub

Sub PrepareRope (m As LevelMap, col As Integer, row As Integer)
    If (row < MAP_HEIGHT - 1 _AndAlso m.Topo(col, row + 1) <> TILE_ROPE) _OrElse row = MAP_HEIGHT - 1 Then
        SpriteSequence_Copy SpriteLevel(DEPTH_ROPE, col, row), SprLevel(LVL_ROPE_E)
    Else
        SpriteSequence_Copy SpriteLevel(DEPTH_ROPE, col, row), SprLevel(LVL_ROPE_M)
    End If
    If row > 0 _AndAlso m.Topo(col, row - 1) = TILE_ROPE Then
        SpriteSequence_Copy SpriteLevel(DEPTH_ROPE, col, row - 1), SprLevel(LVL_ROPE_M)
    End If
End Sub

Sub DropBlock (m As LevelMap, p As Square)
    Let m.Topo(p.col, p.row) = TILE_BLOCK_W
    SetSpriteSquare m, FALSE, p.col, p.row, TILE_BLOCK_W
    Let Dodu.HasBlock = FALSE
End Sub

Sub MovePlayer (v As Viewport, p_to As Point)
    If WalkingTicker.TickCnt <> 0 Then Exit Sub
    If p_to.x < 0 Then Dodu.ToLeft = TRUE
    If p_to.x > 0 Then Dodu.ToLeft = FALSE
    ' Otherwise, leave in its current state
    Let CurrentSprite(0).Flipped = Dodu.ToLeft
    Let CurrentSprite(1).Flipped = Dodu.ToLeft
    Let CurrentSprite(2).Flipped = Dodu.ToLeft
    Dim ScreenPos As Point
    Viewport_PointToScreen v, Dodu.LevPos, ScreenPos
    Let Dodu.LevPos.x = Dodu.LevPos.x + (p_to.x * WALKING_SPEED)
    Let Dodu.LevPos.y = Dodu.LevPos.y + (p_to.y * WALKING_SPEED)
    If p_to.x <> 0 Then
        Select Case Dodu.ToLeft
            Case FALSE ' Going right, x > 0
                If ScreenPos.x >= ScreenDims.x - (ScreenDims.x / 3 + PLAYER_WIDTH) Then
                    'Let v.Pan.x = _Min(v.Pan.x + (p_to.x * WALKING_SPEED#), M_W% * BLOCK_SIZE%)
                    Viewport_MovePan v, p_to
                End If
            Case TRUE ' Going left, x < 0
                If ScreenPos.x <= ScreenDims.x / 3 Then
                    Viewport_MovePan v, p_to
                End If
        End Select
    End If
    If p_to.y > 0 Then '   Going down, y > 0
        If ScreenPos.y >= ScreenDims.y - (ScreenDims.y / 3 + PLAYER_HEIGHT) Then
            Viewport_MovePan v, p_to
            'Let v.Pan.y = _Min(v.Pan.y + (p_to.y * WALKING_SPEED#), M_H% * BLOCK_SIZE%)
        End If
    ElseIf p_to.y < 0 Then '  Going up, y < 0
        If ScreenPos.y <= ScreenDims.y / 3 Then
            Viewport_MovePan v, p_to
        End If
    End If
End Sub

Sub HighlightBlock (v As Viewport, m As LevelMap, s As Square, c~&)
    If Square_IsValid(s) Then
        Dim p1 As Point, p2 As Point
        Square_ToPoint s, p1
        Point_Set p2, p1.x + BLOCK_SIZE - 1, p1.y + BLOCK_SIZE - 1
        Viewport_Line v, FALSE, p1, p2, c~&, TRUE, FALSE, 1
    End If
End Sub

Sub GetDoduSprite (s() As SpriteSequence, DoduNow As Player, DoduPast As Player)
    If PlayerChanged(DoduNow, DoduPast) Then
        Let s(0) = SprDodTuque(Abs(DoduNow.IsWalking), Abs(DoduNow.HasTuque))
        Let s(0).Flipped = DoduNow.ToLeft
        If Dodu.Temp < 3 Then
            Let s(1) = SprDodHead(Abs(DoduNow.IsWalking), SPR_FREEZING)
        Else
            If DoduNow.IsPanting Then
                Let s(1) = SprDodHead(SPR_NOT_WALKING, SPR_PANTING)
                Let s(1).Flipped = DoduNow.ToLeft
            ElseIf DoduNow.IsLooking Then
                Dim screenpt As Point
                Viewport_PointToScreen ImgBuffer, Dodu.LevPos, screenpt
                Let s(1) = SprDodHead(SPR_NOT_WALKING, SPR_LOOKING_THERMO)
                'If screenpt.y >= 20 Then
                '  Let s(1) = SPR_DOD_HEAD(SPR_NOT_WALKING, SPR_LOOKING_THERMO)
                'Else
                '  Let s(1) = SPR_DOD_HEAD(SPR_NOT_WALKING, SPR_LOOKING_THERMO_UP)
                'End If
                Let s(1).Flipped = DoduNow.ToLeft
                SpriteSequence_Start s(1)
            Else
                Let s(1) = SprDodHead(Abs(DoduNow.IsWalking), Abs(DoduNow.InSnow))
                Let s(1).Flipped = DoduNow.ToLeft
            End If
        End If
        Let s(2) = SprDodBody(Abs(DoduNow.IsWalking), Abs(DoduNow.HasBlock), Abs(DoduNow.HasMittens), Abs(DoduNow.IsPanting))
        Let s(2).Flipped = DoduNow.ToLeft
        Let DoduPast = DoduNow
    End If
End Sub


Sub GetDoduCenter (p As Point)
    Point_Set p, Dodu.LevPos.x + (PLAYER_WIDTH / 2), Dodu.LevPos.y + (PLAYER_HEIGHT / 2)
End Sub

Sub DisplayCard (v As Viewport, absolute As Integer, p As Point, value As Integer)
    Dim suit As Integer, nb As Integer
    Dim p1 As Point, p2 As Point
    Let suit = value \ 13
    Let nb = value Mod 13
    Viewport_PutSpriteSequence v, absolute, SprCard, p, FALSE, DEPTH_CARDS
    Point_Set p1, p.x + 5, p.y + 9
    Viewport_PutSpriteSequence v, absolute, SprCardsSuits(suit), p1, FALSE, DEPTH_CARDS
    Point_Set p2, p.x + 2, p.y + 2
    Viewport_PutSpriteSequence v, absolute, SprCardsDigits(nb), p2, FALSE, DEPTH_CARDS
End Sub

Sub DoPasswordInput (rst As RestorePoint)
    SoundPlayer_StopSong Audio
    SoundPlayer_PlaySong Audio, SNG_CARDS
    Dim PwBuffer As Viewport, ws As Point
    Point_Set ws, ScreenDims.x, 1000
    Viewport_Init_Default PwBuffer, ScreenDims, ws, IMG_DEPTH
    Viewport_Clear PwBuffer
    Dim prlx As Point
    Point_Set prlx, 2, 2
    Viewport_SetBackground PwBuffer, Backgrounds(2), prlx
    Dim x As Integer, y As Integer, p As Point, q As Point
    Dim down As Point, up As Point
    Dim coord_row As Integer, coord_col As Integer
    Dim selection(4) As Integer
    Dim selindex As Integer
    Let selindex = 0
    Let coord_row = 0
    Let coord_col = 0
    Do
        _Limit FPS

        Viewport_Clear PwBuffer
        Viewport_Tick PwBuffer

        ' Show cards
        Point_Set up, 0, -4
        Point_Set down, 0, 4
        For y = 0 To 12
            For x = 0 To 3
                Point_Set p, x * 18 + 5, y * 22
                DisplayCard PwBuffer, FALSE, p, x * 13 + y
            Next
        Next

        ' Show previously selected cards
        Dim n As Integer, scr As Integer, scc As Integer
        For n = 0 To selindex - 1
            Let scr = selection(n) Mod 13
            Let scc = selection(n) \ 13
            Point_Set p, scc * 18 + 5, scr * 22
            Point_Set q, p.x + 16, p.y + 22
            Viewport_Line PwBuffer, FALSE, p, q, ColorHighlight2, TRUE, FALSE, 1
        Next

        'Viewport_Print PwBuffer, Str$(selection(0)) + Str$(selection(1)) + Str$(selection(2)) + Str$(selection(3)), P_ORIGIN

        ' Show selected card
        Point_Set p, coord_col * 18 + 5, coord_row * 22
        Point_Set q, p.x + 16, p.y + 22
        Viewport_Line PwBuffer, FALSE, p, q, ColorHighlight, TRUE, FALSE, 1

        Viewport_Copy PwBuffer, MainScreen, EYE_NONE
        Viewport_Display MainScreen, EYE_NONE

        ReadJoystick
        Dim moves As Integer: Let moves = FALSE
        If IsDown% Then
            Let coord_row = Clamp%(coord_row + 1, 0, 12)
            SoundPlayer_PlayEffect Audio, SND_TICK
            Kbd_WaitRelease FPS
            Let moves = TRUE
        ElseIf IsUp% Then
            Let coord_row = Clamp%(coord_row - 1, 0, 12)
            SoundPlayer_PlayEffect Audio, SND_TICK
            Kbd_WaitRelease FPS
            Let moves = TRUE
        ElseIf IsLeft% Then
            Let coord_col = Clamp%(coord_col - 1, 0, 3)
            SoundPlayer_PlayEffect Audio, SND_TICK
            Kbd_WaitRelease FPS
            Let moves = TRUE
        ElseIf IsRight% Then
            Let coord_col = Clamp%(coord_col + 1, 0, 3)
            SoundPlayer_PlayEffect Audio, SND_TICK
            Kbd_WaitRelease FPS
            Let moves = TRUE
        End If
        If moves Then
            Point_Set p, coord_col * 18 + 5, coord_row * 22
            Viewport_ScrollCenter PwBuffer, p, 6
        End If
        If _KeyDown(KEY_ENTER) Then
            Let selection(selindex) = coord_col * 13 + coord_row
            Let selindex = selindex + 1
            SoundPlayer_PlayEffect Audio, SND_TACK
            Kbd_WaitRelease FPS
            If selindex = 4 Then
                Screen 0
                LookupPassword rst, selection()
                If rst.Level < 0 Then
                    SoundPlayer_PlayEffect Audio, SND_WRONG1
                Else
                    SoundPlayer_PlayEffect Audio, SND_LEVELUP
                End If
                SoundPlayer_StopSong Audio
                Exit Sub
            End If
        End If
        If _KeyDown(KEY_SPACE) Then
            SoundPlayer_StopSong Audio
            Exit Sub
        End If
    Loop
    SoundPlayer_StopSong Audio
End Sub

Sub DoIntroduction (rst As RestorePoint)

    Dim p As Point
    Let rst.Level = -1
    Dim sel As Integer, n As Integer, h As Integer
    Dim Flakes(50) As Point, downP As Point
    Dim HeightsInit(ScreenDims.x) As Integer, Heights(ScreenDims.x) As Integer
    Dim FlakesTickers(50) As Ticker, ShakeTicker As Ticker
    Ticker_Init ShakeTicker, 15, 1, TRUE
    If ScreenDims.x = SCREEN_GAMEBUINO_X Then
        Restore SplashShape_GMB:
    Else
        Restore SplashShape_PC:
    End If
    For n = 0 To ScreenDims.x
        Read h
        Let Heights(n) = h
        Let HeightsInit(n) = h
    Next
    Point_Set downP, 0, 1
    For n = 0 To 49
        Point_Set Flakes(n), Floor%(Rnd * ScreenDims.x), Floor%(Rnd * ScreenDims.y)
        Ticker_Init FlakesTickers(n), 2, Int(Rnd * 2) + 2, TRUE
    Next
    Viewport_Reset ImgBuffer
    Viewport_Reset MainScreen
    Viewport_SetBackground ImgBuffer, SplashScreen, PtOrigin
    SpriteSequence_Start SplashScreen
    SoundPlayer_PlaySong Audio, SNG_BIERE
    Dim yoffset As Integer
    Do
        _Limit FPS
        Viewport_Clear ImgBuffer
        Viewport_Clear MainScreen
        Ticker_Tick ShakeTicker
        If ShakeTicker.Index < 3 Then
            Let yoffset = 1
        Else
            Let yoffset = 0
        End If
        For n = 0 To 49
            If FlakesTickers(n).TickCnt = 0 Then
                Point_Add Flakes(n), downP
                If Heights(Flakes(n).x) >= 0 _AndAlso Flakes(n).y = Heights(Flakes(n).x) - 1 Then
                    If Flakes(n).x > 0 _AndAlso (Heights(Flakes(n).x - 1) = -1 _OrElse Heights(Flakes(n).x - 1) - Heights(Flakes(n).x) >= 3) Then
                        Let Flakes(n).x = Flakes(n).x - 1
                    ElseIf Flakes(n).x < ScreenDims.x - 1 _AndAlso (Heights(Flakes(n).x + 1) = -1 _OrElse Heights(Flakes(n).x - 1) - Heights(Flakes(n).x) >= 3) Then
                        Let Flakes(n).x = Flakes(n).x + 1
                    Else
                        Let Heights(Flakes(n).x) = Heights(Flakes(n).x) - 1
                        Point_Set Flakes(n), Int(Rnd * ScreenDims.x%), -Int(Rnd * 5)
                    End If
                End If
            ElseIf Heights(Flakes(n).x) < 0 Then
                Point_Add Flakes(n), downP
                If Flakes(n).y >= ScreenDims.y Then
                    Point_Set Flakes(n), Int(Rnd * ScreenDims.x%), -Int(Rnd * 5)
                End If
            End If
            Viewport_LineC ImgBuffer, TRUE, Flakes(n).x, Flakes(n).y + yoffset, Flakes(n).x, Flakes(n).y + yoffset, ColorSnow, FALSE, FALSE, 0
            Ticker_Tick FlakesTickers(n)
        Next
        For n = 0 To ScreenDims.x - 1
            Viewport_LineC ImgBuffer, TRUE, n, HeightsInit(n) + yoffset - 1, n, Heights(n) + yoffset, ColorSnow, TRUE, FALSE, 0
        Next
        If sel = 0 Then
            Viewport_LineC ImgBuffer, TRUE, 23, 45, 39, 56, ColorHighlight2, TRUE, FALSE, 0
        Else
            Viewport_LineC ImgBuffer, TRUE, 40, 45, 56, 56, ColorHighlight2, TRUE, FALSE, 0
        End If
        Viewport_Tick ImgBuffer
        Viewport_Copy ImgBuffer, MainScreen, EYE_LEFT
        Viewport_Copy ImgBuffer, MainScreen, EYE_RIGHT
        Viewport_Tick MainScreen
        Viewport_Display MainScreen, EYE_NONE
        If IsLeft% Or IsRight% Then
            Let sel = (sel + 1) Mod 2
            SoundPlayer_PlayEffect Audio, SND_TICK
            Kbd_WaitRelease FPS
        ElseIf IsEsc% Then
            SoundPlayer_StopSong Audio
            Cls
            End
        ElseIf IsButton1% Then
            If sel = 1 Then
                Kbd_WaitRelease FPS
                SoundPlayer_StopSong Audio
                DoPasswordInput rst
                If rst.Level < 0 Then
                    Exit Do
                Else ' Valid password
                    SoundPlayer_StopSong Audio
                    Exit Sub
                End If
            Else
                SoundPlayer_StopSong Audio
                Exit Sub
            End If
        End If
    Loop
End Sub

Sub Initiate_Trajectory (index As Integer, flipped As Integer)
    If CurrentTrajectory >= 0 Then
        Exit Sub 'Trajectory already running, ignore
    End If
    Let CurrentTrajectory = index
    Trajectory_Reset Trajectories(CurrentTrajectory)
    Trajectory_Start Trajectories(CurrentTrajectory)
    Let Trajectories(CurrentTrajectory).Flipped = flipped
End Sub

Sub Tick_Trajectory (p As Point)
    If CurrentTrajectory% >= 0 And CurrentTrajectory% < 100 Then
        Trajectory_Tick Trajectories(CurrentTrajectory), p
    End If
End Sub

' --------------------------
' Includes (implementations)
' --------------------------
'$IncludeOnce
'$Include:'Utils.bm'
'$Include:'Geometry.bm'
'$Include:'Ticker.bm'
'$Include:'Sprites.bm'
'$Include:'Fonts.bm'
'$Include:'Sounds.bm'
'$Include:'Keyboard.bm'
'$Include:'Levels.bm'
'$Include:'Gameplay.bm'
'$Include:'LevelMaps.bm'
'$Include:'Passwords.bm'
'$Include:'Assets.bm'

' :mode=visualbasic:folding=explicit:wrap=none:
