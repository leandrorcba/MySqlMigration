ALTER TABLE preciomateriales
  CHANGE COLUMN idprecioMateriales id_precio_materiales INT NOT NULL AUTO_INCREMENT,
  CHANGE COLUMN idMateriales id_materiales INT,
  CHANGE COLUMN precioMaterial precio_material DECIMAL(10,2) NOT NULL,
  ADD COLUMN id_superficie TINYINT UNSIGNED NULL AFTER id_materiales;
  
  UPDATE preciomateriales pm
JOIN materiales m ON m.id_materiales = pm.id_materiales
JOIN superficies s ON s.valor = pm.superficie
SET pm.id_superficie = s.id_superficie
WHERE (pm.id_superficie IS NULL OR pm.id_superficie = 0)
  AND m.is_material = 1 and id_precio_materiales > 0;

#Elimino los insumos
delete from preciomateriales where id_superficie is null and id_precio_materiales > 0;

#Borramos la superficie
ALTER TABLE preciomateriales
DROP COLUMN superficie;

#Elimino los insumos
delete from materiales where is_material = 0 and id_materiales > 0;

#Borramos is_materiale
ALTER TABLE materiales
DROP COLUMN is_material;

ALTER TABLE preciomateriales
RENAME TO  precio_materiales ;