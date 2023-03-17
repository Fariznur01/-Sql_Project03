# Portofolio
# Sql 

<br>
<div align="center">
    <a href=""><img src="/Dqlab/Images/Sql.png" width="200" hegiht="200" alt="Sql" title="Optional title"></a>
</div>
<a name="readme-top"></a>
<br>

[![MySQL](https://img.shields.io/badge/MySQL-orange.svg)]()

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#dataset"> Dataset </a></li> 
    <li><a href="#analisis">Analisis SQL</a></li>
    <li><a href="#author">Author</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project
Project mini ini merupakan salah satu modul project-based DQLab Academy. Analisis pada project ini akan dilakukan menggunakan SQL dengan MySQL dan pentaho.
<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Dataset
Dataset:  https://drive.google.com/drive/folders/11Zyo6dIiStWyQF543lylvTUqWR8pPCWi?usp=sharing

Dataset yang digunakan merupakan data dummy dari DQLab Store yang merupakan e-commerce.

![Erd](https://user-images.githubusercontent.com/87837561/225866825-d557d867-3f02-4014-9ca7-db7128b22321.png)

![Screenshot (166)](https://user-images.githubusercontent.com/87837561/225867786-67ead0eb-a9c4-4936-947b-c7d0332b8e74.png)

![Screenshot (167)](https://user-images.githubusercontent.com/87837561/225867809-91aa10bb-1977-4d82-b28b-ed776689f6e7.png)


* Tabel Data fk_user
* Tabel Data fk_orders_details
* Tabel Data fk_orders_details2
* Tabel Data fk_order_detail
* Tabel Data fk_order_product

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Analisis SQL

```sql

#Menghitung rata-rata lama waktu dari transaksi dibuat sampai dibayar dan  dikelompokkan per bulan
SELECT EXTRACT(YEAR_MONTH FROM created_at) AS tahun_bulan, count(1) AS jumlah_transaksi,  AVG(DATEDIFF(paid_at, created_at)) AS avg_lama_dibayar, min(DATEDIFF(paid_at, created_at)) min_lama_dibayar, max(DATEDIFF(paid_at, created_at)) max_lama_dibayar
FROM dqlab.order_details2
WHERE paid_at IS NOT NULL
GROUP BY 1 ORDER BY 1;

#Mencari penjual yang juga pernah bertransaksi sebagai pembeli minimal 7 kali
SELECT
 nama_user AS nama_pengguna,
 jumlah_transaksi_beli,
 jumlah_transaksi_jual
FROM
 dqlab.fk_user a
INNER JOIN
 (
  SELECT buyer_id, count(1) AS jumlah_transaksi_beli
  FROM dqlab.fk_order_details2 b
  GROUP BY 1
 ) AS buyer
 ON buyer_id = user_id
INNER JOIN
 (
  SELECT seller_id, count(1) AS jumlah_transaksi_jual
  FROM dqlab.fk_order_details2
  GROUP BY 1
 ) AS seller
 ON seller_id = user_id
WHERE  jumlah_transaksi_beli >= 7
ORDER BY 1;

#Mencari pembeli yang punya 8 tau lebih transaksi yang alamat pengiriman transaksi sama dengan alamat pengiriman utama, dan rata-rata total quantity per transaksi lebih dari 10
SELECT nama_user AS nama_pembeli, count(1) AS jumlah_transaksi, sum(total) AS total_nilai_transaksi, avg(total) AS avg_nilai_transaksi, avg(total_quantity) AS avg_quantity_per_transaksi
FROM dqlab.fk_order_details2 a
INNER JOIN dqlab.fk_user b
ON buyer_id = user_id
INNER JOIN
 (
  SELECT order_id, sum(quantity) AS total_quantity
  FROM dqlab.fk_order_detail
  GROUP BY 1
 ) AS summary_order
 USING(order_id)
WHERE a.kodepos = b.kodepos
GROUP BY user_id, nama_user
HAVING count(1) >= 8 AND avg(total_quantity) > 10
ORDER BY 3 DESC;
 
#Mencari pembeli dengan 10 kali transaksi atau lebih yang alamat pengiriman transaksi selalu berbeda setiap transaksi
SELECT nama_user AS nama_pembeli, count(1) AS jumlah_transaksi, count(DISTINCT a.kodepos) AS distinct_kodepos, sum(total) AS total_nilai_transaksi,avg(total) AS avg_nilai_transaksi
FROM dqlab.fk_order_details2 a
INNER JOIN dqlab.fk_user
ON buyer_id = user_id
GROUP BY user_id, nama_user
HAVING count(1) >= 10 AND count(1) = count(DISTINCT a.kodepos)
ORDER BY 2 DESC;

#Pembeli yang sudah bertransaksi lebih dari 5 kali, dan setiap transaksi lebih dari 2,000,000
SELECT nama_user AS nama_pembeli, count(1) AS jumlah_transaksi, sum(total) AS total_nilai_transaksi, min(total) AS min_nilai_transaksi 
FROM dqlab.fk_order_details2
INNER JOIN dqlab.fk_user
ON buyer_id = user_id
GROUP BY 1,user_id
HAVING count(1) > 5 AND min(total) > 2000000 
ORDER BY  3 DESC;

#Kategori Produk Terlaris di 2020
SELECT category, sum(quantity) AS total_quantity, sum(price) AS total_price
FROM dqlab.fk_order_detail
INNER JOIN dqlab.fk_order_details2
 USING(order_id)
INNER JOIN dqlab.fk_product
 USING(product_id)
WHERE created_at >= '2020-01-01' AND delivery_at IS NOT NULL
GROUP BY 1 ORDER BY 2 DESC LIMIT 5;

#Transaksi besar di Desember 2019
SELECT nama_user AS nama_pembeli, total AS nilai_transaksi, created_at AS tanggal_transaksi
FROM dqlab.fk_order_details2
INNER JOIN dqlab.fk_user
ON buyer_id = user_id
WHERE created_at >= '2019-12-01' AND created_at < '2020-01-01' AND total >= 20000000
ORDER BY 1;

#Pengguna dengan rata-rata transaksi terbesar di Januari 2020
SELECT buyer_id, count(1) AS jumlah_transaksi, avg(total) AS avg_nilai_transaksi
FROM dqlab.fk_order_details2
WHERE  created_at >= '2020-01-01' AND created_at < '2020-02-01'
GROUP BY 1 HAVING count(1) >=  2 
ORDER BY 3 DESC LIMIT 10;

#Transaksi per bulan di tahun 2020  
SELECT EXTRACT(YEAR_MONTH FROM created_at) AS tahun_bulan, count(1) AS jumlah_transaksi, sum(total) AS total_nilai_transaksi
FROM dqlab.fk_order_details2
WHERE created_at >= '2020-01-01'
GROUP BY 1 ORDER BY 1;

#10 Transaksi terbesar seorang user 12476
SELECT seller_id, buyer_id,total  AS jumlah_transaksi, created_at AS tanggal_transaksi
FROM dqlab.fk_order_details2
WHERE buyer_id = 12476
ORDER BY  3 DESC LIMIT 10;

/*
Dari daftar nama produk berikut ini, manakah yang merupakan top 5 produk yang dibeli di bulan desember 2019 berdasarkan total quantity
*/

SELECT sum(quantity) AS total_quantity, desc_product
FROM dqlab.fk_order_detail od
JOIN dqlab.fk_product p
ON od.product_id = p.product_id
JOIN dqlab.fk_order_details2 o
ON od.order_id = o.order_id
WHERE created_at BETWEEN '2019-12-01' AND '2019-12-31'
GROUP BY 2
ORDER BY 1 DESC LIMIT 5;

/*
Dari daftar domain berikut, manakah yang merupakan domain email dari penjual di DQLab Store
*/
SELECT DISTINCT substr(email, instr(email, '@') + 1) AS domain_email, count(user_id) AS jumlah_pengguna_seller
FROM dqlab.fk_user
WHERE user_id IN
 (
  SELECT seller_id FROM dqlab.fk_order_details2
 )
GROUP BY 1
ORDER BY 2 DESC;

/*
Dari daftar email pengguna berikut ini, 
mana saja pengguna yang bertransaksi setidaknya 1 kali setiap bulan di tahun 2020 
dengan rata-rata total amount per transaksi lebih dari 1 Juta
*/

SELECT buyer_id, email, rata_rata, month_count
FROM
(
 SELECT trx.buyer_id,rata_rata,jumlah_order,month_count
 FROM
  (
   SELECT buyer_id,round(avg(total),2) AS rata_rata
   FROM
    dqlab.fk_order_details2
   WHERE DATE_FORMAT(created_at, '%Y') = '2020'
   GROUP BY 1
   HAVING rata_rata > 1000000
   ORDER BY 1
  ) AS trx
 JOIN
  (
   SELECT buyer_id, count(order_id) AS jumlah_order, count(DISTINCT DATE_FORMAT(created_at, '%m')) AS month_count
   FROM
	dqlab.fk_order_details2
   WHERE DATE_FORMAT(created_at, '%Y') = '2020'
   GROUP BY 1
   HAVING month_count >= 5 AND jumlah_order >= month_count
   ORDER BY 1
  ) AS months
  ON trx.buyer_id = months.buyer_id
) AS bfq
JOIN dqlab.fk_user
ON buyer_id = user_id;

/*
Dari daftar nama pengguna berikut ini, mana saja pengguna yang tidak pernah menggunakan diskon ketika membeli barang dan merupakan 5 pembeli dengan transaksi terbanyak
*/

SELECT a.nama_user,b.buyer_id, b.discount, COUNT(b.order_id) as total,count(4) AS total
FROM dqlab.fk_user as a 
INNER JOIN  dqlab.fk_order_details2 as b
ON a.user_id = b.buyer_id # selain penjual
WHERE discount = 0
GROUP BY 2,1
ORDER BY 4 DESC LIMIT 5;

SELECT buyer_id, nama_user, count(order_id) AS jumlah_transaksi
FROM dqlab.fk_order_details2 o
JOIN dqlab.fk_user u
ON o.buyer_id = u.user_id
WHERE  discount = 0 
GROUP BY 1,2 ORDER BY 3 DESC, 2 LIMIT 5;

#Customer dengan pembelian terbanyak
SELECT a.nama_user,b.buyer_id, SUM(b.total) as total
FROM dqlab.fk_user as a 
INNER JOIN  dqlab.fk_order_details2 as b
ON a.user_id = b.buyer_id # selain penjual
GROUP BY 1,2
ORDER BY 3 DESC LIMIT 5;

SELECT buyer_id, nama_user, sum(total) AS total_transaksi
FROM dqlab.fk_order_details2 o 
JOIN dqlab.fk_user u
ON o.buyer_id = u.user_id
GROUP BY 1,2
ORDER BY 3 DESC LIMIT 5;

#Cek Total Pembeli 
SELECT count(distinct buyer_id) FROM dqlab.order_details2;

SELECT count(distinct buyer_id) FROM dqlab.order_details2
WHERE buyer_id NOT IN (SELECT seller_id FROM dqlab.fk_order_details2);

#Cek Total Penjual
SELECT count(distinct seller_id) FROM dqlab.order_details2;

SELECT count(DISTINCT seller_id) AS buyer_and_seller 
FROM dqlab.fk_order_details2
WHERE seller_id IN (SELECT buyer_id FROM  dqlab.fk_order_details2);

#Cek Transaksi Pembayaran Belum Dibayar
SELECT COUNT(paid_at) 
FROM dqlab.order_details2
WHERE paid_at = 'NA';

#Cek Pengiriman Belum Terkirim
SELECT COUNT(delivery_at) AS belum_terkirim
FROM dqlab.order_details2
WHERE delivery_at = 'NA';

#Cek transaksi dengan bulan 1,3,5,9,11
# pait_at bulan - tanggal - tahun
SELECT  COUNT(buyer_id),month(created_at) as month, year(created_at) as year
FROM dqlab.order_details2
WHERE month(created_at) = 1 or month(created_at) = 9 or month(created_at) = 3 
OR month(created_at) = 5  or month(created_at) = 11 
group by 2,3
order by 1 DESC;

#Cek jenis kategori
SELECT distinct(category) FROM dqlab.fk_product;
SELECT count(distinct(category)) AS jumlah_kategori FROM dqlab.fk_product;

#Cek Nilai Null 
SELECT * FROM dqlab.fk_product
WHERE product_id or desc_product or category or base_price IS NULL;

#Cek Nilai Null 
SELECT COUNT(DISTINCT order_id) FROM dqlab.fk_order_details2 ;

SELECT COUNT(DISTINCT order_id) FROM dqlab.fk_order_details2 
WHERE paid_at or delivery_at IS NULL;

SELECT order_id, paid_at, delivery_at FROM dqlab.order_details2
WHERE paid_at = 'NA' or delivery_at = 'NA' or created_at = NULL;

```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- AUTHOR -->
## Author

* **Fariz Nurfadillah** 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

