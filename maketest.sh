#########################################################################
# File Name: make.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 四  6/21 16:15:12 2018
#########################################################################
#!/bin/bash
#./configure --enable-debug --prefix=/usr/local/php7 --enable-fpm && make && make install && sudo killall php-fpm&& sudo /usr/local/php7/sbin/php-fpm
#./configure --enable-debug --prefix=/usr/local/php7 --enable-fpm && make && make install && sudo gdb /usr/local/php7/sbin/php-fpm
./configure CFLAGS="-g3 -gdwarf-2" CXXFLAGS="-g3 -gdwarf-2" --prefix=/usr/local/php7 --enable-fpm && make && make install && sudo gdb /usr/local/php7/sbin/php-fpm
