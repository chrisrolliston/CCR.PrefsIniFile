{**************************************************************************************}
{                                                                                      }
{ CCR.PrefsIniFile: TAndroidPreferencesIniFile                                         }
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
{ Chris Rolliston are Copyright (C) 2013 Chris Rolliston. All Rights Reserved.         }
{                                                                                      }
{**************************************************************************************}

unit CCR.PrefsIniFile.Android;
{
  Maps the TCustomIniFile interface to the Android shared preferences API.
  NB: as that API is case sensitive, so to is this wrapper.
}
interface

uses
  System.SysUtils, System.Classes, System.IniFiles, System.Rtti, System.Generics.Collections
  {$IFDEF ANDROID}, AndroidApi.JniBridge, AndroidApi.Jni.JavaTypes, AndroidApi.Jni.App,
  AndroidApi.Jni.GraphicsContentViewText, AndroidApi.Log, FMX.Helpers.Android{$ENDIF};

type
  TAndroidPreferencesIniFile = class(TCustomIniFile)
  {$IFDEF ANDROID}
  strict private class var
    FormatSettings: TFormatSettings;
    class constructor InitializeClass;
  strict private type
    TEnumerateKeysCallback = reference to procedure (const JKeyName: JString;
      const Section, Ident: string);
  strict private
    FDelimiter: Char;
    FEditor: JSharedPreferences_Editor;
    FSharedPrefs: JSharedPreferences;
    FMap: JMap;
    procedure NeedMap;
    procedure EnumerateKeys(const Callback: TEnumerateKeysCallback);
  protected
    destructor Destroy; override;
  public
    const DefaultDelimiter = '|';
    constructor Create(const Name: string = '');
    function Editor: JSharedPreferences_Editor;
    function JKeyName(const Section, Ident: string): JString; inline;
    procedure DeleteKey(const Section: string; const Ident: string); override;
    procedure EraseSection(const SectionToErase: string); override;
    function ReadBool(const Section, Name: string; Default: Boolean): Boolean; override;
    function ReadFloat(const Section, Name: string; Default: Double): Double; override;
    function ReadInteger(const Section, Ident: string; Default: Integer): Integer; override;
    function ReadString(const Section, Ident, Default: string): string; override;
    procedure ReadSection(const SectionToRead: string; Strings: TStrings); override;
    procedure ReadSections(Strings: TStrings); override;
    procedure ReadSectionValues(const SectionToRead: string; Strings: TStrings); override;
    function ValueExists(const Section, Ident: string): Boolean; override;
    procedure WriteBool(const Section, Ident: string; Value: Boolean); override;
    procedure WriteFloat(const Section, Ident: string; Value: Double); override;
    procedure WriteInteger(const Section, Ident: string; Value: Integer); override;
    procedure WriteString(const Section, Ident, Value: string); override;
    procedure UpdateFile; override;
    property Delimiter: Char read FDelimiter write FDelimiter default DefaultDelimiter;
    property SharedPreferences: JSharedPreferences read FSharedPrefs;
  end;
  {$ELSE}
  public
    constructor Create(const Name: string = '');
  end platform;
  {$ENDIF}

implementation

{$IFNDEF ANDROID}
resourcestring
  SNotSupportedError = 'TAndroidPreferencesIniFile only supported when targeting Android';

constructor TAndroidPreferencesIniFile.Create(const Name: string = '');
begin
  raise ENotSupportedException.CreateRes(@SNotSupportedError);
end;

{$ELSE}

{$IF RTLVersion >= 29}
uses AndroidApi.Helpers;
{$ENDIF}

type
  Context = record const
    MODE_PRIVATE = 0;
  end;

class constructor TAndroidPreferencesIniFile.InitializeClass;
begin
  FormatSettings := TFormatSettings.Create('en-us');
end;

constructor TAndroidPreferencesIniFile.Create(const Name: string = '');
begin
  inherited Create(Name);
  FDelimiter := DefaultDelimiter;
  if Name = '' then
    FSharedPrefs := SharedActivity.getPreferences(Context.MODE_PRIVATE)
  else
    FSharedPrefs := SharedActivity.getSharedPreferences(StringToJString(Name),
      Context.MODE_PRIVATE);
end;

destructor TAndroidPreferencesIniFile.Destroy;
begin
  UpdateFile;
  inherited;
end;

function TAndroidPreferencesIniFile.Editor: JSharedPreferences_Editor;
begin
  if FEditor = nil then
  begin
    FEditor := FSharedPrefs.edit;
    FMap := nil;
  end;
  Result := FEditor;
end;

procedure TAndroidPreferencesIniFile.EnumerateKeys(
  const Callback: TEnumerateKeysCallback);
var
  Iterator: JIterator;
  I: Integer;
  JStr: JString;
  S: string;
begin
  NeedMap;
  Iterator := FMap.keySet.iterator;
  while Iterator.hasNext do
  begin
    JStr := Iterator.next.toString;
    S := JStringToString(JStr);
    I := S.IndexOf(Delimiter);
    if I >= 0 then
      Callback(JStr, S.Substring(0, I), S.Substring(I + 1));
  end;
end;

function TAndroidPreferencesIniFile.JKeyName(const Section, Ident: string): JString;
begin
  Result := StringToJString(Section + Delimiter + Ident);
end;

procedure TAndroidPreferencesIniFile.NeedMap;
begin
  UpdateFile;
  if FMap = nil then FMap := FSharedPrefs.getAll;
end;

procedure TAndroidPreferencesIniFile.DeleteKey(const Section, Ident: string);
begin
  { 'Note that when committing back to the preferences, all removals are done first,
    regardless of whether you called remove before or after put methods on this editor.'
    http://developer.android.com/reference/android/content/SharedPreferences.Editor.html#remove(java.lang.String) }
  UpdateFile;
  Editor.remove(JKeyName(Section, Ident));
  UpdateFile;
end;

procedure TAndroidPreferencesIniFile.EraseSection(const SectionToErase: string);
var
  Key: JString;
  KeysToKill: TList<JString>;
begin
  KeysToKill := TList<JString>.Create;
  EnumerateKeys(
    procedure (const Key: JString; const Section, Ident: string)
    begin
      if Section = SectionToErase then KeysToKill.Add(Key);
    end);
  UpdateFile; //see comment in DeleteKey
  for Key in KeysToKill do
    Editor.remove(Key);
  UpdateFile; //ditto
end;

function TAndroidPreferencesIniFile.ReadBool(const Section, Name: string; Default: Boolean): Boolean;
var
  Float: Double;
begin
  Float := ReadFloat(Section, Name, Ord(Default));
  if Frac(Float) = 0 then
    Result := (Float <> 0)
  else
    Result := Default;
end;

function TAndroidPreferencesIniFile.ReadFloat(const Section, Name: string; Default: Double): Double;
var
  ClassName: string;
  Obj: JObject;
  ID: Pointer;
begin
  NeedMap;
  Obj := FMap.get(JKeyName(Section, Name));
  if Obj = nil then Exit(Default);
  ID := (Obj as ILocalObject).GetObjectID;
  ClassName := JStringToString(Obj.getClass.getName);
  if ClassName = 'java.lang.Float' then
    Result := TJNIResolver.GetRawValueFromJFloat(ID)
  else if ClassName = 'java.lang.Integer' then
    Result := TJNIResolver.GetRawValueFromJInteger(ID)
  else if ClassName = 'java.lang.Boolean' then
    Result := Ord(TJNIResolver.GetRawValueFromJBoolean(ID))
  else
    Result := StrToFloatDef(JStringToString(Obj.toString), Default, FormatSettings)
end;

function TAndroidPreferencesIniFile.ReadInteger(const Section, Ident: string;
  Default: Integer): Integer;
var
  Value: Int64;
begin
  Value := Round(ReadFloat(Section, Ident, Default));
  if (Value >= Result.MinValue) and (Value <= Result.MaxValue) then
    Result := Value
  else
    Result := Default;
end;

procedure TAndroidPreferencesIniFile.ReadSection(const SectionToRead: string;
  Strings: TStrings);
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    EnumerateKeys(
      procedure (const Key: JString; const Section, Name: string)
      begin
        if Section = SectionToRead then
          Strings.Add(Name);
      end);
  finally
    Strings.EndUpdate;
  end;
end;

procedure TAndroidPreferencesIniFile.ReadSections(Strings: TStrings);
var
  Sections: TDictionary<string, Byte>;
begin
  Sections := TDictionary<string, Byte>.Create;
  EnumerateKeys(
    procedure (const Key: JString; const Section, Name: string)
    begin
      Sections.AddOrSetValue(Section, 0);
    end);
  Strings.BeginUpdate;
  try
    Strings.Clear;
    Strings.AddStrings(Sections.Keys.ToArray);
  finally
    Strings.EndUpdate;
  end;
end;

procedure TAndroidPreferencesIniFile.ReadSectionValues(const SectionToRead: string; Strings: TStrings);
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    EnumerateKeys(
      procedure (const Key: JString; const Section, Name: string)
      begin
        if Section = SectionToRead then
          Strings.Add(Name + Strings.NameValueSeparator + JStringToString(FMap.get(Key).toString));
      end);
  finally
    Strings.EndUpdate;
  end;
end;

function TAndroidPreferencesIniFile.ReadString(const Section, Ident, Default: string): string;
var
  Obj: JObject;
begin
  NeedMap;
  Obj := FMap.get(JKeyName(Section, Ident));
  if Obj <> nil then
    Result := JStringToString(Obj.toString)
  else
    Result := Default;
end;

procedure TAndroidPreferencesIniFile.UpdateFile;
begin
  if FEditor = nil then Exit;
  FEditor.apply;
  FEditor := nil;
end;

function TAndroidPreferencesIniFile.ValueExists(const Section, Ident: string): Boolean;
begin
  Result := FSharedPrefs.contains(JKeyName(Section, Ident))
end;

procedure TAndroidPreferencesIniFile.WriteBool(const Section, Ident: string;
  Value: Boolean);
begin
  Editor.putBoolean(JKeyName(Section, Ident), Value)
end;

procedure TAndroidPreferencesIniFile.WriteFloat(const Section, Ident: string;
  Value: Double);
begin
  if (Value >= Single.MinValue) and (Value <= Single.MaxValue) then
    Editor.putFloat(JKeyName(Section, Ident), Value)
  else
    WriteString(Section, Ident, FloatToStr(Value, FormatSettings));
end;

procedure TAndroidPreferencesIniFile.WriteInteger(const Section, Ident: string;
  Value: Integer);
begin
  Editor.putInt(JKeyName(Section, Ident), Value)
end;

procedure TAndroidPreferencesIniFile.WriteString(const Section, Ident,
  Value: string);
begin
  Editor.putString(JKeyName(Section, Ident), StringToJString(Value));
end;
{$ENDIF}

end.