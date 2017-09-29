$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'puppet/provider/elastic_rest'

begin
  require 'puppet_x/elastic/deep_to_i'
rescue LoadError
  require 'pathname' # WORK_AROUND #14073 and #7788
  require File.join(File.dirname(__FILE__), '../../../puppet_x/elastic/deep_to_i')
end

Puppet::Type.type(:elasticsearch_template).provide(
  :ruby,
  :parent => Puppet::Provider::ElasticREST,
  :api_uri => '_template',
  :metadata => :content,
  :metadata_pipeline => [
    lambda { |data| Puppet_X::Elastic.deep_to_i data }
  ]
) do
  desc 'A REST API based provider to manage Elasticsearch templates.'

  mk_resource_methods
end
