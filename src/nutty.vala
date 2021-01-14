/* Copyright 2015 Siddhartha Das (bablu.boy@gmail.com)
*
* This file is part of Nutty. This clas is responsible for the implementation  
*  of the window and other command line options
*
* Nutty is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Nutty is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Nutty. If not, see http://www.gnu.org/licenses/.
*/
	
using Gtk;
using Gee;
using Granite.Widgets;
using Granite.Services;
public const string GETTEXT_PACKAGE = "nutty";

namespace NuttyApp {
	public class Nutty : Granite.Application {
		public static bool isNuttyRunning = false;
		public static Gtk.ApplicationWindow window;
		public static Gtk.IconTheme default_theme;
		public static Nutty application;
		public static string[] commandLineArgs;

		public static string[] COMMAND_FOR_ONLINE_MANUFACTURE_NAME = {
					"curl", 
					"-d", 
					"test", 
					"http://www.macvendorlookup.com/api/v2/MAC-ID-SUBSTITUTION/xml"
		};
		public static string[] COMMAND_FOR_SPEED_TEST = {"speedtest-cli", "--simple", "--bytes"};
		public bool hasDisclaimerBeenAgreed = false;
		public string crontabContents = "";
		public static string nutty_config_path = "";
		public static Gtk.IconTheme icon_theme;
		public static Gtk.Image menu_icon;
		public static Gdk.Pixbuf device_available_pix;
		public static Gdk.Pixbuf device_offline_pix;
		public static Gdk.Pixbuf default_app_pix;
		public static int DEVICE_SCHEDULE_ENABLED = 1;
		public static int DEVICE_SCHEDULE_DISABLED = 0;
		public static int DEVICE_SCHEDULE_STATE = -1;
		public static int DEVICE_SCHEDULE_SELECTED = -1;
		public static string UPLOADSPEED = "0";
		public static string DOWNLOADSPEED = "0";
		public static string SPEEDTESTDATE = "";
		public static int exitCodeForCommand = -1;
		public static int info_combobox_counter = 0;
		public static StringBuilder spawn_async_with_pipes_output = new StringBuilder("");
		public static Stack stack;
		public static Gee.HashMap<string,string> interfaceConnectionMap;
		public static Gee.HashMap<string,string> interfaceIPMap;
		public static Gee.HashMap<string,string> interfaceIPV6Map;
		public static Gee.HashMap<string,string> interfaceMACMap;
		public static StringBuilder interfaceCommandOutputMinimal = new StringBuilder("");
		public static StringBuilder interfaceCommandOutputDetailed = new StringBuilder("");
		public static Gtk.TreeStore info_list_store = new Gtk.TreeStore (2, typeof (string), typeof (string));
		public static Gtk.ListStore route_list_store = new Gtk.ListStore (6, typeof (int), typeof (string), typeof (string), typeof (double), typeof (double), typeof (double));
		public static Gtk.ListStore ports_tcp_list_store = new Gtk.ListStore (6, typeof (string), typeof (string), typeof (string), typeof (string), typeof (string), typeof (string));
		public static Gtk.ListStore device_list_store = new Gtk.ListStore (7, typeof (Gdk.Pixbuf), typeof (string), typeof (string), typeof (string), typeof (string), typeof (string), typeof (string));
		public static Gtk.ListStore bandwidth_results_list_store = new Gtk.ListStore (4, typeof (Gdk.Pixbuf), typeof (string), typeof (string), typeof (string));
		public static Gtk.ListStore bandwidth_list_store = new Gtk.ListStore (4, typeof (string), typeof (string), typeof (string), typeof (string));
		public static Gtk.ListStore speedtest_list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
		public static Gtk.InfoBar infobar;
		public static Gtk.Label infobarLabel;
		public static Spinner infoProcessSpinner;
		public static string HostName;
		public static Gtk.SearchEntry headerSearchBar;
		public static Spinner traceRouteSpinner;
		public static Label route_results_label;
		public static Spinner speedTestSpinner;
		public static Button speed_test_refresh_button;
		public static Label speed_test_results_label;
		public static bool isPortsViewLoaded = false;
		public static Label ports_results_label;
		public static Spinner portsSpinner;
		public static Label devices_results_label;
		public static Spinner devicesSpinner;
		public static bool isDevicesViewLoaded = false;
		public static Label bandwidth_results_label;
		public static bool isBandwidthViewLoaded = false;
		public static Spinner bandwidthProcessSpinner;
		public static Gtk.RadioButton NoOption;
		public static Gtk.RadioButton min15Option;
		public static Gtk.RadioButton min30Option;
		public static Gtk.RadioButton hourOption;
		public static Gtk.RadioButton dayOption;
		public static bool isMonitorScheduleReadyForChange = false;
		public static Gtk.TreeModelFilter infoTreeModelFilter;
		public static Gtk.TreeModelFilter portsTreeModelFilter;
		public static Gtk.TreeModelFilter routeTreeModelFilter;
		public static Gtk.TreeModelFilter speedTestTreeModelFilter;
		public static Gtk.TreeModelFilter devicesTreeModelFilter;
		public static Gtk.TreeModelFilter bandwidthTreeModelFilter;
		public static Gtk.TreeModelFilter bandwidthProcessTreeModelFilter;
		public static StringBuilder infoSearchEntry = new StringBuilder ("");
		public static StringBuilder portsSearchEntry = new StringBuilder ("");
		public static StringBuilder routeSearchEntry = new StringBuilder ("");
		public static StringBuilder devicesSearchEntry = new StringBuilder ("");
		public static StringBuilder bandwidthSearchEntry = new StringBuilder ("");
		public static bool command_line_option_version = false;
		public bool command_line_option_debug = false;
		public bool command_line_option_info = false;
		[CCode (array_length = false, array_null_terminated = true)]
		public static string command_line_option_monitor = "";
		public static string command_line_option_alert = "";
		public new OptionEntry[] options;
		public static string nutty_state_data = "";
		public static ArrayList<NuttyApp.Entities.Device> deviceDataArrayList;
		public static StringBuilder device_mac_found_in_scan = new StringBuilder("");
		public static CssProvider cssProvider;
		public static NuttyApp.Settings settings;
		public static Granite.Services.Paths app_xdg_path;

		construct {
			build_version = NuttyApp.Constants.nutty_version;
			application_id = NuttyApp.Constants.app_id;
			flags |= ApplicationFlags.HANDLES_COMMAND_LINE;
			program_name = NuttyApp.Constants.program_name;
			exec_name = NuttyApp.Constants.app_id;

			options = new OptionEntry[5];
			options[0] = { "version", 0, 0, OptionArg.NONE, ref command_line_option_version, _("Display version number"), null };
			options[1] = { "monitor", 0, 0, OptionArg.STRING, ref command_line_option_monitor, _("Run Nutty to discover devices"), "Path to folder containing nutty.db (i.e. /home/sid/.local/share/com.github.babluboy.nutty)" };
			options[2] = { "alert", 0, 0, OptionArg.STRING, ref command_line_option_alert, _("Run Nutty in device alert mode"), "Path to nutty config (i.e. /home/sid/.config/nutty)" };
			options[3] = { "debug", 0, 0, OptionArg.NONE, ref command_line_option_debug, _("Run Nutty in debug mode"), null };
			options[4] = { "info", 0, 0, OptionArg.NONE, ref command_line_option_info, _("Run Nutty in info mode"), null };
			add_main_option_entries (options);
		}

		public Nutty() {
			Intl.setlocale(LocaleCategory.MESSAGES, "");
			Intl.textdomain(GETTEXT_PACKAGE);
			Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "utf-8");
			//Initialize XDG Paths
			app_xdg_path = new Granite.Services.Paths();
			app_xdg_path.initialize (Constants.app_id, Constants.NUTTY_SCRIPT_PATH);
			nutty_config_path = app_xdg_path.user_data_folder.get_path();
			//migrate user data from .config to .local/share -- to be deleted in the next version
			if("true" == NuttyApp.Utils.fileOperations(
							"EXISTS", 
							GLib.Environment.get_user_config_dir ()+"/nutty",
							"/nutty_disclaimer_agreement.txt",""
						 )
			){
				//copy agreement file
				execute_sync_command (
						"cp " +
						GLib.Environment.get_user_config_dir () + "/nutty" +
                        "nutty_disclaimer_agreement.txt " +
						nutty_config_path + "/nutty_disclaimer_agreement.txt"
				);
				//check if the copy was sucessfull
				if("true" == NuttyApp.Utils.fileOperations(
								"EXISTS", nutty_config_path, 
								"/nutty_disclaimer_agreement.txt",""
							 )
				){
					//remove the agreement from the .config folder
					NuttyApp.Utils.fileOperations("DELETE",
												  GLib.Environment.get_user_config_dir () +"/nutty",
												  "nutty_disclaimer_agreement.txt", ""
												 );
				}
				if("true" == NuttyApp.Utils.fileOperations(
								"EXISTS",
								GLib.Environment.get_user_config_dir ()+"/nutty",
								"/nutty.db",""
							 )
				){
					//copy agreement file
					execute_sync_command ("cp "+
										  GLib.Environment.get_user_config_dir ()+"/nutty/nutty.db " +
										  nutty_config_path + "/nutty.db"
										 );
					if("true" == NuttyApp.Utils.fileOperations("EXISTS", nutty_config_path, "/nutty.db", "")) {
						//remove the sql db from the .config folder
						NuttyApp.Utils.fileOperations("DELETE",
													  GLib.Environment.get_user_config_dir ()+"/nutty", 
													  "nutty.db", ""
													 );
					}
				}
			} //end of XDG data migration
		}

		public static Nutty getAppInstance(){
			if(application == null){
				application = new Nutty();
			}else{
				//do nothing, return the existing instance
			}
			return application;
		}


		public override int command_line (ApplicationCommandLine command_line) {
			commandLineArgs = command_line.get_arguments ();
			activate();
			return 0;
		}

		public int processCommandLine (string[] args) {
			try {
				var opt_context = new OptionContext ("- nutty");
				opt_context.set_help_enabled (true);
				opt_context.add_main_entries (options, null);
				unowned string[] tmpArgs = args;
				opt_context.parse (ref tmpArgs);
			} catch (OptionError e) {
				info ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
				info ("error: %s\n", e.message);
				return 0;
			}
			//check and run nutty based on command line option
			if(command_line_option_debug){
				debug ("Nutty running in DEBUG mode...");
			}
			if(command_line_option_debug){
				info ("Nutty running in INFO mode...");
			}
			if(command_line_option_version){
				print("nutty version "+Constants.nutty_version+" \n");
			}else if(command_line_option_monitor.length > 0){
				print("\nRunning Nutty in Device Monitor Mode for config at "+command_line_option_monitor+"\n");
				//initialize the DB
				nutty_config_path = command_line_option_monitor;
				NuttyApp.DB.initializeNuttyDB(nutty_config_path);
				//run device discovery as a background task
				NuttyApp.Devices.runDeviceDiscovery();
			}else if(command_line_option_alert.length  > 0){
				print("\nRunning Nutty in Device Alert Mode \n");
				//initialize the DB
				nutty_config_path = command_line_option_alert;
				//initialize the DB
				NuttyApp.DB.initializeNuttyDB(nutty_config_path);
				//alert devices pending alerting
				NuttyApp.Devices.alertNewDevices();
			}
			return 0;
		}

