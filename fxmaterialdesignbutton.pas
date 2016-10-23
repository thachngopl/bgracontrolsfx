unit FXMaterialDesignButton;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, LResources, Forms, Controls, Graphics, Dialogs,
  BGRABitmap, BGRABitmapTypes, BGRAOpenGL, FXContainer, ExtCtrls;

type

  { TFXMaterialDesignButton }

  TFXMaterialDesignButton = class(TGraphicControl, IFXDrawable)
  private
    FNormalColor: TColor;
    FNormalColorEffect: TColor;
    FRoundBorders: single;
    FShadow: boolean;
    FShadowColor: TColor;
    FShadowSize: integer;
    FTextColor: TColor;
    FTextFont: string;
    FTextQuality: TBGRAFontQuality;
    FTextShadow: boolean;
    FTextShadowColor: TColor;
    FTextShadowOffsetX: integer;
    FTextShadowOffsetY: integer;
    FTextShadowSize: integer;
    FTextSize: integer;
    FTextStyle: TFontStyles;
    FTimer: TTimer;
    FBGRA: TBGRABitmap;
    FBGRAShadow: TBGRABitmap;
    FMousePos: TPoint;
    FCircleSize: single;
    FCircleAlpha: byte;
    fx: TBGLBitmap;
    procedure SetFNormalColor(AValue: TColor);
    procedure SetFNormalColorEffect(AValue: TColor);
    procedure SetFRoundBorders(AValue: single);
    procedure SetFShadow(AValue: boolean);
    procedure SetFShadowColor(AValue: TColor);
    procedure SetFShadowSize(AValue: integer);
    procedure SetFTextColor(AValue: TColor);
    procedure SetFTextFont(AValue: string);
    procedure SetFTextQuality(AValue: TBGRAFontQuality);
    procedure SetFTextShadow(AValue: boolean);
    procedure SetFTextShadowColor(AValue: TColor);
    procedure SetFTextShadowOffsetX(AValue: integer);
    procedure SetFTextShadowOffsetY(AValue: integer);
    procedure SetFTextShadowSize(AValue: integer);
    procedure SetFTextSize(AValue: integer);
    procedure SetFTextStyle(AValue: TFontStyles);
  protected
    procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer;
    {%H-}WithThemeSpace: boolean); override;
    procedure OnStartTimer({%H-}Sender: TObject);
    procedure OnTimer({%H-}Sender: TObject);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    class function GetControlClassDefaultSize: TSize; override;
    procedure TextChanged; override;
    procedure UpdateShadow;
  protected
    procedure FXInvalidate;
    procedure FXDraw;
    procedure FXPreview(var aCanvas: TCanvas);
    procedure Draw;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property RoundBorders: single read FRoundBorders write SetFRoundBorders default 5;
    property NormalColor: TColor read FNormalColor write SetFNormalColor default clWhite;
    property NormalColorEffect: TColor read FNormalColorEffect
      write SetFNormalColorEffect default clSilver;
    property Shadow: boolean read FShadow write SetFShadow default True;
    property ShadowColor: TColor read FShadowColor write SetFShadowColor default clGray;
    property ShadowSize: integer read FShadowSize write SetFShadowSize default 5;
    property TextColor: TColor read FTextColor write SetFTextColor default clBlack;
    property TextSize: integer read FTextSize write SetFTextSize default 16;
    property TextShadow: boolean read FTextShadow write SetFTextShadow default True;
    property TextShadowColor: TColor read FTextShadowColor
      write SetFTextShadowColor default clBlack;
    property TextShadowSize: integer read FTextShadowSize
      write SetFTextShadowSize default 2;
    property TextShadowOffsetX: integer read FTextShadowOffsetX
      write SetFTextShadowOffsetX default 0;
    property TextShadowOffsetY: integer read FTextShadowOffsetY
      write SetFTextShadowOffsetY default 0;
    property TextStyle: TFontStyles read FTextStyle write SetFTextStyle default [];
    property TextFont: string read FTextFont write SetFTextFont;
    property TextQuality: TBGRAFontQuality
      read FTextQuality write SetFTextQuality default fqFineAntialiasing;
  published
    property Action;
    property Align;
    property Anchors;
    property AutoSize;
    property BidiMode;
    property BorderSpacing;
    property Caption;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property OnChangeBounds;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDrag;
    property ParentBidiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
  end;

