#!/usr/bin/ruby

module Webstrip::Views

  # does nothing right now
  def news_cnet_com
    html do
      head { title "Cnet news page" }
      body { 
        cnet_photo_series(@uri)
      }
    end
  end
  
  def cnet_photo_series(uri) # cnet photo_series
    require 'open-uri'		# handles url's as files
    require 'hpricot' 		# html parsing: http://code.whytheluckystiff.net/hpricot/
    hpr_doc = Hpricot(open(uri))
    pages = "<p>wbstrp'd from: <code><a href='#{uri}'>#{uri}</a></code></p>"
    pages << "<h1> #{hpr_doc.at("h1").inner_text}</h1>\n\n"
    links = hpr_doc.at("ul.pagination")/"li/a" # all links from first ul element
    str = links[-2].attributes['href'] # the href portion of last page(relative)
    str =~ %r{/([-_\d]+)-(\d+).html$} # parse into bits, must return zero
    base = $1; num_pages = $2.to_i
    1.upto(num_pages) do |i|
      url = URI('http://' + uri.host + "/" + base + "-" + i.to_s + ".html" )
       hpr_doc = Hpricot(open(url)) # repeats first page, but cached...
       pages << '<div style="page-break-after: always">' + "\n\n"
# #      pages << "h4. #{e.attributes['title']}\n\n"
       pages <<  '<div align="center">' + "\n\n"
       pages <<  (hpr_doc.at("div.galleryImage")).to_html + "\n\n" # alt attribute may be better title
       pages << '</div>' + "\n\n"
       pages <<  hpr_doc.at("div.photoCaption").to_html + "\n\n"
       pages <<  "<hr></hr>\n\n</div>\n\n"
    end
    pages
  end 

end

