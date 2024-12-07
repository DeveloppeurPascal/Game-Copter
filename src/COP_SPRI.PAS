unit cop_sprite;
{
Auteur: Patrick Pr‚martin
Date: 29/11/1992. 06/12/1992. 13/12/1992. 01/01/1993.
Langage: Turbo Pascal 6.0
Date: 17/04/1995.
Langage: Borland Pascal 7.0
But: Gestion et animation des diff‚rents sprites.
}
interface
uses
    u_spr;

type
    t_sens = (left, right, up, down);

    p_araignee = ^o_araignee;
    o_araignee =
      object (o_sprite)
        next : p_araignee;
        sens : t_sens;
        constructor init (x, y : word);
        destructor done;
        procedure run;
      end;

    p_ennemi = ^o_ennemi;
    o_ennemi =
      object (o_sprite)
        effet : byte;
        sens : t_sens;
        next : p_ennemi;
        constructor init (x, y : word);
        destructor done;
        procedure tst_ennemi (var x, y : word; l, h, ox, oy : word);
        procedure run;
      end;

    p_joueur = ^o_joueur;
    o_joueur =
      object (o_sprite)
        effet : byte;
        sens : t_sens;
        next : p_joueur;
        constructor init (x, y : word);
        destructor done;
        procedure tst_joueur (var x, y : word; ox, oy : word);
        procedure run;
      end;

    p_tir = ^o_tir;
    o_tir =
      object
        next : p_tir;
        tx, ty, tl,
        ttmax,
        boom,
        tt : word;
        affichage : boolean;
        constructor init (x, y : word; l : byte; t : word);
        destructor done;
        procedure run;
      end;

    p_bonus = ^o_bonus;
    o_bonus =
      object (o_sprite)
        next : p_bonus;
        effet,
        bt : byte;
        sens : t_sens;
        constructor init (x, y : word; bonus_type : byte);
        destructor done;
        procedure run;
      end;

var
   araignee : p_araignee;
   ennemi : p_ennemi;
   joueur : p_joueur;
   tir : p_tir;
   bonus : p_bonus;

   nb_champignon : word;
   tst_joueur : boolean;
   objet_touche : word;

implementation
uses
    cop_deplacement,
    cop_son,
    cop_var,
    cop_jeu,
    cop_score,
    cop_affiche;

var
   nx, ny : word;

function min (a, b : word) : word;
begin
  if (a < b)
  then
    min := a
  else
    min := b;
  {endif}
end; { min }

function max (a, b : word) : word;
begin
  if (a > b)
  then
    max := a
  else
    max := b;
  {endif}
end; { max }

function rien (x1, y1, x2, y2 : word) : boolean;
var
   i, j : word;
   k : byte;
begin
  x1 := min (x1, 319);
  y1 := min (y1, 199);
  x2 := min (x2, 319);
  y2 := min (y2, 199);
  objet_touche := 0;
  i := x1;
  repeat
    j := y1;
    repeat
      k := mem [$a000:i+j*320];
      case k of
        16..25 : objet_touche := objet_touche or c_mur;
        26..29 : objet_touche := objet_touche or c_ennemi;
        30..32 : objet_touche := objet_touche or c_fleur;
        33..35 : objet_touche := objet_touche or c_joueur;
        36..41 : objet_touche := objet_touche or c_champignon;
        57,
        42..45 : objet_touche := objet_touche or c_araignee;
        46..49 : objet_touche := objet_touche or c_piege;
        50..52 : objet_touche := objet_touche or c_tir;
        58..62 : objet_touche := objet_touche or c_bonus;
      end;
      inc (j);
    until (j > y2);
    inc (i);
  until (i > x2);
  rien := (objet_touche = 0);
end; { rien }

constructor o_araignee.init (x, y : word);
begin
  o_sprite.init (nb+24+random (3));
  set_spr (x, y);
  sens := down;
  next := nil;
end; { o_araignee.init }

destructor o_araignee.done;
begin
  if (next <> nil)
  then
    dispose (next, done);
  {endif}
  next := nil;
  o_sprite.done;
end; { o_araignee.done }

