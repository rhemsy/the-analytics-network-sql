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
	sum(coalesce(descuento,0)) as total_descuento,
	moneda
from
	stg.order_line_sale
where
	fecha
		between to_date('01-NOV-2022','DD-MON-YY')
			and to_date('30-NOV-2022','DD-MON-YY')
group by
	moneda

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

-- CLASE 3

--1 Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, mostrando la leyenda "Unknown" cuando no hay un color disponible
select
	nombre,
	codigo_producto,
	categoria,
	coalesce(color,'Unknown')
from
	stg.product_master
where
	lower(nombre) like '%philips%'
	or lower(nombre) like '%samsung%'
	
--2 Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.
select
	sum(venta) as total_ventas,
	sum(impuestos) as total_impuestos,
	moneda,
	pais,
	provincia
from
	stg.order_line_sale as ols
left join
	stg.store_master as ss
on
	ols.tienda = ss.codigo_tienda
group by
	pais,
	provincia,
	moneda
	
--3 Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria y moneda.
select
	subcategoria,
	sum(venta) as ventas,
	moneda
from
	stg.order_line_sale as ols
left join
	stg.product_master as pm
on
	ols.producto = pm.codigo_producto
group by
	subcategoria,
	moneda
order by
	subcategoria,
	moneda
	
--4 Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia; usar guion como separador y usarla para ordernar el resultado.
select
	subcategoria,
	sum(cantidad) as unidades_vendidas,
	concat(pais,' - ',provincia) as location
from
	stg.order_line_sale as ols
left join
	stg.product_master as pm
on
	ols.producto = pm.codigo_producto
left join
	stg.store_master as ss
on
	ols.tienda = ss.codigo_tienda
group by
	subcategoria,
	concat(pais,' - ',provincia)
order by
	concat(pais,' - ',provincia),
	sum(cantidad) desc

--5 Mostrar una vista donde sea vea el nombre de tienda y la cantidad de entradas de personas que hubo desde la fecha de apertura para el sistema "super_store".
select
	codigo_tienda,
	coalesce(sum(conteo),0) as total_entradas
from
	stg.store_master as sm
left join
	stg.super_store_count as ssc
on
	sm.codigo_tienda = ssc.tienda
group by
	codigo_tienda
order by
	total_entradas desc
	
--6 Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; mostrar el resultado con el nombre de la tienda.
select
	sm.nombre as nombre_tienda,
	extract(month from inv.fecha) as mes,
	inv.sku,
	round(avg(
			( coalesce(inv.inicial,0) + coalesce(inv.final,0) ) /2 
			)
		,2) as inventario_promedio
from
	stg.inventory as inv
left join
	stg.store_master as sm
on
	inv.tienda = sm.codigo_tienda
group by
	mes, -- existe información de sólo 1 mes
	sku,
	nombre_tienda
order by
	sku,
	inventario_promedio desc
	
--7 Calcular la cantidad de unidades vendidas por material. Para los productos que no tengan material usar 'Unknown', homogeneizar los textos si es necesario.
select
	coalesce(lower(pm.material),'Unknown') as tipo_material,
	sum(ol.cantidad) as cantidad_vendida
from
	stg.order_line_sale as ol
left join
	stg.product_master as pm
on
	ol.producto = pm.codigo_producto
group by
	tipo_material

--8 Mostrar la tabla order_line_sales agregando una columna que represente el valor de venta bruta en cada linea convertido a dolares usando la tabla de tipo de cambio.
select
	ols.*,
case
	when moneda = 'ARS' then round(venta/cotizacion_usd_peso,2)
	when moneda = 'EUR' then round(venta/cotizacion_usd_eur,2)
	when moneda = 'URU' then round(venta/cotizacion_usd_uru,2)
	end as venta_usd_conv
from
	stg.order_line_sale as ols
left join
	stg.monthly_average_fx_rate as mafr
on
	extract(month from ols.fecha) = extract(month from mafr.mes)

