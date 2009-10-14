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
      head { 
        title "Economist Series\n"
        style { "
          body { margin: 20px 20px 20px 20px;	}
          .content-image-full, .content-image-float { align: center; margin: 20px 20px; } 
          p.fly-title { color: red }
        \n\n" }

        # css sheet results in crappy borders
        #tag!(:link, "rel" => "stylesheet", "type" => "text/css", "href" => "http://media.economist.com/css/6.1.2/global_story.css")
        } 
      body { 
        #h1 "Stub page."; h2 "Url to parse: #{@uri}"; p.code @uri.inspect
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
  hpr = Hpricot(open(uri))#; hpr.nil?
  links = (hpr/"#content div div.col-right div.related-items ul li a") # css tree
  links.each { |link|
    uri = URI(link.attributes['href']) # removed the base
    pages << "<hr><p>wbstrp'd from: <code><a href='#{uri}'>#{uri}</a></code></p>\n\n"
    hpr = Hpricot(open(uri))
    pages << economist_clean_page(hpr) # the html from a clean page
  }
  pages
end

def economist_clean_page(doc)
  page = (doc/"#content .col-left")
  (page/"script").remove # remove all scripts
  (page/".banner").remove # remove all banner ads
  (page/".article-section").remove # remove all banner ads
  (page/".back-to-top").remove
  (page/"div#add-comment-container").remove
  
  ##FIXME have to fix relative img references
  #<img width="325" height="238" title="" alt=" " src="/images/20071110/4507SR10.jpg"/>
  ## seems to have changed lately...
  #(page/"img").each { |i| i[:src] = 'http://' + base_url.host + i[:src] }
	page.to_html
end