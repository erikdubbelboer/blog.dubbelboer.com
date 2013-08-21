
all:
	jekyll build

install:
	cp -r _site/* /var/www/blog.dubbelboer.com/

