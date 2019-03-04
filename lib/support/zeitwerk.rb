# frozen_string_literal: true

require 'zeitwerk'

# Inflector for Zeitwerk
class CustomInflector < Zeitwerk::Inflector
  # :reek:ControlParameter imposed by Zeitwerk gem
  def camelize(basename, _abspath)
    case basename
    when 'https_client'
      'HTTPSClient'
    when 'object_store_url'
      'ObjectStoreURL'
    else
      super
    end
  end
end

loader = Zeitwerk::Loader.new
loader.push_dir(GEM_ROOT)
loader.inflector = CustomInflector.new
loader.ignore("#{GEM_ROOT}/activestorage_openstack.rb")
loader.setup
