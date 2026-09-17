' Max height/width of a level
Const M_W = 30
Const M_H = 30

' Symbols designating level tiles
Const T_NOTHING = " "
Const T_BLOCK_B = "@"
Const T_BLOCK_W = "#"
Const T_POLE = "!"
Const T_COOKIE = "*"

Type Square
  col As Integer
  row As Integer
End Type

Type LevelMap
  Width As Integer
  Height As Integer
  Topo(M_W, M_H) As String
  StartPoint As Square
  PanX As Integer
  PanY As Integer
End Type

Declare Function IsGoalAt (col As Integer, row As Integer, l As LevelMap)
Declare Function IsBlockAt (col As Integer, row As Integer, l As LevelMap)
Declare Function IsWhiteBlockAt (col As Integer, row As Integer, l As LevelMap)
Declare Function IsObstacleAt (col As Integer, row As Integer, l As LevelMap)
Declare Sub LoadLevel (l As LevelMap)
Declare Sub PrintLevel (m As LevelMap)