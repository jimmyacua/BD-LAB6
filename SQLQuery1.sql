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

--4:

go
create trigger CierraGrupo
on Grupo instead of delete
as
	declare @sigla char(7), @nG int, @sem int, @anno int
	select @sigla = d.SiglaCurso, @nG = d.NumGrupo, @sem = d.Semestre, @anno = d.Año 
	from deleted d join Lleva l on @sigla = l.SiglaCurso and @nG = l.NumGrupo and @sem = l.Semestre and @anno = l.Año
	where l.Nota is null
	
	delete from Lleva 
	where SiglaCurso= @sigla and NumGrupo = @nG and Semestre = @sem and Año = @anno
	
	delete from Grupo
	where SiglaCurso= @sigla and NumGrupo = @nG and Semestre = @sem and Año = @anno
	
	
	/*
	delete from Lleva
	where SiglaCurso in(
	select d.SiglaCurso
	from deleted d)
	and
	NumGrupo in(
	select d.NumGrupo
	from deleted d )
	and 
	Semestre in(
	select d.Semestre
	from deleted d)
	and 
	Año in(
	select d.Año
	from deleted d )

	delete from Grupo 
	where SiglaCurso in
		(Select l.SiglaCurso		
		  from Lleva l
		  where l.Nota is null)
	and
	NumGrupo in
		(select l.NumGrupo
		from Lleva l
		where l.Nota is null)
	and
	Semestre in
		(select l.Semestre
		from Lleva l
		where l.Nota is null
		)
	and 
	Año in(select l.Año
		from Lleva l
		where l.Nota is null)*/
go

drop trigger CierraGrupo

select * from Lleva
--Solo un estudiante matriculado con nota null

delete from Grupo 
where SiglaCurso = 'ci1312'

select * from Lleva
select * from Grupo

--4.i) Se ejecuta el trigger correctamente, pero no tiene ningún efecto pues no encuentra una nota nula en la tabla Lleva

--4.ii) 



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
select * from Grupo

delete from Grupo 
where SiglaCurso = 'ci1312'

--Se borran todas las tuplas que tienen nota null

--5: