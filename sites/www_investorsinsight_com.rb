#!/usr/bin/ruby
# This script strips a Mauldin MOTB page

class Www_investorsinsight_com < WebStrip

  def initialize(uri, page_router)
    super
    @title_string = "Mauldin Outside the Box"
  end

  def style_block
    "
    <style>
      .ContentBody { margin: 20px 20px 20px 20px;	}
      .ContentBody img { margin: 20px 20px; }
    </style>
    "
  end

  # @uri = 'http://www.investorsinsight.com/blogs/john_mauldins_outside_the_box/archive/2008/09/22/observations-on-a-crisis.aspx'
  def clean_page(hpr)
		page = (hpr.at("div#CommonContentInner")).at("div.CommonContentBoxContent")
		(page/"script").remove # ads
		(page/"div.Disclaimer").remove # splurge at bottom
		(page/"div.em").remove # tags
    page.to_html
  end

end

