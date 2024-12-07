unit cop_deplacement;
{
Auteur: Patrick Pr‚martin
Date: 13/12/1992. 01/01/1993.
Langage: Turbo Pascal 6.0
Date: 17/04/1995.
Langage: Borland Pascal 7.0
But: Gestion des mouvements de l'h‚licoptŠre du joueur.
     Utilisation du clavier, de la souris ou du Joystick...
}
interface

var
   c : char;
   nul : boolean;

procedure deplacement_joueur (var x, y : word);
procedure traiter_touches;

implementation
uses
    crt,
    cop_io,
    cop_var,
    u_code_clavier,
    u_temporisation,
    u_joystick,
    u_mouse;

var
   sens : byte;
   ox, oy : word;
   mx, my : integer;

procedure deplacement_joueur (var x, y : word);
begin
  ox := x;
  oy := y;
  sens := 0;
  case typ_depl of
    joystick : sens := stick (stick_a);
    souris :
      begin
        mouse_x_y (mx, my);
        if (mx > x)
        then
          if (my > y)
          then
            sens := 3
          else
            if (my < y)
            then
              sens := 1
            else
              sens := 2
            {endif}
          {endif}
        else
          if (mx < x)
          then
            if (my > y)
            then
              sens := 5
            else
              if (my < y)
              then
                sens := 7
              else
                sens := 6
              {endif}
            {endif}
          else
            if (my > y)
            then
              sens := 4
            else
              if (my < y)
              then
                sens := 8
              else
                sens := 0;
              {endif}
            {endif}
          {endif}
        {endif}
      end;
    clavier :
      case nul of
        true :
          case c of
            touche_droite : sens := 2;
            touche_bas : sens := 4;
            touche_gauche : sens := 6;
            touche_haut : sens := 8;
          end;
        false :
          case c of
            '5' : sens := 0;
            '9' : sens := 1;
            '6' : sens := 2;
            '3' : sens := 3;
            '2' : sens := 4;
            '1' : sens := 5;
            '4' : sens := 6;
            '7' : sens := 7;
            '8' : sens := 8;
          end;
      end;
  end;
  case sens of
    1 :
      begin
        inc (x);
        dec (y);
      end;
    2 : inc (x);
    3 :
      begin
        inc (x);
        inc (y);
      end;
    4 : inc (y);
    5 :
      begin
        dec (x);
        inc (y);
      end;
    6 : dec (x);
    7 :
      begin
        dec (x);
        dec (y);
      end;
    8 : dec (y);
  end;
  if (x > 320-16)
  then
    x := ox;
  {endif}
  if (y > 200-16)
  then
    y := oy;
  {endif}
end; { deplacement_joueur }

procedure traiter_touches;
begin
  if (keypressed)
  then
    c := upcase (readkey)
  else
    c := #127;
  {endif}
  if (c = carac_nul)
  then
    begin
      nul := true;
      c := readkey;
    end
  else
    nul := false;
  {endif}
  case nul of
    true :
      case c of
        touche_f2 :
          if (etat_prog = ecr_jeu)
          then
            sauvegarde_jeu;
          {endif}
        touche_f3 :
          charge_jeu;
        touche_page_up :
          begin
            if (speed < 6)
            then
              inc (speed);
            {endif}
            temporisation_vitesse (speed-3);
          end;
        touche_page_dn :
          begin
            if (speed > 0)
            then
              dec (speed);
            {endif}
            temporisation_vitesse (speed-3);
          end;
      end;
    false :
      case c of
        'P' :
          if (etat_prog = ecr_jeu)
          then
            repeat
            until (upcase (readkey) = 'P');
          {endif}
      end;
  end;
end; { traiter_touches }

end.
