/* Copyright 2018 Siddhartha Das (bablu.boy@gmail.com)
*
* This file is part of Nutty and provides the details of the Devices tab
* The device alert function is also provided in this class
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
using Gdk;
public class NuttyApp.Devices {
	public static TreeView device_table_treeview;
	public static Popover aContextMenu;
	public static Label deviceContentMenuTitleLabel;
	public static Label deviceContentMACLabel;
	public static Label deviceContentIPLabel;
	public static Button deviceRemoveButton;

	public static Box createDeviceUI(){
			info("[START] [FUNCTION:createDeviceUI]");
			Box devices_layout_box = new Box (Orientation.VERTICAL, Constants.SPACING_WIDGETS);
        	device_table_treeview = new TreeView();
			device_table_treeview.activate_on_single_click = true;
			NuttyApp.Nutty.devicesSpinner = new Gtk.Spinner();
            Button devices_refresh_button = new Button.from_icon_name (Constants.REFRESH_ICON, IconSize.SMALL_TOOLBAR);
			devices_refresh_button.set_relief (ReliefStyle.NONE);
			devices_refresh_button.set_tooltip_markup (Constants.TEXT_FOR_DEVICES_TOOLTIP);
			//set the devices refresh button to in-active status
			devices_refresh_button.set_sensitive (false);
			CellRendererText device_cell_txt = new CellRendererText ();
			CellRendererText device_hostname_cell_txt = new CellRendererText ();
			device_hostname_cell_txt.editable = true;
			CellRendererText device_manufacture_cell_txt = new CellRendererText ();
			device_manufacture_cell_txt.editable = true;
			CellRendererPixbuf device_cell_pix = new CellRendererPixbuf ();
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_1, device_cell_pix, "pixbuf", 0);
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_2, device_hostname_cell_txt, "text", 1);
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_3, device_manufacture_cell_txt, "text", 2);
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_4, device_cell_txt, "text", 3);
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_5, device_cell_txt, "text", 4);
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_6, device_cell_txt, "text", 5);
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_7, device_cell_txt, "text", 6);
			
			ScrolledWindow devices_scroll = new ScrolledWindow (null, null);
			devices_scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			devices_scroll.add (device_table_treeview);

			NuttyApp.Nutty.devices_results_label = new Label (" ");
			ComboBoxText devices_combobox = new ComboBoxText();
			//Set connection values into combobox
			devices_combobox.insert(0,Constants.TEXT_FOR_INTERFACE_LABEL,Constants.TEXT_FOR_INTERFACE_LABEL);
			int devices_combobox_counter = 1;
			foreach (var entry in NuttyApp.Nutty.interfaceConnectionMap.entries) {
				devices_combobox.insert(NuttyApp.Nutty.info_combobox_counter, entry.key, entry.value);
				devices_combobox_counter++;
			}
			devices_combobox.active = 0;

			Box devices_results_box = new Box (Orientation.HORIZONTAL, Constants.SPACING_WIDGETS);
			devices_results_box.pack_start (devices_combobox, false, true, 0);
			devices_results_box.pack_start (NuttyApp.Nutty.devices_results_label, false, true, 0);
			devices_results_box.pack_end (devices_refresh_button, false, true, 0);
			devices_results_box.pack_end (NuttyApp.Nutty.devicesSpinner, false, true, 0);

			device_table_treeview.set_activate_on_single_click (true);
			
			//Create the device popover menu
			deviceContentMenuTitleLabel = new Label("");
			deviceContentIPLabel = new Label("");
			deviceContentMACLabel = new Label("");
			deviceContentIPLabel.set_halign(Align.START);
			deviceContentMACLabel.set_halign(Align.START);
			deviceRemoveButton = new Button.with_label(NuttyApp.Constants.TEXT_FOR_DEVICES_REMOVAL);
			aContextMenu = new Gtk.Popover (device_table_treeview);
			Gtk.Box deviceContextMenuBox = new Gtk.Box(Orientation.VERTICAL, NuttyApp.Constants.SPACING_BUTTONS);
    		deviceContextMenuBox.set_border_width(NuttyApp.Constants.SPACING_WIDGETS);
    		deviceContextMenuBox.pack_start(deviceContentMenuTitleLabel, false, false);
    		deviceContextMenuBox.pack_start(new Gtk.Separator (Gtk.Orientation.HORIZONTAL) , true, true, 0);
			deviceContextMenuBox.pack_start(deviceContentIPLabel, false, false);
			deviceContextMenuBox.pack_start(deviceContentMACLabel, false, false);
			deviceContextMenuBox.pack_start(new Gtk.Separator (Gtk.Orientation.HORIZONTAL) , true, true, 0);
			deviceContextMenuBox.pack_start(deviceRemoveButton, false, false);
			aContextMenu.add(deviceContextMenuBox);
						
			//Add components to the device box
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
					NuttyApp.Nutty.devicesSpinner.start();
					NuttyApp.Nutty.devices_results_label.set_text(Constants.TEXT_FOR_DEVICES_SCAN_IN_PROGRESS);
					NuttyApp.Nutty.devicesTreeModelFilter = new Gtk.TreeModelFilter (
												processDevicesScan(devices_combobox.get_active_id ()), 
												null);
					NuttyApp.Nutty.setFilterAndSort(device_table_treeview, NuttyApp.Nutty.devicesTreeModelFilter, SortType.DESCENDING);
					NuttyApp.Nutty.isDevicesViewLoaded = true;
				}else{// no interface connection is set
					//set the devices refresh button to in-active status
					devices_refresh_button.set_sensitive (false);
					//populate device data recorded earlier
					NuttyApp.Nutty.devicesTreeModelFilter = new Gtk.TreeModelFilter (fetchRecordedDevices(), null);
					NuttyApp.Nutty.setFilterAndSort(device_table_treeview, NuttyApp.Nutty.devicesTreeModelFilter, SortType.DESCENDING);
					NuttyApp.Nutty.isDevicesViewLoaded = true;
				}
			});

			// Set actions for Device Refresh Button Clicking
			devices_refresh_button.clicked.connect (() => {
				NuttyApp.Nutty.devicesSpinner.start();
				NuttyApp.Nutty.devices_results_label.set_text(Constants.TEXT_FOR_DEVICES_SCAN_IN_PROGRESS);
				NuttyApp.Nutty.devicesTreeModelFilter = new Gtk.TreeModelFilter (processDevicesScan(devices_combobox.get_active_id ()), null);
				NuttyApp.Nutty.setFilterAndSort(device_table_treeview, NuttyApp.Nutty.devicesTreeModelFilter, SortType.DESCENDING);
				NuttyApp.Nutty.isDevicesViewLoaded = true;
			});

			//Add action to update tree view when editing is Completed
        	device_hostname_cell_txt.edited.connect((path, new_text) => {
				updateDeviceListViewData(path, new_text, 1);
        	});
        	device_manufacture_cell_txt.edited.connect((path, new_text) => {
				updateDeviceListViewData(path, new_text, 2);
        	});	
			
			//add mouse click listener
            device_table_treeview.button_press_event.connect ((widget, event) => {
                //capture which mouse button
                uint mouseButtonClicked;
                event.get_button(out mouseButtonClicked);
				//handle right button click for context menu
                if (event.get_event_type ()  == Gdk.EventType.BUTTON_PRESS  &&  mouseButtonClicked == 3){
					debug("Show Context Menu");
					//determine the position on which the right click has happened			
					TreePath path; TreeViewColumn column; int cell_x; int cell_y;
					device_table_treeview.get_path_at_pos ((int)event.x, (int)event.y, out path, out column, out cell_x, out cell_y);
					device_table_treeview.grab_focus();
               		device_table_treeview.set_cursor(path,column,false);
					//get details of the selected row and display the context menu
					TreeSelection aTreeSelection = device_table_treeview.get_selection ();
					if(aTreeSelection.count_selected_rows() == 1){
						TreeModel model;
						TreeIter iter;
						aTreeSelection.get_selected (out model, out iter);
						deviceContextMenu(model, iter);
					}
				}
				return false;
            });
			info("[END] [FUNCTION:createDeviceUI]");
			return devices_layout_box;
    }

	public static void deviceContextMenu (TreeModel aTreeModel, TreeIter iter){
		//Determine IP and MAC of the device for the context menu
        Value deviceIP;	Value deviceMAC;Value deviceHostName;
        aTreeModel.get_value (iter, 5, out deviceIP);
		aTreeModel.get_value (iter, 6, out deviceMAC);
        aTreeModel.get_value (iter, 1, out deviceHostName);
		//determine the position where the device context menu will be shown
		TreePath path;
		TreeViewColumn focus_column;
		device_table_treeview.get_cursor (out path, out focus_column);
		Rectangle rect;
		device_table_treeview.get_cell_area(path, focus_column, out rect); 
		//set the position of the device context menu
		aContextMenu.set_pointing_to (rect);
		//setup the context menu for the selected device
		deviceContentMenuTitleLabel.set_label(
				new StringBuilder(NuttyApp.Constants.TEXT_FOR_DEVICES_ACTION).append( (string)deviceHostName).str
		);
		deviceContentMACLabel.set_label(
				new StringBuilder(NuttyApp.Constants.TEXT_FOR_DEVICES_COLUMN_NAME_7).append(" : ").append( (string)deviceMAC).str
		);
		deviceContentIPLabel.set_label(
				new StringBuilder(NuttyApp.Constants.TEXT_FOR_DEVICES_COLUMN_NAME_6).append(" : ").append( (string)deviceIP).str
		);
		
		aContextMenu.set_visible (true);
        aContextMenu.show_all();
        
        //set up the action for the click of the Device Remove button
		deviceRemoveButton.clicked.connect (() => {
			NuttyApp.Entities.Device aDevice = new NuttyApp.Entities.Device();
			aDevice.device_ip = (string)deviceIP;
			aDevice.device_mac = (string)deviceMAC;
			bool isDeviceRemoved = NuttyApp.DB.removeDeviceFromDB(aDevice);
			if(isDeviceRemoved){
				fetchRecordedDevices();//refresh the device list
			}
			aContextMenu.hide();
		});

		//catch the event when device popover menu is closed is closed
		aContextMenu.closed.connect(() => {
			//TODO
		});
	}

	public static bool updateDeviceListViewData(string path, string new_text, int column){
		info("[START] [FUNCTION:updateDeviceListViewData] updating device data in List View on row:"+path+
                                                        " for change:"+new_text+" on column:"+column.to_string());
        //Determine IP and MAC of the device which is being updated
        Gtk.TreeIter sortedIter;
        Value deviceIP;
		Value deviceMAC;
        TreeModel aTreeModel =  device_table_treeview.get_model ();
        Gtk.TreePath aTreePath = new Gtk.TreePath.from_string (path);
        aTreeModel.get_iter (out sortedIter, aTreePath);
        aTreeModel.get_value (sortedIter, 5, out deviceIP);
		aTreeModel.get_value (sortedIter, 6, out deviceMAC);

        //iterate over the list store
        Gtk.TreeIter iter;
        string deviceIPforCurrentRow;
		string deviceMACforCurrentRow;
        bool iterExists = true;
        iterExists = NuttyApp.Nutty.device_list_store.get_iter_first (out iter);
        while(iterExists){
            NuttyApp.Nutty.device_list_store.get (iter, 5, out deviceIPforCurrentRow);
			NuttyApp.Nutty.device_list_store.get (iter, 6, out deviceMACforCurrentRow);
            if((string)deviceIP == deviceIPforCurrentRow && (string)deviceMAC == deviceMACforCurrentRow) {
				string deviceHostNameCustomforCurrentRow;
				string deviceManufacturerNameCustomforCurrentRow;
				NuttyApp.Nutty.device_list_store.get (iter, 1, out deviceHostNameCustomforCurrentRow);
				NuttyApp.Nutty.device_list_store.get (iter, 2, out deviceManufacturerNameCustomforCurrentRow);
                NuttyApp.Nutty.device_list_store.set (iter, column, new_text);
				if(column == 1){
					if(deviceHostNameCustomforCurrentRow != new_text){ //check if any edits have happened
						//update the custom host name changes in the DB
						NuttyApp.Entities.Device aDevice = new NuttyApp.Entities.Device();
						aDevice.device_ip = deviceIPforCurrentRow;
						aDevice.device_mac = deviceMACforCurrentRow;
						aDevice.device_hostname_custom = new_text;
						NuttyApp.DB.addDeviceToDB(aDevice);
						debug("Completed updating device data into DB for IP:"+deviceIPforCurrentRow);
					}
				}
				if(column == 2){
					if(deviceManufacturerNameCustomforCurrentRow != new_text){ //check if any edits have happened
						//update the custom manufacturer name changes in the DB
						NuttyApp.Entities.Device aDevice = new NuttyApp.Entities.Device();
						aDevice.device_ip = deviceIPforCurrentRow;
						aDevice.device_mac = deviceMACforCurrentRow;
						aDevice.device_manufacturer_custom = new_text;
						NuttyApp.DB.addDeviceToDB(aDevice);
						debug("Completed updating device data into DB for MAC:"+deviceMACforCurrentRow);
					}
				}
                break; //break out of the iterations
            }
            iterExists = NuttyApp.Nutty.device_list_store.iter_next (ref iter);
        }
        info("[END] [FUNCTION:updateDeviceListViewData] ");
		return true;
	}

	public static Gtk.ListStore fetchRecordedDevices() {
		info("[START] [FUNCTION:fetchRecordedDevices]");
		NuttyApp.Nutty.device_list_store.clear();
		TreeIter iter;
		bool isDeviceOnline = false;
		//Fetch the devices recorded in the database
		NuttyApp.Nutty.deviceDataArrayList = NuttyApp.DB.getDevicesFromDB();
		if(NuttyApp.Nutty.deviceDataArrayList != null && NuttyApp.Nutty.deviceDataArrayList.size > 0){
			//populate the Gtk.ListStore for the recorded data
			foreach(NuttyApp.Entities.Device aDevice in NuttyApp.Nutty.deviceDataArrayList){
				NuttyApp.Nutty.device_list_store.append (out iter);
				if(	aDevice.device_mac != null &&
					aDevice.device_mac != "" && 
					NuttyApp.Nutty.device_mac_found_in_scan.str.index_of(aDevice.device_mac) != -1
				){
					isDeviceOnline = true;
				}else{
					isDeviceOnline = false;
				}
				//display device details
				NuttyApp.Nutty.device_list_store.set (iter, 
							0, isDeviceOnline ? NuttyApp.Nutty.device_available_pix : NuttyApp.Nutty.device_offline_pix, 
							1, NuttyApp.Utils.limitStringLength (aDevice.device_hostname_custom, 25), 
							2, NuttyApp.Utils.limitStringLength (aDevice.device_manufacturer_custom, 25), 
							3, NuttyApp.Utils.getFormattedDate(aDevice.device_last_seen_date,"%d-%m-%Y", true),
							4, NuttyApp.Utils.getFormattedDate(aDevice.device_creation_date,"%d-%m-%Y %H:%M:%S", false),
							5, aDevice.device_ip, 
							6, aDevice.device_mac
				);
			}
			//Set results label
			NuttyApp.Nutty.devices_results_label.set_text(Constants.TEXT_FOR_RECORDED_DEVICES);
		}else{
			//Set results label
			NuttyApp.Nutty.devices_results_label.set_text(Constants.TEXT_FOR_NO_RECORDED_DEVICES_FOUND);
		}
		info("[START] [FUNCTION:fetchRecordedDevices]");
		return NuttyApp.Nutty.device_list_store;
	}

	public static Gtk.ListStore processDevicesScan(string interfaceName){
		info("[START] [FUNCTION:processDevicesScan] [interfaceName="+interfaceName+"]");
		//Get the IP Address for the selected interface
		string scanIPAddress = NuttyApp.Nutty.interfaceIPMap.get(interfaceName);
		if(scanIPAddress == null || scanIPAddress == "" || scanIPAddress == "Not Available" || scanIPAddress == "127.0.0.1"){
			NuttyApp.Nutty.devices_results_label.set_text(Constants.TEXT_FOR_NO_DATA_FOUND+_(" for ")+interfaceName);
		}else{
			//set up the IP Address to scan the network : This should be of the form 192.168.1.1/24
			if(scanIPAddress.length>0 && scanIPAddress.last_index_of(".") > -1){
				scanIPAddress = scanIPAddress.substring(0, scanIPAddress.last_index_of("."))+".1/24";
				if(scanIPAddress != null || "" != scanIPAddress.strip()){
					//parse the NMap output and update the devices on DB
					runDeviceScan(scanIPAddress);
					//refresh the UI for the device list
					fetchRecordedDevices();
					//set the label for devices search
					NuttyApp.Nutty.devices_results_label.set_text(
							NuttyApp.Nutty.device_mac_found_in_scan.str.split(",", 0).length.to_string() 
							+ " " +NuttyApp.Constants.TEXT_FOR_DEVICES_FOUND
					);
				}
			}else{
				NuttyApp.Nutty.devices_results_label.set_text(Constants.TEXT_FOR_NO_DATA_FOUND);
			}
		}
		//stop the spinner on the UI
		NuttyApp.Nutty.devicesSpinner.stop();
		info("[END] [FUNCTION:processDevicesScan] [interfaceName="+interfaceName+"]");
		return NuttyApp.Nutty.device_list_store;
	}

	public static void runDeviceScan (string scanIPAddress) {
		info("[START] [FUNCTION:runDeviceScan] [scanIPAddress="+scanIPAddress+"]");
		//Run NMap scan and capture output
		NuttyApp.Nutty.execute_sync_multiarg_command_pipes({
						"pkexec", 
						NuttyApp.Constants.COMMAND_FOR_DEVICE_SCAN,
						Constants.nmap_output_filename,
						scanIPAddress
		});
		//handle unsucessful command execution and raise error on infobar
		if(!Utils.isExpectedOutputPresent(
						string.joinv(" ", 
								{NuttyApp.Constants.COMMAND_FOR_DEVICE_SCAN, Constants.nmap_output_filename, scanIPAddress}
						),
						NuttyApp.Nutty.spawn_async_with_pipes_output.str,
						{"nmap", "executed", "successfully"},
						true
			)
		){
			NuttyApp.Nutty.devices_results_label.set_text(Constants.TEXT_FOR_NO_DATA_FOUND);
		}
		NuttyApp.XmlParser thisParser = new NuttyApp.XmlParser();
		ArrayList<NuttyApp.Entities.Device> extractedDeviceList = 
								thisParser.extractDeviceDataFromXML(Constants.nmap_output_filename);
		NuttyApp.Nutty.device_mac_found_in_scan.assign("");
		foreach(NuttyApp.Entities.Device aExtractedDevice in extractedDeviceList){
			NuttyApp.DB.addDeviceToDB(aExtractedDevice);
			NuttyApp.Nutty.device_mac_found_in_scan.append(aExtractedDevice.device_mac).append(",");
		}
		info("[END] [FUNCTION:runDeviceScan] [scanIPAddress="+scanIPAddress+"]");
	}

	public static void alertNewDevices () {
		print("\n[START] [FUNCTION:alertNewDevices]");
		
		//get data for all devices recorded in the DB 
        ArrayList<NuttyApp.Entities.Device> listOfDevices = NuttyApp.DB.getDevicesFromDB();
		//Loop over all devices and check if any device has not been alerted
		foreach(NuttyApp.Entities.Device aDevice in listOfDevices){
			print("\nChecking Alert condition for Device with IP: "+aDevice.device_ip + " and alert status:"+aDevice.device_alert);
			if(aDevice.device_alert != NuttyApp.Constants.DEVICE_ALERT_COMPLETED){
				//push an alert for the device
				Notify.init (NuttyApp.Constants.app_id);
				try {
					Notify.Notification notification = new Notify.Notification (
							NuttyApp.Constants.TEXT_FOR_DEVICE_FOUND_NOTIFICATION, 
							aDevice.device_hostname_custom + "(" + aDevice.device_ip + ")'", 
							NuttyApp.Constants.app_icon
					);
					notification.app_name =  NuttyApp.Constants.program_name;
					notification.show ();
				} catch (Error e) {
					print ("\nError while sending notification: %s", e.message);
				}

				//update the device status as alert complete in the DB
				aDevice.device_alert = NuttyApp.Constants.DEVICE_ALERT_COMPLETED;
				NuttyApp.DB.addDeviceToDB(aDevice);
				print("\nAlert completed for Device with IP: "+aDevice.device_ip);
			}			
		}
		print("\n[END] [FUNCTION:alertNewDevices]");
	}

	public static void runDeviceDiscovery(){
		print("\n[START] [FUNCTION:runDeviceDiscovery]");
		//get the list of all interfaces
        ArrayList<string> interfaceList = new ArrayList<string>();
        StringBuilder commandOutput = new StringBuilder("");
        commandOutput.assign(NuttyApp.Nutty.execute_sync_command(Constants.COMMAND_FOR_INTERFACES + " INTERFACE"));
		string[] interfaces = commandOutput.str.strip().split (" ",-1);
		//In each line split the strings and record the first string only
		foreach(string interface in interfaces){
            if(interface.strip().length > 0){
				interfaceList.add (interface.strip());
			}
		}
		//Get the IP addresses corresponding to each interface name
		StringBuilder IPAddress = new StringBuilder("");
		foreach(string data in interfaceList) {
			//execute command for IP
			IPAddress.assign(commandOutput.assign(
        			NuttyApp.Nutty.execute_sync_command(
						Constants.COMMAND_FOR_INTERFACES + " IP " + data.strip()
					)).str.replace("\n","").strip()
			);
			//set up the IP Address to scan the network : This should be of the form 192.168.1.1/24
			if(IPAddress.str.length>0 && IPAddress.str.last_index_of(".") > -1){
				IPAddress.assign(IPAddress.str.substring(0, IPAddress.str.last_index_of("."))+".1/24");
                if(IPAddress != null || "" != IPAddress.str.strip()){
		            print("\nRunning scan for IP Address: "+ IPAddress.str);
		            //scan for devices for each IPAddress
		            runDeviceScan (IPAddress.str);
                }
            }
		}
		print("\n[END] [FUNCTION:runDeviceDiscovery]");
	}

	public static void setupDeviceMonitoring(){
		info("[START] [FUNCTION:setupDeviceMonitoring]");
		//execute the command to update root crontab for monitoring
		NuttyApp.Nutty.execute_sync_multiarg_command_pipes({
					"pkexec",
					Constants.COMMAND_FOR_SCHEDULED_DEVICE_SCAN,
					NuttyApp.Nutty.DEVICE_SCHEDULE_SELECTED.to_string(),
					NuttyApp.Nutty.nutty_config_path, 
					NuttyApp.Nutty.app_xdg_path.user_config_folder.get_path() + "/" + Constants.nutty_monitor_scheduler_backup_file_name,
					NuttyApp.Nutty.app_xdg_path.user_cache_folder.get_path() + "/root_"+ Environment.get_user_name () + "_crontab_temp.txt"
	  	});
		//execute the command to update user crontab for alerting
		NuttyApp.Nutty.execute_sync_multiarg_command_pipes({
					Constants.COMMAND_FOR_SCHEDULED_DEVICE_ALERT,
					NuttyApp.Nutty.DEVICE_SCHEDULE_SELECTED.to_string(),
					NuttyApp.Nutty.nutty_config_path, 
					NuttyApp.Nutty.app_xdg_path.user_config_folder.get_path() + "/" + Constants.nutty_alert_scheduler_backup_file_name,
					NuttyApp.Nutty.app_xdg_path.user_cache_folder.get_path() + "/user_"+Environment.get_user_name () + "_crontab_temp.txt"
  		});
		info("[END] [FUNCTION:setupDeviceMonitoring]");
	}
	
	public static void deviceScheduleSelection (Gtk.ToggleButton button) {
		//isMonitorScheduleReadyForChange - this flag prevents triggering the crontab change 
		//when one of the radio buttons is made active per the saved state
		if(NuttyApp.Nutty.isMonitorScheduleReadyForChange){
			if(Constants.TEXT_FOR_PREFS_DIALOG_15MIN_OPTION == button.label){
				//check if a change is observed and change the crontab
				if(NuttyApp.Nutty.DEVICE_SCHEDULE_SELECTED != Constants.DEVICE_SCHEDULE_15MINS){
					NuttyApp.Nutty.DEVICE_SCHEDULE_SELECTED = Constants.DEVICE_SCHEDULE_15MINS;
					NuttyApp.Devices.setupDeviceMonitoring();	
				}
			}
			if(Constants.TEXT_FOR_PREFS_DIALOG_30MIN_OPTION == button.label){
				//check if a change is observed and change the crontab
				if(NuttyApp.Nutty.DEVICE_SCHEDULE_SELECTED != Constants.DEVICE_SCHEDULE_30MINS){
					NuttyApp.Nutty.DEVICE_SCHEDULE_SELECTED = Constants.DEVICE_SCHEDULE_30MINS;
					NuttyApp.Devices.setupDeviceMonitoring();	
				}
			}
			if(Constants.TEXT_FOR_PREFS_DIALOG_HOUR_OPTION == button.label){
				//check if a change is observed and change the crontab
				if(NuttyApp.Nutty.DEVICE_SCHEDULE_SELECTED != Constants.DEVICE_SCHEDULE_15MINS){
					NuttyApp.Nutty.DEVICE_SCHEDULE_SELECTED = Constants.DEVICE_SCHEDULE_1HOUR;
					NuttyApp.Devices.setupDeviceMonitoring();	
				}
			}
			if(Constants.TEXT_FOR_PREFS_DIALOG_DAY_OPTION == button.label) {
				//check if a change is observed and change the crontab
				if(NuttyApp.Nutty.DEVICE_SCHEDULE_SELECTED != Constants.DEVICE_SCHEDULE_15MINS){
					NuttyApp.Nutty.DEVICE_SCHEDULE_SELECTED = Constants.DEVICE_SCHEDULE_1DAY;
						NuttyApp.Devices.setupDeviceMonitoring();	
					}
				}
			}
			debug("Completed noting the selection for device monitoring schedule...");
		}

		public static void handleDeviceMonitoring(bool isSwitchSet){
			if (isSwitchSet) {
				NuttyApp.Nutty.min15Option.set_sensitive(true);
				NuttyApp.Nutty.min30Option.set_sensitive(true);
				NuttyApp.Nutty.hourOption.set_sensitive(true);
				NuttyApp.Nutty.dayOption.set_sensitive(true);
			} else {
				NuttyApp.Nutty.min15Option.set_sensitive(false);
				NuttyApp.Nutty.min30Option.set_sensitive(false);
				NuttyApp.Nutty.hourOption.set_sensitive(false);
				NuttyApp.Nutty.dayOption.set_sensitive(false);
				if(NuttyApp.Nutty.isMonitorScheduleReadyForChange){
					//set monitoring frequency to zero and call crontab routine,
					//this will remove cron job for both monitoring and alerting
					NuttyApp.Nutty.DEVICE_SCHEDULE_SELECTED = 0;
					NuttyApp.Devices.setupDeviceMonitoring();
				}
			}
			debug("Completed toggling device monitoring UI...");
		}
}
