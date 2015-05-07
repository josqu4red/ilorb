require "spec_helper"

describe ILORb do
  let(:hostname) { "10.200.0.1" }
  let(:login) { "Admin" }
  let(:password) { "SECRET" }
  let(:definitions_path) { File.join(File.dirname(__FILE__), "definitions") }
  let(:ilo) { ILORb.new(hostname: hostname, login: login, password: password, definitions_path: definitions_path) }

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

  describe "#certificate_signing_request" do
    before do
      stub_request(:post, "https://10.200.0.1/ribcl")
        .with(body: asset_file("certificate_signing_request_request.xml"))
        .to_return(status: 200, body: asset_file("basic_response.xml"))
    end

    subject do
      ilo.certificate_signing_request(
        csr_state: "state",
        csr_country: "country",
        csr_locality: "locality",
        csr_organization: "organization",
        csr_organizational_unit: "organizational_unit",
        csr_common_name: "common_name"
      )
    end

    its([:status]) { should include(code: 0, message: "No error") }
  end

  describe "#import_certificate" do
    before do
      stub_request(:post, "https://10.200.0.1/ribcl")
        .with(body: asset_file("import_certificate_request.xml"))
        .to_return(status: 200, body: asset_file("basic_response.xml"))
    end

    subject do
      ilo.import_certificate(certificate: asset_file("certificate.crt"))
    end

    its([:status]) { should include(code: 0, message: "No error") }
  end

  describe "#server_auto_pwr" do
    before do
      stub_request(:post, "https://10.200.0.1/ribcl")
        .with(body: asset_file("server_auto_pwr_request.xml"))
        .to_return(status: 200, body: asset_file("basic_response.xml"))
    end

    subject do
      ilo.server_auto_pwr(value: "On")
    end

    its([:status]) { should include(code: 0, message: "No error") }
  end

  private

  def asset_file(asset)
    File.open(File.join(File.dirname(__FILE__), "assets", asset)).read
  end
end
