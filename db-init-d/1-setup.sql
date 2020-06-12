CREATE DATABASE ebook_platform;
CREATE USER "beidev"@"reader.emcp.php-fpm" IDENTIFIED BY "fas+Horse14";
GRANT ALL ON ebook_platform.* TO "beidev"@"reader.emcp.php-fpm";
FLUSH PRIVILEGES;