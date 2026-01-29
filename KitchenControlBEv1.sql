USE master;
GO

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'KitchenControlBEv1')
BEGIN
    ALTER DATABASE KitchenControlBEv1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE KitchenControlBEv1;
END
GO

CREATE DATABASE KitchenControlBEv1;
GO
USE KitchenControlBEv1;
GO

-- ... (Phần code tạo bảng và Insert data của bạn ở dưới) ...
CREATE TABLE [roles] (
  [role_id] int PRIMARY KEY IDENTITY(1, 1),
  [role_name] nvarchar(255)
)
GO

CREATE TABLE [users] (
  [user_id] int PRIMARY KEY IDENTITY(1, 1),
  [username] nvarchar(255),
  [password] nvarchar(255),
  [full_name] nvarchar(255),
  [role_id] int,
  [store_id] int
)
GO

CREATE TABLE [stores] (
  [store_id] int PRIMARY KEY IDENTITY(1, 1),
  [store_name] nvarchar(255),
  [address] nvarchar(255),
  [phone] nvarchar(255)
)
GO

CREATE TABLE [products] (
  [product_id] int PRIMARY KEY IDENTITY(1, 1),
  [product_name] nvarchar(255),
  [product_type] nvarchar(255) NOT NULL CHECK ([product_type] IN ('RAW_MATERIAL', 'SEMI_FINISHED', 'FINISHED_PRODUCT')),
  [unit] nvarchar(255),
  [shelf_life_days] int
)
GO

CREATE TABLE [recipes] (
  [recipe_id] int PRIMARY KEY IDENTITY(1, 1),
  [product_id] int,
  [recipe_name] nvarchar(255),
  [yield_quantity] float,
  [description] text
)
GO

CREATE TABLE [recipe_details] (
  [recipe_detail_id] int PRIMARY KEY IDENTITY(1, 1),
  [recipe_id] int,
  [raw_material_id] int,
  [quantity] float
)
GO

CREATE TABLE [production_plans] (
  [plan_id] int PRIMARY KEY IDENTITY(1, 1),
  [plan_date] date,
  [start_date] date,
  [end_date] date,
  [status] nvarchar(255),
  [note] text
)
GO

CREATE TABLE [production_plan_details] (
  [plan_detail_id] int PRIMARY KEY IDENTITY(1, 1),
  [plan_id] int NOT NULL,
  [product_id] int NOT NULL,
  [quantity] float NOT NULL,
  [note] text
)
GO

CREATE TABLE [orders] (
  [order_id] int PRIMARY KEY IDENTITY(1, 1),
  [delivery_id] int,
  [store_id] int,
  [order_date] datetime,
  [status] nvarchar(255) NOT NULL CHECK ([status] IN ('WAITTING', 'PROCESSING', 'DELIVERING', 'DONE', 'DAMAGED', 'CANCLED')),
  [img] nvarchar(255),
  [comment] nvarchar(255)
)
GO

CREATE TABLE [order_details] (
  [order_detail_id] int PRIMARY KEY IDENTITY(1, 1),
  [order_id] int,
  [product_id] int,
  [quantity] float
)
GO

CREATE TABLE [log_batches] (
  [batch_id] int PRIMARY KEY IDENTITY(1, 1),
  [plan_id] int,
  [product_id] int,
  [quantity] float,
  [production_date] date,
  [expiry_date] date,
  [status] nvarchar(255) NOT NULL CHECK ([status] IN ('PROCESSING', 'DONE', 'EXPIRED', 'DAMAGED')),
  [type] nvarchar(255) NOT NULL CHECK ([type] IN ('PRODUCTION', 'PURCHASE')),
  [created_at] datetime
)
GO

CREATE TABLE [inventories] (
  [inventory_id] int PRIMARY KEY IDENTITY(1, 1),
  [product_id] int,
  [batch_id] int,
  [quantity] float,
  [expiry_date] date
)
GO

