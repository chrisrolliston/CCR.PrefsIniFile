program DesktopPrefsDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  CCR.PrefsIniFile.Android in '..\..\CCR.PrefsIniFile.Android.pas',
  CCR.PrefsIniFile.Apple in '..\..\CCR.PrefsIniFile.Apple.pas',
  CCR.PrefsIniFile in '..\..\CCR.PrefsIniFile.pas',
  DesktopPrefsForm in 'DesktopPrefsForm.pas' {frmDesktopPrefs},
  ShellUtils in 'ShellUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmDesktopPrefs, frmDesktopPrefs);
  Application.Run;
end.
