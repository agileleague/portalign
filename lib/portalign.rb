require "open-uri"
require "aws"

require File.join(File.dirname(__FILE__), "portalign", "version")
require File.join(File.dirname(__FILE__), "portalign", "config")

class Portalign
  CHECK_IP_URL = "http://checkip.dyndns.org"
  CHECK_IP_REGEX = /(\d+\.){3}\d+/

  def self.config(args)
    config = {
      :ports => 22,
      :wide => false,
      :deauthorize => false,
      :protocol => "tcp"
    }.merge!(Config.load_from_file).merge!(Config.parse_opts(args))
  end

  def self.update_security_group(ip_address, security_groups, ports, protocol = "tcp")
    ports = ports.is_a?(Array) ? ports : [ports]
    security_groups = security_groups.is_a?(Array) ? security_groups : [security_groups]

    if ip_address
      authorize_ingress(ip_address, security_groups, ports, protocol)
    else
      deauthorize_ingress(ip_address, security_groups, ports, protocol)
    end
  end

  def self.authorize_ingress(ip_address, security_groups, ports, protocol)
    security_groups.each do |security_group|
      ports.each do |port|
        ec2_instance.authorize_security_group_IP_ingress(security_group, port, port, protocol, "#{ip_address}/32")
      end
    end
  end

  def self.deauthorize_ingress(ip_address, security_groups, ports, protocol)
    security_groups.each do |security_group|
      ports.each do |port|
        # We deauthorize both the specific IP and also the wide open IP
        ec2_instance.revoke_security_group_IP_ingress(security_group, port, port, protocol, "#{ip_address}/32")
        ec2_instance.revoke_security_group_IP_ingress(security_group, port, port, protocol, "0.0.0.0/0")
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
