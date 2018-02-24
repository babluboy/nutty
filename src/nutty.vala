/* Copyright 2015 Siddhartha Das (bablu.boy@gmail.com)
*
* This file is part of Nutty.
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
		private static Nutty application;
		public static string[] commandLineArgs;
		public Gtk.Window window;
		public string PRIMARY_TEXT_FOR_DISCLAIMER = _("You have permissions to scan devices on your network.");
		public string SECONDARY_TEXT_FOR_DISCLAIMER = _("This application has features to perform port scanning and provide information on devices on the network you are using.")+ "\n" +
										 _("It is perfectly OK to scan for devices on your own residential home network or when explicitly authorized by the destination host and/or network. ") +
										 _("While using port scan (Devices tab) on a network which you do not own please consult and get approval of the Network Administrator or other competent network authority. ") + "\n\n" +
										 _("Please read the following disclaimer on Nmap (used by Nutty) for further information: ") + "\n" +
										 "<a href='http://nmap.org/book/legal-issues.html'>http://nmap.org/book/legal-issues.html</a> \n\n" +
										 _("If you have read and understood the above, click the \"I Agree\" button below to proceed");
		public string TEXT_FOR_WIRED_CONNECTION = _("Wired");
		public string TEXT_FOR_WIRELESS_CONNECTION = _("Wireless");
		public string TEXT_FOR_OTHER_CONNECTION = _("Other");
		public string TEXT_FOR_DEVICE_FOUND_NOTIFICATION = _("New Device found on network:\n");
		public string[] COMMAND_FOR_INTERFACE_HARDWARE_DETAILED = {"lshw", "-xml", "-class", "network"};
		public string[] COMMAND_FOR_BANDWIDTH_USAGE = {"vnstat", "--xml", "-i", "<interface goes here>"};
		public string[] COMMAND_FOR_ONLINE_MANUFACTURE_NAME = {"curl", "-d", "test", "http://www.macvendorlookup.com/api/v2/MAC-ID-SUBSTITUTION/xml"};
		public string[] COMMAND_FOR_SPEED_TEST = {"speedtest-cli", "--simple", "--bytes"};
		public bool hasDisclaimerBeenAgreed = false;
		public string crontabContents = "";
		public static string nutty_executable_path = Environment.find_program_in_path ("nutty");
		public static string nutty_config_path = GLib.Environment.get_user_config_dir ()+"/nutty";
		public static Gtk.IconTheme icon_theme;
		public static Gdk.Pixbuf device_available_pix;
		public static Gdk.Pixbuf device_offline_pix;
		public static Gdk.Pixbuf default_app_pix;
		public int DEVICE_SCHEDULE_ENABLED = 1;
		public int DEVICE_SCHEDULE_DISABLED = 0;
		public int DEVICE_SCHEDULE_STATE = -1;
		public int DEVICE_SCHEDULE_SELECTED = -1;
		public string UPLOADSPEED = "0";
		public string DOWNLOADSPEED = "0";
		public string SPEEDTESTDATE = "";
		public int exitCodeForCommand = 0;
		public StringBuilder spawn_async_with_pipes_output = new StringBuilder("");
		public Stack stack;
		public Gee.HashMap<string,string> interfaceConnectionMap;
		public Gee.HashMap<string,string> interfaceIPMap;
		public Gee.HashMap<string,string> interfaceMACMap;
		public StringBuilder interfaceCommandOutputMinimal = new StringBuilder("");
		public StringBuilder interfaceCommandOutputDetailed = new StringBuilder("");
		public Gtk.TreeStore info_list_store = new Gtk.TreeStore (2, typeof (string), typeof (string));
		public Gtk.ListStore route_list_store = new Gtk.ListStore (6, typeof (int), typeof (string), typeof (string), typeof (double), typeof (double), typeof (double));
		public Gtk.ListStore ports_tcp_list_store = new Gtk.ListStore (6, typeof (string), typeof (string), typeof (string), typeof (string), typeof (string), typeof (string));
		public Gtk.ListStore device_list_store = new Gtk.ListStore (6, typeof (Gdk.Pixbuf), typeof (string), typeof (string), typeof (string), typeof (string), typeof (string));
		public Gtk.ListStore bandwidth_results_list_store = new Gtk.ListStore (4, typeof (Gdk.Pixbuf), typeof (string), typeof (string), typeof (string));
		public Gtk.ListStore bandwidth_list_store = new Gtk.ListStore (4, typeof (string), typeof (string), typeof (string), typeof (string));
		public Gtk.ListStore speedtest_list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
		public Spinner infoProcessSpinner;
		public string HostName;
		public Gtk.SearchEntry headerSearchBar;
		public Spinner traceRouteSpinner;
		public Label route_results_label;
		public Spinner speedTestSpinner;
		public Button speed_test_refresh_button;
		public Label speed_test_results_label;
		public bool isPortsViewLoaded = false;
		public Label ports_results_label;
		public Spinner portsSpinner;
		public Label devices_results_label;
		public Spinner devicesSpinner;
		public bool isDevicesViewLoaded = false;
		public Label bandwidth_results_label;
		public bool isBandwidthViewLoaded = false;
		public Spinner bandwidthProcessSpinner;
		public Gtk.RadioButton min15Option;
		public Gtk.RadioButton min30Option;
		public Gtk.RadioButton hourOption;
		public Gtk.RadioButton dayOption;
		public Gtk.TreeModelFilter infoTreeModelFilter;
		public Gtk.TreeModelFilter portsTreeModelFilter;
		public Gtk.TreeModelFilter routeTreeModelFilter;
		public Gtk.TreeModelFilter speedTestTreeModelFilter;
		public Gtk.TreeModelFilter devicesTreeModelFilter;
		public Gtk.TreeModelFilter bandwidthTreeModelFilter;
		public Gtk.TreeModelFilter bandwidthProcessTreeModelFilter;
		public StringBuilder infoSearchEntry = new StringBuilder ("");
		public StringBuilder portsSearchEntry = new StringBuilder ("");
		public StringBuilder routeSearchEntry = new StringBuilder ("");
		public StringBuilder devicesSearchEntry = new StringBuilder ("");
		public StringBuilder bandwidthSearchEntry = new StringBuilder ("");
		public static bool command_line_option_version = false;
		public static bool command_line_option_alert = false;
		public static bool command_line_option_debug = false;
		public static bool command_line_option_info = false;
		[CCode (array_length = false, array_null_terminated = true)]
		public static string command_line_option_monitor = "";
		public new OptionEntry[] options;
		public string nutty_state_data = "";

		construct {
			application_id = NuttyApp.Constants.nutty_id;
			flags |= ApplicationFlags.HANDLES_COMMAND_LINE;
			program_name = NuttyApp.Constants.program_name;
			
			app_years = app_years;
			build_version = NuttyApp.Constants.nutty_version;
			app_icon = NuttyApp.Constants.app_icon;
			main_url = "https://github.com/babluboy/nutty#nutty";
			bug_url = "https://github.com/babluboy/nutty/issues";
			help_url = "https://github.com/babluboy/nutty/wiki";
			translate_url = "https://translations.launchpad.net/nutty";

			about_artists =NuttyApp.Constants.about_artists;
			about_authors = NuttyApp.Constants.about_authors;
			about_comments = NuttyApp.Constants.about_comments;
			about_translators = NuttyApp.Constants.translator_credits;
			about_license_type = Gtk.License.GPL_3_0;

			options = new OptionEntry[5];
			options[0] = { "version", 0, 0, OptionArg.NONE, ref command_line_option_version, _("Display version number"), null };
			options[1] = { "monitor", 0, 0, OptionArg.STRING, ref command_line_option_monitor, _("PATH"), "Path to nutty config (i.e. /home/sid/.config/nutty)" };
			options[2] = { "alert", 0, 0, OptionArg.NONE, ref command_line_option_alert, _("Run Nutty in device alert mode"), null };
			options[3] = { "debug", 0, 0, OptionArg.NONE, ref command_line_option_debug, _("Run Nutty in debug mode"), null };
			options[4] = { "info", 0, 0, OptionArg.NONE, ref command_line_option_info, _("Run Nutty in info mode"), null };
			add_main_option_entries (options);
		}

		public Nutty() {
			Intl.setlocale(LocaleCategory.MESSAGES, "");
			Intl.textdomain(GETTEXT_PACKAGE);
			Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "utf-8");
			debug ("Completed setting Internalization...");
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
				application.nutty_config_path = command_line_option_monitor;
				application.runDeviceScan();
			}else if(command_line_option_alert){
				print("\nRunning Nutty in Device Alert Mode \n");
				application.alertNewDevices();
			}
			return 0;
		}

		public override void activate() {
			Logger.initialize("com.github.babluboy.nutty");
			if(command_line_option_debug){
				Logger.DisplayLevel = LogLevel.DEBUG;
			}
			if(command_line_option_info){
				Logger.DisplayLevel = LogLevel.INFO;
			}
			info("[START] [FUNCTION:activate]");
			window = new Gtk.Window ();
			add_window (window);
			//set window attributes
			window.set_default_size(1000, 600);
			window.set_border_width (Constants.SPACING_WIDGETS);
			window.set_position (Gtk.WindowPosition.CENTER);
			window.window_position = Gtk.WindowPosition.CENTER;
			//load state information from file
			loadNuttyState();
			//add window components
			create_headerbar(window);
			window.add(createNuttyUI());
			window.show_all();
			//load pictures
			try{
				device_available_pix = new Gdk.Pixbuf.from_file (NuttyApp.Constants.DEVICE_AVAILABLE_ICON_IMAGE_LOCATION);
				device_offline_pix = new Gdk.Pixbuf.from_file (NuttyApp.Constants.DEVICE_OFFLINE_ICON_IMAGE_LOCATION);
				default_app_pix = new Gdk.Pixbuf.from_file (NuttyApp.Constants.DEFAULT_APP_ICON_IMAGE_LOCATION);
				icon_theme = Gtk.IconTheme.get_default ();
			}catch(GLib.Error e){
				warning("Failed to load icons/theme: "+e.message);
			}
			//Exit Application Event
			window.destroy.connect (() => {
				// Manage flags to avoid on load process for tabs not visited
				isDevicesViewLoaded = true;
				isBandwidthViewLoaded = true;
				isPortsViewLoaded = true;
				//save state information to file
				saveNuttyState();
			});
			info("[END] [FUNCTION:activate]");
		}

		private void create_headerbar(Gtk.Window window) {
			debug("Starting creation of header bar..");
			Gtk.HeaderBar headerbar = new Gtk.HeaderBar();
			headerbar.set_title(program_name);
			headerbar.subtitle = Constants.TEXT_FOR_SUBTITLE_HEADERBAR;
			headerbar.set_show_close_button(true);
			headerbar.spacing = Constants.SPACING_WIDGETS;
			window.set_titlebar (headerbar);
			//add menu items
			headerbar.pack_end(createNuttyMenu(new Gtk.Menu ()));

			//Add a search entry to the header
			headerSearchBar = new Gtk.SearchEntry();
			headerSearchBar.set_text(Constants.TEXT_FOR_SEARCH_HEADERBAR);
			headerbar.pack_end(headerSearchBar);
			// Set actions for HeaderBar search
			headerSearchBar.search_changed.connect (() => {
				if(Constants.TEXT_FOR_SEARCH_HEADERBAR != headerSearchBar.get_text()){
					if("my-info"==stack.get_visible_child_name()){
						infoTreeModelFilter.refilter();
						infoSearchEntry.erase(0,-1);
						infoSearchEntry.append(headerSearchBar.get_text());
					}else if("ports"==stack.get_visible_child_name()){
						portsTreeModelFilter.refilter();
						portsSearchEntry.erase(0,-1);
						portsSearchEntry.append(headerSearchBar.get_text());
					} else if("route"==stack.get_visible_child_name()){
						routeTreeModelFilter.refilter();
						routeSearchEntry.erase(0,-1);
						routeSearchEntry.append(headerSearchBar.get_text());
					} else if("devices"==stack.get_visible_child_name()){
						devicesTreeModelFilter.refilter();
						devicesSearchEntry.erase(0,-1);
						devicesSearchEntry.append(headerSearchBar.get_text());
					} else if("bandwidth"==stack.get_visible_child_name()){
						bandwidthTreeModelFilter.refilter();
						bandwidthSearchEntry.erase(0,-1);
						bandwidthSearchEntry.append(headerSearchBar.get_text());
					} else{
					}
				}
			});
			debug("Completed loading HeaderBar sucessfully...");
		}

		public AppMenu createNuttyMenu (Gtk.Menu menu) {
			debug("Starting creation of Nutty Menu...");
			Granite.Widgets.AppMenu app_menu;
			//Add sub menu items
			Gtk.MenuItem menuItemPrefferences = new Gtk.MenuItem.with_label(Constants.TEXT_FOR_HEADERBAR_MENU_PREFS);
			menu.add (menuItemPrefferences);
			Gtk.MenuItem menuItemExportToFile = new Gtk.MenuItem.with_label(Constants.TEXT_FOR_HEADERBAR_MENU_EXPORT);
			menu.add (menuItemExportToFile);
			app_menu = new Granite.Widgets.AppMenu.with_app(this, menu);

			//Add actions for menu items
			menuItemPrefferences.activate.connect(() => {
				createPrefsDialog();
			});
			menuItemExportToFile.activate.connect(() => {
				createExportDialog();
			});
			//Add About option to menu
			app_menu.show_about.connect (show_about);
			debug("Completed creation of Nutty Menu sucessfully...");
			return app_menu;
		}

		public void createPrefsDialog() {
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
					DEVICE_SCHEDULE_STATE = DEVICE_SCHEDULE_ENABLED;
					handleDeviceMonitoring(true);
				}else{
					DEVICE_SCHEDULE_STATE = DEVICE_SCHEDULE_DISABLED;
					handleDeviceMonitoring(false);
				}
			});

			min15Option = new Gtk.RadioButton.with_label_from_widget (null, Constants.TEXT_FOR_PREFS_DIALOG_15MIN_OPTION);
			min15Option.set_sensitive (false);
			min15Option.toggled.connect (deviceScheduleSelection);

			min30Option = new Gtk.RadioButton.with_label_from_widget (min15Option, Constants.TEXT_FOR_PREFS_DIALOG_30MIN_OPTION);
			min30Option.set_sensitive (false);
			min30Option.toggled.connect (deviceScheduleSelection);

			hourOption = new Gtk.RadioButton.with_label_from_widget (min15Option, Constants.TEXT_FOR_PREFS_DIALOG_HOUR_OPTION);
			hourOption.set_sensitive (false);
			hourOption.toggled.connect (deviceScheduleSelection);

			dayOption = new Gtk.RadioButton.with_label_from_widget (min15Option, Constants.TEXT_FOR_PREFS_DIALOG_DAY_OPTION);
			dayOption.set_sensitive (false);
			dayOption.toggled.connect (deviceScheduleSelection);

			//set the option for device monitoring - based on saved state
			if(DEVICE_SCHEDULE_STATE == DEVICE_SCHEDULE_ENABLED){
				deviceMonitoringSwitch.set_active(true);
				handleDeviceMonitoring(true);
			}else{
				deviceMonitoringSwitch.set_active(false);
				handleDeviceMonitoring(false);
			}

			//set the active option for device schedule - based on saved state
			if(DEVICE_SCHEDULE_SELECTED == Constants.DEVICE_SCHEDULE_15MINS){
				min15Option.set_active (true);
			}else if(DEVICE_SCHEDULE_SELECTED == Constants.DEVICE_SCHEDULE_30MINS){
				min30Option.set_active (true);
			}else if(DEVICE_SCHEDULE_SELECTED == Constants.DEVICE_SCHEDULE_1HOUR){
				hourOption.set_active (true);
			}else if(DEVICE_SCHEDULE_SELECTED == Constants.DEVICE_SCHEDULE_1DAY){
				dayOption.set_active (true);
			}else{
				hourOption.set_active (true);
			}

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
			debug("Completed setting up Prefference Dialog sucessfully...");
		}

		private void prefsDialogResponseHandler(Gtk.Dialog source, int response_id) {
			switch (response_id) {
				case Gtk.ResponseType.CLOSE:
					setupDeviceMonitoring();
					source.destroy();
					break;
				case Gtk.ResponseType.DELETE_EVENT:
					setupDeviceMonitoring();
					source.destroy();
					break;
			}
			debug ("Prefference dialog handler response handled ["+response_id.to_string()+"]...");
		}

		private void exportDialogResponseHandler(Gtk.Dialog source, int response_id) {
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

		private void deviceScheduleSelection (Gtk.ToggleButton button) {
			if(Constants.TEXT_FOR_PREFS_DIALOG_15MIN_OPTION == button.label)
				DEVICE_SCHEDULE_SELECTED = Constants.DEVICE_SCHEDULE_15MINS;
			if(Constants.TEXT_FOR_PREFS_DIALOG_30MIN_OPTION == button.label)
				DEVICE_SCHEDULE_SELECTED = Constants.DEVICE_SCHEDULE_30MINS;
			if(Constants.TEXT_FOR_PREFS_DIALOG_HOUR_OPTION == button.label)
				DEVICE_SCHEDULE_SELECTED = Constants.DEVICE_SCHEDULE_1HOUR;
			if(Constants.TEXT_FOR_PREFS_DIALOG_DAY_OPTION == button.label)
				DEVICE_SCHEDULE_SELECTED = Constants.DEVICE_SCHEDULE_1DAY;
			debug("Completed noting the selection for device monitoring schedule...");
		}

		private void handleDeviceMonitoring(bool isSwitchSet){
			if (isSwitchSet) {
				min15Option.set_sensitive(true);
				min30Option.set_sensitive(true);
				hourOption.set_sensitive(true);
				dayOption.set_sensitive(true);
			} else {
				min15Option.set_sensitive(false);
				min30Option.set_sensitive(false);
				hourOption.set_sensitive(false);
				dayOption.set_sensitive(false);
			}
			debug("Completed toggling device monitoring UI...");
		}

		public void createExportDialog() {
			debug("Started setting up Export Dialog ...");
			Gtk.FileChooserDialog aFileChooserDialog = Utils.new_file_chooser_dialog (Gtk.FileChooserAction.SAVE, "Export Nutty Data", window, false);
			aFileChooserDialog.show_all ();
			aFileChooserDialog.response.connect(exportDialogResponseHandler);
			debug("Completed setting up Export Dialog sucessfully...");
		}

		public Box createNuttyUI() {
			debug("Starting to create main window components...");
			Gtk.Box main_ui_box = new Gtk.Box (Orientation.VERTICAL, Constants.SPACING_WIDGETS);

			//define the stack for the tabbed view
			stack = new Gtk.Stack();
			stack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
			stack.set_transition_duration(1000);

			//define the switcher for switching between tabs
			StackSwitcher switcher = new StackSwitcher();
			switcher.set_halign(Align.CENTER);
			switcher.set_stack(stack);
			main_ui_box.pack_start(switcher, false, true, 0);
			main_ui_box.pack_start(stack, true, true, 0);

			//Fetch and persist names of connections and interfaces if it dosent exist already
			getConnectionsList();
			debug("Obtained the list of connections...");

			/* Start of tabs UI set up */

			//Show the Disclaimer only if the Disclaimer has not been agreed earlier
			if(!disclaimerSetGet(Constants.HAS_DISCLAIMER_BEEN_AGREED)){
				debug("Starting to Modal Dialog for Nutty Disclaimer...");
				Gtk.MessageDialog disclaimerDialog = new Gtk.MessageDialog(window,
															   Gtk.DialogFlags.MODAL,
															   Gtk.MessageType.WARNING,
															   Gtk.ButtonsType.NONE,
															   ""
															   );
				disclaimerDialog.set("text", PRIMARY_TEXT_FOR_DISCLAIMER);
				disclaimerDialog.set("secondary_text", SECONDARY_TEXT_FOR_DISCLAIMER);
				disclaimerDialog.add_button(Constants.TEXT_FOR_PREFS_DIALOG_CLOSE_BUTTON,Gtk.ResponseType.CLOSE);
				disclaimerDialog.add_button(Constants.TEXT_FOR_DISCLAIMER_AGREE_BUTTON,Gtk.ResponseType.OK);
				disclaimerDialog.set("secondary_use_markup", true);
				disclaimerDialog.response.connect ((response_id) => {
					switch (response_id) {
						case Gtk.ResponseType.OK:
							disclaimerSetGet(Constants.REMEMBER_DISCLAIMER_AGREEMENT);
							break;
						case Gtk.ResponseType.CLOSE:
							window.destroy();
							break;
						case Gtk.ResponseType.DELETE_EVENT:
							window.destroy();
							break;
					}
					debug("Completed handling Modal Dialog for Nutty Disclaimer [Dialog Response Id="+response_id.to_string()+"]");
					disclaimerDialog.destroy();
				});
				disclaimerDialog.show ();
				debug("Completed showing Modal Dialog for Nutty Disclaimer...");
			}
			// Tab 1 : MyInfo Tab: This Tab displays info on the computer and network interface hardware
			Label info_details_combobox_label = new Label (Constants.TEXT_FOR_MYINFO_DETAILS_LABEL);
			ComboBoxText info_combobox = new ComboBoxText();
			Gtk.Switch detailsInfoSwitch = new Gtk.Switch ();
			detailsInfoSwitch.set_sensitive (false);
			infoProcessSpinner = new Spinner();
			//Set connection values into combobox
			info_combobox.insert(0,Constants.TEXT_FOR_INTERFACE_LABEL,Constants.TEXT_FOR_INTERFACE_LABEL);
			int info_combobox_counter = 1;
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
			infoTreeModelFilter = new Gtk.TreeModelFilter (processMyInfo("", false), null);
			setFilterAndSort(info_table_treeview, infoTreeModelFilter, SortType.DESCENDING);
			// Set actions for Interface DropDown change
			info_combobox.changed.connect (() => {
				if(Constants.TEXT_FOR_INTERFACE_LABEL != info_combobox.get_active_id ()){
					//set the detailsInfoSwitch to active status
					detailsInfoSwitch.set_sensitive (true);
					if (detailsInfoSwitch.active) {
						infoProcessSpinner.start();
						infoTreeModelFilter = new Gtk.TreeModelFilter (processMyInfo(info_combobox.get_active_id (), true), null);
						setFilterAndSort(info_table_treeview, infoTreeModelFilter, SortType.DESCENDING);
					} else {
						infoTreeModelFilter = new Gtk.TreeModelFilter (processMyInfo(info_combobox.get_active_id (), false), null);
						setFilterAndSort(info_table_treeview, infoTreeModelFilter, SortType.DESCENDING);
					}
				}else{
					//set the detailsInfoSwitch to in-active status
					detailsInfoSwitch.set_sensitive (false);
					//Fetch and minimal info with no interface selected
					infoTreeModelFilter = new Gtk.TreeModelFilter (processMyInfo("", false), null);
					setFilterAndSort(info_table_treeview, infoTreeModelFilter, SortType.DESCENDING);
				}
			});
			// Set actions for Detailed Network Hardware switch change
			detailsInfoSwitch.notify["active"].connect (() => {
				if (detailsInfoSwitch.active) {
					infoProcessSpinner.start();
					infoTreeModelFilter = new Gtk.TreeModelFilter (processMyInfo(info_combobox.get_active_id (), true), null);
					setFilterAndSort(info_table_treeview, infoTreeModelFilter, SortType.DESCENDING);
				} else {
					infoTreeModelFilter = new Gtk.TreeModelFilter (processMyInfo(info_combobox.get_active_id (), false), null);
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
			Label speed_test_label = new Label (Constants.TEXT_FOR_SPEED_LABEL);
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
				routeTreeModelFilter = new Gtk.TreeModelFilter (processRouteScan(route_entry_text.get_text()), null);
				setFilterAndSort(route_table_treeview, routeTreeModelFilter, SortType.DESCENDING);
			});

			// Set actions for Route Button Clicking
			route_button.clicked.connect (() => {
				traceRouteSpinner.start();
				routeTreeModelFilter = new Gtk.TreeModelFilter (processRouteScan(route_entry_text.get_text()), null);
				setFilterAndSort(route_table_treeview, routeTreeModelFilter, SortType.DESCENDING);
			});
			// Set actions for Speed Test Refresh Button Clicking
			speed_test_refresh_button.clicked.connect (() => {
				speedTestSpinner.start();
				speed_test_refresh_button.set_sensitive(false);
				speedTestTreeModelFilter = new Gtk.TreeModelFilter (processSpeedTest(true), null);
				setFilterAndSort(speedtest_table_treeview, speedTestTreeModelFilter, SortType.DESCENDING);
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

			//Tab 5 : Devices : Show details of Devices on the network
			TreeView device_table_treeview = new TreeView();
			//device_table_treeview.set_fixed_height_mode(true);
			devicesSpinner = new Gtk.Spinner();

			Button devices_refresh_button = new Button.from_icon_name (Constants.REFRESH_ICON, IconSize.SMALL_TOOLBAR);
			devices_refresh_button.set_relief (ReliefStyle.NONE);
			devices_refresh_button.set_tooltip_markup (Constants.TEXT_FOR_DEVICES_TOOLTIP);
			//set the devices refresh button to in-active status
			devices_refresh_button.set_sensitive (false);

			CellRendererText device_cell_txt = new CellRendererText ();
			CellRendererPixbuf device_cell_pix = new CellRendererPixbuf ();
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_1, device_cell_pix, "pixbuf", 0);
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_2, device_cell_txt, "text", 1);
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_3, device_cell_txt, "text", 2);
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_4, device_cell_txt, "text", 3);
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_5, device_cell_txt, "text", 4);
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_6, device_cell_txt, "text", 5);

			ScrolledWindow devices_scroll = new ScrolledWindow (null, null);
			devices_scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			devices_scroll.add (device_table_treeview);

			devices_results_label = new Label (" ");
			Label devices_details_label = new Label (Constants.TEXT_FOR_LABEL_RESULT);
			ComboBoxText devices_combobox = new ComboBoxText();
			//Set connection values into combobox
			devices_combobox.insert(0,Constants.TEXT_FOR_INTERFACE_LABEL,Constants.TEXT_FOR_INTERFACE_LABEL);
			int devices_combobox_counter = 1;
			foreach (var entry in interfaceConnectionMap.entries) {
				devices_combobox.insert(info_combobox_counter, entry.key, entry.value);
				devices_combobox_counter++;
			}
			devices_combobox.active = 0;

			Box devices_results_box = new Box (Orientation.HORIZONTAL, Constants.SPACING_WIDGETS);
			devices_results_box.pack_start (devices_combobox, false, true, 0);
			devices_results_box.pack_start (devices_details_label, false, true, 0);
			devices_results_box.pack_start (devices_results_label, false, true, 0);
			devices_results_box.pack_end (devices_refresh_button, false, true, 0);
			devices_results_box.pack_end (devicesSpinner, false, true, 0);

			Box devices_layout_box = new Box (Orientation.VERTICAL, Constants.SPACING_WIDGETS);
			devices_layout_box.set_homogeneous (false);
			devices_layout_box.pack_start (devices_results_box, false, true, 0);
			devices_layout_box.pack_start (devices_scroll, true, true, 0);
			debug("Devices tab set up completed...");
			// Set actions for Interface DropDown change
			devices_combobox.changed.connect (() => {
				if(devices_combobox.get_active_id () != Constants.TEXT_FOR_INTERFACE_LABEL){//valid interface connection is set
					//set the devices refresh button to active status
					devices_refresh_button.set_sensitive (true);
					//process device scan for selected interface
					devicesSpinner.start();
					devicesTreeModelFilter = new Gtk.TreeModelFilter (processDevicesScan(devices_combobox.get_active_id ()), null);
					setFilterAndSort(device_table_treeview, devicesTreeModelFilter, SortType.DESCENDING);
					isDevicesViewLoaded = true;
				}else{// no interface connection is set
					//set the devices refresh button to in-active status
					devices_refresh_button.set_sensitive (false);
					//populate device data recorded earlier
					devicesTreeModelFilter = new Gtk.TreeModelFilter (fetchRecordedDevices(), null);
					setFilterAndSort(device_table_treeview, devicesTreeModelFilter, SortType.DESCENDING);
					isDevicesViewLoaded = true;
				}
			});

			// Set actions for Device Refresh Button Clicking
			devices_refresh_button.clicked.connect (() => {
				devicesSpinner.start();
				devicesTreeModelFilter = new Gtk.TreeModelFilter (processDevicesScan(devices_combobox.get_active_id ()), null);
				setFilterAndSort(device_table_treeview, devicesTreeModelFilter, SortType.DESCENDING);
				isDevicesViewLoaded = true;
			});
			//Add devices-box to stack
			stack.add_titled(devices_layout_box, "devices", Constants.TEXT_FOR_DEVICES_TAB);
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
					devicesTreeModelFilter = new Gtk.TreeModelFilter (fetchRecordedDevices(), null);
					setFilterAndSort(device_table_treeview, devicesTreeModelFilter, SortType.DESCENDING);
					isDevicesViewLoaded = true;
				}
			});
			debug("Completed creation of main windows components...");
			return main_ui_box;
		}

		public void saveNuttyState(){
			debug("Starting to save Nutty state...");
			StringBuilder stateInfo = new StringBuilder("");
			//collect all current details of state
			stateInfo.append(Constants.IDENTIFIER_FOR_PROPERTY_START).append(Constants.TEXT_FOR_STATE_DEVICE_MONITORING_STATE).append(Constants.IDENTIFIER_FOR_PROPERTY_VALUE).append(DEVICE_SCHEDULE_STATE.to_string()).append(Constants.IDENTIFIER_FOR_PROPERTY_END);
			stateInfo.append(Constants.IDENTIFIER_FOR_PROPERTY_START).append(Constants.TEXT_FOR_STATE_DEVICE_MONITORING_SCHEDULE).append(Constants.IDENTIFIER_FOR_PROPERTY_VALUE).append(DEVICE_SCHEDULE_SELECTED.to_string()).append(Constants.IDENTIFIER_FOR_PROPERTY_END);

			stateInfo.append(Constants.IDENTIFIER_FOR_PROPERTY_START).append(Constants.TEXT_FOR_STATE_SPEEDTEST_DATE).append(Constants.IDENTIFIER_FOR_PROPERTY_VALUE).append(SPEEDTESTDATE).append(Constants.IDENTIFIER_FOR_PROPERTY_END);
			stateInfo.append(Constants.IDENTIFIER_FOR_PROPERTY_START).append(Constants.TEXT_FOR_STATE_SPEEDTEST_UPLOADSPEED).append(Constants.IDENTIFIER_FOR_PROPERTY_VALUE).append(UPLOADSPEED).append(Constants.IDENTIFIER_FOR_PROPERTY_END);
			stateInfo.append(Constants.IDENTIFIER_FOR_PROPERTY_START).append(Constants.TEXT_FOR_STATE_SPEEDTEST_DOWNLOADSPEED).append(Constants.IDENTIFIER_FOR_PROPERTY_VALUE).append(DOWNLOADSPEED).append(Constants.IDENTIFIER_FOR_PROPERTY_END);
			//overwrite (or write if not exists) the current state info
			string saveNuttyStateResult = fileOperations("WRITE",nutty_config_path, Constants.nutty_state_file_name, stateInfo.str);
			if("true" == saveNuttyStateResult){
				debug("Completed saving Nutty state [ "+stateInfo.str+" ] in file:"+nutty_config_path+"/"+Constants.nutty_state_file_name);
			}else{
				warning("Failure in saving nutty state: "+saveNuttyStateResult);
			}
		}

		public void loadNuttyState(){
			debug("Started loading Nutty state...");
			if("true" == fileOperations("EXISTS",nutty_config_path, Constants.nutty_state_file_name, "")){
				DEVICE_SCHEDULE_STATE = int.parse(fileOperations("READ_PROPS",nutty_config_path, Constants.nutty_state_file_name, Constants.TEXT_FOR_STATE_DEVICE_MONITORING_STATE));
				DEVICE_SCHEDULE_SELECTED = int.parse(fileOperations("READ_PROPS",nutty_config_path, Constants.nutty_state_file_name, Constants.TEXT_FOR_STATE_DEVICE_MONITORING_SCHEDULE));

				SPEEDTESTDATE = fileOperations("READ_PROPS",nutty_config_path, Constants.nutty_state_file_name, Constants.TEXT_FOR_STATE_SPEEDTEST_DATE);
				if(SPEEDTESTDATE == "false") SPEEDTESTDATE = Constants.TEXT_FOR_SPEEDTEST_NOTFOUND;
				UPLOADSPEED = fileOperations("READ_PROPS",nutty_config_path, Constants.nutty_state_file_name, Constants.TEXT_FOR_STATE_SPEEDTEST_UPLOADSPEED);
				if(UPLOADSPEED == "false") UPLOADSPEED = "";
				DOWNLOADSPEED = fileOperations("READ_PROPS",nutty_config_path, Constants.nutty_state_file_name, Constants.TEXT_FOR_STATE_SPEEDTEST_DOWNLOADSPEED);
				if(DOWNLOADSPEED == "false") DOWNLOADSPEED = "";

				debug(new StringBuilder().append("Completed loading Nutty state [")
					.append(" DEVICE_SCHEDULE_STATE="+DEVICE_SCHEDULE_STATE.to_string())
					.append(" DEVICE_SCHEDULE_SELECTED="+DEVICE_SCHEDULE_SELECTED.to_string())
					.append(" SPEEDTESTDATE="+SPEEDTESTDATE)
					.append(" UPLOADSPEED="+UPLOADSPEED)
					.append(" DOWNLOADSPEED="+DOWNLOADSPEED)
					.append("] from file:"+nutty_config_path+"/"+Constants.nutty_state_file_name).str);
			}else{
				debug("Could not load Nutty state, Nutty State file does not exist at path :"+nutty_config_path +"/"+ Constants.nutty_state_file_name);
			}
		}

		public void saveNuttyInfoToFile (string path, string filename) {
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

		public bool disclaimerSetGet(int operation) {
			bool result = false;
			if(operation == Constants.HAS_DISCLAIMER_BEEN_AGREED){
				if("true" == fileOperations("EXISTS",nutty_config_path, Constants.nutty_agreement_file_name, ""))
					result=true; //Disclaimer has been agreed before
			}
			if(operation == Constants.REMEMBER_DISCLAIMER_AGREEMENT){
				fileOperations("WRITE",nutty_config_path, Constants.nutty_agreement_file_name, "Nutty disclaimer agreed by user["+GLib.Environment.get_user_name()+"] on machine["+GLib.Environment.get_host_name()+"]");
				result=true; //Disclaimer agreement file is created
			}
			debug("Nuty Disclaimer operation completed...");
			return result;
		}

		public string fileOperations (string operation, string path, string filename, string contents) {
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

		public bool process_line (IOChannel channel, IOCondition condition, string stream_name) {
			if (condition == IOCondition.HUP) {
				return false;
			}
			try {
				string line;
				channel.read_line (out line, null, null);
				spawn_async_with_pipes_output.append(line);
			} catch (IOChannelError e) {
				spawn_async_with_pipes_output.append(e.message);
				return false;
			} catch (ConvertError e) {
				spawn_async_with_pipes_output.append(e.message);
				warning("Failure in reading command output:"+e.message);
				return false;
			}
			return true;
		}

		public int execute_sync_multiarg_command_pipes(string[] spawn_args) {
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
				warning("Failure in executing async command ["+string.joinv(" ", spawn_args)+"] : "+e.message);
				spawn_async_with_pipes_output.append(e.message);
			}
			debug("Completed executing async command["+string.joinv(" ", spawn_args)+"]...");
			return 0;
		}

		public string execute_sync_command (string cmd){
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

		public Gee.ArrayList<string> getInterfaceList() throws Error{
			debug("Starting to get Interface list...");
			Gee.ArrayList <string> interfaceList =  new Gee.ArrayList<string>();
			string commandOutput = execute_sync_command(Constants.COMMAND_FOR_INTERFACE_NAMES); //get command output for interface details
			string[] linesArray = commandOutput.strip().split ("\n",-1); //split the indivudual lines in the output
			//In each line split the strings and record the first string only
			foreach(string dataElement in linesArray){
				string[] dataArray = dataElement.split (" ",-1);
				interfaceList.add ((string)dataArray[0].strip());
			}
			interfaceList.remove_at (0); //throw away the first string as that is a header name
			debug("Completed getting Interface list...");
			return interfaceList;
		}

		public void getConnectionsList() {
			debug("Starting to get connection details...");
			try{
				if(interfaceConnectionMap != null) {
					//do nothing as the connections map is already populated
				}else{
					Gee.ArrayList<string> interfaceList = getInterfaceList();
					interfaceConnectionMap = new HashMap <string,string>();
					interfaceIPMap = new HashMap <string,string>();
					interfaceMACMap = new HashMap <string,string>();
					StringBuilder commandOutput = new StringBuilder();
					StringBuilder IPAddress = new StringBuilder();
					StringBuilder MACAddress = new StringBuilder();
					//Get interface names to populate the dropdown list and find corresponding IP addresses
					foreach(string data in interfaceList){
						//create a connection name for each interface name and hold in a HashMap
						if(data.down().get_char(0) == 'e'){
							interfaceConnectionMap.set(data, TEXT_FOR_WIRED_CONNECTION +" (" +data+ ")");
						}else if(data.down().get_char(0) == 'w'){
							interfaceConnectionMap.set(data, TEXT_FOR_WIRELESS_CONNECTION +" (" +data+ ")");
						}else{
							interfaceConnectionMap.set(data, TEXT_FOR_OTHER_CONNECTION +" (" +data+ ")");
						}
						//execute command for IP and MAC
						commandOutput.assign(execute_sync_command(Constants.COMMAND_FOR_INTERFACE_DETAILS+data));
						//find an IP address for each interface name and hold in a HashMap
						IPAddress.assign(Utils.extractBetweenTwoStrings(commandOutput.str,Constants.IDENTIFIER_FOR_IPADDRESS_IN_COMMAND_OUTPUT," "));
						interfaceIPMap.set(data,IPAddress.str);
						//find an MAC Address for each interface name and hold in a HashMap
						MACAddress.assign(Utils.extractBetweenTwoStrings(commandOutput.str,Constants.IDENTIFIER_FOR_MACADDRESS_IN_COMMAND_OUTPUT," ").up(-1));
						interfaceMACMap.set(data,MACAddress.str);
						//Record Host Name
						HostName = execute_sync_command(Constants.COMMAND_FOR_HOST_NAMES).strip();
					}
				}
			}catch(Error e){
				warning("Failure in getting connection list:"+e.message);
			}
			debug("Completed getting connection details...");
		}

		private bool filterTree(TreeModel model, TreeIter iter){
			bool isFilterCriteriaMatch = true;
			string modelValueString = "";
			//If there is nothing to filter or the default help text then make the data visible
			if ((headerSearchBar.get_text() == "") || (Constants.TEXT_FOR_SEARCH_HEADERBAR == headerSearchBar.get_text())){
					isFilterCriteriaMatch = true;
			//extract data from the tree model and match againt the filter input
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

		public void setFilterAndSort(TreeView aTreeView, Gtk.TreeModelFilter aTreeModelFilter, SortType aSortType){
			aTreeModelFilter.set_visible_func(filterTree);
			Gtk.TreeModelSort aTreeModelSort = new TreeModelSort.with_model (aTreeModelFilter);
			aTreeView.set_model(aTreeModelSort);
			int noOfColumns = aTreeView.get_model().get_n_columns();
			for(int count=0; count<noOfColumns; count++){
				aTreeView.get_column(count).set_sort_column_id(count);
				aTreeView.get_column(count).set_sort_order(aSortType);
			}
		}

		public Gtk.TreeStore processMyInfo(string interfaceName, bool isDetailsRequired){
			debug("Starting to process MyInfo[interfaceName="+interfaceName+",isDetailsRequired="+isDetailsRequired.to_string()+"]...");
			info_list_store.clear();
			try{
				TreeIter iter;
				TreeIter iterSecondLevel;

				//Get info which does not require an Interface Name
				info_list_store.append (out iter, null);
				info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_HOSTNAME, 1, HostName);
				string[] interfaceDetails = Utils.multiExtractBetweenTwoStrings(execute_sync_command(Constants.COMMAND_FOR_INTERFACE_HARDWARE).strip(), "Ethernet controller:", "\n");
				int interfaceDetailsCounter = 0;
				foreach(string data in interfaceDetails){
					info_list_store.append (out iter, null);
					if(interfaceDetailsCounter ==0){
						info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_INTERFACE_HARDWARE, 1, data);
					} else {
						info_list_store.set (iter, 0, "", 1, data);
					}
					interfaceDetailsCounter++;
				}
				//Get simple info which requires an interface name
				if(interfaceName != null && interfaceName != "" && interfaceName.length > 0){
					info_list_store.append (out iter, null);
					info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_MAC_ADDRESS, 1, interfaceMACMap.get(interfaceName.strip()));

					info_list_store.append (out iter, null);
					info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_IP_ADDRESS, 1, interfaceIPMap.get(interfaceName.strip()));

					//run minimal interface command if the same has not been executed
					interfaceCommandOutputMinimal.assign(execute_sync_command(Constants.COMMAND_FOR_INTERFACE_DETAILS+interfaceName));

					if(interfaceCommandOutputMinimal.str.contains("RUNNING")){
						info_list_store.append (out iter, null);
						info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_INTERFACE_STATE, 1, Constants.TEXT_FOR_MYINFO_INTERFACE_ACTIVE);
					}else{
						info_list_store.append (out iter, null);
						info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_INTERFACE_STATE, 1, Constants.TEXT_FOR_MYINFO_INTERFACE_INACTIVE);
					}
				}
				//Get simple wireless info which requires an interface name
				if(interfaceName != null && interfaceName != "" && interfaceName.length > 0 && interfaceName.get_char(0) == 'w'){
					string iwconfigOutput = execute_sync_command(Constants.COMMAND_FOR_WIRELESS_CARD_DETAILS + interfaceName);
					string frequencyAndChannel = execute_sync_command(Constants.COMMAND_FOR_WIRELESS_CARD_CHANNEL_DETAILS+interfaceName+" channel");

					info_list_store.append (out iter, null);
					info_list_store.set (iter, 0, _("Network Card"), 1, Utils.extractBetweenTwoStrings(iwconfigOutput,interfaceName, "ESSID:").strip() + _(" Standards with Transmit Power of ") + Utils.extractBetweenTwoStrings(iwconfigOutput,"Tx-Power=", "Retry short limit:").strip() + _(" [Power Management: ") +Utils.extractBetweenTwoStrings(iwconfigOutput,"Power Management:", "Link Quality=").strip()+"]");

					info_list_store.append (out iter, null);
					info_list_store.set (iter, 0, _("Connected to"), 1, Utils.extractBetweenTwoStrings(iwconfigOutput,"ESSID:", "Mode:").replace("\"","").strip() + _(" Network at Access Point ") + Utils.extractBetweenTwoStrings(iwconfigOutput,"Access Point:", "Bit Rate=").strip() + "(MAC) in "+Utils.extractBetweenTwoStrings(iwconfigOutput,"Mode:", "Frequency:").strip()+_(" Mode"));

					info_list_store.append (out iter, null);
					info_list_store.set (iter, 0, _("Connected with"), 1, _("Frequency of ")+Utils.extractBetweenTwoStrings(frequencyAndChannel,"Current Frequency:", "\n").strip() + _(" and Bit Rate of ") + Utils.extractBetweenTwoStrings(iwconfigOutput,"Bit Rate=", "Tx-Power=").strip());

					info_list_store.append (out iter, null);
					info_list_store.set (iter, 0, _("Connection strength"), 1, _("Link Quality of ") + Utils.extractBetweenTwoStrings(iwconfigOutput,"Link Quality=", "Signal level=").strip() + _(" and Signal Level of ") + Utils.extractBetweenTwoStrings(iwconfigOutput,"Signal level=", "Rx invalid nwid:").strip());
				}

				//Get detailed info which requires an interface name
				if(interfaceName != null && interfaceName != "" && interfaceName.length > 0 && isDetailsRequired){
					//run detailed interface command if the same has not been executed
					if("" == interfaceCommandOutputDetailed.str){
						execute_sync_multiarg_command_pipes(COMMAND_FOR_INTERFACE_HARDWARE_DETAILED);
						interfaceCommandOutputDetailed.assign(spawn_async_with_pipes_output.str);
					}
					bool isNodeLeftToScan = true;
					int startPos = 0;
					int endPos = 0;
					StringBuilder interfaceNodeXML = new StringBuilder("");
					while (isNodeLeftToScan){
						startPos = interfaceCommandOutputDetailed.str.index_of("<node id=\"network\"",startPos+1);
						endPos = interfaceCommandOutputDetailed.str.index_of("</node>",startPos);
						if(startPos != -1 && endPos != -1 && endPos>startPos){ //xml Nodes found to process
							interfaceNodeXML.assign(interfaceCommandOutputDetailed.str.slice(startPos,endPos));
							if(interfaceName == Utils.extractXMLTag(interfaceNodeXML.str,"<logicalname>", "</logicalname>").strip()){
								//do nothing the extracted node is for the selected interface
								break;
							}else{
								//empty the node as it is not for the selected interface
								interfaceNodeXML.assign("");
							}
							startPos = endPos;
						}else{
							if(startPos != -1 && endPos != -1 && endPos>startPos){ //process last xml Nodes{
								interfaceNodeXML.assign(interfaceCommandOutputDetailed.str.slice(startPos,endPos));
								if(interfaceName == Utils.extractXMLTag(interfaceNodeXML.str,"<logicalname>", "</logicalname>").strip()){
									//do nothing the extracted node is for the selected interface
									break;
								}else{
									//empty the node as it is not for the selected interface
									interfaceNodeXML.assign("");
								}
							}
							isNodeLeftToScan = false; //No more xml Nodes left to scan
						}
					}
					//extract data from node and add to ListStore
					if(interfaceNodeXML.str != ""){
						info_list_store.append (out iter, null);
						info_list_store.set (iter, 0, "NIC Info", -1);
						info_list_store.append (out iterSecondLevel, iter);
						info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_PRODUCT, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<product>", "</product>"));
						info_list_store.append (out iterSecondLevel, iter);
						info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_VENDOR, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<vendor>", "</vendor>"));
						info_list_store.append (out iterSecondLevel, iter);
						info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_PHYSICALID, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<physid>", "</physid>"));
						info_list_store.append (out iterSecondLevel, iter);
						info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_BUSINFO, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<businfo>", "</businfo>"));
						info_list_store.append (out iterSecondLevel, iter);
						info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_VERSION, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<version>", "</version>"));
						info_list_store.append (out iterSecondLevel, iter);
						info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_CAPACITY, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<capacity>", "</capacity>"));
						info_list_store.append (out iterSecondLevel, iter);
						info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_BUSWIDTH, 1, Utils.extractXMLAttribute(interfaceNodeXML.str,"width", "units", "bits")+ " bits");
						info_list_store.append (out iterSecondLevel, iter);
						info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_CLOCKSPEED, 1, (int.parse(Utils.extractXMLAttribute(interfaceNodeXML.str,"clock", "units", "Hz"))/1000000).to_string()+ " MHz");

						Gee.HashMap<string,string> configurationDetails = Utils.extractTagAttributes(Utils.extractXMLTag(interfaceNodeXML.str,"<configuration>", "</configuration>"), "setting", "id", true);
						MapIterator<string,string> configurationIterator = configurationDetails.map_iterator ();
						info_list_store.append (out iter, null);
						info_list_store.set (iter, 0, "Configuration", -1);
						while(configurationIterator.has_next()) {
							configurationIterator.next();
							info_list_store.append (out iterSecondLevel, iter);
							info_list_store.set (iterSecondLevel, 0, configurationIterator.get_key(), 1, configurationIterator.get_value(),-1);
						}

						Gee.HashMap<string,string> capabilityDetails = Utils.extractTagAttributes(Utils.extractXMLTag(interfaceNodeXML.str,"<capabilities>", "</capabilities>"), "capability", "id", false);
						MapIterator<string,string> capabilityIterator = capabilityDetails.map_iterator ();
						info_list_store.append (out iter, null);
						info_list_store.set (iter, 0, "Capability", -1);
						while(capabilityIterator.has_next()) {
							capabilityIterator.next();
							info_list_store.append (out iterSecondLevel, iter);
							info_list_store.set (iterSecondLevel, 0, capabilityIterator.get_key(), 1, capabilityIterator.get_value(),-1);
						}

						Gee.HashMap<string,string> resourceDetails = Utils.extractTagAttributes(Utils.extractXMLTag(interfaceNodeXML.str,"<resources>", "</resources>"), "resource", "type", true);
						MapIterator<string,string> resourceIterator = resourceDetails.map_iterator ();
						info_list_store.append (out iter, null);
						info_list_store.set (iter, 0, "Resources", -1);
						while(resourceIterator.has_next()) {
							resourceIterator.next();
							info_list_store.append (out iterSecondLevel, iter);
							info_list_store.set (iterSecondLevel, 0, resourceIterator.get_key(), 1, resourceIterator.get_value(),-1);
						}
					}
					infoProcessSpinner.stop();
				}
			}catch(Error e){
				warning("Failure to process MyInfo:"+e.message);
			}
			debug("Completed processing MyInfo[interfaceName="+interfaceName+",isDetailsRequired="+isDetailsRequired.to_string()+"]...");
			return info_list_store;
		}

		public Gtk.ListStore processRouteScan(string tracerouteCommand){
			debug("Starting to process RouteScan["+tracerouteCommand+"]...");
			route_list_store.clear();
			try{
				TreeIter iter;
				string serverName = "";
				string serverIP = "";
				string[] firstPacket = {" "};
				string[] secondPacket = {" "};
				string[] thirdPacket = {" "};

				execute_sync_multiarg_command_pipes({"traceroute", tracerouteCommand});
				Gee.ArrayList<Gee.ArrayList<string>> tableData =  Utils.convertMultiLinesToTableArray(spawn_async_with_pipes_output.str, 6, "  ");
				if(exitCodeForCommand != 0){//handle unsucessfull command execution
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
									route_list_store.set (iter, 0, int.parse(rowData.get(0)), 1, serverIP, 2, serverName, 3, double.parse(firstPacket[0]), 4, double.parse(secondPacket[0]), 5, double.parse(thirdPacket[0]));
								}
							}
							countHops++;
						}
					}
				}
				traceRouteSpinner.stop();
			}catch(Error e){
				warning("Failure in processing RouteScan:"+e.message);
			}
			debug("Completed processing RouteScan["+tracerouteCommand+"]...");
			return route_list_store;
		}

		public Gtk.ListStore processPortsScan(string[] commandArgs){
			debug("Starting to process PortsScan["+string.joinv(" ", commandArgs)+"]...");
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

				execute_sync_multiarg_command_pipes (commandArgs);
				Gee.ArrayList<Gee.ArrayList<string>> tableData =  Utils.convertMultiLinesToTableArray(spawn_async_with_pipes_output.str, 100, "  ");

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
			debug("Completed processing PortsScan["+string.joinv(" ", commandArgs)+"]...");
			return ports_tcp_list_store;
		}

		public Gee.ArrayList<Gee.ArrayList<string>> manageDeviceScanResults (string mode, string nmapOutput, string interfaceName){
			debug("Starting to manage DeviceScan Results [mode="+mode+",interfaceName="+interfaceName+"]...");
			Gee.ArrayList<ArrayList<string>> deviceDataArrayList =  new Gee.ArrayList<Gee.ArrayList<string>>();
			try{
				string devicePropsData = "";
				int deviceAttributeCounter = 0;

				/* Read Device Props and create a device data object */
				devicePropsData = fileOperations("READ", nutty_config_path, Constants.nutty_devices_property_file_name, "");
				//Add the data from the Device Props to the Device Array Object
				if("false" != devicePropsData && devicePropsData.length>10){
					//fetch the individual device details
					string[] recordedDeviceList = Utils.multiExtractBetweenTwoStrings(devicePropsData, Constants.IDENTIFIER_FOR_PROPERTY_START, Constants.IDENTIFIER_FOR_PROPERTY_END);
					foreach(string aDeviceDetails in recordedDeviceList){
						//fetch the attributes of each device
						string[] recordedDeviceAttributes = aDeviceDetails.split("==");
						//Add the device into the Device Object only if the number of device attributes is 7
						if(recordedDeviceAttributes.length ==7){
							//create a single device object
							Gee.ArrayList<string> recordedDeviceAttributesArrayList = new Gee.ArrayList<string>();
							//set the device attributes into the single device object
							foreach(string aRecordedDeviceAttribute in recordedDeviceAttributes){
								recordedDeviceAttributesArrayList.insert(deviceAttributeCounter,aRecordedDeviceAttribute);
								deviceAttributeCounter++;
							}
							//set the device status as not active initially
							recordedDeviceAttributesArrayList.set(6,Constants.TEXT_FOR_DEVICES_NONACTIVE_NOW);
							//add the single device object into the device list object
							deviceDataArrayList.add(recordedDeviceAttributesArrayList);
							//reset the device attribute counter
							deviceAttributeCounter = 0;
						}
					}
				}else{
					//This will be the scenario for the first time use of the Devices tab on Nutty
					//Do Nothing
				}

				/* Mode: DEVICE_DATA - Return the data from the device props file */
				if(mode == "DEVICE_DATA"){
					foreach(ArrayList<string> deviceAttributeArrayList in deviceDataArrayList){
						//set the device status as recorded earlier
						deviceAttributeArrayList.set(6,Constants.TEXT_FOR_DEVICES_RECORDED);
					}
					return deviceDataArrayList;
				}

				/* Mode: DEVICE ALERT - Check and update device props for alerting new devices */
				if(mode == "DEVICE_ALERT"){
					foreach(ArrayList<string> deviceAttributeArrayList in deviceDataArrayList){
						//check if the alert is pending for the device and process alert
						if(deviceAttributeArrayList.contains(Constants.DEVICE_ALERT_PENDING)){
							//alert discovery of new device
							execute_sync_command(Constants.COMMAND_FOR_DEVICES_ALERT + " '" + TEXT_FOR_DEVICE_FOUND_NOTIFICATION + deviceAttributeArrayList.get(3) + "(" + deviceAttributeArrayList.get(0) + ")'");
							//set the device alert status to completed
							deviceAttributeArrayList.set(5,Constants.DEVICE_ALERT_COMPLETED);
						}
					}
				}

				/* Mode: DEVICE_SCAN - Use NMap Output to update device props and get combined output */
				if(mode == "DEVICE_SCAN_UI" || mode == "DEVICE_SCAN_SCHEDULED"){
					StringBuilder hostDetails = new StringBuilder("");
					StringBuilder deviceIPAddress = new StringBuilder("");
					StringBuilder deviceMACAddress = new StringBuilder("");
					StringBuilder deviceVendorName = new StringBuilder("");
					StringBuilder deviceHostName = new StringBuilder("");
					int startOfBlock = 0;
					int endOfBlock = 0;
					bool isNewDevice = true;

					//parse NMap XML output for fetching device details and update device list object appropriately
					while(startOfBlock != -1){
						startOfBlock = nmapOutput.index_of(Constants.IDENTIFIER_FOR_START_OF_HOST_IN_NMAP_OUTPUT,startOfBlock);
						endOfBlock = nmapOutput.index_of(Constants.IDENTIFIER_FOR_END_OF_HOST_IN_NMAP_OUTPUT,startOfBlock);
						//get the xml content for a single device
						hostDetails.assign(nmapOutput.substring(startOfBlock, (endOfBlock-startOfBlock)));
						startOfBlock = endOfBlock;
						if(hostDetails.str.strip().length > 10){
							int extractionStartPos = 0;
							int extractionEndPos = 0;
							//check for local device or remote device
							if(hostDetails.str.contains("localhost-response")){ //localhost device: details adjustments
								//get IP Address of Device
								extractionStartPos = hostDetails.str.index_of("\"",hostDetails.str.index_of("<address addr=",extractionStartPos))+1;
								extractionEndPos = hostDetails.str.index_of("\"",extractionStartPos+1);
								if(extractionStartPos != -1 && extractionEndPos != -1 && extractionStartPos != 0){
									deviceIPAddress.assign(hostDetails.str.substring(extractionStartPos, extractionEndPos-extractionStartPos));
								}else{
									//Assign no data available for IP Address
									deviceIPAddress.assign(Constants.TEXT_FOR_NOT_AVAILABLE);
								}
								//get MAC Address of Device
								string MACCommandOutput = execute_sync_command(Constants.COMMAND_FOR_INTERFACE_DETAILS+interfaceName);
								deviceMACAddress.assign(Utils.extractBetweenTwoStrings(MACCommandOutput,Constants.IDENTIFIER_FOR_MACADDRESS_IN_COMMAND_OUTPUT," ").up(-1));
								if(deviceMACAddress.str.length < 5){
									//Assign no data available for MAC Address
									deviceMACAddress.assign(Constants.TEXT_FOR_NOT_AVAILABLE).append(deviceIPAddress.str);
								}
								//get vendor name of Device
								extractionStartPos = hostDetails.str.index_of("\"",hostDetails.str.index_of("vendor=",extractionStartPos))+1;
								extractionEndPos = hostDetails.str.index_of("\"",extractionStartPos+1);
								if(extractionStartPos != -1 && extractionEndPos != -1 && extractionStartPos != 0){
									deviceVendorName.assign(hostDetails.str.substring(extractionStartPos, extractionEndPos-extractionStartPos));
								}else{
									//Attempt an online search for vendor name for scheduled process only
									if(mode == "DEVICE_SCAN_SCHEDULED"){
										deviceVendorName.assign(getHostManufacturerOnline(deviceMACAddress.str));
									}
									if(deviceVendorName.str.length < 1){
										//Assign no data available for vendor name
										deviceVendorName.assign(Constants.TEXT_FOR_NOT_AVAILABLE);
									}
								}
								//get host name of Device
								extractionStartPos = hostDetails.str.index_of("\"",hostDetails.str.index_of("name=",extractionStartPos))+1;
								extractionEndPos = hostDetails.str.index_of("\"",extractionStartPos+1);
								if(extractionStartPos != -1 && extractionEndPos != -1 && extractionStartPos != 0){
									deviceHostName.assign(hostDetails.str.substring(extractionStartPos, extractionEndPos-extractionStartPos));
								}else{
									//Assign no data available for host name
									deviceHostName.assign(Constants.TEXT_FOR_NOT_AVAILABLE);
								}
							}else{ //remote device: parse device details from nmap output
								//get IP Address of Device
								extractionStartPos = hostDetails.str.index_of("\"",hostDetails.str.index_of("<address addr=",extractionStartPos))+1;
								extractionEndPos = hostDetails.str.index_of("\"",extractionStartPos+1);
								if(extractionStartPos != -1 && extractionEndPos != -1 && extractionStartPos != 0){
									deviceIPAddress.assign(hostDetails.str.substring(extractionStartPos, extractionEndPos-extractionStartPos));
								}else{
									//Assign no data available for IP Address
									deviceIPAddress.assign(Constants.TEXT_FOR_NOT_AVAILABLE);
								}
								//get MAC Address of Device
								extractionStartPos = hostDetails.str.index_of("\"",hostDetails.str.index_of("<address addr=",extractionStartPos))+1;
								extractionEndPos = hostDetails.str.index_of("\"",extractionStartPos+1);
								if(extractionStartPos != -1 && extractionEndPos != -1 && extractionStartPos != 0){
									deviceMACAddress.assign(hostDetails.str.substring(extractionStartPos, extractionEndPos-extractionStartPos));
								}else{
									//Assign no data available for IP Address
									deviceMACAddress.assign(Constants.TEXT_FOR_NOT_AVAILABLE).append(deviceIPAddress.str);
								}
								//get vendor name of Device
								extractionStartPos = hostDetails.str.index_of("\"",hostDetails.str.index_of("vendor=",extractionStartPos))+1;
								extractionEndPos = hostDetails.str.index_of("\"",extractionStartPos+1);
								if(extractionStartPos != -1 && extractionEndPos != -1 && extractionStartPos != 0){
									deviceVendorName.assign(hostDetails.str.substring(extractionStartPos, extractionEndPos-extractionStartPos));
								}else{
									//Attempt an online search for vendor name
									if(mode == "DEVICE_SCAN_SCHEDULED"){
										deviceVendorName.assign(getHostManufacturerOnline(deviceMACAddress.str));
									}
									if(deviceVendorName.str.length < 1){
										//Assign no data available for vendor name
										deviceVendorName.assign(Constants.TEXT_FOR_NOT_AVAILABLE);
									}
								}
								//get host name of Device
								extractionStartPos = hostDetails.str.index_of("\"",hostDetails.str.index_of("name=",extractionStartPos))+1;
								extractionEndPos = hostDetails.str.index_of("\"",extractionStartPos+1);
								if(extractionStartPos != -1 && extractionEndPos != -1 && extractionStartPos != 0){
									deviceHostName.assign(hostDetails.str.substring(extractionStartPos, extractionEndPos-extractionStartPos));
								}else{
									//Assign no data available for IP Address
									deviceHostName.assign(Constants.TEXT_FOR_NOT_AVAILABLE);
								}
							}

							//check if the device list object has any data after reading the device props
							if(deviceDataArrayList.size == 0){
								//No devices found in the device props - do nothing
							}else{
								//check if the MAC address of the device is present in device list object
								foreach(Gee.ArrayList<string> deviceAttributeArrayList in deviceDataArrayList){
									if(deviceAttributeArrayList.size != 0){
										if(deviceAttributeArrayList.contains(deviceMACAddress.str)){
											//This device already exists - update IP Address
											deviceAttributeArrayList.set(0,deviceIPAddress.str);
											//update the device status as active
											deviceAttributeArrayList.set(6,Constants.TEXT_FOR_DEVICES_ACTIVE_NOW);
											//Attempt an online search for vendor name if the vendor name is not recorded for this device
											if(deviceAttributeArrayList.get(2) == Constants.TEXT_FOR_NOT_AVAILABLE){
												if(mode == "DEVICE_SCAN_SCHEDULED"){
													deviceAttributeArrayList.set(2,getHostManufacturerOnline(deviceAttributeArrayList.get(1)));
												}
											}
											isNewDevice = false;
										}else{
											//do nothing
										}
									}
								}
							}
							//add details of the device to the device object list if it is a new one
							if(isNewDevice){
								Gee.ArrayList<string> deviceAttributeArrayList = new Gee.ArrayList<string> ();
								deviceAttributeArrayList.add(deviceIPAddress.str);
								deviceAttributeArrayList.add(deviceMACAddress.str);
								deviceAttributeArrayList.add(deviceVendorName.str);
								deviceAttributeArrayList.add(deviceHostName.str);
								deviceAttributeArrayList.add(new DateTime.now_local().format("%d-%b-%Y %H:%M:%S"));
								deviceAttributeArrayList.add(Constants.DEVICE_ALERT_PENDING);
								deviceAttributeArrayList.add(Constants.TEXT_FOR_DEVICES_ACTIVE_NOW);
								deviceDataArrayList.add(deviceAttributeArrayList);
							}

							//reset variables for capturing the next host details
							hostDetails.assign("");
							deviceIPAddress.assign("");
							deviceMACAddress.assign("");
							deviceVendorName.assign("");
							deviceHostName.assign("");
							isNewDevice = true;
						}
					}
				}

				/* Update device props by overwriting it with the latest device details */
				StringBuilder updatedDevicePropsData = new StringBuilder("");
				foreach(Gee.ArrayList<string> updatedDeviceAttributeArrayList in deviceDataArrayList){
					if(updatedDeviceAttributeArrayList.size != 0){
						updatedDevicePropsData.append(Constants.IDENTIFIER_FOR_PROPERTY_START);
						foreach(string updatedDeviceAttribute in updatedDeviceAttributeArrayList){
							updatedDevicePropsData.append(updatedDeviceAttribute);
							updatedDevicePropsData.append(Constants.IDENTIFIER_FOR_PROPERTY_VALUE);
						}
						//remove the last attribute seperator - last two bytes
						updatedDevicePropsData.erase(updatedDevicePropsData.str.length-2,2);
						updatedDevicePropsData.append(Constants.IDENTIFIER_FOR_PROPERTY_END);
					}
				}
				//overwrite the device data to the devices props file
				fileOperations("WRITE", nutty_config_path, Constants.nutty_devices_property_file_name, updatedDevicePropsData.str);
				//set permissions on device props
				fileOperations("SET_PERMISSIONS", nutty_config_path, Constants.nutty_devices_property_file_name, "777");
			}catch(Error e){
				warning("Failure in managing DeviceScan Results:"+e.message);
			}
			debug("Completed managing DeviceScan Results [mode="+mode+",interfaceName="+interfaceName+"]...");
			return deviceDataArrayList;
		}

		public Gtk.ListStore processDevicesScan(string interfaceName){
			debug("Starting to process DevicesScan [interfaceName="+interfaceName+"]...");
			device_list_store.clear();
			try{
				TreeIter iter;

				//Get the IP Address for the selected interface
				string scanIPAddress = interfaceIPMap.get(interfaceName);
				if(scanIPAddress == null || scanIPAddress == "" || scanIPAddress == "Not Available" || scanIPAddress == "127.0.0.1"){
					devices_results_label.set_text(Constants.TEXT_FOR_NO_DATA_FOUND+_(" for ")+interfaceName);
				}else{
					//set up the IP Address to scan the network : This should be of the form 192.168.1.1/24
					if(scanIPAddress.length>0 && scanIPAddress.last_index_of(".") > -1){
						scanIPAddress = scanIPAddress.substring(0, scanIPAddress.last_index_of("."))+".1/24";
						if(scanIPAddress != null || "" != scanIPAddress.strip()){
							//Run NMap scan and capture output
							execute_sync_multiarg_command_pipes({"pkexec", Constants.nutty_script_path + "/" + Constants.nutty_devices_file_name, scanIPAddress});
							string deviceScanResult = spawn_async_with_pipes_output.str;

							//set the NMap scan result on the Devices Results Label
							int extractionStartPos = deviceScanResult.index_of(";",deviceScanResult.index_of(Constants.IDENTIFIER_FOR_NMAP_RESULTS,0))+1;
							int extractionEndPos = deviceScanResult.index_of("\"",extractionStartPos+1);
							devices_results_label.set_text(deviceScanResult.substring(extractionStartPos, extractionEndPos-extractionStartPos));

							//parse the NMap output and update the devices props file
							Gee.ArrayList<ArrayList<string>> deviceDataArrayList = manageDeviceScanResults("DEVICE_SCAN_UI", deviceScanResult, interfaceName);

							//populate the Gtk.ListStore for the NMap scan
							foreach(ArrayList<string> deviceAttributeArrayList in deviceDataArrayList){
								device_list_store.append (out iter);
								if(deviceAttributeArrayList.get(6).contains(Constants.TEXT_FOR_DEVICES_NONACTIVE_NOW)){
									device_list_store.set (iter, 0, device_offline_pix, 1, deviceAttributeArrayList.get(3), 2, deviceAttributeArrayList.get(2), 3, deviceAttributeArrayList.get(4), 4, deviceAttributeArrayList.get(0), 5, deviceAttributeArrayList.get(1));
								}else{
									device_list_store.set (iter, 0, device_available_pix, 1, deviceAttributeArrayList.get(3), 2, deviceAttributeArrayList.get(2), 3, deviceAttributeArrayList.get(4), 4, deviceAttributeArrayList.get(0), 5, deviceAttributeArrayList.get(1));
								}
							}
						}
					}else{
						devices_results_label.set_text(Constants.TEXT_FOR_NO_DATA_FOUND);
					}
				}

				//stop the spinner on the UI
				devicesSpinner.stop();
			}catch(Error e){
				warning("Failure in processing DevicesScan:"+e.message);
			}
			debug("Completed processing DevicesScan [interfaceName="+interfaceName+"]...");
			return device_list_store;
		}

		public string getHostManufacturerOnline (string MAC){
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

		public Gtk.ListStore fetchRecordedDevices() {
			debug("Starting to fetch recorded devices..." );
			device_list_store.clear();
			try{
				TreeIter iter;
				//Read the devices props file for recorded data
				Gee.ArrayList<ArrayList<string>> deviceDataArrayList = manageDeviceScanResults("DEVICE_DATA", "", "");
				if(deviceDataArrayList.size > 0){
					//populate the Gtk.ListStore for the recorded data
					foreach(ArrayList<string> deviceAttributeArrayList in deviceDataArrayList){
						device_list_store.append (out iter);
						device_list_store.set (iter, 0, device_offline_pix, 1, deviceAttributeArrayList.get(3), 2, deviceAttributeArrayList.get(2), 3, deviceAttributeArrayList.get(4), 4, deviceAttributeArrayList.get(0), 5, deviceAttributeArrayList.get(1));
					}
					//Set results label
					devices_results_label.set_text(Constants.TEXT_FOR_RECORDED_DEVICES);
				}else{
					//Set results label
					devices_results_label.set_text(Constants.TEXT_FOR_NO_RECORDED_DEVICES_FOUND);
				}
			}catch(Error e){
				warning("Failure to fetch recorded devices:"+e.message);
			}
			debug("Completed fetching recorded devices...");
			return device_list_store;
		}

		public Gtk.ListStore processBandwidthApps(string interface_name){
			debug("Starting to process bandwidth of apps[interface_name="+interface_name+"]...");
			bandwidth_results_list_store.clear();
			try{
				TreeIter iter;
				Gdk.Pixbuf app_icon = default_app_pix;;
				StringBuilder processNames = new StringBuilder();
				StringBuilder aProcessName = new StringBuilder();
				bandwidthProcessSpinner.start();

				execute_sync_multiarg_command_pipes({"pkexec", Constants.nutty_script_path + "/" + Constants.nutty_bandwidth_process_file_name, interface_name});
				string process_bandwidth_result = spawn_async_with_pipes_output.str;

				//split the indivudual lines in the output
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
								bandwidth_results_list_store.set (iter, 0, app_icon, 1, aProcessName.str, 2, processDataAttributes[1], 3, processDataAttributes[2]);
								processNames.append(aProcessName.str);
							}
						}
						aProcessName.erase(0, -1);
						app_icon = default_app_pix;
					}
				}
				bandwidthProcessSpinner.stop();
			}catch(Error e){
				warning("Failure in processing bandwidth of apps[interface_name="+interface_name+"]:"+e.message);
			}
			debug("Completed processing bandwidth of apps[interface_name="+interface_name+"]...");
			return bandwidth_results_list_store;
		}

		public Gtk.ListStore processBandwidthUsage(string interface_name){
			debug("Starting to process bandwidth usage[interface_name="+interface_name+"]...");
			bandwidth_list_store.clear();
			try{
				TreeIter iter;
				//execute vnstat command to produce xml output (all values in KB)
				COMMAND_FOR_BANDWIDTH_USAGE[3] = interface_name;
				execute_sync_multiarg_command_pipes(COMMAND_FOR_BANDWIDTH_USAGE);
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
		public Gtk.ListStore processSpeedTest(bool shouldExecute){
			debug("Starting to process SpeedTest...");
			speedtest_list_store.clear();
			TreeIter iter;
			if(shouldExecute){
				if(! COMMAND_FOR_SPEED_TEST[0].contains(Constants.nutty_script_path)){
					COMMAND_FOR_SPEED_TEST[0] = Constants.nutty_script_path+ "/" + COMMAND_FOR_SPEED_TEST[0];
				}
				execute_sync_multiarg_command_pipes(COMMAND_FOR_SPEED_TEST);
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

		public void setupDeviceMonitoring(){
			debug("Starting to set up device monitoring...");
			try{
				//reset the device scheduled state if device schedule is disabled
				if(DEVICE_SCHEDULE_STATE == DEVICE_SCHEDULE_DISABLED)
					DEVICE_SCHEDULE_SELECTED = -1;

				//execute the command to update root crontab
				execute_sync_multiarg_command_pipes({"pkexec", Constants.nutty_script_path + "/" + Constants.nutty_monitor_scheduler_file_name,
																							DEVICE_SCHEDULE_SELECTED.to_string(),
																							Environment.get_home_dir () + "/" + Constants.nutty_monitor_scheduler_backup_file_name,
																							"/tmp/root_"+Environment.get_user_name () + "_crontab_temp.txt"
																					  });
				//build the command to update the user crontab
				string[] userCrontabCommand = new string[4];
				userCrontabCommand[0] = Constants.nutty_script_path + "/" + Constants.nutty_alert_scheduler_file_name;
				userCrontabCommand[1] = DEVICE_SCHEDULE_SELECTED.to_string();
				userCrontabCommand[2] = new StringBuilder().append(Environment.get_home_dir ()).append("/").append(Constants.nutty_alert_scheduler_backup_file_name).str;
				userCrontabCommand[3] = new StringBuilder().append("/tmp/user_").append(Environment.get_user_name ()).append("_crontab_temp.txt").str;
				execute_sync_multiarg_command_pipes(userCrontabCommand);
			}catch(Error e){
				warning("Failure in setting up device monitoring:"+e.message);
			}
			debug("Completed setting up device monitoring...");
		}

		/* functions for command line options : monitoring and alerting */
		public Gee.ArrayList<string> getInterfaceListForMonitor() {
			Gee.ArrayList <string> interfaceList =  new Gee.ArrayList<string>();
			string commandOutput = execute_sync_command(Constants.COMMAND_FOR_INTERFACE_NAMES); //get command output for interface details
			string[] linesArray = commandOutput.strip().split ("\n",-1); //split the indivudual lines in the output
			//In each line split the strings and record the first string only
			foreach(string dataElement in linesArray){
				string[] dataArray = dataElement.split (" ",-1);
				interfaceList.add ((string)dataArray[0].strip());
			}
			interfaceList.remove_at (0); //throw away the first string as that is a header name
			return interfaceList;
		}

		public void recordNewDevicesList(string interfaceName){
			debug("Starting to check new devices on scheduled basis [interfaceName="+interfaceName+"]...");
			try{
				StringBuilder commandOutput = new StringBuilder();
				StringBuilder IPAddress = new StringBuilder();
				//execute command for IP and MAC
				commandOutput.assign(execute_sync_command(Constants.COMMAND_FOR_INTERFACE_DETAILS+interfaceName));
				//find an IP address for each interface name
				string scanIPAddress = Utils.extractBetweenTwoStrings(commandOutput.str,Constants.IDENTIFIER_FOR_IPADDRESS_IN_COMMAND_OUTPUT," ");
				debug("Found IPAddress ="+IPAddress.str);
				if(scanIPAddress == null || scanIPAddress == "" || scanIPAddress == "Not Available" || scanIPAddress == "127.0.0.1"){
					//Local IP or No IP Available, so no scanning required
					debug("No scanning required as scanIPAddress="+scanIPAddress);
				}else{
					//set NMap scan on IP of the form: 192.168.1.1/24
					if(scanIPAddress.length>0 && scanIPAddress.last_index_of(".") > -1){
						scanIPAddress = scanIPAddress.substring(0, scanIPAddress.last_index_of("."))+".1/24";
						debug("Starting scanning with scanIPAddress="+scanIPAddress);
						if(scanIPAddress != null || "" != scanIPAddress.strip()){
							//Run NMap scan and capture output
							execute_sync_command(Constants.COMMAND_FOR_DEVICES_PREFIX + Constants.nmap_output_path + "/" + Constants.nmap_output_filename + Constants.COMMAND_FOR_DEVICES_SUFFIX + " " + scanIPAddress);
							//Read NMap Output from temporary file
							string deviceScanResult = fileOperations("READ", Constants.nmap_output_path, Constants.nmap_output_filename, "");
							//Remove temporary NMap results file
							fileOperations("DELETE", Constants.nmap_output_path, Constants.nmap_output_filename, "");
							//parse the NMap output and update the devices props file
							manageDeviceScanResults("DEVICE_SCAN_SCHEDULED", deviceScanResult, interfaceName);
						}
					}
				}
			}catch(Error e){
				warning("Failure in checking new devices on scheduled basis [interfaceName="+interfaceName+"]:"+e.message);
			}
			debug("Completed checking new devices on scheduled basis [interfaceName="+interfaceName+"]...");
		}

		public void runDeviceScan(){
			debug("Starting to run device scan on scheduled mode...");
			//Get a list of active interfaces
			Gee.ArrayList <string> interfaceList = getInterfaceListForMonitor();
			foreach (string inteface in interfaceList) {
				//Get a list of all new devices and record them in the props file
				recordNewDevicesList(inteface);
			}
			debug("Completed running device scan on scheduled mode...");
		}

		public void alertNewDevices(){
			debug("Starting check for alerting on new devices found..");
			//process device props for devices pending alert
			manageDeviceScanResults("DEVICE_ALERT", "", "");
			debug("Completed check for alerting on new devices found..");
		}
	}
}
