#!/usr/bin/ruby
## page_router.rb - defines PageRouter

# TODO Add some basic event logging for production debugging and tracking

require 'rubygems'
require 'open-uri'		# parses url's, opens url's as files

require File.dirname(__FILE__) + "/web_strip.rb" # so sub-classes don't have to


# handles call() method sent from Rack and instantiates appropriate page_handler
# see http://rack.rubyforge.org/doc/
class PageRouter

  attr_reader :env, :uri, :logger # for reference by targets

  ## responds to Rack call(env)
  # typical parameters from env
  # REQUEST_METHOD (String) => GET
  # PATH_INFO (String) => '/news.cnet.com/2300-1041_3-6245912-1.html'
  # QUERY_STRING (String) => 'Story_ID=14678579'
  def call(env)
    @env = env
    @logger = env['rack.errors'] # handle to the Rack/Apache logger

    response = Rack::Response.new
    begin
      response.write(selected_page_content)
      response.finish unless response.nil?

    rescue Exception => err # have to have Exception to catch raises from below
      response = Rack::Response.new
      response.write(WebStrip.error_page(err, env)) # write page showing msg and environment contents
      response.finish unless response.nil?
    end
  end

  protected

  ## select appropriate html page given rack env hash
  def selected_page_content
    parse_uri_from_env
    case

    when @uri.to_s == "http://favicon.ico" # automatic request from most browsers
      true # ignore it

    when @uri.class == URI::Generic
      WebStrip.welcome_page # put up a default page

    when @uri.class == URI::HTTP
      parse_page_handler_from_uri
      load_page_handler_definition_file
      get_filtered_page_from_page_handler

    else
      msg = "PageRouter: URI::class '#{@uri.class}' not handled."
      @logger.write "#{msg}\n"
      raise NotImplementedError, msg
    end
  end

private

  # find url of target page(s) from rack request environment
  def parse_uri_from_env
    target = URI.unescape(@env['PATH_INFO'])[1..-1] # removes leading '/'
    if !target.empty? # clean up url to have a leading 'http://'
      target = ((target =~ %r{^http://}).nil? ? "http://" + target : target)
    end
    target << "?#{URI.unescape(@env['QUERY_STRING'])}" unless @env['QUERY_STRING'].empty?
    @logger.write "PageRouter: parsing target: '#{target}'\n"

    @uri = URI.parse(target)
  end
  
  # return name of class that handles the target url
  def parse_page_handler_from_uri
    @page_handler = @uri.host.gsub(/\./, '_') # get host, replace . with _
    # remove leading www_ if present
    @page_handler.capitalize! # convert to class name
  end

  # load appropriate WebStrip sub-class source file
  def load_page_handler_definition_file
    require File.dirname(__FILE__) + "/sites/#{@page_handler.downcase}.rb"

  rescue LoadError => err
    msg = "PageRouter: Unable to load page handler for #{@page_handler}\n" +
      "  URI: #{@uri}\n" +
      "  Error Message: #{err.message}\n"
    @logger.write "#{msg}\n"
    raise LoadError, msg, caller
  end

  def get_filtered_page_from_page_handler # instantiate sub-class with context
    eval "#{@page_handler}.new(self).filtered_page" # send to WebStrip sub-class

  rescue Exception => err
    msg = "PageRouter: Failure in handling '#{@uri}'\n" +
      "  by page handler '#{@page_handler}'.\n" +
      "  Error Message: #{err.message}\n"
    @logger.write "#{msg}\n"
    raise err.class, msg, err.backtrace
  end

end # PageRouter

# little snippet so that I can develop (and debug) inside NetBeans IDE
# have to launch the app with ruby
# http://m.onkey.org/2008/11/17/ruby-on-rack-1
if $0 == __FILE__
  require 'rack'
  Rack::Handler::Mongrel.run PageRouter.new, :Port => 9400
end

