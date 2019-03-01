# frozen_string_literal: true

require_relative 'support/zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.inflector = CustomInflector.new
loader.ignore(__FILE__) # this file does not define ActivestorageOpenstack
loader.setup
