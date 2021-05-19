/* Copyright 2018 Siddhartha Das (bablu.boy@gmail.com)
*
* This file is part of Nutty and manages all the Database interactions
*
* Bookworm is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Bookworm is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Bookworm. If not, see http://www.gnu.org/licenses/.
*/

using Sqlite;
using Gee;

public class NuttyApp.DB{
    public const string NUTTY_DEVICES_TABLE_BASE_NAME = "NUTTY_DEVICES_TABLE";
    public const string NUTTY_DEVICES_TABLE_VERSION = "1"; //Only integers allowed

    private static Sqlite.Database nuttyDB;
    private static string errmsg;
    private static string queryString;
    private static int executionStatus;
    private static int resultCount;

    public static bool initializeNuttyDB(string config_path){
        info("[START] [FUNCTION:initializeNuttyDB] db_config_path="+config_path);
        debug("Checking Nutty DB or creating it if the DB does not exist...");
        int dbOpenStatus = Database.open_v2 ( config_path+"/nutty.db",
                                                                                out nuttyDB,
                                                                                Sqlite.OPEN_READWRITE | Sqlite.OPEN_CREATE);
        if (dbOpenStatus != Sqlite.OK) {
            warning ("Error in opening database["+config_path+"/nutty.db"+"]: %d: %s\n",
                                            nuttyDB.errcode (), nuttyDB.errmsg ()
            );
            return false;
        } else {
            debug ("Successfully checked/created DB for Nutty.....");
        }

        debug ("Creating latest version for NUTTY_DEVICES_TABLE table if it does not exists");
        queryString = "CREATE TABLE IF NOT EXISTS "+NUTTY_DEVICES_TABLE_BASE_NAME
                   +NUTTY_DEVICES_TABLE_VERSION+" ("
                   + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                   + "DEVICE_IP TEXT NOT NULL DEFAULT '', "
                   + "DEVICE_MAC TEXT NOT NULL DEFAULT '', "
                   + "DEVICE_HOST_NAME TEXT NOT NULL DEFAULT '', "
                   + "DEVICE_HOST_MANUFACTURER TEXT NOT NULL DEFAULT '', "
                   + "DEVICE_HOST_NAME_CUSTOM TEXT NOT NULL DEFAULT '', "
                   + "DEVICE_HOST_MANUFACTURER_CUSTOM TEXT NOT NULL DEFAULT '', "
                   + "IS_ALERT_COMPLETED TEXT NOT NULL DEFAULT '', "
                   + "DEVICE_STATUS TEXT NOT NULL DEFAULT '', "
                   + "creation_date INTEGER,"
                   + "last_seen_date INTEGER,"
                   + "modification_date INTEGER)";
		executionStatus = nuttyDB.exec (queryString, null, out errmsg);
	 	if (executionStatus != Sqlite.OK) {
            debug("Error on executing Query:"+queryString);
	 		warning ("Error details: %s\n", errmsg);
            return false;
	 	} else {
            debug("Successfully checked/created table:"+NUTTY_DEVICES_TABLE_BASE_NAME+NUTTY_DEVICES_TABLE_VERSION);
        }

        //load data from device file into table and then remove device file
        if("true" == NuttyApp.Utils.fileOperations("EXISTS",
                                                                                GLib.Environment.get_user_config_dir ()+"/nutty",
                                                                                Constants.nutty_devices_property_file_name, ""))
        {
            debug("[START] Started loading device data from props file to DB");
            //read data from props file
            string devicesDataFromProps = NuttyApp.Utils.fileOperations("READ",
                                                                                    config_path,
                                                                                    Constants.nutty_devices_property_file_name,
                                                                                     ""
                                                                     );
            string[] devicesList = devicesDataFromProps.split (NuttyApp.Constants.IDENTIFIER_FOR_PROPERTY_END, 0);
            foreach(string aDeviceData in devicesList){
                aDeviceData = aDeviceData.replace(NuttyApp.Constants.IDENTIFIER_FOR_PROPERTY_START,"");
                string[] deviceAttributesList = aDeviceData.split(NuttyApp.Constants.IDENTIFIER_FOR_PROPERTY_VALUE, 0);
                if(deviceAttributesList.length == 7){
                    NuttyApp.Entities.Device aDevice = new NuttyApp.Entities.Device();
                    aDevice.device_ip = deviceAttributesList[0];
                    aDevice.device_mac = deviceAttributesList[1];
                    aDevice.device_manufacturer = deviceAttributesList[2];
                    aDevice.device_manufacturer_custom = deviceAttributesList[2];
                    aDevice.device_hostname = deviceAttributesList[3];
                    aDevice.device_hostname_custom = deviceAttributesList[3];
                    aDevice.device_creation_date = NuttyApp.Utils.getDateFromString(deviceAttributesList[4]).to_unix().to_string();
                    aDevice.device_last_seen_date = aDevice.device_creation_date;
                    aDevice.device_alert = NuttyApp.Constants.DEVICE_ALERT_COMPLETED; //deviceAttributesList[5]; Assumes all devices are alerted
                    aDevice.device_status = deviceAttributesList[6];
                    addDeviceToDB(aDevice);
                }
            }
            debug("[END] Completed loading device data from props file to DB");
        }
        //remove the devices props
        NuttyApp.Utils.fileOperations("DELETE", config_path, Constants.nutty_devices_property_file_name, "");
        //All DB loading operations completed
        info("[END] [FUNCTION:initializeBookWormDB]");
        return true;
    }

