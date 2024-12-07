unit ed_modif;
{
Auteur: Patrick PrÇmartin
Date: 01/11/1992. 14/11/1992.
Langage: Turbo Pascal 6.0
But: Modification des tableaux de COPTER.
}

interface

procedure modifier (num : byte);
procedure afficher_tab (num : byte);
procedure mode_vga;
procedure mode_texte;

implementation
uses
    cop_var,
    u_code_clavier,
    crt,
    u_int10h,
    u_pal,
    u_spr;

var
   om : byte;
   nb : word;
   pal : p_pal;

procedure mode_vga;
begin
  directvideo := false;
  repeat
  until (set_mode (19) or true);
  use_pal (pal);
end; { mode_vga }

procedure mur (x, y : word);
begin
  liste_sprite^.affiche (nb+(x mod 4), x, y);
end; { mur }

procedure fleur (x, y : word);
begin
  liste_sprite^.affiche (nb+12+(x mod 2), x, y);
end; { fleur }

procedure champignon (x, y : word);
begin
  liste_sprite^.affiche (nb+22+(x mod 2), x, y);
end; { champignon }

procedure araignee (x, y : word);
begin
  liste_sprite^.affiche (nb+24+(y mod 3), x, y);
end; { araignee }

procedure joueur (x, y : word);
begin
  liste_sprite^.affiche (nb+14+(x mod 4), x, y);
end; { joueur }

procedure ennemi (x, y : word);
begin
  liste_sprite^.affiche (nb+8+(x mod 4), x, y);
end; { ennemi }

procedure piege (x, y : word);
begin
  liste_sprite^.affiche (nb+29, x, y);
end; { piege }

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
  {endfor}
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

function impair (num, x, y, test : byte) : boolean;
var
   n : byte;
begin
  n := 1;
  while ((x > 1) and (data_disk [num] [x-1, y] and test > 0)) do
    begin
      inc (n);
      dec (x);
    end;
  {endwhile}
  impair := (n mod 2 = 1);
end; { impair }

procedure pset (i, j : byte; k, num : byte);
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
    if (impair (num, i, j, c_joueur))
    then
      joueur (x, y)
    else
      joueur (x-8, y);
    {endif}
  {endif}
  if (0 < (k and c_ennemi))
  then
    if (impair (num, i, j, c_ennemi))
    then
      ennemi (x, y)
    else
      ennemi (x-8, y);
    {endif}
  {endif}
  if (0 < (k and c_piege))
  then
    if (impair (num, i, j, c_piege))
    then
      piege (x, y)
    else
      piege (x-8, y);
    {endif}
  {endif}
  if (0 < (k and c_tir))
  then
    tir (x, y);
  {endif}
end; { pset }

procedure afficher_tab (num : byte);
var
   i, j : byte;
   x, y : word;
begin
  for j := 1 to 20 do
    for i := 1 to 40 do
      pset (i, j, data_disk [num] [i, j], num);
    {endfor}
  {endfor}
  for i := 1 to 40 do
    begin
      mur (pred (i)*8, 20*8);
      tir (pred(i)*8, 20*8);
    end;
  {endfor}
end; { afficher_tab }

procedure mode_texte;
begin
  repeat
  until (set_mode (om) or true);
  directvideo := true;
end; { mode_texte }

procedure curseur (x, y : word);
var
   i, j : word;
begin
  x := pred (x)*8;
  y := pred (y)*8;
  for i := x to x+7 do
    begin
      {$r-}
      mem [$a000:i+y*320] := 16;
      mem [$a000:i+(y+7)*320] := 49;
      {$r+}
    end;
  {endfor}
  for j := y to y+7 do
    begin
      {$r-}
      mem [$a000:x+j*320] := 16;
      mem [$a000:x+7+j*320] := 49;
      {$r+}
    end;
  {endfor}
end; { curseur }

