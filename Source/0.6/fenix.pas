// Fenix ScreenShoter 0.6
// © Ismael Heredia, Argentina , 2017

unit fenix;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, ShellApi,
  Jpeg, IdMultipartFormData, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, PerlRegEx, Vcl.Menus,
  Vcl.Imaging.GIFImg, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TFormHome = class(TForm)
    pcOptions: TPageControl;
    tsUploadImageImageShack: TTabSheet;
    tsUploadScreenshot: TTabSheet;
    tsResult: TTabSheet;
    ssStatus: TStatusBar;
    gbEnterImage: TGroupBox;
    btnLoad: TButton;
    GroupBox2: TGroupBox;
    btnUpload: TButton;
    gbOptions: TGroupBox;
    cbSavePhotoThisName: TCheckBox;
    txtName: TEdit;
    cbGetPhotoInSeconds: TCheckBox;
    txtSeconds: TEdit;
    Label1: TLabel;
    cbOnlyTakeScreenshot: TCheckBox;
    GroupBox4: TGroupBox;
    btnTakeScreenAndUpload: TButton;
    gbName: TGroupBox;
    Button4: TButton;
    gbLink: TGroupBox;
    Button5: TButton;
    tsPhotosFound: TTabSheet;
    gbPhotosFound: TGroupBox;
    lvPhotosFound: TListView;
    txtEnterImage: TEdit;
    txtResultName: TEdit;
    txtLink: TEdit;
    odOpenImage: TOpenDialog;
    ppOptions: TPopupMenu;
    RefreshList1: TMenuItem;
    lbPhotos: TListBox;
    OpenPhoto1: TMenuItem;
    tsAbout: TTabSheet;
    GroupBox8: TGroupBox;
    imgAbout: TImage;
    mmAbout: TMemo;
    imgLogo: TImage;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnTakeScreenAndUploadClick(Sender: TObject);
    procedure btnUploadClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure RefreshList1Click(Sender: TObject);
    procedure listar_screenshots;
    procedure lvPhotosFoundDblClick(Sender: TObject);
    procedure OpenPhoto1Click(Sender: TObject);
  private
    procedure DragDropFile(var Msg: TMessage); message WM_DROPFILES;
  public
    { Public declarations }
  end;

var
  FormHome: TFormHome;

implementation

{$R *.dfm}

procedure screenshot(filename: string);

var
  var1: HDC;
  var2: TRect;
  var3: TPoint;
  var4: TBitmap;
  var5: TJpegImage;
  var6: THandle;

begin

  var1 := GetWindowDC(GetDesktopWindow);
  var4 := TBitmap.Create;

  GetWindowRect(GetDesktopWindow, var2);
  var4.Width := var2.Right - var2.Left;
  var4.Height := var2.Bottom - var2.Top;
  BitBlt(var4.Canvas.Handle, 0, 0, var4.Width, var4.Height, var1, 0, 0,
    SRCCOPY);

  GetCursorPos(var3);

  var6 := GetCursor;
  DrawIconEx(var4.Canvas.Handle, var3.X, var3.Y, var6, 32, 32, 0, 0, DI_NORMAL);

  var5 := TJpegImage.Create;
  var5.Assign(var4);
  var5.CompressionQuality := 60;
  var5.SaveToFile(filename);

  var4.Free;
  var5.Free;

end;

//

procedure TFormHome.btnLoadClick(Sender: TObject);
begin
  if odOpenImage.Execute then
  begin
    txtEnterImage.Text := odOpenImage.filename;
  end;
end;

function upload_imageshack(image: string): string;
var

  search: TPerlRegEx;
  input: TIdMultiPartFormDataStream;
  codigo_fuente: string;
  web: TIdHTTP;
  output: string;