CREATE TABLE [inventory_transactions] (
  [transaction_id] int PRIMARY KEY IDENTITY(1, 1),
  [product_id] int,
  [batch_id] int,
  [type] nvarchar(255) NOT NULL CHECK ([type] IN ('IMPORT', 'EXPORT')),
  [quantity] float,
  [created_at] datetime,
  [note] text
)
GO

CREATE TABLE [deliveries] (
  [delivery_id] int PRIMARY KEY IDENTITY(1, 1),
  [delivery_date] date,
  [shipper_id] int,
  [created_at] datetime
)
GO

CREATE TABLE [quality_feedbacks] (
  [feedback_id] int PRIMARY KEY IDENTITY(1, 1),
  [order_id] int,
  [store_id] int,
  [rating] int,
  [comment] text,
  [created_at] datetime
)
GO

CREATE TABLE [reports] (
  [report_id] int PRIMARY KEY IDENTITY(1, 1),
  [report_type] nvarchar(255),
  [user_id] int,
  [created_date] datetime
)
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Unique',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'users',
@level2type = N'Column', @level2name = 'store_id';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'sản phẩm có thời gian sủ dụng bao ngày (ex: 30 days)',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'products',
@level2type = N'Column', @level2name = 'shelf_life_days';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'How much this recipe makes',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'recipes',
@level2type = N'Column', @level2name = 'yield_quantity';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'có thể là ngày sản xuất hoặc ngày nhập hàng',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'log_batches',
@level2type = N'Column', @level2name = 'production_date';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Unique',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'inventories',
@level2type = N'Column', @level2name = 'batch_id';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Unique',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'quality_feedbacks',
@level2type = N'Column', @level2name = 'order_id';
GO

ALTER TABLE [users] ADD FOREIGN KEY ([role_id]) REFERENCES [roles] ([role_id])
GO

ALTER TABLE [users] ADD FOREIGN KEY ([store_id]) REFERENCES [stores] ([store_id])
GO

ALTER TABLE [recipes] ADD FOREIGN KEY ([product_id]) REFERENCES [products] ([product_id])
GO

ALTER TABLE [recipe_details] ADD FOREIGN KEY ([recipe_id]) REFERENCES [recipes] ([recipe_id])
GO

ALTER TABLE [recipe_details] ADD FOREIGN KEY ([raw_material_id]) REFERENCES [products] ([product_id])
GO

ALTER TABLE [orders] ADD FOREIGN KEY ([store_id]) REFERENCES [stores] ([store_id])
GO

ALTER TABLE [order_details] ADD FOREIGN KEY ([order_id]) REFERENCES [orders] ([order_id])
GO

ALTER TABLE [order_details] ADD FOREIGN KEY ([product_id]) REFERENCES [products] ([product_id])
GO

ALTER TABLE [log_batches] ADD FOREIGN KEY ([plan_id]) REFERENCES [production_plans] ([plan_id])
GO

ALTER TABLE [log_batches] ADD FOREIGN KEY ([product_id]) REFERENCES [products] ([product_id])
GO

ALTER TABLE [inventories] ADD FOREIGN KEY ([product_id]) REFERENCES [products] ([product_id])
GO

ALTER TABLE [inventories] ADD FOREIGN KEY ([batch_id]) REFERENCES [log_batches] ([batch_id])
GO

ALTER TABLE [inventory_transactions] ADD FOREIGN KEY ([product_id]) REFERENCES [products] ([product_id])
GO

ALTER TABLE [inventory_transactions] ADD FOREIGN KEY ([batch_id]) REFERENCES [log_batches] ([batch_id])
GO

ALTER TABLE [orders] ADD FOREIGN KEY ([delivery_id]) REFERENCES [deliveries] ([delivery_id])
GO

ALTER TABLE [quality_feedbacks] ADD FOREIGN KEY ([order_id]) REFERENCES [orders] ([order_id])
GO

