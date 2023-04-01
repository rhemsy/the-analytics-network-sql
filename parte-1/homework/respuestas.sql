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

-- CLASE 2

--1 Cuales son los paises donde la empresa tiene tiendas?
select distinct(pais) from stg.store_master

--2 Cuantos productos por subcategoria tiene disponible para la venta?
--select * from stg.product_master

select
	subcategoria,
	count(codigo_producto) as cantidad_de_productos

from
	stg.product_master
	
group by
	subcategoria

order by cantidad_de_productos desc

--3 Cuales son las ordenes de venta de Argentina de mayor a $100.000?
select
	orden,
	sum(venta) as sum_venta
from
	stg.order_line_sale
where
	moneda = 'ARS'
group by
	orden
having
	sum(venta) >= 100000
order by
	sum_venta desc

--4 Obtener los decuentos otorgados durante Noviembre de 2022 en cada una de las monedas?
select
	sum(descuento) as total_descuento,
	moneda
from
	stg.order_line_sale
where
	fecha
		between to_date('01-NOV-2022','DD-MON-YY')
			and to_date('30-NOV-2022','DD-MON-YY')
group by
	moneda
/*
faltaría reemplazar el null en EUR por 0
select
	moneda,
	coalesce (descuento,0) as descuento
from stg.order_line_sale
*/

--5 Obtener los impuestos pagados en Europa durante el 2022.
select
	sum(impuestos) as impuestos_EUR_2022,
	moneda
from
	stg.order_line_sale
where
	moneda = 'EUR'
	and fecha
		between to_date('01-JAN-2022','DD-MON-YY')
			and to_date('31-DEC-2022','DD-MON-YY')
group by
	moneda

--6 En cuantas ordenes se utilizaron creditos?
select
	count(distinct orden) as ordenes_sin_credito
from
	stg.order_line_sale
where
	creditos is not null
--7 Cual es el % de descuentos otorgados (sobre las ventas) por tienda?
select
	tienda,
-- 	sum(descuento) as descuentos,
-- 	sum(venta) as ventas,
	-sum(descuento) / sum(venta) * 100 as porcentaje_descuento
from
	stg.order_line_sale
group by
	tienda

--8 Cual es el inventario promedio por dia que tiene cada tienda?
select
	fecha,
	tienda,
	avg((inicial + final) / 2) as inventario_promedio
from
	stg.inventory
group by
	fecha, tienda
order by
	fecha, tienda

--9 Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.
select
	producto,
	sum(venta) as ventas,
	sum(descuento) as descuentos,
	-sum(descuento) / sum(venta) * 100 as porcentaje_descuento
from
	stg.order_line_sale
where
	moneda = 'ARS'
group by
	producto
order by
	producto
	
--10 Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa para contar la cantidad de gente que ingresa a tienda, uno para las tiendas de Latinoamerica y otro para Europa. Obtener en una unica tabla, las entradas a tienda de ambos sistemas.
select tienda, cast(fecha as varchar(10)) as fecha,conteo from stg.market_count
union all
select tienda, cast(fecha as varchar(10)) as fecha, conteo from stg.super_store_count

--11 Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
select
	*
from
	stg.product_master
where
	is_active = true
	and lower(nombre) like '%philips%'

--12 Obtener el monto vendido por tienda y moneda y ordenarlo de mayor a menor por valor nominal.
select
	tienda,
	sum(venta) as ventas,
	moneda
from
	stg.order_line_sale
group by
	tienda,
	moneda
order by
	ventas desc

--13 Cual es el precio promedio de venta de cada producto en las distintas monedas? Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
select
	producto,
	sum(venta)/sum(cantidad) as precio_promedio,
	moneda
from
	stg.order_line_sale
group by
	producto,
	moneda
order by
	producto,
	moneda

--14 Cual es la tasa de impuestos que se pago por cada orden de venta?
select
	orden,
	sum(venta),
	sum(impuestos),
	moneda,
	sum(impuestos)/sum(venta)*100 as tasa_impuestos
from
	stg.order_line_sale
group by
	orden,
	moneda
order by
	orden
