CREATE TABLE usuarios (
  id_usuario     INT AUTO_INCREMENT PRIMARY KEY,
  nombre         VARCHAR(100) NOT NULL,         -- nombre y apellido
  username       VARCHAR(50)  NULL,             -- único si usás login
  email          VARCHAR(150) NULL,             -- único si lo usás
  telefono       VARCHAR(30)  NULL,
  password_hash  VARCHAR(255) NULL,             -- bcrypt/argon2 (opcional)
  activo         BOOLEAN      NOT NULL DEFAULT TRUE,

  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,

  UNIQUE KEY uq_usuarios_username (username),
  KEY ix_usuarios_nombre (nombre)
)

