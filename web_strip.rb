#!/usr/bin/ruby
## webstrip.rb - defines base class

require 'open-uri'		# handles url's as files
require 'hpricot' 		# html parsing: http://wiki.github.com/hpricot/hpricot
require 'markaby'     # for composing web pages

class WebStrip

    # Short error screen
  def WebStrip.error_page(err = Exception.new("Unknown error"), env = nil)
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
  # FIXME hard coded links to development port need to change
  def WebStrip.welcome_page
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
          li { a "Missing Page Handler", :href => "google.com" }
        }
      }
    end
    mab.to_s
  end

  def initialize(page_router)
    @uri = page_router.uri
    @env = page_router.env
    @logger = page_router.logger
    @logger.write "WebStrip: Initialising WebStrip class '#{self.class}'.\n"
    if (@doc = open(@uri) { |f| Hpricot(f) }).nil?
      raise IOError, "WebStrip: Unable to open url '#{@uri}'."
    end
    @title_string = title_from(@doc)
  end

  # generic title generation -- override
  def title_from(doc)
    Date.today.strftime("%y%m%d") + (
      doc.at("head title").inner_text || "Webstrip generic page title"
    )
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

  # cleaned up html body text from a document -- override
  def clean_page(doc)
    "
      <h2>Default Body</h2>
      <p>Reached #{self.class} definition file with '#{@uri}'.</p>
    "
  end

end # WebStrip

# handles the case where the initial page has a list of further links
class LinkedPageSeries < WebStrip

  def initialize(page_router)
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

  # aggregate body content until next_link is nil
  def body_html
    pages = strip_mark(@uri.to_s) + clean_page(@doc)
    until (link = next_link).nil?
      hpr = open(URI(link)) { |f| Hpricot(f) }
      pages << clean_page(hpr) unless hpr.nil?
    end
    pages
  end

  # return url to next page, or nil if none -- override
  def next_link
    nil
  end

end # ChainedPageSeries
