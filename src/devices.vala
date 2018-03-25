/* Copyright 2018 Siddhartha Das (bablu.boy@gmail.com)
*
* This file is part of Nutty and creates the headerbar widget
* and all the widgets associated with the headerbar
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

public class NuttyApp.Devices {
	public static TreeView device_table_treeview;
	//public static StringBuilder device_mac_found_in_scan = new StringBuilder("");

	public static Box createDeviceUI(){
			info("[START] [FUNCTION:createDeviceUI]");
			Box devices_layout_box = new Box (Orientation.VERTICAL, Constants.SPACING_WIDGETS);
        	device_table_treeview = new TreeView();
			NuttyApp.Nutty.devicesSpinner = new Gtk.Spinner();
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
			device_table_treeview.insert_column_with_attributes (-1, Constants.TEXT_FOR_DEVICES_COLUMN_NAME_7, device_cell_txt, "text", 6);

			ScrolledWindow devices_scroll = new ScrolledWindow (null, null);
			devices_scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			devices_scroll.add (device_table_treeview);

			NuttyApp.Nutty.devices_results_label = new Label (" ");
			Label devices_details_label = new Label (Constants.TEXT_FOR_LABEL_RESULT);
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
			info("[END] [FUNCTION:createDeviceUI]");
			return devices_layout_box;
    }

	public static Gtk.ListStore fetchRecordedDevices() {
		info("[START] [FUNCTION:fetchRecordedDevices]");
		NuttyApp.Nutty.device_list_store.clear();
		try{
			TreeIter iter;
			bool isDeviceOnline = false;
			//Fetch the devices recorded in the database
			NuttyApp.Nutty.deviceDataArrayList = NuttyApp.DB.getDevicesFromDB();
			if(NuttyApp.Nutty.deviceDataArrayList.size > 0){
				//populate the Gtk.ListStore for the recorded data
				foreach(NuttyApp.Entities.Device aDevice in NuttyApp.Nutty.deviceDataArrayList){
					NuttyApp.Nutty.device_list_store.append (out iter);
					if(NuttyApp.Nutty.device_mac_found_in_scan.str.index_of(aDevice.device_mac) != -1){
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
		}catch(Error e){
			warning("Failure to fetch recorded devices:"+e.message);
		}
		info("[START] [FUNCTION:fetchRecordedDevices]");
		return NuttyApp.Nutty.device_list_store;
	}

	public static Gtk.ListStore processDevicesScan(string interfaceName){
		info("[START] [FUNCTION:processDevicesScan] [interfaceName="+interfaceName+"]");
		try{
			TreeIter iter;
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
						runDeviceScan(interfaceName);
						//refresh the UI for the device list
						Gtk.ListStore currentdevice_list_store = fetchRecordedDevices();
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
		}catch(Error e){
			warning("Failure in processing DevicesScan:"+e.message);
		}
		info("[END] [FUNCTION:processDevicesScan] [interfaceName="+interfaceName+"]");
		return NuttyApp.Nutty.device_list_store;
	}

	public static void runDeviceScan (string interfaceName) {
		info("[START] [FUNCTION:runDeviceScan] [interfaceName="+interfaceName+"]");
		
		//Get the IP Address for the selected interface
		string scanIPAddress = NuttyApp.Nutty.interfaceIPMap.get(interfaceName);
		//Quit if no valid IP is found
		if(scanIPAddress == null || scanIPAddress == "" || scanIPAddress == "Not Available" || scanIPAddress == "127.0.0.1"){
			NuttyApp.Nutty.devices_results_label.set_text(Constants.TEXT_FOR_NO_DATA_FOUND+_(" for ")+interfaceName);
			return;
		}
		//set up the IP Address to scan the network : This should be of the form 192.168.1.1/24
		if(scanIPAddress.length>0 && scanIPAddress.last_index_of(".") > -1){
			scanIPAddress = scanIPAddress.substring(0, scanIPAddress.last_index_of("."))+".1/24";
			if(scanIPAddress != null || "" != scanIPAddress.strip()){
				//Run NMap scan and capture output
				NuttyApp.Nutty.execute_sync_multiarg_command_pipes({
								"pkexec", 
								Constants.nutty_script_path + "/" + Constants.nutty_devices_file_name, scanIPAddress
				});
				string deviceScanResult = NuttyApp.Nutty.spawn_async_with_pipes_output.str;
				deviceScanResult = deviceScanResult.splice(0, deviceScanResult.index_of("<nmaprun"), "");
				NuttyApp.XmlParser thisParser = new NuttyApp.XmlParser();
				ArrayList<NuttyApp.Entities.Device> extractedDeviceList = thisParser.extractDeviceDataFromXML("/tmp/nutty_nmap.xml");
				NuttyApp.Nutty.device_mac_found_in_scan.assign("");
				foreach(NuttyApp.Entities.Device aExtractedDevice in extractedDeviceList){
					NuttyApp.DB.addDeviceToDB(aExtractedDevice);
					NuttyApp.Nutty.device_mac_found_in_scan.append(aExtractedDevice.device_mac).append(",");
				}
			}
		}
		info("[END] [FUNCTION:runDeviceScan] [interfaceName="+interfaceName+"]");
	}

	public static Gee.ArrayList<Gee.ArrayList<string>> manageDeviceScanResults (
		string mode, 
		string nmapOutput, 
		string interfaceName)
	{
		info("[START] [FUNCTION:manageDeviceScanResults] mode="+mode+",interfaceName="+interfaceName+"]");			
		Gee.ArrayList<ArrayList<string>> deviceDataArrayList =  new Gee.ArrayList<Gee.ArrayList<string>>();
		try{
			string devicePropsData = "";
			int deviceAttributeCounter = 0;
			/* Read Device Props and create a device data object */
			devicePropsData = NuttyApp.Utils.fileOperations("READ", NuttyApp.Nutty.nutty_config_path, Constants.nutty_devices_property_file_name, "");
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
							NuttyApp.Nutty.execute_sync_command(Constants.COMMAND_FOR_DEVICES_ALERT + " '" + NuttyApp.Nutty.TEXT_FOR_DEVICE_FOUND_NOTIFICATION + deviceAttributeArrayList.get(3) + "(" + deviceAttributeArrayList.get(0) + ")'");
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
								string MACCommandOutput = NuttyApp.Nutty.execute_sync_command(Constants.COMMAND_FOR_INTERFACE_DETAILS+interfaceName);
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
										deviceVendorName.assign(NuttyApp.Nutty.getHostManufacturerOnline(deviceMACAddress.str));
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
										deviceVendorName.assign(NuttyApp.Nutty.getHostManufacturerOnline(deviceMACAddress.str));
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
													deviceAttributeArrayList.set(2,NuttyApp.Nutty.getHostManufacturerOnline(deviceAttributeArrayList.get(1)));
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
				NuttyApp.Utils.fileOperations("WRITE", NuttyApp.Nutty.nutty_config_path, Constants.nutty_devices_property_file_name, updatedDevicePropsData.str);
				//set permissions on device props
				NuttyApp.Utils.fileOperations("SET_PERMISSIONS", NuttyApp.Nutty.nutty_config_path, Constants.nutty_devices_property_file_name, "777");
			}catch(Error e){
				warning("Failure in managing DeviceScan Results:"+e.message);
			}
			debug("Completed managing DeviceScan Results [mode="+mode+",interfaceName="+interfaceName+"]...");
			return deviceDataArrayList;
		}
}
