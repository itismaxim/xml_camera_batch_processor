require 'cgi'

# HTMLFiles are meant to contain all the information I would need to put
# into the html file, regardless of whether the file is a model, make, or index.
class HTMLFile
  attr_accessor :title, :type, :nav_links, :nav_links_back, :thumbnails, :url

  def initialize(options)
    # The title is self explanatory, but the type is here to avoid namespace
    # collisions. If for some reason there was a camera model named the Index,
    # the resultant html file would be at the address /model+index
    @title, @type = options[:title], options[:type]
    @thumbnails = options[:thumbnails] || []
    @url = self.class.urlify_title({ title: @title, type: @type})

    # @nav_links of course is an array of every single naviagation link the
    # page will need. @nav_links_back is reserved for the links that lead
    # back up: accordingly, they are titled 'Back to Index' and 'Back to Model'
    @nav_links = options[:nav_links] || []
    @nav_links_back = options[:nav_links_back] || []
    # This feature took more thinking and hard work then I care to admit.
  end

  # Returns a url safe version of the title. Used for names and links.
  # Commas present a very interesting problem. I've elected to simply remove them.
  # To learn more, visit the 3spoopy5me section in the README.
  def self.urlify_title(hash)
    title = hash[:title]
    type = hash[:type]
    CGI.escape(type + ' ' + title.downcase.gsub(/[,]/, "")) + ".html"
  end

  # This takes the thumbnails, navigation links and title and turns into text.
  def html_string(base_address, template)

    # When I CSS, I prefer to style by class. It's infinetly more legible then
    # using wacky selector combinations (regardless of how much I love them).
    # So I added some classes for you! They're hard coded, but otherwise the
    # program would have no class at all! Hyuk-hyuk-hyuk-hyuk...
    nav_string = "      <ul class='nav_links'> \n"
    @nav_links_back.each do |link|
      text = link[:title]
      nav_string += "        <li><a href='#{base_address + self.class.urlify_title(link)}'>Back to #{text}</a></li> \n"
    end

    # The spacing looks realy weird, but check out the HTML files. It lines up wonderfully.
    @nav_links.each do |link|
      text = link[:title]
      nav_string += "            <li><a href='#{base_address + self.class.urlify_title(link)}'>#{text}</a></li> \n"
    end
    nav_string += '      </ul>'

    thumbnails_string = "    <div class='thumbnails'> \n"
    @thumbnails.each do |url|
      thumbnails_string += "      <img src='#{url}' /> \n"
    end
    thumbnails_string += "    </div>"

    template % {
      :title => @title,
      :nav_string => nav_string,
      :thumbnails_string => thumbnails_string
    }
  end
end