procedure Register;

implementation

procedure DrawTextShadow(bmpOut: TBGRABitmap; AWidth, AHeight: integer;
  AText: string; AFontHeight: integer; ATextColor, AShadowColor: TBGRAPixel;
  AOffSetX, AOffSetY: integer; ARadius: integer = 0; AFontStyle: TFontStyles = [];
  AFontName: string = 'Default'; AFontQuality: TBGRAFontQuality = fqFineAntialiasing);
var
  bmpSdw: TBGRABitmap;
  OutTxtSize: TSize;
  OutX, OutY: integer;
begin
  bmpOut.FontAntialias := True;
  bmpOut.FontHeight := AFontHeight;
  bmpOut.FontStyle := AFontStyle;
  bmpOut.FontName := AFontName;
  bmpOut.FontQuality := AFontQuality;

  OutTxtSize := bmpOut.TextSize(AText);
  OutX := Round(AWidth / 2) - Round(OutTxtSize.cx / 2);
  OutY := Round(AHeight / 2) - Round(OutTxtSize.cy / 2);

  bmpSdw := TBGRABitmap.Create(OutTxtSize.cx + 2 * ARadius, OutTxtSize.cy +
    2 * ARadius);
  bmpSdw.FontAntialias := True;
  bmpSdw.FontHeight := AFontHeight;
  bmpSdw.FontStyle := AFontStyle;
  bmpSdw.FontName := AFontName;
  bmpSdw.FontQuality := AFontQuality;

  bmpSdw.TextOut(ARadius, ARadius, AText, AShadowColor);
  BGRAReplace(bmpSdw, bmpSdw.FilterBlurRadial(ARadius, rbFast));
  bmpOut.PutImage(OutX + AOffSetX - ARadius, OutY + AOffSetY - ARadius, bmpSdw,
    dmDrawWithTransparency);
  bmpSdw.Free;

  bmpOut.TextOut(OutX, OutY, AText, ATextColor);
end;

procedure Register;
begin
  RegisterComponents('BGRA Controls FX', [TFXMaterialDesignButton]);
end;

{ TFXMaterialDesignButton }

procedure TFXMaterialDesignButton.SetFRoundBorders(AValue: single);
begin
  if FRoundBorders = AValue then
    Exit;
  FRoundBorders := AValue;
  UpdateShadow;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFShadow(AValue: boolean);
begin
  if FShadow = AValue then
    Exit;
  FShadow := AValue;
  InvalidatePreferredSize;
  AdjustSize;
  UpdateShadow;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFShadowColor(AValue: TColor);
begin
  if FShadowColor = AValue then
    Exit;
  FShadowColor := AValue;
  UpdateShadow;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFShadowSize(AValue: integer);
begin
  if FShadowSize = AValue then
    Exit;
  FShadowSize := AValue;
  InvalidatePreferredSize;
  AdjustSize;
  UpdateShadow;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFTextColor(AValue: TColor);
begin
  if FTextColor = AValue then
    Exit;
  FTextColor := AValue;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFTextFont(AValue: string);
begin
  if FTextFont = AValue then
    Exit;
  FTextFont := AValue;
  InvalidatePreferredSize;
  AdjustSize;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFTextQuality(AValue: TBGRAFontQuality);
begin
  if FTextQuality = AValue then
    Exit;
  FTextQuality := AValue;
  InvalidatePreferredSize;
  AdjustSize;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFTextShadow(AValue: boolean);
begin
  if FTextShadow = AValue then
    Exit;
  FTextShadow := AValue;
  InvalidatePreferredSize;
  AdjustSize;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFTextShadowColor(AValue: TColor);
begin
  if FTextShadowColor = AValue then
    Exit;
  FTextShadowColor := AValue;
  UpdateShadow;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFTextShadowOffsetX(AValue: integer);
