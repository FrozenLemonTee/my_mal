Option Explicit

Include "IO.vbs"
Include "Types.vbs"
Include "Reader.vbs"
Include "Printer.vbs"
Include "Env.vbs"
Include "Core.vbs"

Function EvalLater(objMal, objEnv)
	' A fake implement, for compatibility.
	Dim varRes
	Set varRes = Evaluate(objMal, objEnv)
	Set EvalLater = varRes
End Function

Function MDef(objArgs, objEnv)
	Dim varRet
	CheckArgNum objArgs, 2
	CheckType objArgs.Item(1), TYPES.SYMBOL
	Set varRet = Evaluate(objArgs.Item(2), objEnv)
	objEnv.Add objArgs.Item(1).Value, varRet
	Set MDef = varRet
End Function
objNS.Add "def!", NewVbsProc("MDef", True)

Function MLet(objArgs, objEnv)
	Dim varRet
	CheckArgNum objArgs, 2

	Dim objBinds
	Set objBinds = objArgs.Item(1)
	CheckListOrVec objBinds
	
	If objBinds.Count Mod 2 <> 0 Then
		Err.Raise vbObjectError, _
			"MLet", "Wrong argument count."
	End If

	Dim objNewEnv
	Set objNewEnv = NewEnv(objEnv)
	Dim i, objSym
	For i = 0 To objBinds.Count - 1 Step 2
		Set objSym = objBinds.Item(i)
		CheckType objSym, TYPES.SYMBOL
		objNewEnv.Add objSym.Value, Evaluate(objBinds.Item(i + 1), objNewEnv)
	Next

	Set varRet = Evaluate(objArgs.Item(2), objNewEnv)
	Set MLet = varRet
End Function
objNS.Add "let*", NewVbsProc("MLet", True)

Function MDo(objArgs, objEnv)
	Dim varRet, i
	If objArgs.Count - 1 < 1 Then
		Err.Raise vbObjectError, _
			"MDo", "Need more arguments."
	End If
	For i = 1 To objArgs.Count - 1
		Set varRet = Evaluate(objArgs.Item(i), objEnv)
	Next
	Set MDo = varRet
End Function
objNS.Add "do", NewVbsProc("MDo", True)

Function MIf(objArgs, objEnv)
	Dim varRet
	If objArgs.Count - 1 <> 3 And _
		objArgs.Count - 1 <> 2 Then
		Err.Raise vbObjectError, _
			"MIf", "Wrong number of arguments."
	End If

	Dim objCond
	Set objCond = Evaluate(objArgs.Item(1), objEnv)
	Dim boolCond
	If objCond.Type = TYPES.BOOLEAN Then
		boolCond = objCond.Value
	Else
		boolCond = True
	End If
	boolCond = (boolCond And objCond.Type <> TYPES.NIL)
	If boolCond Then
		Set varRet = Evaluate(objArgs.Item(2), objEnv)
	Else
		If objArgs.Count - 1 = 3 Then
			Set varRet = Evaluate(objArgs.Item(3), objEnv)
		Else
			Set varRet = NewMalNil()
		End If
	End If
	Set MIf = varRet
End Function
objNS.Add "if", NewVbsProc("MIf", True)

Function MFn(objArgs, objEnv)
	Dim varRet
	CheckArgNum objArgs, 2

	Dim objParams, objCode
	Set objParams = objArgs.Item(1)
	CheckListOrVec objParams
	Set objCode = objArgs.Item(2)
	
	Dim i
	For i = 0 To objParams.Count - 1
		CheckType objParams.Item(i), TYPES.SYMBOL
	Next
	Set varRet = NewMalProc(objParams, objCode, objEnv)
	Set MFn = varRet
End Function
objNS.Add "fn*", NewVbsProc("MFn", True)

Call InitBuiltIn()

Call REPL()
Sub REPL()
	Dim strCode
	While True
		IO.Write "user> "

		On Error Resume Next
			strCode = IO.ReadLine
			If Err.Number <> 0 Then WScript.Quit 0
		On Error Goto 0

		Dim strRes
		On Error Resume Next
			strRes = REP(strCode)
			If Err.Number <> 0 Then
				IO.WriteErrLine "Exception: " + Err.Description
			Else
				If strRes <> "" Then
					IO.WriteLine strRes
				End If
			End If
		On Error Goto 0
	Wend
End Sub

Function Read(strCode)
	Set Read = ReadString(strCode)
End Function

Sub DebugEval(objCode, objEnv)
	Dim value
	Set value = objEnv.Get("DEBUG-EVAL")
	' And and Or do not short-circuit.
	If TypeName(value) = "Nothing" Then
		Exit Sub
	Else
		Select Case value.Type
			Case TYPES.NIL
				Exit Sub
			Case TYPES.BOOLEAN
				If Not value.Value Then
					Exit Sub
				End If
		End Select
	End If
	IO.WriteLine "EVAL: " + Print(objCode)
End Sub

Function Evaluate(objCode, objEnv)
	If TypeName(objCode) = "Nothing" Then
		Set Evaluate = Nothing
		Exit Function
	End If

	DebugEval objCode, objEnv

	Dim varRet, objFirst
	If objCode.Type = TYPES.LIST Then
		If objCode.Count = 0 Then ' ()
			Set Evaluate = objCode
			Exit Function
		End If
		Set objFirst = Evaluate(objCode.Item(0), objEnv)
		Set varRet = objFirst.Apply(objCode, objEnv)
	Else
		Set varRet = EvaluateAST(objCode, objEnv)
	End If

	Set Evaluate = varRet
End Function


Function EvaluateAST(objCode, objEnv)
	Dim varRet, i
	Select Case objCode.Type
		Case TYPES.SYMBOL
			Set varRet = objEnv.Get(objCode.Value)
			If TypeName(varRet) = "Nothing" Then
				Err.Raise vbObjectError, _
					"EvaluateAST", "'" + objCode.Value + "' not found"
			End If
		Case TYPES.LIST
			Err.Raise vbObjectError, _
				"EvaluateAST", "Unexpect type."
		Case TYPES.VECTOR
			Set varRet = NewMalVec(Array())
			For i = 0 To objCode.Count() - 1
				varRet.Add Evaluate(objCode.Item(i), objEnv)
			Next
		Case TYPES.HASHMAP
			Set varRet = NewMalMap(Array(), Array())
			For Each i In objCode.Keys()
				varRet.Add i, Evaluate(objCode.Item(i), objEnv)
			Next
		Case Else
			Set varRet = objCode
	End Select
	Set EvaluateAST = varRet
End Function

Function EvaluateRest(objCode, objEnv)
	Dim varRet, i
	Select Case objCode.Type
		Case TYPES.LIST
			Set varRet = NewMalList(Array(NewMalNil()))
			For i = 1 To objCode.Count() - 1
				varRet.Add Evaluate(objCode.Item(i), objEnv)
			Next
		Case Else
			Err.Raise vbObjectError, _
				"EvaluateRest", "Unexpected type."
	End Select
	Set EvaluateRest = varRet
End Function

Function Print(objCode)
	Print = PrintMalType(objCode, True)
End Function

Function REP(strCode)
	REP = Print(Evaluate(Read(strCode), objNS))
End Function

Sub Include(strFileName)
	With CreateObject("Scripting.FileSystemObject")
		ExecuteGlobal .OpenTextFile( _
			.GetParentFolderName( _
			.GetFile(WScript.ScriptFullName)) & _
			"\" & strFileName).ReadAll
	End With
End Sub
