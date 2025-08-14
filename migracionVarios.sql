ALTER TABLE varios
CHANGE COLUMN idVarios        id_varios        INT UNSIGNED NOT NULL AUTO_INCREMENT,
CHANGE COLUMN precioMinuto    precio_minuto    DECIMAL(10,2) NULL,
CHANGE COLUMN horaInicio      hora_inicio      TIME NULL,
CHANGE COLUMN horaCierre      hora_cierre      TIME NULL,
CHANGE COLUMN ajuste          ajuste           DECIMAL(10,2) NULL,
CHANGE COLUMN horaInicioFdS   hora_inicio_fds  TIME NULL,
CHANGE COLUMN horaCierreFdS   hora_cierre_fds  TIME NULL;

ALTER TABLE varios
DROP COLUMN PuntosPorMinuto;

