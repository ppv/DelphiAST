unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    OpenDelphiUnit1: TMenuItem;
    OpenDialog1: TOpenDialog;
    MenuItem_Refresh: TMenuItem;
    MenuItem_Copy: TMenuItem;
    procedure OpenDelphiUnit1Click(Sender: TObject);
    procedure MenuItem_RefreshClick(Sender: TObject);
    procedure MenuItem_CopyClick(Sender: TObject);
  private
    procedure LoadFile(const FileName: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  DelphiAST, DelphiAST.Writer, DelphiAST.Classes, Xml.XmlDoc;

{$R *.dfm}

function Parse(const Content: string): string;
var
  ASTBuilder: TPasSyntaxTreeBuilder;
  StringStream: TStringStream;
  SyntaxTree: TSyntaxNode;
begin
  Result := '';

  StringStream := TStringStream.Create(Content, TEncoding.Unicode);
  try
    StringStream.Position := 0;

    ASTBuilder := TPasSyntaxTreeBuilder.Create;
    try
      ASTBuilder.AddDefine('MSWINDOWS');
      ASTBuilder.AddDefine('WIN32');

      SyntaxTree := ASTBuilder.Run(StringStream);
      try
        Result := TSyntaxTreeWriter.ToXML(SyntaxTree);
      finally
        SyntaxTree.Free;
      end;
    finally
      ASTBuilder.Free;
    end;
  finally
    StringStream.Free;
  end;
end;

procedure TForm1.LoadFile(const FileName: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(OpenDialog1.FileName);

    try
      Memo1.Lines.Text := FormatXMLData(Parse(SL.Text));
    except
      on E: EParserException do
        Memo1.Lines.Add(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]));
    end;
  finally
    SL.Free;
  end;
end;

procedure TForm1.MenuItem_CopyClick(Sender: TObject);
begin
  Memo1.SelectAll;
  Memo1.CopyToClipboard;
  Memo1.SelLength := 0;
end;

procedure TForm1.MenuItem_RefreshClick(Sender: TObject);
begin
  if OpenDialog1.FileName <> EmptyStr then
    LoadFile(OpenDialog1.FileName);
end;

procedure TForm1.OpenDelphiUnit1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    LoadFile(OpenDialog1.FileName);
  end;
end;

end.