--9 Calcular cantidad de ventas totales de la empresa en dolares.
select
	sum(case
			when moneda = 'ARS' then round(venta/cotizacion_usd_peso,2)
			when moneda = 'EUR' then round(venta/cotizacion_usd_eur,2)
			when moneda = 'URU' then round(venta/cotizacion_usd_uru,2)
			end
		) as venta_usd_conv
from
	stg.order_line_sale as ols
left join
	stg.monthly_average_fx_rate as mafr
on
	extract(month from ols.fecha) = extract(month from mafr.mes)

--10 Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - promociones) - costo expresado en dolares.
select
	ols.*,
	case
		when moneda = 'ARS' then round( (ols.venta + coalesce(ols.descuento,0) )/cotizacion_usd_peso,2)
		when moneda = 'EUR' then round( (ols.venta + coalesce(ols.descuento,0) )/cotizacion_usd_eur,2)
		when moneda = 'URU' then round( (ols.venta + coalesce(ols.descuento,0) )/cotizacion_usd_uru,2)
		end as margen_usd_conv
from
	stg.order_line_sale as ols
left join
	stg.monthly_average_fx_rate as mafr
on
	extract(month from ols.fecha) = extract(month from mafr.mes)

--11 Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.
select
	ols.orden,
	count(distinct pm.subcategoria) as cant_items_x_subcategoria
from
	stg.order_line_sale as ols
left join
	stg.product_master as pm
on
	ols.producto = pm.codigo_producto
group by
	ols.orden

-- CLASE 4

--1 Crear un backup de la tabla product_master. Utilizar un esquema llamada "bkp" y agregar un prefijo al nombre de la tabla con la fecha del backup en forma de numero entero.
CREATE SCHEMA IF NOT EXISTS bkp

select
	*
into
	bkp.backup_20230408
from
	stg.product_master
--2 Hacer un update a la nueva tabla (creada en el punto anterior) de product_master agregando la leyendo "N/A" para los valores null de material y color. Pueden utilizarse dos sentencias.
update
	bkp.backup_20230408
set
	material = 'N/A' where material is null;

update
	bkp.backup_20230408
set
	color = 'N/A' where color is null
	
--3 Hacer un update a la tabla del punto anterior, actualizando la columa "is_active", desactivando todos los productos en la subsubcategoria "Control Remoto".
update
	bkp.backup_20230408
set
	is_active = false
where
	subsubcategoria = 'Control remoto'

--4 Agregar una nueva columna a la tabla anterior llamada "is_local" indicando los productos producidos en Argentina y fuera de Argentina.
alter table
	bkp.backup_20230408
add column
	is_local boolean default false;
	
update
	bkp.backup_20230408
set
	is_local = (origen = 'Argentina');

--5 Agregar una nueva columna a la tabla de ventas llamada "line_key" que resulte ser la concatenacion de el numero de orden y el codigo de producto.
select * into bkp.copy_ols from stg.order_line_sale;

alter table
	bkp.copy_ols
add column
	line_key varchar(255);

update
	bkp.copy_ols
set
	line_key = concat(orden, '-', producto);
	
--6 Eliminar todos los valores de la tabla "order_line_sale" para el POS 1.
delete from
	bkp.copy_ols
where
	pos = 1

--7 Crear una tabla llamada "employees" (por el momento vacia) que tenga
-- un id (creado de forma incremental),
-- nombre,
-- apellido,
-- fecha de entrada, fecha salida,
-- telefono, pais, provincia,
-- codigo_tienda, posicion.
-- Decidir cual es el tipo de dato mas acorde.
DROP TABLE IF EXISTS bkp.employees ;
    
CREATE TABLE bkp.employees
                 (
							id_employee		SERIAL PRIMARY KEY,
							nombre			VARCHAR(255) NOT NULL,
							apellido		VARCHAR(255) NOT NULL,
							fecha_entrada	date,
							fecha_salida	date null,
							telefono		VARCHAR(255) null,
							pais			VARCHAR(255) null,
							provincia		VARCHAR(255) null,
							codigo_tienda	int null,
							posicion		VARCHAR(255) null
				 );
