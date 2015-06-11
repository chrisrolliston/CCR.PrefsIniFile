{**************************************************************************************}
{                                                                                      }
{ CCR.PrefsIniFile: CreateUserPreferencesIniFile function                              }
{                                                                                      }
{ The contents of this file are subject to the Mozilla Public License Version 1.1      }
{ (the "License"); you may not use this file except in compliance with the License.    }
{ You may obtain a copy of the License at http://www.mozilla.org/MPL/                  }
{                                                                                      }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT   }
{ WARRANTY OF ANY KIND, either express or implied. See the License for the specific    }
{ language governing rights and limitations under the License.                         }
{                                                                                      }
{ The Initial Developer of the Original Code is Chris Rolliston. Portions created by   }
{ Chris Rolliston are Copyright (C) 2013-15 Chris Rolliston. All Rights Reserved.      }
{                                                                                      }
{**************************************************************************************}

unit CCR.PrefsIniFile;

interface

uses
  System.SysUtils, System.IniFiles;

{$SCOPEDENUMS ON}
type
  TWinLocation = (IniFile, Registry);

function CreateUserPreferencesIniFile(AWinLocation: TWinLocation = TWinLocation.Registry): TCustomIniFile;

implementation

{$IFDEF ANDROID}
uses CCR.PrefsIniFile.Android;

function CreateUserPreferencesIniFile(AWinLocation: TWinLocation): TCustomIniFile;
begin
  Result := TAndroidPreferencesIniFile.Create;
end;
{$ENDIF}

{$IFDEF MACOS}
uses CCR.PrefsIniFile.Apple;

function CreateUserPreferencesIniFile(AWinLocation: TWinLocation): TCustomIniFile;
begin
  Result := TApplePreferencesIniFile.Create;
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
uses Winapi.Windows, System.Win.Registry;

function CreateUserPreferencesIniFile(AWinLocation: TWinLocation = TWinLocation.Registry): TCustomIniFile;
var
  CompanyName, ProductName, Path: string;
  {$IFDEF MSWINDOWS}
  Handle, Len: DWORD;
  Data: TBytes;
  CP: PWordArray;
  CharPtr: PChar;
  {$ENDIF}
begin
  Path := GetModuleName(0);
  ProductName := ChangeFileExt(ExtractFileName(Path), '');
  {$IFDEF MSWINDOWS}
  SetLength(Data, GetFileVersionInfoSize(PChar(Path), Handle));
  if GetFileVersionInfo(PChar(Path), Handle, Length(Data), Data) and
     VerQueryValue(Data, 'VarFileInfo\Translation', Pointer(CP), Len) then
  begin
    FmtStr(Path, 'StringFileInfo\%.4x%.4x\', [CP[0], CP[1]]);
    if VerQueryValue(Data, PChar(Path + 'CompanyName'), Pointer(CharPtr), Len) then
      SetString(CompanyName, CharPtr, Len - 1);
    if VerQueryValue(Data, PChar(Path + 'ProductName'), Pointer(CharPtr), Len) then
      SetString(ProductName, CharPtr, Len - 1);
  end;
  {$ENDIF}
  if CompanyName = '' then
    Path := ProductName
  else
    Path := CompanyName + PathDelim + ProductName;
  {$IF DECLARED(TRegistryIniFile)}
  if AWinLocation = TWinLocation.Registry then
  begin
    Result := TRegistryIniFile.Create('Software\' + Path);
    Exit;
  end;
  {$IFEND}
  Path := IncludeTrailingPathDelimiter(GetHomePath) + Path;
  ForceDirectories(Path);
  Result := TMemIniFile.Create(Path + PathDelim + 'Preferences.ini', TEncoding.UTF8);
end;
{$ENDIF}
end.