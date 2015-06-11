unit ShellUtils;

interface

procedure ShellOpen(const FileName: string);

implementation

{$IFDEF MSWINDOWS}
uses WinApi.Windows, WinApi.ShellApi;
{$ENDIF}
{$IFDEF MACOS}
uses Posix.StdLib, System.StrUtils;
{$ENDIF}

procedure ShellOpen(const FileName: string);
begin
{$IFDEF MSWINDOWS}
  ShellExecute(0, nil, PChar(FileName), nil, nil, SW_SHOWNORMAL)
{$ELSE}
  _system(PAnsiChar(UTF8String('open "' +
    ReplaceStr(ReplaceStr(FileName, '\', '\\'), '"', '\"') + '"')));
{$ENDIF};
end;

end.
