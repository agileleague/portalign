require 'yaml'
require 'optparse'

class Portalign
  module Config
    CONFIG_FILE_NAME = ".portalign.yml"
    CONFIG_FILE_PATHS = ["#{ENV["HOME"]}/#{CONFIG_FILE_NAME}", "#{CONFIG_FILE_NAME}"]

    def self.load_from_file
      {}.tap do |config|
        config_file_paths.each do |config_path|
          if File.exist?(config_path)
            YAML.load_file(config_path).each do |k,v|
              config[k.to_sym] = v
            end
          end
        end

        %w(ports security_groups).each {|opt| force_array(config, opt)}
      end
    end

    def self.parse_opts(args)
      {}.tap do |config|
        opts = OptionParser.new do |opts|
          opts.banner = "Usage: portalign [options]"
          opts.separator ""
          opts.separator "General options:"
          opts.on("--access-key-id=ACCESS_KEY_ID", "The AWS access key id. Better to specify in a config file. See README") do |access_key_id|
            config[:access_key_id] = access_key_id
          end
          opts.on("--secret-access-key=SECRET_ACCESS_KEY", "The AWS secret access key. Better to specify in a config file. See README") do |secret_access_key|
            config[:secret_access_key] = secret_access_key 
          end
          opts.on("-r REGION", "--region=REGION", "The AWS region.  AWS's default is us-east") do |region|
            config[:region] = region
          end
          opts.on("-p PORTS", "--ports=PORTS", Array, "A comma delimited list of ports to align. Defaults to 22") do |ports|
            config[:ports] = ports.map(&:to_i)
          end
          opts.on("-s SECURITY_GROUPS", "--security_groups=SECURITY_GROUPS", Array, "A comma delimited list of security groups to update.") do |security_groups|
            config[:security_groups] = security_groups
          end
          opts.on("--protocol=PROTOCOL", [:tcp, :udp, :icmp], "The protocol to use. Defaults to tcp.") do |protocol|
            config[:protocol] = protocol
          end
          opts.on("-d", "--deauthorize", "Remove the current IP (and 0.0.0.0/0) from the security groups.") do |deauthorize|
            config[:deauthorize] = deauthorize
          end
          opts.on("-w", "--wide", "Authorizes 0.0.0.0/0 in the security groups.") do |wide|
            config[:wide] = wide
          end
          opts.separator ""
          opts.separator "Common options:"
          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end
          opts.on_tail("-v", "--version", "Show version") do
            puts "portalign v#{Portalign::VERSION}"
            exit
          end
        end

        opts.parse!(args)

        %w(ports security_groups).each {|opt| force_array(config, opt)}
      end
    end

    def self.validate_config(config)
      unless config.keys.include?(:access_key_id) && config.keys.include?(:secret_access_key)
        return [false, "You must specify an AWS access_key_id and secret_access_key"]
      end

      unless config[:security_groups] && config[:security_groups].any?
        return [false, "You must specify at least one security group."]
      end

      true
    end

    protected

    def self.config_file_paths
      CONFIG_FILE_PATHS
    end

    def self.force_array(config, option)
      option = option.to_sym
      if config[option]
        config[option] = config[option].is_a?(Array) ? config[option] : [config[option]]
      end
    end
  end
end
