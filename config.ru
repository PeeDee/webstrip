# config.ru - very basic rackup file

## Class Hierarchy
# RackResponder - implements response to rack call()
# '-- WebStrip - class with generic routines
#   '-- Site.com - sub-class with site specific filtering

require File.dirname(__FILE__) + "/../rack_responder.rb"
require "webstrip.rb"

run Webstrip.new

