-- =============================================
-- BanGiayDB - Database Schema + Seed idempotent
-- Chạy nhiều lần không bị x2 dữ liệu
-- =============================================

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF DB_ID(N'BanGiayDB') IS NULL
BEGIN
    CREATE DATABASE [BanGiayDB];
END
GO

USE [BanGiayDB]
GO

IF OBJECT_ID(N'dbo.ChiTietDonHang', N'U') IS NOT NULL DROP TABLE dbo.ChiTietDonHang;
IF OBJECT_ID(N'dbo.DonHang', N'U') IS NOT NULL DROP TABLE dbo.DonHang;
IF OBJECT_ID(N'dbo.GioHang', N'U') IS NOT NULL DROP TABLE dbo.GioHang;
IF OBJECT_ID(N'dbo.KichCo', N'U') IS NOT NULL DROP TABLE dbo.KichCo;
IF OBJECT_ID(N'dbo.SanPham', N'U') IS NOT NULL DROP TABLE dbo.SanPham;
IF OBJECT_ID(N'dbo.DanhMuc', N'U') IS NOT NULL DROP TABLE dbo.DanhMuc;
IF OBJECT_ID(N'dbo.NguoiDung', N'U') IS NOT NULL DROP TABLE dbo.NguoiDung;
GO

CREATE TABLE [dbo].[DanhMuc] (
    [DanhMucID]   INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [TenDanhMuc]  NVARCHAR(100) NOT NULL,
    [MoTa]        NVARCHAR(255) NULL,
    [TrangThai]   BIT           NOT NULL DEFAULT 1,
    [NgayTao]     DATETIME      NOT NULL DEFAULT GETDATE()
)
GO

CREATE TABLE [dbo].[SanPham] (
    [SanPhamID]    INT            IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [DanhMucID]    INT            NOT NULL,
    [TenSanPham]   NVARCHAR(200)  NOT NULL,
    [MoTa]         NVARCHAR(MAX)  NULL,
    [Gia]          DECIMAL(18,0)  NOT NULL,
    [GiaKhuyenMai] DECIMAL(18,0)  NULL,
    [HinhAnh]      NVARCHAR(255)  NULL,
    [ThuongHieu]   NVARCHAR(100)  NULL,
    [SoLuongTon]   INT            NOT NULL DEFAULT 0,
    [TrangThai]    BIT            NOT NULL DEFAULT 1,
    [NgayTao]      DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_SanPham_DanhMuc FOREIGN KEY ([DanhMucID]) REFERENCES [DanhMuc]([DanhMucID]) ON UPDATE CASCADE
)
GO

