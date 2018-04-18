/* Copyright 2017 Siddhartha Das (bablu.boy@gmail.com)
*
* This file is part of Nutty and is used for defining
* the keyboard shortcuts for Nutty
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
* with Bookworm. If not, see http://www.gnu.org/licenses/.
*/

public class NuttyApp.Shortcuts: Gtk.Widget {
  public static bool isControlKeyPressed = false;

  public static bool handleKeyPress(Gdk.EventKey ev){
       //Ctrl Key pressed: Record the action for Ctrl combination keys
        if ((ev.keyval == Gdk.Key.Control_L || ev.keyval == Gdk.Key.Control_R)) {
          NuttyApp.Shortcuts.isControlKeyPressed = true;
        }

        //Ctrl+Q Key pressed: Close Nutty completely
        if (NuttyApp.Shortcuts.isControlKeyPressed && (ev.keyval == Gdk.Key.Q || ev.keyval == Gdk.Key.q)) {
          NuttyApp.Nutty.window.destroy();
        }
        //Ctrl+F Key pressed: Focus the search entry on the header
        if (NuttyApp.Shortcuts.isControlKeyPressed && (ev.keyval == Gdk.Key.F || ev.keyval == Gdk.Key.f)) {
          NuttyApp.Nutty.headerSearchBar.grab_focus ();
        }
        return false;
      }

      public static bool handleKeyRelease(Gdk.EventKey ev){
        //Ctrl Key released: Record the action for Ctrl combination keys
        if ((ev.keyval == Gdk.Key.Control_L || ev.keyval == Gdk.Key.Control_R)) {
          NuttyApp.Shortcuts.isControlKeyPressed = false;
        }
        return false;
      }
}
