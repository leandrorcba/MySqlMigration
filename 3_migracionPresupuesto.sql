select * from presupuesto order by idPresupuesto desc;

ALTER TABLE presupuesto
MODIFY COLUMN precioCobrado DECIMAL(10,2) DEFAULT NULL,
MODIFY COLUMN precioMinuto DECIMAL(10,2) DEFAULT NULL,
MODIFY COLUMN senia DECIMAL(10,2) DEFAULT NULL;

ALTER TABLE presupuesto
ADD COLUMN aprobado_1 BOOLEAN DEFAULT FALSE,
ADD COLUMN realizado_1 BOOLEAN DEFAULT FALSE,
ADD COLUMN cobrado_1 BOOLEAN DEFAULT FALSE,
ADD COLUMN entregado_1 BOOLEAN DEFAULT FALSE;

UPDATE presupuesto
SET aprobado_1 = CASE
WHEN UPPER(TRIM(aprobado)) = 'SI' THEN 1
ELSE 0
END where idPresupuesto >= 1;

UPDATE presupuesto
SET realizado_1 = CASE
WHEN UPPER(TRIM(realizado)) = 'SI' THEN 1
ELSE 0
END where idPresupuesto >= 1;

UPDATE presupuesto
SET cobrado_1 = CASE
WHEN UPPER(TRIM(cobrado)) = 'SI' THEN 1
ELSE 0
END where idPresupuesto >= 1;

UPDATE presupuesto
SET entregado_1 = CASE
WHEN UPPER(TRIM(entregado)) = 'SI' THEN 1
ELSE 0
END where idPresupuesto >= 1;

ALTER TABLE presupuesto
DROP COLUMN aprobado,
DROP COLUMN realizado,
DROP COLUMN cobrado,
DROP COLUMN entregado;

ALTER TABLE presupuesto
CHANGE COLUMN aprobado_1 aprobado BOOLEAN,
CHANGE COLUMN realizado_1 realizado BOOLEAN,
CHANGE COLUMN cobrado_1 cobrado BOOLEAN,
CHANGE COLUMN entregado_1 entregado BOOLEAN;

ALTER TABLE presupuesto
ADD COLUMN fecha_hora_presupuesto DATETIME DEFAULT CURRENT_TIMESTAMP;

UPDATE presupuesto
SET fecha_hora_presupuesto = STR_TO_DATE(CONCAT(fechaPresupuesto, ' ', horaPresupuesto), '%d/%m/%Y %H:%i:%s') where idPresupuesto >= 1;

ALTER TABLE presupuesto
DROP COLUMN fechaPresupuesto,
DROP COLUMN horaPresupuesto;

CREATE TABLE senia (
idSenia INT AUTO_INCREMENT PRIMARY KEY,
montoSenia DECIMAL(10,2) NOT NULL,
fechaHoraSenia DATETIME DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE presupuesto
ADD COLUMN fechaSeniaDatetime DATETIME;

UPDATE presupuesto
SET fechaSeniaDatetime = STR_TO_DATE(fechaSenia, '%d/%m/%Y')
WHERE fechaSenia IS NOT NULL AND fechaSenia != '' and idPresupuesto >= 1;

ALTER TABLE presupuesto
DROP COLUMN fechaSenia;

ALTER TABLE presupuesto
CHANGE COLUMN fechaSeniaDatetime fechaSenia DATETIME;

ALTER TABLE presupuesto
ADD COLUMN idSenia INT;

ALTER TABLE presupuesto
ADD CONSTRAINT fk_presupuesto_senia
FOREIGN KEY (idSenia) REFERENCES senia(idSenia);

CALL migrar_senias();

ALTER TABLE presupuesto
DROP COLUMN senia,
DROP COLUMN fechaSenia,
DROP COLUMN puntosDisponibleCanje,
DROP COLUMN puntosDisponibles,
DROP COLUMN puntosCanjeados,
DROP COLUMN maquina;

ALTER TABLE presupuesto
DROP COLUMN puntosAcumuladosPdf;

ALTER TABLE presupuesto
ADD COLUMN fechaCobradoDatetime DATETIME;

UPDATE presupuesto
SET fechaCobradoDatetime = STR_TO_DATE(fechaCobrado, '%d/%m/%Y %H:%i:%s')
WHERE fechaCobrado IS NOT NULL AND fechaCobrado != '' and idPresupuesto >= 1;

ALTER TABLE presupuesto
DROP COLUMN fechaCobrado;

ALTER TABLE presupuesto
CHANGE COLUMN fechaCobradoDatetime fechaSenia DATETIME;

ALTER TABLE presupuesto
ADD COLUMN fechaRealizadoDatetime DATETIME;

UPDATE presupuesto
SET fechaRealizadoDatetime = STR_TO_DATE(fechaRealizado, '%d/%m/%Y %H:%i:%s')
WHERE fechaRealizado IS NOT NULL AND fechaRealizado != '' and idPresupuesto >= 1;

ALTER TABLE presupuesto
DROP COLUMN fechaRealizado;

ALTER TABLE presupuesto
CHANGE COLUMN fechaRealizadoDatetime fechaRealizado DATETIME;   

ALTER TABLE trabajopresupuestado
RENAME TO trabajo_presupuestado ;

ALTER TABLE senia 
CHANGE COLUMN idSenia id_senia INT NOT NULL AUTO_INCREMENT ,
CHANGE COLUMN montoSenia monto_senia DECIMAL(10,2) NOT NULL ,
CHANGE COLUMN fechaHoraSenia fecha_hora_senia DATETIME NULL DEFAULT CURRENT_TIMESTAMP ;


ALTER TABLE presupuesto 
DROP FOREIGN KEY fk_presupuesto_senia;

ALTER TABLE presupuesto 
ADD COLUMN fecha_aprobado DATETIME NULL AFTER fechaRealizado,
ADD COLUMN fecha_cobrado DATETIME NULL AFTER fecha_aprobado,
ADD COLUMN fecha_entregado DATETIME NULL AFTER fecha_cobrado;

ALTER TABLE presupuesto 
CHANGE COLUMN idPresupuesto id_presupuesto INT NOT NULL AUTO_INCREMENT ,
CHANGE COLUMN idCliente id_cliente INT NOT NULL ,
CHANGE COLUMN precioCobrado precio_cobrado DECIMAL(10,2) NULL DEFAULT NULL ,
CHANGE COLUMN precioSinCanje precio_sin_canje DOUBLE NOT NULL ,
CHANGE COLUMN precioMinuto precio_minuto DECIMAL(10,2) NULL DEFAULT NULL ,
CHANGE COLUMN idSenia id_senia INT NULL DEFAULT NULL ,
CHANGE COLUMN fechaSenia fecha_senia DATETIME NULL DEFAULT NULL ,
CHANGE COLUMN fechaRealizado fecha_realizado DATETIME NULL DEFAULT NULL ;

ALTER TABLE presupuesto 
ADD CONSTRAINT fk_presupuesto_senia
  FOREIGN KEY (id_senia)
  REFERENCES senia (id_senia);
  
ALTER TABLE senia
  ADD COLUMN id_usuario INT NULL AFTER fecha_hora_senia,
  ADD INDEX idx_senia_id_usuario (id_usuario);


