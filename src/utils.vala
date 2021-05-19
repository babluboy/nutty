/* Copyright 2016 Siddhartha Das (bablu.boy@gmail.com)
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

using Gee;
namespace NuttyApp.Utils{
	public string last_file_chooser_path = null;
		
	public string extractBetweenTwoStrings(string stringToBeSearched, string startString, string endString) throws Error{
        string extractedString = "";
        int positionOfStartStringInData = stringToBeSearched.index_of(startString,0);
		if(positionOfStartStringInData > -1){
			int positionOfEndOfStartString = positionOfStartStringInData+(startString.char_count(-1));
			int positionOfStartOfEndString = stringToBeSearched.index_of(endString,(positionOfEndOfStartString+1));
			if(positionOfStartOfEndString > -1)
				extractedString = stringToBeSearched.substring(positionOfEndOfStartString,(positionOfStartOfEndString - positionOfEndOfStartString)).strip();
		}else{
			extractedString = Constants.TEXT_FOR_NOT_AVAILABLE;
		}
		return extractedString;
    }
    
    public string[] multiExtractBetweenTwoStrings(string stringToBeSearched, string startString, string endString){
        string[] results = new string[0];
        try{
			string taggedInput = stringToBeSearched.replace(startString, "#~#~#~#~#~#~#~#~#"+startString);
			string[] occurencesOfStartString = taggedInput.split("#~#~#~#~#~#~#~#~#", -1);
			StringBuilder searchResult = new StringBuilder();
			foreach(string splitString in occurencesOfStartString){
				searchResult.assign(extractBetweenTwoStrings(splitString,startString,endString));
				if(searchResult.str != Constants.TEXT_FOR_NOT_AVAILABLE)
					results+= searchResult.str;
			}
		}catch(Error e){
			warning("Failure in utility multi extract between strings:"+e.message);
		}
        return results;
    }
    
    public string[] getListOfRepeatingSegments(string data, string repeatingIdentifier) throws Error{
		string[] segments = {""};
		string currentSegment = "";
		int positionCurrentSegment = data.index_of(repeatingIdentifier);
		int positionOfNextSegment = 0;
		bool isSegmentsRemaning = true;
		if(positionCurrentSegment != -1){
			while(isSegmentsRemaning){
				positionOfNextSegment = data.index_of(repeatingIdentifier, positionCurrentSegment+1);
				if(positionOfNextSegment != -1){
					currentSegment = data.substring(positionCurrentSegment, (positionOfNextSegment-positionCurrentSegment));
					segments+= currentSegment;
					data.splice(positionCurrentSegment, positionOfNextSegment,"");
					positionCurrentSegment = positionOfNextSegment;
				}else{
					segments+= data.substring(positionCurrentSegment);
					isSegmentsRemaning = false;
				}
			}
		}else{
			segments = {Constants.TEXT_FOR_NOT_AVAILABLE};
		}
		return segments;
	}
	
	public Gee.ArrayList<Gee.ArrayList<string>> convertMultiLinesToTableArray(string dataForList, int noOfColumns, string columnToken) throws Error{
		Gee.ArrayList<ArrayList<string>> rowsData = new Gee.ArrayList<Gee.ArrayList<string>>();
		string[] individualLines = dataForList.strip().split ("\n",-1); //split the multiline string lines into individual lines
		foreach(string line in individualLines){
			string[] valuesInALine = line.strip().split (columnToken,-1); //split the individual line into values based on a token
			Gee.ArrayList<string> columnsData = new Gee.ArrayList<string> ();
			for(int count=0; count < noOfColumns; count++){
				if(count <= valuesInALine.length && valuesInALine[count] != null){
					columnsData.add(valuesInALine[count].strip());
				}else{
					columnsData.add(" "); // set an empty space if no values are available for the column
				}
			}
			rowsData.add(columnsData);
		}
		return rowsData;
	}
	
	public string extractXMLTag(string xmlData, string startTag, string endTag) throws Error{
		string extractedData = "";
		if(xmlData.contains(startTag) && xmlData.contains(endTag)){
			extractedData = xmlData.slice(xmlData.index_of(startTag)+startTag.length, xmlData.index_of(endTag));
		}
		return extractedData;
	}
	
	public string extractXMLAttribute (string xmlData, string tagName, string attributeID, string attributeName) throws Error{
		string extractedData = "";
		int startPos = -1;
		int endPos = -1;
		//find the first occurrence of the required xml tag
		if(xmlData.contains("<"+tagName) && xmlData.contains(attributeID+"=\""+attributeName+"\"")){
			//extract the data in the xml tag
			string tagData = xmlData.slice(xmlData.index_of("<"+tagName), xmlData.index_of(">",xmlData.index_of("<"+tagName)+1));
			if(tagData.down().contains("value")){
				startPos = xmlData.index_of("value=\"", xmlData.index_of(attributeID+"=\""+attributeName+"\""))+7;
				endPos = xmlData.index_of("\"", startPos);
			}else{
				startPos = xmlData.index_of(">", xmlData.index_of("<"+tagName))+1;
				endPos = xmlData.index_of("</"+tagName+">", xmlData.index_of("<"+tagName));
			}
			if(startPos != -1 && endPos != -1 && endPos>startPos){
				extractedData = xmlData.slice(startPos, endPos);
			}
		}
		return extractedData;
	}
	
	public Gee.HashMap<string,string> extractTagAttributes (string xmlData, string tagName, string attributeID, bool doesAttributeValueExists) throws Error{
		Gee.HashMap<string,string> AttributeMap = new HashMap <string,string>();
		int positionOfStartTag = 0;
		int positionOfEndTag = 0;
		int positionOfStartAttributeValue = 0;
		int positionOfEndAttributeValue = 0;
		int positionOfStartTagValue = 0;
		int positionOfEndTagValue = 0;
		string qualifiedTagName = "<"+tagName;
		string qualifiedAttributeID = attributeID+"=\"";
		StringBuilder attributeValue = new StringBuilder("");
		StringBuilder tagValue = new StringBuilder("");
		
		while(positionOfStartTag != -1){
			positionOfStartTag = xmlData.index_of(qualifiedTagName, positionOfStartTag);
			if(doesAttributeValueExists){
				positionOfEndTag = xmlData.index_of("/>", positionOfStartTag);
			}else{
				positionOfEndTag = xmlData.index_of(">", positionOfStartTag);
			}
			
			if(positionOfEndTag > positionOfStartTag){
				positionOfStartAttributeValue = xmlData.index_of(qualifiedAttributeID, positionOfStartTag);
				positionOfEndAttributeValue = xmlData.index_of("\"", positionOfStartAttributeValue+qualifiedAttributeID.length);
				if(positionOfStartAttributeValue!=-1 && positionOfEndAttributeValue!=-1 && positionOfEndAttributeValue>positionOfStartAttributeValue){
					attributeValue.assign(xmlData.slice(positionOfStartAttributeValue+qualifiedAttributeID.length,positionOfEndAttributeValue));
				}else{
					attributeValue.assign("");
				}
				if(doesAttributeValueExists){
					positionOfStartTagValue = xmlData.index_of("value=\"",positionOfStartTag);
					positionOfEndTagValue = xmlData.index_of("\"",positionOfStartTagValue+"value=\"".length);
					if(positionOfStartTagValue!=-1 && positionOfEndTagValue!=-1 && positionOfEndTagValue>positionOfStartTagValue){
						tagValue.assign(xmlData.slice(positionOfStartTagValue+"value=\"".length, positionOfEndTagValue));
					}else{
						tagValue.assign("");
					}
					
					if(attributeValue.str != ""){
						AttributeMap.set(attributeValue.str,tagValue.str);
					}
				}else{
					positionOfStartTagValue = xmlData.index_of(">",positionOfStartTag);
					positionOfEndTagValue = xmlData.index_of("</",positionOfStartTagValue+1);
					if(positionOfStartTagValue!=-1 && positionOfEndTagValue!=-1 && positionOfEndTagValue>positionOfStartTagValue){
						tagValue.assign(xmlData.slice(positionOfStartTagValue+1, positionOfEndTagValue));
					}else{
						tagValue.assign("");
					}
					if(attributeValue.str != ""){
						if(!(tagValue.str.contains("<") || tagValue.str.contains(">")))
							AttributeMap.set(attributeValue.str,tagValue.str);
					}
				}
			}
			positionOfStartTag = positionOfEndTag;
		}
		return AttributeMap;
	}
	
	public string extractNestedXMLAttribute(string xmlData, string startTag, string endTag, int nestCount) throws Error{
		string extractedData = "";
		StringBuilder xmlDataBuffer = new StringBuilder(xmlData);
		int positionOfStartTag = xmlData.index_of(startTag);
		if(positionOfStartTag != -1)
			xmlDataBuffer.assign(xmlData.slice(positionOfStartTag, -1));
		positionOfStartTag = xmlDataBuffer.str.index_of(startTag);
		int positionOfEngTag = 0;
		for(int count=0; count < nestCount; count++){
			positionOfEngTag = xmlDataBuffer.str.index_of(endTag, positionOfStartTag+positionOfEngTag+1);
		}
		if(positionOfStartTag != -1 && positionOfEngTag != -1 && positionOfEngTag>positionOfStartTag+startTag.length){
			extractedData = xmlDataBuffer.str.slice(positionOfStartTag+startTag.length, positionOfEngTag);
		}
		return extractedData;
	}
	
	public string convertKiloByteToHigherUnit (string kilobyteVal) throws Error{
		char[] buffer = new char[10];
		//convert to KB
		double KBValue = double.parse(kilobyteVal);
		if(KBValue < 1024){
			return kilobyteVal+" KB";
		}else{
			//convert to MB
			double MBValue = KBValue/1024;
			if(MBValue < 1024){
				return MBValue.format(buffer,"%.2f") +" MB";
			}else{
				//convert to GB
				double GBValue = MBValue/1024;
				if(GBValue < 1){
					return MBValue.format(buffer,"%.2f") +" MB";
				}else{
					return GBValue.format(buffer,"%.2f") +" GB";
				}
			}
		}
	}
	
	// Create a GtkFileChooserDialog to perform the action desired
    public Gtk.FileChooserDialog new_file_chooser_dialog (Gtk.FileChooserAction action, string title, Gtk.Window? parent, bool select_multiple = false) {
        Gtk.FileChooserDialog aFileChooserDialog = new Gtk.FileChooserDialog (title, parent, action);
        aFileChooserDialog.set_select_multiple (select_multiple);
        aFileChooserDialog.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        if (action == Gtk.FileChooserAction.OPEN)
            aFileChooserDialog.add_button (_("Open"), Gtk.ResponseType.ACCEPT);
        else{
            aFileChooserDialog.add_button (_("Save"), Gtk.ResponseType.ACCEPT);
            aFileChooserDialog.set_current_name("Nutty_Export_" + new DateTime.now_local().to_string() + ".csv");
		}
        aFileChooserDialog.set_default_response (Gtk.ResponseType.ACCEPT);
        if(last_file_chooser_path != null){
			aFileChooserDialog.set_current_folder (last_file_chooser_path);
		}else{
			aFileChooserDialog.set_current_folder (GLib.Environment.get_home_dir ());
		}
        aFileChooserDialog.key_press_event.connect ((ev) => {
            if (ev.keyval == 65307) // Esc key
                aFileChooserDialog.destroy ();
            return false;
        });
        var all_files_filter = new Gtk.FileFilter ();
        all_files_filter.set_filter_name (_("All files"));
        all_files_filter.add_pattern ("*");
        var text_files_filter = new Gtk.FileFilter ();
        text_files_filter.set_filter_name (_("Text files"));
        text_files_filter.add_mime_type ("text/*");
        aFileChooserDialog.add_filter (all_files_filter);
        aFileChooserDialog.add_filter (text_files_filter);
        aFileChooserDialog.set_filter (text_files_filter);
        return aFileChooserDialog;
    }

	public static string fileOperations (string operation, string path, string filename, string contents) {
		debug("Started file operation["+operation+"], for path="+path+", filename="+filename);
		StringBuilder result = new StringBuilder("false");
		string data = "";
		File fileDir = null;
		File file = null;
		try{
			if(path != null || path.length > 1){
				fileDir = File.new_for_commandline_arg(path);
			}
			if(filename != null && filename.length > 1){
				file = File.new_for_path(path+"/"+filename);
			}else{
				file = File.new_for_path(path);
			}
			if("CREATEDIR" == operation){
				//check if directory does not exists
				if(!fileDir.query_exists ()){
					//create the directory
					fileDir.make_directory();
					result.assign("true");
					//close and release the file
					FileUtils.close(new IOChannel.file(path, "r").unix_get_fd());
					debug("Directory created:"+fileDir.get_path());
				}else{
					//do nothing
					result.assign("true");
				}
			}
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
						string dataBeforeProp = result.str.split(Constants.IDENTIFIER_FOR_PROPERTY_START+
																   contents.split(Constants.IDENTIFIER_FOR_PROPERTY_VALUE,2)[0],2)[0];
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
				}else{
					result.assign("false");
				}
			}
			if("READ_FILE" == operation){
				bool wasRead = FileUtils.get_contents(path, out data);
				if(wasRead){
					result.assign(data);
				}else{
					result.assign("false");
				}
			}
			if("READ_PROPS" == operation){
				if(NuttyApp.Nutty.nutty_state_data.length > 5){ //nutty state data exists - no need to read the nutty state file
					data  = NuttyApp.Nutty.nutty_state_data;
				}else{ //nutty state data is not available - read the nutty state file
					if(file.query_exists ()){
						bool wasRead = FileUtils.get_contents(path+"/"+filename, out data);
						if(wasRead){
							//set the global variable for the nutty state data to avoid reading the contents again
							NuttyApp.Nutty.nutty_state_data = data;
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
			if("DIR_EXISTS" == operation){
				if(fileDir.query_exists ()){
					result.assign("true");
				}
			}
			if("IS_EXECUTABLE" == operation){
				if(FileUtils.test (path+"/"+filename, FileTest.IS_EXECUTABLE)){
					result.assign("true");
				}
			}
			if("MAKE_EXECUTABLE" == operation){
				NuttyApp.Nutty.execute_sync_command ("chmod +x "+path+"/"+filename);
				result.assign("true");
			}
			if("SET_PERMISSIONS" == operation){
				NuttyApp.Nutty.execute_sync_command ("chmod "+contents+" "+path+"/"+filename);
				result.assign("true");
			}
		}catch (Error e){
			warning("Failure in File Operation [operation="+operation+",path="+path+", filename="+filename+"]: "+e.message);
			result.assign("false:"+e.message);
		}
		debug("Completed file operation["+operation+"]...");
		return result.str;
	}

	public static DateTime getDateFromString(string dateString){
		//expecting date in format : 10-Sep-2016 19:49:04
		char[] dateChars = dateString.strip().to_utf8 ();
		if(dateChars.length == 20){
			int day = int.parse(dateChars[0].to_string()+dateChars[1].to_string());
			string monthString = dateChars[3].to_string()+dateChars[4].to_string()+dateChars[5].to_string();
			int month = 1;
			switch (monthString) {
				case "Jan" : 
						month = 1;
						break;
				case "Feb" : 
						month = 2;
						break;
				case "Mar" : 
						month = 3;
						break;
				case "Apr" : 
						month = 4;
						break;
				case "May" : 
						month = 5;
						break;
				case "Jun" : 
						month = 6;
						break;
				case "Jul" : 
						month = 7;
						break;
				case "Aug" : 
						month = 8;
						break;
				case "Sep" : 
						month = 9;
						break;
				case "Oct" : 
						month = 10;
						break;
				case "Nov" : 
						month = 11;
						break;
				case "Dec" : 
						month = 12;
						break;
				default:
						month = 1;
						break;
			}
			int year = int.parse(dateChars[7].to_string()+dateChars[8].to_string()+dateChars[9].to_string()+dateChars[10].to_string());
			int hour = int.parse(dateChars[12].to_string()+dateChars[13].to_string());
			int min = int.parse(dateChars[15].to_string()+dateChars[16].to_string());
			int sec = int.parse(dateChars[18].to_string()+dateChars[19].to_string());
			return new DateTime.local (year, month, day, hour, min, sec); 
		}else{
			return new DateTime.now_local(); 
		}
	}
	
	public static string getFormattedDate (string dateString, string dateFormatString, bool considerElapsedTIme){
		string modifiedElapsedTime = "";
		if(considerElapsedTIme){
			//calculate the time elapsed from last modified DateTime
			TimeSpan timespan = (new DateTime.now_local()).difference (
					                                        new DateTime.from_unix_local(int64.parse(dateString))
					                                );
			int64 daysElapsed = timespan/(86400000000);
			if( timespan < TimeSpan.DAY){
			  modifiedElapsedTime = NuttyApp.Constants.TEXT_FOR_TIME_TODAY;
			}else if(timespan < 2 * TimeSpan.DAY){
			  modifiedElapsedTime = NuttyApp.Constants.TEXT_FOR_TIME_YESTERDAY;
			}else if(timespan < 30 * TimeSpan.DAY){
			  modifiedElapsedTime = daysElapsed.to_string()+ " " + NuttyApp.Constants.TEXT_FOR_TIME_DAYS;
			}else{
			  modifiedElapsedTime = new DateTime.from_unix_local(int64.parse(dateString)).format(dateFormatString);
			}
		}else{
			modifiedElapsedTime = new DateTime.from_unix_local(int64.parse(dateString)).format(dateFormatString);
		}
		return modifiedElapsedTime;
	}

	public static string limitStringLength (owned string inputString, int length) {
		if(inputString != null && inputString.length > length && inputString.length > length){
			return inputString.slice(0, length) + "...";
		}else{
			return inputString;
		}
	}

    public static bool isExpectedOutputPresent (string executionData, 
												string executionOutput, 
												string[] requiredKeyWords, 
												bool isAllKeywordsRequired)
	{
		bool isOneKeyWordFound = false;
		bool isOneKeyWordMissing = false;
		bool hasCheckFailed = false;
		foreach(string keyword in requiredKeyWords){
			if(executionOutput.index_of(keyword) == -1){
				isOneKeyWordMissing = true;
			}else{
				isOneKeyWordFound = true;
			}
		}
		//make a decision based on whether all key words are required
		if(isAllKeywordsRequired && isOneKeyWordMissing){
			hasCheckFailed = true; //Check has failed - all expected keywords are not in the output
		}
		if(!isAllKeywordsRequired && !isOneKeyWordFound){
			hasCheckFailed = true; //Check has failed - not even one keyword is present in the output
		}
		//Show the infobar with error if the check has failed
		if(hasCheckFailed){
			NuttyApp.AppWindow.showInfoBar(
					"Got Error [" +
						executionOutput.replace("\n"," ").strip() +
					"] in executing command ["+
						executionData +
		            "]",
					Gtk.MessageType.ERROR
			);
			return false;
		}
        return true;
    }
}
