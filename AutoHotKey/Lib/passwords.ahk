#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
SetWorkingDir(A_ScriptDir)

; Manage passwords with the Windows Credential Manager

; Based on work from geek:
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116285

!^c::NewpassGui() ; Add a new password (Ctrl + Alt + c)
!^d::RmpassGui() ; Remove a password (Ctrl + Alt + d)
!^r::ReadpassGui() ; Fetch a password (Ctrl + Alt + r)

; To retrieve a password:
; !^p::sendPass("123")

NewPassGui() {
  myGui := Gui("-MinimizeBox -MaximizeBox +MinSize120x180 +MaxSize120x180", "New pass")
  myGui.Add("Text", , "Key:")
  myGui.Add("Edit", "w100 vnewKey")
  myGui.Add("Text", , "User:")
  myGui.Add("Edit", "w100 vnewUser")
  myGui.Add("Text", , "Pass:")
  myGui.Add("Edit", "w100 vnewPass")
  ogcButtonAddPass := myGui.Add("Button", "Default x30 w60", "&Add Pass")
  ogcButtonAddPass.OnEvent("Click", ButtonAddPass.Bind("Normal"))
  myGui.OnEvent("Escape", GuiEscape)

  ButtonAddPass(*) {
    oSaved := myGui.Submit()
    newKey := oSaved.newKey
    newUser := oSaved.newUser
    newPass := oSaved.newPass
    cred_key := "AHK_" . newKey
    if CredWrite(cred_key, newUser, newPass)
      tToolTip("Saved creds for " newUser " [" cred_key "]", 3000)
    else
      tToolTip("Failed to save creds for " newKey, 3000)
  }
  GuiEscape(*) {
    myGui.Destroy()
  }

  myGui.Show()
}

RmPassGui() {
  myGui := Gui("-MinimizeBox -MaximizeBox +MinSize120x180 +MaxSize120x180", "Delete pass")
  myGui.Add("Text", , "Key:")
  ogcEditoldKey := myGui.Add("Edit", "w100 voldKey")
  ogcButtonRemovePass := myGui.Add("Button", "Default x30 w60", "&Remove Pass")
  ogcButtonRemovePass.OnEvent("Click", ButtonRemovePass.Bind("Normal"))
  myGui.OnEvent("Escape", GuiEscape)

  ButtonRemovePass(A_GuiEvent, GuiCtrlObj, Info, *) {
    oSaved := myGui.Submit()
    oldKey := oSaved.oldKey
    cred_key := "AHK_" . oldKey
    if CredDelete(cred_key)
      tToolTip("Removed creds for " cred_key, 3000)
    else
      tToolTip("Failed to remove creds for " oldKey, 3000)
  }
  GuiEscape(*) {
    myGui.Destory()
  }

  myGui.Show()
}

ReadPassGui() {
  myGui := Gui("-MinimizeBox -MaximizeBox +MinSize120x180 +MaxSize120x180", "Fetch pass")
  myGui.Add("Text", , "Key:")
  ogcEditoldKey := myGui.Add("Edit", "w100 voldKey")
  ogcButtonFetchPass := myGui.Add("Button", "Default x30 w60", "&Fetch Pass")
  ogcButtonFetchPass.OnEvent("Click", ButtonFetchPass.Bind("Normal"))
  myGui.OnEvent("Escape", GuiEscape)

  ButtonFetchPass(A_GuiEvent, GuiCtrlObj, Info, *) {
    oSaved := myGui.Submit()
    oldKey := oSaved.oldKey
    cred_key := "AHK_" . oldKey
    if cred := CredRead(cred_key) {
      tToolTip("Fetch creds for " cred_key, 3000)
      A_Clipboard := cred.password
    } else
      tToolTip("Failed to fetch creds for " oldKey, 3000)
  }
  GuiEscape(*) {
    myGui.Destory()
  }

  myGui.Show()
}

sendPass(key) {
  cred_key := "AHK_" . key
  if (creds := CredRead(cred_key)) {
    tToolTip("Pasting " cred_key " pass for " creds.username, 3000)
    SendText(creds.password)
  } else {
    tToolTip("No stored pass for " key ". Ctrl+Alt+c to create", 3000)
  }
}

CredWrite(name, username, password) {
  cred := Buffer(24 + A_PtrSize * 7, 0)
  cbPassword := StrLen(password) * 2
  NumPut("UInt", 1               , cred,  4+A_PtrSize*0) ; Type = CRED_TYPE_GENERIC
  NumPut("Ptr",  StrPtr(name)    , cred,  8+A_PtrSize*0) ; TargetName = name
  NumPut("UInt", cbPassword      , cred, 16+A_PtrSize*2) ; CredentialBlobSize
  NumPut("Ptr",  StrPtr(password), cred, 16+A_PtrSize*3) ; CredentialBlob
  NumPut("UInt", 3               , cred, 16+A_PtrSize*4) ; Persist = CRED_PERSIST_ENTERPRISE (roam across domain)
  NumPut("Ptr",  StrPtr(username), cred, 24+A_PtrSize*6) ; UserName
  Return DllCall("Advapi32.dll\CredWriteW",
      "Ptr", cred, ; [in] PCREDENTIALW Credential
      "UInt", 0,   ; [in] DWORD        Flags
      "UInt" ; BOOL
  )
}

CredDelete(name) {
  ; Note that creds created by NewPassGui have `AHK_` prepended
  Return DllCall("Advapi32.dll\CredDeleteW",
      "WStr", name, ; [in] LPCWSTR TargetName
      "UInt", 1,    ; [in] DWORD   Type,
      "UInt", 0,    ; [in] DWORD   Flags
      "UInt" ; BOOL
  )
}

CredRead(name) {
  ; Note that creds created by NewPassGui have `AHK_` prepended
  pCred := 0
  DllCall("Advapi32.dll\CredReadW",
      "Str", name,    ; [in]  LPCWSTR      TargetName
      "UInt", 1,      ; [in]  DWORD        Type = CRED_TYPE_GENERIC
      "UInt", 0,      ; [in]  DWORD        Flags
      "Ptr*", &pCred, ; [out] PCREDENTIALW *Credential
      "UInt" ; BOOL
  )
  if !pCred
      Return

  name :=     StrGet(NumGet(pCred,  8 + A_PtrSize * 0, "UPtr"), 256, "UTF-16")
  len :=             NumGet(pCred, 16 + A_PtrSize * 2, "UInt")
  password := StrGet(NumGet(pCred, 16 + A_PtrSize * 3, "UPtr"), len/2, "UTF-16")
  username := StrGet(NumGet(pCred, 24 + A_PtrSize * 6, "UPtr"), 256, "UTF-16")
  DllCall("Advapi32.dll\CredFree", "Ptr", pCred)
	Return {name: name, username: username, password: password}
}
RemoveToolTip() {
  ToolTip()
  Return
}
tToolTip(msg, time:=500) {
  ToolTip(msg)
  SetTimer(RemoveToolTip, -1*time)
}