procedure o_araignee.run;
begin
  if (numero < nb+26)
  then
    inc (numero)
  else
    numero := nb+24;
  {endif}
  case sens of
    down :
      if (rien (spr_x, spr_y+haut, spr_x+larg-1, spr_y+haut))
      then
        begin
          affiche (spr_x, succ (spr_y));
          mem [$a000:spr_x+(spr_y-1)*320+3] := 57;
        end
      else
        begin
          sens := up;
          affiche (spr_x, spr_y);
        end;
      {endif}
    up :
      if ((spr_y = 0) or (rien (spr_x, spr_y-1, spr_x+larg-1, spr_y-1)))
      then
        begin
          sens := down;
          affiche (spr_x, spr_y);
        end
      else
        if (objet_touche and c_araignee > 0)
        then
          begin
            mem [$a000:spr_x+pred (spr_y)*320+3] := 0;
            affiche (spr_x, pred (spr_y));
          end
        else
          begin
            sens := down;
            affiche (spr_x, spr_y);
          end;
        {endif}
      {endif}
  end;
  if (next <> nil)
  then
    next^.run;
  {endif}
end; { o_araignee.run }

constructor o_ennemi.init (x, y : word);
begin
  o_sprite.init (nb+8);
  set_spr (x, y);
  next := nil;
  effet := 0;
  sens := left;
end; { o_ennemi.init }

destructor o_ennemi.done;
begin
  if (next <> nil)
  then
    dispose (next, done);
  {endif}
  next := nil;
  o_sprite.done;
end; { o_ennemi.done }

procedure o_ennemi.tst_ennemi (var x, y : word; l, h, ox, oy : word);
begin
  if (not rien (x, y, x+l-1, y+h-1))
  then
    begin
      if (objet_touche and c_joueur > 0)
      then
        begin
        end;
      {endif}
      if (objet_touche and c_araignee > 0)
      then
        begin
        end;
      {endif}
      if (objet_touche and c_tir > 0)
      then
        begin
        end;
      {endif}
      if (objet_touche <> c_ennemi)
      then
        begin
          x := ox;
          y := oy;
        end;
      {endif}
    end;
  {endif}
end; { o_ennemi.tst_ennemi }

procedure o_ennemi.run;
var
   i : byte;
