require 'puppet/provider/elastic_user_command'

Puppet::Type.type(:elasticsearch_user).provide(
  :esusers,
  :parent => Puppet::Provider::ElasticUserCommand
) do
  desc "Provider for Shield file (esusers) user resources."

  mk_resource_methods

  @command_arguments = ["--default.path.conf=#{homedir}"]

  commands :users_cli => "#{homedir}/bin/shield/esusers"
  commands :es => "#{homedir}/bin/elasticsearch"
end
