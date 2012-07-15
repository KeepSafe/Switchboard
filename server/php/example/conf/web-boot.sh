# echo "Installing PECL APC"
# /app/php/bin/pecl install apc

# echo "[apc]" >> /app/php/php.ini
# echo "extension=apc.so" >> /app/php/php.ini
# echo "[memcache]" >> /app/php/php.ini
# echo "extension=memcache.so" >> /app/php/php.ini

sed -i 's/Listen 80/Listen '$PORT'/' /app/apache/conf/httpd.conf
# sed -i 's/^DocumentRoot/# DocumentRoot/' /app/apache/conf/httpd.conf
# sed -i 's/^ServerLimit 1/ServerLimit 8/' /app/apache/conf/httpd.conf
# sed -i 's/^MaxClients 1/MaxClients 8/' /app/apache/conf/httpd.conf

for var in `env|cut -f1 -d=`; do
  echo "PassEnv $var" >> /app/apache/conf/httpd.conf;
done
echo "Include /app/www/conf/httpd/*.conf" >> /app/apache/conf/httpd.conf
touch /app/apache/logs/error_log
touch /app/apache/logs/access_log
tail -F /app/apache/logs/error_log &
tail -F /app/apache/logs/access_log &
export LD_LIBRARY_PATH=/app/php/ext
export PHP_INI_SCAN_DIR=/app/www
echo "Launching apache"
exec /app/apache/bin/httpd -DNO_DETACH
