#!/usr/bin/ruby

module Webstrip::Views

  # @uri = 'http://arstechnica.com/articles/paedia/gpu-sweeney-interview.ars'
  def arstechnica_com
    html do
      head { 
        title "Ars Technica Article" 
        style { '
          .ContentBody { margin: 20px 20px 20px 20px;	}
          .ContentBody img { margin: 20px 20px; } '
        }
      }
      body { 
        ars_pages(@uri)
      }
    end
  end
  
end

# not very robust error checking
def ars_pages(uri)
  require 'open-uri'		# handles url's as files
  require 'hpricot' 		# html parsing: http://code.whytheluckystiff.net/hpricot/
  
  page_number = 1
  pages = "<p>wbstrp'd from: <a href='#{uri}'>#{uri}</a></p>"
  #puts "First page: #{uri}"
  hpr = Hpricot(open(uri))
  pages << hpr.at("#news-item-info").to_html
  #puts pages
  begin
    last_link = (hpr.at("#pager")/"li").last # normally "Next >"
    link = last_link.at("a") # nil if this is last page
    page = hpr.at("div#news-item")    # just the contents of this div
    (page/"div.Options").remove       # remove stuff about getting pdf
    (page/"#pager").remove            # the followon links
    pages << "\r\n\r\n<!-- page number #{page_number} -->\r\n\r\n"
    pages << page.to_html
    hpr = Hpricot(open(link[:href])) unless link.nil?
    page_number += 1 #; puts "Page number: #{page_number}"
  end until link.nil?
  
  pages
end