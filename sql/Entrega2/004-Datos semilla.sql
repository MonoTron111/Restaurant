-- 004 datos semilla

BEGIN;

INSERT INTO cargo (id_cargo, nombre) VALUES
(1, 'Mesero'), (2, 'Cocinero'), (3, 'Administrador'), (4, 'Cajero');

INSERT INTO empleado (id_empleado, nombre, fch_ingreso, salario, id_cargo) VALUES
(1, 'Maria Gomez', '2024-02-01', 1800000, 1),
(2, 'Carlos Diaz', '2023-06-15', 2100000, 2),
(3, 'Laura Perez', '2022-09-10', 2800000, 3),
(4, 'Andres Ruiz', '2025-01-20', 1750000, 4),
(5, 'Sofia Torres', '2024-08-05', 1850000, 1),
(6, 'David Rojas', '2024-03-12', 2050000, 2);

INSERT INTO empleado_telefono (id_empleado, telefono) VALUES
(1, '3000000001'), (1, '6050000001'), (2, '3000000002'),
(3, '3000000003'), (4, '3000000004'), (5, '3000000005'), (6, '3000000006');

INSERT INTO mesero (id_empleado, porcentaje_propinas) VALUES (1, 8.00), (5, 10.00);
INSERT INTO cocinero (id_empleado, especialidad) VALUES (2, 'Comida tipica'), (6, 'Postres');
INSERT INTO administrador (id_empleado, nivel_permiso) VALUES (3, 5);

INSERT INTO cliente (id_cliente, nombre, telefono, email, direccion) VALUES
(1, 'Juan Perez', '3001110001', 'juan@example.com', 'Barrio Centro'),
(2, 'Ana Martinez', '3001110002', 'ana@example.com', 'Barrio Norte'),
(3, 'Luis Mendoza', '3001110003', 'luis@example.com', 'Barrio Sur'),
(4, 'Camila Castro', '3001110004', 'camila@example.com', 'Barrio Oriente'),
(5, 'Pedro Silva', '3001110005', 'pedro@example.com', 'Barrio Occidente'),
(6, 'Valeria Ortiz', '3001110006', 'valeria@example.com', 'Barrio Centro');

INSERT INTO mesa (id_mesa, numero, capacidad, ubicacion, estado) VALUES
(1, 1, 2, 'Terraza', 'disponible'),
(2, 2, 4, 'Salon principal', 'disponible'),
(3, 3, 6, 'Salon principal', 'ocupada'),
(4, 4, 4, 'Ventana', 'disponible'),
(5, 5, 8, 'Salon familiar', 'disponible');

INSERT INTO reserva (id_reserva, id_cliente, id_mesa, fecha, hora, hora_fin, cant_personas, estado) VALUES
(1, 1, 2, '2026-10-25', '18:00', '20:00', 4, 'Confirmada'),
(2, 2, 1, '2026-10-25', '18:30', '20:00', 2, 'Pendiente'),
(3, 3, 3, '2026-10-25', '19:00', '21:00', 5, 'Confirmada'),
(4, 4, 4, '2026-10-26', '12:00', '13:30', 3, 'No asistio'),
(5, 5, 2, '2026-10-25', '20:00', '22:00', 4, 'Confirmada'),
(6, 6, 5, '2026-10-27', '19:00', '21:00', 7, 'Cancelada');

INSERT INTO categoria (id_categoria, nombre) VALUES
(1, 'Bebidas'), (2, 'Platos fuertes'), (3, 'Postres'), (4, 'Entradas');

INSERT INTO producto (id_producto, nombre, precio, tiempo_preparacion, disponible, id_categoria) VALUES
(1, 'Jugo de mango', 7000, 5, TRUE, 1),
(2, 'Bandeja paisa', 28000, 25, TRUE, 2),
(3, 'Flan casero', 8000, 12, TRUE, 3),
(4, 'Arepa de queso', 6000, 10, TRUE, 4),
(5, 'Limonada', 6500, 5, FALSE, 1),
(6, 'Arroz con pollo', 19000, 20, TRUE, 2),
(7, 'Brownie', 7500, 10, TRUE, 3);

INSERT INTO ingrediente (id_ingrediente, nombre, unidad_medida) VALUES
(1, 'Mango', 'gramos'), (2, 'Leche', 'mililitros'), (3, 'Arroz', 'gramos'),
(4, 'Pollo', 'gramos'), (5, 'Queso', 'gramos'), (6, 'Harina', 'gramos'),
(7, 'Azucar', 'gramos');

INSERT INTO producto_ingrediente (id_producto, id_ingrediente, cantidad_necesaria) VALUES
(1, 1, 180), (1, 7, 15), (2, 3, 150), (2, 4, 200),
(3, 2, 100), (3, 7, 25), (4, 5, 60), (6, 3, 180), (6, 4, 150), (7, 6, 80), (7, 7, 20);

