#!/usr/bin/ruby
# This script strips a Mauldin MOTB page

module Webstrip::Views

  # @uri = 'http://www.investorsinsight.com/blogs/john_mauldins_outside_the_box/archive/2008/09/22/observations-on-a-crisis.aspx'
  def www_investorsinsight_com
  	hpr = Hpricot(open(@uri))
		page = (hpr.at("div#CommonContentInner")).at("div.CommonContentBoxContent")
		(page/"script").remove # ads
		(page/"div.Disclaimer").remove # splurge at bottom
		(page/"div.em").remove # tags
    html do
      head { 
        title "Mauldin Outside the Box" 
        style { '
          .ContentBody { margin: 20px 20px 20px 20px;	}
          .ContentBody img { margin: 20px 20px; } '
        }
      }
      body { 
        page.to_html
      }
    end
  end
  
end

