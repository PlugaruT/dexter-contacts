// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2014 Dexter Contacts Developers (https://launchpad.net/dexter-contacts)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Corentin Noël <corentin@elementaryos.org>
 */

public class Dexter.InfoPanel : Gtk.Grid {
    private Folks.Individual? individual;

    public InfoPanel (Folks.Individual? individual) {
        expand = true;
        this.individual = individual;
        var main_grid = new Gtk.Grid ();
        main_grid.margin = 6;
        var avatar_button = new Gtk.Button ();
        avatar_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        var avatar_image = new Widgets.ContactImage (Gtk.IconSize.DIALOG, individual);
        avatar_button.add (avatar_image);

        var name_entry = new Gtk.Entry ();
        name_entry.placeholder_text = _("Name");
        name_entry.secondary_icon_name = "edit-symbolic";
        name_entry.input_purpose = Gtk.InputPurpose.NAME;
        name_entry.hexpand = true;

        var status_entry = new Gtk.Entry ();
        status_entry.placeholder_text = _("CEO at elementary LLC.");
        status_entry.secondary_icon_name = "edit-symbolic";
        status_entry.input_purpose = Gtk.InputPurpose.FREE_FORM;
        status_entry.hexpand = true;

        main_grid.attach (avatar_button, 0, 0, 1, 2);
        main_grid.attach (name_entry, 1, 0, 1, 1);
        main_grid.attach (status_entry, 1, 1, 1, 1);
        add (main_grid);
    }
}