--8 Insertar nuevos valores a la tabla "employees" para los siguientes 4 empleados:
-- Juan Perez, 2022-01-01, telefono +541113869867, Argentina, Santa Fe, tienda 2, Vendedor.
insert into
	bkp.employees (nombre, apellido, fecha_entrada, telefono, pais, provincia, codigo_tienda, posicion)
values
	(
		'Juan',
		'Perez',
		'2022-01-01',
		'+541113869867',
		'Argentina',
		'Santa Fe',
		2,
		'Vendedor'
	)
-- Catalina Garcia, 2022-03-01, Argentina, Buenos Aires, tienda 2, Representante Comercial
insert into
	bkp.employees (nombre, apellido, fecha_entrada, pais, provincia, codigo_tienda, posicion)
values
	(
		'Catalina',
		'Garcia',
		'2022-03-01',
		'Argentina',
		'Buenos Aires',
		2,
		'Representante Comercial'
	)
-- Ana Valdez, desde 2020-02-21 hasta 2022-03-01, España, Madrid, tienda 8, Jefe Logistica
insert into
	bkp.employees (nombre, apellido, fecha_entrada, fecha_salida, pais, provincia, codigo_tienda, posicion)
values
	(
		'Ana',
		'Valdez',
		'2020-02-21',
		'2022-03-01',
		'España',
		'Madrid',
		8,
		'Jefe Logistica'
	)
-- Fernando Moralez, 2022-04-04, España, Valencia, tienda 9, Vendedor.
insert into
	bkp.employees (nombre, apellido, fecha_entrada, pais, provincia, codigo_tienda, posicion)
values
	(
		'Fernando',
		'Moralez',
		'2022-04-04',
		'España',
		'Valencia',
		9,
		'Vendedor'
	)
--9 Crear un backup de la tabla "cost" agregandole una columna que se llame "last_updated_ts" que sea el momento exacto en el cual estemos realizando el backup en formato datetime.
select
	*,
	CURRENT_TIMESTAMP AS last_updated_ts
into
	bkp.copy_cost
from
	stg.cost

--10 El cambio en la tabla "order_line_sale" en el punto 6 fue un error y debemos volver la tabla a su estado original, como lo harias?
/*
Fui precabido y siempre trabajé sobre copias del original. Pero de pasó investigüé un poco con el amigo chatgpt

Si no tienes una tabla de respaldo de la tabla "order_line_sale", una opción es utilizar una transacción de base de datos para deshacer la eliminación de los datos. Esto requiere que la base de datos esté configurada para admitir transacciones.

Una transacción de base de datos es una serie de operaciones que se ejecutan como una unidad lógica e indivisible, lo que significa que todas las operaciones se completan con éxito o ninguna de ellas se completa. Puedes utilizar una transacción para deshacer la eliminación de datos que realizaste en el punto 6.

Para hacer esto, puedes utilizar la sentencia SQL "BEGIN" para iniciar la transacción, seguida de la sentencia SQL "ROLLBACK" para deshacer la eliminación de datos, y finalmente la sentencia SQL "COMMIT" para finalizar la transacción.

La transacción de base de datos se vería así:

sql
Copy code
BEGIN;
	INSERT INTO bkp.copy_ols (id_order, id_product, quantity, price, pos, sale_date)
	SELECT id_order, id_product, quantity, price, pos, sale_date
	FROM order_line_sale
	WHERE pos = 1;
ROLLBACK;
La sentencia SQL "BEGIN" inicia la transacción, y a continuación, la sentencia SQL "INSERT INTO ... SELECT" inserta en la tabla "bkp.copy_ols" los datos que se eliminaron de la tabla "order_line_sale" en el punto 6. Luego, la sentencia SQL "ROLLBACK" deshace la eliminación de datos y finalmente, la sentencia SQL "COMMIT" confirmaría la transacción, pero en este caso no es necesario porque estamos deshaciendo los cambios.

Es importante tener en cuenta que esta transacción deshará cualquier otro cambio que se haya realizado en la tabla "order_line_sale" desde el momento en que se eliminaron los datos hasta el momento en que se ejecute la transacción. Por lo tanto, debes tener cuidado al utilizar esta opción.
*/
