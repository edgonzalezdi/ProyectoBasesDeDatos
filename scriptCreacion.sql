CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Cliente` (
  `cli_NIT` INT NOT NULL COMMENT 'NIt es el identificador único que tiene cada empresa en Colombia',
  `cli_razonSocial` VARCHAR(70) NOT NULL COMMENT 'La razón social es el nombre comercial de una empresa',
  `cli_telefono` VARCHAR(20) NOT NULL COMMENT 'Representa un único teléfono de contacto para la empresa (Mismos entes de la empresa sugieren el guardado de solamente un teléfono de contacto)',
  `cli_sede` VARCHAR(20) NULL COMMENT 'Representa la sede de la empresa que ha solicitado la realización de algún proyecto',
  `cli_certificadoCamaraComercio` VARCHAR(255) NULL COMMENT 'Certificado de cada empresa disponible en https://linea.ccb.org.co/CertificadosElectronicosR/Index.html',
  `cli_nombreContacto` VARCHAR(45) NOT NULL COMMENT 'Nombre persona intermediaria de una empresa. Por ejemplo puede ser una secretaria o un empleado específico en una empresa',
  `cli_apellidoContacto` VARCHAR(45) NOT NULL COMMENT 'Representa el apellido del contacto de la empresa. Mismas directivas del negocio destino de la base de dato manifiestan la necesidad de guardar sólo un contacto de la empresa',
  `cli_emailContacto` VARCHAR(45) NOT NULL COMMENT 'Representa el email de contacto. La presencia de sólo un contacto por empresa se explica en la columna \"cli_apellidoContacto\"',
  PRIMARY KEY (`cli_NIT`))
ENGINE = InnoDB
COMMENT = 'Representa la entidad Fuerte \'Cliente\', señala siempre a una empresa (por ésta razón su identificador es el NIT de dicha empresa)';


-- -----------------------------------------------------
-- Table `mydb`.`Proyecto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Proyecto` (
  `pro_idProyecto` INT NOT NULL COMMENT 'Representa la llave primaria de la entidad proyecto de tipo numérico',
  `pro_cantidadEnsayos` INT NULL COMMENT 'Cantidad total de ensayos a realizar',
  `pro_valorTotal` INT NOT NULL COMMENT 'Precio total del proyecto',
  `pro_IVA` INT NOT NULL DEFAULT 19 COMMENT 'representa un iva específico a cobrar dentro del proyecto: (19%) con la posibilidad de ser distinto',
  `pro_nombreProyecto` VARCHAR(80) NOT NULL COMMENT 'Representa el nombre dado por el cliente para asignar a un proyecto que éste planea realizar o para el cuál busca estudiar alguna muestra',
  `pro_FechaInicioProyecto` DATE NOT NULL COMMENT 'Representa la fecha en la que se inicia un proyecto (Fecha en la que se crea el registro)',
  `pro_FechaFinalizacionProyecto` DATE NOT NULL COMMENT 'Representa la fecha en la que se da fin a un proyecto. Puede ser cuando se entrega el informe, cuando se completa el pago u otra fecha.',
  `cli_NIT` INT NOT NULL COMMENT 'Representa la llave foránea que relaciona cada proyecto con un único cliente',
  PRIMARY KEY (`pro_idProyecto`),
  INDEX `fk_Proyecto_Cliente1_idx` (`cli_NIT` ASC) VISIBLE,
  CONSTRAINT `fk_Proyecto_Cliente1`
    FOREIGN KEY (`cli_NIT`)
    REFERENCES `mydb`.`Cliente` (`cli_NIT`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Representa la entidad Proyecto, la cual es generada cada vez que un servicio es prestado a un cliente';


-- -----------------------------------------------------
-- Table `mydb`.`Perforacion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Perforacion` (
  `per_idPerforacion` INT NOT NULL COMMENT 'Representa un identificador unico para cada perforación realizada',
  `per_nombrePerforacion` VARCHAR(45) NOT NULL COMMENT 'Define un nombre para la perforación realizada (no se usa como identificador dado que no es único para cada perforación)',
  `per_localizacion` ENUM('TUBO', 'BOLSA', 'BLOQUE') NOT NULL COMMENT 'Se refiere a la localización general de la perforación',
  `per_latitud` DECIMAL(8,6) NOT NULL COMMENT 'Define las coordenadas en latitud de la perforación',
  `per_longitud` DECIMAL(9,6) NOT NULL COMMENT 'Representa la longitud donde se encuentra la perforación',
  `pro_idProyecto` INT NOT NULL COMMENT 'Representa la llave foránea para la relación 1 a varios con la entidad proyecto',
  PRIMARY KEY (`per_idPerforacion`),
  INDEX `fk_Perforacion_Proyecto1_idx` (`pro_idProyecto` ASC) VISIBLE,
  CONSTRAINT `fk_Perforacion_Proyecto1`
    FOREIGN KEY (`pro_idProyecto`)
    REFERENCES `mydb`.`Proyecto` (`pro_idProyecto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Representa la entidad Muestra, proveida por el cliente dentro de un proyecto';


