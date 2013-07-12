context :server_info do
  read_cmd :get_embedded_health
  read_cmd :get_host_power_saver_status
  read_cmd :get_host_power_status
  read_cmd :get_host_pwr_micro_ver
  read_cmd :get_one_time_boot
  read_cmd :get_persistent_boot
  read_cmd :get_power_cap
  read_cmd :get_power_readings
  read_cmd :get_pwreg
  read_cmd :get_server_auto_pwr
  read_cmd :get_server_name
  read_cmd :get_server_power_on_time
  read_cmd :get_uid_status

  write_cmd :clear_server_power_on_time
  write_cmd :cold_boot_server
  write_cmd :hold_pwr_btn do
    attributes :toggle
  end
  write_cmd :press_power_btn
  write_cmd :reset_server
  write_cmd :server_auto_pwr do
    attributes :value
  end
  write_cmd :server_name do
    attributes :value
  end
  write_cmd :set_host_power do
    attributes :host_power
  end
  write_cmd :set_host_power_saver do
    attributes :host_power_saver
  end
  write_cmd :set_one_time_boot do
    attributes :value
  end
  write_cmd :set_persistent_boot do
    not_implemented
  end
  write_cmd :set_power_cap do
    attributes :power_cap
  end
  write_cmd :set_pwreg do
    elements :pwralert => :type, :pwralert_settings => [:threshold, :duration]
  end
  write_cmd :uid_control do
    attributes :uid
  end
  write_cmd :warm_boot_server
end
