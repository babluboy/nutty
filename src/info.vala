/* Copyright 2018 Siddhartha Das (bablu.boy@gmail.com)
*
* This file is part of Nutty and provides the details of the Info tab
* The Interfaces, MAC and IP determined here are used throughout 
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

public class NuttyApp.Info {
    public static void getConnectionsList() {
        info("[START] [FUNCTION:getConnectionsList]");
        if(NuttyApp.Nutty.interfaceConnectionMap != null) {
		    //do nothing as the connections map is already populated
		}else{
            //get the list of all interfaces
            ArrayList<string> interfaceList = new ArrayList<string>();
            StringBuilder commandOutput = new StringBuilder("");
            commandOutput.assign(NuttyApp.Nutty.execute_sync_command(Constants.COMMAND_FOR_INTERFACES + " INTERFACE"));
			string[] interfaces = commandOutput.str.strip().split (" ",-1);
			//In each line split the strings and record the first string only
			foreach(string interface in interfaces){
                if(interface.strip().length > 0){
					interfaceList.add (interface.strip());
                	debug("Found interface :"+interface.strip());
				}
			}
            NuttyApp.Nutty.interfaceConnectionMap = new HashMap <string,string>();
			NuttyApp.Nutty.interfaceIPMap = new HashMap <string,string>();
			NuttyApp.Nutty.interfaceIPV6Map = new HashMap <string,string>();
			NuttyApp.Nutty.interfaceMACMap = new HashMap <string,string>();

			StringBuilder IPAddress = new StringBuilder("");
            StringBuilder IPV6Address = new StringBuilder("");
			StringBuilder MACAddress = new StringBuilder("");
			StringBuilder interfaceDisplayName = new StringBuilder("");
			//Get interface names to populate the dropdown list and find corresponding IP addresses
			foreach(string data in interfaceList){
				//create a connection name for each interface name and hold in a HashMap
				if(data.down().get_char(0) == 'e'){
					NuttyApp.Nutty.interfaceConnectionMap.set(data, 
						interfaceDisplayName.assign
							(Constants.TEXT_FOR_WIRED_CONNECTION).append(" (" ).append(data.replace("\n","").strip()).append( ")").str
					);
				}else if(data.down().get_char(0) == 'w'){
					NuttyApp.Nutty.interfaceConnectionMap.set(data, 
						interfaceDisplayName.assign
							(Constants.TEXT_FOR_WIRELESS_CONNECTION).append(" (" ).append(data.replace("\n","").strip()).append( ")").str
					);
				}else{
					NuttyApp.Nutty.interfaceConnectionMap.set(data, 
						interfaceDisplayName.assign
							(Constants.TEXT_FOR_OTHER_CONNECTION).append(" (" ).append(data.replace("\n","").strip()).append( ")").str
					);
				}
				//execute command for IP
				IPAddress.assign(commandOutput.assign(
            			NuttyApp.Nutty.execute_sync_command(
							Constants.COMMAND_FOR_INTERFACES + " IP " + data.strip()
						)).str.replace("\n","").strip()
				);
				NuttyApp.Nutty.interfaceIPMap.set(data,IPAddress.str);
                //execute command for IPv6
				IPV6Address.assign(commandOutput.assign(
            			NuttyApp.Nutty.execute_sync_command(
							Constants.COMMAND_FOR_INTERFACES + " IPV6 " + data.strip()
						)).str.replace("\n","").strip()
				);
				NuttyApp.Nutty.interfaceIPV6Map.set(data,IPV6Address.str);
				//execute command for MAC
                MACAddress.assign(commandOutput.assign(
                		(NuttyApp.Nutty.execute_sync_command(
							Constants.COMMAND_FOR_INTERFACES + " MAC " + data.strip()
						)).up(-1)).str.replace("\n","").strip()
				);
				NuttyApp.Nutty.interfaceMACMap.set(data,MACAddress.str);
				//Record Host Name
				NuttyApp.Nutty.HostName = NuttyApp.Nutty.execute_sync_command(
					Constants.COMMAND_FOR_INTERFACES + " HOSTNAME"
				).replace("\n","").strip();
			}
        }
		info("[END] [FUNCTION:getConnectionsList]");
    }

	public static Gtk.TreeStore processMyInfo(string interfaceName, bool isDetailsRequired){
		info("[START] [FUNCTION:processMyInfo] [interfaceName="+interfaceName+",isDetailsRequired="+isDetailsRequired.to_string()+"]");
		NuttyApp.Nutty.info_list_store.clear();
		try{
			TreeIter iter;
			TreeIter iterSecondLevel;

			//Get info which does not require an Interface Name
			NuttyApp.Nutty.info_list_store.append (out iter, null);
			NuttyApp.Nutty.info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_HOSTNAME, 1, NuttyApp.Nutty.HostName);
			string[] interfaceDetails = Utils.multiExtractBetweenTwoStrings(
						NuttyApp.Nutty.execute_sync_command(
							Constants.COMMAND_FOR_INTERFACES + " INTERFACE_HARDWARE"
						).strip(),
						"Ethernet controller:", "\n"
			);
			int interfaceDetailsCounter = 0;
			foreach(string data in interfaceDetails){
				NuttyApp.Nutty.info_list_store.append (out iter, null);
				if(interfaceDetailsCounter ==0){
					NuttyApp.Nutty.info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_INTERFACE_HARDWARE, 1, data);
				} else {
					NuttyApp.Nutty.info_list_store.set (iter, 0, "", 1, data);
				}
				interfaceDetailsCounter++;
			}
			//Get simple info which requires an interface name
			if(interfaceName != null && interfaceName != "" && interfaceName.length > 0){
				NuttyApp.Nutty.info_list_store.append (out iter, null);
				if(NuttyApp.Nutty.interfaceMACMap.get(interfaceName.strip()).length > 0) {
					NuttyApp.Nutty.info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_MAC_ADDRESS, 1, NuttyApp.Nutty.interfaceMACMap.get(interfaceName.strip()));
				} else {
					NuttyApp.Nutty.info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_MAC_ADDRESS, 1, Constants.TEXT_FOR_NOT_AVAILABLE);
				}

				NuttyApp.Nutty.info_list_store.append (out iter, null);
				if(NuttyApp.Nutty.interfaceIPMap.get(interfaceName.strip()).length > 0) {
					NuttyApp.Nutty.info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_IP_ADDRESS, 1, NuttyApp.Nutty.interfaceIPMap.get(interfaceName.strip()));
				} else {
					NuttyApp.Nutty.info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_IP_ADDRESS, 1, Constants.TEXT_FOR_NOT_AVAILABLE);
				}

				NuttyApp.Nutty.info_list_store.append (out iter, null);
				if(NuttyApp.Nutty.interfaceIPV6Map.get(interfaceName.strip()).length > 0) {
					NuttyApp.Nutty.info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_IPV6_ADDRESS, 1, NuttyApp.Nutty.interfaceIPV6Map.get(interfaceName.strip()));
				} else {
					NuttyApp.Nutty.info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_IPV6_ADDRESS, 1, Constants.TEXT_FOR_NOT_AVAILABLE);
				}

				//run minimal interface command if the same has not been executed
				NuttyApp.Nutty.interfaceCommandOutputMinimal.assign(
        			NuttyApp.Nutty.execute_sync_command(
						Constants.COMMAND_FOR_INTERFACES + " STATE " + interfaceName
					).replace("\n","").strip()
				);
				NuttyApp.Nutty.info_list_store.append (out iter, null);
				NuttyApp.Nutty.info_list_store.set (iter, 0, Constants.TEXT_FOR_MYINFO_INTERFACE_STATE, 
														1, NuttyApp.Nutty.interfaceCommandOutputMinimal.str);
			}
			//Get simple wireless info which requires an interface name
			if(
				interfaceName != null && 
				interfaceName != "" && 
				interfaceName.length > 0 && 
				interfaceName.get_char(0) == 'w'
			){
				string iwconfigOutput = NuttyApp.Nutty.execute_sync_command(
						Constants.COMMAND_FOR_INTERFACES + " WIRELESS_CARD_DETAILS " + interfaceName
				);
				string frequencyAndChannel = NuttyApp.Nutty.execute_sync_command(
						Constants.COMMAND_FOR_INTERFACES + " WIRELESS_CARD_CHANNEL " + interfaceName
				);

				NuttyApp.Nutty.info_list_store.append (out iter, null);
				NuttyApp.Nutty.info_list_store.set (iter, 0, _("Network Card"), 1, Utils.extractBetweenTwoStrings(iwconfigOutput,interfaceName, "ESSID:").strip() + _(" Standards with Transmit Power of ") + Utils.extractBetweenTwoStrings(iwconfigOutput,"Tx-Power=", "Retry short limit:").strip() + _(" [Power Management: ") +Utils.extractBetweenTwoStrings(iwconfigOutput,"Power Management:", "Link Quality=").strip()+"]");

				NuttyApp.Nutty.info_list_store.append (out iter, null);
				NuttyApp.Nutty.info_list_store.set (iter, 0, _("Connected to"), 1, Utils.extractBetweenTwoStrings(iwconfigOutput,"ESSID:", "Mode:").replace("\"","").strip() + _(" Network at Access Point ") + Utils.extractBetweenTwoStrings(iwconfigOutput,"Access Point:", "Bit Rate=").strip() + "(MAC) in "+Utils.extractBetweenTwoStrings(iwconfigOutput,"Mode:", "Frequency:").strip()+_(" Mode"));

				NuttyApp.Nutty.info_list_store.append (out iter, null);
				NuttyApp.Nutty.info_list_store.set (iter, 0, _("Connected with"), 1, _("Frequency of ")+Utils.extractBetweenTwoStrings(frequencyAndChannel,"Current Frequency:", "\n").strip() + _(" and Bit Rate of ") + Utils.extractBetweenTwoStrings(iwconfigOutput,"Bit Rate=", "Tx-Power=").strip());

				NuttyApp.Nutty.info_list_store.append (out iter, null);
				NuttyApp.Nutty.info_list_store.set (iter, 0, _("Connection strength"), 1, _("Link Quality of ") + Utils.extractBetweenTwoStrings(iwconfigOutput,"Link Quality=", "Signal level=").strip() + _(" and Signal Level of ") + Utils.extractBetweenTwoStrings(iwconfigOutput,"Signal level=", "Rx invalid nwid:").strip());
			}

			//Get detailed info which requires an interface name
			if(interfaceName != null && interfaceName != "" && interfaceName.length > 0 && isDetailsRequired){
				//run detailed interface command if the same has not been executed
				if("" == NuttyApp.Nutty.interfaceCommandOutputDetailed.str){
					NuttyApp.Nutty.execute_sync_multiarg_command_pipes(
							{NuttyApp.Constants.COMMAND_FOR_INTERFACES, "INTERFACE_HARDWARE_DETAILED"}
					);
					NuttyApp.Nutty.interfaceCommandOutputDetailed.assign(NuttyApp.Nutty.spawn_async_with_pipes_output.str);
				}
				bool isNodeLeftToScan = true;
				int startPos = 0;
				int endPos = 0;
				StringBuilder interfaceNodeXML = new StringBuilder("");
				while (isNodeLeftToScan){
					startPos = NuttyApp.Nutty.interfaceCommandOutputDetailed.str.index_of("<node id=\"network\"",startPos+1);
					endPos = NuttyApp.Nutty.interfaceCommandOutputDetailed.str.index_of("</node>",startPos);
					if(startPos != -1 && endPos != -1 && endPos>startPos){ //xml Nodes found to process
						interfaceNodeXML.assign(NuttyApp.Nutty.interfaceCommandOutputDetailed.str.slice(startPos,endPos));
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
							interfaceNodeXML.assign(NuttyApp.Nutty.interfaceCommandOutputDetailed.str.slice(startPos,endPos));
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
					NuttyApp.Nutty.info_list_store.append (out iter, null);
					NuttyApp.Nutty.info_list_store.set (iter, 0, "NIC Info", -1);
					NuttyApp.Nutty.info_list_store.append (out iterSecondLevel, iter);
					NuttyApp.Nutty.info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_PRODUCT, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<product>", "</product>"));
					NuttyApp.Nutty.info_list_store.append (out iterSecondLevel, iter);
					NuttyApp.Nutty.info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_VENDOR, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<vendor>", "</vendor>"));
					NuttyApp.Nutty.info_list_store.append (out iterSecondLevel, iter);
					NuttyApp.Nutty.info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_PHYSICALID, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<physid>", "</physid>"));
					NuttyApp.Nutty.info_list_store.append (out iterSecondLevel, iter);
					NuttyApp.Nutty.info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_BUSINFO, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<businfo>", "</businfo>"));
					NuttyApp.Nutty.info_list_store.append (out iterSecondLevel, iter);
					NuttyApp.Nutty.info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_VERSION, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<version>", "</version>"));
					NuttyApp.Nutty.info_list_store.append (out iterSecondLevel, iter);
					NuttyApp.Nutty.info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_CAPACITY, 1, Utils.extractXMLTag(interfaceNodeXML.str,"<capacity>", "</capacity>"));
					NuttyApp.Nutty.info_list_store.append (out iterSecondLevel, iter);
					NuttyApp.Nutty.info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_BUSWIDTH, 1, Utils.extractXMLAttribute(interfaceNodeXML.str,"width", "units", "bits")+ " bits");
					NuttyApp.Nutty.info_list_store.append (out iterSecondLevel, iter);
					NuttyApp.Nutty.info_list_store.set (iterSecondLevel, 0, Constants.TEXT_FOR_MYINFO_CLOCKSPEED, 1, (int.parse(Utils.extractXMLAttribute(interfaceNodeXML.str,"clock", "units", "Hz"))/1000000).to_string()+ " MHz");

					Gee.HashMap<string,string> configurationDetails = Utils.extractTagAttributes(Utils.extractXMLTag(interfaceNodeXML.str,"<configuration>", "</configuration>"), "setting", "id", true);
					MapIterator<string,string> configurationIterator = configurationDetails.map_iterator ();
					NuttyApp.Nutty.info_list_store.append (out iter, null);
					NuttyApp.Nutty.info_list_store.set (iter, 0, "Configuration", -1);
					while(configurationIterator.has_next()) {
						configurationIterator.next();
						NuttyApp.Nutty.info_list_store.append (out iterSecondLevel, iter);
						NuttyApp.Nutty.info_list_store.set (iterSecondLevel, 0, configurationIterator.get_key(), 1, configurationIterator.get_value(),-1);
					}

					Gee.HashMap<string,string> capabilityDetails = Utils.extractTagAttributes(Utils.extractXMLTag(interfaceNodeXML.str,"<capabilities>", "</capabilities>"), "capability", "id", false);
					MapIterator<string,string> capabilityIterator = capabilityDetails.map_iterator ();
					NuttyApp.Nutty.info_list_store.append (out iter, null);
					NuttyApp.Nutty.info_list_store.set (iter, 0, "Capability", -1);
					while(capabilityIterator.has_next()) {
						capabilityIterator.next();
						NuttyApp.Nutty.info_list_store.append (out iterSecondLevel, iter);
						NuttyApp.Nutty.info_list_store.set (iterSecondLevel, 0, capabilityIterator.get_key(), 1, capabilityIterator.get_value(),-1);
					}

					Gee.HashMap<string,string> resourceDetails = Utils.extractTagAttributes(Utils.extractXMLTag(interfaceNodeXML.str,"<resources>", "</resources>"), "resource", "type", true);
					MapIterator<string,string> resourceIterator = resourceDetails.map_iterator ();
					NuttyApp.Nutty.info_list_store.append (out iter, null);
					NuttyApp.Nutty.info_list_store.set (iter, 0, "Resources", -1);
					while(resourceIterator.has_next()) {
						resourceIterator.next();
						NuttyApp.Nutty.info_list_store.append (out iterSecondLevel, iter);
						NuttyApp.Nutty.info_list_store.set (iterSecondLevel, 0, resourceIterator.get_key(), 1, resourceIterator.get_value(),-1);
					}
				}
				NuttyApp.Nutty.infoProcessSpinner.stop();
			}
		}catch(Error e){
			warning("Failure to process MyInfo:"+e.message);
		}
		info("[END] [FUNCTION:processMyInfo] [interfaceName="+interfaceName+",isDetailsRequired="+isDetailsRequired.to_string()+"]");
		return NuttyApp.Nutty.info_list_store;
	}
}
