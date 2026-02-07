START TRANSACTION;

-- 1) Crear tabla SENIA (permite id_tipo_pago NULL durante migración)
/*CREATE TABLE IF NOT EXISTS senia (
  id_senia INT AUTO_INCREMENT PRIMARY KEY,
  id_presupuesto INT NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  fecha_hora DATETIME NOT NULL,
  id_pago INT NULL,
  INDEX idx_senia_presupuesto (id_presupuesto)
) ENGINE=InnoDB;

-- 2) Backfill de señas
INSERT INTO pago (id_presupuesto, monto, fecha_hora, id_tipo_pago, id_tarjeta, id_cuenta_bancaria)
SELECT
    p.idPresupuesto,
    CAST(p.senia AS DECIMAL(10,2)) AS monto,
    COALESCE(
      STR_TO_DATE(p.fechaSenia, '%d/%m/%Y %H:%i:%s'),
      STR_TO_DATE(p.fechaSenia, '%d/%m/%Y'),
      STR_TO_DATE(p.fechaSenia, '%Y-%m-%d %H:%i:%s'),
      STR_TO_DATE(p.fechaSenia, '%Y-%m-%d'),
      NOW()
    ) AS fecha_hora,
    1, NULL, NULL
FROM presupuesto p
WHERE
    (p.senia IS NOT NULL AND p.senia <> 0)
    OR (p.fechaSenia IS NOT NULL AND TRIM(p.fechaSenia) <> '');*/

-- 3) Nueva columna DATETIME combinada para presupuesto
ALTER TABLE presupuesto
  ADD COLUMN fecha_hora_presupuesto DATETIME NULL AFTER idPresupuesto;

UPDATE presupuesto p
SET p.fecha_hora_presupuesto = COALESCE(
    STR_TO_DATE(CONCAT(p.fechaPresupuesto, ' ', p.horaPresupuesto), '%d/%m/%Y %H:%i:%s'),
    STR_TO_DATE(CONCAT(p.fechaPresupuesto, ' ', p.horaPresupuesto), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(p.fechaPresupuesto, '%d/%m/%Y'),
    STR_TO_DATE(p.fechaPresupuesto, '%Y-%m-%d'),
    STR_TO_DATE(p.horaPresupuesto, '%H:%i:%s'),
    NOW()
);

UPDATE presupuesto p
SET p.senia = COALESCE(
    STR_TO_DATE(p.senia, '%d/%m/%Y'),
    STR_TO_DATE(p.senia, '%Y-%m-%d'),
    NOW()
);

-- 4) Migrar fechas cobrado/realizado
ALTER TABLE presupuesto
  ADD COLUMN fecha_cobrado_dt DATETIME NULL AFTER entregado,
  ADD COLUMN fecha_realizado_dt DATETIME NULL AFTER fecha_cobrado_dt;

UPDATE presupuesto p
SET p.fecha_cobrado_dt = COALESCE(
      STR_TO_DATE(p.fechaCobrado, '%d/%m/%Y %H:%i:%s'),
      STR_TO_DATE(p.fechaCobrado, '%d/%m/%Y'),
      STR_TO_DATE(p.fechaCobrado, '%Y-%m-%d %H:%i:%s'),
      STR_TO_DATE(p.fechaCobrado, '%Y-%m-%d'),
      NULL
    ),
    p.fecha_realizado_dt = COALESCE(
      STR_TO_DATE(p.fechaRealizado, '%d/%m/%Y %H:%i:%s'),
      STR_TO_DATE(p.fechaRealizado, '%d/%m/%Y'),
      STR_TO_DATE(p.fechaRealizado, '%Y-%m-%d %H:%i:%s'),
      STR_TO_DATE(p.fechaRealizado, '%Y-%m-%d'),
      NULL
    );

-- 5) Flags yes/no → BOOLEAN
ALTER TABLE presupuesto
  ADD COLUMN aprobado_bool  TINYINT(1) NOT NULL DEFAULT 0 AFTER idCliente,
  ADD COLUMN realizado_bool TINYINT(1) NOT NULL DEFAULT 0 AFTER aprobado_bool,
  ADD COLUMN cobrado_bool   TINYINT(1) NOT NULL DEFAULT 0 AFTER realizado_bool,
  ADD COLUMN entregado_bool TINYINT(1) NOT NULL DEFAULT 0 AFTER cobrado_bool;

