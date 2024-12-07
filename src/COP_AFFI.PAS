unit cop_affiche;
{
Auteur: Patrick Pr‚martin.
Date: 29/11/1992. 13/12/1992. 31/12/1992.
Langage: Turbo Pascal 6.0
But: Affichage d'un tableau et initialisation de toutes les variables utiles...
}
interface
uses
    cop_var;

var
   level : t_tab;

procedure mode_vga;
procedure mode_texte;
procedure afficher_tab;

implementation
uses
    crt,
    u_int10h,
    u_pal,
    u_spr,
    u_fnt,
    u_msg,
    cop_jeu,
    cop_son,
    cop_score;

var
   om : byte;
   num_tir : word;

procedure mode_vga;
begin
  directvideo := false;
  repeat
  until (set_mode (19) or true);
  use_pal (pal);
end; { mode_vga }

procedure mur (x, y : word);
begin
  liste_sprite^.affiche (nb+random (4), x, y);
end; { mur }

procedure fleur (x, y : word);
begin
  liste_sprite^.affiche (nb+12+random (2), x, y);
end; { fleur }

procedure champignon (x, y : word);
begin
  liste_sprite^.affiche (nb+22+random (2), x, y);
  add_champignon;
end; { champignon }

procedure araignee (x, y : word);
begin
  add_araignee (x, y);
end; { araignee }

procedure joueur (x, y : word);
begin
  add_joueur (x, y);
end; { joueur }

procedure ennemi (x, y : word);
begin
  add_ennemi (x, y);
end; { ennemi }

procedure tir (x, y : word);
var
   i : byte;
begin
  for i := 0 to 7 do
    begin
      {$r-}
      mem [$a000:x+i+(y+3)*320] := 50;
      mem [$a000:x+i+(y+4)*320] := 52;
      {$r+}
    end;
  {endif}
end; { tir }

procedure efface (x, y : word);
var
   i, j : word;
begin
  for i := x to x+7 do
    for j := y to y+7 do
      {$r-}
      mem [$a000:i+j*320] := 0;
      {$r+}
    {endfor}
  {endfor}
end; { efface }

function impair (x, y, test : byte) : boolean;
var
   n : byte;
begin
  n := 1;
  while ((x > 1) and (level [x-1, y] and test > 0)) do
    begin
      inc (n);
      dec (x);
    end;
  {endwhile}
  impair := (n mod 2 = 1);
end; { impair }

procedure pset (i, j : byte; k : byte);
var
   x, y : word;
begin
  x := pred (i)*8;
  y := pred (j)*8;
  efface (x, y);
  if (0 < (k and c_mur))
  then
    mur (x, y);
  {endif}
  if (0 < (k and c_fleur))
  then
    fleur (x, y);
  {endif}
  if (0 < (k and c_champignon))
  then
    champignon (x, y);
  {endif}
  if (0 < (k and c_araignee))
  then
    araignee (x, y);
  {endif}
  if (0 < (k and c_joueur))
  then
    if (impair (i, j, c_joueur))
    then
      joueur (x, y);
    {endif}
  {endif}
  if (0 < (k and c_ennemi))
  then
    if (impair (i, j, c_ennemi))
    then
      ennemi (x, y);
    {endif}
  {endif}
  if (0 < (k and c_tir))
  then
    begin
      if ((i = 1) or (level [pred (i), j] and c_tir = 0))
      then
        begin
          x := 0;
          while ((level [i+x, j] and c_tir > 0) and (i+x < 39)) do
            inc (x);
          {endwhile}
          inc (num_tir);
          add_tir (i, j, x, get_tempo (num_tir));
        end;
      {endif}
    end;
  {endif}
end; { pset }

procedure dessin_tab_score;
var
   i : byte;
