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

public class Dexter.ContactsList : Gtk.Grid {
    public signal void contact_selected (Folks.Individual individual);

    private Gtk.ListBox list_box;
    public ContactsList () {
        set_size_request (150, -1);
        list_box = new Gtk.ListBox ();
        list_box.expand = true;
        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled.vexpand = true;
        scrolled.add (list_box);

        list_box.set_sort_func ((row1, row2) => {
            return GLib.strcmp (((ContactItem)row1).get_sort_name ().collate_key (), ((ContactItem)row2).get_sort_name ().collate_key ());
        });

        list_box.set_header_func (header_update_func);

        list_box.row_activated.connect ((child) => {
            contact_selected (((ContactItem)child).individual);
        });

        this.add (scrolled);
        show_all ();
        var contact_manager = ContactsManager.get_default ();
        contact_manager.individual_added.connect ((individual) => {add_individual (individual);});
        contact_manager.prepared.connect (() => {
            if (list_box.get_children ().length () == 0)
                return;

            var row = list_box.get_row_at_index (0);
            list_box.select_row (row);
            contact_selected (((ContactItem)row).individual);
        });
    }

    private void header_update_func (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
        var sort_name = ((ContactItem)row).get_sort_name ().up ();
        int start = sort_name.index_of_nth_char (0);
        int end = sort_name.index_of_nth_char (1);
        var head_string = canonicalize_for_search (sort_name.slice (start, end));
        if (before != null) {
            var before_sort_name = ((ContactItem)before).get_sort_name ().up ();
            start = before_sort_name.index_of_nth_char (0);
            end = before_sort_name.index_of_nth_char (1);
            var before_head_string = canonicalize_for_search (before_sort_name.slice (start, end));
            if (head_string == before_head_string) {
                row.set_header (null);
                return;
            }
        }

        var header = new HeaderItem (head_string.up ());
        row.set_header (header);
        header.show_all ();
    }

    private void add_individual (Folks.Individual individual) {
        if (individual.is_user == true)
            return;

        var contact_item = new ContactItem (individual);
        var sort_name = contact_item.get_sort_name ();
        if (sort_name == null || sort_name == "")
            return;
        list_box.add (contact_item);
        list_box.invalidate_sort ();
        list_box.invalidate_headers ();
        contact_item.show_all ();
    }

    /*
     * This function comes from GNOME Contacts
     */
    public static string canonicalize_for_search (string str) {
        unowned string s;
        var buffer_result = new unichar[18];
        var result = new StringBuilder ();
        for (s = str; s[0] != 0; s = s.next_char ()) {
            var c = lower_char (s.get_char ());
            if (c != 0) {
                var size = c.fully_decompose (true, buffer_result);
                if (size > 0)
                    result.append_unichar (buffer_result[0]);
            }
        }
        return result.str;
    }

    /*
     * This function comes from GNOME Contacts
     */
    private static unichar lower_char (unichar ch) {
        switch (ch.type ()) {
            case UnicodeType.CONTROL:
            case UnicodeType.FORMAT:
            case UnicodeType.UNASSIGNED:
            case UnicodeType.NON_SPACING_MARK:
            case UnicodeType.COMBINING_MARK:
            case UnicodeType.ENCLOSING_MARK:
                return 0;
            default:
                return ch.tolower ();
        }
    }
}

public class Dexter.HeaderItem : Gtk.Label {
    public HeaderItem (string label) {
        this.label = label;
        margin = 6;
        hexpand = true;
        halign = Gtk.Align.START;
        get_style_context ().add_class ("category-label");
    }
}

public class Dexter.ContactItem : Gtk.ListBoxRow {
    public Folks.Individual individual;
    private Gtk.Label name_label;
    public ContactItem (Folks.Individual individual) {
        this.individual = individual;

        string name = null;
        var structured_name = individual.structured_name;
        if (structured_name != null) {
            if (structured_name.family_name == null || structured_name.family_name == "") {
                name = structured_name.given_name;
            } else {
                name = "%s <b>%s</b>".printf (structured_name.given_name, structured_name.family_name);
            }
        } else {
            if (individual.full_name != null) {
                name = individual.full_name;
            } else {
                name = individual.nickname;
            }
        }

        name_label = new Gtk.Label (name);
        ((Gtk.Misc) name_label).xalign = 0;
        name_label.use_markup = true;
        name_label.ellipsize = Pango.EllipsizeMode.END;
        name_label.margin = 6;
        name_label.margin_start = 12;
        add (name_label);
    }
    
    public string get_sort_name () {
        return name_label.label;
    }
}
