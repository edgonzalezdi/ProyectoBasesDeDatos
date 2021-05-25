﻿use mydb;
SET GLOBAL local_infile = 'ON';
SHOW VARIABLES LIKE "secure_file_priv";

-- Nombres de proyecto para un cliente con nombre
SELECT pro_nombreProyecto AS NombreProyecto 
FROM Proyecto JOIN 
(SELECT cli_NIT FROM Cliente WHERE cli_razonSocial="Idiger")
AS clien 
USING (cli_NIT);

-- Lista de ensayos que faltan por realizar en un proyecto dado por su ID
SELECT per_nombrePerforacion, mue_numeroMuestra, mue_profundidad, tip_nombreTipoEnsayo FROM Proyecto
NATURAL JOIN Perforacion NATURAL JOIN Muestra NATURAL JOIN EnsayoMuestra NATURAL JOIN TipoEnsayo
WHERE Proyecto.pro_idProyecto = 4 AND ens_estado = 1;  -- ens_estado = 1 -> pendiente

-- Lista de ensayos que ya se realizaron, junto con su ejecutor y fecha
SELECT per_nombrePerforacion, mue_numeroMuestra, mue_profundidad, tip_nombreTipoEnsayo, emp_nombreEmpleado, ens_fechaEnsayoMuestra FROM Proyecto
NATURAL JOIN Perforacion NATURAL JOIN Muestra NATURAL JOIN EnsayoMuestra NATURAL JOIN TipoEnsayo NATURAL JOIN Empleado
WHERE Proyecto.pro_idProyecto = 4 AND ens_estado = 3;  -- ens_estado = 3 -> realizado

-- Abono y saldo por pagar para un proyecto dado su ID proyecto
SELECT cli_razonSocial, pro_nombreProyecto, esp_valorAbonado, esp_fechaAbono, (pro_valorTotal - esp_valorAbonado) AS saldoPorPagar
FROM Cliente NATURAL JOIN Proyecto NATURAL JOIN estadoPago WHERE pro_idProyecto = 3;

-- Nombres de tipo de ensayo para un proyecto con ID
SELECT DISTINCT tip_nombreTipoEnsayo AS TipoEnsayo
FROM TipoEnsayo
NATURAL JOIN EnsayoMuestra 
NATURAL JOIN Muestra
NATURAL JOIN (
	SELECT per_idPerforacion FROM Perforacion
    WHERE pro_idProyecto=5
) AS perforacion;

-- -- Nombres de tipo de ensayo para una muestra con ID
SELECT DISTINCT tip_nombreTipoEnsayo AS TipoEnsayo
FROM TipoEnsayo
NATURAL JOIN (
	SELECT tip_idTipoEnsayo FROM EnsayoMuestra
    WHERE mue_idMuestra=5
) AS tipoensayo;

-- Nombres de tipo de ensayo para una muestra y ejecutores con ID de muestra
SELECT DISTINCT tip_nombreTipoEnsayo AS TipoEnsayo,emp_nombreEmpleado AS Nombre,emp_apellidoEmpleado AS Apellido
FROM (TipoEnsayo
NATURAL JOIN (
	SELECT tip_idTipoEnsayo,emp_idEmpleado FROM EnsayoMuestra
    WHERE mue_idMuestra=5
) AS t1)
NATURAL JOIN Empleado;

-- Nombres de proyectos cuyos informes aun no entregados (Cuyos proyectos no han sido pagados)
SELECT pro_nombreProyecto AS Nombre
FROM Proyecto
NATURAL JOIN (
	SELECT pro_idProyecto FROM informeFinal
    WHERE inf_fechaRemisionInforme = NULL
)AS t2;

-- Quién hace un ensayo, estado de los ensayos, ruta del archivo (si fue ejecutado)
SELECT emp_nombreEmpleado AS Nombre,emp_apellidoEmpleado AS Apellido,ens_estado AS Estado, archivoresultado.ens_rutaArchivo AS Ruta
FROM EnsayoMuestra
NATURAL JOIN Empleado 
NATURAL JOIN ArchivoResultado;

