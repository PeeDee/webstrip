#!/usr/bin/ruby

module Webstrip::Views

  # example of a stub
  def sample_site_com # change to match url for site
  	hpr = Hpricot(open(@uri))
		page = (hpr.at("div#id_name")).at("div.class_name") # eg. first of class in id
    html do
      head { 
        title "Page Title Here" 
        style {  }
      }
      body { 
        "<p>wbstrp'd from: <code><a href='#{uri}'>#{uri}</a></code></p><hr>" +
        page.to_html
      }
    end
  end
  
end

