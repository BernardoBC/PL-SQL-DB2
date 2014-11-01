--system
create user dba_Hoteles identified by dba_Hoteles
	default tablespace users
	temporary tablespace temp
	quota unlimited on users;

create user dba_Servicios identified by dba_Servicios
	default tablespace users
	temporary tablespace temp
	quota unlimited on users;

create user dba_Contratos identified by dba_Contratos
	default tablespace users
	temporary tablespace temp
	quota unlimited on users;

--permisos
grant create session, create table to dba_Hoteles;
grant create session, create table to dba_Servicios;
grant create session, create table to dba_Contratos;

--desde dba_Hoteles

CREATE TABLE Ciudades(
  idCiudad number(8) constraint pk_idCiudad primary key,
  nombreCiudad varchar2(45),
  Paises_idPais number(8),
  infoTuristica varchar2(60));

CREATE TABLE CadenasHoteleras(
  idCadena number(8),
  nombreCadena varchar2(45),
  propietario varchar2(45),
  fechaInauguracion date,
  paginaWeb varchar2(45),
  Ciudades_idCiudad number(8) REFERENCES Ciudades,
  constraint pk_idCadena primary key (idCadena));

CREATE TABLE Hoteles (
  idHotel number(8) constraint pk_idHotel primary key,
  nombre varchar2(45), 
  categoria number(4),
  tipo varchar2(45),
  CadenasHoteleras_idCadenas number(8) REFERENCES CadenasHoteleras,
  Ciudades_idCiudad number(8) REFERENCES Ciudades);

CREATE TABLE Habitaciones (
  numero number(4),
  Hoteles_idHotel number(8) REFERENCES Hoteles,
  tipoHab varchar2(45),
  capacidad number(4),
  precio number(8),
  descripcionServicios varchar2(45),
  constraint pk_numero PRIMARY KEY (numero, Hoteles_idHotel));

CREATE TABLE PaqueteEnHotel (
  idPaquetes number(4) REFERENCES dba_Servicios.Paquetes,
  Hoteles_idHotel number(8) REFERENCES Hoteles,
  precio number(4),
  constraint pk_idPaquetesEnHotel PRIMARY KEY (idPaquetes, Hoteles_idHotel));

--desde dba_Servicios
CREATE TABLE Servicios (
  idServicio number(4) constraint pk_idServicio primary key,
  definicion varchar2(45),
  nivelAtraccion number(4));

CREATE TABLE ServiciosEnPaquetes (
  Servicios_idServicio number(4),
  Paquetes_idPaquetes number(4),
  constraint pk_idServiciosEnPaquetes PRIMARY KEY (Servicios_idServicio, Paquetes_idPaquetes),
  FOREIGN KEY (Paquetes_idPaquetes) REFERENCES Paquetes(idPaquetes),
  FOREIGN KEY (Servicios_idServicio) REFERENCES Servicios(idServicio));

CREATE TABLE Paquetes (
  idPaquetes number(4) constraint pk_idPaquetes primary key,
  nombre varchar2(45),
  descripcion varchar2(45));

--desde dba_Contratos

CREATE TABLE Contratos (
  numeroContrato number(4) constraint pk_numeroContrato primary key,
  fechaFirma date,
  Huesped_cedula number(4) REFERENCES Huespedes,
  formaPago varchar2(45),
  entrada date,
  salida date);

CREATE TABLE Huespedes (
  cedula number(8) constraint pk_cedula primary key,
  nombre varchar2(45),
  sexo varchar2(45),
  edad number(4),
  telefono number(8),
  Paises_nacionalidad varchar2(45));

CREATE TABLE PaquetesComprados (
  numeroContrato number(4),
  idPaquetes number(4),
  Hoteles_idHotel number(8),
  constraint pk_paquetesComprados PRIMARY KEY (numeroContrato, idPaquetes, Hoteles_idHotel),
  FOREIGN KEY (numeroContrato) REFERENCES Contratos(numeroContrato),
  FOREIGN KEY (idPaquetes, Hoteles_idHotel) REFERENCES dba_Hoteles.PaqueteEnHotel(idPaquetes, Hoteles_idHotel));

CREATE TABLE ContratoDeHabitacion (
  Contratos_numeroContrato number(4),
  Habitaciones_numero number(4),
  Habitaciones_Hoteles_idHotel number(8),
  constraint pk_ContratoDeHabitacion PRIMARY KEY (Contratos_numeroContrato, Habitaciones_numero, Habitaciones_Hoteles_idHotel),
  FOREIGN KEY (Habitaciones_numero, Habitaciones_Hoteles_idHotel) REFERENCES dba_Hoteles.Habitaciones(numero,Hoteles_idHotel),
  FOREIGN KEY (Contratos_numeroContrato) REFERENCES Contratos(numeroContrato));