-- Valor promedio $$$ contratado con un conjunto de clientes
SELECT cli_razonSocial ,AVG(pro_valorTotal) AS valorPromedioContratado 
FROM Proyecto NATURAL JOIN Cliente 
WHERE cli_razonSocial IN ('Idiger','CI Ambiental S.A.S','DACH & ASOCIADOS S.A.S');

-- Seleccionar los tipos de ensayo y la cantidad de ensayos muestra
-- que se han realizado sobre ellos, para aquellos con minimo tres ensayos a muestras

SELECT tip_nombreTipoEnsayo, COUNT(ens_idEnsayoMuestra) FROM TipoEnsayo
NATURAL JOIN EnsayoMuestra
GROUP BY tip_idTipoEnsayo
HAVING COUNT(ens_idEnsayoMuestra)>=3;

-- Seleccionar los clientes para los cuales se han hecho mas de 3 ensayos distintos

SELECT cli_razonSocial, COUNT(DISTINCT tip_idTipoEnsayo) FROM Cliente
NATURAL JOIN Proyecto
NATURAL JOIN Perforacion
NATURAL JOIN Muestra
NATURAL JOIN EnsayoMuestra
GROUP BY cli_NIT
HAVING COUNT(DISTINCT tip_idTipoEnsayo)>=3;


-- Obtener por localizaciones la cantidad de perforaciones hechas para un proyecto
SELECT per_localizacion AS Localizacion, COUNT(per_idPerforacion) AS Cantidad
FROM Perforacion
NATURAL JOIN (
	SELECT pro_idProyecto FROM Proyecto
    WHERE pro_nombreProyecto='OS No. CG-280'
) AS t3
GROUP BY per_localizacion;


-- Actualizar los archivos resultado para una muestra
UPDATE ArchivoResultado SET ens_rutaArchivo="C:\Downloads\Resultado20" 
WHERE ArchivoResultado.ens_idEnsayoMuestra IN (
	SELECT ens_idEnsayoMuestra FROM EnsayoMuestra
    WHERE mue_idMuestra=5
);


-- Actualizar el nombre de un cliente dado su NIT
UPDATE Cliente SET cli_razonSocial = 'Idiger'
WHERE cli_NIT = 8001542751;

-- Actualizar el valor total de un proyecto dado su ID
UPDATE Proyecto SET pro_valorTotal = ValorEnteroDado
WHERE pro_idProyecto = id_dado;

-- Actualizar el valor abonado en un proyecto dado su ID
UPDATE estadoPago SET esp_valorAbonado = ValorAbonadoNuevo
WHERE pro_idProyecto = id_dado;

-- Actualizar la ubicación en bodega de una muestra dado su ID de muestra
UPDATE Muestra SET mue_ubicacionBodega = "Nueva Ubicación"
WHERE mue_idMuestra = id_muestra_dado;

-- Actualizar el estado de realización de un EnsayoMuestra dado ens_idEnsayoMuestra
UPDATE EnsayoMuestra SET ens_estado = nuevoEstado
WHERE ens_idEnsayoMuestra = id_ensayo_dado;

-- Actualizar las observaciones de un informe final dado un id_proyecto
UPDATE informeFinal SET inf_observacionesInforme = "nuevas observaciones"
WHERE pro_idProyecto = id_proyecto_dado;



--  Reemplazar un tipo de ensayo por otro en un conjunto de perforaciones
UPDATE EnsayoMuestra SET tip_idTipoEnsayo=10
WHERE tip_idTipoEnsayo=5 AND 
mue_idMuestra IN (
	SELECT muestra.mue_idMuestra FROM Muestra
    WHERE per_idPerforacion IN (1,5,6)
);

-- Cambiar el estado de un ensayo a muestra (conociendo id de ensayo muestra)
UPDATE EnsayoMuestra SET ens_estado=3
WHERE ens_idEnsayoMuestra=5;


-- Remover un proyecto (con sus perforaciones, muestras, ensayos a muestras,
-- archivos resultado e informe final)
-- Nos dan la ID de proyecto
CREATE VIEW vw_perforaciones 
AS SELECT DISTINCT per_idPerforacion FROM Perforacion 
WHERE pro_idProyecto=5;