-- -----------------------------------------------------
-- Table `mydb`.`Muestra`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Muestra` (
  `mue_idMuestra` INT NOT NULL COMMENT 'Representa un identificador único para cada muestra (llave primaria)',
  `mue_numeroMuestra` INT NOT NULL COMMENT 'Define el nombre de la muestra entregada para un proyecto (obligatorio)',
  `mue_condicionEmpaque` ENUM('TUBO', 'BOLSA', 'BLOQUE') NOT NULL COMMENT 'EL empaque puede ser tubo, bolsa o apique',
  `mue_tipoMuestra` ENUM('ALTERADA', 'INALTERADA') NOT NULL COMMENT 'El tipo de muestra puede ser alterada o inalterada',
  `mue_ubicacionBodega` VARCHAR(45) NOT NULL COMMENT 'Representa una cadena describiendo la ubicación de la muestra en bodega',
  `mue_tipoExploracion` ENUM('SONDEO', 'APIQUE') NOT NULL COMMENT 'El tipo de exploración puede ser sondeo o apique',
  `mue_descripcionMuestra` VARCHAR(45) NOT NULL COMMENT 'Descripción física de la muestra. Incluye datos como el lugar donde fue extraída, la profundidad y una breve descripción del color y su tipo de suelo.',
  `per_idPerforacion` INT NOT NULL COMMENT 'Representa la llave foránea de la relación 1 a varios con la entidad Perforación',
  `mue_profundidad` DECIMAL(3,2) NOT NULL COMMENT 'Representa la profundidad a la que fue tomada la muestra',
  PRIMARY KEY (`mue_idMuestra`),
  INDEX `fk_Muestra_Perforacion1_idx` (`per_idPerforacion` ASC) VISIBLE,
  CONSTRAINT `fk_Muestra_Perforacion1`
    FOREIGN KEY (`per_idPerforacion`)
    REFERENCES `mydb`.`Perforacion` (`per_idPerforacion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Representa la entidad Muestra, proveida por el cliente dentro de un proyecto';


