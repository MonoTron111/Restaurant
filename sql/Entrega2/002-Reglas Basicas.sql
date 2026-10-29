-- Migracion 002: reglas de negocio que requieren validacion entre tablas.

BEGIN;

-- 1. Validar que el subtipo de empleado coincida con su cargo.
CREATE OR REPLACE FUNCTION fn_validar_subtipo_empleado()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_cargo VARCHAR(30);
BEGIN
    SELECT c.nombre
      INTO v_cargo
      FROM empleado e
      JOIN cargo c ON c.id_cargo = e.id_cargo
     WHERE e.id_empleado = NEW.id_empleado;

    IF v_cargo IS NULL THEN
        RAISE EXCEPTION 'No existe el empleado % o no tiene cargo', NEW.id_empleado;
    END IF;

    IF TG_TABLE_NAME = 'mesero' AND v_cargo <> 'Mesero' THEN
        RAISE EXCEPTION 'El empleado % no tiene cargo Mesero', NEW.id_empleado;
    ELSIF TG_TABLE_NAME = 'cocinero' AND v_cargo <> 'Cocinero' THEN
        RAISE EXCEPTION 'El empleado % no tiene cargo Cocinero', NEW.id_empleado;
    ELSIF TG_TABLE_NAME = 'administrador' AND v_cargo <> 'Administrador' THEN
        RAISE EXCEPTION 'El empleado % no tiene cargo Administrador', NEW.id_empleado;
    END IF;

    IF TG_TABLE_NAME = 'mesero' AND
       (EXISTS (SELECT 1 FROM cocinero WHERE id_empleado = NEW.id_empleado)
        OR EXISTS (SELECT 1 FROM administrador WHERE id_empleado = NEW.id_empleado)) THEN
        RAISE EXCEPTION 'Un empleado no puede pertenecer a mas de un subtipo';
    ELSIF TG_TABLE_NAME = 'cocinero' AND
       (EXISTS (SELECT 1 FROM mesero WHERE id_empleado = NEW.id_empleado)
        OR EXISTS (SELECT 1 FROM administrador WHERE id_empleado = NEW.id_empleado)) THEN
        RAISE EXCEPTION 'Un empleado no puede pertenecer a mas de un subtipo';
    ELSIF TG_TABLE_NAME = 'administrador' AND
       (EXISTS (SELECT 1 FROM mesero WHERE id_empleado = NEW.id_empleado)
        OR EXISTS (SELECT 1 FROM cocinero WHERE id_empleado = NEW.id_empleado)) THEN
        RAISE EXCEPTION 'Un empleado no puede pertenecer a mas de un subtipo';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_mesero_validar_cargo
BEFORE INSERT OR UPDATE OF id_empleado ON mesero
FOR EACH ROW EXECUTE FUNCTION fn_validar_subtipo_empleado();

CREATE TRIGGER trg_cocinero_validar_cargo
BEFORE INSERT OR UPDATE OF id_empleado ON cocinero
FOR EACH ROW EXECUTE FUNCTION fn_validar_subtipo_empleado();

CREATE TRIGGER trg_administrador_validar_cargo
BEFORE INSERT OR UPDATE OF id_empleado ON administrador
FOR EACH ROW EXECUTE FUNCTION fn_validar_subtipo_empleado();


-- 2. Evitar cambios de cargo incompatibles con el subtipo.
CREATE OR REPLACE FUNCTION fn_validar_cambio_cargo_empleado()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM mesero WHERE id_empleado = NEW.id_empleado)
       AND (SELECT nombre FROM cargo WHERE id_cargo = NEW.id_cargo) <> 'Mesero' THEN
        RAISE EXCEPTION 'Debe quitar el subtipo Mesero antes de cambiar el cargo';
    END IF;

    IF EXISTS (SELECT 1 FROM cocinero WHERE id_empleado = NEW.id_empleado)
       AND (SELECT nombre FROM cargo WHERE id_cargo = NEW.id_cargo) <> 'Cocinero' THEN
        RAISE EXCEPTION 'Debe quitar el subtipo Cocinero antes de cambiar el cargo';
    END IF;

    IF EXISTS (SELECT 1 FROM administrador WHERE id_empleado = NEW.id_empleado)
       AND (SELECT nombre FROM cargo WHERE id_cargo = NEW.id_cargo) <> 'Administrador' THEN
        RAISE EXCEPTION 'Debe quitar el subtipo Administrador antes de cambiar el cargo';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_empleado_validar_cambio_cargo
BEFORE UPDATE OF id_cargo ON empleado
FOR EACH ROW EXECUTE FUNCTION fn_validar_cambio_cargo_empleado();


-- 3. Validar capacidad de la mesa para las reservas.
CREATE OR REPLACE FUNCTION fn_validar_capacidad_reserva()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_capacidad INTEGER;
BEGIN
    SELECT capacidad
      INTO v_capacidad
      FROM mesa
     WHERE id_mesa = NEW.id_mesa;

    IF v_capacidad IS NULL THEN
        RAISE EXCEPTION 'La mesa % no existe', NEW.id_mesa;
    END IF;

    IF NEW.cant_personas IS NULL OR NEW.cant_personas <= 0 THEN
        RAISE EXCEPTION 'La cantidad de personas debe ser positiva';
    END IF;

    IF NEW.cant_personas > v_capacidad THEN
        RAISE EXCEPTION 'La reserva es para % personas, pero la mesa % solo tiene capacidad para %',
            NEW.cant_personas, NEW.id_mesa, v_capacidad;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_reserva_validar_capacidad
