#!/usr/bin/ruby
# Economist Special Report, TQ etc.
# eg. http://www.economist.com/displaystory.cfm?story_id=12080751
# eg. http://www.economist.com/printedition/displayStory.cfm?Story_ID=12263158

## Feature: add table of contents?
## Feature: use economist print css?

require File.dirname(__FILE__) + "/../web_strip.rb"

class Www_economist_com < LinkedPageSeries

  def initialize(uri, page_router)
    super
    @title_string = title_from(@doc)
    @logger.write "Www_economist_com: Setting title to '#{@title_string}'\n"
  end

  def title_from(doc)
    title = (doc/"div#content div.col-left p.fly-title").inner_text
    info = (doc/"div#content div.col-left p.info").inner_text # => "Oct 22nd 2009From..."
    d = ((/^(.+)From/ =~ info) == 0 ? Date.parse($1) : Date.today)
    "#{d.strftime("%y%m%d")} #{title}"
  end

  # returns array of href's to related articles
  def link_list
    if (links = @doc.at("div.related-items ul")).nil?
      @logger.write "Www_economist_com: Could not fetch links.\n"
      return [@uri.to_s]
    else
      links = links/"li a" # get the right block of links
    end
    links = links[0..-2] # drop the last element, Offer to Readers (sloppy)
    hrefs = links.collect { |l| l.attributes['href'] }    # return list of href attributes
    #hrefs.each { |h| h.sub!("displaystory.cfm", "PrinterFriendly.cfm") } # convert to print pages
    hrefs # return
  end

  # the contents we are actually interested in
  def clean_page(doc)
    page = (doc/"div#content div.col-left")
    (page/"script").remove           # remove all scripts
    (page/".article-section").remove # header for special reports
    (page/".banner").remove          # remove all banner ads
    (page/".back-to-top").remove     # next article link
    (page/"div#add-comment-container").remove # box for adding comments
    page.to_html
  end

end # Www_economist_com
