' DependsOn: 'Sprites.bi'

Const IMG_DIR$ = "/home/sylvain/Workspaces/dodu/Source/images"

Dim Shared CharSprites(1) As Sprite
Dim DEFAULT_OFFSET As Point
Let DEFAULT_OFFSET = P_ORIGIN

' Character
Sprite_Load CharSprites(0), IMG_DIR$ + "/Dodu_right_0.png", DEFAULT_OFFSET

' Blocks
Dim Shared BlockBlue As Sprite
Sprite_Load BlockBlue, IMG_DIR$ + "/BlockBlue.gif", DEFAULT_OFFSET
Dim Shared BlockWhite As Sprite
Sprite_Load BlockWhite, IMG_DIR$ + "/Block_white.gif", DEFAULT_OFFSET

' Goal post
Dim Shared Pole As Sprite
Dim PoleOffset As Point
Point_Set PoleOffset, 1, -9
Sprite_Load Pole, IMG_DIR$ + "/Pole.gif", PoleOffset

' Thermometer
Dim Shared Thermometer As Sprite
Sprite_Load Thermometer, IMG_DIR$ + "/Thermometer.gif", DEFAULT_OFFSET
Const THERMO_RED~& = _RGB32(170, 0, 0)

' Background
Dim Shared Background As Sprite
Sprite_Load Background, IMG_DIR$ + "/Background.gif", DEFAULT_OFFSET

' Other constants
Const PLAYER_HEIGHT% = 33
Const PLAYER_WIDTH% = 19
Const BLOCK_SIZE% = 11

' :mode=visualbasic: