WebStrip
========

Camping to filter crap out of web-pages.

The idea is to take a url, go there and pull the page's html text.
For pages that are the first of a series I pull the links using Hpricot.
Then I pull the divs I actually want from each page and serve them up.

I got this running locally in a single page app for about a dozen sites 
using "camping webstrip.rb" and localhost:3301. I'm going to migrate those
sites across to the server/git version over time.

The app is now working. You can test it on wbstrp.net. news_cnet_com.rb is only
a stub; but arstechnica_com.rb does exactly what I want. A little more css
would be nice though.

To add a site you just drop a short site_domain.rb file into the
same directory and it's automatically served. I replace the '.'s in the
host name with '_'s, require "host_name.rb", and then call the "host_name"
view for the html to render.

Works great.

Next step is to go back to the single file plan and see if that makes it work again.