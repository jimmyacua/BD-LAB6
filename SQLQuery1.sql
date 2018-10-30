-- en sql server no existe el trigger "before", el "instead of" puede simular un before.
/* declare c cursor for
* select cedula from Deleted 
* open c
* Fetch next from c into @ced
* while @@fetch_status = 0 begin
*	//aquí va la lógica
*	Fetch next from c into @ced
*end 
* close c //IMPORTANTE
* deallocate c //IMPORTANTE
*/

use DB_B50060;



alter table Asistente drop constraint FK__Asistente__Cedul__22401542;

ALTER TABLE Asistente add constraint CedEstudiante 
foreign key(Cedula) references Estudiante(Cedula);

--3:
go
create trigger ElimEstudiante
on Estudiante instead of delete 
as
	declare @ced char(9) 
	select @ced = Cedula from deleted
	delete from Asistente
	where Cedula = @ced
	delete from Estudiante
	where Cedula = @ced
go

select * from Asistente

--agrego un estudiante que no está relacionado con nada
insert into Estudiante
values('1132254','gec@gmail.com','geovanny','cordero', 'valverde', 'M', '1996-02-17', 'perez zeledon', '82165431', 'B40034', 'Activo');
insert into Asistente
values('1132254', 8);

delete from Estudiante
where Cedula = '1132254'
---------------------------------------------------------------------------------------------------------------------------------
--4:

go
create trigger CierraGrupo
on Grupo instead of delete
as
	declare @notNulls int
	select @notNulls = count(*)
	from deleted d join Lleva l on d.SiglaCurso = l.SiglaCurso
	where l.Nota is not null

if @notNulls = 0
begin
	declare @sigla char(7), @nG int, @sem int, @anno int, @notNull int
	select @sigla = d.SiglaCurso, @nG = d.NumGrupo, @sem = d.Semestre, @anno = d.Año 
	from deleted d
		
	delete from Lleva 
	where SiglaCurso = @sigla and NumGrupo = @nG and Semestre = @sem and Año = @anno
	
	delete from Grupo
	where SiglaCurso= @sigla and NumGrupo = @nG and Semestre = @sem and Año = @anno
end
	
go

drop trigger CierraGrupo

select * from Lleva
--Solo un estudiante matriculado con nota null

delete from Grupo 
where SiglaCurso = 'ci1312' 

select * from Lleva
select * from Grupo

EXEC ActualizarNotaEstudiante @ced = '99888777', @sigla = 'ci1312', @numG= 1, 
@sem = 2, @año = 2018, @nuevaNota = null 

delete from Grupo 
where SiglaCurso = 'ci1312'

select * from Lleva
select * from Grupo

--4.i)
	delete from Grupo 
	where SiglaCurso = 'ci1312'
	select * from Grupo
-- Al ejecutarse se eliminar el grupo que no contiene estudiantes matriculados.

--4.ii) 

insert into Grupo values(
'ci1312', 1, 2, 2018, '234567890', 4, '111222333'
);
--se agregan estudiantes con nota null
insert into Lleva values
('111222333','ci1312', 1,2,2018, null)

insert into Lleva values
('176543219','ci1312', 1,2,2018, null)

insert into Lleva values
('876543219','ci1312', 1,2,2018, null)

insert into Lleva values
('99888777','ci1312', 1,2,2018, null)

select * from Lleva
where SiglaCurso = 'ci1312'

delete from Grupo where SiglaCurso = 'ci1312'
select * from Lleva
where SiglaCurso = 'ci1312'

--se eliminan todas las tuplas de la tabla del grupo especificado.

--4.iii)

insert into Grupo values(
'ci1312', 1, 2, 2018, '234567890', 4, '111222333'
);
--se agregan estudiantes con nota null
insert into Lleva values
('111222333','ci1312', 1,2,2018, null)

insert into Lleva values
('176543219','ci1312', 1,2,2018, 13)

insert into Lleva values
('876543219','ci1312', 1,2,2018, null)

insert into Lleva values
('99888777','ci1312', 1,2,2018, 90)


delete from Grupo 
where SiglaCurso = 'ci1312'

select * from Lleva where SiglaCurso = 'ci1312'

--No se elimina el grupo porque se encuentran notas distintas a null
--------------------------------------------------------------------------------------------------------------------------------
--5:
drop trigger CierraVariosGrupos
go
create trigger CierraVariosGrupos
on Grupo instead of delete
as
	declare @sigla char(7), @nG int, @sem int, @anno int, @numNulls int
	declare c cursor for
		select SiglaCurso, NumGrupo, Semestre, Año from deleted
		open c
		fetch next from c into @sigla ,@nG, @sem, @anno 
		while @@FETCH_STATUS = 0 
		begin
			select @numNulls = COUNT(*)
			from deleted d join Lleva l on d.SiglaCurso = l.SiglaCurso and d.NumGrupo = l.NumGrupo and
				d.Semestre = l.Semestre and d.Año  = l.Año
			where @sigla = d.SiglaCurso and @nG = d.NumGrupo and @sem = d.Semestre and @anno = d.Año and l.Nota is not null

			if @numNulls = 0 begin
				/*select @sigla = d.SiglaCurso, @nG = d.NumGrupo, @sem = d.Semestre, @anno = d.Año 
				from deleted d */
				delete from Lleva 
				where SiglaCurso = @sigla and NumGrupo = @nG and Semestre = @sem and Año = @anno
	
				delete from Grupo
				where SiglaCurso= @sigla and NumGrupo = @nG and Semestre = @sem and Año = @anno
			end
			fetch next from c into @sigla ,@nG, @sem, @anno 
		end
	close c
	deallocate c