CREATE TABLE [dbo].[KichCo] (
    [KichCoID]   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [SanPhamID]  INT NOT NULL,
    [Size]       NVARCHAR(10) NOT NULL,
    [SoLuong]    INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_KichCo_SanPham FOREIGN KEY ([SanPhamID]) REFERENCES [SanPham]([SanPhamID]) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

CREATE TABLE [dbo].[NguoiDung] (
    [NguoiDungID] INT            IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [HoTen]       NVARCHAR(150)  NOT NULL,
    [Email]       NVARCHAR(150)  NOT NULL UNIQUE,
    [MatKhau]     NVARCHAR(255)  NOT NULL,
    [SoDienThoai] NVARCHAR(20)   NULL,
    [DiaChi]      NVARCHAR(300)  NULL,
    [VaiTro]      NVARCHAR(20)   NOT NULL DEFAULT N'KhachHang',
    [TrangThai]   BIT            NOT NULL DEFAULT 1,
    [NgayTao]     DATETIME       NOT NULL DEFAULT GETDATE()
)
GO

CREATE TABLE [dbo].[GioHang] (
    [GioHangID]   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [NguoiDungID] INT NOT NULL,
    [SanPhamID]   INT NOT NULL,
    [KichCoID]    INT NULL,
    [SoLuong]     INT NOT NULL DEFAULT 1,
    [NgayThem]    DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_GioHang_NguoiDung FOREIGN KEY ([NguoiDungID]) REFERENCES [NguoiDung]([NguoiDungID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_GioHang_SanPham FOREIGN KEY ([SanPhamID]) REFERENCES [SanPham]([SanPhamID]) ON UPDATE CASCADE,
    CONSTRAINT FK_GioHang_KichCo FOREIGN KEY ([KichCoID]) REFERENCES [KichCo]([KichCoID]) ON DELETE SET NULL
)
GO

CREATE TABLE [dbo].[DonHang] (
    [DonHangID]      INT            IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [NguoiDungID]    INT            NOT NULL,
    [HoTenNguoiNhan] NVARCHAR(150)  NOT NULL,
    [SoDienThoai]    NVARCHAR(20)   NOT NULL,
    [DiaChi]         NVARCHAR(300)  NOT NULL,
    [GhiChu]         NVARCHAR(500)  NULL,
    [TongTien]       DECIMAL(18,0)  NOT NULL,
    [TrangThai]      NVARCHAR(50)   NOT NULL DEFAULT N'Chờ xác nhận',
    [PhuongThucTT]   NVARCHAR(50)   NOT NULL DEFAULT N'Tiền mặt',
    [NgayDat]        DATETIME       NOT NULL DEFAULT GETDATE(),
    [NgayCapNhat]    DATETIME       NULL,
    CONSTRAINT FK_DonHang_NguoiDung FOREIGN KEY ([NguoiDungID]) REFERENCES [NguoiDung]([NguoiDungID]) ON UPDATE CASCADE
)
GO

CREATE TABLE [dbo].[ChiTietDonHang] (
    [ChiTietID]   INT            IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [DonHangID]   INT            NOT NULL,
    [SanPhamID]   INT            NOT NULL,
    [KichCoID]    INT            NULL,
    [TenSanPham]  NVARCHAR(200)  NOT NULL,
    [Size]        NVARCHAR(10)   NULL,
    [SoLuong]     INT            NOT NULL,
    [DonGia]      DECIMAL(18,0)  NOT NULL,
    CONSTRAINT FK_CTDH_DonHang FOREIGN KEY ([DonHangID]) REFERENCES [DonHang]([DonHangID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_CTDH_SanPham FOREIGN KEY ([SanPhamID]) REFERENCES [SanPham]([SanPhamID]) ON UPDATE CASCADE,
    CONSTRAINT FK_CTDH_KichCo FOREIGN KEY ([KichCoID]) REFERENCES [KichCo]([KichCoID]) ON DELETE SET NULL
)
GO

CREATE UNIQUE INDEX UX_KichCo_SanPham_Size ON dbo.KichCo(SanPhamID, Size);
GO

INSERT INTO [DanhMuc] ([TenDanhMuc], [MoTa]) VALUES
(N'Giày Nam', N'Các loại giày dành cho nam giới'),
(N'Giày Nữ', N'Các loại giày dành cho nữ giới'),
(N'Giày Thể Thao', N'Giày dùng cho thể thao, vận động'),
(N'Giày Công Sở', N'Giày lịch sự phù hợp môi trường công sở'),
(N'Dép & Sandal', N'Dép và sandal các loại');
GO

INSERT INTO [SanPham] ([DanhMucID],[TenSanPham],[MoTa],[Gia],[GiaKhuyenMai],[HinhAnh],[ThuongHieu],[SoLuongTon]) VALUES
((SELECT DanhMucID FROM DanhMuc WHERE TenDanhMuc = N'Giày Nam'), N'Giày Da Nam Oxford Classic', N'Giày da thật cao cấp, kiểu dáng Oxford lịch lãm, phù hợp đi làm và dự tiệc.', 850000, 720000, 'product1.jpg', N'Giovanni', 50),
((SELECT DanhMucID FROM DanhMuc WHERE TenDanhMuc = N'Giày Nam'), N'Giày Sneaker Nam Nike Air', N'Sneaker nam phong cách thể thao, đế cao su êm ái, thoáng khí.', 1200000, NULL, 'product2.jpg', N'Nike', 30),
((SELECT DanhMucID FROM DanhMuc WHERE TenDanhMuc = N'Giày Nữ'), N'Giày Cao Gót Nữ Thanh Lịch', N'Giày cao gót 7cm màu đen sang trọng, phù hợp công sở và tiệc tùng.', 650000, 550000, 'product3.jpg', N'Zara', 40),
((SELECT DanhMucID FROM DanhMuc WHERE TenDanhMuc = N'Giày Nữ'), N'Giày Búp Bê Nữ Dễ Thương', N'Giày búp bê mũi tròn, chất liệu da mềm, thoải mái cả ngày.', 450000, NULL, 'product4.jpg', N'H&M', 60),
((SELECT DanhMucID FROM DanhMuc WHERE TenDanhMuc = N'Giày Thể Thao'), N'Giày Chạy Bộ Adidas Ultraboost', N'Công nghệ Boost đỉnh cao, hấp thụ lực tốt, phù hợp chạy bộ marathon.', 2500000, 2100000, 'product5.jpg', N'Adidas', 25),
((SELECT DanhMucID FROM DanhMuc WHERE TenDanhMuc = N'Giày Thể Thao'), N'Giày Bóng Rổ Nike Jordan', N'Thiết kế iconic, đế cao su chịu lực tốt, phù hợp thi đấu bóng rổ.', 1800000, NULL, 'product6.jpg', N'Nike', 20),
((SELECT DanhMucID FROM DanhMuc WHERE TenDanhMuc = N'Giày Công Sở'), N'Giày Tây Nam Công Sở', N'Giày tây da bò thật, kiểu dáng Derby hiện đại, đế cao su chống trơn.', 950000, 800000, 'product7.jpg', N'Belluni', 35),
((SELECT DanhMucID FROM DanhMuc WHERE TenDanhMuc = N'Giày Công Sở'), N'Giày Nữ Công Sở Bít Mũi', N'Giày bít mũi nữ công sở, gót vuông 5cm, chất liệu da PU cao cấp.', 520000, NULL, 'product8.jpg', N'Vascara', 45),
((SELECT DanhMucID FROM DanhMuc WHERE TenDanhMuc = N'Dép & Sandal'), N'Dép Lê Nam Quai Ngang', N'Dép lê nam đế EVA siêu nhẹ, chống trượt, phù hợp đi biển và hàng ngày.', 180000, 150000, 'product9.jpg', N'Bitis', 100),
((SELECT DanhMucID FROM DanhMuc WHERE TenDanhMuc = N'Dép & Sandal'), N'Sandal Nữ Đế Bằng', N'Sandal nữ đế bằng phối quai chéo, chất liệu da tổng hợp, màu sắc trẻ trung.', 280000, NULL, 'product10.jpg', N'Juno', 80);
GO

INSERT INTO [KichCo] ([SanPhamID], [Size], [SoLuong]) VALUES
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Da Nam Oxford Classic'),'39',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Da Nam Oxford Classic'),'40',15),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Da Nam Oxford Classic'),'41',15),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Da Nam Oxford Classic'),'42',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Sneaker Nam Nike Air'),'39',5),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Sneaker Nam Nike Air'),'40',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Sneaker Nam Nike Air'),'41',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Sneaker Nam Nike Air'),'42',5),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Cao Gót Nữ Thanh Lịch'),'35',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Cao Gót Nữ Thanh Lịch'),'36',15),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Cao Gót Nữ Thanh Lịch'),'37',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Cao Gót Nữ Thanh Lịch'),'38',5),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Búp Bê Nữ Dễ Thương'),'35',15),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Búp Bê Nữ Dễ Thương'),'36',20),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Búp Bê Nữ Dễ Thương'),'37',15),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Búp Bê Nữ Dễ Thương'),'38',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Chạy Bộ Adidas Ultraboost'),'40',5),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Chạy Bộ Adidas Ultraboost'),'41',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Chạy Bộ Adidas Ultraboost'),'42',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Bóng Rổ Nike Jordan'),'40',5),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Bóng Rổ Nike Jordan'),'41',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Bóng Rổ Nike Jordan'),'42',5),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Tây Nam Công Sở'),'39',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Tây Nam Công Sở'),'40',15),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Tây Nam Công Sở'),'41',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Nữ Công Sở Bít Mũi'),'35',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Nữ Công Sở Bít Mũi'),'36',20),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Nữ Công Sở Bít Mũi'),'37',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Giày Nữ Công Sở Bít Mũi'),'38',5),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Dép Lê Nam Quai Ngang'),'39',30),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Dép Lê Nam Quai Ngang'),'40',35),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Dép Lê Nam Quai Ngang'),'41',25),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Dép Lê Nam Quai Ngang'),'42',10),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Sandal Nữ Đế Bằng'),'35',20),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Sandal Nữ Đế Bằng'),'36',25),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Sandal Nữ Đế Bằng'),'37',20),
((SELECT SanPhamID FROM SanPham WHERE TenSanPham = N'Sandal Nữ Đế Bằng'),'38',15);
GO

INSERT INTO [NguoiDung] ([HoTen], [Email], [MatKhau], [SoDienThoai], [DiaChi], [VaiTro]) VALUES
(N'Quản Trị Viên', 'quantri@gmail.com', '123456aA@!', '0901234567', N'123 Lê Lợi, Q.1, TP.HCM', N'Admin'),
(N'Nguyễn Văn A', 'nguoidung@gmail.com', '123456aA@!', '0912345678', N'456 Nguyễn Huệ, Q.1, TP.HCM', N'KhachHang');
GO