		public override void activate() {
			try{
				application.register (null);
			}catch(Error e){
				warning("Unsucessful in registering the application. Error:"+e.message);
			}
			Logger.initialize(NuttyApp.Constants.app_id);
			if(command_line_option_debug){
				Logger.DisplayLevel = LogLevel.DEBUG;
			}
			if(command_line_option_info){
				Logger.DisplayLevel = LogLevel.INFO;
			}
			info("[START] [FUNCTION:activate]");
			//proceed if Bookworm is not running already
			if(!isNuttyRunning) {
				debug("No instance of Nutty found");
				default_theme = Gtk.IconTheme.get_default();
				window = new Gtk.ApplicationWindow (this);
				//retrieve Settings
				settings = NuttyApp.Settings.get_instance();
				icon_theme = Gtk.IconTheme.get_default ();
				//set window attributes
				window.get_style_context ().add_class ("rounded");
				window.set_border_width (Constants.SPACING_WIDGETS);
				window.set_position (Gtk.WindowPosition.CENTER);
				window.window_position = Gtk.WindowPosition.CENTER;
				//load state information from last saved settings
				loadNuttyState();
				//load pictures
				loadImages();
				//set css provider
				cssProvider = new Gtk.CssProvider();
				loadCSSProvider(cssProvider);
				//add window components
				window.set_titlebar (NuttyApp.AppHeaderBar.create_headerbar(window));
				//check if the disclaimer has been agreed
				if(! disclaimerSetGet(Constants.HAS_DISCLAIMER_BEEN_AGREED)){
					window.add(NuttyApp.AppWindow.createNuttyWelcomeView()); //add the first time welcome UI Box
				}else{
					window.add(createNuttyUI()); //add the main UI Box
				}
				//show the app window
				add_window (window);
				window.show_all();
				//hide the infobar on initial load
				infobar.hide();
				//capture window re-size events and save the window size
				window.size_allocate.connect(() => {
					saveWindowState();
				});
				//Exit Application Event
				window.destroy.connect (() => {
					// Manage flags to avoid on load process for tabs not visited
					isDevicesViewLoaded = true;
					isBandwidthViewLoaded = true;
					isPortsViewLoaded = true;
					//save state information to file
					saveNuttyState();
				});
				//Add keyboard shortcuts on the window
				window.add_events (Gdk.EventMask.KEY_PRESS_MASK);
				window.key_press_event.connect (NuttyApp.Shortcuts.handleKeyPress);
				window.key_release_event.connect (NuttyApp.Shortcuts.handleKeyRelease);

				isNuttyRunning = true;
				debug("Completed creating an instance of Nutty");
			}else{
				window.present();
				debug("An instance of Nutty is already running");
			}
			info("[END] [FUNCTION:activate]");
		}

		public void loadImages() {
			info("[START] [FUNCTION:loadImages]");
			if (Gtk.IconTheme.get_default ().has_icon ("open-menu")) {
				menu_icon = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
			}else{
				try{
					menu_icon = new Gtk.Image.from_pixbuf (
										new Gdk.Pixbuf.from_resource_at_scale(
											NuttyApp.Constants.HEADERBAR_PROPERTIES_IMAGE_LOCATION,24, 24, true
										)
					);
				}catch(Error e){
					warning("Error in loading the gear icon on the header. Error:"+e.message);
				}
			}
			try{
				device_available_pix = new Gdk.Pixbuf.from_resource (NuttyApp.Constants.DEVICE_AVAILABLE_ICON_IMAGE_LOCATION);
				device_offline_pix = new Gdk.Pixbuf.from_resource (NuttyApp.Constants.DEVICE_OFFLINE_ICON_IMAGE_LOCATION);
				default_app_pix=new Gdk.Pixbuf.from_resource (NuttyApp.Constants.DEFAULT_APP_ICON_IMAGE_LOCATION);
			}catch(GLib.Error e){
				warning("Failed to load icons/theme: "+e.message);
			}
			info("[END] [FUNCTION:loadImages]");
		}

		public static void createPrefsDialog() {
			debug("Started setting up Prefference Dialog ...");
			Gtk.Dialog prefsDialog = new Gtk.Dialog.with_buttons("Preferences", window, DialogFlags.MODAL);
			prefsDialog.title = "Preferences";
			prefsDialog.border_width = Constants.SPACING_WIDGETS;
			prefsDialog.set_default_size (400, 250);
			prefsDialog.destroy.connect (Gtk.main_quit);
			prefsDialog.add_button (Constants.TEXT_FOR_PREFS_DIALOG_CLOSE_BUTTON, Gtk.ResponseType.CLOSE);

			// Layout widgets for Preferences
			Gtk.Label deviceMonitorLabel = new Gtk.Label.with_mnemonic (Constants.TEXT_FOR_PREFS_DIALOG_DEVICE_MONITORING);
			Gtk.Switch deviceMonitoringSwitch = new Gtk.Switch ();
			deviceMonitoringSwitch.set_active(false);

			// trigger action for change of device schedule
			deviceMonitoringSwitch.notify["active"].connect (() => {
				if (deviceMonitoringSwitch.active) {
					settings.is_device_monitoring_enabled = true;
					NuttyApp.Devices.handleDeviceMonitoring(true);
				}else{
					settings.is_device_monitoring_enabled = false;
					NuttyApp.Devices.handleDeviceMonitoring(false);
				}
			});

			NoOption = new Gtk.RadioButton.with_label_from_widget (null, Constants.TEXT_FOR_PREFS_DIALOG_0MIN_OPTION);
			NoOption.set_sensitive (false);
			NoOption.toggled.connect (NuttyApp.Devices.deviceScheduleSelection);

			min15Option = new Gtk.RadioButton.with_label_from_widget (NoOption, Constants.TEXT_FOR_PREFS_DIALOG_15MIN_OPTION);
			min15Option.set_sensitive (false);
			min15Option.toggled.connect (NuttyApp.Devices.deviceScheduleSelection);

			min30Option = new Gtk.RadioButton.with_label_from_widget (min15Option, Constants.TEXT_FOR_PREFS_DIALOG_30MIN_OPTION);
			min30Option.set_sensitive (false);
			min30Option.toggled.connect (NuttyApp.Devices.deviceScheduleSelection);

			hourOption = new Gtk.RadioButton.with_label_from_widget (min15Option, Constants.TEXT_FOR_PREFS_DIALOG_HOUR_OPTION);
			hourOption.set_sensitive (false);
			hourOption.toggled.connect (NuttyApp.Devices.deviceScheduleSelection);

			dayOption = new Gtk.RadioButton.with_label_from_widget (min15Option, Constants.TEXT_FOR_PREFS_DIALOG_DAY_OPTION);
			dayOption.set_sensitive (false);
			dayOption.toggled.connect (NuttyApp.Devices.deviceScheduleSelection);

			//set the option for device monitoring - based on saved state
			if(settings.is_device_monitoring_enabled){
				deviceMonitoringSwitch.set_active(true);
				NuttyApp.Devices.handleDeviceMonitoring(true);
			}else{
				deviceMonitoringSwitch.set_active(false);
				NuttyApp.Devices.handleDeviceMonitoring(false);
			}

			//set the active option for device schedule - based on saved state
			if(DEVICE_SCHEDULE_SELECTED == Constants.DEVICE_SCHEDULE_0MINS){
				NoOption.set_active (true);
			}else if(DEVICE_SCHEDULE_SELECTED == Constants.DEVICE_SCHEDULE_15MINS){
				min15Option.set_active (true);
			}else if(DEVICE_SCHEDULE_SELECTED == Constants.DEVICE_SCHEDULE_30MINS){
				min30Option.set_active (true);
			}else if(DEVICE_SCHEDULE_SELECTED == Constants.DEVICE_SCHEDULE_1HOUR){
				hourOption.set_active (true);
			}else if(DEVICE_SCHEDULE_SELECTED == Constants.DEVICE_SCHEDULE_1DAY){
				dayOption.set_active (true);
			}else{
				//do nothing
			}
			//make the preference window ready to change the cron schedule
			isMonitorScheduleReadyForChange = true;

			Gtk.Box monitorIntervalBox = new Gtk.Box (Gtk.Orientation.VERTICAL, Constants.SPACING_WIDGETS);
			monitorIntervalBox.pack_start (min15Option, false, false, 0);
			monitorIntervalBox.pack_start (min30Option, false, false, 0);
			monitorIntervalBox.pack_start (hourOption, false, false, 0);
			monitorIntervalBox.pack_start (dayOption, false, false, 0);

			Gtk.Box scheduleBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, Constants.SPACING_WIDGETS);
			scheduleBox.pack_start (deviceMonitorLabel, false, true, 0);
			scheduleBox.pack_start (deviceMonitoringSwitch, false, true, 0);

			Gtk.Box prefsBox = new Gtk.Box (Gtk.Orientation.VERTICAL, Constants.SPACING_WIDGETS);
			prefsBox.pack_start (scheduleBox, false, true, 0);
			prefsBox.pack_start (monitorIntervalBox, false, true, 0);

			Gtk.Box prefsContent = prefsDialog.get_content_area () as Gtk.Box;
			prefsContent.pack_start (prefsBox, false, true, 0);
			prefsContent.spacing = Constants.SPACING_WIDGETS;

