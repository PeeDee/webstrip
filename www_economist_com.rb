#!/usr/bin/ruby
# Economist Special Report, TQ etc.
# eg. http://www.economist.com/displaystory.cfm?story_id=12080751
# eg. http://www.economist.com/printedition/displayStory.cfm?Story_ID=12263158

## Feature: add table of contents?
## Feature: use economist print css?

module Webstrip::Views

  # example of a stub - nothing right now
  def www_economist_com
    html do
      head { title "Economist Series" } # put stylesheet here??
      body { 
        #h1 "Stub page."
        #h2 "Url to parse: #{@uri}"
        #p.code "host: #{@uri.host}"
        #p.code @uri.inspect
        economist_related_items(@uri)
      }
    end
  end
  
end

def economist_related_items(uri)
  require 'open-uri'		# handles url's as files
  require 'hpricot' 		# html parsing: http://code.whytheluckystiff.net/hpricot/
  base_host = uri.host
  pages = ""            # add title of page here??
  hpr = Hpricot(open(uri))
  links = hpr.at(".related-items").at("ul")/"li/a"
  links.each { |link|
    uri = URI('http://' + base_host + link.attributes['href'])
    pages << "<hr><p>wbstrp'd from: <code><a href='#{uri}'>#{uri}</a></code></p>"
    hpr = Hpricot(open(uri))
    pages << economist_clean_page(hpr) # the html from a clean page
  }
  pages
end

def economist_clean_page(doc)
  page = doc.at(".col-left")
  (page/"script").remove # remove all scripts
  (page/".banner").remove # remove all banner ads
  (page/".article-section").remove # remove all banner ads
  (page/".back-to-top").remove # remove all banner ads
  ##FIXME have to fix relative img references
  #<img width="325" height="238" title="" alt=" " src="/images/20071110/4507SR10.jpg"/>
  ## seems to have changed lately...
  #(page/"img").each { |i| i[:src] = 'http://' + base_url.host + i[:src] }
	page.to_html
end