go


exec ActualizarNotasGrupo @sigla = 'ci1312', @numG = 1, @sem = 2, @año = 2018, @nuevaNota= null
exec ActualizarNotasGrupo @sigla = 'ci1310', @numG = 1, @sem = 2, @año = 2018, @nuevaNota= 67

insert into Grupo values(
'ci1310', 1, 2, 2018, '234567890', 4, '111222333'
);

insert into Lleva values
('99888777','ci1310', 1,2,2018, null)
insert into Lleva values
('111222333','ci1310', 1,2,2018, null)

delete from Grupo
select * from Lleva
order by SiglaCurso
select * from Grupo
--------------------------------------------------------------------------------------------------------------------------------
--6:
go
create trigger RestrInsertar
on Empadronado_En after insert
as
	declare @cedE char(9), @codC varchar(10), @fI date, @fG date, @numC int

	select @cedE = i.CedEstudiante, @codC = i.CodCarrera, @fI = i.FechaIngreso, 
			@fG = i.FechaGraducación
	from inserted i
	group by CedEstudiante, CodCarrera, FechaIngreso, FechaGraducación
	select @numC = count(*)
	from Empadronado_En
	where CedEstudiante = @cedE
	if @numC > 3
		exec DesempadronarEstudiante @ced = @cedE, @cod = @codC

go

--exec DesempadronarEstudiante @ced = '111222333', @cod = '420001'

select * from Carrera

insert into Empadronado_En
values('111222333', '420002', null, null)

select * from Empadronado_En where CedEstudiante = '111222333'

insert into Empadronado_En
values('111222333', '420201', null, null)
select * from Empadronado_En where CedEstudiante = '111222333'


go
create trigger RestrEliminar
on Empadronado_En instead of delete 
as
	declare @cedE char(9), @codC varchar(10), @fI date, @fG date, @numC int
	select @cedE = d.CedEstudiante, @codC = d.CodCarrera, @fI = d.FechaIngreso, 
			@fG = d.FechaGraducación 
	from deleted d
	group by CedEstudiante, CodCarrera, FechaIngreso, FechaGraducación
	select @numC = count(*)
	from Empadronado_En
	where CedEstudiante = @cedE
	if @numC > 1
		delete from Empadronado_En
		where CedEstudiante = @cedE and CodCarrera = @codC
		--exec DesempadronarEstudiante @ced = @cedE, @cod = @codC
go

drop trigger RestrEliminar

delete from Empadronado_En
where CedEstudiante = '111222333' and CodCarrera = '420201'

select * from Empadronado_En where CedEstudiante = '111222333'

--------------------------------------------------------------------------------------------------------------------------------
--7:
drop trigger RestrInsertar
drop trigger RestrEliminar

go
create trigger RestrInsertVarios
on Empadronado_En after insert
as
declare @cedE char(9), @codC varchar(9),  @numC int
declare c cursor for
select CedEstudiante, CodCarrera
from inserted
open c
fetch next from c into @cedE, @codC
while @@fetch_status = 0 begin
	declare @fI date, @fG date
	select @cedE = i.CedEstudiante, @codC = i.CodCarrera, @fI = i.FechaIngreso, 
			@fG = i.FechaGraducación
	from inserted i
	group by CedEstudiante, CodCarrera, FechaIngreso, FechaGraducación
	select @numC = count(*)
	from Empadronado_En
	where CedEstudiante = @cedE
	if @numC > 3
		exec DesempadronarEstudiante @ced = @cedE, @cod = @codC
fetch next from c into @cedE, @codC
end
close c
deallocate c
go

select * from Carrera
insert into Empadronado_En values
('111222333', '420002', null, null),
('111222333', '420705', null, null);

select * from Empadronado_En where CedEstudiante = '111222333'

----
drop trigger RestrElimVarios
go
create trigger RestrElimVarios
on Empadronado_En instead of delete
as
declare @cedE char(9), @codC varchar(9),  @numC int
declare c cursor for
select CedEstudiante, CodCarrera
from deleted
open c
fetch from c into @cedE, @codC
while @@fetch_status = 0 begin
	declare  @fI date, @fG date
	select @cedE = d.CedEstudiante, @codC = d.CodCarrera, @fI = d.FechaIngreso, 
			@fG = d.FechaGraducación 
	from deleted d
	group by CedEstudiante, CodCarrera, FechaIngreso, FechaGraducación
	select @numC = count(*)
	from Empadronado_En
	where CedEstudiante = @cedE
	if @numC > 1 begin
		delete from Empadronado_En
		where CedEstudiante = @cedE and CodCarrera = @codC
	end
fetch next from c into @cedE, @codC
end
close c
deallocate c
go


delete from Empadronado_En
where CedEstudiante = '111222333'

select * from Empadronado_En where CedEstudiante = '111222333'


---------------------------------------------------------------------------------------------------------------------------
--8:
ALTER TABLE Grupo ADD CantidadEstudiantes INT;

select * from Grupo