unit cop_parametre;
{
Auteur: Patrick Pr‚martin
Date: 13/12/1992. 31/12/1992.
Langage: Turbo Pascal 6.0
But: Gestion des paramˆtres ‚ventuellement pass‚s … COPTER.
}
interface

procedure init_parametre;

implementation
uses
    olf_software,
    crt,
    cop_var,
    cop_io,
    u_msg,
    u_parametre;

procedure init_parametre;
var
   c : char;
   n, n2, n3 : integer;
   ch : string;
begin
  writeln;
  num_data := 0;
  num_level := 1;
  if ((param_del ('/?')) or (param_del ('/H')))
  then
    begin
      writeln (get_msg (6));
      writeln;
      writeln (get_msg (7));
      writeln (get_msg (8));
      writeln (get_msg (9));
      writeln (get_msg (10));
      writeln (get_msg (11));
      writeln;
      writeln (get_msg (16));
      while keypressed do
        c := readkey;
      {endwhile}
      repeat
      until keypressed;
      while keypressed do
        c := readkey;
      {endwhile}
      clrscr;
    end;
  {endif}
  if param_del ('/M')
  then
    typ_depl := souris
  else
    if param_del ('/J')
    then
      typ_depl := joystick
    else
      typ_depl := clavier;
    {endif}
  {endif}
  n := 1;
  while (n <= param_nb) do
    begin
      if ((copy (param_ch (n), 1, 1) = 'F') and (num_util <> 0))
      then
        begin
          ch := copy (param_ch (n), 2, 2);
          if (ch [0] = #0)
          then
            num_data := 0
          else
            begin
              {$r-}
              val (ch, num_data, n2);
              {$r+}
              if (n2 <> 0)
              then
                num_data := 0;
              {endif}
            end;
          {endif}
        end;
      {endif}
      if (copy (param_ch (n), 1, 1) = 'L')
      then
        begin
          {$r-}
          val (copy (param_ch (n), 2, 1), n3, n2);
          {$r+}
          if (n2 = 0)
          then
            load_game (n3);
          {endif}
        end;
      {endif}
      inc (n);
    end;
  {endwhile}
  writeln (get_msg (15), ' ', num_data);
  writeln (get_msg (17), ' ', num_level);
  case typ_depl of
    clavier : writeln (get_msg (12));
    souris : writeln (get_msg (13));
    joystick : writeln (get_msg (14));
  end;
  delay (2000);
end; { init_parametre }
    
end.
