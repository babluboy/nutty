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

public class NuttyApp.AppHeaderBar {
    public static Gtk.HeaderBar headerbar;
    public static Gtk.Button bookmark_inactive_button;
    public static Gtk.Button bookmark_active_button;
    
    public static Gtk.HeaderBar create_headerbar(Gtk.Window window) {
		info("[START] [FUNCTION:create_headerbar]");
		Gtk.HeaderBar headerbar = new Gtk.HeaderBar();
		headerbar.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
		headerbar.set_title(NuttyApp.Constants.program_name);
		//headerbar.subtitle = Constants.TEXT_FOR_SUBTITLE_HEADERBAR;
		headerbar.set_show_close_button(true);
		headerbar.spacing = Constants.SPACING_WIDGETS;
		//add menu items
		headerbar.pack_end(createNuttyMenu());
		//Add a search entry to the header
		NuttyApp.Nutty.headerSearchBar = new Gtk.SearchEntry();
		NuttyApp.Nutty.headerSearchBar.set_placeholder_text(Constants.TEXT_FOR_SEARCH_HEADERBAR);
		headerbar.pack_end(NuttyApp.Nutty.headerSearchBar);
		// Set actions for HeaderBar search
		NuttyApp.Nutty.headerSearchBar.search_changed.connect (() => {
			if(Constants.TEXT_FOR_SEARCH_HEADERBAR != NuttyApp.Nutty.headerSearchBar.get_text()){
				if("my-info"==NuttyApp.Nutty.stack.get_visible_child_name()){
					NuttyApp.Nutty.infoTreeModelFilter.refilter();
					NuttyApp.Nutty.infoSearchEntry.erase(0,-1);
					NuttyApp.Nutty.infoSearchEntry.append(NuttyApp.Nutty.headerSearchBar.get_text());
				}else if("ports"==NuttyApp.Nutty.stack.get_visible_child_name()){
					NuttyApp.Nutty.portsTreeModelFilter.refilter();
					NuttyApp.Nutty.portsSearchEntry.erase(0,-1);
					NuttyApp.Nutty.portsSearchEntry.append(NuttyApp.Nutty.headerSearchBar.get_text());
				} else if("route"==NuttyApp.Nutty.stack.get_visible_child_name()){
					NuttyApp.Nutty.routeTreeModelFilter.refilter();
					NuttyApp.Nutty.routeSearchEntry.erase(0,-1);
					NuttyApp.Nutty.routeSearchEntry.append(NuttyApp.Nutty.headerSearchBar.get_text());
				} else if("devices"==NuttyApp.Nutty.stack.get_visible_child_name()){
					NuttyApp.Nutty.devicesTreeModelFilter.refilter();
					NuttyApp.Nutty.devicesSearchEntry.erase(0,-1);
					NuttyApp.Nutty.devicesSearchEntry.append(NuttyApp.Nutty.headerSearchBar.get_text());
				} else if("bandwidth"==NuttyApp.Nutty.stack.get_visible_child_name()){
					NuttyApp.Nutty.bandwidthTreeModelFilter.refilter();
					NuttyApp.Nutty.bandwidthSearchEntry.erase(0,-1);
					NuttyApp.Nutty.bandwidthSearchEntry.append(NuttyApp.Nutty.headerSearchBar.get_text());
				} else{
				}
			}
		});
		info("[END] [FUNCTION:create_headerbar]");
		return headerbar;
	}

    public static Gtk.MenuButton createNuttyMenu () {
		info("[START] [FUNCTION:createNuttyMenu]");
		
		Gtk.MenuButton appMenuButton = new Gtk.MenuButton ();
        appMenuButton.set_image (NuttyApp.Nutty.menu_icon);

		Gtk.Menu settingsMenu = new Gtk.Menu ();
        appMenuButton.popup = settingsMenu;

		//Add sub menu items
		Gtk.MenuItem menuItemPrefferences = new Gtk.MenuItem.with_label(Constants.TEXT_FOR_HEADERBAR_MENU_PREFS);
		settingsMenu.add (menuItemPrefferences);
		Gtk.MenuItem menuItemExportToFile = new Gtk.MenuItem.with_label(Constants.TEXT_FOR_HEADERBAR_MENU_EXPORT);
		settingsMenu.add (menuItemExportToFile);
		
		//Add actions for menu items
		menuItemPrefferences.activate.connect(() => {
			NuttyApp.Nutty.createPrefsDialog();
		});
		menuItemExportToFile.activate.connect(() => {
			NuttyApp.Nutty.createExportDialog();
		});
		//Add About option to menu
		Gtk.MenuItem showAbout = new Gtk.MenuItem.with_label (NuttyApp.Constants.TEXT_FOR_PREF_MENU_ABOUT_ITEM);
        showAbout.activate.connect (ShowAboutDialog);
        settingsMenu.append (showAbout);

		settingsMenu.show_all ();
		info("[END] [FUNCTION:createNuttyMenu]");
		return appMenuButton;
	}

    public static Gtk.HeaderBar get_headerbar() {
        if(headerbar == null){
            create_headerbar(NuttyApp.Nutty.window);
        }
        return headerbar;
    }

    public static void ShowAboutDialog (){
        info("[START] [FUNCTION:ShowAboutDialog]");
        Gtk.AboutDialog aboutDialog = new Gtk.AboutDialog ();
        aboutDialog.set_destroy_with_parent (true);
	    aboutDialog.set_transient_for (NuttyApp.Nutty.window);
	    aboutDialog.set_modal (true);

        aboutDialog.set_attached_to(NuttyApp.Nutty.window);
        aboutDialog.program_name = NuttyApp.Constants.program_name;
        aboutDialog.website = NuttyApp.Constants.TEXT_FOR_ABOUT_DIALOG_WEBSITE_URL;
        aboutDialog.website_label = NuttyApp.Constants.TEXT_FOR_ABOUT_DIALOG_WEBSITE;
        aboutDialog.logo_icon_name = NuttyApp.Constants.app_icon;
        aboutDialog.copyright = NuttyApp.Constants.nutty_copyright;
        aboutDialog.version = NuttyApp.Constants.nutty_version;
        aboutDialog.authors = NuttyApp.Constants.about_authors;
        aboutDialog.artists = NuttyApp.Constants.about_artists;
        aboutDialog.comments = NuttyApp.Constants.about_comments;
        aboutDialog.license = null;
        aboutDialog.license_type = NuttyApp.Constants.about_license_type;
        aboutDialog.translator_credits = NuttyApp.Constants.translator_credits;

        aboutDialog.present ();
        aboutDialog.response.connect((response_id) => {
            aboutDialog.destroy ();
        });
        info("[END] [FUNCTION:ShowAboutDialog]");
    }
}