begin

  input := TIdMultiPartFormDataStream.Create;
  input.AddFormField('key', 'ACDEIOPU4a1f216b9cb1564f6be25957dfca92b2');
  input.AddFile('fileupload', image, 'application/octet-stream');
  input.AddFormField('format', 'json');

  web := TIdHTTP.Create(nil);
  web.Request.UserAgent :=
    'Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14';
  codigo_fuente := web.Post('http://post.imageshack.us/upload_api.php', input);

  search := TPerlRegEx.Create();

  search.regex := '"image_link":"(.*?)"';
  search.Subject := codigo_fuente;

  if search.Match then
  begin
    output := search.Groups[1];
    output := StringReplace(output, '\', '', [rfReplaceAll, rfIgnoreCase]);
  end
  else
  begin
    output := 'Error';
  end;

  web.Free;
  search.Free;

  Result := output;

end;

procedure TFormHome.btnUploadClick(Sender: TObject);
var
  output: string;

begin

  ssStatus.Panels[0].Text := 'Uploading ...';
  FormHome.ssStatus.Update;

  if (FileExists(txtEnterImage.Text)) then
  begin
    output := upload_imageshack(txtEnterImage.Text);
    if (output = 'Error') then
    begin
      ShowMessage('Error');
    end
    else
    begin
      txtResultName.Text := txtEnterImage.Text;
      txtLink.Text := output;
    end;
  end
  else
  begin
    ShowMessage('The image not exists');
  end;

  ssStatus.Panels[0].Text := 'Finished';
  FormHome.ssStatus.Update;

end;

procedure TFormHome.btnTakeScreenAndUploadClick(Sender: TObject);
var
  nombre_final: string;
  data1: TDateTime;
  data2: string;
  data3: string;
  int1: integer;
  output: string;
begin

  if (cbSavePhotoThisName.Checked = True) then
  begin
    nombre_final := txtName.Text;
  end
  else
  begin
    data1 := now();
    data2 := DateTimeToStr(data1);
    data3 := data2 + '.jpg';
    data3 := StringReplace(data3, '/', ':', [rfReplaceAll, rfIgnoreCase]);
    data3 := StringReplace(data3, ' ', '', [rfReplaceAll, rfIgnoreCase]);
    data3 := StringReplace(data3, ':', '_', [rfReplaceAll, rfIgnoreCase]);
    nombre_final := 'screenshot_' + data3;
  end;

  if (cbGetPhotoInSeconds.Checked) then
  begin
    for int1 := StrToInt(txtSeconds.Text) downto 1 do
    begin
      ssStatus.Panels[0].Text := 'ScreenShot in ' + IntToStr(int1) +
        ' seconds ';
      FormHome.ssStatus.Update;
      Sleep(int1 * 1000);
    end;
  end;

  FormHome.Hide;
  Sleep(1000);

  screenshot(nombre_final);

  FormHome.Show;

  if not(cbOnlyTakeScreenshot.Checked) then
  begin

    ssStatus.Panels[0].Text := 'Uploading ...';
    FormHome.ssStatus.Update;

    // Uploaded

    if (FileExists(nombre_final)) then
    begin
      output := upload_imageshack(nombre_final);
      if (output = 'Error') then
      begin
        ShowMessage('Error');
      end
      else
      begin
        txtResultName.Text := ExtractFilePath(Application.ExeName) +
          '\screenshots\' + nombre_final;
        txtLink.Text := output;
      end;
    end
    else
    begin
      ShowMessage('The image not exists');
    end;

    ssStatus.Panels[0].Text := 'ScreenShot Uploaded';
    FormHome.ssStatus.Update;

  end
  else
  begin

    ssStatus.Panels[0].Text := 'ScreenShot Taked';
    FormHome.ssStatus.Update;
  end;

  listar_screenshots;

end;

procedure TFormHome.Button4Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', Pchar(txtResultName.Text), nil, nil,
    SW_SHOWNORMAL);
end;

procedure TFormHome.Button5Click(Sender: TObject);
begin
  txtLink.SelectAll;
  txtLink.CopyToClipboard;
end;

procedure TFormHome.DragDropFile(var Msg: TMessage);
var
  numero2: integer;
  numero1: integer;
  ruta: array [0 .. MAX_COMPUTERNAME_LENGTH + MAX_PATH] of char;
begin
  numero2 := DragQueryFile(Msg.WParam, $FFFFFFFF, ruta, 255) - 1;
  for numero1 := 0 to numero2 do
  begin
    DragQueryFile(Msg.WParam, numero1, ruta, 255);
    txtEnterImage.Text := ruta;
  end;
  DragFinish(Msg.WParam);
end;

procedure TFormHome.FormCreate(Sender: TObject);
var
  saved: string;
begin

  DragAcceptFiles(Handle, True);
  odOpenImage.InitialDir := GetCurrentDir;

  saved := ExtractFilePath(Application.ExeName) + '/screenshots';

  if not(DirectoryExists(saved)) then
  begin
    CreateDir(saved);
  end;

  ChDir(saved);

  listar_screenshots;

end;

procedure TFormHome.listar_screenshots;
var
  search: TSearchRec;
  ext: string;
  fecha1: integer;
begin

  lvPhotosFound.Items.Clear();
  lbPhotos.Items.Clear();
  FindFirst(ExtractFilePath(Application.ExeName) + '\screenshots\*.*',
    faAnyFile, search);
  while FindNext(search) = 0 do
  begin
    ext := ExtractFileExt(search.Name);
    if (ext = '.jpg') or (ext = '.jpeg') or (ext = '.png') or (ext = '.bmp')
    then
    begin
      with lvPhotosFound.Items.Add do
      begin
        fecha1 := FileAge(ExtractFilePath(Application.ExeName) + '\screenshots\'
          + search.Name);
        lbPhotos.Items.Add(ExtractFilePath(Application.ExeName) +
          '\screenshots\' + search.Name);
        Caption := search.Name;
        SubItems.Add(DateToStr(FileDateToDateTime(fecha1)));
      end;
    end;
  end;
  FindClose(search);
end;

procedure TFormHome.lvPhotosFoundDblClick(Sender: TObject);
begin
  ShellExecute(0, nil, Pchar(lbPhotos.Items[lvPhotosFound.Selected.Index]), nil,
    nil, SW_SHOWNORMAL);
end;

procedure TFormHome.OpenPhoto1Click(Sender: TObject);
begin
  ShellExecute(0, nil, Pchar(lbPhotos.Items[lvPhotosFound.Selected.Index]), nil,
    nil, SW_SHOWNORMAL);
end;

procedure TFormHome.RefreshList1Click(Sender: TObject);
begin
  listar_screenshots;
end;

end.
