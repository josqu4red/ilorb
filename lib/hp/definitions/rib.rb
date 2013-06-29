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
  read_cmd :get_network_settings
  read_cmd :get_security_msg
  read_cmd :get_snmp_im_settings
  read_cmd :get_spatial

  write_cmd :brownout_recovery
  write_cmd :certificate_signing_request
  write_cmd :clear_eventlog
  write_cmd :factory_defaults
  write_cmd :fips_enable
  write_cmd :import_certificate
  write_cmd :license
  write_cmd :mod_global_settings
  write_cmd :mod_network_settings
  write_cmd :mod_snmp_im_settings
  write_cmd :reset_rib
  write_cmd :update_firmware
end
