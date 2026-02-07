CREATE TABLE medio_pago (
  id_medio_pago INT AUTO_INCREMENT PRIMARY KEY,
  tipo VARCHAR(20) NOT NULL UNIQUE,     -- EFECTIVO, DEBITO, CREDITO, TRANSFERENCIA
  descripcion VARCHAR(50) NOT NULL
);

INSERT INTO medio_pago (tipo, descripcion) VALUES
 ('EFECTIVO','Efectivo'),
 ('DEBITO','Tarjeta de débito'),
 ('CREDITO','Tarjeta de crédito'),
 ('TRANSFERENCIA','Transferencia bancaria'),
 ('MERCADO PAGO', 'Mercado Pago'),
  ('OTRO', 'Otro');

-- 2) Catálogo de tarjetas
CREATE TABLE tarjeta (
  id_tarjeta INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE      -- VISA, MASTERCARD, AMEX, CABAL, etc.
);

CREATE TABLE tipo_pago (
  id_tipo_pago INT AUTO_INCREMENT PRIMARY KEY,
  tipo VARCHAR(20) NOT NULL UNIQUE     -- SENIA, PRESUPUESTO, ETC
);

INSERT INTO tipo_pago (tipo) VALUES
 ('SENIA'),
 ('PRESUPUESTO'),
 ('VENTA INSUMOS'),
 ('VENTA MATERIALES');

-- 3) Cuentas bancarias
CREATE TABLE cuenta_bancaria (
  id_cuenta_bancaria INT AUTO_INCREMENT PRIMARY KEY,
  banco VARCHAR(100) NOT NULL,
  alias_cbu VARCHAR(30) UNIQUE,
  cbu CHAR(22) UNIQUE,
  numero_cuenta VARCHAR(34) UNIQUE,
  moneda CHAR(3) NOT NULL DEFAULT 'ARS',
  habilitada BOOLEAN NOT NULL DEFAULT TRUE
);


CREATE TABLE pago (
  id_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_origen_pago INT NOT NULL,   -- id de lo que se esta pagando pej id_presupuesto
  id_tipo_pago INT NOT NULL, -- senia, presupuesto, material, etc
  id_medio_pago INT NOT NULL, -- efectivo, tarjeta, etc
  monto DECIMAL(10,2) NOT NULL,
  fecha_hora DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  id_tarjeta INT NULL,                               -- requerido si CREDITO
  cuotas TINYINT UNSIGNED NULL,                      -- típico de crédito
  id_cuenta_bancaria INT NULL,                       -- requerido si DEBITO/TRANSFERENCIA
  autorizacion VARCHAR(45) NULL,                     -- ID de operación POS si aplica
  notas VARCHAR(255) NULL
  );
  
 /* ALTER TABLE pago
  ADD COLUMN id_usuario INT NULL AFTER notas,
  ADD INDEX idx_senia_id_usuario (id_usuario);
  
    ALTER TABLE pago
  ADD COLUMN descuento_efectivo DECIMAL(10,2) NULL AFTER monto;*/