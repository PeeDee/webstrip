# To change this template, choose Tools | Templates
# and open the template in the editor.

class Krugman_blogs_nytimes_com < WebStrip

  def self.name
    "Krugman's NYT Blog"
  end

  def self.sample
    "http://krugman.blogs.nytimes.com/2009/10/06/krugman-responds-readers-questions/"
  end

  def title_from(doc)
    title = doc.at("h2.entry-title").inner_text
    date = doc.at("span.timestamp")[:title]
    d = (Date.parse(date) || Date.today)
    "#{d.strftime("%y%m%d")} Krugman - #{title}"
  end

  def clean_page(doc)
    doc.at("div.hentry").inner_html
  end

end
