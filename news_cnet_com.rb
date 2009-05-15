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
    pages <<  begin " at #{hpr_doc.at('#contentAux').at('.datestamp').to_html}</p>\n\n" rescue "<code>no date</code>" end
    pages << "<h1> #{hpr_doc.at("h1").inner_text}</h1>\n\n"

    links = hpr_doc.at("div#contentBody").at("ul.pagination")/"li/a" # all links from first ul element
    str = links[-2].attributes['href'] # the href portion of last page(relative)
    unless (m = str.match(/([-_\d]+)-(\d+).html/))
      pages << "<p><code>Ne Error parsing final link: #{str}</code></p>"
      return pages
    end # parse into bits, must return zero

    base = m[1], num_pages = m[2].to_i
    1.upto(num_pages) do |i|
      url = URI('http://' + uri.host + "/" + base + "-" + i.to_s + ".html" )
       hpr_doc = Hpricot(open(url)) # repeats first page, but cached...
       pages << '<div style="page-break-inside: avoid">' + "\n\n"
       # heading doesn't always exist
#        if (sub_head = hpr_doc.at('#contentAux').at('strong')) 
#         pages << "<h4>#{sub_head.inner_text}</h4>\n\n"
#        end
       pages << begin "#{hpr_doc.at('#contentAux').at('.photoCaption').to_html}\n\n" rescue "<code>no caption</code" end
       pages << '<div align="center">' + "\n\n"
       pages << begin (hpr_doc.at(".galleryImage")).to_html + "\n\n" rescue "<code>no photo</code" end
       pages << begin "<i>#{hpr_doc.at('#contentAux').at('.credit').to_html}</i>\n\n" rescue "" end
       pages << '</div>' + "\n\n"
       pages << "<hr></hr>\n\n</div>\n\n"
    end
    pages
  end 
  
  def hpr_scan(doc, choices) # returns hpr element matching first of choices
    choices.each { |str|
      if (element = doc.at(str))
        return element
      else 
        return Hpricot::emptyelement
      end
    }
  end

end