ALTER TABLE [quality_feedbacks] ADD FOREIGN KEY ([store_id]) REFERENCES [stores] ([store_id])
GO

ALTER TABLE [reports] ADD FOREIGN KEY ([user_id]) REFERENCES [users] ([user_id])
GO

ALTER TABLE [deliveries] ADD FOREIGN KEY ([shipper_id]) REFERENCES [users] ([user_id])
GO

ALTER TABLE [production_plan_details] ADD FOREIGN KEY ([product_id]) REFERENCES [products] ([product_id])
GO

ALTER TABLE [production_plan_details] ADD FOREIGN KEY ([plan_id]) REFERENCES [production_plans] ([plan_id])
GO


--INSERTING MOCK DATA

/*=============================BASIC TYPE DATA=============================================================*/
-- 1. Thêm Roles (Vai trò)
INSERT INTO [roles] ([role_name]) VALUES 
(N'Admin'), 
(N'Manager'), 
(N'Store Staff'), 
(N'Kitchen Manager'), 
(N'Supply Coordinator'), 
(N'Shipper');

-- 2. Thêm Stores (Cửa hàng Franchise)
INSERT INTO [stores] ([store_name], [address], [phone]) VALUES 
(N'Store Quận 1', N'123 Nguyễn Huệ, Q1, HCM', N'0901234567'),
(N'Store Quận 7', N'456 Nguyễn Thị Thập, Q7, HCM', N'0909876543'),
(N'Store Thủ Đức', N'789 Võ Văn Ngân, Thủ Đức', N'0905555555');

-- 3. Thêm Users (Nhân viên)
-- Lưu ý: Store Staff cần gắn với Store_ID, các role khác Store_ID có thể NULL
INSERT INTO [users] ([username], [password], [full_name], [role_id], [store_id]) VALUES 
('admin', '123456', N'Nguyễn Quản Trị', 1, NULL),
('manager', '123456', N'Trần Giám Đốc', 2, NULL),
('staff_q1', '123456', N'Lê Nhân Viên Q1', 3, 1), -- Thuộc Store Q1
('staff_q7', '123456', N'Phạm Nhân Viên Q7', 3, 2), -- Thuộc Store Q7
('kitchen_mgr', '123456', N'Võ Bếp Trưởng', 4, NULL),
('coordinator', '123456', N'Đặng Điều Phối', 5, NULL),
('shipper_01', '123456', N'Hoàng Shipper 1', 6, NULL),
('shipper_02', '123456', N'Bùi Shipper 2', 6, NULL);

/*=============================PRODUCT DATA=============================================================*/
-- 4. Thêm Products (Sản phẩm)
-- Bao gồm đủ 3 loại: RAW_MATERIAL, SEMI_FINISHED, FINISHED_PRODUCT
INSERT INTO [products] ([product_name], [product_type], [unit], [shelf_life_days]) VALUES 
-- Nguyên liệu thô
(N'Bột Mì', 'RAW_MATERIAL', N'kg', 180),      -- ID: 1
(N'Thịt Bò', 'RAW_MATERIAL', N'kg', 7),        -- ID: 2
(N'Phô Mai', 'RAW_MATERIAL', N'kg', 30),       -- ID: 3
(N'Cà Chua', 'RAW_MATERIAL', N'kg', 5),        -- ID: 4
-- Bán thành phẩm
(N'Đế Bánh Pizza', 'SEMI_FINISHED', N'cái', 3), -- ID: 5
(N'Sốt Cà Chua', 'SEMI_FINISHED', N'lít', 7),   -- ID: 6
-- Thành phẩm (Bán cho Store)
(N'Pizza Bò Phô Mai', 'FINISHED_PRODUCT', N'cái', 1), -- ID: 7
(N'Mì Ý Sốt Bò', 'FINISHED_PRODUCT', N'hộp', 1);      -- ID: 8

