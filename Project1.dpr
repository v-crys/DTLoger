﻿//----------------------------------------------------------------------------------\\
//-------Текстурный диапозонный логер для создания визуальных читов к играм---------\\
//---------------------Автор: vovken1997 с форума CheatON.ru------------------------\\
//--------------------Проэкт создан: 26 марта 2013 в 11:43:19-----------------------\\
//------------------------------Версия: 0.5.3 Final---------------------------------\\
//----------------------------------------------------------------------------------\\
library Project1;

uses
  System.SysUtils,
  System.Classes,
  WinApi.Windows,
  advApiHook,
  D3DX9,
  Direct3D,
  Direct3D9,
  DirectDraw,
  DXTypes;


//Запись, хранящая каждое условие первого режима
type StrNumPrim=record
        Strides:integer;
        NumVertices:integer;
        PrimCount:integer;
        ZnakStr:integer;
        ZnakNum:integer;
        ZnakPrim:integer;
        ZBuf:boolean;
        Draw:boolean;
        Chams:boolean;
        Sheyder:boolean;
        TextRect:TRect;
        StrBase:String;
        StrOut:String;
        condition:integer;
        Enable: boolean;
        WireFrame: integer;
     end;

      const Path_File_Base='LOGER_Base.txt';  //Путь обычного лога
            Mode1_if=1000;    //Максимальное кол-во условий первого режима
            //Описываем цвета текстур Chams
            bPink:array[0..57] of byte = ($42, $4D, $3A, $00, $00, $00, $00, $00, $00,
                                          $00, $36, $00, $00, $00, $28, $00, $00, $00,
                                          $01, $00, $00, $00, $01, $00, $00, $00, $01,
                                          $00, $18, $00, $00, $00, $00, $00, $04, $00,
                                          $00, $00, $00, $00, $00, $00, $00, $00, $00,
                                          $00, $00, $00, $00, $00, $00, $00, $00, $00,
                                          $80, $00, $FF, $00);
            bBlue:array[0..59] of byte = ($42, $4D, $3C, $00, $00, $00, $00, $00, $00,
                                          $00, $36, $00, $00, $00, $28, $00, $00, $00,
                                          $01, $00, $00, $00, $01, $00, $00, $00, $01,
                                          $00, $20, $00, $00, $00, $00, $00, $00, $00,
                                          $00, $00, $12, $0B, $00, $00, $12, $0B, $00,
                                          $00, $00, $00, $00, $00, $00, $00, $00, $00,
                                          $FF, $00, $00, $00, $00, $00);
            bRed:array[0..59] of byte =  ($42, $4D, $3C, $00, $00, $00, $00, $00, $00,
                                          $00, $36, $00, $00, $00, $28, $00, $00, $00,
                                          $01, $00, $00, $00, $01, $00, $00, $00, $01,
                                          $00, $20, $00, $00, $00, $00, $00, $00, $00,
                                          $00, $00, $12, $0B, $00, $00, $12, $0B, $00,
                                          $00, $00, $00, $00, $00, $00, $00, $00, $00,
                                          $00, $00, $FF, $00, $00, $00);
            bGreen:array[0..59] of byte =($42, $4D, $3C, $00, $00, $00, $00, $00, $00,
                                          $00, $36, $00, $00, $00, $28, $00, $00, $00,
                                          $01, $00, $00, $00, $01, $00, $00, $00, $01,
                                          $00, $20, $00, $00, $00, $00, $00, $00, $00,
                                          $00, $00, $12, $0B, $00, $00, $12, $0B, $00,
                                          $00, $00, $00, $00, $00, $00, $00, $00, $00,
                                          $20, $A0, $00, $00, $FF, $FF);
            bYellow:array[0..59] of byte=($42, $4D, $3C, $00, $00, $00, $00, $00, $00,
                                          $00, $36, $00, $00, $00, $28, $00, $00, $00,
                                          $01, $00, $00, $00, $01, $00, $00, $00, $01,
                                          $00, $20, $00, $00, $00, $00, $00, $00, $00,
                                          $00, $00, $12, $0B, $00, $00, $12, $0B, $00,
                                          $00, $00, $00, $00, $00, $00, $00, $00, $00,
                                          $00, $FF, $FF, $00, $00, $00);
            bOrange:array[0..59] of byte=($42, $4D, $3C, $00, $00, $00, $00, $00, $00,
                                          $00, $36, $00, $00, $00, $28, $00, $00, $00,
                                          $01, $00, $00, $00, $01, $00, $00, $00, $01,
                                          $00, $20, $00, $00, $00, $00, $00, $00, $00,
                                          $00, $00, $12, $0B, $00, $00, $12, $0B, $00,
                                          $00, $00, $00, $00, $00, $00, $00, $00, $00,
                                          $10, $80, $F0, $B0, $00, $00);
            bWhite:array[0..57] of byte= ($42, $4D, $3A, $00, $00, $00, $00, $00, $00,
                                          $00, $36, $00, $00, $00, $28, $00, $00, $00,
                                          $01, $00, $00, $00, $01, $00, $00, $00, $01,
                                          $00, $18, $00, $00, $00, $00, $00, $04, $00,
                                          $00, $00, $00, $00, $00, $00, $00, $00, $00,
                                          $00, $00, $00, $00, $00, $00, $00, $00, $00,
                                          $FF, $FF, $FF, $00);


  //Объявление методов для возращения игре после выполнения наших действий
  var Direct3DCreate9Next: function (SDKVersion: LongWord): DWORD stdcall = nil;
      CreateDevice9Next: function (self: pointer; Adapter: LongWord; DeviceType: TD3DDevType; hFocusWindow: HWND; BehaviorFlags: DWord; pPresentationParameters: PD3DPresentParameters; out ppReturnedDeviceInterface: IDirect3DDevice9): HResult; stdcall = nil;
      EndScene9Next : function (self: pointer): HResult stdcall = nil;
      ResetNext: function (self: pointer; const pPresentationParameters: TD3DPresentParameters): HResult; stdcall;
      SetStreamSourceNext: function (self: pointer; StreamNumber: LongWord; pStreamData: IDirect3DVertexBuffer9; OffsetInBytes, Stride: LongWord): HResult; stdcall;
      DrawIndexedPrimitiveNext: function (DeviceInterface: IDirect3DDevice9; _Type: TD3DPrimitiveType; BaseVertexIndex: Integer; MinVertexIndex, NumVertices, startIndex, primCount: LongWord): HResult; stdcall;

      //Инициализация текста
      g_Font: ID3DXFont;
      g_Font_Cross: ID3DXFont;
      TextRect1: TRect;
      TextRect2: TRect;
      TextRect3: TRect;
      TextRect4: TRect;
      TextRect5:TRect;
      TextRect6:TRect;
      TextRect7:TRect;
      TextRect8:TRect;
      TextRect9:TRect;
      TextRect10:TRect;
      TextRect11: TRect;
      TextRect12: TRect;
      TextRect13: TRect;
      TextRect14: TRect;
      TextRect15: TRect;
      TextRectCross:TRect;


      //Переменные первого режима логера
      SNPArray:array[1..Mode1_IF] of StrNumPrim;
      SNPCount:integer=1;     //Колличество условий, которые сейчас используются
      SNPEn:integer=1;      //Выделенное условие
      k : integer;//Кол-во условий на экране
      StrOutCond:integer=1;
      StrNewStrid,StrNewNum,StrNewPrim,StrNewSet:string; //Строки вывода первого режима



      //Переменные второго режима
      //Массивы хранящие значения второго режима логера
      StridesN: array[1..4] of integer;
      NumVerticesN: array[1..4] of integer;
      primCountN: array[1..4] of integer;
      //Позиции выбора второго режима
      pos_xor:Integer=1;
      pos_vert:Integer=1;
      //Chams
      Chams:boolean=False; //Вкл/Выкл текстурирования объектов жёлтым цветом
      //Инициализация Chams цветов
      DeviceInterface:  IDirect3DDevice9;
      Pink: IDirect3DTexture9;
      Green: IDirect3DTexture9;
      Blue: IDirect3DTexture9;
      Red: IDirect3DTexture9;
      Yellow: IDirect3DTexture9;
      Orange: IDirect3DTexture9;
      White: IDirect3DTexture9;
      r:byte=1;

      Z_buf: boolean=true;//видимось сквозь стены (x-Ray mode)
      Draw: boolean=true;//Рисовать ли объекты вообще, нужно чтоб отключить световые гранаты
      Shader: boolean=False;//Шейдерная подсветка
      WireFrame: integer=0;

      //Остальные переменные
      //CrossHair
      x,y:integer;
      CrossHeir:boolean=False;

      vid: boolean=true;//Отображать ли текст
      StridesNow:integer; //Страйдес которое сейчас выводит игра
      Mode: integer=0; //Выбор одного из трёх режимов чита (0-Заглавие; 1-Обычный режим; 2-Диапозонный режим)
      Razr:integer=1; //Разряды числа на которое изменяем значение
      Save:integer=0; //Информация о том, сколько раз был сохранён лог

      //Описание шейдрных цветов
      psRed, psGreen, psBlue, psYellow, psWhite, psCyan, psBlack, psPink:IDirect3DPixelShader9;
{$R *.res}

