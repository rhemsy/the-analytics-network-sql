-- CLASE 1

/*
Ejemplo. Pregunta: Cuantas tiendas estan ubicadas en Argentina?
1° Ver tabla filtrada por país 'Argentina'
select * from stg.store_master where pais = 'Argentina'
2° filtramos en la columna por valor únicos y contamos para obtener la respuesta específica 
*/
select count(distinct codigo_tienda) from stg.store_master where pais = 'Argentina'

--1 Mostrar todos los productos dentro de la categoria electro junto con todos los detalles.
select * from stg.product_master where categoria = 'Electro'

--2 Cuales son los producto producidos en China?
select * from stg.product_master where origen = 'China'

--3 Mostrar todos los productos de Electro ordenados por nombre.
select * from stg.product_master
where categoria = 'Electro'
order by nombre asc

--4 Cuales son las TV que se encuentran activas para la venta?
select * from stg.product_master
where subcategoria = 'TV'
and is_active = true

--5 Mostrar todas las tiendas de Argentina ordenadas por fecha de apertura de las mas antigua a la mas nueva.
select * from stg.store_master
where pais = 'Argentina'
order by fecha_apertura asc

--6 Cuales fueron las ultimas 5 ordenes de ventas?
select orden from stg.order_line_sale
order by fecha desc
limit 5
-- Aunque no hay repetidos, no estoy seguro de cómo filtrarlos

--7 Mostrar los primeros 10 registros de el conteo de trafico por Super store ordenados por fecha.
select * from stg.super_store_count
order by fecha asc
limit 10

--8 Cuales son los producto de electro que no son Soporte de TV ni control remoto.
select * from stg.product_master
where categoria = 'Electro'
and subsubcategoria != 'Soporte'
and subsubcategoria != 'Control remoto'
-- and subsubcategoria not in ('Soporte','Control remoto')

--9 Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
select * from stg.order_line_sale
where moneda = 'ARS'
and venta > 100000

--10 Mostrar todas las lineas de ventas de Octubre 2022.
select * from stg.order_line_sale
where fecha between to_date('01-OCT-2022','DD-MON-YY') and to_date('31-OCT-2022','DD-MON-YY')
order by fecha

--11 Mostrar todos los productos que tengan EAN.
select * from stg.product_master
where ean is not null

--12 Mostrar todas las lineas de venta que que hayan sido vendidas entre 1 de Octubre de 2022 y 10 de Noviembre de 2022.
select * from stg.order_line_sale
where fecha between to_date('01-OCT-2022','DD-MON-YY') and to_date('10-NOV-2022','DD-MON-YY')
order by fecha
