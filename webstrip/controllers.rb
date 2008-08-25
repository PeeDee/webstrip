#!/usr/bin/ruby

module Webstrip::Controllers # handles url's
  
  # handle bare root url, eg. http://wbstrp.com/news.cnet.com
  class Index < R '/'

    def get
      @page_title = "Empty Page."
      render :empty
    end

  end
 
  # handle cnet picture series url
  # eg. http://wbstrp.com/news.cnet.com/2300-11397_3-6244276-1.html
  class Pictures < R '/news.cnet.com/(\S+)'

    def get(id)
      @cnet_url = URI("http://news.cnet.com/#{id}")
      @page_title = "CNET Photo Gallery"
      render :picture_series
    end

  end

end