--permisos
--desde dba_Hoteles
grant references on Habitaciones to dba_Contratos;
grant references on PaqueteEnHotel to dba_Contratos;

--desde dba_Servicios
grant references on Paquetes to dba_Hoteles;


--desarollador
create user desarrollador identified by desarrollador
temporary tablespace temp;

--permisos desde system
grant create session, create procedure to desarrollador;

--desde dba_Hoteles dar permiso
grant insert on Ciudades to desarrollador;
grant insert on CadenasHoteleras to desarrollador;
grant insert on Hoteles to desarrollador;
grant insert on Habitaciones to desarrollador;
grant insert on PaqueteEnHotel to desarrollador;

grant select on Ciudades to desarrollador;
grant select on CadenasHoteleras to desarrollador;
grant select on Hoteles to desarrollador;
grant select on Habitaciones to desarrollador;
grant select on PaqueteEnHotel to desarrollador;

--desde dba_Servicios
grant insert on Servicios to desarrollador;
grant insert on ServiciosEnPaquetes to desarrollador;
grant insert on Paquetes to desarrollador;

grant select on Servicios to desarrollador;
grant select on ServiciosEnPaquetes to desarrollador;
grant select on Paquetes to desarrollador;

--desde dba_Contratos
grant select on Contratos to desarrollador;
grant select on Huespedes to desarrollador;
grant select on PaquetesComprados to desarrollador;
grant select on ContratoDeHabitacion to desarrollador;

grant insert on Contratos to desarrollador;
grant insert on Huespedes to desarrollador;
grant insert on PaquetesComprados to desarrollador;
grant insert on ContratoDeHabitacion to desarrollador;


--En procedimientos, no usar ""




--PaqueteEnHotel

CREATE OR REPLACE PROCEDURE INSPAQUETEENHOTEL (total in number)
 as

cursor cHoteles is select idHotel
	from dba_Hoteles.Hoteles;
cursor cPaquetes is select *
	from (
		select idPaquetes
			from dba_Servicios.Paquetes
			order by dbms_random.value()
    )
	where rownum <= trunc(dbms_random.value(1,total));
cont number;

begin
cont:=0;
  for rcHoteles in cHoteles loop  	
    for rcPaquetes in cPaquetes loop
      insert into dba_Hoteles.PaqueteEnHotel values(
        rcPaquetes.idPaquetes,
        rcHoteles.idHotel,
        trunc(dbms_random.value(5,200)));
      commit;
      cont:= cont+1;
      if cont = total then
      	exit;
      end if;
    end loop;
    if cont = total then
    	exit;
    end if; 
  end loop;
end;

--Habitaciones
CREATE OR REPLACE PROCEDURE INSHABITACIONES (total in number)
 as

cursor cHoteles is select idHotel
  from dba_Hoteles.Hoteles;
ca number;
cont number;
begin
  for rcHoteles in cHoteles loop
    ca:=trunc(dbms_random.value(1,total));
    for j in 1..ca loop
      insert into dba_Hoteles.Habitaciones values(
        j,
        rcHoteles.idHotel,
        'TipoHabitacion '||dbms_random.string('U',4),
        trunc(dbms_random.value(1,8)),
        trunc(dbms_random.value(40,200)),
        'descripServ '||dbms_random.string('U',8));                           
      commit;
      cont:= cont+1;
      if cont = total then
        exit;
      end if;  
    end loop;
  if cont = total then
      exit; 
  end if;    
  end loop;
end;

--Huespedes
CREATE OR REPLACE PROCEDURE INSHUESPEDES (total in number)
as
maxid number;
begin
	select nvl(max(cedula),0) into maxid --nvl(<select>,0) regresa 0 si <select> regresa NULL
    	from dba_Contratos.Huespedes;
	for i in 1..total loop
	    if dbms_random.value(0,1)<=0.5 then
			insert into dba_Contratos.Huespedes values(
				maxid+i,
				'NOMBRE '||dbms_random.string('U',8),
		        'M',
		        trunc(dbms_random.value(21,80)),
		        trunc(dbms_random.value(10000000,99999999)),
		        'PAIS '||dbms_random.string('U',3)); 
	    else
	    	insert into dba_Contratos.Huespedes values(
		        maxid+i,
		        'NOMBRE '||dbms_random.string('U',8),
		        'F',
		        trunc(dbms_random.value(21,80)),
		        trunc(dbms_random.value(10000000,99999999)),
		        'PAIS '||dbms_random.string('U',3)); 
	    end if;   
    	commit;
	end loop;
