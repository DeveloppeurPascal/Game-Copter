program Editeur_des_tirs_de_COPTER;
{
Auteur: Patrick Pr‚martin
Date: 14/11/1992. 15/11/1992.
Langage: Turbo Pascal 6.0
But: Mise … jour de la temporisation TIR par TIR des tableaux de COPTER.
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

function saisie_nombre2 (min, max : word) : word;
var
   x, y, n, res : word;
   c : char;
begin
  textcolor (red);
  textbackground (black);
  res := min;
  x := wherex;
  y := wherey;
  repeat
    gotoxy (x, y);
    write (res : 5);
    c := upcase (readkey);
    if (c in ['0'..'9'])
    then
      begin
        n := (res mod 1000)*10;
        if (n > max)
        then
          n := ord (c)-ord ('0')
        else
          n := (res mod 1000)*10+ord (c)-ord ('0');
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
    saisie_nombre2 := succ (max)
  else
    saisie_nombre2 := res;
  {endif}
end; { saisie_nombre2 }

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

procedure sauvegarde;
begin
  save_data_disk (num_data);
end; { sauvegarde }

function compter_tir (num_tab : byte; tst_aff : boolean) : word;
var
   res : word;
   i, j : byte;
   b : boolean;
begin
  res := 0;
  if (tst_aff)
  then
    afficher_tab (num_tab);
  {endif}
  for j := 1 to 20 do
    begin
      b := false;
      for i := 1 to 40 do
        if (data_disk [num_tab] [i, j] and c_tir > 0)
        then
          begin
            if (not b)
            then
              begin
                inc (res);
                if (tst_aff)
                then
                  begin
                    textattr := 51;
                    gotoxy (i, j);
                    write (res);
                  end;
                {endif}
                b := true;
              end;
            {endif}
          end
        else
          b := false;
        {endif}
      {endfor}
    end;
  {endfor}
  compter_tir := res;
end; { compter_tir }

procedure modification;
var
   nb : byte; { Indique le num‚ro du tableau en cours }
   num_tir : word; { Indique le premier tir du tableau }
   nb_tir_tab : word; { Indique le nombre de tirs pour le tableau en cours }
   i : word;
   valeur : t_tempo_tir;
begin
  mode_vga;
  nb := 0;
  num_tir := 0;
  repeat
    inc (nb);
    if (nb < 17)
    then
      nb_tir_tab := compter_tir (nb, true);
    {endif}
  until ((nb_tir_tab > 0) or (nb > 16));
  while (nb < 17) do
    begin
      for i := 1 to nb_tir_tab do
        begin
          repeat
            gotoxy (1, 22);
            textattr := lightblue;
            write ('Tir ');
            textattr := 51;
            write (i:2);
            textattr := lightblue;
            write (':');
            gotoxy (1, 23);
            textattr := 16;
            write ('     Ancienne valeur: ');
            textattr := 18;
            write (get_tempo (pred (num_tir+i)):5);
            gotoxy (1, 24);
            textattr := 20;
            write ('     Nouvelle valeur: ');
            valeur := saisie_nombre2 (0, 1023);
            if ((valeur < 1024) and (valeur > 0))
            then
              set_tempo (pred (num_tir+i), valeur);
            {endif}
          until ((valeur = 1024) or (valeur = 0));
        end;
      {endfor}
      num_tir := nb_tir_tab+num_tir;
      repeat
        inc (nb);
        if (nb < 17)
        then
          nb_tir_tab := compter_tir (nb, true);
        {endif}
      until ((nb_tir_tab > 0) or (nb > 16));
    end;
  {endwhile}
  mode_texte;
end; { modification }

procedure documentation;
var
  nb, j, num : word;
  i : byte;
begin
  gotoxy (10, 20);
  clreol;
  textcolor (lightblue);
  gotoxy (10, 20);
  write ('Documentation en cours...');
  writeln (lst, '     *****     Date: ', get_date_chaine, '     *****     ',
                'Heure: ', get_time_chaine, '     *****     ');
  writeln (lst, 'Documentation tirs COPTER: data disk ', num_data);
  writeln (lst);
  num := 0;
  for i := 1 to 16 do
    begin
      writeln (lst, 'Tableau ', i:2);
      nb := compter_tir (i, false);
      if (nb = 0)
      then
        writeln (lst, '     # Aucun tir pour ce tableau. #')
      else
        for j := 1 to nb do
          writeln (lst, '     Tir ', j, ' = ', get_tempo (pred (j+num)));
        {endfor}
      {endif}
      num := num+nb;
    end;
  {endfor}
  writeln (lst);
  writeln (lst, '***** Fin de la liste des tirs *****', carac_ff);
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
    writeln ('Editeur des tirs pour le logiciel COPTER');
    writeln;
    writeln ('Data disk: ', num_data);
    writeln;
    writeln;
    writeln ('     1 - Chargement des salles');
    writeln ('     4 - Modification des temporisations des tirs');
    writeln ('     6 - Sauvegarde des salles');
    writeln ('     7 - Documentation des salles');
    case (question ('Votre choix ?', 1, 7)) of
      1 : chargement;
      4 : modification;
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
  writeln ('Copter Editeur des tirs '+num_ver);
  writeln ('(c) Patrick Pr‚martin '+dat_ver);
  writeln ('(c) Olf Software');
  writeln;
  chargement;
  traitement;
  textcolor (lightgray);
  textbackground (black);
  clrscr;
  writeln ('Copter Editeur des tirs '+num_ver);
  writeln ('(c) Patrick Pr‚martin '+dat_ver);
  writeln ('(c) Olf Software');
  writeln;
end.
