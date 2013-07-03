context :server_info do
  read_cmd :get_embedded_health
  read_cmd :get_host_power_saver_status
  read_cmd :get_host_power_status
  read_cmd :get_host_pwr_micro_ver
  read_cmd :get_power_cap
  read_cmd :get_power_readings
  read_cmd :get_pwreg
  read_cmd :get_server_auto_pwr
  read_cmd :get_server_name
  read_cmd :get_server_power_on_time
  read_cmd :get_uid_status

  write_cmd :clear_server_power_on_time
  write_cmd :cold_boot_server
  write_cmd :reset_server
  write_cmd :warm_boot_server
  write_cmd :hold_pwr_btn do
    attributes :toggle
  end
  write_cmd :server_auto_pwr do
    attributes :value # = yes/no/random/restore
  end
  write_cmd :server_name do
    attributes :value # = hostname
  end
  write_cmd :set_host_power do
    attributes :host_power # = yes/no
  end
  write_cmd :set_host_power_saver do
    attributes :host_power_saver # = [1-4] (doc)
  end
  write_cmd :set_power_cap do
    attributes :power_cap # = N
  end
  write_cmd :set_pwreg do
    elements :pwralert, :pwralert_settings # <pwralert type="peak"/> <pwralert_settings threshold="200" duration="35"/>
  end
  write_cmd :uid_control do
    attributes :uid # = yes/no
  end
end
