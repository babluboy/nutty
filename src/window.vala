/* Copyright 2018 Siddhartha Das (bablu.boy@gmail.com)
*
* This file is part of Nutty and is responsible for drawing the window elements.
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

public class NuttyApp.AppWindow {
    public static Gtk.Box createNuttyWelcomeView() {
		debug("Starting to create main window components...");
		Gtk.Box welcome_ui_box = new Gtk.Box (Orientation.VERTICAL, Constants.SPACING_WIDGETS);
		Granite.Widgets.Welcome welcome = new Granite.Widgets.Welcome (
    		NuttyApp.Constants.PRIMARY_TEXT_FOR_DISCLAIMER,   
    		NuttyApp.Constants.SECONDARY_TEXT_FOR_DISCLAIMER
		);
		//Format the welcome secondary text
		Grid welcome_grid = (Grid) welcome.get_child ();
		GLib.List<weak Gtk.Widget> welcome_widgets = welcome_grid.get_children ();
		foreach(Widget aWelcomeWidget in welcome_widgets) {
			debug(aWelcomeWidget.get_path().to_string());
			//grab the secondary text label
			if(aWelcomeWidget.get_path().to_string().contains("GtkLabel") &&
			   aWelcomeWidget.get_path().to_string().contains("h2"))
			{
				   ((Label)aWelcomeWidget).justify = Gtk.Justification.LEFT;
				   break;
			}
		}
		//Add a link to the nmap disclaimer website
		welcome.append (
			"emblem-web",
			_("Nutty Disclaimer"), 
			_("Click to read the legal disclaimer on Nmap (used by Nutty) for further information")
		);
		welcome.activated.connect ((index) => {
		    switch (index) {
		        case 0:
		            try {
		                AppInfo.launch_default_for_uri ("https://nmap.org/book/legal-issues.html", null);
		            } catch (Error e) {
		                warning ("Error in launching browser for NMap Legal details: " + e.message);
		            }
		            break;
		    }
		});	
		Gtk.Box disclaimer_agreement_box = new Gtk.Box (Orientation.HORIZONTAL, Constants.SPACING_WIDGETS);

		Button continueButton = new Button.with_label(_("Use Nutty"));
		continueButton.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
		continueButton.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
		Button exitButton = new Button.with_label(_("Exit"));
		exitButton.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
		disclaimer_agreement_box.pack_end (continueButton, false, false, 0);
		disclaimer_agreement_box.pack_end (exitButton, false, false, 0);

		continueButton.clicked.connect (() => {
			NuttyApp.Nutty.disclaimerSetGet(Constants.REMEMBER_DISCLAIMER_AGREEMENT);
			welcome_ui_box.destroy();//remove the welcome widget
			NuttyApp.Nutty.window.add(NuttyApp.Nutty.createNuttyUI()); //add the main UI Box
			NuttyApp.Nutty.window.show_all();
			//hide the infobar on initial load
			NuttyApp.Nutty.infobar.hide();
		});
		exitButton.clicked.connect (() => {
			NuttyApp.Nutty.window.destroy();
		});

		welcome_ui_box.add (welcome);
		welcome_ui_box.pack_start (disclaimer_agreement_box, true, false, 0);
		info("[END] [FUNCTION:createExportDialog]");
		return welcome_ui_box;
    }

    public static void showInfoBar(string message, MessageType aMessageType){
        debug("[START] [FUNCTION:showInfoBar] ");
        NuttyApp.Nutty.infobarLabel.set_text(message);
        NuttyApp.Nutty.infobar.set_message_type (aMessageType);
        NuttyApp.Nutty.infobar.show();
        debug("[END] [FUNCTION:showInfoBar] with message:"+message);
    }

    //Handle action for close of the InfoBar
    public static void on_info_bar_closed(){
        NuttyApp.Nutty.infobar.hide();
    }
}

