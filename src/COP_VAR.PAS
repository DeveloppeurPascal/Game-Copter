unit cop_var;
{
Auteur: Patrick Pr‚martin
Date: 01/11/1992. 14/11/1992. 15/11/1992. 29/11/1992. 13/12/1992. 31/12/1992.
      01/01/1993.
Langage: Turbo Pascal 6.0
But: Unit‚ regroupant les d‚clarations de types et de variables utilis‚s par le
     jeu COPTER ainsi que l'‚diteur de tableaux.
}

interface
const
     c_araignee = 1;
     c_champignon = 2;
     c_fleur = 4;
     c_joueur = 8;
     c_ennemi = 16;
     c_mur = 32;
     c_piege = 64;
     c_tir = 128;
     c_bonus = 256;
     c_bonus_temps = 512;
     c_bonus_bombe = 1024;

     c_copter_data_disk = #8'COPTER Data Disk ##'#10#13'(c) Olf Software'#10#13+
                          'all rights reserved for all world'#10#13#26#0;

     c_nb_vie = 5;
     c_nb_bombe = 5;
     c_tps = 24*8*10;

type
    t_typ_depl = (joystick, souris, clavier);
    t_tab = array [1..40, 1..20] of byte;
    t_data = array [1..16] of t_tab;
    t_tempo_tir = word;