CREATE VIEW vw_muestras
AS SELECT DISTINCT mue_idMuestra FROM Muestra
NATURAL JOIN vw_perforaciones;

CREATE VIEW vw_ensayosmuestra
AS SELECT DISTINCT ens_idEnsayoMuestra FROM EnsayoMuestra
NATURAL JOIN vw_muestras;

DELETE FROM ArchivoResultado
WHERE ens_idEnsayoMuestra IN (
	SELECT * FROM vw_ensayosmuestra
    );


DELETE FROM informeFinal 
WHERE pro_idProyecto=5; -- Borando el informe del proyecto

DELETE FROM estadoPago
WHERE pro_idProyecto=5; -- Borrando el estado de pago

DELETE FROM EnsayoMuestra 
WHERE ens_idEnsayoMuestra IN (
	SELECT * FROM 
    vw_ensayosmuestra
);

DELETE FROM Muestra
WHERE mue_idMuestra IN (SELECT * FROM 
vw_muestras);

DELETE FROM Perforacion
WHERE per_idPerforacion IN (SELECT * FROM 
vw_perforaciones);

DELETE FROM Proyecto
WHERE pro_idProyecto=5;

DROP VIEW vw_muestras;
DROP VIEW vw_perforaciones;
DROP VIEW vw_ensayosmuestra;

-- Remover los clientes cuya sumatoria de pago de proyectos sea menor a
-- un millón
CREATE VIEW vw_clientes AS 
SELECT Cliente.cli_NIT FROM Cliente
    JOIN Proyecto USING(cli_NIT)
    GROUP BY Cliente.cli_NIT
    HAVING SUM(Proyecto.pro_valorTotal)<1000000;

CREATE VIEW vw_proyectos 
AS SELECT  DISTINCT pro_idProyecto FROM Proyecto
NATURAL JOIN vw_clientes;

CREATE VIEW vw_perforaciones
AS SELECT  DISTINCT per_idPerforacion FROM Perforacion
NATURAL JOIN vw_proyectos;

CREATE VIEW vw_muestras
AS SELECT  DISTINCT mue_idMuestra FROM Muestra
NATURAL JOIN vw_perforaciones;

CREATE VIEW vw_ensayosmuestra
AS SELECT  DISTINCT ens_idEnsayoMuestra FROM EnsayoMuestra
NATURAL JOIN vw_muestras;

DELETE FROM ArchivoResultado
WHERE ens_idEnsayoMuestra IN (SELECT * FROM vw_ensayosmuestra);

DELETE FROM informeFinal
WHERE pro_idproyecto IN (SELECT * FROM vw_proyectos);

DELETE FROM estadoPago
WHERE pro_idproyecto IN (SELECT * FROM vw_proyectos);

DELETE FROM EnsayoMuestra
WHERE ens_idEnsayoMuestra IN ( 
SELECT ens_idEnsayoMuestra FROM vw_ensayosmuestra
);

DELETE FROM Muestra
WHERE mue_idMuestra IN(SELECT * FROM vw_muestras);

DELETE FROM perforacion
WHERE per_idPerforacion IN(SELECT * FROM vw_perforaciones);

DELETE FROM Proyecto
WHERE pro_idProyecto IN (SELECT * FROM vw_proyectos);

DELETE FROM Cliente
WHERE cli_NIT IN (SELECT * FROM vw_clientes);

DROP VIEW vw_ensayosmuestra;
DROP VIEW vw_muestras;
DROP VIEW vw_perforaciones;
DROP VIEW vw_proyectos;
DROP VIEW vw_clientes;
-- Delete Edgar
-- Update Jose Luis

-- Borrar una muestra de un proyecto
CREATE VIEW vw_ensayosmuestra
as select distinct ens_idEnsayoMuestra FROM
EnsayoMuestra WHERE mue_idMuestra=10;

DELETE FROM ArchivoResultado 
WHERE ens_idEnsayoMuestra IN (
	SELECT * FROM vw_ensayosmuestra
);
DELETE FROM EnsayoMuestra
WHERE ens_idEnsayoMuestra IN (
	SELECT * FROM vw_ensayosmuestra
);
DELETE FROM Muestra WHERE mue_idMuestra=10;
DROP VIEW vw_ensayosmuestra;	