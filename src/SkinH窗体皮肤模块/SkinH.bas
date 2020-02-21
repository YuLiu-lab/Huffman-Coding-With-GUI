Attribute VB_Name = "Module1"
Public Declare Function SkinH_SetAero Lib "SkinH.dll" (ByVal hWnd As Long) As Long

Public Declare Function SkinH_Attach Lib "SkinH.dll" () As Long

Public Declare Function SkinH_AttachEx Lib "SkinH.dll" (ByVal lpSkinFile As String, ByVal lpPasswd As String) As Long

