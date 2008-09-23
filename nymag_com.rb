#!/usr/bin/ruby

module Webstrip::Views

  # eg. http://nymag.com/news/media/50279/
  def nymag_com
    html do
      head { 
        title "New York Magazine Article"
        meta :content => "text/html; charset=iso-8859-1"
      }
      body { 
        nymag_pages(@uri)
      }
    end
  end
  
end

# not very robust error checking
def nymag_pages(uri)
  require 'open-uri'		# handles url's as files
  require 'hpricot' 		# html parsing: http://code.whytheluckystiff.net/hpricot/
  hpr = Hpricot(open(uri))
  pages = "<p>wbstrp'd from: <code><a href='#{uri}'>#{uri}</a></code></p>"
  links = hpr/("div.page-navigation")/"li/a"
  pages << (hpr.at("div#main")).to_html  # just the contents of this div
  links[1..-2].each { |l|
    hpr = Hpricot(open(l[:href]))
    page = (hpr.at("div#main"))
    (page/("div.page-navigation")).remove
    (page/("script")).remove
    (page/("div#article-related")).remove
    (page/("div#article-tools")).remove
    pages << page.to_html
  }
  pages
end