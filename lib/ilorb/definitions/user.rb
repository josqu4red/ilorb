context :user_info do
  write_cmd :add_user do
    attributes :user_name, :user_login, :password
    elements :admin_priv, :remote_cons_priv, :reset_server_priv, :virtual_media_priv, :config_ilo_priv
  end

  write_cmd :delete_user do
    attributes :user_login
  end

  read_cmd :get_user do
    attributes :user_login
  end

  write_cmd :mod_user do
    attributes :user_login
    elements :user_name, :user_login, :password, :admin_priv, :remote_cons_priv, :reset_server_priv, :virtual_media_priv, :config_ilo_priv, :del_users_ssh_key
  end

  read_cmd :get_all_users

  read_cmd :get_all_user_info
end