end;

--ejemplo: execute inshuespedes(1000)


--Servicios

CREATE OR REPLACE PROCEDURE INSSERVICIOS (total in number)
 as
maxid number;
begin
	select nvl(max(idServicio),0) into maxid
		from dba_Servicios.Servicios;
	for i in 1..total loop
		insert into dba_Servicios.Servicios values(
			maxid+i,  
			'Definicion '||dbms_random.string('U',8),
			trunc(dbms_random.values(1,100)));		
		commit;
	end loop;
end;
	
--Paquetes

CREATE OR REPLACE PROCEDURE INSPAQUETES (total in number)
as
maxid number;
begin
	select nvl(max(idPaquetes),0) into maxid
		from dba_Servicios.Paquetes;
	for i in 1..total loop
		insert into dba_Servicios.Paquetes values(
			maxid+i,
			'Nombre '||dbms_random.string('U',6),
			'Descripcion '||dbms_random.string('U',8));
		commit;
	end loop;  
end;


--Servicios en paquetes 
-- @param total= maximo numero de servicios por paquetes
CREATE OR REPLACE PROCEDURE INSSERVICIOSENPAQUETES(total in number)
as
Cursor cPaquetes is select idPaquetes
	from dba_Servicios.Paquetes;
cursor cServicios is select *
		from (
			select idServicio
				from dba_Servicios.Servicios
				order by dbms_random.value()
	    )
		where rownum <= trunc(dbms_random.value(1,total));	
begin
	for rcPaquetes in cPaquetes loop		
		for rcServicios in cServicios  loop
			insert into dba_Servicios.ServiciosEnPaquetes values(
				rcServicios.idServicio,
				rcPaquetes.idPaquetes);
			commit;
		end loop;
	end loop;
end;


-- Insert Ciudades
CREATE OR REPLACE PROCEDURE INSCIUDADES (total in number)
 as
maxid number;
begin
	select nvl(max(idCiudad),0) into maxid
  		from dba_Hoteles.Ciudades;
  for j in 1..total loop
    insert into dba_Hoteles.Ciudades values(
      maxid+j,
      'Ciudad '||dbms_random.string('U',5),
      trunc(dbms_random.value(1,300)),   
      'InfoTur '||dbms_random.string('U',8));                           
    commit; 
  end loop;
end;

--cadenas hoteleras:
--@Param total es la cantidad maxima de cadenas hoteleras por ciudad
create or replace procedure INSCADENASHOTELERAS (total in number)
 as
cursor cCiudades is select  *
	  from dba_Hoteles.Ciudades;
ca number;
maxid number;
begin
	select nvl(max(idCiudad),0) into maxid
	  from dba_Hoteles.Ciudades;
    	
  for rcCiudades in cCiudades loop
    ca:=trunc(dbms_random.value(1,total));
    for j in 1..ca loop
      maxid:=maxid+1;
      insert into dba_Hoteles.CadenasHoteleras values(
        maxid,
        'Cadena Hotelera '||dbms_random.string('U',5),
        'Propietario '||dbms_random.string('U',4),
        null,
        'Pagina '||dbms_random.string('U',5),                          
        rcCiudades.idCiudad);
      commit;
    end loop; 
  end loop;
end;


--Hoteles:
--@param total: cantidad maxima de hoteles por cadena
CREATE OR REPLACE PROCEDURE INSHOTELES (total in number)
 as

cursor cCadenas is select  idCadena
  from dba_Hoteles.CadenasHoteleras;
 cursor cCiudades is select  (idCiudad)
      from (
      select *
        from dba_Hoteles.Ciudades
        order by dbms_random.value()
      )
      where rownum <= trunc(dbms_random.value(1,30)); 
ca number;
maxid number;
cont number;
begin
cont:=0;
select nvl(max(idHotel),0) into maxid
  from dba_Hoteles.Hoteles;
  for rcCadenas in cCadenas loop    
    for rcCiudades in cCiudades loop
      maxid:=maxid+1;
      insert into dba_Hoteles.Hoteles values(
        maxid,
        'Nombre'||dbms_random.string('U',5),
        trunc(dbms_random.value(1,8)),        
        'Tipo '||dbms_random.string('U',8),                           
        rcCadenas.idCadena,
        rcCiudades.idCiudad);
      commit;
      cont:=cont+1;
      if total = cont then
      	exit;
      end if;
    end loop; 
    if total = cont then
      	exit;
      end if;
  end loop;
end;



--creacion
execute inshuespedes(1000);
execute INSCIUDADES(1000);
