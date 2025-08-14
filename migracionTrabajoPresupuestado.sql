ALTER TABLE trabajopresupuestado
RENAME TO  trabajo_presupuestado;

-- 1) Columnas nuevas para backfill
ALTER TABLE trabajo_presupuestado
  ADD COLUMN precio_material_dec    DECIMAL(10,2) NULL,
  ADD COLUMN precio_trabajo_dec     DECIMAL(10,2) NULL,
  ADD COLUMN precio_corte_dec       DECIMAL(10,2) NULL,
  ADD COLUMN vinilo_dec             DECIMAL(10,2) NULL,
  ADD COLUMN vectorizado_dec        DECIMAL(10,2) NULL,
  ADD COLUMN disenio_dec            DECIMAL(10,2) NULL,
  ADD COLUMN precio_minuto_dec      DECIMAL(10,2) NULL;


-- 4) Montos a DECIMAL
UPDATE trabajo_presupuestado
SET precio_material_dec = ROUND(precioMaterial, 2),
    precio_trabajo_dec  = ROUND(precioTrabajo, 2),
    precio_corte_dec    = ROUND(precioCorte, 2),
    vinilo_dec          = ROUND(vinilo, 2),
    vectorizado_dec     = ROUND(vectorizado, 2),
    disenio_dec         = ROUND(disenio, 2),
    precio_minuto_dec   = ROUND(precioMinuto, 2);

-- 5) (Opcional) Unir archivoCad a notas si querés conservar el valor allí
-- UPDATE trabajo_presupuestado
-- SET notas = TRIM(CONCAT(COALESCE(NULLIF(notas,''),''),
--                         CASE WHEN archivoCad IS NOT NULL AND archivoCad <> '' THEN
--                              CONCAT(CASE WHEN notas IS NULL OR notas='' THEN '' ELSE ' | ' END,
--                                     'CAD: ', archivoCad)
--                         ELSE '' END));



-- 7) Renombrar columnas a snake_case y endurecer tipos
ALTER TABLE trabajo_presupuestado
  CHANGE COLUMN idTrabajoPresupuestado id_trabajo_presupuestado INT NOT NULL AUTO_INCREMENT,
  CHANGE COLUMN seleccionado           seleccionado              TINYINT(1) NOT NULL DEFAULT 0,
  CHANGE COLUMN archivoCad             archivo_cad               VARCHAR(255) NULL,
  CHANGE COLUMN archivoOriginal        archivo_original          VARCHAR(255) NULL,
  CHANGE COLUMN idPResupuesto          id_presupuesto            INT NOT NULL,
  CHANGE COLUMN material               material                  VARCHAR(255) NULL,
  CHANGE COLUMN notas                  notas                     VARCHAR(255) NULL,
  CHANGE COLUMN puntosPorCorte         puntos_por_corte          INT NOT NULL,
  CHANGE COLUMN tiempoDeCorte          tiempo_de_corte           INT NOT NULL;

-- 8) Tipos finales para montos/fechas y reemplazo de columnas antiguas
ALTER TABLE trabajo_presupuestado
  MODIFY precio_material_dec DECIMAL(10,2) NOT NULL,
  MODIFY precio_trabajo_dec  DECIMAL(10,2) NOT NULL,
  MODIFY precio_corte_dec    DECIMAL(10,2) NULL DEFAULT 0,
  MODIFY vinilo_dec          DECIMAL(10,2) NULL DEFAULT 0,
  MODIFY vectorizado_dec     DECIMAL(10,2) NULL DEFAULT 0,
  MODIFY disenio_dec         DECIMAL(10,2) NULL DEFAULT 0,
  MODIFY precio_minuto_dec   DECIMAL(10,2) NULL DEFAULT 0;

-- 9) Eliminar columnas viejas y dejar nombres finales
ALTER TABLE trabajo_presupuestado
  DROP COLUMN fechaRealizacion,
  DROP COLUMN horaRealizacion,
  DROP COLUMN fechaRealizado,
  DROP COLUMN precioMaterial,
  DROP COLUMN precioTrabajo,
  DROP COLUMN precioCorte,
  DROP COLUMN vinilo,
  DROP COLUMN vectorizado,
  DROP COLUMN disenio,
  DROP COLUMN precioMinuto,
  DROP COLUMN puntos_por_corte;

ALTER TABLE trabajo_presupuestado
  CHANGE COLUMN precio_material_dec  precio_material        DECIMAL(10,2) NOT NULL,
  CHANGE COLUMN precio_trabajo_dec   precio_trabajo         DECIMAL(10,2) NOT NULL,
  CHANGE COLUMN precio_corte_dec     precio_corte           DECIMAL(10,2) NULL DEFAULT 0,
  CHANGE COLUMN vinilo_dec           vinilo                 DECIMAL(10,2) NULL DEFAULT 0,
  CHANGE COLUMN vectorizado_dec      extra                  DECIMAL(10,2) NULL DEFAULT 0,
  CHANGE COLUMN disenio_dec          vectorizado            DECIMAL(10,2) NULL DEFAULT 0,
  CHANGE COLUMN precio_minuto_dec    precio_minuto          DECIMAL(10,2) NULL DEFAULT 0;

-- 10) (Opcional pero recomendado) NOT NULL en fecha_hora_realizacion si todas parsearon
-- ALTER TABLE trabajo_presupuestado
--   MODIFY fecha_hora_realizacion DATETIME NOT NULL;

-- 11) FK e índices útiles
ALTER TABLE trabajo_presupuestado
  ADD CONSTRAINT fk_tp_presupuesto
  FOREIGN KEY (id_presupuesto) REFERENCES presupuesto(id_presupuesto);

CREATE INDEX idx_tp_presupuesto      ON trabajo_presupuestado (id_presupuesto);
CREATE INDEX idx_tp_seleccionado     ON trabajo_presupuestado (seleccionado);

ALTER TABLE trabajo_presupuestado
ADD COLUMN descuento DECIMAL(10,2) NULL AFTER precio_minuto,
ADD COLUMN id_superficie INT NULL AFTER descuento;
