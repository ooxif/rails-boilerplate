CREATE USER appname_development@'%' IDENTIFIED BY 'appname';
GRANT ALL ON appname_development.* TO appname_development@'%';

CREATE USER appname_test@'%' IDENTIFIED BY 'appname';
GRANT ALL ON appname_test.* TO appname_test@'%';

-- test を並列実行する場合、複数のデータベースを作成するため、
-- その全てにアクセスできるようにする。
GRANT ALL ON `appname\_test-%`.* TO appname_test@'%';
