# Sử dụng Image chính chủ của Microsoft (Bản 2022 mới nhất)
FROM mcr.microsoft.com/mssql/server:2022-latest

# Chuyển sang quyền root để thao tác file và cài đặt
USER root

# Tạo thư mục làm việc
WORKDIR /usr/src/app

# Cài đặt dos2unix (để sửa lỗi định dạng file script nếu bạn code trên Windows)
RUN apt-get update && apt-get install -y dos2unix

# Copy file script và file sql vào container
COPY entrypoint.sh .
COPY KitchenControlBEv1.sql .

# Cấp quyền thực thi cho file script và chuyển đổi định dạng dòng (CRLF -> LF)
RUN chmod +x entrypoint.sh && dos2unix entrypoint.sh

# Chuyển lại quyền user mssql (Bảo mật)
USER mssql

# Chạy script mồi khi Container khởi động
CMD ["/bin/bash", "./entrypoint.sh"]
