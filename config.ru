# config.ru - very basic rackup file

require "page_router.rb"

use Rack::CommonLogger # TESTME what will removing this do??

run PageRouter.new

