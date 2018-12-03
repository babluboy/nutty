#update policy kit with install dir
conf_data = configuration_data()
conf_data.set('MESON_INSTALL_PREFIX', get_option('prefix'))
polkit_config = configure_file(
   input: 'org.freedesktop.policykit.nutty.policy.in',
   output: 'org.freedesktop.policykit.nutty.policy',
   configuration: conf_data
)

#install policykit
install_data (
    polkit_config,
    install_dir: join_paths (get_option ('datadir'), 'polkit-1', 'actions')
)

#install scripts
script_names = [
    'nutty_cli_script.sh',
    'nutty_device_alert.sh',
    'nutty_device_monitor.sh',
    'nutty_nethogs_script.sh',
    'nutty_nmap_script.sh',
    'nutty_vnstat_script.sh',
    'nutty_traceroute_script.sh',
    'nutty_ports_script.sh',
    'speedtest-cli'
]
foreach a_script : script_names
    install_data(
        a_script,
        install_dir: join_paths(scripts_dir),
        install_mode: 'rwxr-xr-x'
    )
endforeach
