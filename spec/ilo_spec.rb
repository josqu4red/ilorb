require "spec_helper"

describe ILORb do
  let(:hostname) { "10.200.0.1" }
  let(:login) { "Admin" }
  let(:password) { "SECRET" }
  let(:ilo) { ILORb.new(hostname: hostname, login: login, password: password) }

  describe "#get_network_settings" do
    before do
      stub_request(:post, "https://10.200.0.1/ribcl")
        .with(body: asset_file("get_network_settings_request.xml"))
        .to_return(status: 200, body: asset_file("get_network_settings_response.xml"))
    end

    subject { ilo.get_network_settings }

    its([:status]) { should include(code: 0, message: "No error") }
    its([:get_network_settings]) { should_not be_empty }
  end

  describe "#set_one_time_boot" do
    before do
      stub_request(:post, "https://10.200.0.1/ribcl")
        .with(body: asset_file("set_one_time_boot_request.xml"))
        .to_return(status: 200, body: asset_file("basic_response.xml"))
    end

    subject { ilo.set_one_time_boot(value: "FLOPPY") }

    its([:status]) { should include(code: 0, message: "No error") }
  end

  describe "#set_pwreg" do
    before do
      stub_request(:post, "https://10.200.0.1/ribcl")
        .with(body: asset_file("set_pwreg_request.xml"))
        .to_return(status: 200, body: asset_file("basic_response.xml"))
    end

    subject { ilo.set_pwreg(pwralert_type: "PEAK", pwralert_settings_threshold: 200, pwralert_settings_duration: 35) }

    its([:status]) { should include(code: 0, message: "No error") }
  end

  describe "#set_persistent_boot" do
    before do
      stub_request(:post, "https://10.200.0.1/ribcl")
        .with(body: asset_file("set_persistent_boot_request.xml"))
        .to_return(status: 200, body: asset_file("basic_response.xml"))
    end

    subject { ilo.set_persistent_boot([{ device_value: "FLOPPY" }, { device_value: "CDROM" }]) }

    its([:status]) { should include(code: 0, message: "No error") }
  end

  private

  def asset_file(asset)
    File.open(File.join(File.dirname(__FILE__), "assets", asset)).read
  end
end
