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
  begin
    hpr = Hpricot(open(uri))
    page = hpr.at("div.ContentBody")  # just the contents of this div
    (page/"div.Options").remove       # remove stuff about getting pdf
    unless page_number == 1 then      # remove heading & byline from all but first page
      (page/"h1").remove
      Hpricot::Elements[(page.at("p"))].remove # first para; "p.Tag Full" won't match
    end
    pages << "\r\n\r\n<!-- page number #{page_number} -->\r\n\r\n"
    pages << page.to_html
    link = (hpr.at("p.Paging")/"a")[-1]
    uri = link[:href]
    page_number += 1
  end until (link[:class] == "Inactive")
  pages
end