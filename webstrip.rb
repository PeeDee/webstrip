#!/usr/bin/ruby

require 'rubygems'
require 'camping'     # ruby for fcgi: http://camping.rubyforge.org/
require 'open-uri'		# opens url's as files
require 'hpricot' 		# html parsing: http://code.whytheluckystiff.net/doc/hpricot/

Camping.goes :Webstrip # name of application

module Webstrip::Controllers # handles url's
  
  # will show environment, eg. http://wbstrp.net/info
  #class Info
  #  def get; code @env.inspect end
  #end

  # handle bare root url
  # eg. http://wbstrp.net/ or http://wbstrp.net/help
  ## FIXME cleanup help page links to use referring host (localhost, wbstrp...) 
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
            li { a "CNET Photo Series", :href => "http://wbstrp.net/news.cnet.com/2300-1041_3-6245912-1.html" }
            li { a "Ars Technica", :href => "http://wbstrp.net/arstechnica.com/articles/paedia/gpu-sweeney-interview.ars" }
            li { a "Economist Special Report (not done)", :href => "http://wbstrp.net/http://www.economist.com/displaystory.cfm?story_id=11751139" }
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
        #h3 "Environment:"; p.code @env.inspect
      }
    end
  end

end # Webstrip::Views