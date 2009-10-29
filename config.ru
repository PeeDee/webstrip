# config.ru - VERY basic rackup file

# need this on Dreamhost to pick up my own gems, eg. markaby
ENV['GEM_PATH'] = '/home/np_dh/.gems:/usr/lib/ruby/gems/1.8'

require "page_router.rb"

run PageRouter.new
