# frozen_string_literal: true

require 'zeitwerk'

# Openstack Inflector for Zeitwerk
class OpenstackCustomInflector < Zeitwerk::Inflector
  # :reek:ControlParameter imposed by Zeitwerk gem
  def camelize(basename, _abspath)
    if configuration.key?(basename)
      configuration.fetch(basename)
    else
      super
    end
  end

  private

  def configuration
    {
      'https_client' => 'HTTPSClient',
      'object_store_url' => 'ObjectStoreURL',
      'create_temporary_uri' => 'CreateTemporaryURI',
      'version' => 'VERSION'
    }
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
