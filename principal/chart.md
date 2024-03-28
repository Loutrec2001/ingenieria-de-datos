erDiagram
      
"dbo.Cargo" {
    varchar(5) Id_Cargo "PK"
          varchar(100) Cargo ""
          decimal Salario ""
          
}
"dbo.Departamentos" {
    varchar(5) Id_Departamento "PK"
          varchar(80) Departamento ""
          
}
"dbo.Empleados" {
    varchar(80) Nombre ""
          varchar(50) Fecha_Nacimiento ""
          varchar(80) Direccion ""
          varchar(80) Correo ""
          varchar(100) Cargo ""
          varchar(5) Id_Departamento "FK"
          varchar(5) Id_Cargo "FK"
          
}
      "dbo.Empleados" |o--|{ "dbo.Departamentos": "Id_Departamento"
"dbo.Empleados" |o--|{ "dbo.Cargo": "Id_Cargo"
