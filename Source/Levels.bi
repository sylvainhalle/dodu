'$IncludeOnce

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
	col AS Integer
	row AS Integer
End Type

Type LevelMap
  Width As Integer
  Height As Integer
  Topo(M_W, M_H) As String
  StartPoint as Square
  PanX As Integer
  PanY As Integer
End Type

Function IsBlockAt (col As Integer, row As Integer, l As LevelMap)
	if l.Topo(col,row) = T_BLOCK_B Or l.Topo(col,row) = T_BLOCK_W then
		let IsBlockAt = TRUE
	else
		let IsBlockAt = FALSE
	end if
End Function

' --------------------------
' Loads a level
' --------------------------
Sub LoadLevel (l As LevelMap)
  Dim w As Integer, h As Integer
  Dim sx As Integer, sy As Integer
  Read h
  Read w
  Read sx
  Read sy
  Let l.Width = w
  Let l.Height = h
  Let l.StartPoint.col = sx
  Let l.Startpoint.row = sy
  Dim col, row As Integer
  Dim b As String
  For row = 1 To h
    For col = 1 To w
      Read b
      Let l.Topo(col - 1, row - 1) = b
    Next
  Next
End Sub


' --------------------------
' Prints a level as characters onscreen
' --------------------------
Sub PrintLevel (m As LevelMap)
  Dim i, j As Integer
  For i = 1 To m.Height
    For j = 1 To m.Width
      Locate i, j
      Print m.Topo(i - 1, j - 1)
    Next
    Print
  Next
End Sub


' :mode=visualbasic:
