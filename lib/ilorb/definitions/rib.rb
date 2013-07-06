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
  write_cmd :certificate_signing_request
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
  write_cmd :import_certificate do #TODO
    not_implemented
    text :certificate
  end
  write_cmd :insert_virtual_media do
    attributes :device, :image_url
  end
  write_cmd :license do
    elements :activate => :key
  end
  write_cmd :mod_global_settings do #TODO
    not_implemented
  end
  write_cmd :mod_network_settings do #TODO
    not_implemented
  end
  write_cmd :mod_snmp_im_settings do #TODO
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
    elements :security_msg, :security_msg_text => :cdata
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
  write_cmd :update_firmware do #TODO
    not_implemented
  end
end
