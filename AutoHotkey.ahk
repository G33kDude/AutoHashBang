RegKey = AutoHotkeyScript\Shell\Open\Command

Params := []
loop, %0%
	Params[A_Index] := %A_Index%

if !Params.MaxIndex()
{
	if !A_IsAdmin
		RunAs(Params*)
	MsgBox, 52, , Are you sure you want to install AutoHashBang?
	IfMsgBox, Yes
		RegWrite, REG_SZ, HKCR, %RegKey%,, "%A_AhkPath%" "%A_ScriptFullPath%" "`%1" `%*
	ExitApp
}

FilePath := Params[1]

if (FilePath == A_ScriptFullPath)
{
	if !A_IsAdmin
		RunAs(Params*)
	MsgBox, 52, , Are you sure you want to uninstall AutoHashBang?
	IfMsgBox, Yes
		RegWrite, REG_SZ, HKCR, %RegKey%,, "%A_AhkPath%" "`%1" `%*
	ExitApp
}

File := FileOpen(FilePath, "r").Read()
if RegExMatch(File, "^\s*`;#!\s*(.+)", Match)
	AhkPath := Trim(Match1)
else
	AhkPath := A_AhkPath
Run(AhkPath, Params*)

RunAs(Params*)
{
	Params.Verb := "*RunAs"
	Run(A_AhkPath, A_ScriptFullPath, Params*)
	ExitApp
}

Run(Params*)
{
	RunStr := Params.Verb
	for Key, Param in Params
	{
		if (Key != A_Index)
			Break
		Param := RegExReplace(Param, "(\\*)""", "$1$1\""")
		RunStr .= " """ Param """"
	}
	Run, % Trim(RunStr)
}