context :rib_info do
  read_cmd :get_network_settings

  write_cmd :certificate_signing_request do
    elements :csr_state, :csr_country, :csr_locality, :csr_organization, :csr_organizational_unit, :csr_common_name
  end

  write_cmd :import_certificate do
    text :certificate
  end

  write_cmd :license do
    elements activate: :key
  end
end

context :server_info do
  write_cmd :set_persistent_boot do
    elements device: [:value]
  end

  write_cmd :set_one_time_boot do
    attributes :value
  end

  write_cmd :set_pwreg do
    elements pwralert: :type, pwralert_settings: [:threshold, :duration]
  end

  write_cmd :server_auto_pwr do
    attributes :value
  end
end
