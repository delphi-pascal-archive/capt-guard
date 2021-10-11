unit Ccntrol1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Jpeg, ComCtrls, Mask, Shellapi;

type
  TForm1 = class(TForm)
    Connect: TButton;
    Timer1: TTimer;
    Panel1: TPanel;
    Image1: TImage;
    Bevel1: TBevel;
    Bevel2: TBevel;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Label4: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    CheckBox4: TCheckBox;
    Panel2: TPanel;
    Bevel3: TBevel;
    Label9: TLabel;
    Label10: TLabel;
    fDrivers: TComboBox;
    MaskEdit1: TMaskEdit;
    RadioGroup1: TRadioGroup;
    Stop: TButton;
    Start: TButton;
    GroupBox2: TGroupBox;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    Panel3: TPanel;
    Button1: TButton;
    LabelR2: TLabel;
    Label8: TLabel;
    TrackBar3: TTrackBar;
    LabelR1: TLabel;
    Label7: TLabel;
    TrackBar2: TTrackBar;
    Label1: TLabel;
    Label5: TLabel;
    TrackBar1: TTrackBar;
    Label11: TLabel;
    DELFILES: TButton;
    ComboBox1: TComboBox;
    StaticText4: TStaticText;
    Bevel4: TBevel;
    Label12: TLabel;
    Driver: TButton;
    procedure FormShow(Sender: TObject);
    procedure ConnectClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure StartClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure LabelR1Click(Sender: TObject);
    procedure LabelR2Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure DriverClick(Sender: TObject);
    procedure fDriversChange(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
    procedure StaticText2Click(Sender: TObject);
    procedure StaticText3Click(Sender: TObject);
    procedure StaticText4Click(Sender: TObject);
    procedure DELFILESClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);

  private
    { Private declarations }   
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  DC    : HWND;
  Bt    : BITMAPINFO; 
  h_cam : HDC;
  buf   : array [0..640 * 480 * 3] of Byte; // изображение-эталон
  first : Boolean;
  SENS  : Byte = 110;
  cont:boolean=true;
  sum    : Single=0;
  sums    : Single;
  su:integer=0;
  x1,x2,y1,y2:integer;
  x11,x12,y11,y12:integer;
  x21,x22,y21,y22:integer;
  tf:integer=0;
  r1:integer=0;
  r2:integer=0;
  wl:integer=0;
  vin:integer=0;
  cfl:integer;
  kz:integer=4;
  colfot,zon:string;
  FName:string;
implementation

{$R *.dfm}
//********************************************
const
  AVICAPDLL   = 'AVICAP32.DLL';
  WM_CAP_START                    = WM_USER;
  WM_CAP_SET_CALLBACK_FRAME       = WM_CAP_START + 5;
  WM_CAP_DRIVER_CONNECT           = WM_CAP_START + 10;
  WM_CAP_DRIVER_DISCONNECT        = WM_CAP_START + 11;
  WM_CAP_DLG_VIDEOFORMAT          = WM_CAP_START + 41;
  WM_CAP_GET_VIDEOFORMAT          = WM_CAP_START + 44;
  WM_CAP_SET_VIDEOFORMAT          = WM_CAP_START + 45;
  WM_CAP_SET_SCALE                = WM_CAP_START + 53;
  WM_CAP_GET_STATUS               = WM_CAP_START + 54;
  WM_CAP_GRAB_FRAME               = WM_CAP_START + 60;
  WM_CAP_STOP                     = WM_CAP_START + 68;
  WM_CAP_SET_PREVIEW              = WM_CAP_START + 50;
  WM_CAP_DLG_VIDEOSOURCE          = WM_CAP_START + 42;
  WM_CAP_SAVEDIB                  = WM_CAP_START + 25;
  WM_CAP_SET_OVERLAY              = WM_CAP_START + 51;
function    capCreateCaptureWindowA(
    lpszWindowName      : LPCSTR;
    dwStyle             : DWORD;
    x, y                : Integer;
    nWidth, nHeight     : Integer;
    hwndParent          : HWND;
    nID                 : Integer): HWND; stdcall; external AVICAPDLL;

