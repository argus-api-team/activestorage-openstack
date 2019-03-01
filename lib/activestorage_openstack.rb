# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
# loader.logger = method(:puts) # For debug
loader.setup