procedure DLLEntryPoint(dwReason:DWORD);forward;


//Шейдеры
procedure GenShader(pDevice:IDirect3DDevice9);
var
 pv1,pv2, szShader:String;
 pShaderBuf :ID3DXBuffer;
 caps:D3DCAPS9;
begin
 pDevice.GetDeviceCaps(caps);
 pv1:=(inttostr( D3DSHADER_VERSION_MAJOR(caps.PixelShaderVersion)));
 pv2:=(inttostr( D3DSHADER_VERSION_MINOR(caps.PixelShaderVersion)));
 szShader:='ps_'+pv1+'_'+pv2+#13+'def c0, 1.0 , 0.0, 0.0, 1.0'+#13+'mov oC0, c0 '+#13;
 D3DXAssembleShader(PAnsiCHAR(AnsiString(szShader)), Length(szShader), nil, nil, 0, @pShaderBuf, nil);
 pDevice.CreatePixelShader(pShaderBuf.GetBufferPointer, psRed);

 szShader:='ps_'+pv1+'_'+pv2+#13+'def c0, 0.0 , 1.0, 0.0, 1.0'+#13+'mov oC0, c0 '+#13;
 D3DXAssembleShader(PAnsiCHAR(AnsiString(szShader)), Length(szShader), nil, nil, 0, @pShaderBuf, nil);
 pDevice.CreatePixelShader(pShaderBuf.GetBufferPointer, psGreen);

 szShader:='ps_'+pv1+'_'+pv2+#13+'def c0, 0.0 , 0.0, 1.0, 1.0'+#13+'mov oC0, c0 '+#13;
 D3DXAssembleShader(PAnsiCHAR(AnsiString(szShader)), Length(szShader), nil, nil, 0, @pShaderBuf, nil);
 pDevice.CreatePixelShader(pShaderBuf.GetBufferPointer, psBlue);

 szShader:='ps_'+pv1+'_'+pv2+#13+'def c0, 1.0 , 1.0, 0.0, 1.0'+#13+'mov oC0, c0 '+#13;
 D3DXAssembleShader(PAnsiCHAR(AnsiString(szShader)), Length(szShader), nil, nil, 0, @pShaderBuf, nil);
 pDevice.CreatePixelShader(pShaderBuf.GetBufferPointer, psYellow);

 szShader:='ps_'+pv1+'_'+pv2+#13+'def c0, 1.0 , 1.0, 1.0, 1.0'+#13+'mov oC0, c0 '+#13;
 D3DXAssembleShader(PAnsiCHAR(AnsiString(szShader)), Length(szShader), nil, nil, 0, @pShaderBuf, nil);
 pDevice.CreatePixelShader(pShaderBuf.GetBufferPointer, psWhite);

 szShader:='ps_'+pv1+'_'+pv2+#13+'def c0, 0.0 , 1.0, 1.0, 1.0'+#13+'mov oC0, c0 '+#13;
 D3DXAssembleShader(PAnsiCHAR(AnsiString(szShader)), Length(szShader), nil, nil, 0, @pShaderBuf, nil);
 pDevice.CreatePixelShader(pShaderBuf.GetBufferPointer, psCyan);

 szShader:='ps_'+pv1+'_'+pv2+#13+'def c0, 0.0 , 0.0, 0.0, 1.0'+#13+'mov oC0, c0 '+#13;
 D3DXAssembleShader(PAnsiCHAR(AnsiString(szShader)), Length(szShader), nil, nil, 0, @pShaderBuf, nil);
 pDevice.CreatePixelShader(pShaderBuf.GetBufferPointer, psBlack);

 szShader:='ps_'+pv1+'_'+pv2+#13+'def c0, 1.0 , 0.0, 1.0, 1.0'+#13+'mov oC0, c0 '+#13;
 D3DXAssembleShader(PAnsiCHAR(AnsiString(szShader)), Length(szShader), nil, nil, 0, @pShaderBuf, nil);
 pDevice.CreatePixelShader(pShaderBuf.GetBufferPointer, psPink);
end;


//Опрос клавиатуры
procedure CheckPressed;
var
F:TextFile;
I: Integer;
begin
//Клавиши, работающие во всех режимах
if (GetAsyncKeyState(VK_F1) and 1)<>0 then Mode:=Mode+1;
if Mode>3 then Mode:=0;

if ((GetAsyncKeyState(VK_ADD) and 1)<>0) and (razr<100000000) then razr:=razr*10;

if ((GetAsyncKeyState(VK_SUBTRACT) and 1)<>0) and (razr>1) then razr:=razr div 10;

