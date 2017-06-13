# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet/provider/elastic_parsedfile'
require 'puppet/util/package'
require 'puppet_x/elastic/hash'

# Puppet namespace
module Puppet
  # Provider namespace
  module Provider
    # Provider for yaml-based Elasticsearch configuration files.
    class ElasticYaml < Puppet::Provider::ElasticParsedFile
      class << self
        attr_accessor :metadata
      end

      # Transform a given string into a Hash-based representation of the
      # provider.
      def self.parse(text)
        yaml = YAML.load text
        if yaml
          yaml.map do |key, metadata|
            {
              :name => key,
              :ensure => :present,
              @metadata => metadata
            }
          end
        else
          []
        end
      end

      # Transform a given list of provider records into yaml-based
      # representation.
      def self.to_file(records)
        yaml = records.map do |record|
          # Convert top-level symbols to strings
          Hash[record.map { |k, v| [k.to_s, v] }]
        end.inject({}) do |hash, record|
          # Flatten array of hashes into single hash
          hash.merge({ record['name'] => record.delete(@metadata.to_s) })
        end.extend(Puppet_X::Elastic::SortedHash).to_yaml.split("\n")

        yaml.shift if yaml.first =~ /---/
        yaml = yaml.join("\n")

        # Puppet < 4 uses ZAML, which prepends spaces in to_yaml... why
        unless Puppet::Util::Package.versioncmp(Puppet.version, '4') >= 0
          yaml.gsub!(/^\s{2}/, '')
        end

        yaml << "\n"
      end

      def self.skip_record?(_record)
        false
      end

      # This is ugly, but it's overridden in ParsedFile with abstract
      # functionality we don't need for our simple provider class.
      # This has been observed to break in Puppet version 3/4 switches.
      def self.valid_attr?(klass, attr_name)
        klass.is_a? Class ? klass.parameters.include?(attr_name) : true
      end
    end
  end
end
