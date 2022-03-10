CREATE DATABASE QLBanHang
GO 

USE QLBanHang
GO

CREATE TABLE CUSTOMERS(
	MaKH VARCHAR(10) NOT NULL PRIMARY KEY,
	HoTen NVARCHAR(50),
	Email VARCHAR(50),
	Phone VARCHAR(30),
	DiaChi NVARCHAR(255)
)
GO

CREATE TABLE PRODUCTS(
	MaSP VARCHAR(10) NOT NULL PRIMARY KEY,
	TenSP NVARCHAR(50),
	MoTa NVARCHAR(255),
	GiaSP float,
	SoLuong INT
)
GO

CREATE TABLE ORDER_DETAIL(
	MaHD_De_id VARCHAR(10) NOT NULL,
	MaHD VARCHAR(10) NOT NULL,--khoá ngoại
	MaSP VARCHAR(10) NOT NULL,--khoá ngoại
	SLuongSPM INT,
	ThanhTien float,
	PRIMARY KEY(MaHD_De_id, MaHD, MaSP)
)
GO

CREATE TABLE PAYMENTSS(
	MaPTTT VARCHAR(10) NOT NULL PRIMARY KEY,
	TenPTTT NVARCHAR(50),
	PhiPTTT INT
)
GO

CREATE TABLE ORDERS(
	MaHD VARCHAR(10) NOT NULL primary key,
	MaKH VARCHAR(10) NOT NULL,--khoá ngoại
	NgayDH DATE,
	TrangThaiDH NVARCHAR(255),
	TongTien float,
	MaPTTT VARCHAR(10) NOT NULL --khóa ngoại
)
GO

-- liên kết khoá ngoại
	ALTER TABLE dbo.ORDER_DETAIL ADD FOREIGN KEY(MaSP) REFERENCES dbo.PRODUCTS(MaSP);
	ALTER TABLE dbo.ORDER_DETAIL ADD FOREIGN KEY(MaHD) REFERENCES dbo.ORDERS(MaHD);
	ALTER TABLE dbo.ORDERS ADD FOREIGN KEY(MaKH) REFERENCES dbo.CUSTOMERS(MaKH);
	ALTER TABLE dbo.ORDERS ADD FOREIGN KEY(MaPTTT) REFERENCES dbo.PAYMENTSS(MaPTTT);

--Nhập dữ liệu
INSERT INTO CUSTOMERS (MaKH,HoTen,Email,Phone,DiaChi)
VALUES ('KH001','Nguyen Thi Uyen','uyenn@gmail.com','0397695379','Da Nang')
INSERT INTO CUSTOMERS (MaKH,HoTen,Email,Phone,DiaChi)
VALUES ('KH002','Tran Thi Thuy','thuy@gmail.com','0394758299','Da Nang')
SELECT * FROM CUSTOMERS

INSERT INTO PRODUCTS (MaSP,TenSP,MoTa,GiaSP,SoLuong)
VALUES ('SP001','Banh my','Banh my thit cha',15,10)
INSERT INTO PRODUCTS (MaSP,TenSP,MoTa,GiaSP,SoLuong)
VALUES ('SP002','Mi tron cung dinh (ly)','Mi tron an lien',12,24)
SELECT * FROM PRODUCTS

INSERT INTO ORDER_DETAIL (MaHD_De_id,MaHD,MaSP,SLuongSPM,ThanhTien)
VALUES ('001','HD001','SP002',2,24)
SELECT * FROM ORDER_DETAIL

INSERT INTO PAYMENTSS (MaPTTT,TenPTTT,PhiPTTT)
VALUES ('PTTT01','Thanh toan khi nhan hang',0)
INSERT INTO PAYMENTSS (MaPTTT,TenPTTT,PhiPTTT)
VALUES ('PTTT02','Thanh toan qua Internet Banking',0)
SELECT * FROM PAYMENTSS

