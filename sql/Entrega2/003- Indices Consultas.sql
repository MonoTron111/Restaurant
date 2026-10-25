-- Migracion 003: indices para claves foraneas y consultas frecuentes.

BEGIN;

CREATE INDEX idx_empleado_id_cargo ON empleado(id_cargo);
CREATE INDEX idx_empleado_telefono_empleado ON empleado_telefono(id_empleado);
CREATE INDEX idx_reserva_cliente_fecha ON reserva(id_cliente, fecha);
CREATE INDEX idx_reserva_mesa_fecha_hora ON reserva(id_mesa, fecha, hora, hora_fin);
CREATE INDEX idx_producto_categoria_disponible ON producto(id_categoria, disponible);
CREATE INDEX idx_producto_ingrediente_ingrediente ON producto_ingrediente(id_ingrediente);
CREATE INDEX idx_pedido_cliente_fecha ON pedido(id_cliente, fecha_hora);
CREATE INDEX idx_pedido_mesa_fecha ON pedido(id_mesa, fecha_hora);
CREATE INDEX idx_pedido_empleado_fecha ON pedido(id_empleado_registra, fecha_hora);
CREATE INDEX idx_pedido_estado_fecha ON pedido(estado, fecha_hora);
CREATE INDEX idx_item_producto ON item_pedido(id_producto);
CREATE INDEX idx_atencion_pedido ON atencion(id_pedido);
CREATE INDEX idx_prepara_pedido ON prepara(id_pedido);
CREATE INDEX idx_atencion_empleado ON atencion(id_empleado);

COMMIT;
