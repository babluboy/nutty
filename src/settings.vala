/* Copyright 2017 Siddhartha Das (bablu.boy@gmail.com)
*
* This file is part of Nutty and is used for persisting
* the state of the window, application data and associated user prefferences
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
namespace NuttyApp {
	public class Settings : Granite.Services.Settings {
        private static Settings? instance = null;

          public int window_width { get; set; }
          public int window_height { get; set; }
          public int pos_x { get; set; }
          public int pos_y { get; set; }
          public bool window_is_maximized { get; set; }
          public bool is_device_monitoring_enabled { get; set; }
          public int device_monitoring_scheduled { get; set; }
          public string last_speed_test_date { get; set; }
          public string last_recorded_upload_speed { get; set; }
          public string last_recorded_download_speed { get; set; }            
         
          public static Settings get_instance () {
            if (instance == null) {
                instance = new Settings ();
            }
            return instance;
          }

          private Settings () {
            base (NuttyApp.Constants.app_id);
          }
    }
}