INSERT INTO ORDERS (MaHD,MaKH,NgayDH,TrangThaiDH,TongTien,MaPTTT)
VALUES ('HD001','KH001','2022-01-12','Thanh cong',12,'PTTT01')
INSERT INTO ORDERS (MaHD,MaKH,NgayDH,TrangThaiDH,TongTien,MaPTTT)
VALUES ('HD002','KH002','2022-01-29','Thanh cong',15,'PTTT02')
SELECT * FROM ORDERS


  --nâng cao 1 :tìm thông tin của những khách hàng có đơn hàng lớn hơn 10.000d và đặt hàng trước 8-3-2022
  select * from CUSTOMERS join ORDERS
  on CUSTOMERS.MaKH = ORDERS.MaKH
  where TongTien > 10000 and NgayDH < '2022-3-8'
  go
   --nâng cao 2 :tìm những đơn hàng có phí thanh toán lớn hơn 10.000d 
  select * from ORDERS join PAYMENTSS
  on ORDERS.MaPTTT = PAYMENTSS.MaPTTT
  where PhiPTTT > 10000
  go

  --view 1: Tạo 1 khung nhìn hiển thị thông tin SP có SL từ 20 trở lên và thanh tiền > 15.000
 CREATE VIEW V_thongTinSP
 AS
	SELECT p.TenSP, p.MoTa, p.SoLuong, o.ThanhTien	FROM dbo.PRODUCTS p
	JOIN dbo.ORDER_DETAIL o
	ON o.MaSP = p.MaSP
	WHERE p.SoLuong > 20 AND o.ThanhTien > 15000

SELECT * FROM V_thongTinSP

 
--view 2: Tạo 1 khung nhìn hiển thị thông tin KH bao gồm cả thông tin hóa đơn của KH đó.
CREATE VIEW V_thongTinKH
AS
	SELECT c.MaKH, c.HoTen, c.Email, c.Phone, c.DiaChi, o.MaDH, o.NgayDH, o.TongTien, o.TrangThaiDH FROM dbo.CUSTOMERS c
	JOIN dbo.ORDERS o
	ON o.MaKH = c.MaKH

	SELECT *FROM V_thongTinKH

--view 3: Tạo 1 khung hình hiển thị thông tin các đơn đặt hàng trong năm nay
CREATE VIEW V_thongTinDH
AS
	SELECT  DISTINCT c.MaKH, c.HoTen, od.maDH, od.NgayDH, od.TongTien, od.TrangThaiDH	
	FROM dbo.CUSTOMERS c 
		JOIN dbo.ORDERS od ON od.MaKH = c.MaKH
		JOIN dbo.ORDER_DETAIL ON ORDER_DETAIL.MaHD = od.MaDH
	WHERE YEAR(od.NgayDH) = YEAR(GETDATE())

SELECT * FROM V_thongTinDH

--view 4: Tạo View có tổng số lượng sp được mua lớn hơn 26 
CREATE VIEW DonHangCuaHang AS
SELECT p.MaSP, TenSP, SUM(SLuongSPM) AS TongSoLuong FROM PRODUCTS p
LEFT OUTER JOIN ORDER_DETAIL d ON p.MaSP = d.MaSP  
GROUP BY p.MaSP, TenSP
HAVING SUM(SLuongSPM) > 26
GO

SELECT * FROM DonHangCuaHang 

--view 5: Tạo View có khách hàng thanh toán bằng phương thức Internet Banking 
CREATE VIEW Phuongthucthanhtoan AS
SELECT p.MaKH, c.HoTen, c.DiaChi FROM ORDERS p
LEFT OUTER JOIN PAYMENTSS m ON p.MaPTTT = m.MaPTTT
LEFT OUTER JOIN CUSTOMERS c ON p.MaKH = c.MaKH
WHERE TenPTTT LIKE 'Thanh toan qua Internet Banking'
GO

SELECT * FROM Phuongthucthanhtoan 

   --. Function; multi-statement table-valued: 
--Tạo một hàm vô hướng để tính điểm thưởng theo ràng buộc dưới đây:
--	Nếu tổng số tiền khách hàng đã trả cho tất cả các lần mua hàng dưới 2.000.000, thì trả về kết quả là khách hàng được nhận 20 điểm thưởng.
--	Nếu tổng số tiền khách hàng đã trả cho tất cả các lần mua hàng từ 2.000.000 trở đi, thì trả về kết quả là khách hàng được nhận 50 điểm thưởng.
--Sử dụng hàm vô hướng này trong cấu trúc điều kiện để liệt kê thông tin sau đây: mã khách hàng, tên khách hàng, tổng tiền cho đơn hàng, điểm thưởng của khách hàng cho 100 đơn hàng có tổng số tiền lớn nhất và trên mức-tối-thiểu. mức-tối-thiểu được nhập theo tham số của hàm.


-- hàm tính điểm thưởng 
create  function funct_tinh_diem_thuong(@makh nvarchar(225))
  returns int
  as
  begin
 ---
 declare @diemthuong int ,@tongtien money

 select  @tongtien = sum(TongTien) from ORDERS
 where MaKH = @makh



 if @tongtien < 2000000
  set @diemthuong = 20
 else
  set @diemthuong = 40


 return @diemthuong
 	    

  end

  -- hàm lọc các khách hàng có tổng tiền cao hơn mức tối thiểu
