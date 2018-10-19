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
	declare @sigla char(7)
	select @sigla = d.SiglaCurso from deleted d-- join Lleva l on d.SiglaCurso = l.SiglaCurso
	declare @nG int
	select @nG = d.NumGrupo from deleted d --join Lleva l on d.NumGrupo = l.NumGrupo
	declare @sem int
	select @sem = d.Semestre from deleted d --join Lleva l on d.Semestre = l.Semestre
	declare @anno int
	select @anno = d.Año from deleted d --join Lleva l on d.Año = l.Año
	delete from Grupo
	--delete from Lleva
go

drop trigger CierraGrupo

select * from Lleva
select * from Grupo

delete from Grupo 
where(SiglaCurso, NumGrupo, Semestre, Año)  
		(Select l.SiglaCurso, l.NumGrupo, l.Semestre, l.Año
		  from Lleva l
		  where l.Nota is null);