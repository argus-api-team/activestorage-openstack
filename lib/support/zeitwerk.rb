# frozen_string_literal: true

require 'zeitwerk'

# Inflector for Zeitwerk
class CustomInflector < Zeitwerk::Inflector
  # :reek:ControlParameter
  def camelize(basename, _abspath)
    case basename
    when 'https_client'
      'HTTPSClient'
    else
      super
    end
  end
end