create   function funct_Liet_Ke(@muctoithieu int)
  returns table
  as

   
 return ( select  distinct kh.MaKH,kh.HoTen,sum(TongTien) as tổngtiền,(select dbo.funct_tinh_diem_thuong(kh.MaKH) ) as điểmthưởng   from   CUSTOMERS  kh  inner join ORDERS  dh on kh.MaKH = dh.MaKH
     group by kh.MaKH,kh.HoTen
	  having sum(TongTien) > @muctoithieu) 
	  	 
 	    

  go

 -- function 2:
 --Func getProductbyId: hiển thị tên sản phẩm với mã sản phẩm là tham số.
 CREATE FUNCTION getProductbyId (@id NVARCHAR(10)) RETURNS NVARCHAR(255) AS
BEGIN
	DECLARE @result NVARCHAR(255);

	IF NOT EXISTS (SELECT * FROM PRODUCTS WHERE MaSP = @id)
	BEGIN
			SET @result = 'Khong ton tai ma san pham nay'
	END
	ELSE 
	BEGIN
			SELECT @result = TenSP FROM PRODUCTS WHERE MaSP = @id
	END
	RETURN @result;
END;
GO

SELECT dbo.getProductbyId(N'SP001')
GO

SELECT dbo.getProductbyId(N'SP003')
GO
---Func bestSeller: sản phẩm bán được nhiều nhất.

CREATE FUNCTION bestSeller() RETURNS TABLE RETURN
	SELECT top 1 p.MaSP, TenSP, SUM(SLuongSPM) AS TongSLMua FROM PRODUCTS p
	LEFT OUTER JOIN ORDER_DETAIL od
	ON p.MaSP = od.MaSP
	GROUP BY p.MaSP, TenSP
	ORDER BY SUM(SLuongSPM) desc;
GO

SELECT * FROM bestSeller()
GO


  --Stored Procedure: Thực hiện thêm mới 01 bản ghi vào bảng ORDER DETAIL thoả mãn các điều kiện số
--lượng sản phẩm mua phải lớn hơn 0, tính thành tiền bằng số lượng mua/bán nhân với giá sản phẩm, mã
--đơn hàng phải có trong bảng ORDER, cập nhật giảm tương ứng số lượng sản phẩm trong bảng PRODUCT.
CREATE PROC Pro_N3
 	@MaHD_De_id VARCHAR(10),
	@MaHD VARCHAR(10),
	@MaSP VARCHAR(10),
	@SLuongSPM INT,
	@ThanhTien FLOAT
AS
BEGIN
    IF @SLuongSPM > 0 AND EXISTS (SELECT MaHD FROM ORDERS WHERE MaHD = @MaHD)
	   BEGIN
          INSERT INTO ORDER_DETAIL
          VALUES(@MaHD_De_id,@MaHD,@MaSP,@SLuongSPM,@ThanhTien)

	      UPDATE ORDER_DETAIL
	      SET ThanhTien = SLuongSPM * (SELECT GiaSP FROM PRODUCTS WHERE MaSP = ORDER_DETAIL.MaSP)

	      UPDATE PRODUCTS
	      SET SoLuong = SoLuong - @SLuongSPM
       END
    ELSE 
       BEGIN 
          ROLLBACK TRANSACTION
	      PRINT N'số lượng và tổng thành tiền nhỏ hơn hoặc bằng 0'
       END
END
--
EXEC Pro_N3 '004', 'HD002', 'SP001',2,30
SELECT * FROM PRODUCTS
SELECT * FROM ORDER_DETAIL

--tong so tien ban dc vs 1 mat hang
create proc Totalprice
		@MaSP  VARCHAR(10)
AS
	Begin
		DECLARE @tongtien float
		select @tongtien = sum(ct.SLuongSPM *sp.GiaSP) from PRODUCTS sp join ORDER_DETAIL ct on sp.MaSP=ct.MaSP
		where @MaSP = sp.MaSP

		DECLARE @sanpham nvarchar(50)
		select @sanpham = TenSP from PRODUCTS where @MaSP = MaSP

		PRINT N'Tổng số tiền thu được khi bán sản phẩm ' + @sanpham +':' +str(@tongtien)

	End


EXECUTE Totalprice @MaSP = 'SP002'