INSERT INTO pedido (id_pedido, id_cliente, id_mesa, id_empleado_registra, cant_personas, fecha_hora, estado) VALUES
(1, 1, 2, 1, 4, '2026-10-20 12:15:00', 'Entregado'),
(2, 2, 1, 5, 2, '2026-10-21 13:10:00', 'Preparacion'),
(3, 3, NULL, 1, 2, '2026-10-22 19:30:00', 'Pendiente'),
(4, 4, 4, 5, 3, '2026-10-23 20:00:00', 'Listo'),
(5, 5, NULL, 4, 1, '2026-10-24 18:40:00', 'Cancelado'),
(6, 1, 3, 1, 4, '2026-10-25 19:20:00', 'Entregado'),
(7, 6, 5, 4, 5, '2026-10-26 14:00:00', 'Entregado');

INSERT INTO item_pedido (id_pedido, numero_linea, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 2, 2, 28000), (1, 2, 1, 2, 7000),
(2, 1, 6, 1, 19000), (2, 2, 5, 1, 6500),
(3, 1, 4, 2, 6000), (3, 2, 1, 1, 7000),
(4, 1, 3, 2, 8000), (4, 2, 7, 1, 7500),
(5, 1, 2, 1, 28000),
(6, 1, 6, 2, 19000), (6, 2, 1, 2, 7000),
(7, 1, 4, 3, 6000), (7, 2, 3, 2, 8000);

INSERT INTO atencion (id_atencion, id_empleado, id_pedido, fch_hora_de_atencion) VALUES
(1, 1, 1, '2026-10-20 12:15:00'),
(2, 5, 2, '2026-10-21 13:10:00'),
(3, 1, 3, '2026-10-22 19:30:00'),
(4, 5, 4, '2026-10-23 20:00:00'),
(5, 1, 6, '2026-10-25 19:20:00');

INSERT INTO prepara (id_empleado, id_pedido, cantidad_platos) VALUES
(2, 1, 4), (6, 2, 2), (2, 3, 3), (6, 4, 3),
(2, 6, 4), (6, 7, 5);

-- Cliente que todavia no ha realizado pedidos
INSERT INTO cliente
    (id_cliente, nombre, telefono, email, direccion)
VALUES
    (7, 'Daniela Fuentes', '3001110007',
     'daniela.fuentes@example.com', 'Barrio Los Alpes');

-- Producto que nunca se ha vendido
INSERT INTO producto
    (id_producto, nombre, precio, tiempo_preparacion,
     disponible, id_categoria)
VALUES
    (8, 'Sopa de lentejas', 12000, 20, TRUE, 2);

-- Ingredientes del producto que nunca se ha vendido
INSERT INTO ingrediente
    (id_ingrediente, nombre, unidad_medida)
VALUES
    (8, 'Lentejas', 'gramos'),
    (9, 'Zanahoria', 'gramos'),
    (10, 'Cebolla', 'gramos');

INSERT INTO producto_ingrediente
    (id_producto, id_ingrediente, cantidad_necesaria)
VALUES
    (8, 8, 180),
    (8, 9, 40),
    (8, 10, 25);

-- Ajustar las secuencias de identidad despues de cargar IDs explicitos.
SELECT setval(pg_get_serial_sequence('cliente', 'id_cliente'),(SELECT MAX(id_cliente) FROM cliente));
SELECT setval(pg_get_serial_sequence('producto', 'id_producto'),(SELECT MAX(id_producto) FROM producto));
SELECT setval(pg_get_serial_sequence('ingrediente', 'id_ingrediente'),(SELECT MAX(id_ingrediente) FROM ingrediente));
SELECT setval(pg_get_serial_sequence('cargo', 'id_cargo'), (SELECT MAX(id_cargo) FROM cargo));
SELECT setval(pg_get_serial_sequence('empleado', 'id_empleado'), (SELECT MAX(id_empleado) FROM empleado));
SELECT setval(pg_get_serial_sequence('cliente', 'id_cliente'), (SELECT MAX(id_cliente) FROM cliente));
SELECT setval(pg_get_serial_sequence('mesa', 'id_mesa'), (SELECT MAX(id_mesa) FROM mesa));
SELECT setval(pg_get_serial_sequence('reserva', 'id_reserva'), (SELECT MAX(id_reserva) FROM reserva));
SELECT setval(pg_get_serial_sequence('categoria', 'id_categoria'), (SELECT MAX(id_categoria) FROM categoria));
SELECT setval(pg_get_serial_sequence('producto', 'id_producto'), (SELECT MAX(id_producto) FROM producto));
SELECT setval(pg_get_serial_sequence('ingrediente', 'id_ingrediente'), (SELECT MAX(id_ingrediente) FROM ingrediente));
SELECT setval(pg_get_serial_sequence('pedido', 'id_pedido'), (SELECT MAX(id_pedido) FROM pedido));
SELECT setval(pg_get_serial_sequence('atencion', 'id_atencion'), (SELECT MAX(id_atencion) FROM atencion));

COMMIT;