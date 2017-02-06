Hello! Welcome to my batch processor. A few notes on the program:

    It's written in ruby 2.2.0. Please run 'bundle install' before you start.
      If that doesn't work, it means you need to install bundler too.
      Smack 'gem install bundler' into the command line, and then run 'bundle instal'
    If you don't have ruby installed, I suggest finding your
    operating system on this page and following the instructions.
    https://www.ruby-lang.org/en/documentation/installation/#package-management-systems


Running The Program

    Enter 'ruby camera_batch_processor.rb' into the command line.
    That's actually all you need! However, there's four optional
    arguments you can include, should the mood strike you.

    Which directory the XML is in: -i or --input-location
      The default is the current directory.

    Which directory you want the HTML files to go: -o or --output-location
      The default is current_directory/output.

    Which HTML template you would like to use: -t or --template
      The default is 'output-template.html'

    What size you'd like the thumbnails: 0 is smallest, 2 is largest: -s or --size
      The default is the smallest. They're called thumbnails after all!

    Example: ruby camera_batch_processor.rb -o /Users/maxim/Desktop/new_folder -i /Users/maxim/Desktop/Coding


Bonus Features!

    I've added a few bells and whistles to hopefully make the program more convenient.

    Variable Thumbnail Sizes!
      The XML files you provided have three different sizes of image.
      You may pick either the small, medium, or large one to be used as thumbnails.

    Switch Templates!
      The template is not hard coded into the project.
      Instead, feel free to use A COMPLETELY DIFFERENT HTML TEMPLATE.
      Templates require #{title}, #{nav_string}, and #{thumbnails_string}
      to be written somewhere inside, and can only be .txt or .html files.
      *Templates must be located within this directory.*

    Makes Output Directory!
      Give it a try! If the output location does not exist,
      the program will happily make it for you.

    Avoids Namespace Conflicts!
      If by chance makes and models share names,

    Classes!
      Add a little CSS onto the unimaginatively named #title, #nav_links,
      and #thumbnails classes.


Big Assumptions

    Nothing is completely idiot proof, and this program makes a few assumptions.
    **If something is going stupidly wrong, this is a good place to check.**
    Most of these were design shrugs: I didn't know what the intended behavior
    was supposed to be, and my email wasn't answered. So I guessed!
    For the most part, I could change these decisions quite easily.

      1. I DON'T assume the XML file is named works.xml. The Program will grab
         the first XML file it finds in the input directory.

      2. I assume the input XML file looks like the example you gave me.
         This is the bear minimum I need:
             <work>
               <work>
                 <urls>
                   <url type="small">http://ih1.redbubble.net/work.31820.1.flat,135x135,075,f.jpg</url>
                   <url type="medium">http://ih1.redbubble.net/work.31820.1.flat,300x300,075,f.jpg</url>
                   <url type="large">http://ih1.redbubble.net/work.31820.1.flat,550x550,075,f.jpg</url>
                 </urls>
                 <exif>
                   <model>NIKON D80</model>
                   <make>NIKON CORPORATION</make>
                 </exif>
               </work>
            </works>
         While I doubt the the exif data will change, if the url bit
         does I won't be able to access any thumbnails.

      3. If the XML bit for a picture does not have an image URL of the correct size,
         a model field, or a make field, I flat out ignore it. You need all three.
         You won't see those pictures, models, or makes in output.


3spoopy5me

    (Read this when you find the relevant comment in html_file.rb)
    (Or right now: You're a cool person and I'm not your dad)

    The following method is meant to turn titles into url friendly file names.
        def self.urlify_title(hash)
          title = hash[:title]
          type = hash[:type]
          CGI.escape(type + ' ' + title.downcase.gsub(/[,]/, "")) + ".html"
        end

    Originally, there was no comma deletion. I just used
        def self.urlify_title(hash)
          title = hash[:title]
          type = hash[:type]
          CGI.escape(type + ' ' + title.downcase) + ".html"
        end

    But something weird happened when it hit FUJI PHOTO FILM CO., LTD.
    Like expected, it was turned into 'fuji+photo+film+co.%2C+ltd..html'
    And the links, therefore, all led to:
    file:///Users/maxim/Desktop/coding-test/fuji+photo+film+co.%2C+ltd..html

    I opened the webpage just fine, but none of the links to it worked!
    'This webpage is not found'

    What's more, the file was called 'fuji+photo+film+co.%2C+ltd..html'
    but when I opened the webpage...
    the url said:
    file:///Users/maxim/Desktop/coding-test/fuji+photo+film+co.%252C+ltd..html

    Look at that!
    film+co.%252C+ltd. !!
    %252C.  !!!!
    THERE'S AN EXTRA '52'. WHERE DID IT COME FROM.

    Mate, there's some mysteries that are very difficult to google. This is one of them.
    If you know what's up with all of that, I'd love to hear!
