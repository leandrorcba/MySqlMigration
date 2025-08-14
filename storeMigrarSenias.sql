CREATE DEFINER=`root`@`%` PROCEDURE `migrar_senias`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_idPresupuesto INT;
    DECLARE v_montoSenia DECIMAL(10,2);
    DECLARE v_fechaHoraSenia DATETIME;
    DECLARE v_idSeniaNuevo INT;

    -- Cursor para recorrer presupuestos con datos de seña
    DECLARE cur CURSOR FOR
        SELECT idPresupuesto, senia, fechaSenia
        FROM presupuesto
        WHERE senia IS NOT NULL AND fechaSenia IS NOT NULL AND idSenia IS NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_idPresupuesto, v_montoSenia, v_fechaHoraSenia;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insertar en senia
        INSERT INTO senia (montoSenia, fechaHoraSenia)
        VALUES (v_montoSenia, v_fechaHoraSenia);

        SET v_idSeniaNuevo = LAST_INSERT_ID();

        -- Actualizar presupuesto con el nuevo idSenia
        UPDATE presupuesto
        SET idSenia = v_idSeniaNuevo
        WHERE idPresupuesto = v_idPresupuesto;
    END LOOP;

    CLOSE cur;
END