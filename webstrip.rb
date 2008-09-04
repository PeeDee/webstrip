#!/usr/bin/ruby

## Webstrip matches various sites and then displays filtered pages.
  # FIXME add logging for evaluation purposes...
  # FIXME standard routine to fetch dates, build file name for page title
  
require 'rubygems'
require 'camping'
require 'redcloth'    # markup: http://hobix.com/textile/ 
require 'open-uri'		# handles url's as files
require 'hpricot' 		# html parsing: http://code.whytheluckystiff.net/hpricot/

Camping.goes :Webstrip # name of application

module Webstrip::Controllers # handles url's
  
  # handle bare root url, eg. http://webstrip.tiserver.net/
  class Index < R '/' 

    def get
      @page_title = "Empty Web Strip Page."
      render :empty
    end

  end
 
  # handle cnet picture series url
  class Cnet < R '/(\S+)'

    def get(id)
      @cnet_url = URI("http://news.cnet.com/#{id}")
      @page_title = "CNET Photo Gallery"
      render :cnet_photo_series
    end

  end

  # handle Mauldin MOTB newsletters
  class Motb <  R '/(www.investorsinsight.com)/(\S+)'
  
    def get(site, id)
      @motb_url = URI("http://#{site}/#{id}")
      @page_title = "Mauldin MOTB letter"
      render :motb
    end

  end
  
  #http://seekingalpha.com/article/86926-bmc-software-inc-f1q09-qtr-end-30-6-08-earnings-call-transcript?source=feed
  #http://seekingalpha.com/article/86926-bmc-software-inc-f1q09-qtr-end-30-6-08-earnings-call-transcript?source=feed&page=-1
  class SeekingAlpha <  R '/(seekingalpha.com)/(\S+)'
  
    def get(site, id)
      @url = URI("http://#{site}/#{id}&page=-1")
      @page_title = "YYMMDD XXX Transcript"
      render :seekingalpha
    end

  end
  
  #http://www.economist.com/displaystory.cfm?story_id=11751139
  #FIXME: R method won't take an argument with ? in it...
  class SPEconomist <  R '/www.economist.com/displaystory.cfm-story_id=(\S+)'
  
    def get(id)
      @url = URI("http://www.economist.com/displaystory.cfm?story_id=#{id}")
      @page_title = "YYMMDD SP"
      render :speconomist
    end

  end
 

end

module Webstrip::Views # handles views

  def layout
    html do
      head { title @page_title }
      body { self << yield }
    end
  end

  def empty
    h1 "Empty Web Strip Page."
    h2 "Add your target page to the end of the URL."
    p "eg. http://wbstrp.net/{target page without the 'http://' bit}"
    h2 "Sites handled at this time:"
    ul {
      li { a "CNET Photo Series", :href => "http://wbstrp.net/news.cnet.com/2300-1041_3-6245912-1.html" }
#      li "Mauldin MOTB letter: www.investorsinsight.com/..."
#      li "Seeking Alpha Transcript: seekingalpha.com/article/..."
    }
  end
  
  def cnet_photo_series # cnet photo_series
    # FIXME: look at using markaby (as in empty) to build web page
    # FIXME: iterate from first to last link (because all on page)
    #   http://news.cnet.com/2300-11397_3-6244276-1.html?tag=nl.e433
    # FIXME: need to create intermediate links before iteration
    # http://news.cnet.com/2300-1041_3-6245469-1.html 
    # ... links 2 & 3
    # http://news.cnet.com/2300-1041_3-6245469-4.html
    # "..."cd 
    # http://news.cnet.com/2300-1041_3-6245469-10.html
    hpr_doc = Hpricot(open(@cnet_url))
    r = RedCloth.new "h1=. #{hpr_doc.at("h1").inner_text}\n\n"
    links = hpr_doc.at("ul.pagination")/"li/a" # all links from first ul element
    str = links[-2].attributes['href'] # the href portion of last page(relative)
    str =~ %r{/([-_\d]+)-(\d+).html$} # parse into bits, must return zero
    base = $1; pages = $2.to_i
    1.upto(pages) do |i|
      url = URI('http://' + @cnet_url.host + "/" + base + "-" + i.to_s + ".html" )
      r << "Stripping page: #{url.to_s}\n\n"
       hpr_doc = Hpricot(open(url)) # repeats first page, but cached...
       r << '<div style="page-break-after: always">' + "\n\n"
# #      r << "h4. #{e.attributes['title']}\n\n"
       r <<  '<div align="center">' + "\n\n"
       r <<  (hpr_doc.at("div.galleryImage")).to_html + "\n\n" # alt attribute may be better title
       r << '</div>' + "\n\n"
       r <<  hpr_doc.at("div.photoCaption").to_html + "\n\n"
       r <<  "<hr></hr>\n\n</div>\n\n"
    end
    #$stderr.puts r
    r.to_html
  end 
  
  def motb # mauldin outside the box letter
    hpr = Hpricot(open(@motb_url))
    page = (hpr.at("div#CommonContent")).at("div.CommonContentBoxContent")
    (page/"div.Ad_300x250").remove
    (page/"div.em").remove
    page.to_html
  end
  
  def seekingalpha # seeking alpha transcript
    hpr = Hpricot(open(@url))
    page = hpr.at("div#article_body")
    page.to_html
  end
  
  def speconomist # economist special report
    $stderr.puts @url
    hpr = Hpricot(open(@url))
    r = RedCloth.new "h1=. Special Survey: #{hpr.at('p.fly-title').inner_text}\n\n"
    links = hpr.at(".related-items").at("ul")/"li/a" 
    links.each { |e|
      unless e.bogusetag? then
        $stderr.puts "Fetching url #{e.inner_html}: #{e.attributes['title']}"
        url = URI('http://' + @url.host + e.attributes['href'])  # href attribute
        hpr = Hpricot(open(url)) # repeats first page, but cached...
        page = hpr.at(".col-left")
        (page/"script").remove # remove all scripts
        (page/".banner").remove # remove all banner ads
        (page/".article-section").remove # remove all banner ads
        (page/".back-to-top").remove # remove all banner ads
        r << page.to_html
      end
    }
    $stderr.puts r
    r.to_html
  end
  
end

if __FILE__ == $0
  require 'camping/fastcgi'
  Camping::FastCGI.start(Webstrip)
end

