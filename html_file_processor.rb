require_relative './html_file'

# The HTMLFileProcessor rips the relevant information from each entry in the
# exif_array and turns it into a slimmed down HTMLFile.
class HTMLFileProcessor
  attr_reader :html_objects

  def initialize(options)
    @exif_array = options[:exif_array]
    @image_size = options[:image_size]

    # The exif_array contains information for each PICTURE. But I don't need
    # an html file for each picture: I need one for each Model of camera,
    # one for each Make of camera, and one for the Index.
    # @html_objects stores all of them.
    @html_objects = {}
    construct_model_objects
    construct_make_objects
    construct_index_object
    @html_objects = @html_objects.merge(@all_make_objects).merge(@all_model_objects)
  end


  # The exif_array contains one entry for every picture, each which hase a model.
  # construct_model_objects collapses this information: each model now has many
  # pictures, instead of each picture having only one model.
  def construct_model_objects

    # Eventually the index will need thumbnials too. I'll collect them
    # while I iterate through the works.
    @first_ten_thumbnails = []
    @all_model_objects = {}

    @exif_array.each do |work|
      model = work['exif']['model']
      make = work['exif']['make']
      url = work['urls']['url'][@image_size]

      # Some of the works in the XML file don't have makes and models.
      # I've chosen to ignore those entries entirely. They don't even appear
      # as thumbnails in the index. NO CREDIT FOR PARTIAL ANSWERS, MAGGOT!
      if make && model && url

        # If it doesn't already exist there, I add this model
        # to the @all_model_objects hash. I give the model the only two
        # navigation links it will need: Back to Index and Back to Make.
        @all_model_objects[model] = HTMLFile.new({
          title: model,
          type: 'model',
          nav_links_back: [
            {title: 'Index', type: ""},
            {title: make,    type: 'make'}
          ]
        }) unless @all_model_objects[model]

        # And now I add the thumbnail picture to the list of thumbnails.
        @first_ten_thumbnails << url if @first_ten_thumbnails.length < 10
        @all_model_objects[model].thumbnails << url
      end
    end
  end

  # To make the HTMLFiles for different camera makes*, I repeat the above
  # trick. I make the hash @all_make_objects, which has many models belonging
  # to one make, instead of having each model having one make.
  def construct_make_objects
    @all_make_objects = {}

    @all_model_objects.each do |key, value|
      model = key
      make = value.nav_links_back[1][:title]
      # [1] because, as you'll notice above, the first entry in the nav_links
      # array is always back to index. The second is always back to make.

      @all_make_objects[make] = HTMLFile.new({
        title: make,
        type: 'make',
        nav_links_back: [{title: 'Index', type: ""}]
        }) unless @all_make_objects[make]

      @all_make_objects[make].nav_links << { title: model, type: 'model' }

      # I add all the thumbnails from that model to this make. Regardless
      # of how many thumbnails I have, I only keep the first ten.
      if @all_make_objects[make].thumbnails.length < 10
        @all_make_objects[make].thumbnails = (@all_make_objects[make].thumbnails + value.thumbnails)[0..9]
      end
    end
  end

  # Yep, same bloody thing. The index needs a link to every make, so I cycle
  # through the list of makes I've already prepared. Each step of the pyramid
  # helps build the next.
  def construct_index_object
    @html_objects['Index'] = HTMLFile.new({
        title: "Index",
        type: ''
      })

    @html_objects['Index'].nav_links = @all_make_objects.keys.map do |key|
      {title: key, type: 'make'}
    end

    @html_objects['Index'].thumbnails = @first_ten_thumbnails
  end
end

# * Why call it a make? Wouldn't brand be a more accurate word?
#   Or manafacturer? Or company? I have some questions for the
#   people who came up with exif.