    public static int addDeviceToDB(NuttyApp.Entities.Device aDevice){
        Sqlite.Statement stmt = null;
        bool isDevicePresent = false;
        string whereClauseForDeviceCheck = "";

        //avoid adding loopback devices
        if(aDevice.device_ip.contains ("127.0.0")){
            return 0;
        }

        //Form the where clause on the basis of MAC and IP of the device
        if(aDevice.device_mac != null && aDevice.device_mac.length>0 && aDevice.device_mac.strip() != ""){
            if(aDevice.device_ip != null && aDevice.device_ip.length>0 && aDevice.device_ip.strip() != ""){
                //Both IP and MAC are present
                whereClauseForDeviceCheck = " WHERE DEVICE_IP=\'"+aDevice.device_ip+
                                                                          "\' AND DEVICE_MAC=\'"+aDevice.device_mac+"\'";
            }else{
                //IP is absent but MAC is present
                whereClauseForDeviceCheck = " WHERE DEVICE_MAC=\'"+aDevice.device_mac+"\'";
            }
        }else{
             if(aDevice.device_ip != null && aDevice.device_ip.length>0 && aDevice.device_ip.strip() != ""){
                //MAC is absent but IP is present
                whereClauseForDeviceCheck = " WHERE DEVICE_IP=\'"+aDevice.device_ip+"\'";
            }else{
                //Both IP and MAC are not present - the device should be added. make the where clause random
                whereClauseForDeviceCheck = " WHERE DEVICE_IP=\'ABC\'  AND DEVICE_MAC=\'123\'";    
            }   
        }
        //Check if the device is present in the DB based on MAC and/or IP
        queryString = "SELECT " +
                            "DEVICE_IP, " +
                            "DEVICE_MAC, " +
                            "DEVICE_HOST_MANUFACTURER, " +
                            "DEVICE_HOST_NAME, " +
                            "DEVICE_HOST_MANUFACTURER_CUSTOM, " +
                            "DEVICE_HOST_NAME_CUSTOM, " +
                            "IS_ALERT_COMPLETED, " +
                            "DEVICE_STATUS " +
                        "FROM " + NUTTY_DEVICES_TABLE_BASE_NAME+NUTTY_DEVICES_TABLE_VERSION +
                        whereClauseForDeviceCheck;
        executionStatus = nuttyDB.prepare_v2 (queryString, queryString.length, out stmt);
        if (executionStatus != Sqlite.OK) {
            debug("Error on executing Query:"+queryString);
            warning ("Error details: %d: %s\n", nuttyDB.errcode (), nuttyDB.errmsg ());
            return -1;
        }

        while (stmt.step () == ROW) {
            isDevicePresent = true; //Device is already present
            if(aDevice.device_ip == null || aDevice.device_ip == ""){
                aDevice.device_ip = stmt.column_text(0);
            }
            if(aDevice.device_mac == null || aDevice.device_mac == ""){
                aDevice.device_mac = stmt.column_text(1);
            }
            if(aDevice.device_manufacturer == null || aDevice.device_manufacturer == ""){
                aDevice.device_manufacturer = stmt.column_text(2);
            }
            if(aDevice.device_hostname == null || aDevice.device_hostname == ""){
                aDevice.device_hostname = stmt.column_text(3);
            }
            if(aDevice.device_manufacturer_custom == null || aDevice.device_manufacturer_custom == ""){
                aDevice.device_manufacturer_custom = stmt.column_text(4);
            }
            if(aDevice.device_hostname_custom == null || aDevice.device_hostname_custom == ""){
                aDevice.device_hostname_custom = stmt.column_text(5);
            }
            if(aDevice.device_alert == null || aDevice.device_alert == ""){
                aDevice.device_alert = stmt.column_text(6);
            }
            if(aDevice.device_status == null || aDevice.device_status == ""){
                aDevice.device_status = stmt.column_text(7);
            }
            debug("Device is present in DB based on the WHERE clause: " + whereClauseForDeviceCheck);
            break;
        }
        stmt.reset ();

        if(isDevicePresent){ //device present, update device table
            debug("Found device [DEVICE_IP=\'"+aDevice.device_ip+
                        "\' OR DEVICE_MAC=\'"+aDevice.device_mac+
                        "\'] in table, device details will be updated");
            queryString = "UPDATE "+NUTTY_DEVICES_TABLE_BASE_NAME+NUTTY_DEVICES_TABLE_VERSION + " " + 
                                    "SET DEVICE_IP = ?, " +
                                    "DEVICE_MAC = ?, " + 
                                    "DEVICE_HOST_MANUFACTURER = ?, " +
                                    "DEVICE_HOST_NAME = ?, " +
                                    "DEVICE_HOST_MANUFACTURER_CUSTOM = ?, " +
                                    "DEVICE_HOST_NAME_CUSTOM = ?, " +
                                    "IS_ALERT_COMPLETED = ?, " +
                                    "DEVICE_STATUS = ?, " +
                                    "last_seen_date = CAST(strftime('%s', 'now') AS INT),  " +
                                    "modification_date = CAST(strftime('%s', 'now') AS INT) " +
                                    "WHERE DEVICE_IP=\'"+aDevice.device_ip+"\' AND DEVICE_MAC=\'"+aDevice.device_mac+"\'";
            executionStatus = nuttyDB.prepare_v2 (queryString, queryString.length, out stmt);
            if (executionStatus != Sqlite.OK) {
                debug("Error on executing Query:"+queryString);
                warning ("Error details: %d: %s\n", nuttyDB.errcode (), nuttyDB.errmsg ());
                return -1;
            }
            stmt.bind_text (1, aDevice.device_ip);
            stmt.bind_text (2, aDevice.device_mac);
            stmt.bind_text (3, aDevice.device_manufacturer);
            stmt.bind_text (4, aDevice.device_hostname);
            stmt.bind_text (5, aDevice.device_manufacturer_custom);
            stmt.bind_text (6, aDevice.device_hostname_custom);
            stmt.bind_text (7, aDevice.device_alert);
            stmt.bind_text (8, aDevice.device_status);

            stmt.step ();
            stmt.reset ();
        } else { //device not present, add to device table
            debug("Did not find device [DEVICE_IP=\'"+aDevice.device_ip+
                        "\' OR DEVICE_MAC=\'"+aDevice.device_mac+
                        "\'] in table, device with following details will be inserted : "+
                        aDevice.to_string()
            );
            queryString = "INSERT INTO "+NUTTY_DEVICES_TABLE_BASE_NAME+NUTTY_DEVICES_TABLE_VERSION +
                            "( DEVICE_IP, " +
                              "DEVICE_MAC, " +
                              "DEVICE_HOST_MANUFACTURER, " +
                              "DEVICE_HOST_NAME, " +
                              "DEVICE_HOST_MANUFACTURER_CUSTOM, " +
                              "DEVICE_HOST_NAME_CUSTOM, " +
                              "IS_ALERT_COMPLETED, " +
                              "DEVICE_STATUS, " +
                              "creation_date, " +
                              "last_seen_date, " +
                              "modification_date) " +
                            "VALUES (?,?,?,?,?,?,?,?,?,CAST(? AS INT),CAST(strftime('%s', 'now') AS INT))";
            executionStatus = nuttyDB.prepare_v2 (queryString, queryString.length, out stmt);
            if (executionStatus != Sqlite.OK) {
                debug("Error on executing Query:"+queryString);
                warning ("Error details: %d: %s\n", nuttyDB.errcode (), nuttyDB.errmsg ());
                return -1;
            }

            if(aDevice.device_ip != null && aDevice.device_ip.length > 0){
                stmt.bind_text (1, aDevice.device_ip);
            }else{
                stmt.bind_text (1, NuttyApp.Constants.TEXT_FOR_NOT_AVAILABLE);
            }
            if(aDevice.device_mac != null && aDevice.device_mac.length > 0){
                stmt.bind_text (2, aDevice.device_mac);
            }else{
                stmt.bind_text (2, NuttyApp.Constants.TEXT_FOR_NOT_AVAILABLE);
            }
            if(aDevice.device_manufacturer != null && aDevice.device_manufacturer.length > 0){
                stmt.bind_text (3, aDevice.device_manufacturer);
            }else{
                stmt.bind_text (3, NuttyApp.Constants.TEXT_FOR_NOT_AVAILABLE);
            }
            if(aDevice.device_hostname != null && aDevice.device_hostname.length > 0){
                stmt.bind_text (4, aDevice.device_hostname);
            }else{
                stmt.bind_text (4, NuttyApp.Constants.TEXT_FOR_NOT_AVAILABLE);
            }
            if(aDevice.device_manufacturer_custom != null && aDevice.device_manufacturer_custom.length > 0){
                stmt.bind_text (5, aDevice.device_manufacturer_custom);
            }else{
                if(aDevice.device_manufacturer != null && aDevice.device_manufacturer.length > 0){
                    stmt.bind_text (5, aDevice.device_manufacturer);
                }else{
                    stmt.bind_text (5, NuttyApp.Constants.TEXT_FOR_NOT_AVAILABLE);
                } 
            }
            if(aDevice.device_hostname_custom !=null && aDevice.device_hostname_custom.length > 0){
                stmt.bind_text (6, aDevice.device_hostname_custom);
            }else{
                 if(aDevice.device_hostname != null && aDevice.device_hostname.length > 0){
                    stmt.bind_text (6, aDevice.device_hostname);
                }else{
                    stmt.bind_text (6, NuttyApp.Constants.TEXT_FOR_NOT_AVAILABLE);
                } 
            }
            stmt.bind_text (7, aDevice.device_alert);
            stmt.bind_text (8, aDevice.device_status);
            if(aDevice.device_creation_date != ""){
                stmt.bind_text (9, aDevice.device_creation_date);
            }else{
                stmt.bind_text (9, NuttyApp.Utils.getDateFromString("").to_unix().to_string());
            }
            if(aDevice.device_last_seen_date != ""){
                stmt.bind_text (10, aDevice.device_last_seen_date);
            }else{
                 stmt.bind_text (10, NuttyApp.Utils.getDateFromString("").to_unix().to_string());
            }
            resultCount = stmt.step ();
            debug("Insertion done for Device [IP="+aDevice.device_ip+"] with insert row count="+resultCount.to_string());
            stmt.reset ();
        }
        return 0;
    }