procedure modifier (num : byte);
var
   x, y, old : byte;
   k : word;
   c : char;
   tmove,
   fin : boolean;

   procedure depl (nx, ny : integer);
   begin
     pset (x, y, data_disk [num] [x, y], num);
     while (nx > 40) do
       begin
         inc (ny);
         dec (nx, 40);
       end;
     {endwhile}
     while (nx < 1) do
       begin
         dec (ny);
         inc (nx, 40);
       end;
     {endwhile}
     x := nx;
     while (ny > 20) do
       begin
         dec (ny, 20);
       end;
     {endwhile}
     while (ny < 1) do
       begin
         inc (ny, 20);
       end;
     {endwhile}
     y := ny;
     pset (x, y, data_disk [num] [x, y], num);
     curseur (x, y);
   end; { depl }

begin
  mode_vga;
  afficher_tab (num);
  x := 1;
  y := 1;
  depl (1, 1);
  fin := false;
  repeat
    old := data_disk [num] [x, y];
    c := readkey;
    tmove := true;
    case c of
      carac_nul :
        begin
          case readkey of
            touche_haut : depl (x, pred (y));
            touche_bas : depl (x, succ (y));
            touche_gauche : depl (pred (x), y);
            touche_droite : depl (succ (x), y);
            touche_home : depl (1, y);
            touche_end : depl (40, y);
          end;
          tmove := false;
        end;
      'A',
      'a' : data_disk [num] [x, y] := c_araignee;
      'C',
      'c' : data_disk [num] [x, y] := c_champignon;
      'F',
      'f' : data_disk [num] [x, y] := c_fleur;
      'H',
      'h' :
        if (x < 40)
        then
          begin
            data_disk [num] [x, y] := c_joueur;
            depl (x+1, y);
            data_disk [num] [x, y] := c_joueur;
          end;
        {endif}
      'E',
      'e' :
        if (x < 40)
        then
          begin
            data_disk [num] [x, y] := c_ennemi;
            depl (x+1, y);
            data_disk [num] [x, y] := c_ennemi;
          end;
        {endif}
      'M',
      'm' : data_disk [num] [x, y] := c_mur;
      'P',
      'p' :
        if (x < 40)
        then
          begin
            data_disk [num] [x, y] := c_piege;
            depl (x+1, y);
            data_disk [num] [x, y] := c_piege;
          end;
        {endif}
      'T',
      't' :
        if (old and (c_joueur+c_ennemi+c_araignee) = 0)
        then
          data_disk [num] [x, y] := data_disk [num] [x, y] or c_tir;
        {endif}
      ' ' : data_disk [num] [x, y] := 0;
      touche_return,
      touche_escape : fin := true;
    else
      tmove := false;
    end;
    if (tmove)
    then
      begin
        k := 0;
        if (old and c_joueur > 0)
        then
          k := c_joueur;
        {endif}
        if (old and c_ennemi > 0)
        then
          k := c_ennemi;
        {endif}
        if (old and c_piege > 0)
        then
          k := c_piege;
        {endif}
        if (k > 0)
        then
          begin
            if ((x = 1) and (data_disk [num] [x+1, y] = old))
            then
              data_disk [num] [x+1, y] := 0
            else
              if ((x = 40) and (data_disk [num] [x-1, y] = old))
              then
                data_disk [num] [x-1, y] := 0
              else
                if (impair (num, x, y, k))
                then
                  begin { premier caractäre }
                    if (data_disk [num] [x+1, y] = old)
                    then
                      data_disk [num] [x+1, y] := 0;
                    {endif}
                  end
                else
                  begin { deuxiäme caractäre }
                    if (data_disk [num] [x-1, y] = old)
                    then
                      data_disk [num] [x-1, y] := 0;
                    {endif}
                  end;
                {endif}
              {endif}
            {endif}
          end;
        {endif}
        depl (x-1, y);
        depl (x+2, y);
      end;
    {endif}
  until fin;
  mode_texte;
end; { modifier }

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
  nb := register_sprite ('COPTER');
  pal := load_pal ('COPTER');
end.