-- 5. Thêm Recipes (Công thức tổng quát)
INSERT INTO [recipes] ([product_id], [recipe_name], [yield_quantity], [description]) VALUES 
(5, N'Công thức Đế Bánh', 10, N'Làm ra 10 cái đế bánh'), -- ID: 1 (Cho Đế Bánh)
(7, N'Công thức Pizza Bò', 1, N'Làm ra 1 cái Pizza');    -- ID: 2 (Cho Pizza Bò)

-- 6. Thêm Recipe Details (Chi tiết nguyên liệu)
INSERT INTO [recipe_details] ([recipe_id], [raw_material_id], [quantity]) VALUES 
-- Chi tiết cho Đế Bánh (ID 1): Cần 2kg Bột mì
(1, 1, 2.0), 
-- Chi tiết cho Pizza Bò (ID 2): Cần 1 Đế bánh + 0.2kg Bò + 0.1kg Phô mai
(2, 5, 1.0),
(2, 2, 0.2),
(2, 3, 0.1);


/*=============================PRODUCTION & BATCHES=============================================================*/
-- 7. Thêm Production Plans (Kế hoạch sản xuất)
INSERT INTO [production_plans] ([plan_date], [start_date], [end_date], [status], [note]) VALUES 
(GETDATE(), GETDATE(), DATEADD(day, 1, GETDATE()), N'APPROVED', N'Kế hoạch sản xuất Pizza thứ 2'), -- ID: 1
(DATEADD(day, -5, GETDATE()), DATEADD(day, -5, GETDATE()), DATEADD(day, -4, GETDATE()), N'COMPLETED', N'Kế hoạch tuần trước'); -- ID: 2

-- 8. Thêm Production Plan Details (Chi tiết kế hoạch)
INSERT INTO [production_plan_details] ([plan_id], [product_id], [quantity], [note]) VALUES 
(1, 7, 50, N'Làm 50 cái Pizza Bò'), -- Plan 1 làm Pizza
(1, 8, 30, N'Làm 30 hộp Mì Ý');    -- Plan 1 làm Mì Ý

-- 9. Thêm Log Batches (Lô hàng) - QUAN TRỌNG: Cả Purchase và Production
INSERT INTO [log_batches] ([plan_id], [product_id], [quantity], [production_date], [expiry_date], [status], [type], [created_at]) VALUES 
-- Lô 1: Nhập mua Bột mì (PURCHASE - ko cần Plan ID)
(NULL, 1, 100, GETDATE(), DATEADD(day, 180, GETDATE()), 'DONE', 'PURCHASE', GETDATE()),
-- Lô 2: Nhập mua Thịt bò (PURCHASE)
(NULL, 2, 50, GETDATE(), DATEADD(day, 7, GETDATE()), 'DONE', 'PURCHASE', GETDATE()),
-- Lô 3: Sản xuất Đế bánh (PRODUCTION - Có Plan ID)
(1, 5, 50, GETDATE(), DATEADD(day, 3, GETDATE()), 'DONE', 'PRODUCTION', GETDATE()),
-- Lô 4: Sản xuất Pizza Bò (PRODUCTION - Có Plan ID)
(1, 7, 20, GETDATE(), DATEADD(day, 1, GETDATE()), 'DONE', 'PRODUCTION', GETDATE()),
-- Lô 5: Hàng hết hạn (Ví dụ nhập mua Cà chua lâu rồi)
(NULL, 4, 10, DATEADD(day, -10, GETDATE()), DATEADD(day, -1, GETDATE()), 'EXPIRED', 'PURCHASE', DATEADD(day, -10, GETDATE()));

