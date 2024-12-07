program Copter;
{
Auteur: Patrick Pr‚martin
Date: (1.0) 29/11/1992. 06/12/1992. 13/12/1992. 31/12/1992. 01/01/1993.
Langage: Turbo Pascal 6.0
But: Jeu d'arcade: pilotez un h‚licoptŠre et ramassez les champignons en
     ‚vitant les piŠges divers.
}
{$m 32768, 0, 655350}
uses
    crt,
    olf_software,
    olf_vga,
    u_msg,
    cop_affiche,
    cop_jeu,
    cop_code_acces,
    cop_parametre,
    cop_var;

const
     num_ver = '1.0';
     dat_ver = '01/01/1993';

var
   presentation : t_data;

procedure copter_init;
var
  f : file;
  ch : string;
  n : byte;
begin
  assign (f, 'COPTER.PRS');
  {$i-}
  reset (f, 1);
  {$i+}
  if (ioresult <> 0)
  then
    begin
      writeln ('Error loading COPTER.PRS...');
      halt (1);
    end;
  {endif}
  blockread (f, ch [0], 1);
  if (ch [0] > #0)
  then
    blockread (f, ch [1], length (ch));
  {endif}
  blockread (f, n, sizeof (num_data));
  blockread (f, presentation, sizeof (data_disk));
  close (f);
  num_data := 0;
  init_parametre;
end; { copter_init }

procedure copter_pres;
var
   i, j : byte;
begin
  etat_prog := ecr_pres;
  etat_prog := ecr_jeu;
  fin_prog := false;
      load_data_disk (num_data);
      i := num_level;
      j := i;
      while not fin_prog do
        begin
          num_level := j;
          etat_prog := ecr_jeu;
          if (j < 5)
          then
            begin
              level := presentation [j];
              case j of
                1 : etat_prog := ecr_pres;
                2 : etat_prog := ecr_score;
                3 : etat_prog := ecr_nou_score;
                4 : etat_prog := ecr_pass;
              end;
            end
          else
            level := data_disk [j];
          {endif}
          afficher_tab;
          run;
          if (j < 16)
          then
            inc (j)
          else
            j := 1;
          {endif}
        end;
      {endwhile}
end; { copter_pres }

begin
  writeln ('COPTER '+num_ver);
  writeln ('(c) Patrick Pr‚martin '+dat_ver);
  writeln;
  init_licence ('GAMECPTR');
  shareware_careware;
  copter_init;
  olf_software_vga_pres;
  mode_vga;
  copter_pres;
  mode_texte;
  textattr := $07;
  writeln ('COPTER '+num_ver);
  writeln ('(c) Patrick Pr‚martin '+dat_ver);
  writeln;
  writeln (get_msg (1));
end.
