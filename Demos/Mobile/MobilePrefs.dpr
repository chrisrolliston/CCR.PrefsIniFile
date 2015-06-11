program MobilePrefs;

uses
  System.StartUpCopy,
  FMX.Forms,
  CCR.PrefsIniFile.Android in '..\..\CCR.PrefsIniFile.Android.pas',
  CCR.PrefsIniFile.Apple in '..\..\CCR.PrefsIniFile.Apple.pas',
  CCR.PrefsIniFile in '..\..\CCR.PrefsIniFile.pas',
  MobilePrefsForm in 'MobilePrefsForm.pas' {frmMobilePrefs};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMobilePrefs, frmMobilePrefs);
  Application.Run;
end.
