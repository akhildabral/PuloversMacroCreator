﻿LV_Export(ListID)
{
	local LVData, Id_LVData, Indent, RowData, Action, Match, ExpValue
	, Step, TimesX, DelayX, Type, Target, Window, Comment, sArray
	, PAction, PType, PDelayX, PComment, Act, iCount, init_ie, ComExp
	, VarsScope, FuncParams, IsFunction := false, CommentOut := false
	Gui, chMacro:Default
	Gui, chMacro:ListView, InputList%ListID%
	ComType := ComCr ? "ComObjCreate" : "ComObjActive"
	Loop, % LV_GetCount()
	{
		LV_GetTexts(A_Index, Action, Step, TimesX, DelayX, Type, Target, Window, Comment)
	,	IsChecked := LV_GetNext(A_Index-1, "Checked")
		If (InStr(FileCmdList, Type "|"))
			Step := StrReplace(Step, "```,", "`,")
		If (Type = cType1)
		{
			If (InStr(Step, "``n"))
			{
				Step := StrReplace(Step, "``n", "`n")
			,	Step := "`n(LTrim`n" Step "`n)"
			}
			If !(Send_Loop)
			{
				If (((TimesX > 1) || InStr(TimesX, "%")) && (Action != "[Text]"))
					Step := RegExReplace(Step, "{\w+\K(})", " " TimesX "$1")
				If (DelayX = 0)
				{
					LV_GetText(PAction, A_Index-1, 2)
				,	LV_GetText(PType, A_Index-1, 6)
				,	LV_GetText(PDelayX, A_Index-1, 5)
				,	LV_GetText(PComment, A_Index-1, 9)
					If (PType != Type)
						f_SendRow := A_Index
					IsPChecked := LV_GetNext(f_SendRow-1, "Checked")
					LV_GetText(NChecked, IsPChecked, 6)
					If ((f_SendRow != IsPChecked) && (PType != Type)
					&& (NChecked = Type))
						LVData .= "`n" Type ", "
					If ((Type = PType) && (PDelayX = 0) && (PComment = "")
					&& !InStr(Action, "[Text]") && (PAction != "[Text]"))
						RowData := Step
					Else
						RowData := "`n" Type ", " Step
				}
				Else
					RowData := "`n" Type ", " Step
				RowData := Add_CD(RowData, Comment, DelayX)
				If ((Action = "[Text]") && (TimesX > 1))
					RowData := "`nLoop, " TimesX "`n{" RowData "`n}"

			}
			Else
			{
				RowData := "`n" Type ", " Step
			,	RowData := Add_CD(RowData, Comment, DelayX)
				If ((TimesX > 1) || InStr(TimesX, "%"))
					RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
			}
		}
		If ((IsChecked != A_Index) && (!CommentUnchecked))
			continue
		If (Type = cType48)
		{
			If (IsChecked != A_Index)
				continue
			FuncParams .= LTrim(Target " " Step ", "), RowData := ""
		}
		Else If (Type = cType47)
		{
			IsFunction := true
		,	RowData := "`n" Step "(" RTrim(FuncParams, ", ") ")"
			If (Comment != "")
				RowData .= "  " "; " Comment
			RowData .= "`n{"
			StringSplit, FuncVariables, Window, /, %A_Space%
			If (FuncVariables1 != "")
				RowData .= "`n" ((Target = "Local") ? "Global " : "Local ") . StrReplace(FuncVariables1, """")
			Else If (Target = "Global")
				RowData .= "`nGlobal"
			If (FuncVariables2 != "")
				RowData .= "`n" "Static " . StrReplace(FuncVariables2, """")
		}
		Else If (Type = cType49)
			RowData := "`nReturn " Step
		Else If ((Type = cType2) || (Type = cType9) || (Type = cType10))
		{
			If (InStr(Step, "``n"))
			{
				Step := StrReplace(Step, "``n", "`n")
			,	Step := "`n(LTrim`n" Step "`n)"
			}
			If (((TimesX > 1) || InStr(TimesX, "%")) && (Action != "[Text]"))
				Step := RegExReplace(Step, "{\w+\K(})", " " TimesX "$1")
			RowData := "`n" Type ", " Target ", " Step ", " Window
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If (TimesX > 1 || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType4)
		{
			RowData := "`n" Type ", " Target ", " Window ",, " Step
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType5)
		{
			RowData := "`n" Type ", " DelayX
			If (Comment != "")
				RowData .= "  " "; " Comment
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType6)
		{
			If (InStr(Step, "``n"))
			{
				Step := StrReplace(Step, "``n", "`n")
				Step := "`n(LTrim`n" Step "`n)"
			}
			Step := StrReplace(Step, "```,", "`````,")
		,	Window := StrReplace(Window, "```,", "`````,")
		,	RowData := "`n" Type ", " Target ", " Window ", " Step ((DelayX > 0) ? ", " DelayX : "")
			If (Comment != "")
				RowData .= "  " "; " Comment
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If ((Type = cType7) || (Type = cType38) || (Type = cType39)
		|| (Type = cType40) || (Type = cType41) || (Type = cType45))
		{
			If (Action = "[LoopStart]")
			{
				If (Type = cType7)
					RowData := "`n" Type ((TimesX = 0) ? "" : ", " TimesX)
				Else If (Type = cType45)
				{
					StringSplit, Stp, Step, `,, %A_Space%``
					RowData := "`nFor " Stp2 ", " Stp3 " in " Stp1
				}
				Else
				{
					Type := StrReplace(Type, "FilePattern", ", Files")
				,	Type := StrReplace(Type, "Parse", ", Parse")
				,	Type := StrReplace(Type, "Read", ", Read")
				,	Type := StrReplace(Type, "Registry", ", Reg")
				,	RowData := "`n" Type ", " RTrim(Step, ", ")
					If (SubStr(RowData, 0) = "``")
						RowData := SubStr(RowData, 1, StrLen(RowData)-1)
				}
			}
			If (Comment != "")
				RowData .= "  " "; " Comment
			RowData .= "`n{"
			If (Action = "[LoopEnd]")
				RowData := "`n}"
		}
		Else If (Type = cType12)
		{
			If (InStr(Step, "``n"))
			{
				Step := StrReplace(Step, "``n", "`n")
			,	Step := "`n(LTrim`n" Step "`n)"
			}
			RowData := "`n" ((Step != "") ? "SavedClip := ClipboardAll`nClipboard =`nClipboard = " Step "`nSleep, 333" : "")
			If ((Target != "") && (Step != ""))
				RowData .= "`nControlSend, " Target ", ^v, " Window
			Else
				RowData .= "`nSend, ^v"
			RowData := Add_CD(RowData, Comment, DelayX)
			If (Step != "")
				RowData .= "`nClipboard := SavedClip`nSavedClip ="
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If ((Type = cType15) || (Type = cType16))
		{
			RowData := "`nCoordMode, Pixel, " Window
		,	RowData .= "`n" Type ", FoundX, FoundY, " Step
			Loop, Parse, Action, `,,%A_Space%
				Act%A_Index% := A_LoopField
			If (Act1 != "Continue")
			{
				RowData .= "`nIf ErrorLevel = 0"
				If (Act1 = "Break")
					RowData .= "`n`tBreak"
				Else If (Act1 = "Stop")
					RowData .= "`n`tReturn"
				Else If (Act1 = "Move")
					RowData .= "`n`tClick, %FoundX%, %FoundY%, 0"
				Else If (InStr(Act1, "Click"))
				{
					Loop, Parse, Act1, %A_Space%
						Action%A_Index% := A_LoopField
					RowData .= "`n`tClick, %FoundX%, %FoundY% " Action1 ", 1"
				}
				Else If (Act1 = "Prompt")
					RowData .= "`n{`nMsgBox, 49, " d_Lang035 ", " d_Lang036 " %FoundX%x%FoundY%.``n" d_Lang038 "`nIfMsgBox, Cancel`n`tReturn`n}"
				Else If (Act1 = "Play Sound")
					RowData .= "`n`tSoundBeep"
			}
			If (Act2 != "Continue")
			{
				RowData .= "`nIf ErrorLevel"
				If (Act2 = "Break")
					RowData .= "`n`tBreak"
				Else If (Act2 = "Stop")
					RowData .= "`n`tReturn"
				Else If (Act2 = "Prompt")
					RowData .= "`n{`nMsgBox, 49, " d_Lang035 ", " d_Lang037 "``n" d_Lang038 "`nIfMsgBox, Cancel`n`tReturn`n}"
				Else If (Act2 = "Play Sound")
					RowData .= "`n`tLoop, 2`n`t`tSoundBeep"
			}
			RowData := Add_CD(RowData, Comment, DelayX)
			If (Target = "Break")
				RowData := "`nLoop`n{" RowData "`n}`nUntil ErrorLevel = 0"
			Else If (Target = "Continue")
				RowData := "`nLoop`n{" RowData "`n}`nUntil ErrorLevel"
			Else If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType17)
		{
			If (Step = "Else")
			{
				RowData := "`n}`nElse"
				If (Comment != "")
					RowData .= "  " "; " Comment
				RowData .= "`n{"
			}
			Else If (Step = "EndIf")
				RowData := "`n}"
			Else
			{
				IfStReplace(Action, Step)
				RowData := "`n" Action " " Step
			,	RowData := RTrim(RowData)
				If (Comment != "")
					RowData .= "  " "; " Comment
				RowData .= "`n{"
			}
		}
		Else If ((Type = cType18) || (Type = cType19))
		{
			Loop, Parse, Step, `,
				Par%A_Index% := A_LoopField
			RowData := "`n" Type ", " Step ", " Target ", " Window
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType20)
		{
			RowData := "`n" Type ", " Step
		,	RowData .= "`n" Type ", " Step ", D"
			If (DelayX > 0)
				RowData .= " T" Round(DelayX/1000, 2) "`nIf ErrorLevel`n`tReturn"
			Else If (InStr(DelayX, "%"))
				RowData .= " T" DelayX "`nIf ErrorLevel`n`tReturn"
			If (Comment != "")
				RowData .= "  " "; " Comment
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If ((Type = cType21) || (Type = cType44) || (Type = cType46))
		{
			AssignReplace(Step)
			If (Type = cType21)
			{
				If VarValue is not number
				{
					If (Target != "Expression")
					{
						VarValue := StrReplace(VarValue, ",", "``,")
					,	VarValue := CheckExp(VarValue)
					}
				}
				If (InStr(VarValue, "``n"))
				{
					VarValue := StrReplace(VarValue, "``n", "`n")
				,	VarValue := "`n(LTrim`n" VarValue "`n)"
				}
				Step := VarName " " Oper " " VarValue
			}
			Else If (Type = cType46)
				Step := ((VarName = "_null") ? "" : VarName " " Oper " ") Target "." Action "(" ((VarValue = """") ? "" : VarValue) ")"
			Else
				Step := ((VarName = "_null") ? "" : VarName " " Oper " ") Action "(" ((VarValue = """") ? "" : VarValue) ")"
			RowData := "`n" Step
			If (Comment != "")
				RowData .= "  " "; " Comment
		}
		Else If (Type = cType22)
		{
			If (InStr(Step, "``n"))
			{
				Step := StrReplace(Step, "``n", "`n")
				Step := "`n(LTrim`n" Step "`n)"
			}
			RowData := "`nControl, EditPaste, " Step ", " Target ", " Window
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType23)
		{
			RowData := "`n" Type ", " Step ", " Target ", " Window
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If ((Type = cType24) || (Type = cType28))
		{
			RowData := "`n" Type ", " Step ", " Target ", " Window
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType25)
		{
			RowData := "`n" Type ", " Target ", " Window
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType26)
		{
			RowData := "`n" Type ", " Target ", " Step ", " Window
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType27)
		{
			RowData := "`n" Type ", " Step ", " Window
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If ((Type = cType29) || (Type = cType30))
		{
			RowData := "`n" Type (RegExMatch(Step, "^\d+$") ? ", " Step : "")
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType31)
		{
			RowData := "`n" Type ", " Step "X, " Step "Y, "
			. Step "W, " Step "H, " Target ", " Window
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType32)
		{
			StringSplit, Act, Action, :
			StringSplit, El, Target, :
			RowData := "`n" IEComExp(Act2, Step, El1, El2, "", Act3, Act1)
		,	RowData := CheckComExp(RowData)
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If (!init_ie)
				RowData := "`nIf !IsObject(ie)"
				.			"`n`tie := ComObjCreate(""InternetExplorer.Application"")"
				.			"`nie.Visible := true" RowData
			init_ie := true
			If (Window = "LoadWait")
				RowData .=
				(LTrim
				"`nWhile !(ie.busy)
				`tSleep, 100
				While (ie.busy)
				`tSleep, 100
				While !(ie.document.Readystate = ""Complete"")
				`tSleep, 100"
				)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType33)
		{
			StringSplit, Act, Action, :
			StringSplit, El, Target, :
			RowData := "`n" IEComExp(Act2, "", El1, El2, Step, Act3, Act1)
		,	RowData := CheckComExp(RowData, Step)
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If (!init_ie)
				RowData := "`nIf !IsObject(ie)"
				.			"`n`tie := ComObjCreate(""InternetExplorer.Application"")"
				.			"`nie.Visible := true" RowData
			init_ie := true
			If (Window = "LoadWait")
				RowData .=
				(LTrim
				"`nWhile !(ie.busy)
				`tSleep, 100
				While (ie.busy)
				`tSleep, 100
				While !(ie.document.Readystate = ""Complete"")
				`tSleep, 100"
				)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType34)
		{
			StringSplit, Act, Action, :
			RowData := ""
			If (Act2 != "")
				RowData .= "`n" Act2 " := " Act1 "." CheckComExp(Step, "", "", Act1)
			Else
			{
				Step := StrReplace(Step, "``n", "`n")
				Loop, Parse, Step, `n, %A_Space%%A_Tab%
				{
					If (A_LoopField = "")
						continue
					ComExp := CheckComExp(A_LoopField, "", sArray := "", Act1)
				,	RowData .= "`n" sArray . Act1 "." ComExp
				}
			}
			RowData := Add_CD(RowData, Comment, DelayX)
			If ((Target != "") && (!InStr(LVData, Act1 " := " ComType "(")))
				RowData := "`nIf !IsObject(" Act1 ")`n`t" Act1 " := " ComType "(""" Target """)" RowData
			If (Window = "LoadWait")
				RowData .=
				(LTrim
				"`nWhile !(ie.busy)
				`tSleep, 100
				While (ie.busy)
				`tSleep, 100
				While !(ie.document.Readystate = ""Complete"")
				`tSleep, 100"
				)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (Type = cType35)
		{
			RowData := "`n" Step ":"
		,	RowData := Add_CD(RowData, Comment, DelayX)
		}
		Else If ((Type = cType36) || (Type = cType37))
		{
			RowData := "`n" Type ", " Step
		,	RowData := Add_CD(RowData, Comment, DelayX)
		}
		Else If (Type = cType50)
			RowData := (IsChecked = A_Index) ? "`n/*`n" Step "`n*/" : ""
		Else If ((Type = cType3) || (Type = cType8) || (Type = cType11)
		|| (Type = cType13) || (Type = cType14))
		{
			If (InStr(Step, "``n") && ((Type = cType8) || (Type = cType13)))
			{
				Step := StrReplace(Step, "``n", "`n")
			,	Step := "`n(LTrim`n" Step "`n)"
			}
			Step := StrReplace(Step, "`````,", "```,")
		,	RowData := "`n" Type ", " Step
			If (!RegExMatch(Step, "```,\s*?$"))
				RowData := RTrim(RowData, ", ")
			If (Action != "[Text]")
				RowData := Add_CD(RowData, Comment, DelayX)
			Else If (Comment != "")
				RowData .= "  " "; " Comment
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
			If (Action = "[Text]")
				RowData := "`nSetKeyDelay, " DelayX RowData
		}
		Else If (InStr(FileCmdList, Type "|"))
		{
			If (InStr(Step, "``n") && (Type = cType8))
			{
				Step := StrReplace(Step, "``n", "`n")
			,	Step := "`n(LTrim`n" Step "`n)"
			}
			Step := StrReplace(Step, "`````,", "```,")
		,	RowData := "`n" Type ", " Step
			If (!RegExMatch(Step, "```,\s*?$"))
				RowData := RTrim(RowData, ", ")
			RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If ((Type = cType42) || (Type = cType43))
		{
			Act := SubStr(Action, 1, 2)
			If (InStr(Step, "``n"))
			{
				Step := StrReplace(Step, "``n", "`n")
			,	Step := "`n(LTrim`n" Step "`n)"
			}
			RowData := ""
		,	RowData .= "`n" Act "Code = " Step
		,	RowData .= "`n" Act " := ComObjCreate(""ScriptControl"")"
		,	RowData .= "`n" Act ".Language := """ Type """"
		,	RowData .= "`n" Act ".ExecuteStatement(" Act "Code)"
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		Else If (InStr(Type, "Win"))
		{
			If (Type = "WinMove")
				RowData := "`n" Type ", " Window "," ", " Step
			Else If (Type = "WinGetPos")
				RowData := "`n" Type ", " Step "X, " Step "Y, "
				. Step "W, " Step "H, " Window
			Else If ((Type = "WinSet") || InStr(Type, "Get"))
				RowData := "`n" Type ", " Step ", " Window
			Else If Type contains Close,Kill,Wait
			{
				Win := SplitWin(Window)
			,	RowData := "`n" Type ", " Win[1] ", " Win[2] ", " Step ", " Win[3] ", " Win[4]
			}
			Else
				RowData := "`n" Type ", " Window
			RowData := RTrim(RowData, " ,")
		,	RowData := Add_CD(RowData, Comment, DelayX)
			If ((TimesX > 1) || InStr(TimesX, "%"))
				RowData := "`nLoop, " TimesX "`n{" RowData "`n}"
		}
		If (!InStr(FileCmdList, Type "|"))
			RowData := StrReplace(RowData, "```,", "`,")
		If ((IsChecked = A_Index) && (CommentOut))
			LVData .= "`n*/" RowData, CommentOut := false
		Else If ((IsChecked != A_Index) && (!CommentOut) && (Type != cType50))
			LVData .= "`n/*" RowData, CommentOut := true
		Else
			LVData .= RowData
	}
	If (IsFunction)
		LVData .= "`n}"
	LVData := LTrim(LVData, "`n")
	If (TabIndent)
	{
		Loop, Parse, LVData, `n
		{
			If (RegExMatch(A_LoopField, "^\}(\s `;)?"))
				Indent--
			Loop, %Indent%
				Id_LVData .= "`t"
			Id_LVData .= A_LoopField "`n"
			If (A_LoopField = "{")
				Indent++
		}
		return Id_LVData
	}
	return LVData "`n"
}

IfStReplace(ByRef Action, ByRef Step)
{
	global
	Loop, 15
	{
		Act := "If" A_Index
		If (Action = %Act%)
			Action := c_%Act%
	}
	If (Action = c_If15)
	{
		Action := "If"
		StringReplace, Step, Step, `%,, All
		Step := "(" Step ")"
	}
}

Add_CD(RowData, Comment, DelayX)
{
	If (Comment != "")
		RowData .= "  " "; " Comment
	If ((DelayX > 0) || InStr(DelayX, "%"))
		RowData .= "`n" "Sleep, " DelayX
	return RowData
}

Script_Header()
{
	global
	Header := HeadLine "`n`n#NoEnv`nSetWorkingDir %A_ScriptDir%`nCoordMode, Mouse, " CoordMouse
	If (Ex_SM = 1)
		Header .= "`nSendMode " SM
	If (Ex_SI = 1)
		Header .= "`n#SingleInstance " SI
	If (Ex_ST = 1)
		Header .= "`nSetTitleMatchMode " ST
	If (Ex_DH = 1)
		Header .= "`nDetectHiddenWindows On"
	If (Ex_AF = 1)
		Header .= "`n#WinActivateForce"
	If (Ex_NT = 1)
		Header .= "`n#NoTrayIcon"
	If (Ex_SC = 1)
		Header .= "`nSetControlDelay " SC
	If (Ex_SW = 1)
		Header .= "`nSetWinDelay " SW
	If (Ex_SK = 1)
		Header .= "`nSetKeyDelay " SK
	If (Ex_MD = 1)
		Header .= "`nSetMouseDelay " MD
	If (Ex_SB = 1)
		Header .= "`nSetBatchLines " SB
	If (Ex_HK = 1)
		Header .= "`n#UseHook"
	If (Ex_PT = 1)
		Header .= "`n#Persistent"
	If (Ex_MT = 1)
		Header .= "`n#MaxThreadsPerHotkey " MT
	Header .= "`n`n"
	return Header
}

IncludeFiles(L, N)
{
	global cType44
	
	Gui, chMacro:Default
	Gui, chMacro:ListView, InputList%L%
	Loop, %N%
	{
		If (LV_GetNext(A_Index-1, "Checked") != A_Index)
			continue
		LV_GetText(Row_Type, A_Index, 6)
		If (Row_Type != cType44)
			continue
		LV_GetText(IncFile, A_Index, 7)
		If ((IncFile != "") && (IncFile != "Expression"))
			IncList .= "`#`Include " IncFile "`n"
	}
	Sort, IncList, U
	return IncList
}

CheckForExp(Field)
{
	global cType44
	
	RegExReplace(Field, "U)%\s+([\w%]+)\((.*)\)", "", iCount)
	Match := 0
	Loop, %iCount%
	{
		Match := RegExMatch(Field, "U)%\s+([\w%]+)\((.*)\)", Funct, Match+1)
		If (Type = cType44)
			StringReplace, Funct2, Funct2, `,, ```,
		If ((ExpValue := CheckExp(Funct2)) = """""")
			ExpValue := ""
		StringReplace, Field, Field, %Funct%, % "% " Funct1 "(" ExpValue ")"
	}
	return Field
}

CheckExp(String)
{
	Static _x := Chr(2), _y := Chr(3), _z := Chr(4)
	
	If (String = "")
		return """"""
	StringReplace, String, String, ```%, %_y%, All
	StringReplace, String, String, `````, , %_x%, All
	Loop, Parse, String, `,, %A_Space%``
	{
		LoopField := (A_LoopField != """""") ? RegExReplace(A_LoopField, """", """""") : A_LoopField
		If (InStr(LoopField, "%"))
		{
			Loop, Parse, LoopField, `%
			{
				If (A_LoopField != "")
					NewStr .=  Mod(A_Index, 2) ? " """ RegExReplace(A_LoopField, "%") """ " : RegExReplace(A_LoopField, "%")
			}
			NewStr := RTrim(NewStr) ", "
		}
		Else If (RegExMatch(LoopField, "[\w%]+\[\S+?\]"))
			NewStr .= LoopField ", "
		Else
			NewStr .= """" LoopField """, "
	}
	StringReplace, NewStr, NewStr, %_x%, `,, All
	StringReplace, NewStr, NewStr, %_y%, `%, All
	NewStr := Trim(RegExReplace(NewStr, " """" "), ", ")
,	NewStr := RegExReplace(NewStr, """{4}", """""")
,	NewStr := RegExReplace(NewStr, "U)""(-?\d+)""", "$1")
	return NewStr
}

CheckComExp(String, OutVar := "", ByRef ArrString := "", Ptr := "ie")
{
	If (OutVar != "")
		String := Trim(RegExReplace(String, "(.*):=[\s]?"))
	Else If (RegExMatch(String, "[\s]?:=(.*)", Assign))
	{
		Value := Trim(Assign1), String := Trim(RegExReplace(String, "[\s]?:=(.*)"))
		If Value in true,false
			Value := "%" Value "%"
	}
	While, RegExMatch(String, "\(([^()]++|(?R))*\)", _Parent%A_Index%)
		String := RegExReplace(String, "\(([^()]++|(?R))*\)", "&_Parent" A_Index, "", 1)
	While, RegExMatch(String, "U)\[(.*)\]", _Block%A_Index%)
		String := RegExReplace(String, "U)\[(.*)\]", "&_Block" A_Index, "", 1)

	Loop, Parse, String, .&
	{
		If (RegExMatch(A_LoopField, "^_Parent\d+"))
		{
			Parent := SubStr(%A_LoopField%, 2, -1)
			While, RegExMatch(Parent, "U)[^\w\]]\[(.*)\]", _Arr%A_Index%)
				Parent := RegExReplace(Parent, "U)[^\w\]]\[(.*)\]", "_Arr" A_Index, "", 1)
			While, RegExMatch(Parent, "\(([^()]++|(?R))*\)", _iParent%A_Index%)
				Parent := RegExReplace(Parent, "\(([^()]++|(?R))*\)", "&_iParent" A_Index, "", 1)
			Params := ""
			If (InStr(Parent, "`,"))
			{
				Loop, Parse, Parent, `,, %A_Space%
				{
					LoopField := A_LoopField
					While, RegExMatch(LoopField, "&_iParent(\d+)", inPar)
					{
						iPar := RegExReplace(_iParent%inPar1%, "\$", "$$$$")
					,	LoopField := RegExReplace(LoopField, "&_iParent\d+", iPar, "", 1)
					}
					If (RegExMatch(LoopField, "^_Arr\d+"))
					{
						StringSplit, Arr, %LoopField%1, `,, %A_Space%
						ArrString := "SafeArray := ComObjArray(0xC, " Arr0 ")"
						Loop, %Arr0%
							ArrString .= "`nSafeArray[" A_Index-1 "] := " CheckExp(Arr%A_Index%)
						ArrString .= "`n"
						Params .= "SafeArray, "
					}
					Else
					{
						If (Loopfield = "")
							LoopField := "%ComObjMissing()%"
						If (RegExMatch(LoopField, "i)^" Ptr "\..*", NestStr))
							Params .= (CheckComExp(NestStr, OutVar, "", Ptr)) ", "
						Else
							Params .= ((CheckExp(LoopField) = """""") ? "" : CheckExp(LoopField)) ", "
					}
				}
			}
			Else
			{
				While, RegExMatch(Parent, "&_iParent(\d+)", inPar)
					Parent := RegExReplace(Parent, "&_iParent\d+", _iParent%inPar1%, "", 1)
				Params := Parent
			}
			Params := RTrim(Params, ", ")
			If (!InStr(Params, "`,"))
			{
				If (RegExMatch(Params, "i)^" Ptr "\..*", NestStr))
					Params := (CheckComExp(NestStr, OutVar, "", Ptr))
				Else
					Params := (CheckExp(Params) = """""") ? "" : CheckExp(Params)
			}
			String := RegExReplace(String, "&" A_LoopField, "(" Params ")")
		}
		If (RegExMatch(A_LoopField, "^_Block\d+"))
			String := RegExReplace(String, "&" A_LoopField, "[" CheckExp(%A_LoopField%1) "]")
	}
	If (Value != "")
	{
		StringReplace, Value, Value, `,, `````,, All
		String .= (Value = """""") ? " := """"" : " := " CheckExp(Value)
	}
	Else If (OutVar != "")
		String := "`n" OutVar " := " String
	
	return String
}

IEComExp(Method, Value := "", Element := "", ElIndex := 0, OutputVar := "", GetBy := "Name", Obj := "Method")
{
	If (GetBy = "ID")
		getEl := "getElementByID"
	Else
		getEl := "getElementsBy" GetBy
	
	ElIndex := (ElIndex != "") ? "[" ElIndex "]" : ""
	
	If (!Element)
	{
		If (OutputVar)
			return OutputVar " := ie." Method
		Else If (Obj = "Method")
		{
			If (Value != "")
				return "ie." Method "(" Value ")"
			Else
				return "ie." Method "()"
		}
		Else If (Obj = "Property")
			return "ie." Method " := " Value
	}
	Else If (GetBy = "ID")
	{
		If (OutputVar)
			return OutputVar " := ie.document." getEl "(" Element ")." Method
		Else If (Obj = "Method")
		{
			If (Value != "")
				return "ie.document." getEl "(" Element ")." Method "(" Value ") := " Value
			Else
				return "ie.document." getEl "(" Element ")." Method "()"
		}
		Else If (Obj = "Property")
			return "ie.document." getEl "(" Element ")." Method " := " Value
	}
	Else If (GetBy = "Links")
	{
		If (OutputVar)
			return OutputVar " := ie.document." Element . ElIndex "." Method
		Else If (Obj = "Method")
		{
			If (Value != "")
				return "ie.document." Element . ElIndex "." Method "(" Value ")"
			Else
				return "ie.document." Element . ElIndex "." Method "()"
		}
		Else If (Obj = "Property")
			return "ie.document." Element . ElIndex "." Method " := " Value
	}
	Else If (GetBy != "ID")
	{
		If (OutputVar)
			return OutputVar " := ie.document." getEl "(" Element ")" ElIndex "." Method
		Else If (Obj = "Method")
		{
			If (Value != "")
				return "ie.document." getEl "(" Element ")" ElIndex "." Method "(" Value ")"
			Else
				return "ie.document." getEl "(" Element ")" ElIndex "." Method "()"
		}
		Else If (Obj = "Property")
			return "ie.document." getEl "(" Element ")" ElIndex "." Method " := " Value
	}
}

