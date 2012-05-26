require 'spec_helper'

describe Portalign do

  let(:portalign_config) do
    {
      :access_key_id => "54321",
      :secret_access_key => "12345",
      :security_groups => "portalign",
      :ports => 22,
      :protocol => "tcp"
    }
  end

  let(:current_ip) { "66.56.44.38" }

  let(:checkip_response) do
    "<html><head><title>Current IP Check</title></head><body>Current IP Address: #{current_ip}</body></html>"
  end

  let(:ec2_instance) { stub("ec2_instance") }

  before do
    Portalign.stub(:call_checkip).and_return(checkip_response)
  end

  context "#resolve_ip" do
    it "should call checkip" do
      Portalign.should_receive(:call_checkip).and_return(checkip_response)
      Portalign.resolve_ip
    end

    it "should get the correct IP address" do
      Portalign.resolve_ip.should == current_ip
    end
  end

  context "#authorize_ingress" do
    context "successfully" do
      it "should update the security group" do
        ec2_instance.should_receive(:authorize_security_group_IP_ingress).with(
          portalign_config[:security_groups],
          portalign_config[:ports],
          portalign_config[:ports],
          "tcp",
          "#{current_ip}/32"
        )

        Portalign.authorize_ingress(ec2_instance, current_ip, Portalign::NARROW_CIDR, [portalign_config[:security_groups]], [portalign_config[:ports]], portalign_config[:protocol])
      end
    end
  end

  context "#deauthorize_ingress" do
    context "successfully" do
      it "should update the security group" do
        ec2_instance.should_receive(:revoke_security_group_IP_ingress).with(
          portalign_config[:security_groups],
          portalign_config[:ports],
          portalign_config[:ports],
          "tcp",
          "#{current_ip}/32"
        )

        ec2_instance.should_receive(:revoke_security_group_IP_ingress).with(
          portalign_config[:security_groups],
          portalign_config[:ports],
          portalign_config[:ports],
          "tcp",
          "0.0.0.0/0"
        )

        Portalign.deauthorize_ingress(ec2_instance, current_ip, Portalign::NARROW_CIDR, [portalign_config[:security_groups]], [portalign_config[:ports]], portalign_config[:protocol])
      end
    end
  end
end
