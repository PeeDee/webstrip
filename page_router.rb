#!/usr/bin/ruby
## page_router.rb - defines PageRouter

# TODO Add some basic event logging for production debugging and tracking

require 'rubygems'
require 'open-uri'		# parses url's, opens url's as files
require 'markaby'     # for composing web pages

require File.dirname(__FILE__) + "/web_strip.rb" # so sub-classes don't have to


# handles call() method sent from Rack and instantiates appropriate page_handler
# see http://rack.rubyforge.org/doc/
class PageRouter

  attr_reader :env, :logger

  ## responds to Rack call(env)
  # typical parameters from env
    # REQUEST_METHOD (String) => GET
    # PATH_INFO (String) => '/news.cnet.com/2300-1041_3-6245912-1.html'
    # QUERY_STRING (String) => 'Story_ID=14678579'

  def call(env)
    @env = env
    @logger = env['rack.errors'] # handle to the Rack/Apache logger

    @response = Rack::Response.new
    begin
      @response.write(selected_page)
      @response.finish unless @response.nil?

    rescue Exception => err # have to have Exception to catch raises from below
      @response = Rack::Response.new
      @response.write(PageRouter.error_page(err, env)) # write page showing msg and environment contents
      @response.finish unless @response.nil?
    end
  end

  ## select appropriate html page given rack env hash
  def selected_page
    target = URI.unescape(@env['PATH_INFO'])[1..-1] # removes leading '/'
    if !target.empty? # clean up url to have a leading 'http://'
      target = ((target =~ %r{^http://}).nil? ? "http://" + target : target)
    end
    target << "?#{URI.unescape(@env['QUERY_STRING'])}" unless @env['QUERY_STRING'].empty?
    @logger.write "PageRouter: parsing target: '#{target}'\n"

    @uri = URI.parse(target)
    case
      when @uri.to_s == "http://favicon.ico" # automatic request from most browsers
        true # ignore it
      when @uri.class == URI::Generic
        PageRouter.welcome_page # put up a simple page
      when @uri.class == URI::HTTP
        page_handler = @uri.host.gsub(/\./, '_').capitalize! # convert to class name
        begin
          require File.dirname(__FILE__) + "/sites/#{page_handler}.rb" # WebStrip sub-class
          rescue LoadError => err
            msg = "PageRouter: Unable to load page handler for #{page_handler}\n" +
                  "  URI: #{@uri}\n" +
                  "  Error Message: #{err.message}\n"
            @logger.write "#{msg}\n"
            raise LoadError, msg, caller
        end
        begin
          eval "#{page_handler}.new(@uri, self).filtered_page" # send to WebStrip sub-class
          rescue Exception => err
            msg = "PageRouter: Failure in handling '#{@uri}'\n" +
                  "  by page handler '#{page_handler}'.\n" +
                  "  Error Message: #{err.message}\n"
            @logger.write "#{msg}\n"
            raise err.class, msg, caller
        end
      else
        msg = "PageRouter: URI::class '#{@uri.class}' not handled."
        @logger.write "#{msg}\n"
        raise NotImplementedError, msg
    end
  end

  # Short error screen
  def PageRouter.error_page(err = Exception.new("Unknown error"), env = nil)
    mab = Markaby::Builder.new
    mab.html do
      head { title "Error Page" }
      body {
        h1 "Web Strip Error Page"
        h2 "#{err.class}:"
        self << err.to_s.split(/\n/).collect{|line| "<p>#{line}</p>" }.join("\n")
        h3 "Call Stack"
        self << err.backtrace.join("</br>\n")
        h3 "Environment:"
        self << "<table><tr>"
        self << env.collect{|k,v| "<tr><td>#{k} (#{v.class.to_s})</td><td><code>#{v}</code></td></tr>" }.join("\n")
        self << "</tr></table>"
      }
    end
    mab.to_s
  end

  ## a simple welcome page
  # TODO generate dynamic list of pages I understand
  # TODO form with text blank to paste in url
  def PageRouter.welcome_page
    mab = Markaby::Builder.new
    mab.html do
      head { title "Web Strip Help Page" }
      body {
        h1 "Web Strip Help Page"
        h3 "Add your target page to the end of the URL."
        p "eg. http://wbstrp.com/{target page}"
        h3 "Testing:"
        ul {
          li { a "Valid Site ", :href => "http://localhost:3000/http://news.cnet.com/2300-1041_3-6245912-1.html" }
          li { a "Valid Site w/o http", :href => "http://localhost:3000/news.cnet.com/2300-1041_3-6245912-1.html" }
          li { a "Missing Page Handler", :href => "http://localhost:3000/http://google.com" }
        }
      }
    end
    mab.to_s
  end

end # PageRouter