begin
  if FTextShadowOffsetX = AValue then
    Exit;
  FTextShadowOffsetX := AValue;
  InvalidatePreferredSize;
  AdjustSize;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFTextShadowOffsetY(AValue: integer);
begin
  if FTextShadowOffsetY = AValue then
    Exit;
  FTextShadowOffsetY := AValue;
  InvalidatePreferredSize;
  AdjustSize;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFTextShadowSize(AValue: integer);
begin
  if FTextShadowSize = AValue then
    Exit;
  FTextShadowSize := AValue;
  InvalidatePreferredSize;
  AdjustSize;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFTextSize(AValue: integer);
begin
  if FTextSize = AValue then
    Exit;
  FTextSize := AValue;
  InvalidatePreferredSize;
  AdjustSize;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFTextStyle(AValue: TFontStyles);
begin
  if FTextStyle = AValue then
    Exit;
  FTextStyle := AValue;
  InvalidatePreferredSize;
  AdjustSize;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.CalculatePreferredSize(
  var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
var
  ts: TSize;
begin
  inherited CalculatePreferredSize(PreferredWidth, PreferredHeight,
    WithThemeSpace);

  if Caption <> '' then
  begin
    FBGRA.FontQuality := FTextQuality;
    FBGRA.FontName := FTextFont;
    FBGRA.FontStyle := FTextStyle;
    FBGRA.FontHeight := FTextSize;
    FBGRA.FontAntialias := True;

    ts := FBGRA.TextSize(Caption);
    Inc(PreferredWidth, ts.cx + 26);
    Inc(PreferredHeight, ts.cy + 10);
  end;

  if FShadow then
  begin
    Inc(PreferredWidth, FShadowSize * 2);
    Inc(PreferredHeight, FShadowSize * 2);
  end;
end;

procedure TFXMaterialDesignButton.SetFNormalColor(AValue: TColor);
begin
  if FNormalColor = AValue then
    Exit;
  FNormalColor := AValue;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.SetFNormalColorEffect(AValue: TColor);
begin
  if FNormalColorEffect = AValue then
    Exit;
  FNormalColorEffect := AValue;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.OnStartTimer(Sender: TObject);
begin
  FCircleAlpha := 255;
  FCircleSize := 0;
end;

procedure TFXMaterialDesignButton.OnTimer(Sender: TObject);
begin
  if Width > Height then
    FCircleSize := FCircleSize + (Width div 15)
  else
    FCircleSize := FCircleSize + (Height div 15);

  if FCircleAlpha - 10 > 0 then
    FCircleAlpha := FCircleAlpha - 10
  else
    FCircleAlpha := 0;
  if FCircleAlpha <= 0 then
    FTimer.Enabled := False;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  FTimer.Enabled := False;
  FMousePos := Point(X, Y);
  FTimer.Enabled := True;
  inherited MouseDown(Button, Shift, X, Y);
end;

class function TFXMaterialDesignButton.GetControlClassDefaultSize: TSize;
begin
  Result.CX := 123;
  Result.CY := 33;
end;

procedure TFXMaterialDesignButton.TextChanged;
begin
  InvalidatePreferredSize;
  AdjustSize;
  if not (csLoading in ComponentState) then
    FXInvalidate;
end;

procedure TFXMaterialDesignButton.UpdateShadow;
begin
  FBGRAShadow.FillTransparent;
  if FShadow then
  begin
    FBGRAShadow.RoundRectAntialias(FShadowSize, FShadowSize, Width - FShadowSize,
      Height - FShadowSize, FRoundBorders, FRoundBorders,
      FShadowColor, 1, FShadowColor, [rrDefault]);
    BGRAReplace(FBGRAShadow, FBGRAShadow.FilterBlurRadial(FShadowSize,
      FShadowSize, rbFast) as TBGRABitmap);
  end;
end;

procedure TFXMaterialDesignButton.FXInvalidate;
begin
  if (csDesigning in ComponentState) then
    Invalidate;

  if Parent is TFXContainer then
    TFXContainer(Parent).DoOnPaint;
end;

procedure TFXMaterialDesignButton.FXDraw;
begin
  if (csDesigning in ComponentState) then
    exit;

  Draw;
  if (fx.Width <> Width) or (fx.Height <> Height) then
    fx.SetSize(Width, Height);

  fx.FillTransparent;
  fx.PutImage(0, 0, FBGRA, dmDrawWithTransparency);
  BGLCanvas.PutImage(Left, Top, fx.Texture);
end;

procedure TFXMaterialDesignButton.FXPreview(var aCanvas: TCanvas);
begin
  Draw;
  FBGRA.Draw(aCanvas, Left, Top, False);
end;

procedure TFXMaterialDesignButton.Draw;
var
  temp: TBGRABitmap;
  round_rect_left: integer;
  round_rect_width: integer;
  round_rect_height: integer;
  text_height: integer;
begin
  if (Width-1 > FRoundBorders * 2) and (Height-1 > FRoundBorders * 2) then
  begin
    if (FBGRA.Width <> Width) or (FBGRA.Height <> Height) then
    begin
      FBGRA.SetSize(Width, Height);
      FBGRAShadow.SetSize(Width, Height);
      UpdateShadow;
    end;

    FBGRA.FillTransparent;
    if FShadow then
      FBGRA.PutImage(0, 0, FBGRAShadow, dmDrawWithTransparency);

    temp := TBGRABitmap.Create(Width, Height, FNormalColor);
    temp.EllipseAntialias(FMousePos.X, FMousePos.Y, FCircleSize, FCircleSize,
      ColorToBGRA(FNormalColorEffect, FCircleAlpha), 1,
      ColorToBGRA(FNormalColorEffect, FCircleAlpha));

    if FShadow then
    begin
      round_rect_left := FShadowSize;
      round_rect_width := Width - FShadowSize;
      round_rect_height := Height - FShadowSize;
    end
    else
    begin
      round_rect_left := 0;
      round_rect_width := Width;
      round_rect_height := Height;
    end;


    FBGRA.FillRoundRectAntialias(round_rect_left, 0, round_rect_width, round_rect_height,
      FRoundBorders, FRoundBorders, temp, [rrDefault], False);

    temp.Free;

    if Caption <> '' then
    begin
      if FShadow then
        text_height := Height - FShadowSize
      else
        text_height := Height;
      DrawTextShadow(FBGRA, Width, text_height, Caption, FTextSize,
        FTextColor, FTextShadowColor, FTextShadowOffsetX, FTextShadowOffsetY,
        FTextShadowSize, FTextStyle, FTextFont, FTextQuality);
    end;
  end;
end;

constructor TFXMaterialDesignButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, CX, CY);
  FTimer := TTimer.Create(Self);
  FTimer.Interval := 15;
  FTimer.Enabled := False;
  FTimer.OnStartTimer := @OnStartTimer;
  FTimer.OnTimer := @OnTimer;
  FBGRA := TBGRABitmap.Create(Width, Height);
  FBGRAShadow := TBGRABitmap.Create(Width, Height);
  fx := TBGLBitmap.Create;
  FRoundBorders := 5;
  FNormalColor := clWhite;
  FNormalColorEffect := clSilver;
  FShadow := True;
  FShadowColor := clGray;
  FShadowSize := 5;
  FTextColor := clBlack;
  FTextSize := 16;
  FTextShadow := True;
  FTextShadowColor := clBlack;
  FTextShadowSize := 2;
  FTextShadowOffsetX := 0;
  FTextShadowOffsetY := 0;
  FTextStyle := [];
  FTextFont := 'default';
  FTextQuality := fqFineAntialiasing;
end;

destructor TFXMaterialDesignButton.Destroy;
begin
  FTimer.Enabled := False;
  FTimer.OnStartTimer := nil;
  FTimer.OnTimer := nil;
  FreeAndNil(FBGRA);
  FreeAndNil(FBGRAShadow);
  FreeAndNil(fx);
  inherited Destroy;
end;

end.