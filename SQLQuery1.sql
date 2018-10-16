-- en sql server no existe el trigger "before", el "instead of" puede simular un before.

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
	delete from Asistente
	select @ced = Cedula from deleted
	@ced = Cedula
	where Cedula = @ced
	delete from Estudiante
	where Cedula = @ced
go

select * from Asistente

insert into Estudiante
values('1132254','gec@gmail.com','geovanny','cordero', 'valverde', 'M', '1996-02-17', 'perez zeledon', '82165431', 'B40034', 'Activo');

insert into Asistente
values('1132254', 8);

delete from Estudiante
where Cedula = '1132254'