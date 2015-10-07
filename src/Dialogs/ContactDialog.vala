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

public class Dexter.ContactDialog : Gtk.Dialog {
    public enum Type {
        ADD,
        EDIT
    }

    private Type contact_type { get; private set; }
    private Folks.Individual? individual;
    private InfoPanel info_panel;

    public ContactDialog () {
        deletable = false;

        //if (date_time != null) {
            title = _("Add Contact");
            contact_type = Type.ADD;
        /*} else {
            title = _("Edit Contact");
            contact_type = Type.EDIT;
        }*/

        // Dialog properties
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        type_hint = Gdk.WindowTypeHint.DIALOG;

        // Build dialog
        build_dialog (contact_type == Type.ADD);
    }

    void build_dialog (bool add_event) {
        var grid = new Gtk.Grid ();
        grid.row_spacing = 6;
        grid.column_spacing = 12;

        info_panel = new InfoPanel (individual);

        var buttonbox = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
        buttonbox.margin_start = 6;
        buttonbox.margin_end = 6;
        buttonbox.margin_bottom = 6;
        buttonbox.spacing = 6;
        buttonbox.baseline_position = Gtk.BaselinePosition.CENTER;
        buttonbox.set_layout (Gtk.ButtonBoxStyle.END);

        var create_button = new Gtk.Button ();
        create_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        create_button.clicked.connect (save_dialog);
        if (add_event == true) {
            create_button.label = _("Create Contact");
        } else {
            create_button.label = _("Save Changes");
        }

        var close_button = new Gtk.Button.with_label (_("Close"));
        close_button.clicked.connect (() => this.destroy ());

        if (add_event == false) {
            var delete_button = new Gtk.Button.with_label (_("Delete Contact"));
            delete_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            delete_button.clicked.connect (remove_contact);
            buttonbox.add (delete_button);
            buttonbox.set_child_secondary (delete_button, true);
            buttonbox.set_child_non_homogeneous (delete_button, true);
        }

        buttonbox.add (close_button);
        buttonbox.add (create_button);

        grid.attach (info_panel, 0, 0, 1, 1);
        grid.attach (buttonbox, 0, 1, 1, 1);

        ((Gtk.Container)get_content_area ()).add (grid);
    }

    private void save_dialog () {
        this.destroy ();
    }

    private void remove_contact () {
        this.destroy ();
    }
}