var
   typ_depl : t_typ_depl;
        { Type de d‚placement choisi par le joueur (Souris, Clavier, Joystick) }
   data_disk : t_data;
        { Donn‚es concernant le data-disk actuel }
   tab_tir : pointer;
        { Table contenant les tempos de tous les tirs du data-disk }
   speed : byte;
        { Vitesse du jeu }
   num_data : byte;
        { Num‚ro du data-disk actuel }
   nb_tir : word;
        { Nombre de tirs … g‚rer dans ce tableau }
   debut_tableau_nb_vie,
   nb_vie : byte;
        { Nombre de vies restant au joueur }
   debut_tableau_nb_bombe,
   nb_bombe : byte;
        { Nombre de bombes du joueur }
   debut_tableau_tps,
        { Temps restant au joueur avant de commencer ce tableau }
   tps : word;
        { Temps restant au joueur pour finir ce tableau }
   debut_tableau_score,
        { Score qu'avait le joueur au d‚but du tableau en cours }
   score,
        { Score actuellement r‚alis‚ par le joueur }
   high_score : longint;
        { Meilleur score r‚alis‚ pour ce data disk }
   niveau_diff : byte;
        { Niveau de difficult‚: 1 - Facile:
                         - Temps maxi … chaque tableau,
                         - 5 bombes … chaque tableau,
                         - Ennemis vuln‚rables aux tirs et araign‚es.
                                2 - Moyen:
                         - Temps maxi … chaque tableau,
                         - Bombes non r‚initialis‚es,
                         - Ennemis vuln‚rables aux tirs.
                                3 - Difficile,
                         - Temps non r‚initialis‚,
                         - Bombes non r‚initialis‚es,
                         - Ennemis invuln‚rables. }
   num_level : byte;
        { Num‚ro du tableau actuel }
   fin_prog : boolean;
        { Indique la fin de la partie actuelle par ESC }
   etat_prog : (ecr_pres, ecr_score, ecr_nou_score, ecr_pass, ecr_jeu);
        { Indique l'‚tat du programme:
             - ecr_pres = Ecran de pr‚sentation
             - ecr_score = Ecran des scores
             - ecr_nou_score = Ecran de saisie d'un score
             - ecr_pass = Ecran de saisie d'un mot de passe
             - ecr_jeu = Ecran du jeu }

procedure init_debut_tableau;

function test_exist (num : byte) : boolean;
procedure init_data_disk (num : byte);
procedure load_data_disk (num : byte);
procedure save_data_disk (num : byte);

function get_tempo (num_tir : word) : t_tempo_tir;
procedure set_tempo (num_tir : word; valeur : t_tempo_tir);
procedure set_default_tir;
procedure compter_tir (num_level : byte; var num_tir : word);

implementation
var
   taille_tab_tir : word;

procedure init_debut_tableau;
begin
  debut_tableau_nb_vie := nb_vie;
  debut_tableau_nb_bombe := nb_bombe;
  debut_tableau_score := score;
  debut_tableau_tps := tps;
end; { init_debut_tableau }

function test_exist (num : byte) : boolean;
var
   ch, n : string;
   f : file;
begin
  while (num > 99) do
    dec (num, 100);
  {endwhile}
  str (num, n);
  while (n [0] < #2) do
    n := '0'+n;
  {endwhile}
  ch := 'COPTER'+n+'.DAT';
  assign (f, ch);
  {$i-}
  reset (f, 1);
  close (f);
  {$i+}
  test_exist := (ioresult = 0);
end; { test_exist }

procedure init_data_disk (num : byte);
var
   i, j, k : byte;
begin
  while (num > 99) do
    dec (num, 100);
  {endwhile}
  num_data := num;
  for i := 1 to 16 do
    for j := 1 to 40 do
      for k := 1 to 20 do
        data_disk [i] [j, k] := 0;
      {endfor}
    {endfor}
  {endfor}
end; { init_data_disk }

procedure load_data_disk (num : byte);
var
   f : file;
   ch : string;
   n : string;
   nb : byte;
begin
  while (num > 99) do
    dec (num, 100);
  {endwhile}
  str (num, n);
  while (n [0] < #2) do
    n := '0'+n;
  {endwhile}
  ch := 'COPTER'+n+'.DAT';
  assign (f, ch);
  {$i-}
  reset (f, 1);
  {$i+}
  if (ioresult <> 0)
  then
    begin
      writeln ('Can not load data disk '+ch+' ...');
      halt (ioresult);
    end;
  {endif}
  blockread (f, ch [0], 1);
  if (ch [0] > #0)
  then
    blockread (f, ch [1], length (ch));
  {endif}
  blockread (f, num_data, sizeof (num_data));
  blockread (f, data_disk, sizeof (data_disk));
  if not eof (f)
  then
    begin
      if (tab_tir <> nil)
      then
        freemem (tab_tir, taille_tab_tir);
      {endif}
      blockread (f, nb_tir, sizeof (nb_tir));
      taille_tab_tir := nb_tir * sizeof (t_tempo_tir);
      getmem (tab_tir, taille_tab_tir);
      blockread (f, tab_tir^, taille_tab_tir);
    end
  else
    begin
      nb_tir := 0;
      if (tab_tir <> nil)
      then
        freemem (tab_tir, taille_tab_tir);
      {endif}
      tab_tir := nil;
    end;
  {endif}
  close (f);
end; { load_data_disk }

procedure save_data_disk (num : byte);
var
   f : file;
   ch : string;
   n : string;
   nb : byte;
begin
  while (num > 99) do
    dec (num, 100);
  {endwhile}
  str (num, n);
  while (n [0] < #2) do
    n := '0'+n;
  {endwhile}
  ch := 'COPTER'+n+'.DAT';
  assign (f, ch);
  {$i-}
  rewrite (f, 1);
  {$i+}
  if (ioresult <> 0)
  then
    begin
      writeln ('Can not save data disk '+ch+' ...');
      halt (ioresult);
    end;
  {endif}
  ch := c_copter_data_disk;
  nb := pos ('##', ch);
  ch := copy (ch, 1, pred (nb))+ n+ copy (ch, nb+2, length (ch));
  blockwrite (f, ch [0], succ (length (ch)));
  blockwrite (f, num, sizeof (num));
  blockwrite (f, data_disk, sizeof (data_disk));
  if (nb_tir > 0)
  then
    begin
      blockwrite (f, nb_tir, sizeof (nb_tir));
      blockwrite (f, tab_tir^, taille_tab_tir);
    end;
  {endif}
  close (f);
end; { save_data_disk }

function get_tempo (num_tir : word) : t_tempo_tir;
var
   res : t_tempo_tir;
   p : ^t_tempo_tir;
begin
  if ((succ (num_tir) > nb_tir) or (tab_tir = nil))
  then
    res := 0
  else
    begin
      {$r-}
      p := ptr (seg (tab_tir^), ofs (tab_tir^)+num_tir*sizeof (t_tempo_tir));
      res := p^;
      {$r-}
    end;
  {endif}
  get_tempo := res;
end; { get_tempo }

procedure set_tempo (num_tir : word; valeur : t_tempo_tir);
var
   p : ^t_tempo_tir;
begin
  if not ((succ (num_tir) > nb_tir) or (tab_tir = nil))
  then
    begin
      {$r-}
      p := ptr (seg (tab_tir^), ofs (tab_tir^)+num_tir*sizeof (t_tempo_tir));
      p^ := valeur;
      {$r-}
    end;
  {endif}
end; { set_tempo }

procedure set_default_tir;
var
   num, i, j, n : byte;
   num_tir : word;
   b : boolean;
begin
  { Elimination des pr‚c‚dentes valeurs. }
  if (nb_tir > 0)
  then
    begin
      nb_tir := 0;
      if (tab_tir <> nil)
      then
        freemem (tab_tir, taille_tab_tir);
      {endif}
    end;
  {endif}
  { On va compter le nombre de tirs dans le data-disk }
  nb_tir := 0;
  for num := 1 to 16 do
    for j := 1 to 20 do
      begin
        b := false;
        for i := 1 to 40 do
          begin
            if (data_disk [num] [i, j] and c_tir > 0)
            then
              begin
                if not (b)
                then
                  begin
                    b := true;
                    inc (nb_tir);
                  end;
                {endif}
              end
            else
              b := false;
            {endif}
          end;
        {endfor}
      end;
    {endfor}
  {endfor}
  { On cr‚e les valeurs par d‚faut pour les diff‚rents tirs. }
  taille_tab_tir := nb_tir * sizeof (t_tempo_tir);
  if (taille_tab_tir = 0)
  then
    tab_tir := nil
  else
    begin
      getmem (tab_tir, taille_tab_tir);
      num_tir :=0;
      for num := 1 to 16 do
        for j := 1 to 20 do
          begin
            n := 0;
            b := false;
            for i := 1 to 40 do
              begin
                if (data_disk [num] [i, j] and c_tir > 0)
                then
                  begin
                    inc (n);
                    if not (b)
                    then
                      b := true;
                    {endif}
                  end
                else
                  if (b)
                  then
                    begin
                      set_tempo (num_tir, 16+n*8);
                      inc (num_tir);
                      n := 0;
                      b := false;
                    end;
                  {endif}
                {endif}
              end;
            {endfor}
            if (b)
            then
              begin
                set_tempo (num_tir, 16+n*8);
                inc (num_tir);
                n := 0;
                b := false;
              end;
            {endif}
          end;
        {endfor}
      {endfor}
    end;
  {endif}
end; { set_default_tir }

procedure compter_tir (num_level : byte; var num_tir : word);
var
   i, j, k : byte;
begin
  num_tir := 0;
  if ((num_level > 1) and (num_level < 17))
  then
    for i := 1 to pred (num_level) do
      for j := 1 to 20 do
        for k := 1 to 40 do
          if (data_disk [i] [j, k] and c_tir > 0)
          then
            if ((j = 1) or (data_disk [i] [pred (j), k] and c_tir = 0))
            then
              inc (num_tir);
            {endif}
          {endif}
        {endfor}
      {endfor}
    {endfor}
  {endif}
end; { compter_tir }

var
   old_exitproc : pointer;

procedure exit_cop_var; far;
begin
  if (tab_tir <> nil)
  then
    freemem (tab_tir, taille_tab_tir);
  {endif}
  tab_tir := nil;
  exitproc := old_exitproc;
end; { exit_cop_var }

begin
  typ_depl := clavier;
  tab_tir := nil;
  taille_tab_tir := 0;
  speed := 5;
  num_data := 0;
  nb_tir := 0;
  nb_vie := c_nb_vie;
  nb_bombe := c_nb_bombe;
  tps := c_tps;
  score := 0;
  high_score := 0;
  niveau_diff := 1;
  num_level := 1;
  init_debut_tableau;
  old_exitproc := exitproc;
  exitproc := @exit_cop_var;
end.
