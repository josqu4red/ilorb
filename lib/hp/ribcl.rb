module HP
  RIBCL = {
    # RIB_INFO
    :get_ahs_status => {:context => :rib_info, :mode => :read},
    :get_all_languages => {:context => :rib_info, :mode => :read},
    :get_all_licenses => {:context => :rib_info, :mode => :read},
    :get_asset_tag => {:context => :rib_info, :mode => :read},
    :get_ers_settings => {:context => :rib_info, :mode => :read},
    :get_event_log => {:context => :rib_info, :mode => :read},
    :get_fips_status => {:context => :rib_info, :mode => :read},
    :get_fw_version => {:context => :rib_info, :mode => :read},
    :get_global_settings => {:context => :rib_info, :mode => :read},
    :get_hotkey_config => {:context => :rib_info, :mode => :read},
    :get_language => {:context => :rib_info, :mode => :read},
    :get_network_settings => {:context => :rib_info, :mode => :read},
    :get_security_msg => {:context => :rib_info, :mode => :read},
    :get_snmp_im_settings => {:context => :rib_info, :mode => :read},
    :get_spatial => {:context => :rib_info, :mode => :read},

    :brownout_recovery => {:context => :rib_info, :mode => :write},
    :certificate_signing_request => {:context => :rib_info, :mode => :write},
    :clear_eventlog => {:context => :rib_info, :mode => :write},
    :factory_defaults => {:context => :rib_info, :mode => :write},
    :fips_enable => {:context => :rib_info, :mode => :write},
    :import_certificate => {:context => :rib_info, :mode => :write},
    :license => {:context => :rib_info, :mode => :write},
    :mod_global_settings => {:context => :rib_info, :mode => :write},
    :mod_network_settings => {:context => :rib_info, :mode => :write},
    :mod_snmp_im_settings => {:context => :rib_info, :mode => :write},
    :reset_rib => {:context => :rib_info, :mode => :write},
    :update_firmware => {:context => :rib_info, :mode => :write},

    # SERVER_INFO
    :get_embedded_health => {:context => :server_info, :mode => :read},
    :get_host_power_saver_status => {:context => :server_info, :mode => :read},
    :get_host_power_status => {:context => :server_info, :mode => :read},
    :get_host_pwr_micro_ver => {:context => :server_info, :mode => :read},
    :get_power_cap => {:context => :server_info, :mode => :read},
    :get_power_readings => {:context => :server_info, :mode => :read},
    :get_pwreg => {:context => :server_info, :mode => :read},
    :get_server_auto_pwr => {:context => :server_info, :mode => :read},
    :get_server_name => {:context => :server_info, :mode => :read},
    :get_server_power_on_time => {:context => :server_info, :mode => :read},
    :get_uid_status => {:context => :server_info, :mode => :read},

    :clear_server_power_on_time => {:context => :server_info, :mode => :write},
    :cold_boot_server => {:context => :server_info, :mode => :write},
    :hold_pwr_btn => {:context => :server_info, :mode => :write, :attributes => [:toggle]},
    :reset_server => {:context => :server_info, :mode => :write},
    :server_auto_pwr => {:context => :server_info, :mode => :write}, # value = yes/no/random/restore
    :server_name => {:context => :server_info, :mode => :write, :attributes => [:value]}, # value = hostname
    :set_host_power => {:context => :server_info, :mode => :write, }, # host_power = yes/no
    :set_host_power_saver => {:context => :server_info, :mode => :write}, # host_power_saver = [1-4] (doc)
    :set_power_cap => {:context => :server_info, :mode => :write}, # power_cap = n
    :set_pwreg => {:context => :server_info, :mode => :write}, # <pwralert type="peak"/> <pwralert_settings threshold="200" duration="35"/>
    :uid_control => {:context => :server_info, :mode => :write}, # uid= yes/no
    :warm_boot_server => {:context => :server_info, :mode => :write},

    # USER_INFO
    :get_user => {:context => :user_info, :mode => :read, :attributes => [:user_login]},
    :get_all_users => {:context => :user_info, :mode => :read},
    :get_all_user_info => {:context => :user_info, :mode => :read},

    :add_user => {:context => :user_info, :mode => :write, :attributes => [:user_name, :user_login, :password], :elements => [:admin_priv, :remote_cons_priv, :reset_server_priv, :virtual_media_priv, :config_ilo_priv]},
    :delete_user => {:context => :user_info, :mode => :write, :attributes => [:user_login]},
    :mod_user => {:context => :user_info, :mode => :write, :attributes => [:user_login], :elements => [:user_name, :user_login, :password, :admin_priv, :remote_cons_priv, :reset_server_priv, :virtual_media_priv, :config_ilo_priv, :del_users_ssh_key]},
  }
end