    public static ArrayList<NuttyApp.Entities.Device> getDevicesFromDB(){
        info("[START] [FUNCTION:getDevicesFromDB]");
        ArrayList<NuttyApp.Entities.Device> listOfDevices = new ArrayList<NuttyApp.Entities.Device> ();
        Statement stmt;
        queryString = "SELECT " +
                        "id, " + 
                        "DEVICE_IP, " + 
                        "DEVICE_MAC, " + 
                        "DEVICE_HOST_NAME, " + 
                        "DEVICE_HOST_MANUFACTURER, " + 
                        "DEVICE_HOST_NAME_CUSTOM, " + 
                        "DEVICE_HOST_MANUFACTURER_CUSTOM, " + 
                        "IS_ALERT_COMPLETED, " + 
                        "DEVICE_STATUS, " + 
                        "creation_date, " + 
                        "last_seen_date, " +
                        "modification_date " + 
                    " FROM " + NUTTY_DEVICES_TABLE_BASE_NAME+NUTTY_DEVICES_TABLE_VERSION +
                    " ORDER BY modification_date DESC";
        executionStatus = nuttyDB.prepare_v2 (queryString, queryString.length, out stmt);
        if (executionStatus != Sqlite.OK) {
            debug("Error on executing Query:"+queryString);
	 		warning ("Error details: %d: %s\n", nuttyDB.errcode (), nuttyDB.errmsg ());
	    }else{
            while (stmt.step () == ROW) {
                NuttyApp.Entities.Device aDevice = new NuttyApp.Entities.Device();
                aDevice.device_id = stmt.column_int(0);
                aDevice.device_ip = stmt.column_text (1);
                aDevice.device_mac = stmt.column_text (2);
                aDevice.device_hostname = stmt.column_text (3);
                aDevice.device_manufacturer = stmt.column_text (4);
                aDevice.device_hostname_custom = stmt.column_text (5);
                aDevice.device_manufacturer_custom = stmt.column_text(6);
                aDevice.device_alert = stmt.column_text (7);
                aDevice.device_status = stmt.column_text (8);
                aDevice.device_creation_date = stmt.column_text (9);
                aDevice.device_last_seen_date = stmt.column_text(10);

                debug(
                    "Device details fetched from DB: id="+ aDevice.device_id.to_string()+ 
                    ",DEVICE_IP="+aDevice.device_ip+
                    ",DEVICE_MAC="+aDevice.device_mac+
                    ",DEVICE_HOST_NAME="+aDevice.device_hostname+
                    ",DEVICE_HOST_MANUFACTURER="+aDevice.device_manufacturer+
                    ",DEVICE_HOST_NAME_CUSTOM="+aDevice.device_hostname_custom+
                    ",DEVICE_HOST_MANUFACTURER_CUSTOM="+aDevice.device_manufacturer_custom+
                    ",IS_ALERT_COMPLETED="+aDevice.device_alert+
                    ",DEVICE_STATUS="+aDevice.device_status+
                    ",creation_date="+aDevice.device_creation_date+
                    ",last_seen_date="+aDevice.device_last_seen_date
                );
                //add book details to list
                listOfDevices.add(aDevice);
            }
            stmt.reset ();
        }
        info("[END] [FUNCTION:getDevicesFromDB] listOfDevices.size="+listOfDevices.size.to_string());
        return listOfDevices;
    }

