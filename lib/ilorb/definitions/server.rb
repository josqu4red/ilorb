context :server_info do
  read_cmd :get_tpm_status

  read_cmd :get_current_boot_mode

  read_cmd :get_pending_boot_mode
  write_cmd :set_pending_boot_mode do
    attributes :value
  end

  read_cmd :get_persistent_boot
  write_cmd :set_persistent_boot do
    elements device: [:value]
  end

  read_cmd :get_one_time_boot
  write_cmd :set_one_time_boot do
    attributes :value
  end

  read_cmd :get_supported_boot_mode

  read_cmd :get_server_name
  write_cmd :server_name do
    attributes :value
  end

  read_cmd :get_server_fqdn
  write_cmd :server_fqdn do
    attributes :value
  end

  read_cmd :get_smh_fqdn
  write_cmd :smh_fqdn do
    attributes :value
  end

  read_cmd :get_product_name

  read_cmd :get_embedded_health

  read_cmd :get_power_readings

  read_cmd :get_pwreg
  write_cmd :set_pwreg do
    elements pwralert: :type, pwralert_settings: [:threshold, :duration]
  end

  read_cmd :get_power_cap
  write_cmd :set_power_cap do
    attributes :power_cap
  end

  read_cmd :get_host_power_saver_status
  write_cmd :set_host_power_saver do
    attributes :host_power_saver
  end

  read_cmd :get_host_power_status
  write_cmd :set_host_power do
    attributes :host_power
  end

  read_cmd :get_host_pwr_micro_ver

  write_cmd :reset_server

  write_cmd :press_pwr_btn

  write_cmd :hold_pwr_btn do
    attributes :toggle
  end

  write_cmd :cold_boot_server

  write_cmd :warm_boot_server

  read_cmd :get_server_auto_pwr
  write_cmd :server_auto_pwr do
    attributes :value
  end

  read_cmd :get_uid_status
  write_cmd :uid_control do
    attributes :uid
  end

  read_cmd :get_pers_mouse_keyboard_enabled
  write_cmd :set_pers_mouse_keyboard_enabled do
    attributes :value
  end

  read_cmd :get_server_power_on_time
  write_cmd :clear_server_power_on_time

  write_cmd :clear_iml
end
