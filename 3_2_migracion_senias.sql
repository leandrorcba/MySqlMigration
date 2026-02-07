


/*-- Pagos (una seña puede tener 1..N pagos)
CREATE TABLE pago (
  id_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_senia INT NULL,                                 -- requerido cuando aplica_a = 'SENIA'
  id_venta_insumo INT NULL,                                 -- requerido cuando aplica_a = 'VENTA_INSUMOS'
  id_venta_material INT NULL,                                 -- requerido cuando aplica_a = 'VENTA_MATERIAL'
  id_presupuesto INT NULL,                                 -- requerido cuando aplica_a = 'TRABAJO'
  id_tipo_pago INT NOT NULL,
  aplica_a ENUM('SENIA','VENTA_INSUMOS','VENTA_MATERIAL','TRABAJO')
           NOT NULL DEFAULT 'SENIA',
  descripcion VARCHAR(255) NULL,
  monto DECIMAL(10,2) NOT NULL,
  fecha_hora_pago DATETIME,
  CONSTRAINT fk_pago_senia      FOREIGN KEY (id_senia)    REFERENCES senia(id_senia),
  CONSTRAINT fk_pago_tipo_pago  FOREIGN KEY (id_tipo_pago) REFERENCES tipo_pago(id_tipo_pago),
  CONSTRAINT chk_pago_senia CHECK (
    (aplica_a <> 'SENIA') OR (id_senia IS NOT NULL)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;*/

-- CREATE INDEX idx_pago_senia ON pago(id_senia);
-- CREATE INDEX idx_pago_tipo  ON pago(id_tipo_pago);

-- id del tipo EFECTIVO
-- SET @id_efectivo := (SELECT id_tipo_pago FROM tipo_pago WHERE nombre_tipo_pago = 'PREVIO_MIGRACION');
/*
### migracion datos
INSERT INTO senia (id_presupuesto, monto_senia, fecha_hora_senia)
SELECT
  p.id_presupuesto,
  CAST(p.senia AS DECIMAL(10,2)) AS monto_senia,
  COALESCE(
    -- Intento convertir fechaSenia (VARCHAR) con varios formatos comunes
      STR_TO_DATE(p.fechaSenia, '%d/%m/%Y %H:%i:%s'),
      STR_TO_DATE(p.fechaSenia, '%d/%m/%Y'),
      STR_TO_DATE(p.fechaSenia, '%Y-%m-%d %H:%i:%s'),
      STR_TO_DATE(p.fechaSenia, '%Y-%m-%d'),
    -- Último recurso: NOW()
    NOW()
  ) AS fecha_hora_senia
FROM presupuesto p
WHERE p.senia IS NOT NULL AND p.senia > 0;*/


SET @id_efectivo := (SELECT id_tipo_pago FROM tipo_pago WHERE tipo = 'SENIA');
SET @id_medio_pago := (SELECT id_medio_pago FROM medio_pago WHERE tipo = 'EFECTIVO');

INSERT INTO pago (id_origen_pago, id_tipo_pago, id_medio_pago, monto, fecha_hora)
SELECT
  p.id_presupuesto,
  @id_efectivo,
  @id_medio_pago,
  p.senia,
  p.fechaSenia
FROM presupuesto p
WHERE p.senia IS NOT NULL and p.senia != 0;

ALTER TABLE presupuesto
  DROP COLUMN senia,
  DROP COLUMN fechasenia;
  
-- ALTER TABLE senia
-- DROP COLUMN monto_senia;

