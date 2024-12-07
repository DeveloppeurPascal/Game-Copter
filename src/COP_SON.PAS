unit cop_son;
{
Auteur: Patrick Pr‚martin.
Date: 06/11/1992.
Langage: Turbo Pascal 6.0
But: Sonorisation du jeu COPTER.
}
interface

var
   son_autorise : boolean;

procedure son (n : word);
procedure fin_son;

implementation
uses
    crt;

procedure son (n : word);
begin
  if (son_autorise)
  then
    sound (n);
  {endif}
end; { son }

procedure fin_son;
begin
  nosound;
end; { fin_son }

var
   old_exitproc : pointer;

procedure son_exitproc; far;
begin
  fin_son;
  exitproc := old_exitproc;
end; { son_exitproc }

begin
  son_autorise := true;
  old_exitproc := exitproc;
  exitproc := @son_exitproc;
end.
