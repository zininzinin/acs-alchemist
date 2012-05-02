# Auto-generated by EclipseNSIS Script Wizard
# Jun 6, 2011 4:54:19 PM

Name "ACS Alchemist"

# General Symbol Definitions
!define REGKEY "SOFTWARE\$(^Name)"
!define VERSION 1.0.0
!define COMPANY Azavea
!define URL http://www.azavea.com
!define SOURCE_DIR C:\projects\acs-alchemist\csharp\Azavea.NijPredictivePolicing.AcsImporter\bin\x86\Debug
#!define SOURCE_DIR "C:\projects\acs-alchemist\csharp\Azavea.NijPredictivePolicing.AcsImporter\bin\Debug"

# MUI Symbol Definitions
!define MUI_ICON "C:\projects\acs-alchemist\csharp\Azavea.NijPredictivePolicing.AcsImporter\Icon1.ico"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_REGISTRY_KEY ${REGKEY}
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Azavea"
!define MUI_FINISHPAGE_SHOWREADME $INSTDIR\README.txt
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-colorful.ico"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

# Included files
!include Sections.nsh
!include MUI2.nsh
#!include ShellLink.nsh
!include nsDialogs.nsh
!include LogicLib.nsh

# Variables
Var StartMenuGroup

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup

Page custom onPathPageCreate onPathPageLeave "Add directory to system path?"

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Installer languages
!insertmacro MUI_LANGUAGE English

# Installer attributes
OutFile ACSInstaller.exe
InstallDir "$PROGRAMFILES\Azavea\ACS Alchemist"
CRCCheck on
XPStyle on
ShowInstDetails show
VIProductVersion 1.0.0.0
VIAddVersionKey ProductName "ACS Alchemist"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""
InstallDirRegKey HKLM "${REGKEY}" Path
ShowUninstDetails show

!define SHORTCUTFILE "$SMPROGRAMS\$StartMenuGroup\ACS Alchemist.lnk"

#
# Added variables
#

Var Dialog
Var chkAddToPath
Var Checkbox_State

# Installer sections
Section -Main SEC0000
    SetOutPath $INSTDIR
    SetOverwrite on
    File /r ${SOURCE_DIR}\*
    ;File /r C:\projects\acs-alchemist\csharp\Azavea.NijPredictivePolicing.AcsImporter\bin\Debug\*
    File C:\projects\acs-alchemist\doc\README.txt
	
	#23265 -- any config files must be present!  otherwise the user will need to be an admin on first run, which is annoying
	File ${SOURCE_DIR}\AcsAlchemist.2009.config
	File ${SOURCE_DIR}\AcsAlchemist.2010.config
	
	
	SetOutPath $INSTDIR\Docs
	File C:\projects\acs-alchemist\doc\README.txt
	File C:\projects\acs-alchemist\doc\ACS_Alchemist_Flowchart.jpg
	File C:\projects\acs-alchemist\doc\ACS2009_5-Year_TableShells.xls
	File C:\projects\acs-alchemist\doc\ACS2010_5-Year_TableShells.xls
	
	#Licenses#
	SetOutPath $INSTDIR\Licenses
	SetOutPath $INSTDIR\Licenses\Ionic
	File C:\projects\acs-alchemist\lib\dotnetzip\License.txt
	File C:\projects\acs-alchemist\lib\dotnetzip\PleaseDonate.txt
	File C:\projects\acs-alchemist\lib\dotnetzip\Readme.txt	
	SetOutPath $INSTDIR\Licenses\exceldatareader
	File C:\projects\acs-alchemist\lib\excelDataReader\license.txt	
	SetOutPath $INSTDIR\Licenses\geoapi
	File C:\projects\acs-alchemist\lib\geoapi\lgpl-2.1.txt
	SetOutPath $INSTDIR\Licenses\json
	File C:\projects\acs-alchemist\lib\json\readme.txt
	SetOutPath $INSTDIR\Licenses\log4net
	File C:\projects\acs-alchemist\lib\log4net\LICENSE.txt
	File C:\projects\acs-alchemist\lib\log4net\NOTICE.txt
	File C:\projects\acs-alchemist\lib\log4net\README.txt
	SetOutPath $INSTDIR\Licenses\nettopologysuite
	File C:\projects\acs-alchemist\lib\nettopologysuite\License.txt
	File C:\projects\acs-alchemist\lib\nettopologysuite\lgpl-3.0.txt
	File C:\projects\acs-alchemist\lib\nettopologysuite\lgpl-2.1.txt
	File C:\projects\acs-alchemist\lib\nettopologysuite\Iesi.Collections.License.txt
	File C:\projects\acs-alchemist\lib\nettopologysuite\Rtools.Util.License.txt
	SetOutPath $INSTDIR\Licenses\spatialite
	File C:\projects\acs-alchemist\lib\spatialite\lgpl-v3.txt
	SetOutPath $INSTDIR\Licenses\sqlite
	File C:\projects\acs-alchemist\lib\sqlite\license.txt	
	
    SetOutPath $SMPROGRAMS\$StartMenuGroup	
	CreateShortcut "$SMPROGRAMS\$StartMenuGroup\View Files.lnk" "$INSTDIR"	
    CreateShortcut "${SHORTCUTFILE}" "cmd" "/k cd $INSTDIR"
	#ShellLink::SetRunAsAdministrator "${SHORTCUTFILE}"
	#Pop $0
	ShellLink::SetShortCutWorkingDirectory "${SHORTCUTFILE}" $INSTDIR
	Pop $0
	
    WriteRegStr HKLM "${REGKEY}\Components" Main 1
