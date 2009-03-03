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
    pages <<  " at #{hpr_doc.at('#contentAux').at('.dateStamp').to_html}</p>\n\n"
    pages << "<h1> #{hpr_doc.at("h1").inner_text}</h1>\n\n"

    links = hpr_doc.at("div#contentBody").at("ul.pagination")/"li/a" # all links from first ul element
    str = links[-2].attributes['href'] # the href portion of last page(relative)
    unless (str =~ %r{/([-_\d]+)-(\d+).html}) == 0
      pages << "<p><code>Error parsing final link: #{str}</code></p>"
      return pages
    end # parse into bits, must return zero

    base = $1; num_pages = $2.to_i
    1.upto(num_pages) do |i|
      url = URI('http://' + uri.host + "/" + base + "-" + i.to_s + ".html" )
       hpr_doc = Hpricot(open(url)) # repeats first page, but cached...
       pages << '<div style="page-break-after: always">' + "\n\n"
       pages << "<h4>#{hpr_doc.at('#contentAux').at('strong').inner_text}</hr>\n\n"
       pages << "#{hpr_doc.at('#contentAux').at('.caption').to_html}\n\n"
       pages << '<div align="center">' + "\n\n"
       pages << (hpr_doc.at("#galleryimage")).to_html + "\n\n" # alt attribute may be better title
       pages << "<i>#{hpr_doc.at('#contentAux').at('.credit').to_html}</i>\n\n"
       pages << '</div>' + "\n\n"
       pages << "<hr></hr>\n\n</div>\n\n"
    end
    pages
  end 

end

