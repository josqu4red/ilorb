context :rib_info do
  read_cmd :get_ahs_status
  read_cmd :get_all_languages
  read_cmd :get_all_licenses
  read_cmd :get_asset_tag
  read_cmd :get_ers_settings
  read_cmd :get_event_log
  read_cmd :get_fips_status
  read_cmd :get_fw_version
  read_cmd :get_global_settings
  read_cmd :get_hotkey_config
  read_cmd :get_language
  read_cmd :get_all_languages
  read_cmd :get_network_settings
  read_cmd :get_security_msg
  read_cmd :get_snmp_im_settings
  read_cmd :get_spatial
  read_cmd :get_vm_status do
    attributes :device
  end
  read_cmd :profile_apply_get_results do
    not_implemented
  end
  read_cmd :profile_list do
    not_implemented
  end

  write_cmd :ahs_clear_data
  write_cmd :brownout_recovery # > mod_global_settings
  write_cmd :certificate_signing_request do
    elements :csr_state, :csr_country, :csr_locality, :csr_organization, :csr_organizational_unit, :csr_common_name
  end
  write_cmd :clear_eventlog
  write_cmd :computer_lock do
    not_implemented
  end
  write_cmd :disable_ers
  write_cmd :eject_virtual_media do
    attributes :device
  end
  write_cmd :factory_defaults
  write_cmd :fips_enable
  write_cmd :hotkey_config do
    not_implemented
  end
  write_cmd :import_certificate do
    text :certificate
  end
  write_cmd :insert_virtual_media do
    attributes :device, :image_url
  end
  write_cmd :license do
    elements activate: :key
  end
  write_cmd :mod_global_settings do
    elements :session_timeout, :f8_prompt_enabled, :http_port, :https_port, :remote_console_port, :min_password,
             :ilo_funct_enabled, :virtual_media_port, :f8_login_required, :enforce_aes, :authentication_failure_logging,
             :ssh_status, :ssh_port, :serial_cli_status, :serial_cli_speed, :rbsu_post_ip, :snmp_access_enabled,
             :snmp_port, :snmp_trap_port, :remote_syslog_enable, :remote_syslog_port, :remote_syslog_server_address,
             :alertmail_enable, :alertmail_email_address, :alertmail_sender_domain, :alertmail_smtp_server,
             :ipmi_dcmi_over_lan_enabled, :vsp_log_enable
  end
  write_cmd :mod_network_settings do
    elements :enable_nic, :nic_speed, :full_duplex, :speed_autoselect, :ping_gateway,
             :shared_network_port, :vlan_enabled, :vlan_id,
             :dhcp_enable, :dhcp_domain_name, :dhcp_gateway, :dhcp_dns_server, :dhcp_wins_server, :dhcp_static_route,
             :dhcp_sntp_settings, :ip_address, :subnet_mask, :gateway_ip_address, :dns_name, :domain_name,
             :prim_dns_server, :sec_dns_server, :ter_dns_server, :reg_ddns_server,
             :prim_wins_server, :sec_wins_server, :reg_wins_server,
             :sntp_server1, :sntp_server2, :timezone,
             :enclosure_ip_enable, :web_agent_ip_address
  end
  write_cmd :mod_snmp_im_settings do # TODO
    not_implemented
  end
  write_cmd :profile_apply do
    not_implemented
  end
  write_cmd :profile_delete do
    not_implemented
  end
  write_cmd :profile_desc_download do
    not_implemented
  end
  write_cmd :reset_rib
  write_cmd :set_ahs_status do
    attributes :value
  end
  write_cmd :set_asset_tag do
    attributes :value
  end
  write_cmd :set_ers_irs_connect do
    elements :ers_destination_url, :ers_destination_port
  end
  write_cmd :set_language do
    attributes :lang_id
  end
  write_cmd :set_security_msg do
    not_implemented
    elements :security_msg, security_msg_text: :cdata
  end
  write_cmd :set_vm_status do
    attributes :device
    elements :vm_boot_option, :vm_write_protect
  end
  write_cmd :trigger_l2_collection do
    not_implemented
  end
  write_cmd :trigger_test_event do
    not_implemented
  end
  write_cmd :update_firmware do # TODO
    not_implemented
  end
end
