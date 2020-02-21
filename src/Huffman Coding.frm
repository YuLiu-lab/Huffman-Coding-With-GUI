VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Huffman Coding GUI"
   ClientHeight    =   9405
   ClientLeft      =   7950
   ClientTop       =   3465
   ClientWidth     =   13260
   BeginProperty Font 
      Name            =   "宋体"
      Size            =   12
      Charset         =   134
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   9405
   ScaleWidth      =   13260
   Begin VB.TextBox Text3 
      Enabled         =   0   'False
      Height          =   735
      Left            =   10080
      MultiLine       =   -1  'True
      TabIndex        =   12
      Text            =   "Huffman Coding.frx":0000
      Top             =   7440
      Width           =   2895
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Matching"
      Height          =   735
      Left            =   2280
      TabIndex        =   10
      Top             =   8400
      Width           =   1695
   End
   Begin VB.TextBox Text2 
      Height          =   3255
      Left            =   240
      MultiLine       =   -1  'True
      TabIndex        =   9
      Text            =   "Huffman Coding.frx":0006
      Top             =   4920
      Width           =   6015
   End
   Begin VB.TextBox Text1 
      Height          =   3255
      Left            =   240
      MultiLine       =   -1  'True
      TabIndex        =   7
      Text            =   "Huffman Coding.frx":000C
      Top             =   960
      Width           =   6015
   End
   Begin VB.ListBox List2 
      Height          =   6300
      Left            =   10080
      TabIndex        =   4
      Top             =   720
      Width           =   2895
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Coding"
      Height          =   735
      Left            =   10680
      TabIndex        =   3
      Top             =   8400
      Width           =   1695
   End
   Begin VB.ListBox List1 
      Height          =   7500
      Left            =   6720
      TabIndex        =   2
      Top             =   720
      Width           =   2175
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Select File"
      Height          =   735
      Left            =   6960
      TabIndex        =   0
      Top             =   8400
      Width           =   1695
   End
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   6600
      Top             =   8520
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.Label Label5 
      Caption         =   "Decoding:"
      Height          =   495
      Left            =   9000
      TabIndex        =   11
      Top             =   7560
      Width           =   1095
   End
   Begin VB.Label Label4 
      Caption         =   "Weight:"
      Height          =   495
      Left            =   240
      TabIndex        =   8
      Top             =   4440
      Width           =   1935
   End
   Begin VB.Label Label3 
      Caption         =   "Char:"
      Height          =   495
      Left            =   240
      TabIndex        =   6
      Top             =   360
      Width           =   1935
   End
   Begin VB.Line Line1 
      X1              =   6480
      X2              =   6480
      Y1              =   120
      Y2              =   9240
   End
   Begin VB.Label Label2 
      Caption         =   "Coding result:"
      Height          =   495
      Left            =   10080
      TabIndex        =   5
      Top             =   240
      Width           =   1815
   End
   Begin VB.Label Label1 
      Caption         =   "Weight value："
      Height          =   495
      Left            =   6720
      TabIndex        =   1
      Top             =   240
      Width           =   2055
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim filePath, dirPath As String 'filePath为选择的文件路径，dirPath为选择的文件所在目录的路径
Dim chars(1 To 100) As String
Dim weights(1 To 100) As Integer
Dim results(1 To 100) As String
Dim charsCnt, weightsCnt As Integer
Dim isMatched As Boolean
'实现检测调用是否完成
Private Declare Function OpenProcess Lib "kernel32" (ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Long, ByVal dwProcessId As Long) As Long
Private Declare Function GetExitCodeProcess Lib "kernel32" (ByVal hProcess As Long, lpExitCode As Long) As Long
Private Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long
Const PROCESS_QUERY_INFORMATION = &H400
Const STILL_ALIVE = &H103