BEFORE INSERT OR UPDATE OF id_mesa, cant_personas ON reserva
FOR EACH ROW EXECUTE FUNCTION fn_validar_capacidad_reserva();


-- 4. Validar capacidad de la mesa para los pedidos.
CREATE OR REPLACE FUNCTION fn_validar_capacidad_pedido()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_capacidad INTEGER;
BEGIN
    IF NEW.id_mesa IS NOT NULL THEN
        SELECT capacidad
          INTO v_capacidad
          FROM mesa
         WHERE id_mesa = NEW.id_mesa;

        IF v_capacidad IS NULL THEN
            RAISE EXCEPTION 'La mesa % no existe', NEW.id_mesa;
        END IF;

        IF NEW.cant_personas IS NULL OR NEW.cant_personas <= 0 THEN
            RAISE EXCEPTION 'Un pedido asociado a una mesa debe indicar una cantidad positiva de personas';
        END IF;

        IF NEW.cant_personas > v_capacidad THEN
            RAISE EXCEPTION 'El pedido es para % personas, pero la mesa % solo tiene capacidad para %',
                NEW.cant_personas, NEW.id_mesa, v_capacidad;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pedido_validar_capacidad
BEFORE INSERT OR UPDATE OF id_mesa, cant_personas ON pedido
FOR EACH ROW EXECUTE FUNCTION fn_validar_capacidad_pedido();


-- 5. Evitar reducir la capacidad de una mesa por debajo de reservas
-- o pedidos activos que ya tiene asignados.
CREATE OR REPLACE FUNCTION fn_validar_cambio_capacidad_mesa()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.capacidad < OLD.capacidad AND EXISTS (
        SELECT 1
          FROM reserva r
         WHERE r.id_mesa = NEW.id_mesa
           AND r.cant_personas > NEW.capacidad
           AND r.estado IN ('Pendiente', 'Confirmada')
    ) THEN
        RAISE EXCEPTION 'No se puede reducir la capacidad: hay reservas activas para mas personas';
    END IF;

    IF NEW.capacidad < OLD.capacidad AND EXISTS (
        SELECT 1
          FROM pedido p
         WHERE p.id_mesa = NEW.id_mesa
           AND p.cant_personas > NEW.capacidad
           AND p.estado IN ('Pendiente', 'Preparacion', 'Listo')
    ) THEN
        RAISE EXCEPTION 'No se puede reducir la capacidad: hay pedidos activos para mas personas';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_mesa_validar_capacidad
BEFORE UPDATE OF capacidad ON mesa
FOR EACH ROW EXECUTE FUNCTION fn_validar_cambio_capacidad_mesa();


-- 6. Evitar reservas que se crucen en la misma mesa.
CREATE OR REPLACE FUNCTION fn_validar_solapamiento_reserva()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.estado IN ('Pendiente', 'Confirmada', 'Asistio') AND EXISTS (
        SELECT 1
          FROM reserva r
         WHERE r.id_mesa = NEW.id_mesa
           AND r.fecha = NEW.fecha
           AND r.estado IN ('Pendiente', 'Confirmada', 'Asistio')
           AND r.id_reserva <> COALESCE(NEW.id_reserva, -1)
           AND NEW.hora < r.hora_fin
           AND NEW.hora_fin > r.hora
    ) THEN
        RAISE EXCEPTION 'La mesa % ya tiene una reserva que se cruza con ese horario', NEW.id_mesa;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_reserva_validar_solapamiento
BEFORE INSERT OR UPDATE OF id_mesa, fecha, hora, hora_fin, estado ON reserva
FOR EACH ROW EXECUTE FUNCTION fn_validar_solapamiento_reserva();


-- 7. Validar que cada pedido tenga al menos un detalle.
-- La validacion se ejecuta al confirmar la transaccion.
CREATE OR REPLACE FUNCTION fn_pedido_debe_tener_detalles()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_pedido INTEGER;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_id_pedido := OLD.id_pedido;
    ELSE
        v_id_pedido := NEW.id_pedido;
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pedido
         WHERE id_pedido = v_id_pedido
    ) AND NOT EXISTS (
        SELECT 1
          FROM item_pedido
         WHERE id_pedido = v_id_pedido
    ) THEN
        RAISE EXCEPTION 'El pedido % debe tener al menos un detalle', v_id_pedido;
    END IF;

    RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_pedido_debe_tener_detalles
AFTER INSERT OR UPDATE ON pedido
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION fn_pedido_debe_tener_detalles();

CREATE CONSTRAINT TRIGGER trg_item_debe_pertenecer_a_pedido_con_detalles
AFTER INSERT OR UPDATE OR DELETE ON item_pedido
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION fn_pedido_debe_tener_detalles();


-- 8. Vista con resumen de pedidos y sus detalles.
CREATE OR REPLACE VIEW v_pedido_resumen AS
SELECT p.id_pedido,
       p.fecha_hora,
       p.estado,
       p.id_cliente,
       p.id_mesa,
       p.cant_personas,
       p.id_empleado_registra,
       COALESCE(SUM(ip.cantidad * ip.precio_unitario), 0)::NUMERIC(12,2) AS subtotal,
       COALESCE(SUM(ip.cantidad), 0)::BIGINT AS unidades
  FROM pedido p
  LEFT JOIN item_pedido ip ON ip.id_pedido = p.id_pedido
 GROUP BY p.id_pedido,
          p.fecha_hora,
          p.estado,
          p.id_cliente,
          p.id_mesa,
          p.cant_personas,
          p.id_empleado_registra;

COMMIT;