type
  PVIDEOHDR = ^TVIDEOHDR;
  TVIDEOHDR = record
    lpData              : PBYTE;                // pointer to locked data buffer
    dwBufferLength      : DWORD;                // Length of data buffer
    dwBytesUsed         : DWORD;                // Bytes actually used
    dwTimeCaptured      : DWORD;                // Milliseconds from start of stream
    dwUser              : DWORD;                // for client's use
    dwFlags             : DWORD;                // assorted flags (see defines)
    dwReserved          : array[0..3] of DWORD; // reserved for driver
  end;

  PCAPSTATUS                      = ^TCAPSTATUS;
  TCAPSTATUS                      = record
    uiImageWidth                : UINT    ; // Width of the image
    uiImageHeight               : UINT    ; // Height of the image
    fLiveWindow                 : BOOL    ; // Now Previewing video?
    fOverlayWindow              : BOOL    ; // Now Overlaying video?
    fScale                      : BOOL    ; // Scale image to client?
    ptScroll                    : TPOINT  ; // Scroll position
    fUsingDefaultPalette        : BOOL    ; // Using default driver palette?
    fAudioHardware              : BOOL    ; // Audio hardware present?
    fCapFileExists              : BOOL    ; // Does capture file exist?
    dwCurrentVideoFrame         : DWORD   ; // # of video frames cap'td
    dwCurrentVideoFramesDropped : DWORD   ; // # of video frames dropped
    dwCurrentWaveSamples        : DWORD   ; // # of wave samples cap'td
    dwCurrentTimeElapsedMS      : DWORD   ; // Elapsed capture duration
    hPalCurrent                 : HPALETTE; // Current palette in use
    fCapturingNow               : BOOL    ; // Capture in progress?
    dwReturn                    : DWORD   ; // Error value after any operation
    wNumVideoAllocated          : UINT    ; // Actual number of video buffers
    wNumAudioAllocated          : UINT    ; // Actual number of audio buffers
  end;
(*************************************)

function capGetDriverDescriptionA(wDriverIndex:WORD;
          lpszName:pchar; cnName:integer; lpszVer:pchar;
          cbVer:integer):longbool; stdcall; external AVICAPDLL;

Procedure AddInfo(AInfo,AFinalFile : string);
Var
  MS : TMemoryStream;
begin
MS := TMemoryStream.Create;
  Try
   MS.LoadFromFile(AFinalFile);
   ms.SetSize(MS.Size+120);
   ms.Position:=MS.Size-80;
   MS.Write(PChar(AInfo)^,Length(colfot));
  Finally
  MS.SaveToFile(AFinalFile);
  FreeAndNil(MS);
  End;
end;

function ConvTojpg:DWORD;  // Конв. bmp to jpg
var
searchr:TSearchRec;
jp: TJPEGImage;
bm:TBitmap;
begin
if FindFirst('*.bmp',faAnyFile,searchr)=0 then repeat
if searchr.Attr<>0 then begin
jp:= TJPEGImage.Create;
bm:=TBitmap.Create;
if searchr.Name<>'obr.bmp' then begin
bm.LoadFromFile(searchr.Name);
jp.Assign(bm);
jp.SaveToFile(ChangeFileExt(searchr.Name,'.jpg'));
jp.Free; bm.Free;
DeleteFile(searchr.Name);
FName:=ChangeFileExt(searchr.Name,'.jpg');
AddInfo(colfot,FName);
end; end;
until(FindNext(searchr))<>0;
FindClose(searchr);
Result:=0;
end;

//== Получение и обработка кадра
function FrameCallbackA(hWnd: HWND; lpVHdr: PVIDEOHDR): DWORD; stdcall;
type
  TByteArray = array [0..1] of Byte;
  PByteArray = ^TByteArray;
var
  status : TCapStatus;
  xw,yh,p:integer;

begin
  Result := 0;
// информация об изображении
  SendMessage(h_cam, WM_CAP_GET_STATUS, SizeOf(status), Integer(@status));
// проверка на корректность формата изображения
  if (status.uiImageWidth > 640) or (status.uiImageHeight > 480) or
(lpVhdr^.dwBytesUsed div (status.uiImageWidth * status.uiImageHeight) <> 3) then   Exit;

// получаем эталон
  if first then
  begin
    Move(lpVHdr^.lpData^, buf, lpVhdr^.dwBytesUsed);
    first := False;
  end;

