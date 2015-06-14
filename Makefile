
all:
	rvm 2.2.1 do jekyll build

install:
	cp -r _site/* /var/www/blog.dubbelboer.com/

