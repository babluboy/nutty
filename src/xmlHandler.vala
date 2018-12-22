/* Copyright 2018 Siddhartha Das (bablu.boy@gmail.com)
*
* This file is part of Nutty and handles all xml related parsing
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

using Xml;
using Gee;

    ArrayList<NuttyApp.Entities.Device> listOfScanedDevices;
    string mode;
    bool isContainerTagMatched = false;
    bool shouldExtractionStart = false;
    int noOfTagsMatched = 0;
    string currentTagName;
    StringBuilder charBuffer;
    NuttyApp.Entities.Device aDevice;

public class NuttyApp.XmlParser {

    public XmlParser(){
        mode = "";
        currentTagName = "";
        charBuffer = new StringBuilder("");
    }

    public ArrayList<NuttyApp.Entities.Device> extractDeviceDataFromXML (string path){
        //path = "/home/sid/Downloads/nutty_nmap_device_scan_results.xml";
        info("[START] [FUNCTION:extractDataFromXML] extracting xml from file="+path);
        listOfScanedDevices = new ArrayList<NuttyApp.Entities.Device> ();
        mode = "DEVICE_SCAN";
        parseXML(path);
        info("[END] [FUNCTION:extractDataFromXML] extracting xml from file="+path);
        return listOfScanedDevices;
    }

    public void parseXML(string path) {
        Parser.init();
        var handler = SAXHandler();
        void* user_data = null;

        handler.startElement = start_element;
        handler.characters = get_text;
        handler.endElement = end_element;

        handler.user_parse_file(user_data, path);
        Parser.cleanup();
    }

    public void start_element(string name, string[] attributeList) {
        debug(">>>>>Start Tag:"+name);
        currentTagName = process_tagname(name);
        if("DEVICE_SCAN" == mode) {        
            //If Start element matches "host" - set container flag to true 
            if("host" == currentTagName) {
                isContainerTagMatched = true;
                aDevice = new NuttyApp.Entities.Device();
            }
            if("address" == currentTagName){
                noOfTagsMatched++;
            }

            //Check if the tag name matches the input tag name
            if(isContainerTagMatched && (currentTagName == "address" || currentTagName == "hostname")) {
                //Check if container tag has been matched and the tag is required - set extraction flag to true
                shouldExtractionStart = true;
                charBuffer.assign("");
            }

            //If Extraction criteria is met and attribute extraction is required, extract required attribute
            if(shouldExtractionStart && ("address" == currentTagName) ) { //check whether attributes need to be extracted 
                if(attributeList.length >1 && noOfTagsMatched == 1) {
                    aDevice.device_ip = attributeList[1]; 
                }
                if(attributeList.length >3 && noOfTagsMatched == 2) {
                    aDevice.device_mac = attributeList[1];
                    aDevice.device_manufacturer = attributeList[5];
                }
            }
            if(shouldExtractionStart && ("hostname" == currentTagName) ) {
                 if(attributeList.length >1) {
                    aDevice.device_hostname = attributeList[1];
                }
            }
        }
    }

    public void end_element(string name) {
        debug("<<<<<End Tag:"+name);        
        string processed_name = process_tagname(name);
        //If End element matches container tag - set container flag to false and extraction flag to false
        if("host" == processed_name) {
            isContainerTagMatched = false;
            noOfTagsMatched = 0;
            listOfScanedDevices.add(aDevice);
            debug("Device extracted from NMap XML:"+aDevice.to_string());
        }
    }
 
    public void get_text (string chars, int len){
        //debug("......TagData:"+chars);
        if(shouldExtractionStart ) {
            charBuffer.append(chars.slice(0, len));
        }
    }

    public string process_tagname (string tagname){
        string local_tagname = tagname.strip();
        if(local_tagname.index_of(":") != -1){
            local_tagname = local_tagname.slice(local_tagname.index_of(":")+1, local_tagname.length);
        }
        return local_tagname;
    }
}

//valac --pkg libxml-2.0 --pkg gee-0.8 xmlHandler.vala
