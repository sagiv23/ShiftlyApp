[Setup]
AppId={{D37E7492-9988-4A59-880A-D3F3763D0819}
AppName=Shiftly
AppVersion={#AppVersion}
AppPublisher=Shiftly
DefaultDirName={autopf}\Shiftly
DefaultGroupName=Shiftly
OutputDir=..\build\windows
OutputBaseFilename=Shiftly_Windows_Setup
SetupIconFile=runner\resources\app_icon.ico
Compression=lzma2/max
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64compatible

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Shiftly"; Filename: "{app}\shiftly.exe"
Name: "{autodesktop}\Shiftly"; Filename: "{app}\shiftly.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\shiftly.exe"; Description: "{cm:LaunchProgram,Shiftly}"; Flags: nowait postinstall skipifsilent
