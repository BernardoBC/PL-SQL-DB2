--PERMISOS de sistema
--PERMISOS de Objecto PRIVILEDGES
--TABLESPACES
--QUOTEAS
--OBJETOS

--------------------------------
--PERMISOS DE SISTEMA

--desde system
select *
from dba_sys_privs
where grantee like 'DBA_%';

--desde cada usuario dba
select *
from user_sys_privs;

-----------------------------
--PERMISOS DE OBJETOS

--desde system
select * 
from dba_tab_privs;

--en cada dba
select *
from user_tab_privs;

---------------------------
--TABLESPACE

--desde system
select username, default_tablespace, temporary_tablespace
from dba_users
where username like 'DBA_%';

--desde dba
select username, default_tablespace, temporary_tablespace
from user_users

--------------------------
--QUOTAS

--desde system
select *
from dba_ts_quotas
where username like 'DBA_%';

--desde usuario
select *
from user_ts_quotas;

--------------------------
--Objetos

--desde system
--Para ver objetos desde system es dba_objects y desde cada usuario es user_ts_quotas
select oowner, object_name, object_type
from dba_objects
where owner like 'DBA_%';

--desde cada dba
select object_name, object_type
from user_objects;