if (GetAsyncKeyState(VK_F9) and 1)<>0 then CrossHeir:=not CrossHeir;

if (GetAsyncKeyState(VK_HOME) and 1)<>0 then vid:=not vid;

if (GetAsyncKeyState(VK_End) and 1)<>0 then DLLEntryPoint(DLL_PROCESS_DETACH);


if (GetAsyncKeyState(VK_F2) and 1)<>0 then
begin
      AssignFile(F,Path_File_BAse);
      if fileexists(Path_File_Base)=false then
      begin
          rewrite(f);
          closefile(f);
      end;
      Append(f);

      Writeln(F,'----------------------Base-------------------');
      writeln(F,'----------------------Mode1------------------');
      for I := 1 to SNPCount do Writeln(F,SNPArray[i].StrBase);
      writeln(F,'----------------------Mode2------------------');
      Writeln(F,StrNewStrid);
      Writeln(F,StrNewNum);
      WriteLN(F,StrNewPrim);
      Writeln(F,StrNewSet);
      Writeln(F,'');
      CloseFile(F);
      Save:=Save+1;
end;

//Клавиши первого режима
if mode=1 then
begin
  if (GetAsyncKeyState(VK_F3) and 1)<>0 then SNPArray[SNPEn].Chams:=not SNPArray[SNPEn].Chams;
  if (GetAsyncKeyState(VK_F4) and 1)<>0 then SNPArray[SNPEn].Draw:=not SNPArray[SNPEn].Draw;
  if (GetAsyncKeyState(VK_F5) and 1)<>0 then SNPArray[SNPEn].ZBuf:=not SNPArray[SNPEn].ZBuf;

  if (GetAsyncKeyState(VK_F6) and 1)<>0 then SNPArray[SNPEn].WireFrame:=SNPArray[SNPEn].WireFrame+1;
  if SNPArray[SNPEn].WireFrame>2 then SNPArray[SNPEn].WireFrame:=0;

  if ((GetAsyncKeyState(VK_F7) and 1)<>0) and (SNPCount>1) then
  begin
      SNPCount:=SNPCount-1;
      if SNPEn>SNPCount then SNPEn:=SNPCount;
  end;

  if ((GetAsyncKeyState(VK_F8) and 1)<>0) and (SNPCount<Mode1_IF) then SNPCount:=SNPCount+1;

  if (GetAsyncKeyState(VK_F10) and 1)<>0 then SNPArray[SNPEn].condition:=SNPArray[SNPEn].condition+1;
  if SNPArray[SNPEn].condition>2 then SNPArray[SNPEn].condition:=0;

  if (GetAsyncKeyState(VK_F11) and 1)<>0 then SNPArray[SNPEn].Enable:=not SNPArray[SNPEn].Enable;

  if (GetAsyncKeyState(VK_F12) and 1)<>0 then SNPArray[SNPEn].Sheyder:=not SNPArray[SNPEn].Sheyder;




  if ((GetAsyncKeyState(VK_UP) and 1)<>0) and (SNPEn>1) then
  begin
    SNPEn:=SNPEn-1;
    if SNPEn<StrOutCond then StrOutCond:=StrOutCond-k;
  end;

  if ((GetAsyncKeyState(VK_Down) and 1)<>0) and (SNPEn<SNPCount) then
  begin
    SNPEn:=SNPEn+1;
    if SNPEn>=StrOutCond+k then StrOutCond:=StrOutCond+k;
  end;



  if (GetAsyncKeyState(VK_NUMPAD7) and 1)<>0 then SNPArray[SNPEn].Strides:=SNPArray[SNPEn].Strides+razr;
  if (GetAsyncKeyState(VK_NUMPAD8) and 1)<>0 then SNPArray[SNPEn].NumVertices:=SNPArray[SNPEn].NumVertices+razr;
  if (GetAsyncKeyState(VK_NUMPAD9) and 1)<>0 then SNPArray[SNPEn].PrimCount:=SNPArray[SNPEn].PrimCount+razr;

  if (GetAsyncKeyState(VK_NUMPAD4) and 1)<>0 then SNPArray[SNPEn].Strides:=SNPArray[SNPEn].Strides-razr;
  if (GetAsyncKeyState(VK_NUMPAD5) and 1)<>0 then SNPArray[SNPEn].NumVertices:=SNPArray[SNPEn].NumVertices-razr;
  if (GetAsyncKeyState(VK_NUMPAD6) and 1)<>0 then SNPArray[SNPEn].PrimCount:=SNPArray[SNPEn].PrimCount-razr;

  if (GetAsyncKeyState(VK_NUMPAD1) and 1)<>0 then SNPArray[SNPEn].ZnakStr:=SNPArray[SNPEn].ZnakStr+1;
  if (GetAsyncKeyState(VK_NUMPAD2) and 1)<>0 then SNPArray[SNPEn].ZnakNum:=SNPArray[SNPEn].ZnakNum+1;
  if (GetAsyncKeyState(VK_NUMPAD3) and 1)<>0 then SNPArray[SNPEn].ZnakPrim:=SNPArray[SNPEn].ZnakPrim+1;

  if SNPArray[SNPEn].ZnakStr>4 then SNPArray[SNPEn].ZnakStr:=1;
  if SNPArray[SNPEn].ZnakNum>4 then SNPArray[SNPEn].ZnakNum:=1;
  if SNPArray[SNPEn].ZnakPrim>4 then SNPArray[SNPEn].ZnakPrim:=1;

  if (GetAsyncKeyState(VK_NUMPAD0) and 1)<>0 then
  begin
        SNPArray[SNPEn].Strides:=-1;
        SNPArray[SNPEn].NumVertices:=-1;
        SNPArray[SNPEn].PrimCount:=-1;
        SNPArray[SNPEn].ZnakStr:=1;
        SNPArray[SNPEn].ZnakNum:=1;
        SNPArray[SNPEn].ZnakPrim:=1;
  end;
 end;



 //Клавиши второго режима