			prefsDialog.show_all ();
			prefsDialog.response.connect(prefsDialogResponseHandler);
			debug("Completed setting up Prefference Dialog successfully...");
		}

		private static void prefsDialogResponseHandler(Gtk.Dialog source, int response_id) {
			switch (response_id) {
				case Gtk.ResponseType.CLOSE:
					isMonitorScheduleReadyForChange = false;
					source.destroy();
					break;
				case Gtk.ResponseType.DELETE_EVENT:
					isMonitorScheduleReadyForChange = false;
					source.destroy();
					break;
			}
			debug ("Prefference dialog handler response handled ["+response_id.to_string()+"]...");
		}

		private static void exportDialogResponseHandler(Gtk.Dialog source, int response_id) {
			//Set the File Chooser default folder path based on the folder the action was comitted
			Utils.last_file_chooser_path = ((Gtk.FileChooserDialog) source).get_current_folder();
			switch (response_id) {
				case Gtk.ResponseType.CANCEL:
					source.destroy();
					break;
				case Gtk.ResponseType.ACCEPT:
					saveNuttyInfoToFile(((Gtk.FileChooserDialog) source).get_current_folder(), ((Gtk.FileChooserDialog) source).get_current_name());
					source.destroy();
					break;
			}
			debug ("Export dialog handler response handled ["+response_id.to_string()+"]...");
		}

		public static void createExportDialog() {
			info("[START] [FUNCTION:createExportDialog]");
			Gtk.FileChooserDialog aFileChooserDialog = Utils.new_file_chooser_dialog (Gtk.FileChooserAction.SAVE, "Export Nutty Data", window, false);
			aFileChooserDialog.show_all ();
			aFileChooserDialog.response.connect(exportDialogResponseHandler);
			debug("Completed setting up Export Dialog successfully...");
		}

		public static Box createNuttyUI() {
			debug("Starting to create main window components...");
			Gtk.Box main_ui_box = new Gtk.Box (Orientation.VERTICAL, Constants.SPACING_WIDGETS);
			//define the stack for the tabbed view
			stack = new Gtk.Stack();
			stack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);

			//Create a MessageBar to show status messages
		    infobar = new Gtk.InfoBar ();
		    infobarLabel = new Gtk.Label("");
			infobarLabel.set_line_wrap (true);
		    Gtk.Container infobarContent = infobar.get_content_area ();
		    infobarContent.add (infobarLabel);
		    infobar.set_show_close_button (true);
		    infobar.response.connect(NuttyApp.AppWindow.on_info_bar_closed);
		    infobar.hide();

			//define the switcher for switching between tabs
			StackSwitcher switcher = new StackSwitcher();
			switcher.set_halign(Align.CENTER);
			switcher.set_stack(stack);
			main_ui_box.pack_start(infobar, false, true, 0);
			main_ui_box.pack_start(switcher, false, true, 0);
			main_ui_box.pack_start(stack, true, true, 0);

			//Fetch and persist names of connections and interfaces if it does not exist already
			NuttyApp.Info.getConnectionsList();
			debug("Obtained the list of connections...");

			/* Start of tabs UI set up */

			// Tab 1 : MyInfo Tab: This Tab displays info on the computer and network interface hardware
			Label info_details_combobox_label = new Label (Constants.TEXT_FOR_MYINFO_DETAILS_LABEL);
			ComboBoxText info_combobox = new ComboBoxText();
			Gtk.Switch detailsInfoSwitch = new Gtk.Switch ();
			detailsInfoSwitch.set_sensitive (false);
			infoProcessSpinner = new Spinner();
			//Set connection values into connections combobox
			info_combobox.insert(0,Constants.TEXT_FOR_INTERFACE_LABEL,Constants.TEXT_FOR_INTERFACE_LABEL);
			info_combobox_counter = 1;
			foreach (var entry in interfaceConnectionMap.entries) {
				info_combobox.insert(info_combobox_counter, entry.key, entry.value);
				info_combobox_counter++;
			}
			info_combobox.active = 0;

			TreeView info_table_treeview = new TreeView();
			CellRendererText info_cell = new CellRendererText ();
			info_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_MYINFO_COLUMN_NAME_1, info_cell, "text", 0);
			info_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_MYINFO_COLUMN_NAME_2, info_cell, "text", 1);
			//Fetch and minimal info with no interface selected
			infoTreeModelFilter = new Gtk.TreeModelFilter (NuttyApp.Info.processMyInfo("", false), null);
			setFilterAndSort(info_table_treeview, infoTreeModelFilter, SortType.DESCENDING);
			// Set actions for Interface DropDown change
			info_combobox.changed.connect (() => {
				if(Constants.TEXT_FOR_INTERFACE_LABEL != info_combobox.get_active_id ()){
					//set the detailsInfoSwitch to active status
					detailsInfoSwitch.set_sensitive (true);
					if (detailsInfoSwitch.active) {
						infoProcessSpinner.start();
						infoTreeModelFilter = new Gtk.TreeModelFilter (NuttyApp.Info.processMyInfo(info_combobox.get_active_id (), true), null);
						setFilterAndSort(info_table_treeview, infoTreeModelFilter, SortType.DESCENDING);
					} else {
						infoTreeModelFilter = new Gtk.TreeModelFilter (NuttyApp.Info.processMyInfo(info_combobox.get_active_id (), false), null);
						setFilterAndSort(info_table_treeview, infoTreeModelFilter, SortType.DESCENDING);
					}
				}else{
					//set the detailsInfoSwitch to in-active status
					detailsInfoSwitch.set_sensitive (false);
					//Fetch and minimal info with no interface selected
					infoTreeModelFilter = new Gtk.TreeModelFilter (NuttyApp.Info.processMyInfo("", false), null);
					setFilterAndSort(info_table_treeview, infoTreeModelFilter, SortType.DESCENDING);
				}
			});
			// Set actions for Detailed Network Hardware switch change
			detailsInfoSwitch.notify["active"].connect (() => {
				if (detailsInfoSwitch.active) {
					infoProcessSpinner.start();
					infoTreeModelFilter = new Gtk.TreeModelFilter (NuttyApp.Info.processMyInfo(info_combobox.get_active_id (), true), null);
					setFilterAndSort(info_table_treeview, infoTreeModelFilter, SortType.DESCENDING);
				} else {
					infoTreeModelFilter = new Gtk.TreeModelFilter (NuttyApp.Info.processMyInfo(info_combobox.get_active_id (), false), null);
					setFilterAndSort(info_table_treeview, infoTreeModelFilter, SortType.DESCENDING);
				}
			});

			Box info_interface_box = new Box (Orientation.HORIZONTAL, Constants.SPACING_WIDGETS);
			info_interface_box.pack_start (info_combobox, false, true, 0);
			info_interface_box.pack_start (info_details_combobox_label, false, true, 0);
			info_interface_box.pack_start (detailsInfoSwitch, false, true, 0);
			info_interface_box.pack_end (infoProcessSpinner, false, true, 0);

			ScrolledWindow info_scroll = new ScrolledWindow (null, null);
			info_scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			info_scroll.add (info_table_treeview);

			Box info_layout_box = new Box (Orientation.VERTICAL, Constants.SPACING_WIDGETS);
			info_layout_box.pack_start (info_interface_box, false, true, 0);
			info_layout_box.pack_start (info_scroll, true, true, 0);
			//Add info-box to stack
			stack.add_titled(info_layout_box, "my-info", Constants.TEXT_FOR_MYINFO_TAB);
			debug("Info tab set up completed...");

			//Tab 2 : Bandwidth : Show bandwidth usage for this device
			Label bandwidth_details_label = new Label (Constants.TEXT_FOR_LABEL_RESULT);
			bandwidth_results_label = new Label (Constants.TEXT_FOR_BANDWIDTH_LABEL);
			bandwidthProcessSpinner = new Spinner();
			ComboBoxText bandwidth_combobox = new ComboBoxText();
			//Set connection values into combobox
			bandwidth_combobox.insert(0,Constants.TEXT_FOR_INTERFACE_LABEL,Constants.TEXT_FOR_INTERFACE_LABEL);
			int bandwidth_combobox_counter = 1;
			foreach (var entry in interfaceConnectionMap.entries) {
				bandwidth_combobox.insert(info_combobox_counter, entry.key, entry.value);
				bandwidth_combobox_counter++;
			}
			bandwidth_combobox.active = 0;
			Box bandwidth_results_box = new Box (Orientation.HORIZONTAL, Constants.SPACING_WIDGETS);
			bandwidth_results_box.pack_start (bandwidth_combobox, false, true, 0);
			bandwidth_results_box.pack_start (bandwidth_details_label, false, true, 0);
			bandwidth_results_box.pack_start (bandwidth_results_label, false, true, 0);

			TreeView bandwidth_table_treeview = new TreeView();
			//bandwidth_table_treeview.set_fixed_height_mode(false);
			CellRendererText bandwidth_cell = new CellRendererText ();
			bandwidth_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_BANDWIDTH_COLUMN_NAME_1, bandwidth_cell, "text", 0);
			bandwidth_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_BANDWIDTH_COLUMN_NAME_2, bandwidth_cell, "text", 1);
			bandwidth_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_BANDWIDTH_COLUMN_NAME_3, bandwidth_cell, "text", 2);
			bandwidth_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_BANDWIDTH_COLUMN_NAME_4, bandwidth_cell, "text", 3);

			ScrolledWindow bandwidth_scroll = new ScrolledWindow (null, null);
			bandwidth_scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			bandwidth_scroll.add (bandwidth_table_treeview);

			Gtk.Separator bandwidth_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

			TreeView bandwidth_process_table_treeview = new TreeView();
			bandwidth_process_table_treeview.set_fixed_height_mode(true);
			CellRendererText bandwidth_process_cell = new CellRendererText ();
			CellRendererPixbuf bandwidth_cell_pix = new CellRendererPixbuf ();
			bandwidth_process_table_treeview.insert_column_with_attributes (-1, "", bandwidth_cell_pix, "pixbuf", 0);
			bandwidth_process_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_BANDWIDTH_PROCESS_COLUMN_NAME_1, bandwidth_process_cell, "text", 1);
			bandwidth_process_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_BANDWIDTH_PROCESS_COLUMN_NAME_2, bandwidth_process_cell, "text", 2);
			bandwidth_process_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_BANDWIDTH_PROCESS_COLUMN_NAME_3, bandwidth_process_cell, "text", 3);

			ScrolledWindow bandwidth_process_scroll = new ScrolledWindow (null, null);
			bandwidth_process_scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			bandwidth_process_scroll.add (bandwidth_process_table_treeview);

			Box bandwidth_process_result_box = new Box (Orientation.HORIZONTAL, Constants.SPACING_WIDGETS);
			Button bandwidth_process_refresh_button = new Button.from_icon_name (Constants.REFRESH_ICON, IconSize.SMALL_TOOLBAR);
			bandwidth_process_refresh_button.set_relief (ReliefStyle.NONE);
			bandwidth_process_refresh_button.set_tooltip_markup (Constants.TEXT_FOR_BANDWIDTH_PROCESS_TOOLTIP);
			Label bandwidth_process_label = new Label (Constants.TEXT_FOR_BANDWIDTH_PROCESS_LABEL+bandwidth_combobox.get_active_text()+ " connection.");

			bandwidth_process_result_box.pack_start (bandwidth_process_label, false, false, 0);
			bandwidth_process_result_box.pack_end (bandwidth_process_refresh_button, false, false, 0);
			bandwidth_process_result_box.pack_end (bandwidthProcessSpinner, false, false, 0);

			Box bandwidth_layout_box = new Box (Orientation.VERTICAL, Constants.SPACING_WIDGETS);
			bandwidth_layout_box.pack_start (bandwidth_results_box, false, true, 0);
			bandwidth_layout_box.pack_start (bandwidth_scroll, true, true, 0);
			bandwidth_layout_box.pack_start (bandwidth_separator, false, false, 0);
			bandwidth_layout_box.pack_start (bandwidth_process_result_box, false, false, 0);
			bandwidth_layout_box.pack_end (bandwidth_process_scroll, true, true, 0);

			bandwidth_combobox.changed.connect (() => {
				if(Constants.TEXT_FOR_INTERFACE_LABEL != bandwidth_combobox.get_active_id ()){
					bandwidthTreeModelFilter = new Gtk.TreeModelFilter (processBandwidthUsage(bandwidth_combobox.get_active_id ()), null);
					setFilterAndSort(bandwidth_table_treeview, bandwidthTreeModelFilter, SortType.DESCENDING);
					//set the text for the bandwidth process label
					bandwidth_process_label.set_text(Constants.TEXT_FOR_BANDWIDTH_PROCESS_LABEL+bandwidth_combobox.get_active_text()+ " connection.");
					//empty the bandwidth process treeview of any previous results
					bandwidth_process_table_treeview.set_model(null);
				}else{
					//set the text for the bandwidth label and the bandwidth process label
					bandwidth_results_label.set_text(Constants.TEXT_FOR_BANDWIDTH_LABEL);
					bandwidth_process_label.set_text(Constants.TEXT_FOR_BANDWIDTH_LABEL);
					//empty the bandwidth treeview of any previous results
					bandwidth_table_treeview.set_model(null);
					//empty the bandwidth process treeview of any previous results
					bandwidth_process_table_treeview.set_model(null);
				}
			});
			// Set actions for Bandwidth Processes Refresh Button Clicking
			bandwidth_process_refresh_button.clicked.connect (() => {
				bandwidthProcessTreeModelFilter = new Gtk.TreeModelFilter (processBandwidthApps(bandwidth_combobox.get_active_id ()), null);
				setFilterAndSort(bandwidth_process_table_treeview, bandwidthProcessTreeModelFilter, SortType.DESCENDING);
			});
			//Add bandwidth-box to stack
			stack.add_titled(bandwidth_layout_box, "bandwidth", Constants.TEXT_FOR_BANDWIDTH_TAB);
			debug("Bandwidth tab set up completed...");

			//Tab 3 : Speed Tab : Show internet speed or speed of routing to a remote host
			speedTestSpinner = new Spinner();
			Label speed_test_label = new Label ("");
			if(SPEEDTESTDATE != null && SPEEDTESTDATE.length > 1){
				speed_test_label.set_text (Constants.TEXT_FOR_SPEED_LABEL);
			}else{
				speed_test_label.set_text (NuttyApp.Constants.TEXT_FOR_SPEED_TEST_NOT_DONE_LABEL);
			}
			speed_test_results_label = new Label (SPEEDTESTDATE);
			speed_test_refresh_button = new Button.from_icon_name (Constants.REFRESH_ICON, IconSize.SMALL_TOOLBAR);
			speed_test_refresh_button.set_relief (ReliefStyle.NONE);
			speed_test_refresh_button.set_tooltip_markup (Constants.TEXT_FOR_SPEEDTEST_TOOLTIP);
			Gtk.Separator speed_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

			TreeView speedtest_table_treeview = new TreeView();
			speedtest_table_treeview.set_fixed_height_mode(true);
			CellRendererText speedtest_cell = new CellRendererText ();
			speedtest_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_SPEEDTEST_COLUMN_NAME_1, speedtest_cell, "text", 0);
			speedtest_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_SPEEDTEST_COLUMN_NAME_2, speedtest_cell, "text", 1);

			speedTestTreeModelFilter = new Gtk.TreeModelFilter (processSpeedTest(false), null);
			setFilterAndSort(speedtest_table_treeview, speedTestTreeModelFilter, SortType.DESCENDING);

			Box speed_test_box = new Box (Orientation.HORIZONTAL, Constants.SPACING_WIDGETS);
			speed_test_box.pack_start (speed_test_label, false, true, 0);
			speed_test_box.pack_start (speed_test_results_label, false, true, 0);
			speed_test_box.pack_end (speed_test_refresh_button, false, true, 0);
			speed_test_box.pack_end (speedTestSpinner, false, true, 0);

			Box speedtest_layout_box = new Box (Orientation.VERTICAL, Constants.SPACING_WIDGETS);
			speedtest_layout_box.pack_start (speed_test_box, false, true, 0);
			speedtest_layout_box.pack_start (speedtest_table_treeview, false, true, 0);

			traceRouteSpinner = new Spinner();
			Label route_speed_label = new Label (Constants.TEXT_FOR_ROUTE_TO_HOST);
			Entry route_entry_text = new Entry();
			route_entry_text.set_events(Gdk.EventMask.KEY_PRESS_MASK);
			route_entry_text.set_text("www.google.com");
			Button route_button = new Button.from_icon_name (Constants.GO_ICON, IconSize.SMALL_TOOLBAR);
			route_button.set_relief (ReliefStyle.NONE);
			TreeView route_table_treeview = new TreeView();
			route_table_treeview.set_fixed_height_mode(true);

			CellRendererText route_cell = new CellRendererText ();
			route_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_ROUTE_COLUMN_NAME_1, route_cell, "text", 0);
			route_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_ROUTE_COLUMN_NAME_2, route_cell, "text", 1);
			route_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_ROUTE_COLUMN_NAME_3, route_cell, "text", 2);
			route_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_ROUTE_COLUMN_NAME_4, route_cell, "text", 3);
			route_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_ROUTE_COLUMN_NAME_5, route_cell, "text", 4);
			route_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_ROUTE_COLUMN_NAME_6, route_cell, "text", 5);

			// Set actions for Route EntryText Return Key Press
			route_entry_text.activate.connect (() => {
				traceRouteSpinner.start();
				routeTreeModelFilter = new Gtk.TreeModelFilter(
					processRouteScan(route_entry_text.get_text()), 
					null
				);
				setFilterAndSort(route_table_treeview, routeTreeModelFilter, SortType.DESCENDING);
			});

			// Set actions for Route Button Clicking
			route_button.clicked.connect (() => {
				traceRouteSpinner.start();
				routeTreeModelFilter = new Gtk.TreeModelFilter(
					processRouteScan(route_entry_text.get_text()), 
					null
				);
				setFilterAndSort(route_table_treeview, routeTreeModelFilter, SortType.DESCENDING);
			});
			// Set actions for Speed Test Refresh Button Clicking
			speed_test_refresh_button.clicked.connect (() => {
				speedTestSpinner.start();
				speed_test_refresh_button.set_sensitive(false);
				speedTestTreeModelFilter = new Gtk.TreeModelFilter (processSpeedTest(true), null);
				setFilterAndSort(speedtest_table_treeview, speedTestTreeModelFilter, SortType.DESCENDING);
				speed_test_label.set_text (Constants.TEXT_FOR_SPEED_LABEL);
				speed_test_results_label.set_text(SPEEDTESTDATE);
			});

			Box route_input_box = new Box (Orientation.HORIZONTAL, Constants.SPACING_WIDGETS);
			route_input_box.pack_start (route_speed_label, false, true, 0);
			route_input_box.pack_start (route_entry_text, false, true, 0);
			route_input_box.pack_start (route_button, false, true, 0);
			route_input_box.pack_end (traceRouteSpinner, false, true, 0);

			Box route_results_box = new Box (Orientation.HORIZONTAL, Constants.SPACING_WIDGETS);
			Label route_destination_label = new Label (Constants.TEXT_FOR_LABEL_RESULT);
			route_results_label = new Label (" ");
			route_results_box.pack_start (route_destination_label, false, true, 0);
			route_results_box.pack_start (route_results_label, false, true, 0);

			ScrolledWindow route_scroll = new ScrolledWindow (null, null);
			route_scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			route_scroll.add (route_table_treeview);

			Box route_layout_box = new Box (Orientation.VERTICAL, Constants.SPACING_WIDGETS);
			route_layout_box.pack_start (speedtest_layout_box, false, true, 0);
			route_layout_box.pack_start (speed_separator, false, true, 0);
			route_layout_box.pack_start (route_input_box, false, true, 0);
			route_layout_box.pack_start (route_results_box, false, true, 0);
			route_layout_box.pack_start (route_scroll, true, true, 0);
			//Add route-box to stack
			stack.add_titled(route_layout_box, "route", Constants.TEXT_FOR_ROUTE_TAB);
			debug("Speed tab set up completed...");

			//Tab 4 : Ports Tab : Show details of open internet connections and application ports
			TreeView ports_tcp_table_treeview = new TreeView();
			ports_tcp_table_treeview.set_fixed_height_mode(true);

			CellRendererText ports_tcp_cell = new CellRendererText ();
			ports_tcp_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_PORTS_COLUMN_NAME_1, ports_tcp_cell, "text", 0);
			ports_tcp_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_PORTS_COLUMN_NAME_2, ports_tcp_cell, "text", 1);
			ports_tcp_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_PORTS_COLUMN_NAME_3, ports_tcp_cell, "text", 2);
			ports_tcp_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_PORTS_COLUMN_NAME_4, ports_tcp_cell, "text", 3);
			ports_tcp_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_PORTS_COLUMN_NAME_5, ports_tcp_cell, "text", 4);
			ports_tcp_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_PORTS_COLUMN_NAME_6, ports_tcp_cell, "text", 5);

			ScrolledWindow ports_tcp_scroll = new ScrolledWindow (null, null);
			ports_tcp_scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			ports_tcp_scroll.add (ports_tcp_table_treeview);

			portsSpinner = new Spinner();
			Button ports_refresh_button = new Button.from_icon_name (Constants.REFRESH_ICON, IconSize.SMALL_TOOLBAR);
			ports_refresh_button.set_relief (ReliefStyle.NONE);
			ports_refresh_button.set_tooltip_markup (Constants.TEXT_FOR_PORTS_TOOLTIP);
			Box ports_results_box = new Box (Orientation.HORIZONTAL, Constants.SPACING_WIDGETS);
			Label ports_destination_label = new Label (Constants.TEXT_FOR_LABEL_RESULT);
			ports_results_label = new Label (" ");
			ports_results_box.pack_start (ports_destination_label, false, true, 0);
			ports_results_box.pack_start (ports_results_label, false, true, 0);
			ports_results_box.pack_end (ports_refresh_button, false, true, 0);
			ports_results_box.pack_end (portsSpinner, false, true, 0);

			Box ports_layout_box = new Box (Orientation.VERTICAL, Constants.SPACING_WIDGETS);
			ports_layout_box.pack_start (ports_results_box, false, true, 0);
			ports_layout_box.pack_start (ports_tcp_scroll, true, true, 0);

			//Note: the contents of the Ports Tab are loaded when the Ports Tab is clicked
			//see the Tab Change Event section below

			// Set actions for Ports Refresh Button Clicking
			ports_refresh_button.clicked.connect (() => {
				portsSpinner.start();
				portsTreeModelFilter = new Gtk.TreeModelFilter (processPortsScan(Constants.COMMAND_FOR_PORTS), null);
				setFilterAndSort(ports_tcp_table_treeview, portsTreeModelFilter, SortType.DESCENDING);
				isPortsViewLoaded = true;
			});
			//Add ports-box to stack
			stack.add_titled(ports_layout_box, "ports", Constants.TEXT_FOR_PORTS_TAB);
			debug("Ports tab set up completed...");

			//Tab 5: Add devices-box to stack
			stack.add_titled(NuttyApp.Devices.createDeviceUI(), "devices", Constants.TEXT_FOR_DEVICES_TAB);
			/* End of all tabs UI set up */

			//Check every time a tab is clicked and perform necessary actions
			stack.notify["visible-child"].connect ((sender, property) => {
				if(Constants.TEXT_FOR_SEARCH_HEADERBAR != headerSearchBar.get_text()){
					//Reset the HeaderBar SearchEntry text everytime the tab is changed/clicked
					if("my-info"==stack.get_visible_child_name()){
						headerSearchBar.set_text(infoSearchEntry.str);
					}
					if("ports"==stack.get_visible_child_name()){
						headerSearchBar.set_text(portsSearchEntry.str);
					}
					if("route"==stack.get_visible_child_name()){
						headerSearchBar.set_text(routeSearchEntry.str);
					}
					if("devices"==stack.get_visible_child_name()){
						headerSearchBar.set_text(devicesSearchEntry.str);
					}
					if("bandwidth"==stack.get_visible_child_name()){
						headerSearchBar.set_text(bandwidthSearchEntry.str);
					}
				}
				//Load the contents of some tabs when viewed for first time
				if(!isPortsViewLoaded && "ports"==stack.get_visible_child_name()){
					portsSpinner.start();
					portsTreeModelFilter = new Gtk.TreeModelFilter (processPortsScan(Constants.COMMAND_FOR_PORTS), null);
					setFilterAndSort(ports_tcp_table_treeview, portsTreeModelFilter, SortType.DESCENDING);
					isPortsViewLoaded = true;
				}
				if(!isDevicesViewLoaded && "devices"==stack.get_visible_child_name()){
					devicesTreeModelFilter = new Gtk.TreeModelFilter (NuttyApp.Devices.fetchRecordedDevices(), null);
					setFilterAndSort(NuttyApp.Devices.device_table_treeview, devicesTreeModelFilter, SortType.DESCENDING);
					isDevicesViewLoaded = true;
				}
			});
			info("[END] [FUNCTION:createExportDialog]");
			return main_ui_box;
		}

		public void loadNuttyState(){
			info("[START] [FUNCTION:loadNuttyState]");
			//Set the window to the last saved position
			if(settings.pos_x == 0 && settings.pos_y == 0){
				window.set_position (Gtk.WindowPosition.CENTER);
			}else{
				window.move(settings.pos_x, settings.pos_y);
			}
			//set window size to the last saved height/width
			if(settings.window_is_maximized){
				window.maximize();
			}else{
				if(settings.window_width > 0 && settings.window_height > 0){
					window.set_default_size(settings.window_width, settings.window_height);
				}else{
					window.set_default_size(1100, 600);
				}
			}
			//check if the database exists otherwise create database and required tables
			NuttyApp.DB.initializeNuttyDB(nutty_config_path);
			//Load state of various settings from last saved state
			DEVICE_SCHEDULE_SELECTED = settings.device_monitoring_scheduled;
			SPEEDTESTDATE = settings.last_speed_test_date;
			UPLOADSPEED = settings.last_recorded_upload_speed;
			DOWNLOADSPEED = settings.last_recorded_download_speed;
			debug("Loaded Nutty state with: " +
						"Window Position: x=" + settings.pos_x.to_string() + " and y="+settings.pos_y.to_string() +
						", Is the Window To be Maximized=" + settings.window_is_maximized.to_string() +
						", Window Sixe: width=" + settings.window_width.to_string() + " and height="+settings.window_height.to_string() +
						", Monitoring Schedule="+settings.device_monitoring_scheduled.to_string()+
						", Speed Test Date="+ settings.last_speed_test_date +
						", Last Upload Speed="+ settings.last_recorded_upload_speed +
						", Last Download Speed="+			settings.last_recorded_download_speed
			);
			info("[END] [FUNCTION:loadNuttyState]");
		}
	
		public void saveWindowState(){
			int width;
			int height;
			int x;
			int y;
			window.get_size (out width, out height);
			window.get_position (out x, out y);
			if(settings.pos_x != x || settings.pos_y != y){
				settings.pos_x = x;
				settings.pos_y = y;
				debug("Saved window position: x="+settings.pos_x.to_string()+
																	  ", y="+settings.pos_y.to_string());
			}
			if(settings.window_width != width || settings.window_height != height){
				settings.window_width = width;
				settings.window_height = height;
				debug("Saved window dimension: width="+settings.window_width.to_string()+
																		  ", height="+settings.window_height.to_string());
			}
			if(window.is_maximized == true){
				settings.window_is_maximized = true;
			}else{
				settings.window_is_maximized = false;
			}
		}

		public void saveNuttyState(){
			info("[START] [FUNCTION:saveNuttyState]");
			//Save state of various settings
			settings.device_monitoring_scheduled = DEVICE_SCHEDULE_SELECTED;
			settings.last_speed_test_date = SPEEDTESTDATE;
			settings.last_recorded_upload_speed = UPLOADSPEED;
			settings.last_recorded_download_speed = DOWNLOADSPEED;
			debug("Saving Nutty state with: " +
						"Monitoring Schedule="+settings.device_monitoring_scheduled.to_string()+
						", Speed Test Date="+ settings.last_speed_test_date +
						", Last Upload Speed="+ settings.last_recorded_upload_speed +
						", Last Download Speed="+			settings.last_recorded_download_speed
			);
			info("[END] [FUNCTION:saveNuttyState]");
		}

		public static void saveNuttyInfoToFile (string path, string filename) {
			debug("Started exporting Nutty information...");
			StringBuilder printDataText = new StringBuilder("");
			var now = new DateTime.now_local();
			printDataText.append("======").append(Constants.TEXT_FOR_NUTTY_EXPORT_HEADER).append(now.to_string()).append("======\n\n");

			Gtk.TreeModelForeachFunc print_row = (model, path, iter) => {
				int number_of_cols = model.get_n_columns();
				GLib.Value[] cellArray = new GLib.Value[number_of_cols];
				for(int i=0; i<number_of_cols;i++){
					model.get_value (iter, i, out cellArray[i]);
					if("gchararray" == cellArray[i].type_name()){
						printDataText.append("\"").append((string) cellArray[i]).append("\"").append(",");
					}else if("gint" == cellArray[i].type_name()){
						printDataText.append(((int) cellArray[i]).to_string()).append(",");
					}else if("gdouble" == cellArray[i].type_name()){
						printDataText.append(((double) cellArray[i]).to_string()).append(",");
					}else{
						//printDataText.append(" ").append(",");
					}
				}
				printDataText.append("\n");
				return false;
			};
			//Print Details of the Info Tab
			printDataText.append(Constants.TEXT_FOR_MYINFO_TAB).append("\n");
			printDataText.append(Constants.TEXT_FOR_MYINFO_COLUMN_NAME_1).append(",").append(Constants.TEXT_FOR_MYINFO_COLUMN_NAME_2).append("\n");
			info_list_store.foreach (print_row);
			printDataText.append("\n");
			//Print Details of Bandwidth Tab
			printDataText.append(Constants.TEXT_FOR_BANDWIDTH_TAB).append("\n");
			printDataText.append(Constants.TEXT_FOR_BANDWIDTH_COLUMN_NAME_1).append(",").append(Constants.TEXT_FOR_BANDWIDTH_COLUMN_NAME_2).append(",").append(Constants.TEXT_FOR_BANDWIDTH_COLUMN_NAME_3).append(",").append(Constants.TEXT_FOR_BANDWIDTH_COLUMN_NAME_4).append("\n");
			bandwidth_list_store.foreach (print_row);
			printDataText.append("\n");
			printDataText.append(Constants.TEXT_FOR_BANDWIDTH_PROCESS_COLUMN_NAME_2).append(",").append(Constants.TEXT_FOR_BANDWIDTH_PROCESS_COLUMN_NAME_3).append("\n");
			bandwidth_results_list_store.foreach (print_row);
			printDataText.append("\n");
			//Print Details of Speed Tab
			printDataText.append(Constants.TEXT_FOR_ROUTE_TAB).append("\n");
			printDataText.append(Constants.TEXT_FOR_SPEEDTEST_COLUMN_NAME_1).append(",").append(Constants.TEXT_FOR_SPEEDTEST_COLUMN_NAME_2).append("\n");
			speedtest_list_store.foreach (print_row);
			printDataText.append("\n");
			printDataText.append(Constants.TEXT_FOR_ROUTE_COLUMN_NAME_1).append(",").append(Constants.TEXT_FOR_ROUTE_COLUMN_NAME_2).append(",").append(Constants.TEXT_FOR_ROUTE_COLUMN_NAME_3).append(",").append(Constants.TEXT_FOR_ROUTE_COLUMN_NAME_4).append(",").append(Constants.TEXT_FOR_ROUTE_COLUMN_NAME_5).append(",").append(Constants.TEXT_FOR_ROUTE_COLUMN_NAME_6).append("\n");
			route_list_store.foreach (print_row);
			printDataText.append("\n");
			//Print Details of Devices Tab
			printDataText.append(Constants.TEXT_FOR_DEVICES_TAB).append("\n");
			printDataText.append(Constants.TEXT_FOR_DEVICES_COLUMN_NAME_2).append(",").append(Constants.TEXT_FOR_DEVICES_COLUMN_NAME_3).append(",").append(Constants.TEXT_FOR_DEVICES_COLUMN_NAME_4).append(",").append(Constants.TEXT_FOR_DEVICES_COLUMN_NAME_5).append(",").append(Constants.TEXT_FOR_DEVICES_COLUMN_NAME_6).append("\n");
			device_list_store.foreach (print_row);
			printDataText.append("\n");
			//Print Details of Ports Tab
			printDataText.append(Constants.TEXT_FOR_PORTS_TAB).append("\n");
			printDataText.append(Constants.TEXT_FOR_PORTS_COLUMN_NAME_1).append(",").append(Constants.TEXT_FOR_PORTS_COLUMN_NAME_2).append(",").append(Constants.TEXT_FOR_PORTS_COLUMN_NAME_3).append(",").append(Constants.TEXT_FOR_PORTS_COLUMN_NAME_4).append(",").append(Constants.TEXT_FOR_PORTS_COLUMN_NAME_5).append(",").append(Constants.TEXT_FOR_PORTS_COLUMN_NAME_6).append("\n");
			ports_tcp_list_store.foreach (print_row);
			printDataText.append("\n");
			//Write Nutty data to file
			fileOperations("WRITE",path, filename, printDataText.str);

			debug("Completed exporting Nutty information...");
		}

		public static bool disclaimerSetGet(int operation) {
			bool result = false;
			if(operation == Constants.HAS_DISCLAIMER_BEEN_AGREED){
				if("true" == NuttyApp.Utils.fileOperations(
											"EXISTS",
											nutty_config_path, 
											Constants.nutty_agreement_file_name, 
											"")
				)
					result=true; //Disclaimer has been agreed before
			}
			if(operation == Constants.REMEMBER_DISCLAIMER_AGREEMENT){
				NuttyApp.Utils.fileOperations(
											"WRITE",
											nutty_config_path, 
											Constants.nutty_agreement_file_name, 
											"Nutty disclaimer agreed by user["+
														GLib.Environment.get_user_name()+
														"] on machine["+GLib.Environment.get_host_name()+"]"
				);
				result=true;
			}
			debug("Nuty Disclaimer operation completed [for operation="+operation.to_string()+"] with result:"+result.to_string());
			return result;
		}

		public static string fileOperations (string operation, string path, string filename, string contents) {
			debug("Started file operation["+operation+"]...");
			StringBuilder result = new StringBuilder("false");
			string data = "";
			try{
				File fileDir = File.new_for_commandline_arg(path);
				File file = File.new_for_path(path+"/"+filename);
				if("WRITE" == operation){
					//check if directory does not exists
					if(!fileDir.query_exists ()){
						//create the directory
						fileDir.make_directory();
						//write the contents to file
						FileUtils.set_contents (path+"/"+filename, contents);
						result.assign("true");
					}else{
						//write or overwrite contents to file
						FileUtils.set_data (path+"/"+filename, contents.data);
						result.assign("true");
					}
					//close and release the file
					FileUtils.close(new IOChannel.file(path+"/"+filename, "r").unix_get_fd());
				}
				if("WRITE_PROPS" == operation){
					//check if directory does not exists
					if(!fileDir.query_exists ()){
						//create the directory
						fileDir.make_directory();
						//write the contents to file
						FileUtils.set_contents (path+"/"+filename, contents);
					}
					bool wasRead = FileUtils.get_contents(path+"/"+filename, out data);
					if(wasRead){
						string[] name_value = contents.split(Constants.IDENTIFIER_FOR_PROPERTY_VALUE, -1);
						//get the contents of the file
						result.assign(data);
						//check if the property (name/value) exists
						if(data.contains(name_value[0])){
							//extract the data before the property name
							string dataBeforeProp = result.str.split(Constants.IDENTIFIER_FOR_PROPERTY_START+contents.split(Constants.IDENTIFIER_FOR_PROPERTY_VALUE,2)[0],2)[0];
							//extract the data after the property name/value
							string dataAfterProp = result.str.split(contents+Constants.IDENTIFIER_FOR_PROPERTY_END)[1];
							//name/value exists - update the same
							result.append(dataBeforeProp+contents+dataAfterProp);
							//update the modified contents to file
							FileUtils.set_contents (path+"/"+filename, result.str);
						}else{
							//name/value does not exists - write the same
							result.append(Constants.IDENTIFIER_FOR_PROPERTY_START+contents+Constants.IDENTIFIER_FOR_PROPERTY_END);
							FileUtils.set_contents (path+"/"+filename, result.str);
						}
						//close and release the file
						FileUtils.close(new IOChannel.file(path+"/"+filename, "r").unix_get_fd());
					}else
						result.assign("false");
					}
				if("READ" == operation){
					if(file.query_exists ()){
						bool wasRead = FileUtils.get_contents(path+"/"+filename, out data);
						if(wasRead){
							result.assign(data);
						}else{
							result.assign("false");
						}
						//close and release the file
						FileUtils.close(new IOChannel.file(path+"/"+filename, "r").unix_get_fd());
					}else{
						result.assign("false");
					}
				}
				if("READ_PROPS" == operation){
					if(nutty_state_data.length > 5){ //nutty state data exists - no need to read the nutty state file
						data  = nutty_state_data;
					}else{ //nutty state data is not available - read the nutty state file
						if(file.query_exists ()){
							bool wasRead = FileUtils.get_contents(path+"/"+filename, out data);
							if(wasRead){
								//set the global variable for the nutty state data to avoid reading the contents again
								nutty_state_data = data;
							}else{
								result.assign("false");
							}
							//close and release the file
							FileUtils.close(new IOChannel.file(path+"/"+filename, "r").unix_get_fd());
						}else{
							result.assign("false");
						}
					}
					//get the part of the contents starting with the value of the props
					result.assign(data.split(Constants.IDENTIFIER_FOR_PROPERTY_START+contents+Constants.IDENTIFIER_FOR_PROPERTY_VALUE,2)[1]);
					//get the value of the prop
					result.assign(result.str.split(Constants.IDENTIFIER_FOR_PROPERTY_END,2)[0]);
				}
				if("DELETE" == operation){
					FileUtils.remove(path+"/"+filename);
				}
				if("EXISTS" == operation){
					if(file.query_exists ()){
						result.assign("true");
					}
				}
				if("IS_EXECUTABLE" == operation){
					if(FileUtils.test (path+"/"+filename, FileTest.IS_EXECUTABLE)){
						result.assign("true");
					}
				}
				if("MAKE_EXECUTABLE" == operation){
					execute_sync_command ("chmod +x "+path+"/"+filename);
					result.assign("true");
				}
				if("SET_PERMISSIONS" == operation){
					execute_sync_command ("chmod "+contents+" "+path+"/"+filename);
					result.assign("true");
				}
			}catch (Error e){
				warning("Failure in File Operation [operation="+operation+",path="+path+", filename="+filename+"]: "+e.message);
				result.assign("false:"+e.message);
			}
			debug("Completed file operation["+operation+"]...");
			return result.str;
		}

		public static bool process_line (IOChannel channel, IOCondition condition, string stream_name) {
			if (condition == IOCondition.HUP) {
				return false;
			}
			try {
				string line;
				channel.read_line (out line, null, null);
				spawn_async_with_pipes_output.append(line);
			} catch (IOChannelError e) {
				spawn_async_with_pipes_output.append(e.message);
				warning("IOChannelError in reading command output:"+e.message);
				return false;
			} catch (ConvertError e) {
				spawn_async_with_pipes_output.append(e.message);
				warning("ConvertError in reading command output:"+e.message);
				return false;
			}
			return true;
		}

		public static int execute_sync_multiarg_command_pipes(string[] spawn_args) {
			debug("Starting to execute async command: "+string.joinv(" ", spawn_args));
			spawn_async_with_pipes_output.erase(0, -1); //clear the output buffer
			MainLoop loop = new MainLoop ();
			try {
				string[] spawn_env = Environ.get();
				Pid child_pid;

				int standard_input;
				int standard_output;
				int standard_error;

				Process.spawn_async_with_pipes ("/",
					spawn_args,
					spawn_env,
					SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
					null,
					out child_pid,
					out standard_input,
					out standard_output,
					out standard_error);

				// capture stdout:
				IOChannel output = new IOChannel.unix_new (standard_output);
				output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
					return process_line (channel, condition, "stdout");
				});

				// capture stderr:
				IOChannel error = new IOChannel.unix_new (standard_error);
				error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
					return process_line (channel, condition, "stderr");
				});

				ChildWatch.add (child_pid, (pid, status) => {
					// Triggered when the child indicated by child_pid exits
					Process.close_pid (pid);
					loop.quit ();
				});
				loop.run ();
			} catch(SpawnError e) {
				warning("Failure in executing async command ["+
						string.joinv(" ", spawn_args)+"] : "+
						e.message
				);
				spawn_async_with_pipes_output.append(e.message);
			}
			debug("Completed executing async command["+string.joinv(" ", spawn_args)+"]...");
			return 0;
		}

		public static string execute_sync_command (string cmd){
			debug("Starting to execute sync command ["+cmd+"]...");
			string std_out;
			string std_err;
			try {
				Process.spawn_command_line_sync(cmd, out std_out, out std_err, out exitCodeForCommand);
				if(exitCodeForCommand != 0){
					warning("Error encountered in execution of sync command ["+cmd+"]: "+std_err);
				}
			}catch (Error e){
				warning("Error encountered in execution of sync command ["+cmd+"]: "+e.message);
			}
			debug("Completed execution of sync command ["+cmd+"]...");
			return std_out;
		}

		public static bool filterTree(TreeModel model, TreeIter iter){
			bool isFilterCriteriaMatch = true;
			string modelValueString = "";
			//If there is nothing to filter or the default help text then make the data visible
			if ((headerSearchBar.get_text() == "")){
					isFilterCriteriaMatch = true;
			//extract data from the tree model and match against the filter input
			}else{
				GLib.Value modelValue;
				int noOfColumns = model.get_n_columns();
				for (int count = 0; count < noOfColumns; count++){
					model.get_value (iter, count, out modelValue);
					if(modelValue.strdup_contents().strip() != null){
						//Attempt to get the value as a string - modelValueString will be empty if attempt fails
						modelValueString = modelValue.strdup_contents().strip();
						//Check the value of modelValueString and attempt to match to search string if it is not empty
						if("" != modelValueString || modelValueString != null){
							if ((modelValueString.up()).contains((headerSearchBar.get_text()).up())){
								isFilterCriteriaMatch = true;
								break;
							}else{
								isFilterCriteriaMatch =  false;
							}
						}
					}
					modelValue.unset();
				}
			}
			return isFilterCriteriaMatch;
		}

		public static void setFilterAndSort(TreeView aTreeView, Gtk.TreeModelFilter aTreeModelFilter, SortType aSortType){
			aTreeModelFilter.set_visible_func(filterTree);
			Gtk.TreeModelSort aTreeModelSort = new TreeModelSort.with_model (aTreeModelFilter);
			aTreeView.set_model(aTreeModelSort);
			int noOfColumns = aTreeView.get_model().get_n_columns();
			for(int count=0; count<noOfColumns; count++){
				aTreeView.get_column(count).set_sort_column_id(count);
				aTreeView.get_column(count).set_sort_order(aSortType);
			}
		}

		public static Gtk.ListStore processRouteScan(string tracerouteDestination){
			debug("Starting to process RouteScan["+tracerouteDestination+"]...");
			route_list_store.clear();
			try{
				TreeIter iter;
				string serverName = "";
				string serverIP = "";
				string[] firstPacket = {" "};
				string[] secondPacket = {" "};
				string[] thirdPacket = {" "};

				execute_sync_multiarg_command_pipes(
					{Constants.COMMAND_FOR_TRACEROUTE, tracerouteDestination}
				);
				//handle unsucessful command execution and raise error on infobar
				if(!Utils.isExpectedOutputPresent(
								string.joinv(" ", {Constants.COMMAND_FOR_TRACEROUTE, tracerouteDestination}),
								spawn_async_with_pipes_output.str,
								{"hops", "byte", "packets", "ms"},
								true
					)
				){
					traceRouteSpinner.stop();
					return route_list_store;
				}
				Gee.ArrayList<Gee.ArrayList<string>> tableData =  Utils.convertMultiLinesToTableArray(
							spawn_async_with_pipes_output.str, 
							6, 
							"  "
				);
				if(exitCodeForCommand != 0){
					route_results_label.set_text(spawn_async_with_pipes_output.str.replace("/n",".."));
				}else if(tableData == null){//handle no output from command
					route_results_label.set_text(Constants.TEXT_FOR_NO_DATA_FOUND);
				}else if (tableData != null){
					if(tableData.size < 1){
						route_results_label.set_text(Constants.TEXT_FOR_NO_DATA_FOUND);
					}else{
						int countHops = 0;
						foreach(Gee.ArrayList<string> rowData in tableData){
							if(countHops == 0){
								route_results_label.set_text(rowData.get(0));
							} else {
								if(rowData.size >3){
									serverIP = Utils.extractBetweenTwoStrings(rowData.get(1), "(", ")").strip();
									serverName = rowData.get(1).replace("("+serverIP+")", "").strip();

									/* split the information of the packet time from the server they were received
									 * The information sometimes contains the server name and ip along with the time in the format
									 * 36.973 ms host-78-151-228-25.as13285.net (78.151.228.25)
									 * splitting by "ms" gets the time in the first array for displaying in the table
									 * TODO: hold and use the server details in the second array for displaying on mouse over
									 */
									if(rowData.get(2) != null)
										firstPacket = rowData.get(2).split("ms");
									if(rowData.get(3) != null)
										secondPacket = rowData.get(3).split("ms");
									if(rowData.get(4) != null)
										thirdPacket = rowData.get(4).split("ms");
									route_list_store.append (out iter);
									route_list_store.set (iter, 
										0, int.parse(rowData.get(0)), 
										1, serverIP, 
										2, serverName, 
										3, double.parse(firstPacket[0]), 
										4, double.parse(secondPacket[0]), 
										5, double.parse(thirdPacket[0])
									);
								}
							}
							countHops++;
						}
					}
				}
			}catch(Error e){
				warning("Failure in processing RouteScan:"+e.message);
			}
			traceRouteSpinner.stop();
			debug("Completed processing RouteScan["+tracerouteDestination+"]...");
			return route_list_store;
		}

		public static Gtk.ListStore processPortsScan(string commandForPorts){
			debug("Starting to process PortsScan["+ commandForPorts +"]...");
			ports_tcp_list_store.clear();
			try{
				TreeIter iter;
				bool isTCP = false;
				bool isUnix = false;
				int columnCount = 0;
				StringBuilder unixProtocol = new StringBuilder();
				StringBuilder unixState = new StringBuilder();
				StringBuilder unixPort = new StringBuilder();
				StringBuilder unixPID = new StringBuilder();
				StringBuilder unixProgram = new StringBuilder();
				StringBuilder unixPath = new StringBuilder();

				execute_sync_multiarg_command_pipes ({commandForPorts});
				debug("Output of command execution:\n"+spawn_async_with_pipes_output.str);
				//handle unsucessful command execution and raise error on infobar
				if(!Utils.isExpectedOutputPresent(
								commandForPorts,
								spawn_async_with_pipes_output.str,
								{"tcp", "unix", "CLOSE_WAIT", "ESTABLISHED"},
								false
					)
				){
					portsSpinner.stop();
					return ports_tcp_list_store;
				}
				Gee.ArrayList<Gee.ArrayList<string>> tableData =
						Utils.convertMultiLinesToTableArray(spawn_async_with_pipes_output.str, 100, "  ");

				foreach(Gee.ArrayList<string> rowData in tableData){
					if(rowData.get(0).index_of("tcp") != -1){
						isTCP = true;
						isUnix = false;
					}else if(rowData.get(0).index_of("unix") != -1){
						isTCP = false;
						isUnix = true;
					}else{
						isTCP = false;
						isUnix = false;
					}
					columnCount = 0;
					foreach(string columnData in rowData){
						if(isUnix){
							if(columnData.strip().length > 0){
								if(columnCount==0)
									unixProtocol.append(columnData);
								if(columnCount==4)
									unixState.append(columnData);
								if(columnCount==5)
									unixPort.append(columnData);
								if(columnCount==6){
									if(columnData.index_of("/") != -1){
										unixPID.append(columnData.substring(0,columnData.index_of("/")));
										if((columnData.substring(columnData.index_of("/")+1)).index_of("@") != -1){
											unixProgram.append((columnData.substring(columnData.index_of("/")+1)).substring(0,(columnData.substring(columnData.index_of("/")+1)).index_of("@")));
											unixPath.append((columnData.substring(columnData.index_of("/")+1)).substring((columnData.substring(columnData.index_of("/")+1)).index_of("@")));
										}else
											unixProgram.append(columnData.substring(columnData.index_of("/")+1));
									}
								}
								if(columnCount==7)
									unixPath.append(columnData);

								columnCount++;
							}
						}
						if(isTCP){
							if(columnData.strip().length > 0){
								if(columnCount==0)
									unixProtocol.append(columnData);
								if(columnCount==5 || columnCount==6)
									if(columnData.index_of("/") != -1){
										unixPID.append(columnData.substring(0,columnData.index_of("/")));
										unixProgram.append(columnData.substring(columnData.index_of("/")+1));
									}
								if(columnCount==3 || columnCount==4){
									if(columnData.index_of("CLOSE_WAIT") != -1)
										unixState.append("CLOSE_WAIT");
									if(columnData.index_of("ESTABLISHED") != -1)
										unixState.append("ESTABLISHED");
								}
								if(columnCount==3){
									if(columnData.index_of("CLOSE_WAIT") != -1)
										unixPath.append(columnData.replace("CLOSE_WAIT","").strip());
									if(columnData.index_of("ESTABLISHED") != -1)
										unixPath.append(columnData.replace("ESTABLISHED","").strip());
								}
								columnCount++;
							}
						}
					}
					if((isUnix && unixPID.str.length >1) || (isTCP && unixPID.str.length >1)){
						ports_tcp_list_store.append (out iter);
						ports_tcp_list_store.set (iter, 0, unixProtocol.str, 1, unixState.str, 2, unixPort.str, 3, unixPID.str, 4, unixProgram.str, 5, unixPath.str);
					}

					unixProtocol.erase(0,-1);
					unixState.erase(0,-1);
					unixPort.erase(0,-1);
					unixPID.erase(0,-1);
					unixProgram.erase(0,-1);
					unixPath.erase(0,-1);
				}
				portsSpinner.stop();
				ports_results_label.set_text(Constants.TEXT_FOR_PORTS_RESULTS);
			}catch(Error e){
				warning("Failure to process PortsScan:"+e.message);
			}
			debug("Completed processing PortsScan["+ commandForPorts +"]...");
			return ports_tcp_list_store;
		}

		public static string getHostManufacturerOnline (string MAC){
			debug("Starting to get Host Manufacturer Name from MAC Id["+MAC+"] by Online search...");
			string manufacturerName = "";
			try{
				string[] commandForMACQueryOnline = COMMAND_FOR_ONLINE_MANUFACTURE_NAME;
				commandForMACQueryOnline[3] = COMMAND_FOR_ONLINE_MANUFACTURE_NAME[3].replace("MAC-ID-SUBSTITUTION",MAC);
				execute_sync_multiarg_command_pipes(commandForMACQueryOnline);
				string onlineResults = spawn_async_with_pipes_output.str;
				if(onlineResults != null && onlineResults.length > 20 )
					manufacturerName = Utils.extractXMLTag(onlineResults, "<company>", "</company>");
				if(manufacturerName == "" )
					manufacturerName = Constants.TEXT_FOR_NOT_AVAILABLE;
			}catch(Error e){
				warning("Failure in getting Manufacture Name by online search:"+e.message);
			}
			debug("Completed getting Host Manufacturer Name from MAC Id["+MAC+"] by Online search...");
			return manufacturerName;
		}

		public static Gtk.ListStore processBandwidthApps(string interface_name){
			debug("Starting to process bandwidth of apps[interface_name="+interface_name+"]...");
			bandwidth_results_list_store.clear();
			TreeIter iter;
			Gdk.Pixbuf app_icon = default_app_pix;;
			StringBuilder processNames = new StringBuilder();
			StringBuilder aProcessName = new StringBuilder();
			bandwidthProcessSpinner.start();

			execute_sync_multiarg_command_pipes({
				"pkexec", 
				Constants.COMMAND_FOR_PROCESS_BANDWIDTH, 
				interface_name
			});
			//handle unsucessful command execution and raise error on infobar
			if(!Utils.isExpectedOutputPresent(
							" " + "pkexec" + Constants.COMMAND_FOR_PROCESS_BANDWIDTH + interface_name,
							spawn_async_with_pipes_output.str,
							{"\t", "/"},
							false
				)
			){
				bandwidthProcessSpinner.stop();
				return bandwidth_results_list_store;
			}
			string process_bandwidth_result = spawn_async_with_pipes_output.str;

			//split the individual lines in the output
			string[] linesWithProcessData = process_bandwidth_result.strip().split ("\n",-1);
			foreach(string data in linesWithProcessData){
				//only consider those lines with a tab (i.e. "\t")
				if(data.contains("\t")){
					//split data by tab
					string[] processDataAttributes = data.strip().split ("\t",-1);
					//consider only those processes which donot have zero received and sent data
					if(processDataAttributes.length > 2 && !(processDataAttributes[1] == "0" && processDataAttributes[2] == "0")){
						string[] processNameAttributes = processDataAttributes[0].strip().split ("/",-1);
						if(processNameAttributes.length > 2){
							aProcessName.append(processNameAttributes[processNameAttributes.length - 3]);
						}else{
							aProcessName.append(processNameAttributes[0]);
						}
						if(!processNames.str.contains(aProcessName.str)){
							//break the process name further if possible
							if(aProcessName.str.contains(" ")){
								processNames.append(aProcessName.str);
								aProcessName.assign(aProcessName.str.split (" ",-1)[0]);
							}
							if(aProcessName.str.contains("--")){
								processNames.append(aProcessName.str);
								aProcessName.assign(aProcessName.str.split ("--",-1)[0]);
							}
							// Get the icon:
							try {
								app_icon = icon_theme.load_icon (aProcessName.str, 16, 0);
								if(app_icon == null){
									app_icon = default_app_pix;
								}
							} catch (Error e) {
								warning (e.message);
							}

							bandwidth_results_list_store.append (out iter);
							bandwidth_results_list_store.set (iter, 
									0, app_icon, 
									1, aProcessName.str, 
									2, processDataAttributes[1], 
									3, processDataAttributes[2]
							);
							processNames.append(aProcessName.str);
						}
					}
					aProcessName.erase(0, -1);
					app_icon = default_app_pix;
				}
			}
			bandwidthProcessSpinner.stop();
			debug("Completed processing bandwidth of apps[interface_name="+interface_name+"]...");
			return bandwidth_results_list_store;
		}

		public static Gtk.ListStore processBandwidthUsage(string interface_name){
			debug("Starting to process bandwidth usage[interface_name="+interface_name+"]...");
			bandwidth_list_store.clear();
			try{
				TreeIter iter;
				//execute vnstat command to produce xml output (all values in KB)
				execute_sync_multiarg_command_pipes({
					Constants.COMMAND_FOR_BANDWIDTH_USAGE, 
					interface_name
				});
				//handle unsucessful command execution and raise error on infobar
				if(!Utils.isExpectedOutputPresent(
								string.joinv(" ", {Constants.COMMAND_FOR_BANDWIDTH_USAGE, interface_name}),
								spawn_async_with_pipes_output.str,
								{"<created>", "</created>"},
								true
					)
				){
					return bandwidth_list_store;
				}
				string bandwidth_usage_result = spawn_async_with_pipes_output.str;
				//present a user friendly message if the interface database is not present
				if(Constants.IDENTIFIER_FOR_NO_DB_FOUND_IN_VNSTAT_OUTPUT in bandwidth_usage_result){
					//set results if no data is found for this interface
					bandwidth_results_label.set_text(Constants.TEXT_FOR_BANDWIDTH_INTERFACE_NO_DB_FOUND);
				//parse results to extract data
				}else{
					//set header results
					string interfaceMonitoredFrom = "";
					string interfaceMonitoredLast = "";

					string monitoredFromDate = Utils.extractXMLTag(bandwidth_usage_result, "<created>", "</created>");
					if(monitoredFromDate.contains("<day>") && monitoredFromDate.contains("<month>") && monitoredFromDate.contains("<year>")){
						interfaceMonitoredFrom = Utils.extractXMLTag(monitoredFromDate,"<day>", "</day>")+"-"+Utils.extractXMLTag(monitoredFromDate,"<month>", "</month>")+"-"+Utils.extractXMLTag(monitoredFromDate,"<year>", "</year>");
					}
					string lastMonitoredDate = Utils.extractXMLTag(bandwidth_usage_result, "<updated>", "</updated>");
					if(lastMonitoredDate.contains("<day>") && lastMonitoredDate.contains("<month>") && lastMonitoredDate.contains("<year>")){
						interfaceMonitoredLast = Utils.extractXMLTag(lastMonitoredDate,"<day>", "</day>")+"-"+Utils.extractXMLTag(lastMonitoredDate,"<month>", "</month>")+"-"+Utils.extractXMLTag(lastMonitoredDate,"<year>", "</year>");
					}
					bandwidth_results_label.set_text(Constants.TEXT_FOR_BANDWIDTH_INTERFACE_RESULTS_1+interfaceMonitoredFrom+Constants.TEXT_FOR_BANDWIDTH_INTERFACE_RESULTS_2+interfaceMonitoredLast);

					//get monthly data
					string allMonthsData = Utils.extractXMLTag(bandwidth_usage_result, "<months>", "</months>");

					//set data for previous month
					string previousMonthData = Utils.extractNestedXMLAttribute(allMonthsData, "<month id=\"1\">", "</month>", 2);
					if("" != previousMonthData && previousMonthData!= null){
						string previousYear = Utils.extractXMLTag(previousMonthData, "<year>", "</year>");
						string previousMonth = Utils.extractXMLTag(previousMonthData, "<month>", "</month>");
						string previousMonthReceivedValue = Utils.extractXMLTag(previousMonthData, "<rx>", "</rx>");
						string previousMonthTransmittedValue = Utils.extractXMLTag(previousMonthData, "<tx>", "</tx>");
						DateTime extractedDate = new DateTime.utc (int.parse(previousYear), int.parse(previousMonth), 22, 9, 22, 0);
						bandwidth_list_store.append (out iter);
						bandwidth_list_store.set (iter, 0, extractedDate.format ("%b'%y"), 1, Utils.convertKiloByteToHigherUnit(previousMonthReceivedValue), 2, Utils.convertKiloByteToHigherUnit(previousMonthTransmittedValue), 3, Utils.convertKiloByteToHigherUnit((int.parse(previousMonthReceivedValue)+int.parse(previousMonthTransmittedValue)).to_string()));
					}

					//set data for current month
					string currentMonthData = Utils.extractNestedXMLAttribute(allMonthsData, "<month id=\"0\">", "</month>", 2);
					if("" != currentMonthData && currentMonthData != null){
						string currentYear = Utils.extractXMLTag(currentMonthData, "<year>", "</year>");
						string currentMonth = Utils.extractXMLTag(currentMonthData, "<month>", "</month>");
						string currentMonthReceivedValue = Utils.extractXMLTag(currentMonthData, "<rx>", "</rx>");
						string currentMonthTransmittedValue = Utils.extractXMLTag(currentMonthData, "<tx>", "</tx>");
						DateTime extractedDate = new DateTime.utc (int.parse(currentYear), int.parse(currentMonth), 22, 9, 22, 0);
						bandwidth_list_store.append (out iter);
						bandwidth_list_store.set (iter, 0, extractedDate.format ("%b'%y"), 1, Utils.convertKiloByteToHigherUnit(currentMonthReceivedValue), 2, Utils.convertKiloByteToHigherUnit(currentMonthTransmittedValue), 3, Utils.convertKiloByteToHigherUnit((int.parse(currentMonthReceivedValue)+int.parse(currentMonthTransmittedValue)).to_string()));
					}

					//get daily data
					string allDailyData = Utils.extractXMLTag(bandwidth_usage_result, "<days>", "</days>");

					//set data for yesterday
					string yesterdayData = Utils.extractNestedXMLAttribute(allDailyData, "<day id=\"1\">", "</day>", 2);
					if("" != yesterdayData || yesterdayData !=null){
						string yesterdayReceivedValue = Utils.extractXMLTag(yesterdayData, "<rx>", "</rx>");
						string yesterdayTransmittedValue = Utils.extractXMLTag(yesterdayData, "<tx>", "</tx>");
						bandwidth_list_store.append (out iter);
						bandwidth_list_store.set (iter, 0, Constants.TEXT_FOR_BANDWIDTH_YESTERDAY, 1, Utils.convertKiloByteToHigherUnit(yesterdayReceivedValue), 2, Utils.convertKiloByteToHigherUnit(yesterdayTransmittedValue), 3, Utils.convertKiloByteToHigherUnit((int.parse(yesterdayReceivedValue)+int.parse(yesterdayTransmittedValue)).to_string()));
					}

					//set data for today
					string todayData = Utils.extractNestedXMLAttribute(allDailyData, "<day id=\"0\">", "</day>", 2);
					if("" != todayData || todayData !=null){
						string todayReceivedValue = Utils.extractXMLTag(todayData, "<rx>", "</rx>");
						string todayTransmittedValue = Utils.extractXMLTag(todayData, "<tx>", "</tx>");
						bandwidth_list_store.append (out iter);
						bandwidth_list_store.set (iter, 0, Constants.TEXT_FOR_BANDWIDTH_TODAY, 1, Utils.convertKiloByteToHigherUnit(todayReceivedValue), 2, Utils.convertKiloByteToHigherUnit(todayTransmittedValue), 3, Utils.convertKiloByteToHigherUnit((int.parse(todayReceivedValue)+int.parse(todayTransmittedValue)).to_string()));
					}
				}
			}catch(Error e){
				warning("Failure in processing bandwidth usage[interface_name="+interface_name+"]:"+e.message);
			}
			debug("Completed processing bandwidth usage[interface_name="+interface_name+"]...");
			return bandwidth_list_store;
		}

		/* This function uses the speedtest-cli script to measure internet speed
		*  Copyright 2012-2015 Matt Martz
		*  speedtest-cli version used: 0.3.4
		*/
		public static Gtk.ListStore processSpeedTest(bool shouldExecute){
			debug("Starting to process SpeedTest...");
			speedtest_list_store.clear();
			TreeIter iter;
			if(shouldExecute){
				if(! COMMAND_FOR_SPEED_TEST[0].contains(Constants.NUTTY_SCRIPT_PATH)){
					COMMAND_FOR_SPEED_TEST[0] = Constants.NUTTY_SCRIPT_PATH+ "/" + COMMAND_FOR_SPEED_TEST[0];
				}
				execute_sync_multiarg_command_pipes(COMMAND_FOR_SPEED_TEST);
				//handle unsucessful command execution and raise error on infobar
				if(!Utils.isExpectedOutputPresent(
								string.joinv(" ", COMMAND_FOR_SPEED_TEST),
								spawn_async_with_pipes_output.str,
								{"Upload", "Download"},
								true
					)
				){
					speedTestSpinner.stop();
					return speedtest_list_store;
				}
				string speedtest_result = spawn_async_with_pipes_output.str;
				UPLOADSPEED = speedtest_result.slice(speedtest_result.index_of(Constants.IDENTIFIER_FOR_UPLOAD_IN_SPEED_TEST,0)+Constants.IDENTIFIER_FOR_UPLOAD_IN_SPEED_TEST.length+1, speedtest_result.index_of("\n",speedtest_result.index_of("Upload:",0)));
				DOWNLOADSPEED = speedtest_result.slice(speedtest_result.index_of(Constants.IDENTIFIER_FOR_DOWNLOAD_IN_SPEED_TEST,0)+Constants.IDENTIFIER_FOR_DOWNLOAD_IN_SPEED_TEST.length+1, speedtest_result.index_of("\n",speedtest_result.index_of("Download:",0)));
				SPEEDTESTDATE = new DateTime.now_local().format("%d-%b-%Y %H:%M:%S");
			}
			speedtest_list_store.append (out iter);
			speedtest_list_store.set (iter, 0, UPLOADSPEED, 1, DOWNLOADSPEED);
			speedTestSpinner.stop();
			speed_test_refresh_button.set_sensitive(true);
			debug("Completed processing SpeedTest...");
			return speedtest_list_store;
		}
	}
	public static void loadCSSProvider(Gtk.CssProvider cssProvider){
		info("[START] [FUNCTION:loadCSSProvider] cssProvider="+cssProvider.to_string());
		try{															;
			cssProvider.load_from_data(	NuttyApp.Constants.DYNAMIC_CSS_CONTENT,
																NuttyApp.Constants.DYNAMIC_CSS_CONTENT.length);
		}catch(GLib.Error e){
			warning("Stylesheet could not be loaded from CSS Content["+
							 NuttyApp.Constants.DYNAMIC_CSS_CONTENT+"]. Error:"+
						     e.message);
		}
		Gtk.StyleContext.add_provider_for_screen(
			Gdk.Screen.get_default(),
			cssProvider,
			Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
		);
		info("[END] [FUNCTION:loadCSSProvider]");
	}
}