// вычисление объектов:
  if cont=false then begin
  if (status.uiImageWidth=160) and (status.uiImageHeight=120) then
  kz:=1;
  if (status.uiImageWidth=320) and (status.uiImageHeight=240) then
  kz:=2;
  if (status.uiImageWidth=640) and (status.uiImageHeight=480) then
  kz:=4;
  for yh := y1*kz to  y2*kz do begin
  sum := 0;
  for xw := x1*kz to  x2*kz do begin
   //p:=xw+(480-(yh-1))*640 ;
  p:=xw+(((120*kz)-(yh-1))*160*kz) ;
  sum :=abs(buf[p * 3 ] - PbyteArray(lpVHdr^.lpData)[p * 3 ]);
   //sum := sum / 2;
  sum := sum / (0.5 * kz);
  if sum > SENS then sums:=sum;
  end; end;
  end;
// вывод результата в окно
  bt.bmiHeader.biWidth  := status.uiImageWidth;
  bt.bmiHeader.biHeight := status.uiImageHeight;
  StretchDIBits(DC, 0, 0, 640, 480, 0, 0, status.uiImageWidth,
  status.uiImageHeight, lpVHdr.lpData, bt, 0, SRCCOPY);
  colfot:='Size: '+IntToStr(status.uiImageWidth)+'x'+IntToStr(status.uiImageHeight)
end;

procedure TForm1.FormShow(Sender: TObject);
begin
DC:=Form1.Handle;
Connect.Click;
Label1.Caption:=INTTOSTR(SENS);
Label2.Caption:='Контроль: Отключен';
x11:=16; y11:=16; x12:=46; y12:=46;
x21:=118; y21:=88; x22:=148; y22:=118;
Bevel1.Left:=x11; Bevel1.Top:=y11; Bevel1.Width:=x12-x11; Bevel1.Height:=y12-y11;
Bevel2.Left:=x21; Bevel2.Top:=y21; Bevel2.Width:=x22-x21; Bevel2.Height:=y22-y21;
Label12.Caption:='Запомнить'#13'количество файлов :';
cfl:=10;
r1:=0;  r2:=0;
end;

procedure TForm1.ConnectClick(Sender: TObject);
begin
h_cam := capCreateCaptureWindowA('WDC', WS_CHILD or WS_VISIBLE, 2, 10, 640, 480, DC, 0);
if h_cam <> 0 then begin

if SendMessage(h_cam, WM_CAP_DRIVER_CONNECT, vin, 0) <> 0 then
  begin
    Bt.bmiHeader.biWidth    := 640;
    Bt.bmiHeader.biHeight   := 480;
    Bt.bmiHeader.biSize     := SizeOf(Bt.bmiHeader);
    Bt.bmiHeader.biPlanes   := 1;
    Bt.bmiHeader.biBitCount := 24;
    SendMessage(h_cam, WM_CAP_SET_CALLBACK_FRAME, 0, Integer(@FrameCallbackA));
    SendMessage(h_cam,WM_CAP_SET_SCALE,1,1);
    SendMessage(h_cam,WM_CAP_SET_OVERLAY,0,0);

    SendMessage(h_cam,
                   WM_CAP_SAVEDIB,
                   0,
                   longint(pchar('obr.bmp')));
     if FileExists('obr.bmp') then
    Image1.Picture.LoadFromFile('obr.bmp');

  end else
  begin
    MessageBox(h_cam, 'Не удалось инициализировать драйвер', nil, MB_ICONHAND);
    Exit;
  end;
  end;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
SendMessage(h_cam, WM_CAP_STOP, 0, 0);
SendMessage(h_cam, WM_CAP_DRIVER_DISCONNECT, vin, 0);
ShowWindow(h_cam,SW_HIDE);
h_cam := 0;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
str:string;
begin
if tf>3 then tf:=0;
tf:=tf+1;

if (tf=1) and (r1=1) then begin
SENS:=TrackBar2.Position;
zon:='1';
x1:=x11; x2:=x12; y1:=y11; y2:=y12; end;
if (tf=2) and (r2=1) then begin
SENS:=TrackBar3.Position;
zon:='2';
x1:=x21; x2:=x22; y1:=y21; y2:=y22; end;
if (r2=0) and (r1=0) then begin
SENS:=TrackBar1.Position;
zon:='0';
x1:=2; x2:=158; y1:=2; y2:=118; end;
Label11.Caption:=IntToStr(SENS);

SendMessage(h_cam, WM_CAP_GRAB_FRAME, 0, 0);
      if sums>0 then begin
      Timer1.Interval:=3000;
      Label4.Caption:='Есть изменения';
      sums:=0;
      first:=false;
if RadioGroup1.ItemIndex=1 then begin
      su:=su+1;
