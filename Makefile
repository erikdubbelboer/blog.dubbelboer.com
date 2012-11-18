
all:
	rvm 1.9.3 do ruby ~/.rvm/gems/ruby-1.9.3-p125/gems/jekyll-0.11.2/bin/jekyll --pygments --safe

install:
	cp -r _site/* /var/www/blog.dubbelboer.com/

