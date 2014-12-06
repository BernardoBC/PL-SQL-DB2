create or replace
PROCEDURE INSTRANSACCIONHABITACION (total in number)
 as
cursor cRegistros is SELECT *
  FROM dba_Contratos.RegistroEntrada;
cursor cCedula is SELECT *
  FROM dba_Contratos.Huespedes;
cursor cHoteles is SELECT idHotel
  FROM dba_Hoteles.Hoteles;
cursor cContratoDeHabitacion is SELECT *
  FROM dba_Hoteles.Hoteles;
bandera BOOLEAN;
numeroDeHabitacionesExistentes number;
numeroDeHabitacionesOcupadas number;
fechaEntradaHab date;
fechaSalidaHab date;
maxContrato number;
maxContratoDeHabitacion number;
contratoEncontrado number;
HabitacionesDisponibles number;
HabitacionesALlenar number;
HabitacionesAPonerEnBitacora number;
fechaEntradaEnContrato date;
fechaSalidaEnContrato date;

rcRegistro cRegistros%rowtype;
rcHoteles cHoteles%rowtype;
rcCedula cCedula%rowtype;
begin
  
  FOR rcRegistro in cRegistros LOOP
    bandera := false;

    FOR rcCedula in cCedula LOOP
      IF rcRegistro.cedula = rcCedula.cedula THEN
        bandera := true;

      END IF;      
    END LOOP;

    IF bandera THEN
      bandera := false;

      FOR rcHoteles in cHoteles LOOP
        IF rcRegistro.idHotel = rcHoteles.idHotel THEN
          bandera := true;
        END IF;      
      END LOOP;
      IF bandera THEN     
        bandera := false;

        --Verificar si hay habitaciones
        --aqui esta lo bueno
        

        numeroDeHabitacionesOcupadas := 0;

        select count(*) into numeroDeHabitacionesExistentes
          from dba_Hoteles.Habitaciones
          where hoteles_idhotel = rcRegistro.idHotel;

        for curl in (select * from dba_Contratos.ContratoDeHabitacion where Habitaciones_Hoteles_idHotel = rcRegistro.idHotel) LOOP
          select entrada into fechaEntradaHab
            from dba_Contratos.Contratos
            where curl.Contratos_numeroContrato = numeroContrato;
          select salida into fechaSalidaHab
            from dba_Contratos.Contratos
            where curl.Contratos_numeroContrato = numeroContrato;
          IF fechaEntradaHab < rcRegistro.fechaSalida AND fechaSalidaHab > rcRegistro.fechaEntrada THEN
            numeroDeHabitacionesOcupadas := numeroDeHabitacionesOcupadas + 1;
          END IF;
        end loop;

        HabitacionesDisponibles := numeroDeHabitacionesExistentes - numeroDeHabitacionesOcupadas;

        --Hay habitaciones disponibles
        IF HabitacionesDisponibles > 0 THEN
          
          SELECT nvl(max(numeroContrato),0) INTO maxContrato
            FROM dba_Contratos.Contratos;
          maxContrato := maxContrato + 1;
          INSERT INTO dba_Contratos.Contratos values(
            maxContrato,
            trunc(sysdate),
            rcRegistro.cedula,
            'Pago'||dbms_random.string('U',3),  
            rcRegistro.fechaEntrada,
            rcRegistro.fechaSalida);                           
          commit;  
                    
                    --Hay suficientes habitaciones disponibles
          IF rcRegistro.cantidadHabitaciones <= HabitacionesDisponibles THEN
          
            for i in 1..rcRegistro.cantidadHabitaciones loop 
              bandera := false;              
              for curs in (select * from dba_Hoteles.Habitaciones where hoteles_idhotel = rcRegistro.idHotel) LOOP
                IF not bandera THEN
                  select nvl(count(*),0) into contratoEncontrado
                    from dba_Contratos.ContratoDeHabitacion where Habitaciones_numero = curs.numero and Habitaciones_Hoteles_idHotel = rcRegistro.idHotel;
                  IF contratoEncontrado > 0 THEN

                    for rHabitacion in (select *
                      from dba_Contratos.ContratoDeHabitacion
                      where Habitaciones_numero = curs.numero
                      and Habitaciones_Hoteles_idHotel = rcRegistro.idHotel) loop

                      select entrada into fechaEntradaEnContrato
                        from dba_Contratos.Contratos where numeroContrato = rHabitacion.Contratos_numeroContrato;    
                      select salida into fechaSalidaEnContrato
                        from dba_Contratos.Contratos where numeroContrato = rHabitacion.Contratos_numeroContrato;                
                      IF not (fechaEntradaEnContrato < rcRegistro.fechaSalida AND fechaSalidaEnContrato > rcRegistro.fechaEntrada) THEN

                        INSERT INTO dba_Contratos.ContratoDeHabitacion values(
                          maxContrato,
                          rHabitacion.Habitaciones_numero,
                          rcRegistro.idHotel);
                        commit;  
                        bandera := true; 
                        EXIT;                 
                      END IF;

                    END LOOP;
                  ELSE

                    INSERT INTO dba_Contratos.ContratoDeHabitacion values(
                      maxContrato,
                      curs.numero,
                      rcRegistro.idHotel);
                    commit;  
                    bandera := true;                                  
                  END IF;
                END IF;  
              end loop;


            end loop;

          --No hay suficientes habitaciones disponibles
          ELSE
            HabitacionesALlenar := rcRegistro.cantidadHabitaciones - HabitacionesDisponibles;
            for i in 1..HabitacionesALlenar loop 
              bandera := false;
              for curs in (select * from dba_Hoteles.Habitaciones where hoteles_idhotel = rcRegistro.idHotel) LOOP
                IF not bandera THEN
                  select nvl(count(*),0) into contratoEncontrado
                    from dba_Contratos.ContratoDeHabitacion where Habitaciones_numero = curs.numero and Habitaciones_Hoteles_idHotel = rcRegistro.idHotel;
                  IF contratoEncontrado > 0 THEN

                    for rHabitacion in (select *
                      from dba_Contratos.ContratoDeHabitacion
                      where Habitaciones_numero = curs.numero
                      and Habitaciones_Hoteles_idHotel = rcRegistro.idHotel) loop

                      select entrada into fechaEntradaEnContrato
                        from dba_Contratos.Contratos where numeroContrato = rHabitacion.Contratos_numeroContrato;    
                      select salida into fechaSalidaEnContrato
                        from dba_Contratos.Contratos where numeroContrato = rHabitacion.Contratos_numeroContrato;                
                      IF not (fechaEntradaEnContrato < rcRegistro.fechaSalida AND fechaSalidaEnContrato > rcRegistro.fechaEntrada) THEN
                        

                        INSERT INTO dba_Contratos.ContratoDeHabitacion values(
                          maxContrato,
                          rHabitacion.Habitaciones_numero,
                          rcRegistro.idHotel);
                        commit;
                        EXIT;
                      END IF;
                    END LOOP;
                  ELSE

                    INSERT INTO dba_Contratos.ContratoDeHabitacion values(
                      maxContrato,
                      curs.numero,
                      rcRegistro.idHotel);
                    commit;
                  END IF;
                END IF;
              end loop;
            end loop;


            HabitacionesAPonerEnBitacora := rcRegistro.cantidadHabitaciones - HabitacionesALlenar;
            INSERT INTO dba_Contratos.Bitacora values(
              rcRegistro.cedula,
              rcRegistro.idHotel,
              rcRegistro.fechaEntrada,  
              rcRegistro.fechaSalida,
              rcRegistro.cantidadHabitaciones,
              HabitacionesALlenar,
              0);                           
            commit;

          END IF;
         
        --no hay habitaciones disponibles         
        ELSE
          INSERT INTO dba_Contratos.Bitacora values(
            rcRegistro.cedula,
            rcRegistro.idHotel,
            rcRegistro.fechaEntrada,  
            rcRegistro.fechaSalida,
            rcRegistro.cantidadHabitaciones,
            rcRegistro.cantidadHabitaciones,
            0);                           
          commit;
        END IF;      
        
      ELSE  
        INSERT INTO dba_Contratos.Bitacora values(
          rcRegistro.cedula,
          rcRegistro.idHotel,
          rcRegistro.fechaEntrada,  
          rcRegistro.fechaSalida,
          rcRegistro.cantidadHabitaciones,
          rcRegistro.cantidadHabitaciones,
          2);                           
        commit; 
      END IF;

    ELSE
      INSERT INTO dba_Contratos.Bitacora values(
        rcRegistro.cedula,
        rcRegistro.idHotel,
        rcRegistro.fechaEntrada,  
        rcRegistro.fechaSalida,
        rcRegistro.cantidadHabitaciones,
        rcRegistro.cantidadHabitaciones,
        1);                           
      commit;      
     
    END IF;     
  END LOOP;
end;