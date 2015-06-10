CCR.PrefsIniFile
================

Implements TCustomIniFile descendants (TAndroidPreferencesIniFile and TApplePreferencesIniFile) that delegate to the native app preferences API on Android, iOS and OS X. A factory function is also provided to allow easily creating a TCustomIniFile instance without worrying about the platform (Android/iOS/OS X/Windows).

Usage
-----

    uses
      System.IniFiles, CCR.PrefsIniFile;
    
    procedure ReadTest;
    var
      Settings: TCustomIniFile;
      Flag: Boolean;
    begin
      Settings := CreateUserPreferencesIniFile;
      try
        Flag := Settings.ReadBool('General', 'NeverShowSaveConfirmationPrompt', False);
        if Flag then //...
      finally
        Settings.Free;
      end;
    end;
    
    procedure WriteTest;
    var
      Settings: TCustomIniFile;
    begin
      Settings := CreateUserPreferencesIniFile;
      try
        Settings.WriteBool('General', 'NeverShowSaveConfirmationPrompt', True);
      finally
        Settings.Free;
      end;
    end;