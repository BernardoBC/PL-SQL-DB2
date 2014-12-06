--ROLES
create role rolePrincipal;

select * 
from dba_roles;

grant creates session to rolePrincipal;

--ver permisos asignados al role
select *
from dba_sys_privs
where grantee = 'rolePrincipal';

--asignar un role al usuario
GRANT ufinal to rperez; 