-- -----------------------------------------------------
-- Table `mydb`.`estadoPago`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`estadoPago` (
  `pro_idProyecto` INT NOT NULL COMMENT 'Representa una llave foránea converitda en primaria que identifica una relación 1-1 entre la presente relación y un proyecto.',
  `esp_valorAbonado` INT NOT NULL COMMENT 'Representa un valor abonado por el cliente en el momento de iniciar un proyecto. Puede ser 0 para indicar que el cliente no abonó ningún valor. Según sea el caso',
  `esp_fechaAbono` DATETIME NULL COMMENT 'Representa la fecha en la que se entregó un abono para la realización de un proyecto. Puede ser vacía si no se ha pagado ningún abono',
  `esp_fechaPagoTotal` DATETIME NULL COMMENT 'Representa la fecha en la que se ha pagado la totalidad del proyecto, puede ser nula si aún no ha sido pagado ',
  PRIMARY KEY (`pro_idProyecto`),
  CONSTRAINT `fk_estadoPago_Proyecto1`
    FOREIGN KEY (`pro_idProyecto`)
    REFERENCES `mydb`.`Proyecto` (`pro_idProyecto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Representa la entidad \'Estado de pago de un proyecto\'; ésta entidad específicamente representa la existencia de un anticipo por parte de el cliente ante la propuesta de un proyecto';


-- -----------------------------------------------------
-- Table `mydb`.`Empleado`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Empleado` (
  `emp_idEmpleado` INT NOT NULL COMMENT 'Representa la identificación del empleado (Puede ser tomada su identificación como cédula de ciudadanía)',
  `emp_nombreEmpleado` VARCHAR(60) NOT NULL COMMENT 'Representa el nombre completo del empleado',
  `emp_oficioEmpleado` VARCHAR(20) NOT NULL COMMENT 'Representa el oficio desempeñado por el empleado dentro de la entidad. (Puede ser una descripción general de su papel)',
  `emp_apellidoEmpleado` VARCHAR(60) NOT NULL COMMENT 'Representa el (los) apellido (s) del empleado',
  PRIMARY KEY (`emp_idEmpleado`))
ENGINE = InnoDB
COMMENT = 'Representa la entidad fuerte Empleado, participante en el estudio de las muestras';


-- -----------------------------------------------------
-- Table `mydb`.`TipoEnsayo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`TipoEnsayo` (
  `tip_idTipoEnsayo` INT NOT NULL AUTO_INCREMENT COMMENT 'Representa la identificación única de cada tipo de Ensayo. ',
  `tip_nombreTipoEnsayo` VARCHAR(45) NOT NULL COMMENT 'Representa el nombre de ensayo proveniente de un conjunto de datos ya especificado dentro de la entidad',
  PRIMARY KEY (`tip_idTipoEnsayo`))
ENGINE = InnoDB
COMMENT = 'Representa la entidad Ensayo, ésta entidad puede ser definida como una constante con alteraciones poco frecuentes';


-- -----------------------------------------------------
-- Table `mydb`.`EnsayoMuestra`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`EnsayoMuestra` (
  `ens_idEnsayoMuestra` INT NOT NULL AUTO_INCREMENT COMMENT 'Representa una llave primaria autogenerada que identifica a cada registro único de la relación EnsayoMuestra',
  `ens_fechaEnsayoMuestra` DATETIME NOT NULL COMMENT 'Representa la fecha en la que se realizó el ensayo',
  `ens_hayResiduo` TINYINT NOT NULL COMMENT 'Un ensayo puede generar un residuo o no.',
  `ens_condicionesParticularesEstudio` VARCHAR(400) NULL COMMENT 'Condiciones específicas establecidas por el cliente para un ensayo. Puede ser cambiar un parámetro como la presión o la humedad de un ensayo.',
  `emp_idEmpleado` INT NOT NULL COMMENT 'Representa una llave foránea proveniente la relación Empleado. Representa la identificación de la persona que realizó el ensayo',
  `mue_idMuestra` INT NOT NULL COMMENT 'Representa la identificación de la muestra estudiada dentro de un ensayo.',
  `tip_idTipoEnsayo` INT NOT NULL COMMENT 'Representa una llave foránea relativa al id (identificador único dentro de dicha tabla) del tipo de ensayo realizado.',
  `ens_estado` ENUM('PENDIENTE', 'EN CURSO', 'REALIZADO') NOT NULL DEFAULT 'PENDIENTE' COMMENT 'La columna estado representa si el ensayo ya fue realizado, esta en curso o no ha sido iniciado',
  PRIMARY KEY (`ens_idEnsayoMuestra`),
  INDEX `fk_estudioMuestra_Empleado1_idx` (`emp_idEmpleado` ASC) VISIBLE,
  INDEX `fk_estudioMuestra_Muestra1_idx` (`mue_idMuestra` ASC) VISIBLE,
  INDEX `fk_EnsayoMuestra_TipoEnsayo1_idx` (`tip_idTipoEnsayo` ASC) VISIBLE,
  CONSTRAINT `fk_estudioMuestra_Empleado1`
    FOREIGN KEY (`emp_idEmpleado`)
    REFERENCES `mydb`.`Empleado` (`emp_idEmpleado`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_estudioMuestra_Muestra1`
    FOREIGN KEY (`mue_idMuestra`)
    REFERENCES `mydb`.`Muestra` (`mue_idMuestra`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_EnsayoMuestra_TipoEnsayo1`
    FOREIGN KEY (`tip_idTipoEnsayo`)
    REFERENCES `mydb`.`TipoEnsayo` (`tip_idTipoEnsayo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Esta relación representa cada ensayo de laboratorio individual que se realice.';


-- -----------------------------------------------------
-- Table `mydb`.`informeFinal`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`informeFinal` (
  `inf_fechaRemisionInforme` DATETIME NOT NULL COMMENT 'Representa la fecha en la cual un informe ha sido remitido',
  `inf_observacionesInforme` VARCHAR(1000) NULL COMMENT 'Representa observaciones opcionales dadas a un informe al momento de ser creado / entregado',
  `pro_idProyecto` INT NOT NULL COMMENT 'Representa una llave foránea converitda en primaria en una relación 1-1 con la tabla proyecto',
  PRIMARY KEY (`pro_idProyecto`),
  CONSTRAINT `fk_informeFinal_Proyecto1`
    FOREIGN KEY (`pro_idProyecto`)
    REFERENCES `mydb`.`Proyecto` (`pro_idProyecto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Define la entidad débil \'Informe Final\', la cual representa un resumen de los resultados a entregar dentro de un proyecto';


-- -----------------------------------------------------
-- Table `mydb`.`ArchivoResultado`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`ArchivoResultado` (
  `ens_idEnsayoMuestra` INT NOT NULL COMMENT 'Representa una llave foránea convertida en primaria en una relación 1-1 con la tabla EnsayoMuestra. ',
  `ens_rutaArchivo` VARCHAR(1000) NOT NULL COMMENT 'Representa una cadena que contiene la ruta (Path) de un archivo de excel generado por la empresa esquematizando detalladamente el resultado de la aplicación de un ensayo a una muestra',
  `pro_idProyecto` INT NOT NULL COMMENT 'Representa una llave foránea que relaciona los archivos con un único informe al que pertenece (Nótese que a través de ésta llave puede ser encontrado directamente el proyecto y el estado de pago relativo al archivo en cuestión)',
  INDEX `fk_ArchivoResultado_EnsayoMuestra1_idx` (`ens_idEnsayoMuestra` ASC) VISIBLE,
  INDEX `fk_ArchivoResultado_informeFinal1_idx` (`pro_idProyecto` ASC) VISIBLE,
  PRIMARY KEY (`ens_idEnsayoMuestra`),
  CONSTRAINT `fk_ArchivoResultado_EnsayoMuestra1`
    FOREIGN KEY (`ens_idEnsayoMuestra`)
    REFERENCES `mydb`.`EnsayoMuestra` (`ens_idEnsayoMuestra`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ArchivoResultado_informeFinal1`
    FOREIGN KEY (`pro_idProyecto`)
    REFERENCES `mydb`.`informeFinal` (`pro_idProyecto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Define la entidad débil \'Resultado Muestra\' la cual representa el resultado alcanzado dentro de un ensayo a una determinada muestra';

