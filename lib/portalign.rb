require "open-uri"
require "aws"

require File.join(File.dirname(__FILE__), "portalign", "version")
require File.join(File.dirname(__FILE__), "portalign", "config")

class Portalign
  CHECK_IP_URL = "http://checkip.dyndns.org"
  CHECK_IP_REGEX = /(\d+\.){3}\d+/

  NARROW_CIDR = "32"
  WIDE_IP = "0.0.0.0"
  WIDE_CIDR = "0"

  def self.build_config(args)
    {
      :ports => [22],
      :wide => false,
      :deauthorize => false,
      :protocol => "tcp"
    }.merge!(Config.load_from_file).merge!(Config.parse_opts(args))
  end

  def self.validate_config(config)
    Config.validate_config(config)
  end

  def self.run(config)
    ip_address = resolve_ip

    ec2 = ec2_instance(config[:access_key_id], config[:secret_access_key])

    if config[:deauthorize]
      deauthorize_ingress(ec2, ip_address, NARROW_CIDR, config[:security_groups], config[:ports], config[:protocol])
    elsif config[:wide]
      authorize_ingress(ec2, WIDE_IP, WIDE_CIDR, config[:security_groups], config[:ports], config[:protocol])
    else
      authorize_ingress(ec2, ip_address, NARROW_CIDR, config[:security_groups], config[:ports], config[:protocol])
    end
  end

  def self.authorize_ingress(ec2, ip_address, cidr, security_groups, ports, protocol)
    security_groups.each do |security_group|
      ports.each do |port|
        ec2.authorize_security_group_IP_ingress(security_group, port, port, protocol, "#{ip_address}/#{cidr}")
      end
    end
  end

  def self.deauthorize_ingress(ec2, ip_address, cidr, security_groups, ports, protocol)
    security_groups.each do |security_group|
      ports.each do |port|
        # We deauthorize both the specific IP and also the wide open IP
        ec2.revoke_security_group_IP_ingress(security_group, port, port, protocol, "#{ip_address}/#{cidr}")
        ec2.revoke_security_group_IP_ingress(security_group, port, port, protocol, "#{WIDE_IP}/#{WIDE_CIDR}")
      end
    end
  end

  def self.resolve_ip
    parse_checkip(call_checkip)
  end

  protected

  def self.ec2_instance(access_key_id, secret_access_key)
    @ec2_instance ||= Aws::Ec2.new(access_key_id, secret_access_key)
  end

  def self.call_checkip
    # TODO: Put some guards around this in case of timeout, 404, etc.
    open("http://checkip.dyndns.org").read
  end

  def self.parse_checkip(response)
    match_data = CHECK_IP_REGEX.match(response)
    match_data ? match_data[0] : nil
  end
end
