WebStrip
========

A simple web app to filter unwanted crap out of web-pages.

The idea is to take a url, go there and pull the page's html text.
For pages that are the first of a series I pull the link block.
For pages with a "next" I follow the chain.
Then for each page I pull the divs I actually want, remove extraneous
fluff - banners, scripts - and serve them up in some crude css.

PrintWhatYouLike.com does the same in a more interactive way.

I got this running in a single page app for about a dozen sites
using "camping webstrip.rb" and localhost:3301. But now after a brief
flirtation with Sinatra I'm basing directly on Rack as that seems much
less hassle to run on Dreamhost using Passenger. I'm trying to avoid all the
dependencies that I can, but you must have the Hpricot and open-uri gems
and of course, Rack running on Passenger (which DH provides).

To install just checkout the whole tree and point a domain at webstrip/public.

A little better css in style_block() would be nice.

The setup is modular, so once you've cloned the repo you can add sites
by just dropping their def files into the "sites" directory. The page router
loads a ruby file named "#{URI(url).hostname}.rb" replacing '.'s with '_'s,
instantiates a new object of the same class name passing the url to it, and
then sends this object a request for filtered page content. Each def file
defines a sub-class of WebStrip (or LinkedPageSeries or ChainedPageSeries)
and overrides clean_page(doc) which returns a text string of html given the
Hpricot document parsed from the url.

Class Hierarchy
---------------
    PageRouter - implements basic response to rack call(), routes page
    WebStrip - class with generic routines, must override clean_page
      |-- LinkedPageSeries - handles articles with a link block
      | '-- www_..._com - your sub-classes here
      |-- ChainedPageSeries - handles articles with a "next" link
      | '-- www_..._com - your sub-classes here
      '-- www_..._com - your sub-classes here

File Layout
-----------
    webstrip
      |-- README.markdown
      |-- config.ru
      |-- page_router.rb
      |-- public
      |   |-- favicon.gif
      |   `-- favicon.ico
      |-- sites
      |   `-- www_..._com.rb
      |-- tmp
      |   `-- restart.txt
      `-- webstrip.rb