if mode=2 then
begin
  if (GetAsyncKeyState(VK_F3) and 1)<>0 then Chams:=not Chams;
  if (GetAsyncKeyState(VK_F4) and 1)<>0 then Draw:=not Draw;
  if (GetAsyncKeyState(VK_F5) and 1)<>0 then Z_Buf:=not Z_Buf;
  if (GetAsyncKeyState(VK_F6) and 1)<>0 then WireFrame:=WireFrame+1;
  if WireFrame>2 then WireFrame:=0;
  if (GetAsyncKeyState(VK_F12) and 1)<>0 then Shader:=not Shader;

  if ((GetAsyncKeyState(VK_RIGHT) and 1 )<>0) and (pos_xor<4) then pos_xor:=pos_xor+1;
  if ((GetAsyncKeyState(VK_LEFT) and 1)<>0) and (pos_xor>1) then pos_xor:=pos_xor-1;
  if ((GetAsyncKeyState(VK_DOWN) and 1)<>0) and (pos_vert<3) then pos_vert:=pos_vert+1;
  if ((GetAsyncKeyState(VK_UP) and 1)<>0) and (pos_vert>1) then pos_vert:=pos_vert-1;


  if (GetAsyncKeyState(VK_NUMPAD6) and 1)<>0 then
  begin
    case (pos_vert) of
          1: StridesN[pos_xor]:=StridesN[pos_xor]+Razr;
          2: NumVerticesN[pos_xor]:=NumVerticesN[pos_xor]+Razr;
          3: primCountN[pos_xor]:=primCountN[pos_xor]+Razr;
    end;
  end;

  if (GetAsyncKeyState(VK_NUMPAD4) and 1)<>0 then
  begin
    case (pos_vert) of
          1: StridesN[pos_xor]:=StridesN[pos_xor]-Razr;
          2: NumVerticesN[pos_xor]:=NumVerticesN[pos_xor]-Razr;
          3: primCountN[pos_xor]:=primCountN[pos_xor]-Razr;
    end;
  end;

  if (GetAsyncKeyState(VK_NUMPAD0) and 1)<>0 then
  begin
      case pos_vert of
            1: case pos_xor of
                    1: StridesN[1]:=0;
                    2: StridesN[2]:=0;
                    3: StridesN[3]:=0;
                    4: StridesN[4]:=0;
               end;
            2: case pos_xor of
                    1: NumVerticesN[1]:=0;
                    2: NumVerticesN[2]:=0;
                    3: NumVerticesN[3]:=0;
                    4: NumVerticesN[4]:=0;
               end;
            3: case pos_xor of
                    1: PrimCountN[1]:=0;
                    2: PrimCountN[2]:=0;
                    3: PrimCountN[3]:=0;
                    4: PrimCountN[4]:=0;
               end;
      end;
  end;
end;

end;

//Отрисовка объектов по верх всего
procedure DrawIndexedPrimitive1(ChamsDraw,DrawD,Z_BufDraw,Sheyder:boolean;WareFrame:integer;Color:IDirect3DTexture9;DeviceInterface: IDirect3DDevice9; _Type: TD3DPrimitiveType; BaseVertexIndex: Integer; MinVertexIndex, NumVertices, startIndex, primCount: LongWord);
begin
if Z_bufDraw=true then DeviceInterface.SetRenderState(D3DRS_ZENABLE, D3DZB_FALSE);
if WareFrame=1 then DeviceInterface.SetRenderState(D3DRS_FILLMODE, D3DFILL_WIREFRAME);
if WareFrame=2 then DeviceInterface.SetRenderState(D3DRS_FILLMODE, D3DFILL_POINT);

