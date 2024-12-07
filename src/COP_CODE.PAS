unit cop_code_acces;
{
Auteur: Patrick Pr‚martin
Date: 15/11/1992
Langage: Turbo Pascal 6.0
But: Gestion des codes d'accŠs aux 16 tableaux des 100 data-disks de COPTER.
}

interface
function get_code_acces (num_data_disk, num_tableau : byte) : string;
procedure get_data_tab (code_acces : string; var num_data_disk,
                                                 num_tableau : byte);

implementation
function get_code_acces (num_data_disk, num_tableau : byte) : string;
var
   res : string;
   n : longint;
   i : byte;
begin
  res := '000000';
  i := length (res);
  n := 1619*longint (num_data_disk) + 101*longint (num_tableau);
  while (n > 0) do
    begin
      res [i] := chr (48+ (n mod 8));
      dec (i);
      n := n div 8;
    end;
  {endwhile}
  get_code_acces := res;
end; { get_code_acces }

procedure get_data_tab (code_acces : string; var num_data_disk,
                                                 num_tableau : byte);
var
   n : longint;
begin
  n := 0;
  while (code_acces [0] > #0) do
    begin
      n := n*8+ord (code_acces [1])-48;
      delete (code_acces, 1, 1);
    end;
  {endwhile}
  num_data_disk := n div 1619;
  num_tableau := (n mod 1619) div 101;
end; { get_data_tab }

end.