Private Sub Command1_Click()
'如果从源码直接运行，请复制Huffman Coding.exe到选择的txt文件目录下，否则无法调用
Dim length, i As Integer
CommonDialog1.ShowOpen
filePath = CommonDialog1.FileName
For pos = Len(filePath) To 1 Step -1
    If (Mid(filePath, pos, 1) = "\") Then
        Exit For
    End If
Next pos
dirPath = Mid(filePath, 1, pos)
End Sub

Private Sub Command2_Click()
Dim pid 'pid储存进程句柄，用于判断是否运行结束
Dim countPath, codePath, s As String
If Not isMatched Then
    pid = Shell(App.Path + "\Huffman Coding.exe " + filePath, 1)
    '等待调用的程序执行完成
    hProcess = OpenProcess(PROCESS_QUERY_INFORMATION, 0, pid)
    Do
        Call GetExitCodeProcess(hProcess, ExitCode)
        DoEvents
    Loop While ExitCode = STILL_ALIVE
    Call CloseHandle(hProcess)
    MsgBox ("编码完成！")
    countPath = dirPath + "data.txt"
    codePath = dirPath + "coding result.txt"
    List1.Clear
    List2.Clear
    charsCnt = 0
    weightsCnt = 0
    '向list1中输出字符和出现次数
    Open countPath For Input As #1
        Do While Not EOF(1)
        Line Input #1, textline
        charsCnt = charsCnt + 1
        List1.AddItem textline
    Loop
    Close #1
    '向list2中输出字符和编码结果
    Open codePath For Input As #1
    Do While Not EOF(1)
        Line Input #1, textline
        weightsCnt = weightsCnt + 1
        Dim temppos As Integer
        temppos = InStr(1, textline, " ") + 1
        chars(weightsCnt) = Mid(textline, 1, temppos - 1)
        results(weightsCnt) = Mid(textline, temppos, Len(textline) - pos)
        List2.AddItem textline
    Loop
    Close #1
    Text3.Text = ""
    Text3.Enabled = True
    isMatched = False
Else
    pid = Shell(App.Path + "\Huffman Coding.exe temp.txt", 1)
    '等待调用的程序执行完成
    hProcess = OpenProcess(PROCESS_QUERY_INFORMATION, 0, pid)
    Do
        Call GetExitCodeProcess(hProcess, ExitCode)
        DoEvents
    Loop While ExitCode = STILL_ALIVE
    Call CloseHandle(hProcess)
    MsgBox ("编码完成！")
    countPath = dirPath + "data.txt"
    codePath = dirPath + "coding result.txt"
    List2.Clear
    '向list2中输出字符和编码结果
    Open codePath For Input As #1
    Do While Not EOF(1)
        Line Input #1, textline
        List2.AddItem textline
    Loop
    Close #1
    Text3.Text = ""
    Text3.Enabled = True
    isMatched = False
    Kill App.Path + "\temp.txt"
End If
End Sub

Private Sub Command3_Click()
List1.Clear
List2.Clear
Dim length1, length2, spacePos, spacePos_next As Integer
Dim char As String
length1 = Len(Text1.Text)
length2 = Len(Text2.Text)
weightsCnt = 0
spacePos = 1
spacePos_next = InStr(spacePos, Text2.Text, " ", 1)
If length1 = 0 Or length2 = 0 Then
    MsgBox "某项未输入", vbCritical, "错误"
Else
    Do While (spacePos_next < length2) '把权值存入数组weights
        weightsCnt = weightsCnt + 1
        weights(weightsCnt) = Int(Mid(Text2.Text, spacePos, spacePos_next - spacePos))
        spacePos = spacePos_next + 1
        spacePos_next = InStr(spacePos, Text2.Text, " ", 1)
        If spacePos_next = 0 Then Exit Do
    Loop
    weightsCnt = weightsCnt + 1
    weights(weightsCnt) = Int(Mid(Text2.Text, spacePos, length2))
    '把字符存入数组chars
    char = Replace(Text1.Text, " ", "")
    spacePos = InStr(1, Text1.Text, "space")
    Dim temppos As Integer
    charsCnt = 1
    For temppos = 1 To length1
        If temppos = spacePos Then
            chars(charsCnt) = "space"
            temppos = temppos + 4
        Else
            chars(charsCnt) = Mid(char, temppos, 1)
        End If
        If charsCnt > weightsCnt Then Exit For
        charsCnt = charsCnt + 1
    Next temppos
End If
charsCnt = charsCnt - 1
If (charsCnt = weightsCnt) Then
    Dim i As Integer
    temppath = App.Path + "\temp.txt"
    Open temppath For Output As #1
    For temppos = 1 To charsCnt
        For i = 1 To weights(temppos)
            If chars(temppos) = "space" Then
                Print #1, " ";
            Else
                Print #1, chars(temppos);
            End If
        Next i
        List1.AddItem chars(temppos) + " " + Str(weights(temppos))
    Next temppos
    Close #1
    isMatched = True
Else
    MsgBox "个数不匹配", vbCritical, "错误"
    Kill App.Path + "\temp.txt"
End If

End Sub


Private Sub Form_LinkClose()
Dim fs As New filesystemobject
If fs.FileExists(App.Path + "\temp.txt") Then Kill App.Path + "\temp.txt"
End Sub

Private Sub Form_Load()
Text1.Text = "Please enter characters separated by space." & vbCrLf & "Sample:" & vbCrLf & "space A B C D E F G H I J K L M"
Text2.Text = "Please enter weights separated by space." & vbCrLf & "Sample:" & vbCrLf & "186 64 13 22 32 103 21 15 47 57 1 5 32 20"
Text3.Text = "Uncoded."
Text3.Enabled = False
SkinH_AttachEx App.Path & "\aero.she", ""
CommonDialog1.Filter = "TXT文件 (*.txt)|*.txt"
End Sub

Private Sub Text1_Change()
s1 = Text1.Text
End Sub

Private Sub Text2_Change()
s2 = Text2.Text
End Sub

Private Sub Text3_Change()
If Text3.Enabled = True Then
    Dim i, pos As Integer
    Dim s As String
    For i = 0 To weightsCnt - 1
        s = List2.List(i)
        pos = InStr(1, s, " ") + 1
        If pos > 0 Then
            If Mid(s, pos, Len(s)) = Text3.Text Then
                List2.Selected(i) = True
                Exit For
            End If
        End If
    Next i
End If

End Sub
