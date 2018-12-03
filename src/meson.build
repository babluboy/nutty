# Replace parameters in source code
conf_data = configuration_data()
conf_data.set('MESON_INSTALL_PREFIX', get_option('prefix'))
conf_data.set('MESON_INSTALL_SCRIPTS_DIR', scripts_dir)
conf_data.set('meson_install_version', app_version)

constants_config = configure_file(
   input: 'constants.vala.in',
   output: 'constants.vala',
   configuration: conf_data
)
