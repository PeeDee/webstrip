#!/usr/bin/ruby
## webstrip.rb - defines base class

require 'open-uri'		# handles url's as files
require 'hpricot' 		# html parsing: http://wiki.github.com/hpricot/hpricot

class WebStrip

  def initialize(uri, page_router)
    @uri = uri
    @env = page_router.env
    @logger = page_router.logger
    @logger.write "WebStrip: Initialising WebStrip class '#{self.class}'.\n"
    if (@doc = open(@uri) { |f| Hpricot(f) }).nil?
      raise IOError, "WebStrip: Unable to open url '#{@uri}'."
    end
    @title_string = "Webstrip generic page"
  end

  # builds an html page from supplied blocks and strings
  def filtered_page
    # "Reached #{self.class} definition file with '#{@uri}'."
    "
    <html>
      <head>
        #{meta_block}
        <title>#{@title_string}</title>
        #{style_block}
      </head>
      <body>
        #{body_html}
      </body>
    </html>
    "
  end

  def meta_block
    '<meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>'
  end

  def style_block
    "<style></style>"
  end

  def body_html
    strip_mark(@uri.to_s) + clean_page(@doc)
  end

  def strip_mark(link)
    "<hr><p>wbstrp'd from: <code><a href='#{link}'>#{link}</a></code></p>\n\n"
  end

  def clean_page(doc)
    "
      <h2>Default Body</h2>
      <p>Reached #{self.class} definition file with '#{@uri}'.</p>
    "
  end

end # WebStrip

# handles the case where the initial page has a list of further links
class LinkedPageSeries < WebStrip

  def initialize(uri, page_router)
    super
    @links = link_list
    @logger.write "LinkedPageSeries: Fetching #{@links.length} links.\n"
  end

  def body_html
    pages = ""            # add title of page here??
    @links.each { |link|
      @logger.write "LinkedPageSeries: Fetching '#{link}'\n"
      pages << strip_mark(link)
      hpr = open(URI(link)) { |f| Hpricot(f) }
      pages << clean_page(hpr) unless hpr.nil? # the html from a clean page
    }
    pages
  end

end # LinkedPageSeries

# handles the case of a sequence of pages
class ChainedPageSeries < WebStrip


end # ChainedPageSeries