UPDATE presupuesto
SET
  aprobado_bool  = CASE WHEN LOWER(TRIM(aprobado))  IN ('si','sí','yes','true','1') THEN 1 ELSE 0 END,
  realizado_bool = CASE WHEN LOWER(TRIM(realizado)) IN ('si','sí','yes','true','1') THEN 1 ELSE 0 END,
  cobrado_bool   = CASE WHEN LOWER(TRIM(cobrado))   IN ('si','sí','yes','true','1') THEN 1 ELSE 0 END,
  entregado_bool = CASE WHEN LOWER(TRIM(entregado)) IN ('si','sí','yes','true','1') THEN 1 ELSE 0 END;

-- 6) Montos double → DECIMAL y creación de descuento
ALTER TABLE presupuesto
  ADD COLUMN precio_cobrado_dec   DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER idCliente,
  ADD COLUMN precio_sin_canje_dec DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER precio_cobrado_dec,
  ADD COLUMN precio_minuto_dec    DECIMAL(10,2) NULL AFTER precio_sin_canje_dec,
  ADD COLUMN descuento            DECIMAL(10,2) NULL AFTER precio_minuto_dec;

UPDATE presupuesto
SET
  precio_cobrado_dec   = CAST(precioCobrado   AS DECIMAL(10,2)),
  precio_sin_canje_dec = CAST(precioSinCanje  AS DECIMAL(10,2)),
  precio_minuto_dec    = CASE WHEN precioMinuto IS NULL THEN NULL ELSE CAST(precioMinuto AS DECIMAL(10,2)) END,
  descuento            = CAST(precioSinCanje AS DECIMAL(10,2)) - CAST(precioCobrado AS DECIMAL(10,2));

-- 7) Eliminar columnas viejas y puntos
ALTER TABLE presupuesto
  -- DROP COLUMN senia,
  -- DROP COLUMN fechaSenia,
  DROP COLUMN fechaPresupuesto,
  DROP COLUMN horaPresupuesto,
  DROP COLUMN aprobado,
  DROP COLUMN realizado,
  DROP COLUMN cobrado,
  DROP COLUMN entregado,
  DROP COLUMN fechaCobrado,
  DROP COLUMN fechaRealizado,
  DROP COLUMN precioCobrado,
  DROP COLUMN precioSinCanje,
  DROP COLUMN precioMinuto,
  DROP COLUMN puntosDisponibleCanje,
  DROP COLUMN puntosDisponibles,
--  DROP COLUMN puntosCanjeados,
  DROP COLUMN maquina,
  DROP COLUMN puntosAcumuladosPdf;

-- 8) Renombrar a snake_case
ALTER TABLE presupuesto
 -- CHANGE COLUMN idPresupuesto        id_presupuesto        INT AUTO_INCREMENT PRIMARY KEY,
  CHANGE COLUMN idCliente            id_cliente            INT NOT NULL,
  CHANGE COLUMN fecha_hora_presupuesto fecha_hora_presupuesto DATETIME NOT NULL,
  CHANGE COLUMN fecha_cobrado_dt     fecha_cobrado         DATETIME NULL,
  CHANGE COLUMN fecha_realizado_dt   fecha_realizado       DATETIME NULL,
  CHANGE COLUMN aprobado_bool        aprobado              TINYINT(1) NOT NULL,
  CHANGE COLUMN realizado_bool       realizado             TINYINT(1) NOT NULL,
  CHANGE COLUMN cobrado_bool         cobrado               TINYINT(1) NOT NULL,
  CHANGE COLUMN entregado_bool       entregado             TINYINT(1) NOT NULL,
  CHANGE COLUMN precio_cobrado_dec   precio_cobrado        DECIMAL(10,2) NOT NULL,
  CHANGE COLUMN precio_sin_canje_dec precio_sin_canje      DECIMAL(10,2) NOT NULL,
  CHANGE COLUMN precio_minuto_dec    precio_minuto         DECIMAL(10,2) NULL;

-- 9) Índices y FK
-- CREATE INDEX idx_presupuesto_cliente ON presupuesto (id_cliente);
-- CREATE INDEX idx_presupuesto_fecha   ON presupuesto (fecha_hora_presupuesto);

 ALTER TABLE `precision_schema_v2`.`presupuesto` 
 CHANGE COLUMN `idPresupuesto` `id_presupuesto` INT NOT NULL AUTO_INCREMENT ;

/*ALTER TABLE senia
  ADD CONSTRAINT fk_senia_presupuesto
  FOREIGN KEY (id_presupuesto) REFERENCES presupuesto(id_presupuesto);*/

COMMIT;