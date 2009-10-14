#!/usr/bin/ruby
# created to parse the Technology Review series
# mistakenly deleted this on local branch; don't know how to restore

module Webstrip::Views

  # does nothing right now
  def www_technologyreview_com
    html do
      head { title "Technology Review series" }
      body { 
        tr_series(@uri)
      }
    end
  end
  
  def tr_series(uri) # cnet photo_series
    require 'open-uri'		# handles url's as files
    require 'hpricot' 		# html parsing: http://code.whytheluckystiff.net/hpricot/
    hpr_doc = Hpricot(open(uri))
    pages = "<p>wbstrp'd from: <code><a href='#{uri}'>#{uri}</a></code></p>"
    pages << "<h1> #{hpr_doc.at("h1.srh1").inner_text}</h1>\n\n"
    links = hpr_doc.at("#articlebody")/"dd/a" # all links to articles
    # have: /read_article.aspx?ch=specialsections&sc=tr10&id=22117
    # need: http://www.technologyreview.com/printer_friendly_article.aspx?id=22117
    re = /(id=\d+)/ # to chop up href
    links.each do |l|
      m = re.match(l[:href])
      url = URI("http://#{uri.host}/printer_friendly_article.aspx?#{m[0]}")
      pages << '<div style="page-break-after: always">' + "\n\n"
      pages << "<p>#{l.inner_text}: <code>#{url}</code></p>" # debug check
      hpr_doc = Hpricot(open(url)) # 
      pages << "<h2>#{hpr_doc.at('div.HeadlineDiv').to_html}</h2>\n\n"
      pages <<  hpr_doc.at("div.ArticleBody").to_html + "\n\n"
      pages <<  "<hr></hr>\n\n</div>\n\n"
    end
    pages
  end 

end

