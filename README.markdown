WebStrip
========

Camping to filter crap out of web-pages.

The idea is to take a url, go there and pull the page html text.
For pages that are the first of a series I pull the links using Hpricot.
Then I pull the divs I actually want from each page and serve them up.

I got this running locally in a single page app for about a dozen sites 
using "camping webstrip.rb" and localhost:3301.

But for the git version I started over trying to separate controllers and
views. I can't seem to get this to run under fcgi reliably.

Ideally, I would like each hostname to have its own camping app.

That way, to add a site you just drop a short site.domain.rb file into the
camping directory and it's automatically served. But
camping doesn't seem to allow hostname syntax, eg. xyz.com as the name of a
module or file so that didn't work.

Sigh.

Next step is to go back to the single file plan and see if that makes it work again.