FName:=inttostr(su)+' Z'+zon+'.bmp';

if su>cfl then begin
su:=0;
str:='Файлов заказано: '+ComboBox1.Text+''#13'Файлов сохранено '+ComboBox1.Text
+' или более.' +''#13'Будем удалять?';
if MessageDlg(str,mtConfirmation, [mbYes, mbCancel], 0) = idYes then begin
Stop.Click;
DELFILES.Click;
Start.Click;
end; end;
////////
      SendMessage(h_cam,
                   WM_CAP_SAVEDIB,
                   0,
                   longint(pchar(FName)));
      first:=true;
colfot:=colfot+' Зона № '+zon +' x1:'+IntToStr(x1*kz)+' x2:'+IntToStr(x2*kz)+' y1:'+IntToStr(y1*kz)
+' y2:'+IntToStr(y2*kz)+' SENS:'+IntToStr(sens);
ConvTojpg;
end;
end
     else begin
      Label4.Caption:='Без изменений';
      Timer1.Interval:=112;
      sums:=0;  first:=false;
      end;
      if cont then
      first := True;   //добавка для непрерывной съёмки............

end;

procedure TForm1.StartClick(Sender: TObject);
begin
SendMessage(h_cam,
                   WM_CAP_SAVEDIB,
                   0,
                   longint(pchar('obr.bmp')));
    if FileExists('obr.bmp') then
    Image1.Picture.LoadFromFile('obr.bmp');
if RadioGroup1.ItemIndex=1 then begin
cont:=false;  Label2.Caption:='Контроль: Включен';
Timer1.Enabled:=true;
SendMessage(h_cam,WM_CAP_SET_OVERLAY,0,0);
end;
if RadioGroup1.ItemIndex>1 then Timer1.Enabled:=true;
end;

procedure TForm1.StopClick(Sender: TObject);
begin
cont:=true;   Label2.Caption:='Контроль: Отключен';
Timer1.Enabled:=false;
end;


 
procedure TForm1.Label1Click(Sender: TObject);
begin     //Изменение чувствительности
SENS:=TrackBar1.Position;
Label1.Caption:=INTTOSTR(SENS);
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if RadioGroup1.ItemIndex=0 then begin
if  CheckBox1.Checked then begin
x11:=X; y11:=Y; end;
if  CheckBox2.Checked then begin
x21:=X; y21:=Y; end;
end;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if RadioGroup1.ItemIndex=0 then begin
if  CheckBox1.Checked and CheckBox2.Checked then
MessageBox(Form1.Handle, 'Не выбран регион.', 'Regions', MB_ICONHAND);
if  CheckBox1.Checked then begin
x12:=X; y12:=Y;
if x11<x12 then begin
Bevel1.Visible:=true;
Bevel1.Top:=Image1.Top+y11;  Bevel1.Left:=Image1.Left+x11;
Bevel1.Width:=x12-x11; Bevel1.Height:=y12-y11; end
else MessageBox(Form1.Handle, 'Выделять сверху вниз, слева направо.', 'Region1', MB_ICONHAND);
end;

if  CheckBox2.Checked then begin
x22:=X; y22:=Y;
if x21<x22 then begin
Bevel2.Visible:=true;
Bevel2.Top:=Image1.Top+y21;  Bevel2.Left:=Image1.Left+x21;
Bevel2.Width:=x22-x21; Bevel2.Height:=y22-y21; end
else MessageBox(Form1.Handle, 'Выделять сверху вниз, слева направо.', 'Region2', MB_ICONHAND);
end;
end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
Form1.Close;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
if  CheckBox1.Checked then begin
zon:='1';
if RadioGroup1.ItemIndex=0 then CheckBox2.Checked:=false;
CheckBox3.Checked:=false;
CheckBox4.Checked:=false; wl:=0;
r1:=1; Bevel1.Visible:=true; end
else begin Bevel1.Visible:=false; r1:=0;
if CheckBox2.Checked=false then begin zon:='2'; CheckBox3.Checked:=true;
end; end;
Label6.Caption:='Статус: reg1 = '+IntToStr(r1)+', reg2 = '+IntToStr(r2);
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
if  CheckBox2.Checked then begin
zon:='2';
if RadioGroup1.ItemIndex=0 then CheckBox1.Checked:=false;
CheckBox3.Checked:=false;
CheckBox4.Checked:=false; wl:=0;
r2:=1; Bevel2.Visible:=true;  end
else begin Bevel2.Visible:=false;  r2:=0;
if CheckBox1.Checked=false then begin zon:='1'; CheckBox3.Checked:=true;
  end;    end;
