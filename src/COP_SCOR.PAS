unit cop_score;
{
Auteur: Patrick Pr‚martin.
Date: 13/12/1992. 31/12/1992. 01/01/1993.
Langage: Turbo Pascal 6.0
But: Gestion du score des joueurs de COPTER.
}
interface
type
    string20 = string [20];
    t_player =
      record
        nom : string20;
        dtdk : byte;
        lvl : byte;
        score : longint;
      end;
    t_score = array [1..5] of t_player;

var
   tab_score : t_score;

procedure add_score (n : word);
     { Permet le calcul du score: n correspond … l'objet touch‚. }
procedure vie (n : integer);
     { Permet d'ajouter ou d'enlever une vie. }
procedure bombe (n : integer);
     { Permet d'ajouter ou d'enlever des bombes. }

implementation
uses
    u_fnt,
    u_msg,
    u_spr,
    cop_jeu,
    cop_var;

const
     c_copter_score = #8'COPTER BEST SCORE'#10#13'(c) Olf Software'#10#13#26#0;

procedure add_score (n : word);
begin
  case n of
    c_champignon : inc (score, 3);
    c_bonus_temps : inc (score, 50);
    c_bonus_bombe : inc (score, 30);
    c_fleur : inc (score, 10);
    c_ennemi : inc (score, 100);
  end;
  ecr_mode := normal;
  ecr_xy (2, 22);
  ecr_color (78, 0);
  ecr_str (get_msg (2));
  ecr_int (score);
  ecr_xy (20, 22);
  ecr_color (79, 0);
  ecr_str (get_msg (3)+' ');
  ecr_int (high_score);
end; { add_score }

procedure vie (n : integer);
begin
  if ((n >= 0) or ((n < 0) and (nb_vie >= -n)))
  then
    nb_vie := nb_vie + n
  else
    nb_vie := 0;
  {endif}
  ecr_mode := normal;
  ecr_xy (20, 23);
  ecr_color (77, 0);
  ecr_str (get_msg (5));
  ecr_int (nb_vie);
end; { vie }

procedure bombe (n : integer);
var
   i, j : word;
begin
  if ((n >= 0) or ((n < 0) and (nb_bombe >= -n)))
  then
    nb_bombe := nb_bombe + n
  else
    nb_bombe := 0;
  {endif}
  for i := 30*8 to 39*8+7 do
    for j := 22*8 to 23*8+7 do
      mem [$a000: i+j*320] := 0;
    {endfor}
  {endfor}
  for i := 1 to nb_bombe do
    liste_sprite^.affiche (nb+33, ((i-1) mod 10)*8+29*8,((i-1) div 10)*8+21*8);
  {endfor}
end; { bombe }

procedure cop_score_init;
var
   i : byte;
   f : file;
   ch : string;
begin
  assign (f, 'COPTER.SCR');
  {$i-}
  reset (f, 1);
  {$i+}
  if (ioresult <> 0)
  then
    for i := 1 to 5 do
      begin
        tab_score [i].nom := '';
        tab_score [i].dtdk := 0;
        tab_score [i].lvl := 1;
        tab_score [i].score := 0;
      end
    {endfor}
  else
    begin
      blockread (f, ch [0], 1);
      if (ch [0] <> #0)
      then
        blockread (f, ch [1], length (ch));
      {endif}
      blockread (f, tab_score, sizeof (tab_score));
      close (f);
    end;
  {endif}
  high_score := tab_score [1].score;
end; { cop_score_init }

var
   old_exitproc : pointer;

procedure cop_score_done; far;
var
   f : file;
   i : byte;
   ch : string;
begin
  exitproc := old_exitproc;
  assign (f, 'COPTER.SCR');
  {$i-}
  rewrite (f, 1);
  {$i+}
  if (ioresult = 0)
  then
    begin
      ch := c_copter_score;
      blockwrite (f, ch, succ (length (ch)));
      blockwrite (f, tab_score, sizeof (tab_score));
      close (f);
    end;
  {endif}
end; { cop_score_done }

begin
  cop_score_init;
  old_exitproc := exitproc;
  exitproc := @cop_score_done;
end.
