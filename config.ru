# config.ru - very basic rackup file

# need this to pick up my own gems, eg. markaby
ENV['GEM_PATH'] = '/home/np_dh/.gems:/usr/lib/ruby/gems/1.8'

require "page_router.rb"

#use Rack::CommonLogger # TESTME what will removing this do??

run PageRouter.new

