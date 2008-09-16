#!/usr/bin/ruby

module Webstrip::Views

  # does nothing right now
  def news_cnet_com
    html do
      head { title "Cnet news page" }
      body { 
        h1 "Cnet news page."
        h2 "Url to parse: #{@uri}"
        p.code "host: #{@uri.host}"
        p.code @uri.inspect
      }
    end
  end
  
end

