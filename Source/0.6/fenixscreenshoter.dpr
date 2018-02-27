program fenixscreenshoter;

uses
  Vcl.Forms,
  fenix in 'fenix.pas' {FormHome},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Orange Graphite');
  Application.CreateForm(TFormHome, FormHome);
  Application.Run;
end.
