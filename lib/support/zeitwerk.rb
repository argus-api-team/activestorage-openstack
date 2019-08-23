# frozen_string_literal: true

require 'zeitwerk'

# Openstack Inflector for Zeitwerk
class OpenstackCustomInflector < Zeitwerk::Inflector
  # :reek:ControlParameter imposed by Zeitwerk gem
  def camelize(basename, _abspath)
    case basename
    when 'https_client'
      'HTTPSClient'
    when 'object_store_url'
      'ObjectStoreURL'
    when 'create_temporary_uri'
      'CreateTemporaryURI'
    when 'version'
      'VERSION'
    else
      super
    end
  end
end

loader = Zeitwerk::Loader.new
# loader.logger = method(:puts)
loader.inflector = OpenstackCustomInflector.new
loader.preload("#{GEM_ROOT}/active_storage/service/openstack_service.rb")
loader.push_dir(GEM_ROOT)
loader.ignore(__dir__)
loader.ignore("#{GEM_ROOT}/activestorage_openstack.rb")
loader.setup
