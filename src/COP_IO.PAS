unit cop_io;
{
Auteur: Patrick Pr‚martin.
Date: 13/12/1992. 31/12/1992.
Langage: Turbo Pascal 6.0
But: Gestion des entr‚es/sorties pour le jeu COPTER.
}

interface

procedure sauvegarde_jeu;
procedure charge_jeu;
procedure load_game (n : integer);
procedure save_game (n : integer);

implementation
uses
    crt,
    u_m_util,
    u_msg,
    u_fnt,
    cop_var;

const
     c_copter_save = #8'Copter Saved Game #'#10#13'(c) Olf Software'#10#13#26#0;

procedure sauvegarde_jeu;
var
   c : char;
begin
  while keypressed do
    c := readkey;
  {endwhile}
  ecr_mode := normal;
  ecr_xy (1, 25);
  ecr_color (77, 0);
  ecr_str (get_msg (20));
  repeat
    c := upcase (readkey);
  until ((c = #27) or (c in ['0'..'9']));
  if (c <> #27)
  then
    save_game (ord (c)-48);
  {endif}
  gotoxy (1, 25);
  textattr := $07;
  for c := #1 to #79 do
    write (' ');
  {endfor}
end; { sauvegarde_jeu }

procedure charge_jeu;
var
   c : char;
begin
  while keypressed do
    c := readkey;
  {endwhile}
  ecr_mode := normal;
  ecr_xy (1, 25);
  ecr_color (77, 0);
  ecr_str (get_msg (21));
  repeat
    c := upcase (readkey);
  until ((c = #27) or (c in ['0'..'9']));
  if (c <> #27)
  then
    load_game (ord (c)-48);
  {endif}
  gotoxy (1, 25);
  textattr := $07;
  for c := #1 to #79 do
    write (' ');
  {endfor}
end; { charge_jeu }

procedure load_game (n : integer);
var
   ch : string;
   f : file;
begin
  if (n > 9)
  then
    exit
  else
    begin
      assign (f, 'COPTER_'+chr (48+n)+'.SAV');
      {$i-}
      reset (f, 1);
      {$i+}
      if (ioresult <> 0)
      then
        calert ('COPTER_'+chr (48+n)+'.SAV '+get_msg (19), al_error, 53)
      else
        begin
          blockread (f, ch [0], 1);
          if (ch [0] > #0)
          then
            blockread (f, ch [1], length (ch));
          {endif}
          blockread (f, num_data, sizeof (num_data));
          blockread (f, num_level, sizeof (num_level));
          blockread (f, debut_tableau_score, sizeof (debut_tableau_score));
          blockread (f, debut_tableau_nb_bombe, sizeof (debut_tableau_nb_bombe));
          blockread (f, debut_tableau_nb_vie, sizeof (debut_tableau_nb_vie));
          blockread (f, debut_tableau_tps, sizeof (debut_tableau_tps));
          blockread (f, niveau_diff, sizeof (niveau_diff));
          close (f);
        end;
      {endif}
    end;
  {endif}
end; { load_game }

procedure save_game (n : integer);
var
   ch : string;
   f : file;
begin
  if (n > 9)
  then
    exit
  else
    begin
      ch := c_copter_save;
      ch [pos ('#', ch)] := chr (48+n);
      assign (f, 'COPTER_'+chr (48+n)+'.SAV');
      {$i-}
      rewrite (f, 1);
      {$i+}
      if (ioresult <> 0)
      then
        calert (get_msg (18), al_error, 53)
      else
        begin
          blockwrite (f, ch, succ (length (ch)));
          blockwrite (f, num_data, sizeof (num_data));
          blockwrite (f, num_level, sizeof (num_level));
          blockwrite (f, debut_tableau_score, sizeof (debut_tableau_score));
          blockwrite (f, debut_tableau_nb_bombe, sizeof (debut_tableau_nb_bombe));
          blockwrite (f, debut_tableau_nb_vie, sizeof (debut_tableau_nb_vie));
          blockwrite (f, debut_tableau_tps, sizeof (debut_tableau_tps));
          blockwrite (f, niveau_diff, sizeof (niveau_diff));
          close (f);
        end;
      {endif}
    end;
  {endif}
end; { save_game }

end.
