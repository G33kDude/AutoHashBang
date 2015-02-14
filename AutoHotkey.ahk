#NoEnv
SetBatchLines, -1
#NoTrayIcon

Params := []
loop, %0%
	Params[A_Index] := %A_Index%

if !Params.MaxIndex()
{
	Elevate(Params)
	MsgBox, 52,, Are you sure you want to install AutoHashBang?
	IfMsgBox, Yes
		Install()
}
else if (Params[1] == A_ScriptFullPath)
{
	Elevate(Params)
	MsgBox, 52,, Are you sure you want to uninstall AutoHashBang?
	IfMsgBox, Yes
		Uninstall()
}
else
{
	AhkPath := DeHashBang(Params[1])
	if (GetSubSystem(AhkPath) == 3) ; Console
		RunWait, % MakeRun(AhkPath, Params*)
	else
		Run, % MakeRun(AhkPath, Params*)
}
ExitApp

Elevate(Params)
{
	if !A_IsAdmin
	{
		Run, % "*RunAs " MakeRun(A_AhkPath, A_ScriptFullPath, Params*)
		ExitApp
	}
}

DeHashBang(FilePath)
{
	FileRead, Script, %FilePath%
	if RegExMatch(Script, "`a)^\s*`;#!\s*(.+)", Match)
	{
		AhkPath := Trim(Match1)
		Vars := {"%A_ScriptDir%": FilePath "\.."
		, "%A_AppData%": A_AppData
		, "%A_AppDataCommon%": A_AppDataCommon
		, "%A_LineFile%": FilePath
		, "%A_AhkPath%": A_AhkPath}
		for SearchText, Replacement in Vars
			StringReplace, AhkPath, AhkPath, %SearchText%, %Replacement%, All
		return AhkPath
	}
	return A_AhkPath
}

Install()
{
	SplitPath, A_AhkPath,, AhkDir
	FileCopy, %A_AhkPath%, %AhkDir%\AutoHotConsole.exe, 1
	Sleep, 100 ; Just to be safe
	SetSubSystem(AhkDir "\AutoHotConsole.exe", 3)
	
	ahk = "%A_AhkPath%" "%A_ScriptFullPath%" "`%1" `%*
	ahc = "%AhkDir%\AutoHotConsole.exe" "%A_ScriptFullPath%" "`%1" `%*
	
	Registry := {".ahc": "AutoHotConsoleScript"
	, "AutoHotConsoleScript": "AHC Script"
	, "AutoHotConsoleScript\DefaultIcon": "C:\Program Files\AutoHotkey\AutoHotkey.exe,1"
	, "AutoHotConsoleScript\Shell": "Open"
	, "AutoHotConsoleScript\Shell\Open": "Run Script"
	, "AutoHotConsoleScript\Shell\Open\Command": ahc
	, "AutoHotkeyScript\Shell\Open\Command": ahk}
	
	for SubKey, Value in Registry
		RegWrite, REG_SZ, HKCR, %SubKey%,, %Value%
}

Uninstall()
{
	FileDelete, %A_AhkPath%\..\AutoHotConsole.exe
	RegDelete, HKCR, .ahc
	RegDelete, HKCR, AutoHotConsoleScript
	RegWrite, REG_SZ, HKCR, AutoHotkeyScript\Shell\Open\Command,, "%A_AhkPath%" "`%1" `%*
}

SetSubSystem(FilePath, SubSystem=0)
{
	exe := FileOpen(FilePath, "rw")
	if (exe.ReadUShort() != 0x5A4D)
		throw Exception("Bad exe file: no DOS sig")
	exe.Seek(60), offset := exe.ReadInt()
	exe.Seek(offset)
	if (exe.ReadUInt() != 0x4550)
		throw Exception("Bad exe file: no NT sig")
	exe.Seek(offset + 92)
	if !SubSystem
	{
		SubSystem := exe.ReadUShort() ^ 1
		exe.Seek(offset + 92)
	}
	exe.WriteUShort(SubSystem)
	return SubSystem
}

GetSubSystem(FilePath)
{
	exe := FileOpen(FilePath, "r")
	if (exe.ReadUShort() != 0x5A4D)
		throw Exception("Bad exe file: no DOS sig")
	exe.Seek(60), offset := exe.ReadInt()
	exe.Seek(offset)
	if (exe.ReadUInt() != 0x4550)
		throw Exception("Bad exe file: no NT sig")
	exe.Seek(offset + 92)
	return exe.ReadUShort()
}

MakeRun(Params*)
{
	for Key, Param in Params
		RunStr .= """" RegExReplace(Param, "(\\*)""", "$1$1\""") """ "
	return RunStr
}