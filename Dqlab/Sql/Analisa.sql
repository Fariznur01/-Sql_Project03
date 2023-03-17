#Menghitung rata-rata lama waktu dari transaksi dibuat sampai dibayar, dikelompokkan per bulan
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
Dari daftar nama produk berikut ini, 
manakah yang merupakan top 5 produk yang dibeli di bulan desember 2019 
berdasarkan total quantity
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
2550	QUEEN CEFA BRACELET LEATHER 
1423	SHEW SKIRTS BREE 
1323	ANNA FAITH LEGGING GLOSSY 
1242	Cdr Vitamin C 10'S 
1186	RIDER CELANA DEWASA SPANDEX ANTI BAKTERI R325BW 
*/

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
 
#gmail.com	16
#hotmail.com	14
#yahoo.com	5
#pd.go.id	3
#pt.net.id	3
#perum.edu	2
#cv.mil	2
#cv.web.id	2
#ud.net.id	2
#ud.edu	2
#ud.id	2
#pt.mil.id	1
#pd.ac.id	1
#perum.int	1
#pd.web.id	1
#cv.id	1
#pd.net	1
#perum.mil	1
#pt.gov	1
#ud.go.id	1
#cv.co.id	1
#pd.mil.id	1
#pd.org	1
#ud.net	1
#pd.my.id	1
#perum.mil.id	1
#pd.sch.id	1 

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

# 302	pharyanto@perum.or.id	3406400.00	5
#1270	artawannashiruddin@gmail.com	2386900.00	5
#1403	taswirprabowo@ud.mil.id	2341200.00	5
#1952	maras02@hotmail.com	1187000.00	5
#2112	hsaefullah@yahoo.com	1827400.00	5
#2424	maryadiviolet@ud.mil.id	5639880.00	5
#2512	iswahyudiprabawa@gmail.com	1663080.00	5
#3185	bzulkarnain@yahoo.com	5310480.00	5
#3965	asmanfirgantoro@cv.org	1967966.67	5
#4660	sakapalastri@pd.gov	1890800.00	5
#4808	wastutigenta@perum.desa.id	2256333.33	5
#5061	xsetiawan@hotmail.com	2800700.00	5
#5620	namagaargono@hotmail.com	3934000.00	5
#5966	ibrahimsaputra@ud.mil.id	2157000.00	5
#5973	hwinarsih@yahoo.com	2308200.00	5
#6231	skusmawati@hotmail.com	1278480.00	5
#6251	tfirgantoro@ud.gov	3520520.00	5
#7905	riyantialika@gmail.com	4315333.33	5
#8172	ganepusada@gmail.com	3923000.00	5
#38705	wasitabajragin@yahoo.com	1581200.00	5
#9027	hasna57@yahoo.com	2473833.33	5
#9030	chelseasaputra@ud.mil	1851000.00	5
#9694	owinarsih@yahoo.com	1963833.33	5
#9898	dananguyainah@cv.desa.id	3448666.67	5
#10088	latuponojais@perum.gov	1167750.00	5
#10569	karmanpurnawati@hotmail.com	2421891.67	5
#11094	mpermadi@hotmail.com	2675320.00	5
#11195	fnainggolan@hotmail.com	5867500.00	5
#11998	dyulianti@gmail.com	4900920.00	5
#12011	kuswoyobakda@gmail.com	3852883.33	5
#12381	lukmanjailani@yahoo.com	2814033.33	5
#12716	tedi40@gmail.com	3974080.00	5
#12813	ida51@ud.net	1723700.00	5
#13973	amiwibisono@cv.my.id	4961416.67	5
#14080	setyawaluyo@hotmail.com	1123800.00	5
#14652	nilampurnawati@hotmail.com	2060600.00	5
#15467	megantaraajiono@cv.org	2171000.00	5
#15674	luluh59@hotmail.com	3520140.00	5

/*
Dari daftar nama pengguna berikut ini, mana saja pengguna yang tidak pernah menggunakan 
diskon ketika membeli barang dan merupakan 5 pembeli dengan transaksi terbanyak
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

/*
'12476', 'Yessi Wibisono', '13'
'10977', 'Drs. Pandu Mansur, M.TI.', '12'
'12577', 'Umay Latupono', '12'
'9260', 'Bakiono Zulaika', '11'
'5620', 'Cakrawangsa Habibi', '11'
*/


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
/* 
'14411', 'Jaga Puspasari', '54102250'
'11140', 'R.A. Yulia Padmasari, S.I.Kom', '52743200'
'15915', 'Sutan Agus Ardianto, S.Kom', '49141800'
'2908', 'Septi Melani, S.Ked', '49033000'
'10355', 'Kartika Habibi', '48868000'
*/

#Cek Total Pembeli 
SELECT count(distinct buyer_id) FROM dqlab.order_details2;
#Ada 17,877 total pembeli maupun penjual

SELECT count(distinct buyer_id) FROM dqlab.order_details2
WHERE buyer_id NOT IN (SELECT seller_id FROM dqlab.fk_order_details2);
#Ada 17808 total pembeli tanpa penjual

#Cek Total Penjual
SELECT count(distinct seller_id) FROM dqlab.order_details2;
#Ada 69 total penjual

SELECT count(DISTINCT seller_id) AS buyer_and_seller 
FROM dqlab.fk_order_details2
WHERE seller_id IN (SELECT buyer_id FROM  dqlab.fk_order_details2);
#Ada 69 total penjual melakukan pembelian

#Cek Transaksi Pembayaran Belum Dibayar
SELECT COUNT(paid_at) 
FROM dqlab.order_details2
WHERE paid_at = 'NA';
#Ada 5,046 transaksi yang tidak dibayar

#Cek Pengiriman Belum Terkirim
SELECT COUNT(delivery_at) AS belum_terkirim
FROM dqlab.order_details2
WHERE delivery_at = 'NA';
#Ada total 9,790 transaksi belum dikirim

#Cek transaksi dengan bulan 1,3,5,9,11
# pait_at bulan - tanggal - tahun
SELECT  COUNT(buyer_id),month(created_at) as month, year(created_at) as year
FROM dqlab.order_details2
WHERE month(created_at) = 1 or month(created_at) = 9 or month(created_at) = 3 
OR month(created_at) = 5  or month(created_at) = 11 
group by 2,3
order by 1 DESC;
/*
buyer_id bulan tahun
10026	5	2020
7323	3	2020
7162	11	2019
5062	1	2020
4327	9	2019
1462	5	2019
668	3	2019
117	1	2019
*/

#Cek jenis kategori
SELECT distinct(category) FROM dqlab.fk_product;
SELECT count(distinct(category)) AS jumlah_kategori FROM dqlab.fk_product;

#Cek Nilai Null 
SELECT * FROM dqlab.fk_product
WHERE product_id or desc_product or category or base_price IS NULL;
#Total ada 1145 bari tidak kosong

#Cek Nilai Null 
SELECT COUNT(DISTINCT order_id) FROM dqlab.fk_order_details2 ;
#Total seluruh baris 74874

SELECT COUNT(DISTINCT order_id) FROM dqlab.fk_order_details2 
WHERE paid_at or delivery_at IS NULL;
#Total baris tidak kosong 69828

SELECT order_id, paid_at, delivery_at FROM dqlab.order_details2
WHERE paid_at = 'NA' or delivery_at = 'NA' or created_at = NULL;
#total 9790 kosong


