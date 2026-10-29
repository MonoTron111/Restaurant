-- 005 Banco de Consultas
-- 1. Pedidos con cliente, empleado, mesa y subtotal
SELECT
    vr.id_pedido,
    vr.fecha_hora,
    c.nombre AS cliente,
    e.nombre AS empleado,
    m.numero AS numero_mesa,
    vr.estado,
    vr.subtotal,
    vr.unidades
FROM v_pedido_resumen AS vr
JOIN cliente AS c ON c.id_cliente = vr.id_cliente
JOIN empleado AS e ON e.id_empleado = vr.id_empleado_registra
LEFT JOIN mesa AS m ON m.id_mesa = vr.id_mesa
ORDER BY vr.fecha_hora;

-- 2. Pedidos de octubre de 2026
SELECT
    p.id_pedido,
    p.fecha_hora,
    c.nombre AS cliente,
    p.estado
FROM pedido AS p
JOIN cliente AS c ON c.id_cliente = p.id_cliente
WHERE p.fecha_hora >= TIMESTAMP '2026-10-01 00:00:00'
  AND p.fecha_hora < TIMESTAMP '2026-11-01 00:00:00'
ORDER BY p.fecha_hora;

-- 3. Productos por categoría y disponibilidad
SELECT
    ca.nombre AS categoria,
    pr.nombre AS producto,
    pr.precio,
    pr.disponible
FROM producto AS pr
JOIN categoria AS ca ON ca.id_categoria = pr.id_categoria
ORDER BY ca.nombre, pr.nombre;

-- 4. Clientes sin pedidos
SELECT
    c.id_cliente,
    c.nombre
FROM cliente AS c
LEFT JOIN pedido AS p ON p.id_cliente = c.id_cliente
WHERE p.id_pedido IS NULL
ORDER BY c.nombre;

-- 5. Productos nunca vendidos
SELECT
    pr.id_producto,
    pr.nombre,
    ca.nombre AS categoria
FROM producto AS pr
JOIN categoria AS ca ON ca.id_categoria = pr.id_categoria
LEFT JOIN item_pedido AS ip ON ip.id_producto = pr.id_producto
WHERE ip.id_producto IS NULL
ORDER BY pr.nombre;

-- 6. Clientes con más de un pedido
SELECT
    c.id_cliente,
    c.nombre,
    COUNT(p.id_pedido) AS cantidad_pedidos
FROM cliente AS c
JOIN pedido AS p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre
HAVING COUNT(p.id_pedido) > 1
ORDER BY cantidad_pedidos DESC;

-- 7. Subtotal promedio por estado
SELECT
    estado,
    COUNT(*) AS cantidad_pedidos,
    ROUND(AVG(subtotal), 2) AS subtotal_promedio,
    SUM(subtotal) AS subtotal_acumulado
FROM v_pedido_resumen
GROUP BY estado
ORDER BY estado;

-- 8. Productos con unidades vendidas por encima del promedio
WITH ventas_producto AS (
    SELECT
        pr.id_producto,
        pr.nombre AS producto,
        SUM(ip.cantidad) AS unidades_vendidas
    FROM producto AS pr
    JOIN item_pedido AS ip ON ip.id_producto = pr.id_producto
    GROUP BY pr.id_producto, pr.nombre
)
SELECT *
FROM ventas_producto
WHERE unidades_vendidas > (
    SELECT AVG(unidades_vendidas::NUMERIC)
    FROM ventas_producto
)
ORDER BY unidades_vendidas DESC;

-- 9. Reservas de una fecha
SELECT
    r.id_reserva,
    r.fecha,
    r.hora,
    r.hora_fin,
    c.nombre AS cliente,
    m.numero AS numero_mesa,
    r.cant_personas,
    r.estado
FROM reserva AS r
JOIN cliente AS c ON c.id_cliente = r.id_cliente
JOIN mesa AS m ON m.id_mesa = r.id_mesa
WHERE r.fecha = DATE '2026-10-25'
ORDER BY r.hora;

-- 10. Pedidos atendidos por meseros
SELECT
    em.nombre AS mesero,
    p.id_pedido,
    c.nombre AS cliente,
    a.fch_hora_de_atencion,
    p.estado
FROM atencion AS a
JOIN mesero AS me ON me.id_empleado = a.id_empleado
JOIN empleado AS em ON em.id_empleado = me.id_empleado
JOIN pedido AS p ON p.id_pedido = a.id_pedido
JOIN cliente AS c ON c.id_cliente = p.id_cliente
ORDER BY a.fch_hora_de_atencion;

-- 11. Ingredientes utilizados por cada producto
SELECT
    pr.nombre AS producto,
    ca.nombre AS categoria,
    i.nombre AS ingrediente,
    pi.cantidad_necesaria,
    i.unidad_medida
FROM producto AS pr
JOIN categoria AS ca ON ca.id_categoria = pr.id_categoria
JOIN producto_ingrediente AS pi ON pi.id_producto = pr.id_producto
JOIN ingrediente AS i ON i.id_ingrediente = pi.id_ingrediente
ORDER BY pr.nombre, i.nombre;

-- 12. Pedidos sin atención registrada
SELECT
    p.id_pedido,
    p.fecha_hora,
    c.nombre AS cliente,
    p.estado
FROM pedido AS p
JOIN cliente AS c ON c.id_cliente = p.id_cliente
LEFT JOIN atencion AS a ON a.id_pedido = p.id_pedido
WHERE a.id_atencion IS NULL
ORDER BY p.fecha_hora;

-- 13. Pedidos por encima del subtotal promedio
SELECT
    vr.id_pedido,
    c.nombre AS cliente,
    vr.estado,
    vr.subtotal
FROM v_pedido_resumen AS vr
JOIN cliente AS c ON c.id_cliente = vr.id_cliente
WHERE vr.subtotal > (
    SELECT AVG(subtotal)
    FROM v_pedido_resumen
)
ORDER BY vr.subtotal DESC;

-- 14. Valor vendido por categoría
SELECT
    ca.nombre AS categoria,
    SUM(ip.cantidad) AS unidades_vendidas,
    SUM(ip.cantidad * ip.precio_unitario) AS valor_vendido
FROM categoria AS ca
JOIN producto AS pr ON pr.id_categoria = ca.id_categoria
JOIN item_pedido AS ip ON ip.id_producto = pr.id_producto
GROUP BY ca.id_categoria, ca.nombre
HAVING SUM(ip.cantidad * ip.precio_unitario) > 0
ORDER BY valor_vendido DESC;
