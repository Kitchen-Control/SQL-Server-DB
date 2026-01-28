#!/bin/bash

# 1. Khởi động SQL Server dưới background (&)
/opt/mssql/bin/sqlservr &
pid=$!

# 2. Vòng lặp đợi SQL Server khởi động xong
echo "Đang đợi SQL Server khởi động..."
# Lưu ý: sqlcmd trong bản 2022 cần thêm cờ -C (Trust Server Certificate)
until /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" &> /dev/null
do
  echo -n "."
  sleep 1
done
echo "SQL Server đã sẵn sàng!"

# 3. Chạy file init.sql để tạo bảng và data
echo "Bắt đầu chạy script khởi tạo Database..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -i /usr/src/app/init.sql

if [ $? -eq 0 ]; then
    echo "Khởi tạo Database THÀNH CÔNG!"
else
    echo "Khởi tạo Database THẤT BẠI!"
fi

# 4. Giữ cho Container luôn chạy (bằng cách chờ process SQL Server)
wait $pid