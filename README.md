项目说明
===================
这个项目是从PHP官方的github中fork出来的版本，基于php7.1.17版本。本项目主要用来研究PHP-FPM支持协程。

协程是一种可以支持高并发服务器的设计模式。

现在主流的服务器端语言和框架均支持协程调用，包括golang、openresty、java、swoole等。

协程可以降低服务器阻塞，对于需要使用远程调用的服务如使用rpc、mysql、redis等场景，使用协程可以显著提升其服务器性能。

是一种服务器端异步非阻塞IO模型的一种实现方式。

PHP-FPM的设计模式主要是通过多进程来进行并发处理请求。对于服务器资源的使用不充分。

本项目就是通过对PHP-FPM进行优化，通过实现协程模式的PHP-FPM，最终可以像NGINX一样，几个进程即可处理大量的并发请求，充分的利用CPU资源，成倍提升PHP服务器性能。

协程原理
===================
![avatar](/tutorial/coroutine.jpg)

协程本身是一种异步非阻塞的实现方式之一，实现协程需要分成两部分，一个是调度器，另外一个就是协程插件。

这里PHP-FPM就是充当着调度器的功能。当有请求进来之后，由调度器来触发执行。在这次请求的执行过程中，如果遇到远程调用，则需要在请求发送之后PHP主动将控制权交给调度器。调度器这个时候再决定处理其他的请求或者是处理之前执行远程时返回来可以继续执行的请求。
每个请求之间有独立的存储，互相不干扰。

进度说明
===================
这个项目基本上完成，接下来要做的事情是压力测试，和功能测试

项目中，每个进程会开启512个协程，如果想增大并发，可以通过增加进程数来提升总的协程数量。每台机器总协程数=进程数X512

项目调试说明
===================
/ext/coro_http 目录是为了测试协程开发的PHP扩展。
里面已包含详尽的注释。
这个扩展可以当成一个协程实现的demo,里面内容非常简单，开发者可以参照demo开发更多支持协程的扩展，不需要关心PHP-FPM中实现的携程控制器部分

目前只支持macOS和linux

项目调试方法一，编译安装:
=====

1.系统中先要安装libevent库，具体安装方法请自行查找资料

2.项目根目录中执行

 sh buildconf --force

3.项目根目录中执行，安装php

 ./configure --prefix=/usr/local/php7 --enable-fpm --enable-coro_http --enable-maintainer-zts && make && make install

4.修改php-fpm配置文件，设置PHP-FPM进程数，线上环境根据CPU数量和需要的协程数量调整，测试的情况可以设置成1（php-fpm.d/www.conf）
主要是这两个参数

 pm = static
 pm.max_children = 1

5.启动php-fpm

 sudo /usr/local/php7/sbin/php-fpm

6.配置nginx，请自行查阅相关资料,请将nginx的访问目录配置成源码中的tutorial目录，主要是里面的test.php,用于测试


7.这里就可以开始测试了，根据配置好的NGINX，直接访问浏览器(在mac里特别说明)
http://localhost/test.php?a=xx
注意：这里一定要注意，可以开两个窗口访问，但是后面的参数要不一样。因为NGINX对同一个请求，如果相同的参数，NGINX会排队，这里NGINX可能也需要处理一下。不过可以忽略
到这里，就可以看到协程的效果了，结果是，两个窗口同时访问，会先后回来。coro_http会请求nodejs的服务，5秒返回。这里大致可以看到同一个进程的情况下，访问时无阻塞的。

test.php中coro_http_get()方法是实现好的支持协程的扩展，功能是可以请求一个远程地址，返回值是远程地址的输出结果

项目调试方法二，Docker安装:
=====

1.进入tutorial/，执行:

 docker build -t php-fpm-coroutine ./

2.运行docker:

 docker run --privileged php-fpm-coroutine

注意:这块还在调试兼容性，需要进入docker自行启动php，这块启动的时候有一个错误，但是可以正常运行