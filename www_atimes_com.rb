#!/usr/bin/ruby

module Webstrip::Views

  # http://www.atimes.com/atimes/South_Asia/JL16Df02.html
  def www_atimes_com # change to match url for site
    html do
      head { 
        title "Asia Times Online" 
        style { '
          .ContentBody { margin: 20px 20px 20px 20px;	}
          .ContentBody img { margin: 20px 20px; } '
        }
      }
      body { 
        asia_times_pages(@uri)
      }
    end
  end
  
end

def asia_times_pages(uri)
  require 'open-uri'		# handles url's as files
  require 'hpricot' 		# html parsing: http://code.whytheluckystiff.net/hpricot/
  pages = "<h1>Asia Times Online</h1>"
  begin
    hpr = Hpricot(open(uri))
    page = hpr.at("//td[@width='323']").at("td")  # just the contents of this div
    link = (page/("a")).last
    uri = URI("http://" + uri.host + link[:href])
    (page/"script").remove
    (page/"noscript").remove
    (page/"p[@align='right']").remove
    pages << "<hr><p>wbstrp'd from: <code><a href='#{uri}'>#{uri}</a></code></p><hr>"
    pages << page.inner_html
    pages << "\r\n\r\n<!-- next link #{uri.to_s} -->\r\n\r\n<hr>"
  end until (link.inner_text.to_i == 1)
  pages
end