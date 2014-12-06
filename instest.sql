create or replace
PROCEDURE INSTEST (total in number)
 as

cursor cRegistros is SELECT *
  FROM dba_Contratos.RegistroEntrada;
cursor cCedula is SELECT *
  FROM dba_Contratos.Huespedes;
bandera boolean;
begin

  FOR rcRegistros in cRegistros LOOP
    bandera := false;
    dbms_output.put_line ('main for initiated'); 
    FOR rcCedula in cCedula LOOP
      IF rcRegistro.cedula = rcCedula.cedula THEN
        bandera := true;
        dbms_output.put_line ('cedula found'); 
      END IF;      
    END LOOP;
  END LOOP;
end;