Label6.Caption:='Статус: reg1 = '+IntToStr(r1)+', reg2 = '+IntToStr(r2);
end;

procedure TForm1.CheckBox3Click(Sender: TObject);
begin
if  CheckBox3.Checked then begin
zon:='0';
CheckBox1.Checked:=false; r1:=0; Bevel1.Visible:=false;
CheckBox2.Checked:=false; r2:=0; Bevel2.Visible:=false;
end;
Label6.Caption:='Весь экран';

end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
Stop.Click;
if RadioGroup1.ItemIndex=0 then begin
zon:='0';
CheckBox1.Checked:=false; r1:=0; Bevel1.Visible:=false;
CheckBox2.Checked:=false; r2:=0; Bevel2.Visible:=false;
end;
if RadioGroup1.ItemIndex=2 then begin
first:=true;
cont:=false;
Label2.Caption:='Контроль: Включен';
end;
if RadioGroup1.ItemIndex<>0 then Start.Click;
end;

procedure TForm1.LabelR1Click(Sender: TObject);
begin
SENS:=TrackBar2.Position;
LabelR1.Caption:=INTTOSTR(SENS);
end;

procedure TForm1.LabelR2Click(Sender: TObject);
begin
SENS:=TrackBar3.Position;
LabelR2.Caption:=INTTOSTR(SENS);
end;

procedure TForm1.CheckBox4Click(Sender: TObject);
begin
if  CheckBox4.Checked=false then begin
CheckBox4.Checked:=true; wl:=1;
end;
end;

procedure TForm1.DriverClick(Sender: TObject);
var
	 DeviceName:array [0..79] of char;
   DeviceVersion:array [0..79] of char;
   q:integer;
begin
Stop.Click;    Panel2.Visible:=true;
	fDrivers.Clear;
	for q:=0 to 6 do
   	if capGetDriverDescriptionA(q,DeviceName,80,DeviceVersion,80) then
			fDrivers.Items.Add(string(DeviceName)+' '+string(DeviceVersion));
      fDrivers.ItemIndex:=0;
      fDrivers.Hint:=fDrivers.Items.Strings[fDrivers.ItemIndex];
end;

procedure TForm1.fDriversChange(Sender: TObject);
begin
if h_cam <> 0 then begin
     SendMessage(h_cam, WM_CAP_DRIVER_DISCONNECT, vin, 0);
     ShowWindow(h_cam,SW_HIDE);
     h_cam:= 0;
     end;

MaskEdit1.Text:=IntToStr(fDrivers.ItemIndex);
vin:=StrToInt(MaskEdit1.Text);
fDrivers.Hint:=fDrivers.Items.Strings[fDrivers.ItemIndex];
Connect.Click;
Start.Click;
end;

procedure TForm1.StaticText1Click(Sender: TObject);
begin
SendMessage(h_cam, WM_CAP_DLG_VIDEOSOURCE, SizeOf(Bt), LongInt(@Bt));
Start.Click;
end;

procedure TForm1.StaticText2Click(Sender: TObject);
begin
SendMessage(h_cam, WM_CAP_DLG_VIDEOFORMAT, SizeOf(Bt), LongInt(@Bt));
first := True;
end;

procedure TForm1.StaticText3Click(Sender: TObject);
begin
Panel2.Visible:=false;
end;

procedure TForm1.StaticText4Click(Sender: TObject);
resourcestring
 ReadStr = 'Программа для захвата видеопотока, кадра,'+
               ' записи в файл JPG событий на объекте.' +
              chr(13) +
             ' Используется USB камера VideoCam Smart300 ' +
             ' или TV тюнер AverTV 307 - ' +
             chr(13) +
             'любой канал или  внешняя аналоговая камера.' +
              chr(13) +
             'Размер экрана на выбор: 160х120, 320х240, 640х480 точек.' +
             chr(13) +  chr(13) +
             '2009-2010   Воробьев Н.С.      bukst@inbox.ru';
         begin
MessageDlg(ReadStr, mtInformation,[mbOK], 0);
end;

procedure TForm1.DELFILESClick(Sender: TObject);

begin
ShellExecute(Form1.Handle,nil,'delcapt.bat',nil,nil,SW_HIDE);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
cfl:=StrToInt(ComboBox1.Text);
end;

end.
