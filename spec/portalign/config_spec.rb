require 'spec_helper'
require 'tempfile'

describe Portalign::Config do
  let(:access_key_id) { "123abc" }
  let(:secret_access_key) { "abc123" }
  let(:ports) { [22,80] }
  let(:security_groups) { ["mygroup"] }

  context "reading from the YAML files" do

    let(:config1) do
      t = Tempfile.new("config1")
      t.write("access_key_id: wrong_key\n")
      t.write("secret_access_key: wrong_key\n")
      t.write("security_groups: #{security_groups.join(',')}\n")
      t.close
      t
    end

    let(:config2) do
      t = Tempfile.new("config2")
      t.write("access_key_id: #{access_key_id}\n")
      t.write("secret_access_key: #{secret_access_key}\n")
      t.write("ports:\n")
      ports.each { |p| t.write("- #{p}\n") }
      t.close
      t
    end

    before do
      Portalign::Config.stub(:config_file_paths).and_return([config1.path, config2.path])
    end

    it "should parse the files in order" do
      Portalign::Config.load_from_file.should == {
        :access_key_id => access_key_id,
        :secret_access_key => secret_access_key,
        :ports => ports,
        :security_groups => security_groups
      }
    end

  end

  context "parsing the CLI options" do
    let(:args) { "--access-key-id=#{access_key_id} --secret-access-key #{secret_access_key} --ports=#{ports.join(',')} -s #{security_groups.join(',')}".split(/\s/) }
    it "should extract all the options" do
      Portalign::Config.parse_opts(args).should == {
        :access_key_id => access_key_id,
        :secret_access_key => secret_access_key,
        :ports => ports,
        :security_groups => security_groups
      }
    end
  end
end
