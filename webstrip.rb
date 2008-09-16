#!/usr/bin/ruby

## Webstrip matches various sites and then displays filtered pages.
  # FIXME add logging for evaluation purposes...
  # FIXME standard routine to fetch dates, build file name for page title

## Things to do:
  # @env.REQUEST_URI has the entire URI passed to controller
  # add http:// to request uri if missing
  # parse uri.host & replace "."s with "_"s
  # if file named "uri_host.rb" exists, require it
  # send output from Uri_host::html(uri) to screen
  
require 'rubygems'
require 'camping'
require 'redcloth'    # markup: http://hobix.com/textile/ 
require 'open-uri'		# handles url's as files
require 'hpricot' 		# html parsing: http://code.whytheluckystiff.net/hpricot/

Camping.goes :Webstrip # name of application

module Webstrip::Controllers # handles url's
  
  # will show environment, eg. http://wbstrp.net/info
  class Info
    def get; code @env.inspect end
  end

  # handle bare root url
  # eg. http://wbstrp.net/
  class Index < R '/', '/help' 

    def get
      html do
        head { title "Web Strip Help Page" }
        body {
          h1 "Web Strip Help Page"
          h3 "Add your target page to the end of the URL."
          p "eg. http://wbstrp.net/{target page}"
          h3 "Examples:"
          ul {
            li { a "CNET Photo Series", :href => "http://localhost:3301/news.cnet.com/2300-1041_3-6245912-1.html" }
            li { a "Economist Special Report", :href => "http://localhost:3301/http://www.economist.com/displaystory.cfm?story_id=11751139" }
          }
        }
      end
    end # get

  end # Index
  
  class Route < R '/\S+' 
  
    def get
      target = @env.REQUEST_URI 
      target = ((target =~ %r{^/http://}).nil? ? "http:/" + target : target[1..-1])
      @uri = URI.parse(target) # available to views
      view = @uri.host.gsub(/\./, '_')
      load view + ".rb" # rescue if load fails - no view defined
      render view
      rescue MissingSourceFile
        render :whoops
    end
    
  end # Route
  
end # Webstrip::Controllers

module Webstrip::Views # handles views

  def whoops
    html do
      head { title "Missing View" }
      body { 
        h1 "Missing View"
        h2 "Url to parse: #{@uri}"
        h3 "Host:"; p.code "host: #{@uri.host}"
        # looking for file... looking for view...
        h3 "URI:"; p.code @uri.inspect
        h3 "Environment:"; p.code @env.inspect
      }
    end
  end

end # Webstrip::Views