-- 10. Thêm Inventories (Tồn kho hiện tại)
INSERT INTO [inventories] ([product_id], [batch_id], [quantity], [expiry_date]) VALUES 
(1, 1, 80, DATEADD(day, 180, GETDATE())), -- Còn 80kg Bột (Lô 1)
(2, 2, 40, DATEADD(day, 7, GETDATE())),   -- Còn 40kg Bò (Lô 2)
(5, 3, 30, DATEADD(day, 3, GETDATE())),   -- Còn 30 Đế bánh (Lô 3)
(7, 4, 20, DATEADD(day, 1, GETDATE())),   -- Còn 20 Pizza Bò (Lô 4) thành phẩm sẵn sàng bán
(4, 5, 10, DATEADD(day, -1, GETDATE()));  -- Còn 10kg Cà chua (Lô 5) - Đã hết hạn (EXPIRED trong Batch)

-- 11. Thêm Inventory Transactions (Lịch sử biến động)
INSERT INTO [inventory_transactions] ([product_id], [batch_id], [type], [quantity], [created_at], [note]) VALUES 
(1, 1, 'IMPORT', 100, GETDATE(), N'Nhập kho Bột mì'),
(1, 1, 'EXPORT', 20, GETDATE(), N'Xuất bột mì để làm đế bánh'), -- Ví dụ
(7, 4, 'IMPORT', 20, GETDATE(), N'Nhập kho thành phẩm Pizza');

-- 12. Thêm Deliveries (Chuyến xe)
INSERT INTO [deliveries] ([delivery_date], [shipper_id], [created_at]) VALUES 
(GETDATE(), 7, GETDATE()), -- Delivery 1: Shipper 1 đang chạy (Hôm nay)
(DATEADD(day, -1, GETDATE()), 8, DATEADD(day, -1, GETDATE())); -- Delivery 2: Shipper 2 đã chạy xong (Hôm qua)

-- 13. Thêm Orders (Đơn đặt hàng từ Store)
INSERT INTO [orders] ([delivery_id], [store_id], [order_date], [status], [img], [comment]) VALUES 
-- Đơn 1: Mới tạo (WAITING) - Chưa có Delivery ID
(NULL, 1, GETDATE(), 'WAITTING', NULL, N'Giao trước 10h sáng mai'),
-- Đơn 2: Đang giao (DELIVERING) - Gắn với Delivery 1
(1, 2, GETDATE(), 'DELIVERING', NULL, N'Đang trên đường giao'),
-- Đơn 3: Đã xong (DONE) - Gắn với Delivery 2 (Hôm qua)
(2, 3, DATEADD(day, -1, GETDATE()), 'DONE', NULL, N'Đã nhận đủ hàng'),
-- Đơn 4: Đã hủy (CANCLED)
(NULL, 1, DATEADD(day, -2, GETDATE()), 'CANCLED', NULL, N'Đặt nhầm món'),
-- Đơn 5: Bị hỏng (DAMAGED) - Gắn với Delivery 2
(2, 1, DATEADD(day, -1, GETDATE()), 'DAMAGED', 'hinh_anh_hong.jpg', N'Bánh bị nát khi giao');

-- 14. Thêm Order Details (Chi tiết đơn hàng)
INSERT INTO [order_details] ([order_id], [product_id], [quantity]) VALUES 
(1, 7, 5),  -- Đơn 1: 5 cái Pizza Bò
(1, 8, 10), -- Đơn 1: 10 hộp Mì Ý
(2, 7, 20), -- Đơn 2: 20 cái Pizza Bò
(3, 7, 15); -- Đơn 3: 15 cái Pizza Bò

-- 15. Thêm Quality Feedbacks (Chỉ cho đơn hàng DONE)
INSERT INTO [quality_feedbacks] ([order_id], [store_id], [rating], [comment], [created_at]) VALUES 
(3, 3, 5, N'Pizza rất ngon, đế giòn', DATEADD(day, -1, GETDATE()));

-- 16. Thêm Reports (Báo cáo hệ thống)
INSERT INTO [reports] ([report_type], [user_id], [created_date]) VALUES 
('WASTE', 5, GETDATE()), -- Báo cáo hủy hàng do Coordinator tạo
('REVENUE', 1, GETDATE()); -- Báo cáo doanh thu do Admin tạo