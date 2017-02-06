# I like writing error messages that are helpful and in english.
# Mostly because I hate looking at error messages and wondering
# what on earth they mean.

class NoXmlError < StandardError
  def initialize(msg="There is no XML file at the input location.")
    super
  end
end

class InvalidInputLocationError < StandardError
  def initialize(msg="The Input Location directory does not exist.")
    super
  end
end

class InvalidSizeValueError < StandardError
  def initialize(msg="The Size integer must be between 0, 1, or 2.")
    super
  end
end

class NoTemplateError < StandardError
  def initialize(msg="The HTML template does not exist in this directory.")
    super
  end
end

class WrongTemplateFormatError < StandardError
  def initialize(msg="The Template file must be either .txt or .html.")
    super
  end
end