begin
  ecr_mode := transparent;
  ecr_color (83, 0);
  ecr_xy (1, 10);
  ecr_str ('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄ¿');
  ecr_xy (1, 11);
  ecr_str ('³                    ³    ³   ³        ³');
  ecr_xy (1, 12);
  ecr_str ('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÅÄÄÄÅÄÄÄÄÄÄÄÄ´');
  ecr_xy (1, 13);
  ecr_str ('³                    ³    ³   ³        ³');
  ecr_xy (1, 14);
  ecr_str ('³                    ³    ³   ³        ³');
  ecr_xy (1, 15);
  ecr_str ('³                    ³    ³   ³        ³');
  ecr_xy (1, 16);
  ecr_str ('³                    ³    ³   ³        ³');
  ecr_xy (1, 17);
  ecr_str ('³                    ³    ³   ³        ³');
  ecr_xy (1, 18);
  ecr_str ('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÙ');
  ecr_color (84, 0);
  ecr_xy (2+(20-length (get_msg (23))) div 2, 11);
  ecr_str (get_msg (23));
  ecr_color (85, 0);
  ecr_xy (23, 11);
  ecr_str ('DTDK');
  ecr_color (86, 0);
  ecr_xy (28, 11);
  ecr_str ('LVL');
  ecr_color (78, 0);
  ecr_xy (34, 11);
  ecr_str ('SCORE');
  for i := 1 to 5 do
    begin
      ecr_color (86+i, 0);
      ecr_xy (2, 12+i);
      ecr_str (tab_score [i].nom);
      ecr_xy (24, 12+i);
      ecr_int (tab_score [i].dtdk);
      ecr_xy (29, 12+i);
      ecr_int (tab_score [i].lvl);
      ecr_xy (33, 12+i);
      ecr_int (tab_score [i].score);
    end;
  {endfor}
end; { dessin_tab_score }

procedure dessin_touches_pres;
begin
  ecr_mode := normal;
  ecr_color (85, 0);
  ecr_xy (2, 22);
  ecr_str ('ESC-'+get_msg (24));
  ecr_xy (2, 23);
  ecr_str ('F3 -'+get_msg (25));
  if (etat_prog <> ecr_score)
  then
    begin
      ecr_xy (2, 24);
      ecr_str ('F4 -SCORE');
    end;
  {endif}
  ecr_xy (21, 22);
  if (son_autorise)
  then
    ecr_str ('F5 -'+get_msg (27))
  else
    ecr_str ('F5 -'+get_msg (26));
  {endif}
  ecr_xy (21, 23);
  ecr_str ('F6 -PASSWORD');
  ecr_xy (21, 24);
  case niveau_diff of
    1 : ecr_str ('F7 -'+get_msg (31)+' '+get_msg (28));
    2 : ecr_str ('F7 -'+get_msg (31)+' '+get_msg (29));
    3 : ecr_str ('F7 -'+get_msg (31)+' '+get_msg (30));
  end;
end; { dessin_touches_pres }

procedure afficher_tab;
var
   i, j : byte;
   x, y : word;
begin
  clear_jeu;
  textattr := 15;
  gotoxy (1, 22);
  write ('                                        ');
  gotoxy (1, 23);
  write ('                                        ');
  gotoxy (1, 24);
  write ('                                        ');
  compter_tir (num_level, num_tir);
  for j := 1 to 20 do
    for i := 1 to 40 do
      pset (i, j, level [i, j]);
    {endfor}
  {endfor}
  for i := 1 to 40 do
    begin
      mur (pred (i)*8, 20*8);
      tir (pred (i)*8, 20*8);
    end;
  {endfor}
  case etat_prog of
    ecr_jeu :
      begin
        ecr_mode := normal;
        ecr_color (76, 0);
        ecr_xy (2, 23);
        ecr_str (get_msg (4));
        ecr_int (num_level);
        ecr_str (' ');
        add_score (0);
        vie (0);
        bombe (0);
      end;
    ecr_pres :
      begin
        ecr_mode := transparent;
        ecr_color (81, 0);
        ecr_xy (10, 11);
        ecr_str ('(C) PATRICK PREMARTIN');
        ecr_color (80, 0);
        ecr_xy (12, 12);
        ecr_str ('(C) OLF SOFTWARE');
        dessin_touches_pres;
      end;
    ecr_score :
      begin
        dessin_tab_score;
        dessin_touches_pres;
      end;
    ecr_nou_score : dessin_tab_score;
    ecr_pass :
      begin
        ecr_mode := transparent;
        ecr_color (45, 0);
        ecr_xy (17, 18);
        ecr_str ('PASSWORD');
      end;
  end;
end; { afficher_tab }

procedure mode_texte;
begin
  repeat
  until (set_mode (om) or true);
  directvideo := true;
end; { mode_texte }

begin
  om := get_mode;
  if (not set_mode (19))
  then
    begin
      writeln ('VGA or MCGA card needed...');
      halt (1);
    end
  else
    repeat
    until (set_mode (om) or true);
  {endif}
  if (fnt_register (fnt_load ('COPTER'), 1) <> 0)
  then
    begin
      writeln ('Error reading COPTER.FNT...');
      halt (1);
    end;
  {endif}
  nb := fnt_select (1);
  nb := register_sprite ('COPTER');
  pal := load_pal ('COPTER');
end.
