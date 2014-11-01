--PERMISOS de sistema
--PERMISOS de Objecto PRIVILEDGES
--TABLESPACES
--QUOTEAS
--OBJETOS

--------------------------------
--PERMISOS DE SISTEMA

--desde system
SELECT *
FROM dba_sys_privs
WHERE grantee LIKE 'DBA_%';

SELECT *
FROM dba_sys_privs
WHERE grantee LIKE 'DESARROLLADOR';

--desde cada usuario dba
SELECT *
FROM user_sys_privs;

-----------------------------
--PERMISOS DE OBJETOS

--desde system
SELECT * 
FROM dba_tab_privs
WHERE grantee LIKE 'DBA_%';

SELECT * 
FROM dba_tab_privs
WHERE grantee LIKE 'DESARROLLADOR';

--en cada dba
SELECT *
FROM user_tab_privs;

---------------------------
--TABLESPACE

--desde system
SELECT username, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username LIKE 'DBA_%';

SELECT username, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username LIKE 'DESARROLLADOR';

--desde dba
SELECT username, default_tablespace, temporary_tablespace
FROM user_users

--------------------------
--QUOTAS

--desde system
SELECT *
FROM dba_ts_quotas
WHERE username LIKE 'DBA_%';

SELECT *
FROM dba_ts_quotas
WHERE username LIKE 'DESARROLLADOR';

--desde usuario
SELECT *
FROM user_ts_quotas;

--------------------------
--Objetos

--desde system
--Para ver objetos desde system es dba_objects y desde cada usuario es user_ts_quotas
SELECT owner, object_name, object_type
FROM dba_objects
WHERE owner LIKE 'DBA_%';

SELECT owner, object_name, object_type
FROM dba_objects
WHERE owner LIKE 'DESARROLLADOR';

--desde cada dba
SELECT object_name, object_type
FROM user_objects;