unit DesktopPrefsForm;
{
  Simple demo of the TApplePreferencesIniFile class. Uses TMemIniFile instead when
  targeting Windows.

  NB - you may have to manually delete uses clause entries for FMX.StdCtrls and/or
  FMX.Controls.Presentation to compile in older versions.
}
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.IniFiles,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Edit, FMX.StdCtrls,
  FMX.Controls.Presentation;

type
  TfrmDesktopPrefs = class(TForm)
    edtSection: TEdit;
    Label1: TLabel;
    edtKey: TEdit;
    Label2: TLabel;
    edtValue: TEdit;
    Label3: TLabel;
    btnWriteAsBoolean: TButton;
    btnWriteAsFloat: TButton;
    btnWriteAsInt: TButton;
    btnWriteAsStr: TButton;
    btnUpdateFile: TButton;
    btnReadAsBool: TButton;
    btnReadAsFloat: TButton;
    btnReadAsInt: TButton;
    btnReadAsStr: TButton;
    ImageControl1: TImageControl;
    btnImageRoundtrip: TButton;
    btnOpenFile: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnWriteAsBooleanClick(Sender: TObject);
    procedure btnWriteAsFloatClick(Sender: TObject);
    procedure btnWriteAsIntClick(Sender: TObject);
    procedure btnWriteAsStrClick(Sender: TObject);
    procedure btnReadAsBoolClick(Sender: TObject);
    procedure btnReadAsFloatClick(Sender: TObject);
    procedure btnReadAsIntClick(Sender: TObject);
    procedure btnReadAsStrClick(Sender: TObject);
    procedure btnUpdateFileClick(Sender: TObject);
    procedure btnImageRoundtripClick(Sender: TObject);
    procedure btnOpenFileClick(Sender: TObject);
  private
    FIniFile: TCustomIniFile;
  end;

var
  frmDesktopPrefs: TfrmDesktopPrefs;

implementation

uses
  CCR.PrefsIniFile, ShellUtils;

{$R *.fmx}

procedure TfrmDesktopPrefs.FormCreate(Sender: TObject);
begin
  FIniFile := CreateUserPreferencesIniFile(TWinLocation.IniFile);
end;

procedure TfrmDesktopPrefs.FormDestroy(Sender: TObject);
begin
  FIniFile.Free;
end;

procedure TfrmDesktopPrefs.btnImageRoundtripClick(Sender: TObject);
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    ImageControl1.Bitmap.SaveToStream(Stream);
    Stream.Position := 0;
    FIniFile.WriteBinaryStream('Images', 'Coffee cup', Stream);
    Stream.Clear;
    {$IF RTLVersion >= 28}
    ImageControl1.Bitmap.Assign(nil);
    {$ELSE}
    ImageControl1.Bitmap.Clear(0);
    {$ENDIF}
    MessageDlg('Click OK to reload...', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
    FIniFile.ReadBinaryStream('Images', 'Coffee cup', Stream);
    Stream.Position := 0;
    ImageControl1.Bitmap.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TfrmDesktopPrefs.btnWriteAsBooleanClick(Sender: TObject);
begin
  FIniFile.WriteBool(edtSection.Text, edtKey.Text, StrToBool(edtValue.Text));
end;

procedure TfrmDesktopPrefs.btnWriteAsFloatClick(Sender: TObject);
begin
  FIniFile.WriteFloat(edtSection.Text, edtKey.Text, StrToFloat(edtValue.Text));
end;

procedure TfrmDesktopPrefs.btnWriteAsIntClick(Sender: TObject);
begin
  FIniFile.WriteInteger(edtSection.Text, edtKey.Text, StrToInt(edtValue.Text));
end;

procedure TfrmDesktopPrefs.btnWriteAsStrClick(Sender: TObject);
begin
  FIniFile.WriteString(edtSection.Text, edtKey.Text, edtValue.Text);
end;

procedure TfrmDesktopPrefs.btnUpdateFileClick(Sender: TObject);
begin
  FIniFile.UpdateFile;
end;

procedure TfrmDesktopPrefs.btnOpenFileClick(Sender: TObject);
begin
  if FileExists(FIniFile.FileName) then
    ShellOpen(FIniFile.FileName)
  else
    MessageDlg('Preferences file does not exist yet - try clicking "Flush Changes to Disk" first.',
      TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
end;

procedure TfrmDesktopPrefs.btnReadAsBoolClick(Sender: TObject);
begin
  edtValue.Text := BoolToStr(FIniFile.ReadBool(edtSection.Text, edtKey.Text, False), True)
end;

procedure TfrmDesktopPrefs.btnReadAsFloatClick(Sender: TObject);
begin
  edtValue.Text := FloatToStr(FIniFile.ReadFloat(edtSection.Text, edtKey.Text, 0))
end;

procedure TfrmDesktopPrefs.btnReadAsIntClick(Sender: TObject);
begin
  edtValue.Text := IntToStr(FIniFile.ReadInteger(edtSection.Text, edtKey.Text, 0))
end;

procedure TfrmDesktopPrefs.btnReadAsStrClick(Sender: TObject);
begin
  edtValue.Text := FIniFile.ReadString(edtSection.Text, edtKey.Text, '')
end;

end.
