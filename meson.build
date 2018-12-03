# project name and programming language
project('com.github.babluboy.nutty', ['vala', 'c'],
    version: '1.1.1'
)
app_version = meson.project_version()
gnome = import('gnome')
i18n = import('i18n')

# Set all the install directories
install_dir = join_paths(get_option('prefix'), 'share')
scripts_dir = join_paths(install_dir, meson.project_name(), 'scripts')

asresources = gnome.compile_resources(
    'as-resources', 'data/com.github.babluboy.nutty.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

vala_args = [
  '-g', '--target-glib=2.38',
]

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')
# Replace parameters in source code
subdir('src')

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    constants_config,
    'src/main.vala',
    'src/nutty.vala',
    'src/headerbar.vala',
    'src/utils.vala',
    'src/devices.vala',
    'src/database.vala',
    'src/entities.vala',
    'src/xmlHandler.vala',
    'src/info.vala',
    'src/window.vala',
    'src/settings.vala',
    'src/shortcuts.vala',
    asresources,
    vala_args: vala_args,
    link_args: '-lm',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('gee-0.8'),
        dependency('libxml-2.0'),
        dependency('libnotify'),
        dependency('granite', version: '>=0.5'),
        dependency('sqlite3', version: '>=3.5.9')
    ],
    install: true
)

meson.add_install_script('meson/post_install.py')
subdir('data')
subdir('po')