if chamsDraw=true then DeviceInterface.SetTexture(0,Color);
if Sheyder=true then DeviceInterface.SetPixelShader(psGreen);
if DrawD=true then DrawIndexedPrimitiveNext(DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
if Sheyder=true then DeviceInterface.SetPixelShader(psGreen);
if chamsDraw=true then DeviceInterface.SetTexture(0,Color);

if WareFrame=2 then DeviceInterface.SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
if WareFrame=1 then DeviceInterface.SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
if Z_bufDraw=true then DeviceInterface.SetRenderState(D3DRS_ZENABLE, D3DZB_TRUE);
end;

//Функция вызывается при рисовании объектов игрой
function DrawIndexedPrimitiveCallback(DeviceInterface: IDirect3DDevice9; _Type: TD3DPrimitiveType; BaseVertexIndex: Integer; MinVertexIndex, NumVertices, startIndex, primCount: LongWord): HResult; stdcall;
var
Draw_out,Flag_Znak_Strides,Flag_Znak_Num,Flag_Znak_Prim,Draw_Out_Mode1,DrawOutPrimitive:boolean;
I, buf3,i1: Integer;
begin
Draw_out:=false;   //Переменная, будет установлена в True если произойдёт отрисовка в втором режиме
Draw_out_Mode1:=False; //Переменная будет в True если произойдёт отрисовка в первом режиме
//Инициализируем текстуры для Chams
if (r<=5) then
begin
    r:=r+1;
    D3DXCreateTextureFromFileInMemory(DeviceInterface,@bPink,58,Pink);
    D3DXCreateTextureFromFileInMemory(DeviceInterface,@bBlue,60,Blue);
    D3DXCreateTextureFromFileInMemory(DeviceInterface,@bRed,60,Red);
    D3DXCreateTextureFromFileInMemory(DeviceInterface,@bGreen,60,Green);
    D3DXCreateTextureFromFileInMemory(DeviceInterface,@bYellow,60,Yellow);
    D3DXCreateTextureFromFileInMemory(DeviceInterface,@bOrange,60,Orange);
    D3DXCreateTextureFromFileInMemory(DeviceInterface,@bWhite,58,White);
end;


//Вывод моделей в диапозонном режиме
if Mode=2 then
begin
  if Chams=True then
  begin
    if ((StridesNow>StridesN[1]) and (StridesNow<StridesN[2])) OR ((StridesNow>StridesN[3]) and (StridesNow<StridesN[4])) then
    begin
        if ((NumVertices>NumVerticesN[1]) and (NumVertices<NumVerticesN[2])) OR ((NumVertices>NumVerticesN[3]) and (NumVertices<NumVerticesN[4])) then
        begin
            if ((primCount>primCountN[1]) and (primCount<primCountN[2])) OR ((primCount>primCountN[3]) and (primCount<primCountN[4])) then
            begin
                Draw_out:=true;
                DrawIndexedPrimitive1(True,Draw,Z_Buf,Shader,WireFrame,Red, DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            end else
            begin
                Draw_out:=true;
                DrawIndexedPrimitive1(True,Draw,Z_Buf,Shader,WireFrame,Pink, DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            end;
        end;
    end;

    if Draw_out=False then
    begin
      if ((StridesNow>StridesN[1]) and (StridesNow<StridesN[2])) OR ((StridesNow>StridesN[3]) and (StridesNow<StridesN[4])) then
      begin
            if ((primCount>primCountN[1]) and (primCount<primCountN[2])) OR ((primCount>primCountN[3]) and (primCount<primCountN[4])) then
            begin
                Draw_out:=true;
                DrawIndexedPrimitive1(True,Draw,Z_Buf,Shader,WireFrame,Blue, DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            end;
      end;
    end;

    if Draw_out=False then
    begin
      if ((NumVertices>NumVerticesN[1]) and (NumVertices<NumVerticesN[2])) OR ((NumVertices>NumVerticesN[3]) and (NumVertices<NumVerticesN[4])) then
      begin
            if ((primCount>primCountN[1]) and (primCount<primCountN[2])) OR ((primCount>primCountN[3]) and (primCount<primCountN[4])) then
            begin
                Draw_out:=true;
                DrawIndexedPrimitive1(True,Draw,Z_Buf,Shader,WireFrame,Green, DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            end;
      end;
    end;

  end else
  begin
    if ((StridesNow>StridesN[1]) and (StridesNow<StridesN[2])) OR ((StridesNow>StridesN[3]) and (StridesNow<StridesN[4])) then
    begin
        if ((NumVertices>NumVerticesN[1]) and (NumVertices<NumVerticesN[2])) OR ((NumVertices>NumVerticesN[3]) and (NumVertices<NumVerticesN[4])) then
        begin
            if ((primCount>primCountN[1]) and (primCount<primCountN[2])) OR ((primCount>primCountN[3]) and (primCount<primCountN[4])) then
            begin
                //Если Chams отключён, рисуем любым цветом, всё ровно он не выведится
                Draw_out:=true;
                DrawIndexedPrimitive1(False,Draw,Z_Buf,Shader,WireFrame,Green, DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            end;
        end;
    end;
  end;
//Если этот объект не удовлетворяет условию, просто выведем его
if Draw_out=False then result:=DrawIndexedPrimitiveNext(DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
end;


//Обычный режим
if Mode=1 then
begin
//Проверяем, Выполняются ли условия, и записываем, какие именно выполняются
  for I := 1 to SNPCount do
  begin
    if SNPArray[i].Enable=true then
    begin
      case SNPArray[i].ZnakStr of
        1: if StridesNow=SNPArray[i].Strides then Flag_znak_Strides:=True else Flag_Znak_Strides:=False;
        2: if StridesNow<>SNPArray[i].Strides then Flag_Znak_Strides:=True else Flag_Znak_Strides:=False;
        3: if StridesNow<SNPArray[i].Strides then Flag_Znak_Strides:=True else Flag_Znak_Strides:=False;
        4: if StridesNow>SNPArray[i].Strides then Flag_Znak_Strides:=True else Flag_Znak_Strides:=False;
      end;


      case SNPArray[i].ZnakNum of
        1: if NumVertices=SNPArray[i].NumVertices then Flag_Znak_Num:=True else Flag_Znak_Num:=False;
        2: if NumVertices<>SNPArray[i].NumVertices then Flag_Znak_Num:=True else Flag_Znak_Num:=False;
        3: if NumVertices<SNPArray[i].NumVertices then Flag_Znak_Num:=True else Flag_Znak_Num:=False;
        4: if NumVertices>SNPArray[i].NumVertices then Flag_Znak_Num:=True else Flag_Znak_Num:=False;
      end;

      case SNPArray[i].ZnakPrim of
        1: if PrimCount=SNPArray[i].PrimCount then Flag_Znak_Prim:=True else Flag_Znak_Prim:=False;
        2: if PrimCount<>SNPArray[i].PrimCount then Flag_Znak_Prim:=True else Flag_Znak_Prim:=False;
        3: if PrimCount<SNPArray[i].PrimCount then Flag_Znak_Prim:=True else Flag_Znak_Prim:=False;
        4: if PrimCount>SNPArray[i].PrimCount then Flag_Znak_Prim:=True else Flag_Znak_Prim:=False;
      end;

      if SNPArray[i].condition=0 then
      begin
        if (Flag_Znak_Strides=true) and (Flag_Znak_Num=True) and (Flag_Znak_Prim=True) then
        begin
            DrawIndexedPrimitive1(SNPArray[i].Chams,SNPArray[i].Draw,SNPArray[i].ZBuf,SNPArray[i].Sheyder,SNPArray[i].WireFrame,Red,DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            Draw_Out_Mode1:=True;
            SNPArray[i].StrOut:='S='+IntToStr(StridesNow)+' N='+IntToStr(NumVertices)+' P='+IntToStr(PrimCount);
            Break;
        end;

        if (Flag_Znak_Strides=True) and (Flag_Znak_Num=True) then
        begin
            DrawIndexedPrimitive1(SNPArray[i].Chams,SNPArray[i].Draw,SNPArray[i].ZBuf,SNPArray[i].Sheyder,SNPArray[i].WireFrame,Pink,DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            Draw_Out_Mode1:=True;
            SNPArray[i].StrOut:='S='+IntToStr(StridesNow)+' N='+IntToStr(NumVertices);
            Break;
        end;

        if (Flag_Znak_Strides=True) and (Flag_Znak_Prim=True) then
        begin
            DrawIndexedPrimitive1(SNPArray[i].Chams,SNPArray[i].Draw,SNPArray[i].ZBuf,SNPArray[i].Sheyder,SNPArray[i].WireFrame,Blue,DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            Draw_out_Mode1:=True;
            SNPArray[i].StrOut:='S='+IntToStr(StridesNow)+' P='+IntToStr(PrimCount);
            Break;
        end;

        if (Flag_Znak_Num=True) and (Flag_Znak_Prim=true) then
        begin
            DrawIndexedPrimitive1(SNPArray[i].Chams,SNPArray[i].Draw,SNPArray[i].ZBuf,SNPArray[i].Sheyder,SNPArray[i].WireFrame,Green,DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            Draw_out_Mode1:=True;
            SNPArray[i].StrOut:='N='+IntToStr(NumVertices)+' P='+IntToStr(PrimCount);
            Break;
        end;
      end;

      if SNPArray[i].condition=1 then
      begin
        if (Flag_Znak_Strides=true) and (Flag_Znak_Num=True) and (Flag_Znak_Prim=True) then
        begin
            DrawIndexedPrimitive1(SNPArray[i].Chams,SNPArray[i].Draw,SNPArray[i].ZBuf,SNPArray[i].Sheyder,SNPArray[i].WireFrame,Red,DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            Draw_out_Mode1:=True;
            SNPArray[i].StrOut:='S='+IntToStr(StridesNow)+' N='+IntToStr(NumVertices)+' P='+IntToStr(PrimCount);
            Break;
        end;
      end;

      if SNPArray[i].condition=2 then
      begin
        if (Flag_Znak_Strides=true) then
        begin
            DrawIndexedPrimitive1(SNPArray[i].Chams,SNPArray[i].Draw,SNPArray[i].ZBuf,SNPArray[i].Sheyder,SNPArray[i].WireFrame,Yellow,DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            Draw_out_Mode1:=True;
            SNPArray[i].StrOut:='S='+IntToStr(StridesNow);
            Break;
        end;
        if (Flag_Znak_Num=True) then
        begin
            DrawIndexedPrimitive1(SNPArray[i].Chams,SNPArray[i].Draw,SNPArray[i].ZBuf,SNPArray[i].Sheyder,SNPArray[i].WireFrame,Orange,DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            Draw_out_Mode1:=True;
            SNPArray[i].StrOut:=' N='+IntToStr(NumVertices);
            Break;
        end;
        if (Flag_Znak_Prim=True) then
        begin
            DrawIndexedPrimitive1(SNPArray[i].Chams,SNPArray[i].Draw,SNPArray[i].ZBuf,SNPArray[i].Sheyder,SNPArray[i].WireFrame,White,DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
            Draw_out_Mode1:=True;
            SNPArray[i].StrOut:=' P='+IntToStr(PrimCount);
            Break;
        end;
      end;

    end;
 end;

  //Если объект ни подошёл ни к одному условию, то просто выведем его
  if Draw_Out_Mode1=False then result:=DrawIndexedPrimitiveNext(DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
end;

if (Mode=0) or (MODE=3) then result:=DrawIndexedPrimitiveNext(DeviceInterface, _Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
end;

//Функция вызываемая при завершении вывода объектов. Здесь выводим информацию пользователю
function EndScene9Callback(self: pointer): HResult; stdcall;
var
bStrStrides,bStrNumVertices,bStrPrimCount,bStrSet,bStrR : string;
StridR,NumVertR,PrimCoR:string;
ChamsStr, Z_BufStr,DrawStr:string;
StrCrossHeir: string;
StrCond: string;
i:integer;
begin
CheckPressed;
if vid=true then
begin
  if Mode=2 then
  begin
     case pos_vert of
        1:  begin
                case pos_xor of
                    1: bStrStrides:='-'+'((STRIDES>'+IntToStr(StridesN[1])+') and/or (Strides<'+IntToStr(StridesN[2])+')) OR ((Strides>'+IntToStr(StridesN[3])+') and/or (Strides<'+IntToStr(StridesN[4])+'))';
                    2: bStrStrides:='-'+'((Strides>'+IntToStr(StridesN[1])+') and/or (STRIDES<'+IntToStr(StridesN[2])+')) OR ((Strides>'+IntToStr(StridesN[3])+') and/or (Strides<'+IntToStr(StridesN[4])+'))';
                    3: bStrStrides:='-'+'((Strides>'+IntToStr(StridesN[1])+') and/or (Strides<'+IntToStr(StridesN[2])+')) OR ((STRIDES>'+IntToStr(StridesN[3])+') and/or (Strides<'+IntToStr(StridesN[4])+'))';
                    4: bStrStrides:='-'+'((Strides>'+IntToStr(StridesN[1])+') and/or (Strides<'+IntToStr(StridesN[2])+')) OR ((Strides>'+IntToStr(StridesN[3])+') and/or (STRIDES<'+IntToStr(StridesN[4])+'))';
                end;
                bStrNumVertices:='((NumVertices>'+IntToStr(NumVerticesN[1])+') and/or (NumVertices<'+IntToStr(NumVerticesN[2])+')) OR ((NumVertices>'+IntToStr(NumVerticesN[3])+') and/or (NumVertices<'+IntToStr(NumVerticesN[4])+'))';
                bStrPrimCount:='((PrimCount>'+IntToStr(PrimCountN[1])+') and/or (PrimCount<'+IntToStr(PrimCountN[2])+')) OR ((PrimCount>'+IntToStr(PrimCountN[3])+') and/or (PrimCount<'+IntToStr(PrimCountN[4])+'))';
            end;
        2:  begin
                case pos_xor of
                    1: bStrNumVertices:='-'+'((NUMVERTICES>'+IntToStr(NumVerticesN[1])+') and/or (NumVertices<'+IntToStr(NumVerticesN[2])+')) OR ((NumVertices>'+IntToStr(NumVerticesN[3])+') and/or (NumVertices<'+IntToStr(NumVerticesN[4])+'))';
                    2: bStrNumVertices:='-'+'((NumVertices>'+IntToStr(NumVerticesN[1])+') and/or (NUMVERTICES<'+IntToStr(NumVerticesN[2])+')) OR ((NumVertices>'+IntToStr(NumVerticesN[3])+') and/or (NumVertices<'+IntToStr(NumVerticesN[4])+'))';
                    3: bStrNumVertices:='-'+'((NumVertices>'+IntToStr(NumVerticesN[1])+') and/or (NumVertices<'+IntToStr(NumVerticesN[2])+')) OR ((NUMVERTICES>'+IntToStr(NumVerticesN[3])+') and/or (NumVertices<'+IntToStr(NumVerticesN[4])+'))';
                    4: bStrNumVertices:='-'+'((NumVertices>'+IntToStr(NumVerticesN[1])+') and/or (NumVertices<'+IntToStr(NumVerticesN[2])+')) OR ((NumVertices>'+IntToStr(NumVerticesN[3])+') and/or (NUMVERTICES<'+IntToStr(NumVerticesN[4])+'))';
                end;
                bStrStrides:='((Strides>'+IntToStr(StridesN[1])+') and/or (Strides<'+IntToStr(StridesN[2])+')) OR ((Strides>'+IntToStr(StridesN[3])+') and/or (Strides<'+IntToStr(StridesN[4])+'))';
                bStrPrimCount:='((PrimCount>'+IntToStr(PrimCountN[1])+') and/or (PrimCount<'+IntToStr(PrimCountN[2])+')) OR ((PrimCount>'+IntToStr(PrimCountN[3])+') and/or (PrimCount<'+IntToStr(PrimCountN[4])+'))';
            end;
        3:  begin
                case pos_xor of
                    1: bStrPrimCount:='-'+'((PRIMCOUNT>'+IntToStr(PrimCountN[1])+') and/or (PrimCount<'+IntToStr(PrimCountN[2])+')) OR ((PrimCount>'+IntToStr(PrimCountN[3])+') and/or (PrimCount<'+IntToStr(PrimCountN[4])+'))';
                    2: bStrPrimCount:='-'+'((PrimCount>'+IntToStr(PrimCountN[1])+') and/or (PRIMCOUNT<'+IntToStr(PrimCountN[2])+')) OR ((PrimCount>'+IntToStr(PrimCountN[3])+') and/or (PrimCount<'+IntToStr(PrimCountN[4])+'))';
                    3: bStrPrimCount:='-'+'((PrimCount>'+IntToStr(PrimCountN[1])+') and/or (PrimCount<'+IntToStr(PrimCountN[2])+')) OR ((PRIMCOUNT>'+IntToStr(PrimCountN[3])+') and/or (PrimCount<'+IntToStr(PrimCountN[4])+'))';
                    4: bStrPrimCount:='-'+'((PrimCount>'+IntToStr(PrimCountN[1])+') and/or (PrimCount<'+IntToStr(PrimCountN[2])+')) OR ((PrimCount>'+IntToStr(PrimCountN[3])+') and/or (PRIMCOUNT<'+IntToStr(PrimCountN[4])+'))';
                end;
                bStrStrides:='((Strides>'+IntToStr(StridesN[1])+') and/or (Strides<'+IntToStr(StridesN[2])+')) OR ((Strides>'+IntToStr(StridesN[3])+') and/or (Strides<'+IntToStr(StridesN[4])+'))';
                bStrNumVertices:='((NumVertices>'+IntToStr(NumVerticesN[1])+') and/or (NumVertices<'+IntToStr(NumVerticesN[2])+')) OR ((NumVertices>'+IntToStr(NumVerticesN[3])+') and/or (NumVertices<'+IntToStr(NumVerticesN[4])+'))';
            end;

      end;

     if Chams=True then bStrSet:='Chams: Yes' else bStrSet:='Chams: No';
     if Draw=True then bStrSet:=bStrSet+'; Draw: Yes' else bStrSet:=bStrSet+'; Draw: No';
     if Z_Buf=True then bStrSet:=bStrSet+'; X-Rey mode: Yes' else bStrSet:=bStrSet+'; X-Rey mode: No';
     if WireFrame=0 then bStrSet:=bStrSet+'; WireFrame: No';
     if WireFrame=1 then bStrSet:=bStrSet+'; WireFrame: Line';
     if WireFrame=2 then bStrSet:=bStrSet+'; WireFrame: Point';
     if Shader=True then bStrSet:=bStrSet+'; Shader: Yes' else bStrSet:=bStrSet+'; Shader: No';


    g_Font.DrawTextW(nil,PWideChar(bStrStrides),-1,@TextRect1,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(200,255,0,0));
    g_Font.DrawTextW(nil,PWideChar(bStrNumVertices),-1,@TextRect2,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(200,0,255,0));
    g_Font.DrawTextW(nil,PWideChar(bStrPrimCount),-1,@TextRect3,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(200,0,0,255));
    g_Font.DrawTextW(nil,PWideChar(bStrSet),-1,@TextRect4,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(200,0,158,255));

    StrNewStrid:=bStrStrides;
    StrNewNum:=bStrNumVertices;
    StrNewPrim:=bStrPrimCount;
    StrNewSet:=bStrSet;
  end;

  if Mode=1 then
  begin
   for i := StrOutCond to StrOutCond+k-1 do
   begin
    if SNPCount<i then break;

    case SNPArray[i].ZnakStr of
          1: StridR:='=';
          2: StridR:='<>';
          3: StridR:='<';
          4: StridR:='>';
    end;
    case SNPArray[i].ZnakNum of
          1: NumVertR:='=';
          2: NumVertR:='<>';
          3: NumVertR:='<';
          4: NumVertR:='>';
    end;
    case SNPArray[i].ZnakPrim of
          1: PrimCoR:='=';
          2: PrimCoR:='<>';
          3: PrimCor:='<';
          4: PrimCor:='>';
    end;

          case SNPArray[i].condition of
          0: StrCond:='AND/OR';
          1: StrCond:='AND';
          2: StrCond:='OR';
          end;


          bStrR:='(Strides'+StridR+IntToStr(SNPArray[i].Strides)+') '+StrCond+' (NumVertices'+NumVertR+IntToStr(SNPArray[i].NumVertices)+') '+StrCond+' (PrimCount'+PrimCoR+IntToStr(SNPArray[i].PrimCount)+')';
          if i=SNPEn then bStrR:='-'+bStrR;
          if SNPArray[i].Chams=True then bStrR:=bStrR+' Chams: Yes;' else bStrR:=bStrR+' Chams: No;';
          if SNPArray[i].Draw=True then bStrR:=bStrR+' Draw: Yes;' else bStrR:=bStrR+' Draw: No;';
          if SNPArray[i].ZBuf=True then bStrR:=bStrR+' ZBuf: Yes;' else bStrR:=bStrR+' ZBuf: No;';

          if SNPArray[i].WireFrame=0 then bStrR:=bStrR+' WF: No;';
          if SNPArray[i].WireFrame=1 then bStrR:=bStrR+' WF: Line;';
          if SNPArray[i].WireFrame=2 then bStrR:=bStrR+' WF: Point;';

          if SNPArray[i].Sheyder=True then bStrR:=bStrR+' Shader: Yes;' else bStrR:=bStrR+' Shader: No;';



          bStrR:=bStrR+'   Out:'+SNPArray[i].StrOut;
          if SNPArray[i].Enable=True then
          g_Font.DrawTextW(nil,PWideChar(bStrR),-1,@SNPArray[i].TextRect,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0))
              else
          g_Font.DrawTextW(nil,PWideChar(bStrR),-1,@SNPArray[i].TextRect,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,255,0,0));
          SNPArray[i].StrBase:=bStrR;
   end;
  end;

  if Mode=0 then
  begin
      g_Font.DrawTextW(nil,PWideChar('Диапозонный текстурный логер от vovken1997 (CheatON.ru®)'),-1,@TextRect1,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,255,255,0));
      g_Font.DrawTextW(nil,PWideChar('Распространяется с открытым исходным кодом'),-1,@TextRect2,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,255,255,0));
      g_Font.DrawTextW(nil,PWideChar('Версия: 0.5.3 Final Editor'),-1,@TextRect3,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,255,255,0));
      g_Font.DrawTextW(nil,PWideChar('ИНСТРУКЦИЯ'),-1,@TextRect4,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0));
      g_Font.DrawTextW(nil,PWideChar('F1-Выбор режима (Заглавие; Обычный режим; Диапозонный режим; Настройки)'),-1,@TextRect5,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0));
      g_Font.DrawTextW(nil,PWideChar('1 режим: 7;8;9-Повышение значений; 4;5;6-Понижение значений; 1;2;3-Выбор знака условия; F7-уменьшение усл.;'),-1,@TextRect6,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0));
      g_Font.DrawTextW(nil,PWideChar('1 режим: F8-Добавление усл.;Стрелки-навигация; F3-вкл\выкл Chams; F4-вкл\выкл Draw; F5-вкл\выкл X-Rey mode; '),-1,@TextRect7,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0));
      g_Font.DrawTextW(nil,PWideChar('1 режим: F6-WireFrame; F10-логические операции; F11-вкл./выкл условие; F12-вкл./выкл. шейдеры'),-1,@TextRect8,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0));

      g_Font.DrawTextW(nil,PWideChar('2 режим: Стрелки-навигация; 4-Понижение значений; 6-Повышение значений '),-1,@TextRect9,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0));
      g_Font.DrawTextW(nil,PWideChar('2 режим: F3-вкл\выкл Chams; F4-вкл\выкл Draw; F5-вкл\выкл X-Rey mode'),-1,@TextRect10,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0));
      g_Font.DrawTextW(nil,PWideChar('2 режим: F6-WireFrame; F12-вкл./выкл. шейдеры'),-1,@TextRect11,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0));

      g_Font.DrawTextW(nil,PWideChar('Настройки: F2-сохранение в лог с игрой; "+" и "-"-Разрядность чисел; "0"-сброс; HOME-вкл/выкл меню; F9-Вкл\Выкл CrossHeir'),-1,@TextRect12,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0));
      g_Font.DrawTextW(nil,PWideChar('ВНИМАНИЕ! ВСЕ ЦИФРЫ ВВОДЯТСЯ С NUMLOCK!!!'),-1,@TextRect13,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0));
  end;

  if Mode=3 then
  begin
      g_Font.DrawTextW(nil,PWideChar('НАСТРОЙКИ'),-1,@TextRect1,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,255,0,0));
      g_Font.DrawTextW(nil,PWideChar('Информация сохранена '+IntToStr(Save)+' раз (F2)'),-1,@TextRect2,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,255,0,0));

      g_Font.DrawTextW(nil,PWideChar('Разрядность числа (F6): '+IntToStr(Razr)),-1,@TextRect3,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,255,0,0));

      if CrossHeir=true then StrCrossHeir:='Yes' else StrCrossHeir:='No';
      g_Font.DrawTextW(nil,PWideChar('CrossHeir(F9): '+StrCrossHeir),-1,@TextRect4,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,255,0,0));
  end;
