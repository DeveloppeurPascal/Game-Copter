unit cop_jeu;
{
Auteur: Patrick Pr‚martin
Date: 29/11/1992. 06/12/1992. 13/12/1992. 31/12/1992. 01/01/1993.
Langage: Turbo Pascal 6.0
But: Routines utilis‚es pour l'affichage des sprites, et leur gestion.
}
interface
uses
    u_pal;

var
   nb : word;
   pal : p_pal;

procedure clear_jeu;
procedure add_araignee (x, y : word);
procedure add_ennemi (x, y : word);
procedure add_champignon;
procedure add_joueur (x, y : word);
procedure add_tir (x, y, l, t : word);
procedure add_bonus (x, y : word; l : byte);

procedure run;

implementation
uses
    crt,
    u_spr,
    u_msg,
    u_mouse,
    u_m_util,
    u_temporisation,
    cop_var,
    cop_deplacement,
    cop_sprite;

procedure clear_jeu;
begin
  if (araignee <> nil)
  then
    dispose (araignee, done);
  {endif}
  araignee := nil;
  if (ennemi <> nil)
  then
    dispose (ennemi, done);
  {endif}
  ennemi := nil;
  if (joueur <> nil)
  then
    dispose (joueur, done);
  {endif}
  joueur := nil;
  if (tir <> nil)
  then
    dispose (tir, done);
  {endif}
  tir := nil;
  if (bonus <> nil)
  then
    dispose (bonus, done);
  {endif}
  bonus := nil;
  nb_champignon := 0;
  tst_joueur := false;
end; { clear_jeu }

procedure add_araignee (x, y : word);
var
   e : p_araignee;
begin
  e := new (p_araignee, init (x, y));
  if (e <> nil)
  then
    begin
      e^.next := araignee;
      araignee := e;
    end;
  {endif}
end; { add_araignee }

procedure add_ennemi (x, y : word);
var
   e : p_ennemi;
begin
  e := new (p_ennemi, init (x, y));
  if (e <> nil)
  then
    begin
      e^.next := ennemi;
      ennemi := e;
    end;
  {endif}
end; { add_ennemi }

procedure add_champignon;
begin
  inc (nb_champignon);
end; { add_champignon }

procedure add_joueur (x, y : word);
var
   e : p_joueur;
begin
  e := new (p_joueur, init (x, y));
  if (e <> nil)
  then
    begin
      setmouse (x, y);
      e^.next := joueur;
      joueur := e;
    end;
  {endif}
  tst_joueur := true;
end; { add_joueur }

procedure add_tir (x, y, l, t : word);
var
   e : p_tir;
begin
  e := new (p_tir, init (x, y, l, t));
  if (e <> nil)
  then
    begin
      e^.next := tir;
      tir := e;
    end;
  {endif}
end; { add_tir }

procedure add_bonus (x, y : word; l : byte);
var
   e : p_bonus;
begin
  e := new (p_bonus, init (x, y, l));
  if (e <> nil)
  then
    begin
      e^.next := bonus;
      bonus := e;
    end;
  {endif}
end; { add_bonus }

procedure run;
var
   fin : boolean;
begin
  while keypressed do
    c := readkey;
  {endwhile}
  fin := false;
  temporisation_init;
  repeat
    traiter_touches;
    if (araignee <> nil)
    then
      araignee^.run;
    {endif}
    if (ennemi <> nil)
    then
      ennemi^.run;
    {endif}
    if (joueur <> nil)
    then
      joueur^.run;
    {endif}
    if (tir <> nil)
    then
      tir^.run;
    {endif}
    if (bonus <> nil)
    then
      bonus^.run;
    {endif}
    fin := (c = ' ');
    if ((c = #27) and (nul = false))
    then
      fin_prog := confirm (get_msg (22));
    {endif}
    temporisation;
  until (fin_prog or fin);
end; { run }

var
   old_exitproc : pointer;

procedure cop_jeu_exit; far;
begin
  clear_jeu;
  exitproc := old_exitproc;
end; { cop_jeu_exit }

begin
  araignee := nil;
  ennemi := nil;
  joueur := nil;
  tir := nil;
  bonus := nil;
  old_exitproc := exitproc;
  exitproc := @cop_jeu_exit;
end.
