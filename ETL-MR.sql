--Comenzamos creando las tablas en el Database para luego 
-- copiar los datos en las tablas con Data Factory
DROP TABLE Empleados;
CREATE TABLE Empleados(
    Nombre VARCHAR(80),
    Fecha_Nacimiento VARCHAR(50),
    Direccion VARCHAR(80),
    Correo VARCHAR(80),
    Departamento VARCHAR(50),
    Cargo VARCHAR(100)
);

CREATE TABLE Cargo (
    Id_Cargo VARCHAR(5) PRIMARY KEY,
    Cargo VARCHAR(100)
);

CREATE TABLE Departamentos(
    Id_Departamento VARCHAR(5) PRIMARY KEY,
    Departamento VARCHAR(80)
);

-- Agregamos las columnas para cambiar cargo y departamento por su
--correspondiente ID. utilizaremos una longitud distinta para mostrar 
-- el proceso de cambio del tipo de dato mas adelante

ALTER TABLE Empleados
ADD Id_Departamento VARCHAR(80) DEFAULT 'Sin Cargo';

ALTER TABLE Empleados
ADD Id_Cargo VARCHAR(80) DEFAULT 'Sin Cargo';



-- Para generar una base relacional SQL realizaremos
-- varios ajustes en las bases creadas en Databricks y exportadas por medio de 
-- DataFactory

-- Primero diligenciamos las celdas de Id_Cargo y Id_Departamento teniendo en cuenta
-- las tablas departamento y cargo para realizar el JOIN
UPDATE [dbo].[Empleados]
SET [dbo].[Empleados].[Id_Cargo] = [dbo].[Cargo].[Id_Cargo]
FROM [dbo].[Empleados]
JOIN [dbo].[Cargo]
ON [dbo].[Empleados].[Cargo] = [dbo].[Cargo].[Cargo];


-- Ya que se observa que el DEP02 no fue copiado lo ahcemos manualmente
UPDATE [dbo].[Empleados]
SET [dbo].[Empleados].[Id_Departamento] = 'DEP02'
WHERE [dbo].[Empleados].[Departamento] = 'Desarrollo de Software';


-- Ahora con la relación de Cargo
UPDATE [dbo].[Empleados]
SET [dbo].[Empleados].[Id_DCargo] = [dbo].[Departamentos].[Id_Departamento]
FROM [dbo].[Empleados]
JOIN [dbo].[Departamentos]
ON [dbo].[Empleados].[Departamento] = [dbo].[Departamentos].[Departamento];


-- Segundo se borran las columnas Departamento y Cargo ya que tenemos 
-- el correspondiente ID
ALTER TABLE [dbo].[Empleados]
DROP COLUMN [Departamento];

ALTER TABLE [dbo].[Empleados]
DROP COLUMN [Departamento];

-- Ahora creamos las foreing key para relacionar las tres tablas
-- pero primero verificamos que las columnas en cuestion tengan la misma longitud

-- En este caso no tienen la misma longitud así que creamos una columna
-- con la logitud adecuada y luego pasamos los valores originales
ALTER TABLE Empleados
ADD Nueva_Id_Departamento VARCHAR(5);
UPDATE Empleados
SET Nueva_Id_Departamento = Id_Departamento;

-- Ahora podemos eliminar la columna original
ALTER TABLE Empleados
DROP COLUMN Id_Departamento;
-- Ya que no se deja eliminar por que tiene una restricción entonces
-- buscamos en nombre de la restricción y la eliminamos para poder borrar la columna
SELECT name
FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('Empleados')
  AND parent_column_id = (
      SELECT column_id
      FROM sys.columns
      WHERE name = 'Id_Departamento'
        AND object_id = OBJECT_ID('Empleados')
  );

ALTER TABLE Empleados
DROP CONSTRAINT DF__Empleados__Id_De__6754599E;

-- Ahora que se eliminó, borramos la columna y
-- cambiamos el nombre de la nueva columna para que coincida con el original
EXEC sp_rename 'Empleados.Nueva_Id_Departamento', 'Id_Departamento', 'COLUMN';

-- Ahora agregamos la clave foranea
ALTER TABLE [dbo].[Empleados]  
ADD CONSTRAINT fk_empleados_departamento
FOREIGN KEY (Id_Departamento) REFERENCES [dbo].[Departamentos](Id_Departamento);

-- Ahora hacemos lo mismo para la columna Id_Cargo
ALTER TABLE Empleados
ADD Nueva_Id_cargo VARCHAR(5);

UPDATE Empleados
SET Nueva_Id_Cargo = Id_Cargo;

ALTER TABLE Empleados
DROP COLUMN Id_Cargo;

SELECT name
FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('Empleados')
  AND parent_column_id = (
      SELECT column_id
      FROM sys.columns
      WHERE name = 'Id_Cargo'
        AND object_id = OBJECT_ID('Empleados')
  );

ALTER TABLE Empleados
DROP CONSTRAINT DF__Empleados__Id_Ca__68487DD7;
EXEC sp_rename 'Empleados.Nueva_Id_Cargo', 'Id_Cargo', 'COLUMN';
ALTER TABLE [dbo].[Empleados]  
ADD CONSTRAINT fk_empleados_cargo
FOREIGN KEY (Id_Cargo) REFERENCES [dbo].[Cargo](Id_Cargo);

-- Ya con este proceso queda formada la base de datos relacional



-- Por último vamos a agregarle los salarios a cada uno de los cargos para realizar unas mejores consultas


ALTER TABLE dbo.Cargo
ADD Salario DECIMAL(18, 2);  

UPDATE dbo.Cargo
SET Salario = 
    CASE 
        WHEN Cargo = 'Administrador de Base de Datos' THEN 8000000
        WHEN Cargo = 'Analista BI' THEN 7000000
        WHEN Cargo = 'Analista de Datos' THEN 6500000
        WHEN Cargo = 'Analista de Negocios' THEN 7500000
        WHEN Cargo = 'Científico de Datos' THEN 8500000
        WHEN Cargo = 'Desarrollador de Software' THEN 7500000
        WHEN Cargo = 'Diseñador UX/UI' THEN 7000000
        WHEN Cargo = 'Especialista en Redes' THEN 7500000
        WHEN Cargo = 'Especialista en Seguridad Informática' THEN 8000000
        WHEN Cargo = 'Gerente de Proyecto' THEN 9000000
        WHEN Cargo = 'Gerente de TI' THEN 9500000
        WHEN Cargo = 'Ingeniero de Datos' THEN 7500000
        WHEN Cargo = 'Ingeniero de Software' THEN 7500000
        WHEN Cargo = 'Ingeniero de Telecomunicaciones' THEN 8000000
        WHEN Cargo = 'Técnico de Soporte' THEN 6000000
        WHEN Cargo = 'TI Recruiter' THEN 5500000
        WHEN Cargo =  'Analista de Sistemas' THEN 5800000
        WHEN Cargo =  'Coordinador de Recursos Humanos' THEN 6500000
        ELSE 0
    END;



