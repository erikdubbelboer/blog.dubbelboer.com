
# rvm 3.4.1 do gem install jekyll bundler
all:
	rvm 3.4.1 do jekyll build

install:
	cp -r _site/* /var/www/blog.dubbelboer.com/

