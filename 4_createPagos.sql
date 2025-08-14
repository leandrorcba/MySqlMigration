CREATE TABLE tipo_pago (
  id_tipo_pago INT AUTO_INCREMENT PRIMARY KEY,
  tipo VARCHAR(20) NOT NULL UNIQUE,     -- EFECTIVO, DEBITO, CREDITO, TRANSFERENCIA
  descripcion VARCHAR(50) NOT NULL
);

INSERT INTO tipo_pago (codigo, descripcion) VALUES
 ('EFECTIVO','Efectivo'),
 ('DEBITO','Tarjeta de débito'),
 ('CREDITO','Tarjeta de crédito'),
 ('TRANSFERENCIA','Transferencia bancaria'),
 ('MERCADO PAGO', 'Mercado Pago');

-- 2) Catálogo de tarjetas
CREATE TABLE tarjeta (
  id_tarjeta INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE      -- VISA, MASTERCARD, AMEX, CABAL, etc.
);

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
  -- id_venta INT NOT NULL, 
  id_presupuesto INT NOT NULL,
  id_senia INT NOT NULL	,
  id_tipo_pago INT NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_tarjeta INT NULL,                               -- requerido si CREDITO
  cuotas TINYINT UNSIGNED NULL,                      -- típico de crédito
  id_cuenta_bancaria INT NULL,                       -- requerido si DEBITO/TRANSFERENCIA
  autorizacion VARCHAR(45) NULL,                     -- ID de operación POS si aplica
  notas VARCHAR(255) NULL
  );
  
  ALTER TABLE pago
  ADD CONSTRAINT fk_pago_presupuesto
    FOREIGN KEY (id_presupuesto) REFERENCES presupuesto(id_presupuesto),
  ADD CONSTRAINT fk_pago_senia
    FOREIGN KEY (id_senia) REFERENCES senia(id_senia),
  ADD CONSTRAINT fk_pago_tipo_pago
    FOREIGN KEY (id_tipo_pago) REFERENCES tipo_pago(id_tipo_pago),
  ADD CONSTRAINT fk_pago_tarjeta
    FOREIGN KEY (id_tarjeta) REFERENCES tarjeta(id_tarjeta),
  ADD CONSTRAINT fk_pago_cuenta
    FOREIGN KEY (id_cuenta_bancaria) REFERENCES cuenta_bancaria(id_cuenta_bancaria);

  ALTER TABLE pago
  ADD COLUMN id_usuario INT NULL AFTER notas,
  ADD INDEX idx_senia_id_usuario (id_usuario)