SectionEnd

Section -post SEC0001
    WriteRegStr HKLM "${REGKEY}" Path $INSTDIR
    SetOutPath $INSTDIR
    WriteUninstaller $INSTDIR\uninstall.exe
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetOutPath $SMPROGRAMS\$StartMenuGroup
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Uninstall $(^Name).lnk" $INSTDIR\uninstall.exe
    !insertmacro MUI_STARTMENU_WRITE_END
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayName "$(^Name)"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayVersion "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" Publisher "${COMPANY}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLInfoAbout "${URL}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayIcon $INSTDIR\uninstall.exe
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" UninstallString $INSTDIR\uninstall.exe
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoModify 1
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoRepair 1
SectionEnd

# Macro for selecting uninstaller sections
!macro SELECT_UNSECTION SECTION_NAME UNSECTION_ID
    Push $R0
    ReadRegStr $R0 HKLM "${REGKEY}\Components" "${SECTION_NAME}"
    StrCmp $R0 1 0 next${UNSECTION_ID}
    !insertmacro SelectSection "${UNSECTION_ID}"
    GoTo done${UNSECTION_ID}
next${UNSECTION_ID}:
    !insertmacro UnselectSection "${UNSECTION_ID}"
done${UNSECTION_ID}:
    Pop $R0
!macroend

# Uninstaller sections
Section /o -un.Main UNSEC0000
    Delete /REBOOTOK $INSTDIR\README.txt
    RmDir /r /REBOOTOK $INSTDIR
    DeleteRegValue HKLM "${REGKEY}\Components" Main
SectionEnd

Section -un.post UNSEC0001
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Uninstall $(^Name).lnk"
    Delete /REBOOTOK $INSTDIR\uninstall.exe
    DeleteRegValue HKLM "${REGKEY}" StartMenuGroup
    DeleteRegValue HKLM "${REGKEY}" Path
    DeleteRegKey /IfEmpty HKLM "${REGKEY}\Components"
    DeleteRegKey /IfEmpty HKLM "${REGKEY}"
    
    delete "$SMPROGRAMS\$StartMenuGroup\View Files.lnk"
    delete "${SHORTCUTFILE}"
    
    RmDir /REBOOTOK $SMPROGRAMS\$StartMenuGroup
    RmDir /REBOOTOK $INSTDIR
    Push $R0
    StrCpy $R0 $StartMenuGroup 1
    StrCmp $R0 ">" no_smgroup
no_smgroup:
    Pop $R0
SectionEnd

# Installer functions
Function .onInit
    InitPluginsDir
FunctionEnd

# Uninstaller functions
Function un.onInit
    ReadRegStr $INSTDIR HKLM "${REGKEY}" Path
    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuGroup
    !insertmacro SELECT_UNSECTION Main ${UNSEC0000}
FunctionEnd




Function onPathPageLeave

${NSD_GetState} $chkAddToPath $Checkbox_State
${If} $Checkbox_State == ${BST_CHECKED}
    #APPEND TO PATH!
    
    #setx PATH "%path%;C:\FOO"    
    NsExec::ExecToLog 'setx PATH "%path%;$INSTDIR;"'
    
    #reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_SZ /d %path%;c:\FOO
    NsExec::ExecToLog 'reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_SZ /d "%path%;$INSTDIR;"'

    DetailPrint "Added install dir to path"

${EndIf}


FunctionEnd



Function onPathPageCreate
 nsDialogs::Create 1018
 Pop $Dialog

 ${If} $Dialog == error
  Abort
 ${EndIf}

 #create our form...

 ${NSD_CreateCheckbox} 0 0 75% 24u "Add the install directory to your system path?"
 Pop $chkAddToPath
 
 ${NSD_SetFocus} $chkAddToPath

 nsDialogs::Show
FunctionEnd