end;

if CrossHeir=true then g_Font_Cross.DrawTextW(nil,PWideChar('+          '),-1,@TextRectCross,DT_LEFT or DT_NOCLIP,D3DCOLOR_ARGB(255,0,255,0));

Result:=EndScene9Next(self);
end;

//Сохраняем зачение страйдс при вырисовке
function SetStreamSourceCallback(self: pointer; StreamNumber: LongWord; pStreamData: IDirect3DVertexBuffer9; OffsetInBytes, Stride: LongWord): HResult; stdcall;
begin
StridesNow := Stride;
result  := SetStreamSourceNext(self,StreamNumber,pStreamData,OffsetInBytes, StridesNow);
end;

//Функция для перезагруски ресурсов, чтоб при сворачивании игра нормально разворачивалась
procedure All_OnLostDevice;
begin
g_Font.OnLostDevice;
g_Font_Cross.OnLostDevice;
end;

procedure All_OnResetDevice;
begin
g_Font.OnResetDevice;
g_Font_Cross.OnResetDevice;
end;

function ResetCallback(self: pointer; const pPresentationParameters: TD3DPresentParameters): HResult; stdcall;
begin
All_OnLostDevice;

result:= ResetNext(self,pPresentationParameters);

if( SUCCEEDED(result) ) then
begin
  All_OnResetDevice;
