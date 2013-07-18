require 'spec_helper'

describe ILORb::ILO do
  let(:hostname) { "10.200.0.1" }
  let(:login) { "Admin" }
  let(:password) { "SECRET" }
  let(:ilo) { ILORb::ILO.new(hostname: hostname, login: login, password: password) }

  describe "#get_network_settings" do
    before do
      stub_request(:post, "https://10.200.0.1/ribcl").
        with(:body => "<?xml version=\"1.0\"?>\n<ribcl version=\"2.0\">\n  <login password=\"SECRET\" user_login=\"Admin\">\n    <rib_info mode=\"read\">\n      <get_network_settings/>\n    </rib_info>\n  </login>\n</ribcl>\n").
        to_return(:status => 200, :body => asset_file('get_network_settings_response.xml'))
    end

    subject { ilo.get_network_settings }

    its([:status]) { should include(code: 0, message: 'No error') }
    its([:get_network_settings]) { should_not be_empty }
  end

  describe "#set_one_time_boot" do
    before do
      stub_request(:post, "https://10.200.0.1/ribcl").
        with(:body => "<?xml version=\"1.0\"?>\n<ribcl version=\"2.0\">\n  <login password=\"SECRET\" user_login=\"Admin\">\n    <server_info mode=\"write\">\n      <set_one_time_boot value=\"FLOPPY\"/>\n    </server_info>\n  </login>\n</ribcl>\n").
        to_return(:status => 200, :body => asset_file('basic_response.xml'))
    end

    subject { ilo.set_one_time_boot(value: "FLOPPY") }

    its([:status]) { should include(code: 0, message: 'No error') }
  end

  describe "#set_pwreg" do
    before do
      stub_request(:post, "https://10.200.0.1/ribcl").
        with(:body => "<?xml version=\"1.0\"?>\n<ribcl version=\"2.0\">\n  <login password=\"SECRET\" user_login=\"Admin\">\n    <server_info mode=\"write\">\n      <set_pwreg>\n        <pwralert type=\"PEAK\"/>\n        <pwralert_settings threshold=\"200\" duration=\"35\"/>\n      </set_pwreg>\n    </server_info>\n  </login>\n</ribcl>\n").
        to_return(:status => 200, :body => asset_file('basic_response.xml'))
    end

    subject { ilo.set_pwreg pwralert_type: "PEAK",
                            pwralert_settings_threshold: 200,
                            pwralert_settings_duration: 35 }

    its([:status]) { should include(code: 0, message: 'No error') }
  end

  describe "#set_one_time_boot" do
    before do
      stub_request(:post, "https://10.200.0.1/ribcl").
        with(:body => "<?xml version=\"1.0\"?>\n<ribcl version=\"2.0\">\n  <login password=\"SECRET\" user_login=\"Admin\">\n    <server_info mode=\"write\">\n      <set_one_time_boot value=\"FLOPPY\"/>\n    </server_info>\n  </login>\n</ribcl>\n").
        to_return(:status => 200, :body => asset_file('basic_response.xml'))
    end

    subject { ilo.set_one_time_boot(value: "FLOPPY") }

    its([:status]) { should include(code: 0, message: 'No error') }
  end

  private

  def asset_file(asset)
    path = File.join(File.dirname(__FILE__), 'assets', asset)
    File.new(path)
  end
end
