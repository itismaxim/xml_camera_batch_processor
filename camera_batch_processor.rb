require 'rails'
require 'fileutils'
require 'slop'
require_relative './custom_errors'
require_relative './html_file_processor'

# And AWAAAAAAAAAY we go!
# camera_batch_processor is the outer shell. It takes care of parsing
# the options, reading files, changing directories, and producing the output.
def run

  # I use slop to enable elegant style command line options.
  # See the readme for instructions on how to use them.
  # It makes a nice options hash that contains everything
  # you typed in the command line.
  options = Slop.parse do |option|
    option.string  '-i', '--input-location', "Which directory the XML is in.",
                   default: Dir.pwd
    option.string  '-o', '--output-location', "Which directory you want the HTML files to go.",
                   default: Dir.pwd + '/output'
    option.string  '-t', '--template', "Which HTML template you would like to use.",
                   default: 'output-template.html'
    option.integer '-s', '--size', "What size you'd like the thumbnails: 0 is smallest, 2 is largest.",
                   default: 0
  end
  # As you may have noticed, my style of naming variables and
  # writing help text, error text, and comments tends towards verbose.

  # template_text is the HTML template converted into a string.
  template_text = grab_template(options[:template])

  # The XML has three seperate images in increasing sizes.
  # image_size let's you choose which you to use as thumbnails.
  image_size = options[:size]
  raise InvalidSizeValueError unless [0, 1, 2].include?(image_size)

  # The exif_array contains every exif file in order.
  exif_array = create_exif_array(options[:input_location])

  move_to_output_location(options[:output_location])

  proccesor = HTMLFileProcessor.new({
    exif_array: exif_array,
    image_size: image_size,
  })

  turn_into_html_files(proccesor.html_objects, template_text)
end

# Reads the HTML template and turns it into a string.
# This way I avoid hardcodeing it in.
# It searches around in the same folder as camera_batch_processor.
def grab_template(template_name)
  template_file = Dir.glob(template_name)[0]
  raise NoTemplateError if (template_file) == nil

  accepted_formats = [".txt", ".html"]
  unless accepted_formats.include? File.extname(template_file)
    raise WrongTemplateFormatError
  end

  File.read(template_file)
end

# create_exif_array goes to your input location and grabs
# the first XML file it finds. I was working under the assumption
# that the file in question might not always be called 'works.xml'
# If need be, just change the * to works.
def create_exif_array(input_location)
  raise InvalidInputLocationError unless Dir.exist?(input_location)
  Dir.chdir input_location
  xml_file_to_open = Dir.glob("*.xml")[0]
  raise NoXmlError if xml_file_to_open == nil

  exif_data = File.open(xml_file_to_open) { |xml| Hash.from_xml(xml) }
  exif_data['works']['work']
  # This trims the exif_data, since the two outer layers of the hash are useless to me.
end

# If the Output Location doesn't exist, I make it. Then I move there.
def move_to_output_location(output_location)
  FileUtils.mkdir_p(output_location) unless File.directory?(output_location)
  Dir.chdir output_location
end

# turn_into_html_files recieves HTMLFiles, grabs their strings,
# and writes the completed HTML to a new, properly named file.
def turn_into_html_files(html_objects, template)
  base_address = Dir.pwd + '/'

  html_objects.each_value do |object|
    File.open(object.url, 'w') {|f| f.puts(object.html_string(base_address, template)) }
  end
end

run