begin
  efface;
  if (next <> nil)
  then
    next^.run;
  {endif}
  nx := spr_x;
  ny := spr_y;
  if (joueur <> nil) 
  then
    begin { On se dirige vers le joueur s'il existe }
      if (nx > joueur^.spr_x)
      then
        begin
          dec (nx);
          sens := left;
        end
      else
        if (nx < joueur^.spr_x)
        then
          begin
            inc (nx);
            sens := right;
          end;
        {endif}
      {endif}
      tst_ennemi (nx, ny, larg, haut, spr_x, spr_y);
      if (ny > joueur^.spr_y)
      then
        dec (ny)
      else
        if (ny < joueur^.spr_y)
        then
          inc (ny);
        {endif}
      {endif}
      tst_ennemi (nx, ny, larg, haut, nx, spr_y);
    end
  else
    begin { D‚placement al‚atoire si pas de joueur }
      i := random (256);
      if (i < 128)
      then
        begin
          dec (nx);
          sens := left;
        end
      else
        if (i > 128)
        then
          begin
            inc (nx);
            sens := right;
          end;
        {endif}
      {endif}
      tst_ennemi (nx, ny, larg, haut, spr_x, spr_y);
      i := random (256);
      if (i < 128)
      then
        dec (ny)
      else
        if (i > 128)
        then
          inc (ny);
        {endif}
      {endif}
      tst_ennemi (nx, ny, larg, haut, spr_x, spr_y);
    end;
  {endif}
  if (effet < 3)
  then
    inc (effet)
  else
    effet := 0;
  {endif}
  case sens of
    left :
      numero := nb+8+effet;
    right :
      numero := nb+4+effet;
  end;
  met_sprite (nx, ny);
end; { o_ennemi.run }

constructor o_joueur.init (x, y : word);
begin
  o_sprite.init (nb+14);
  set_spr (x, y);
  next := nil;
  effet := 0;
  sens := right;
end; { o_joueur.init }

destructor o_joueur.done;
begin
  if (next <> nil)
  then
    dispose (next, done);
  {endif}
  next := nil;
  o_sprite.done;
end; { o_joueur.done }

procedure o_joueur.tst_joueur (var x, y : word; ox, oy : word);

  procedure traite_champignons (a, b : word);
  var
     i, j : word;
  begin
    if (level [a+1, b+1] and c_champignon > 0)
    then
      begin
        level [a+1, b+1] := 0;
        for i := a*8 to a*8+7 do
          for j := b*8 to b*8+7 do
            mem [$a000:i+j*320] := 0;
          {endfor}
        {endfor}
        add_score (c_champignon);
        dec (nb_champignon);
      end;
    {endif}
  end; { traite_champignon }

begin
  if (not rien (x, y, x+15, y+7))
  then
    begin
      if (objet_touche and c_ennemi > 0)
      then
        begin
        end;
      {endif}
      if (objet_touche and c_araignee > 0)
      then
        begin
        end;
      {endif}
      if (objet_touche and c_fleur > 0)
      then
        begin
        end;
      {endif}
      if (objet_touche and c_champignon > 0)
      then
        begin
          traite_champignons (x div 8, y div 8);
          traite_champignons (x div 8, (y+7) div 8);
          traite_champignons ((x+8) div 8, y div 8);
          traite_champignons ((x+8) div 8, (y+7) div 8);
          traite_champignons ((x+15) div 8, y div 8);
          traite_champignons ((x+15) div 8, (y+7) div 8);
        end;
      {endif}
      if (objet_touche and c_mur > 0)
      then
        if rien (x, oy, x+15, oy+7)
        then y := oy
        else
          if rien (ox, y, ox+15, y+7)
          then x := ox
          else
            begin
              x := ox;
              y := oy;
            end;
          {endif}
        {endif}
      {endif}
    end;
  {endif}
end; { o_joueur.tst_joueur }

procedure o_joueur.run;
begin
  nx := spr_x;
  ny := spr_y;
  deplacement_joueur (nx, ny);
  if (nx < spr_x)
  then
    sens := left
  else
    if (nx > spr_x)
    then
      sens := right;
    {endif}
  {endif}
  if (effet < 3)
  then
    inc (effet)
  else
    effet := 0;
  {endif}
  case sens of
    left :
      numero := nb+18+effet;
    right :
      numero := nb+14+effet;
  end;
  tst_joueur (nx, ny, spr_x, spr_y);
  affiche (nx, ny);
  if (next <> nil)
  then
    next^.run;
  {endif}
end; { o_joueur.run }

constructor o_tir.init (x, y : word; l : byte; t : word);
begin
  tx := pred (x)*8;
  ty := pred (y)*8;
  tl := (pred (l*8)) mod 320;
  ttmax := t;
  tt := ttmax;
  next := nil;
  affichage := false;
  boom := 0;
end; { o_tir.init }

destructor o_tir.done;
begin
  if (next <> nil)
  then
    dispose (next, done);
  {endif}
  next := nil;
end; { o_tir.done }

procedure o_tir.run;
var
   i, j : word;
begin
  dec (tt);
  if (tt = 0)
  then
    begin
      boom := 0;
      tt := ttmax;
      affichage := not affichage;
      j := tx+ty*320+3*320;
      case affichage of
        true :
          for i := 0 to tl do
            begin
              if (not rien (tx+i, ty+3, tx+i, ty+4))
              then
                boom := 10;
              {endif}
              mem [$a000:i+j] := 50;
              mem [$a000:i+j+320] := 52;
            end;
          {endfor}
        false :
          begin
            for i := 0 to tl do
              begin
                mem [$a000:i+j] := 0;
                mem [$a000:i+j+320] := 0;
              end;
            {endfor}
          end;
      end;
    end;
  {endif}
  if (boom > 0)
  then
    begin
      j := tx+ty*320+3*320;
      dec (boom);
      for i := 0 to tl do
        begin
          mem [$a000:i+j+random (2)*320] := 51;
          son (random (200)+100);
        end;
      {endfor}
      if (boom = 0)
      then
        begin
          for i := 0 to tl do
            begin
              mem [$a000:i+j] := 0;
              mem [$a000:i+j+320] := 0;
              son (random (200)+100);
            end;
          {endfor}
          affichage := false;
        end;
      {endif}
      fin_son;
    end;
  {endif}
  if (next <> nil)
  then
    next^.run;
  {endif}
end; { o_tir.run }

constructor o_bonus.init (x, y : word; bonus_type : byte);
begin
  o_sprite.init (nb+30+random (3));
  set_spr (x, y);
  sens := left;
  next := nil;
  effet := 0;
  bt := bonus_type;
end; { o_bonus.init }

destructor o_bonus.done;
begin
  if (next <> nil)
  then
    dispose (next, done);
  {endif}
  next := nil;
  o_sprite.done;
end; { o_bonus.done }

procedure o_bonus.run;
begin
  if (effet = 0)
  then
    begin
      effet := 2;
      case sens of
        left :
          if (numero > nb+30)
          then
            dec (numero)
          else
            sens := right;
          {endif}
        right :
          if (numero < nb+32)
          then
            inc (numero)
          else
            sens := left;
          {endif}
      end;
    end
  else
    dec (effet);
  {endif}
  affiche (spr_x, spr_y);
  if (next <> nil)
  then
    next^.run;
  {endif}
end; { o_bonus.run }

end.