end;

end;

//Инициализация устройства, прописываем так же настройки шрифта и положение строк
function CreateDevice9Callback(self: pointer; Adapter: LongWord; DeviceType: TD3DDevType; hFocusWindow: HWND; BehaviorFlags: DWord; pPresentationParameters: PD3DPresentParameters; out ppReturnedDeviceInterface: IDirect3DDevice9): HResult; stdcall;
var
i, y_pos: integer;
F:TextFile;
begin
Result :=CreateDevice9Next(self,Adapter,DeviceType, hFocusWindow,BehaviorFlags,pPresentationParameters,ppReturnedDeviceInterface);
if (result = 0) then
begin
  GenShader(ppReturnedDeviceInterface);

  x:=Round(GetSystemMetrics(0)/2);
  y:=Round(GetSystemMetrics(1)/2);
  TextRectCross:=Rect(x-6,y-13,x,y);
  TextRect1:=Rect(10,10,10,10);
  TextRect2:=Rect(10,30,10,10);
  TextRect3:=Rect(10,50,10,10);
  TextRect4:=Rect(10,70,10,10);

  TextRect5:=Rect(10,90,10,10);
  TextRect6:=Rect(10,110,10,10);
  TextRect7:=Rect(10,130,10,10);
  TextRect8:=Rect(10,150,10,10);
  TextRect9:=Rect(10,170,10,10);
  TextRect10:=Rect(10,190,10,10);
  TextRect11:=Rect(10,210,10,10);
  TextRect12:=Rect(10,230,10,10);
  TextRect13:=Rect(10,250,10,10);
  TextRect14:=Rect(10,270,10,10);
  TextRect15:=Rect(10,290,10,10);

  D3DXCreateFont(ppReturnedDeviceInterface,20,0,FW_NORMAL,1,false,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,6,DEFAULT_PITCH or FF_DONTCARE,PChar('Arial'),g_Font);
  D3DXCreateFont(ppReturnedDeviceInterface,30,10,FW_NORMAL,1,false,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,1,DEFAULT_PITCH or FF_DONTCARE,PChar('Arial'),g_Font_Cross);
  HookCode(GetInterfaceMethod(ppReturnedDeviceInterface, 42), @EndScene9Callback, @EndScene9Next);
  HookCode(GetInterfaceMethod(ppReturnedDeviceInterface, 16), @ResetCallback, @ResetNext);
  HookCode(GetInterfaceMethod(ppReturnedDeviceInterface, 100),@SetStreamSourceCallback, @SetStreamSourceNext);
  HookCode(GetInterfaceMethod(ppReturnedDeviceInterface, 82), @DrawIndexedPrimitiveCallback, @DrawIndexedPrimitiveNext);

  k:=0;
  for i := 1 to Mode1_IF do
  begin
    SNPArray[i].ZnakStr:=1;
    SNPArray[i].ZnakNum:=1;
    SNPArray[i].ZnakPrim:=1;
    SNPArray[i].Strides:=-1;
    SNPArray[i].NumVertices:=-1;
    SNPArray[i].PrimCount:=-1;
    SNPArray[i].Chams:=False;
    SNPArray[i].Draw:=True;
    SNPArray[i].ZBuf:=True;
    SNPArray[i].Enable:=True;

    if k=0 then
    begin
        y_pos:=i*20-10;
        SNPArray[i].TextRect:=Rect(10,y_pos,10,10);
        if y_pos+20>(y*2) then k:=i;
    end else
    begin
        if (i mod k)=0 then SNPArray[i].TextRect:=Rect(10,k*20-10,10,10) else
        SNPArray[i].TextRect:=SNPArray[i mod k].TextRect;
    end;
  end;