    public static bool removeDeviceFromDB(NuttyApp.Entities.Device aDevice){
        info("[START] [FUNCTION:removeDeviceFromDB] IP="+aDevice.device_ip + ", MAC="+aDevice.device_mac);
        Sqlite.Statement stmt;
        //delete device from device table
        queryString = "DELETE FROM "+NUTTY_DEVICES_TABLE_BASE_NAME+NUTTY_DEVICES_TABLE_VERSION+
                                 " WHERE DEVICE_IP = ? AND DEVICE_MAC = ?";
        executionStatus = nuttyDB.prepare_v2 (queryString, queryString.length, out stmt);
        if (executionStatus != Sqlite.OK) {
          debug("Error on executing Query:"+queryString);
          warning ("Error details: %d: %s\n", nuttyDB.errcode (), nuttyDB.errmsg ());
          return false;
        }else{
            stmt.bind_text (1, aDevice.device_ip);
            stmt.bind_text (2, aDevice.device_mac);
            stmt.step ();
            stmt.reset ();
            debug("Removed this device from device table: IP=" + aDevice.device_ip+", MAC=" + aDevice.device_mac);
        }
        info("[END] [FUNCTION:removeDeviceFromDB] IP=" + aDevice.device_ip + ", MAC=" + aDevice.device_mac);
        return true;
    }
}
