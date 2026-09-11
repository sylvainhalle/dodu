'$IncludeOnce

' Max height/width of a level
Const M_W = 30
Const M_H = 30

Type LevelMap
  Width As Integer
  Height As Integer
  Topo(M_H, M_W) As String
  StartPointX As Integer
  StartpointY As Integer
  PanX As Integer
  PanY As Integer
End Type

' --------------------------
' Loads a level
' --------------------------
Sub LoadLevel (l As LevelMap)
  Dim w As Integer, h As Integer
  Read h
  Read w
  Let l.Width = w
  Let l.Height = h
  Dim i, j As Integer
  Dim b As String
  For i = 1 To h
    For j = 1 To w
      Read b
      Let l.Topo(i - 1, j - 1) = b
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
      If m.Topo(i - 1, j - 1) = "@" Then Print "@"
    Next
    Print
  Next
End Sub


' :mode=visualbasic:
