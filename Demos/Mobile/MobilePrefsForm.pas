unit MobilePrefsForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.IniFiles,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Edit, CCR.PrefsIniFile;

type
  TfrmMobilePrefs = class(TForm)
    Label1: TLabel;
    edtSection: TEdit;
    Label2: TLabel;
    edtKey: TEdit;
    Label3: TLabel;
    edtValue: TEdit;
    lyoReadWriteButtons: TGridLayout;
    btnReadBool: TButton;
    btnWriteBool: TButton;
    btnReadFloat: TButton;
    btnWriteFloat: TButton;
    btnReadInt: TButton;
    btnWriteInt: TButton;
    btnReadStr: TButton;
    btnWriteStr: TButton;
    btnReadSection: TButton;
    btnReadSectionVals: TButton;
    btnReadSections: TButton;
    btnUpdateFile: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnReadBoolClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnReadFloatClick(Sender: TObject);
    procedure btnReadIntClick(Sender: TObject);
    procedure btnReadStrClick(Sender: TObject);
    procedure btnReadSectionClick(Sender: TObject);
    procedure btnReadSectionValsClick(Sender: TObject);
    procedure btnReadSectionsClick(Sender: TObject);
    procedure btnWriteBoolClick(Sender: TObject);
    procedure btnWriteFloatClick(Sender: TObject);
    procedure btnWriteIntClick(Sender: TObject);
    procedure btnWriteStrClick(Sender: TObject);
    procedure btnUpdateFileClick(Sender: TObject);
  private
    FIniFile: TCustomIniFile;
    procedure ReportValue(const Value: string);
  end;

var
  frmMobilePrefs: TfrmMobilePrefs;

implementation

{$R *.fmx}

procedure TfrmMobilePrefs.FormCreate(Sender: TObject);
begin
  FIniFile := CreateUserPreferencesIniFile;
end;

procedure TfrmMobilePrefs.FormDestroy(Sender: TObject);
begin
  FIniFile.Free;
end;

procedure TfrmMobilePrefs.FormResize(Sender: TObject);
begin
  lyoReadWriteButtons.ItemWidth := lyoReadWriteButtons.Width / 2;
end;

procedure TfrmMobilePrefs.ReportValue(const Value: string);
begin
  ShowMessageFmt('The value for %s -> %s is %s', [edtSection.Text, edtKey.Text, Value]);
end;

procedure TfrmMobilePrefs.btnReadBoolClick(Sender: TObject);
const
  Strs: array[Boolean] of string = ('False', 'True');
begin
  ReportValue(Strs[FIniFile.ReadBool(edtSection.Text, edtKey.Text, StrToBoolDef(edtValue.Text, False))]);
end;

procedure TfrmMobilePrefs.btnReadFloatClick(Sender: TObject);
begin
  ReportValue(FIniFile.ReadFloat(edtSection.Text, edtKey.Text, StrToFloatDef(edtValue.Text, 0)).ToString);
end;

procedure TfrmMobilePrefs.btnReadIntClick(Sender: TObject);
begin
  ReportValue(FIniFile.ReadInteger(edtSection.Text, edtKey.Text, StrToIntDef(edtValue.Text, 0)).ToString);
end;

procedure TfrmMobilePrefs.btnReadSectionClick(Sender: TObject);
var
  Strings: TStringList;
begin
  Strings := TStringList.Create;
  FIniFile.ReadSection(edtSection.Text, Strings);
  if Strings.Count = 0 then
    ShowMessage('The specified section either does not exist or has no keys.')
  else
  begin
    Strings.Insert(0, 'The specified section has the following keys:');
    ShowMessage(Strings.Text);
  end;
end;

procedure TfrmMobilePrefs.btnReadSectionsClick(Sender: TObject);
var
  Strings: TStringList;
begin
  Strings := TStringList.Create;
  FIniFile.ReadSections(edtSection.Text, Strings);
  if Strings.Count = 0 then
    ShowMessage('The preferences data is either empty or contains no recognised sections.')
  else
  begin
    Strings.Insert(0, 'The preferences data contains the following sections:');
    ShowMessage(Strings.Text);
  end;
end;

procedure TfrmMobilePrefs.btnReadSectionValsClick(Sender: TObject);
var
  Strings: TStringList;
begin
  Strings := TStringList.Create;
  FIniFile.ReadSectionValues(edtSection.Text, Strings);
  if Strings.Count = 0 then
    ShowMessage('The specified section either does not exist or has no keys.')
  else
  begin
    Strings.Insert(0, 'The specified section has the following key/value pairs:');
    ShowMessage(Strings.Text);
  end;
end;

procedure TfrmMobilePrefs.btnReadStrClick(Sender: TObject);
begin
  ReportValue('''' + FIniFile.ReadString(edtSection.Text, edtKey.Text, edtValue.Text) + '''');
end;

procedure TfrmMobilePrefs.btnUpdateFileClick(Sender: TObject);
begin
  FIniFile.UpdateFile;
end;

procedure TfrmMobilePrefs.btnWriteBoolClick(Sender: TObject);
begin
  FIniFile.WriteBool(edtSection.Text, edtKey.Text, StrToBoolDef(edtValue.Text, False));
end;

procedure TfrmMobilePrefs.btnWriteFloatClick(Sender: TObject);
begin
  FIniFile.WriteFloat(edtSection.Text, edtKey.Text, StrToFloatDef(edtValue.Text, 0));
end;

procedure TfrmMobilePrefs.btnWriteIntClick(Sender: TObject);
begin
  FIniFile.WriteInteger(edtSection.Text, edtKey.Text, StrToIntDef(edtValue.Text, 0));
end;

procedure TfrmMobilePrefs.btnWriteStrClick(Sender: TObject);
begin
  FIniFile.WriteString(edtSection.Text, edtKey.Text, edtValue.Text);
end;

end.