end;
end;

//Основные функции перехвата, старта DLL и т.д. О них читайте на CheatON.ru
function Direct3DCreate9Callback(SDKVersion: LongWord): DWORD; stdcall;
begin
  Result:=Direct3DCreate9Next(SDKVersion);
  if (Result <> 0) then
  begin
    if (@CreateDevice9Next <> nil) then UnhookCode(@CreateDevice9Next);
    HookCode(GetInterfaceMethod(result, 16), @CreateDevice9Callback, @CreateDevice9Next);
  end;
end;

procedure DLLEntryPoint(dwReason:DWORD);
begin
  case dwReason of
      DLL_PROCESS_ATTACH:
          begin
               HookProc('d3d9.dll', 'Direct3DCreate9', @Direct3DCreate9Callback, @Direct3DCreate9Next);
          end;
      DLL_PROCESS_DETACH:
          begin
               UnhookCode(@EndScene9Next);
               UnhookCode(@ResetNext);
               UnhookCode(@SetStreamSourceNext);
               UnhookCode(@DrawIndexedPrimitiveNext);
               UnhookCode(@CreateDevice9Next);
               UnhookCode(@Direct3DCreate9Next);
          end;
  end;
end;

begin
    DLLProc:=@DLLEntryPoint;
    DLLEntryPoint(DLL_PROCESS_ATTACH);
end.

