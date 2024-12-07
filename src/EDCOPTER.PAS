program Copter_Editeur;
{
Auteur: Patrick Pr‚martin
Date: 01/11/1992. 14/11/1992. 15/11/1992.
Langage: Turbo Pascal 6.0
But: Editeur de tableaux (et de data_disk) pour le jeu COPTER.
}
uses
    cop_var,
    ed_modif,
    crt,
    printer,
    u_time,
    u_date,
    u_code_clavier;

const
     num_ver = '1.0';
     dat_ver = '15/11/1992';

function saisie_nombre (min, max : byte) : byte;
var
   x, y, n, res : byte;
   c : char;
begin
  textcolor (red);
  textbackground (black);
  res := min;
  x := wherex;
  y := wherey;
  repeat
    clreol;
    gotoxy (x, y);
    write (res : 2);
    c := upcase (readkey);
    if (c in ['0'..'9'])
    then
      begin
        n := (res mod 10)*10;
        if (n > max)
        then
          n := ord (c)-ord ('0')
        else
          n := (res mod 10)*10+ord (c)-ord ('0');
        {endif}
        if ((n >= min) and (n <= max))
        then
          res := n;
        {endif}
      end;
    {endif}
  until (c in [touche_escape, touche_return]);
  if (c = touche_escape)
  then
    saisie_nombre := succ (max)
  else
    saisie_nombre := res;
  {endif}
end; { saisie_nombre }

function question (ch : string; min, max : byte) : byte;
begin
  textcolor (lightblue);
  gotoxy (10, 20);
  clreol;
  gotoxy (10, 20);
  write (ch, ' ');
  question := saisie_nombre (min, max);
end; { question }

procedure chargement;
var
   n : byte;
begin
  n := question ('Data-disk … modifier ?', 0, 99);
  if (n < 100)
  then
    if (test_exist (n))
    then
      load_data_disk (n)
    else
      init_data_disk (n);
    {endif}
  {endif}
end; { chargement }

procedure copie;
var
   i, j : byte;
   k, l : byte;
begin
  i := question ('Tableau … copier ?', 1, 16);
  if (i < 17)
  then
    begin
      j := question ('Vers le tableau ?', 1, 16);
      if (j < 17)
      then
        begin
          data_disk [j] := data_disk [i];
        end;
      {endif}
    end;
  {endif}
end; { copie }

procedure effacement;
var
   n : byte;
   k, l : byte;
begin
  n := question ('Tableau … effacer ?', 1, 16);
  if (n < 17)
  then
    for k := 1 to 40 do
      for l := 1 to 20 do
        data_disk [n] [k, l] := 0;
      {endfor}
    {endfor}
  {endif}
end; { effacement }

procedure modification;
var
   n : byte;
begin
  n := question ('Tableau … modifier ?', 1, 16);
  if (n < 17)
  then
    modifier (n);
  {endif}
end; { modification }

procedure permutation;
var
   i, j : byte;
   t : t_tab;
begin
  i := question ('Tableau 1 … permuter ?', 1, 16);
  if (i < 17)
  then
    begin
      j := question ('Tableau 2 … permuter ?', 1, 16);
      if (j < 17)
      then
        begin
          t := data_disk [i];
          data_disk [i] := data_disk [j];
          data_disk [j] := t;
        end;
      {endif}
    end;
  {endif}
end; { permutation }

procedure sauvegarde;
begin
  set_default_tir;
  save_data_disk (num_data);
end; { sauvegarde }

procedure documentation;
var
   i, j, k, n : byte;
   c : char;
begin
  gotoxy (10, 20);
  clreol;
  textcolor (lightblue);
  gotoxy (10, 20);
  write ('Documentation en cours...');
  for n := 1 to 16 do
    begin
      writeln (lst, '     *****     Date: ', get_date_chaine, '     *****     ',
                    'Heure: ', get_time_chaine, '     *****     ');
      writeln (lst, 'Documentation COPTER: data disk ', num_data);
      writeln (lst);
      writeln (lst, 'Tableau ', n);
      writeln (lst);
      for i := 1 to 19 do
        write (lst, ' ');
      {endfor}
      write (lst, #218);
      for i := 1 to 40 do
        write (lst, #196);
      {endfor}
      writeln (lst, #191);
      for j := 1 to 20 do
        begin
          for i := 1 to 19 do
            write (lst, ' ');
          {endfor}
          write (lst, #179);
          for i := 1 to 40 do
            begin
              k := data_disk [n] [i, j];
              c := '.';
              if (0 < (k and c_piege))
              then
                c := 'P';
              {endif}
              if (0 < (k and c_mur))
              then
                c := 'M';
              {endif}
              if (0 < (k and c_ennemi))
              then
                c := 'E';
              {endif}
              if (0 < (k and c_joueur))
              then
                c := 'H';
              {endif}
              if (0 < (k and c_fleur))
              then
                c := 'F';
              {endif}
              if (0 < (k and c_champignon))
              then
                c := 'C';
              {endif}
              if (0 < (k and c_araignee))
              then
                c := 'A';
              {endif}
              if (0 < (k and c_tir))
              then
                c := 'T';
              {endif}
              write (lst, c);
            end;
          {endfor}
          writeln (lst, #179);
        end;
      {endfor}
      for i := 1 to 19 do
        write (lst, ' ');
      {endfor}
      write (lst, #192);
      for i := 1 to 40 do
        write (lst, #196);
      {endfor}
      write (lst, #217);
      writeln (lst);
      writeln (lst, 'L‚gende:     A  - Araign‚e  ', '     C  - Champignon',
                    '     EE - Ennemis   ');
      writeln (lst, '             F  - Fleur     ', '     HH - Joueur    ',
                    '     M  - Mur       ');
      writeln (lst, '             PP - PiŠge     ', '     T  - Tir       ');
      if (n mod 2 = 0)
      then
        writeln (lst, carac_ff)
      else
        writeln (lst, '-------------------------------------------------------'+
                      '-------------------------');
      {endif}
    end;
  {endfor}
end; { documentation }

procedure traitement;
var
   fin : boolean;
begin
  fin := false;
  repeat
    textcolor (lightgray);
    textbackground (black);
    clrscr;
    writeln ('Editeur de tableaux pour le logiciel COPTER');
    writeln;
    writeln ('Data disk: ', num_data);
    writeln;
    writeln;
    writeln ('     1 - Chargement des salles');
    writeln ('     2 - Copie');
    writeln ('     3 - Effacement');
    writeln ('     4 - Modification');
    writeln ('     5 - Permutation');
    writeln ('     6 - Sauvegarde des salles');
    writeln ('     7 - Documentation des salles');
    case (question ('Votre choix ?', 1, 7)) of
      1 : chargement;
      2 : copie;
      3 : effacement;
      4 : modification;
      5 : permutation;
      6 : sauvegarde;
      7 : documentation;
      8 : fin := true;
    end;
  until fin;
end; { traitement }

begin
  textcolor (lightgray);
  textbackground (black);
  clrscr;
  writeln ('Copter Editeur '+num_ver);
  writeln ('(c) Patrick Pr‚martin '+dat_ver);
  writeln ('(c) Olf Software');
  writeln;
  chargement;
  traitement;
  textcolor (lightgray);
  textbackground (black);
  clrscr;
  writeln ('Copter Editeur '+num_ver);
  writeln ('(c) Patrick Pr‚martin '+dat_ver);
  writeln ('(c) Olf Software');
  writeln;
end.
