#!/usr/bin/ruby

require 'redcloth'    # markup: http://hobix.com/textile/ 
require 'open-uri'		# handles url's as files
require 'hpricot' 		# html parsing: http://code.whytheluckystiff.net/hpricot/

module Webstrip::Views # handles views

  def layout
    html do
      head do
        title { @page_title }
      end
      body { self << yield }
    end
  end

  def empty
    h1 "Empty Webstrip Page."
    h2 "Insert 'wbstrp.com/' just after 'http://' in the URL."
    p "eg. http://wbstrp.com/{target page without the 'http://' bit}"
    h2 "Sites handled at this time:"
    ul {
      li "CNET Photo Series: news.cnet.com/..."
      li "Mauldin MOTB letter: www.investorsinsight.com/..."
      li "Seeking Alpha Transcript: seekingalpha.com/article/..."
    }
  end
  
  def picture_series
    # FIXME: look at using markaby (as in empty) to build web page
    # FIXME: iterate from first to last link (because all on page)
    #   http://news.cnet.com/2300-11397_3-6244276-1.html?tag=nl.e433
    hpr_doc = Hpricot(open(@cnet_url))
    r = RedCloth.new "h1=. #{hpr_doc.at("h1").inner_text}\n\n"
    r << "p. URL is: #{@cnet_url}"
#     links = hpr_doc.at("#photoShell").at("ul")/"li/a" # all links from first ul element
#     links.each { |e|
#       unless e.bogusetag? || e.attributes['class'] == 'hide' || e.inner_html =~ /ext/ then
#         #$stderr.puts "Fetching url #{e.inner_html}: #{e.attributes['title']}"
#         url = URI('http://' + @cnet_url.host + e.attributes['href'])  # href attribute
#         hpr_doc = Hpricot(open(url)) # repeats first page, but cached...
#         r << '<div style="page-break-after: always">' + "\n\n"
#         r << "h4. #{e.attributes['title']}\n\n"
#         r <<  '<div align="center">' + "\n\n"
#         r <<  (hpr_doc.at("#photoShell")/"img").last.to_html + "\n\n" # alt attribute may be better title
#         r << '</div>' + "\n\n"
#         r <<  hpr_doc.at("#captionColumn").at("#photoCaption").to_html + "\n\n"
#         r <<  "<hr></hr>\n\n</div>\n\n"
#       end
#     }
#     #$stderr.puts r
     r.to_html
  end 
  
end

