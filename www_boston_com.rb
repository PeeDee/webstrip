#!/usr/bin/ruby

module Webstrip::Views

  # example of a stub
  def www_boston_com # change to match url for site
  	hpr = Hpricot(open(@uri))
		page = (hpr.at("div.headDiv2")) # eg. first of class in id
		(page/"div#moreLinks").remove
		#(page/"script").remove
		(page/"div#shareBp").remove
		(page/"div#midAd").remove
    html do
      head { 
        title "Boston Globe Photo Series" 
        style {  }
      }
      body { 
        "<p>wbstrp'd from: <code><a href='#{uri}'>#{uri}</a></code></p><hr>" +
        page.to_html
      }
    end
  end
  
end

