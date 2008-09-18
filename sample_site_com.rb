#!/usr/bin/ruby

module Webstrip::Views

  # example of a stub - nothing right now
  def sample_site_com
    html do
      head { title "stub" }
      body { 
        h1 "Stub page."
        h2 "Url to parse: #{@uri}"
        p.code "host: #{@uri.host}"
        p.code @uri.inspect
      }
    end
  end
  
end

