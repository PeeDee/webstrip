#!/usr/bin/ruby

module Webstrip::Views

  # ft blog, eg. http://blogs.ft.com/maverecon/2008/11/how-likely-is-a-sterling-crisis-or-is-london-really-reykjavik-on-thames/
  def blogs_ft_com
  	hpr = Hpricot(open(@uri))
		page = (hpr.at("div#content")).at("div.post") # id content, class post
    html do
      head { 
        title "FT Blog Page" 
      }
      body { 
        "<p>wbstrp'd from: <code><a href='#{uri}'>#{uri}</a></code></p><hr>" +
        page.to_html
      }
    end
  end
  
end

