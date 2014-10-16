// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2014 Pantheon Developers (http://launchpad.net/online-accounts-plug)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Corentin Noël <tintou@mailoo.org>
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
            return GLib.strcmp (((ContactItem)row1).get_sort_name (), ((ContactItem)row2).get_sort_name ());
        });

        list_box.set_header_func ((row, before) => {
            var sort_name = ((ContactItem)row).get_sort_name ().casefold ();
            int start = sort_name.index_of_nth_char (0);
            int end = sort_name.index_of_nth_char (1);
            var head_string = sort_name.slice (start, end).up ();
            if (before != null) {
                var before_sort_name = ((ContactItem)before).get_sort_name ().casefold ();
                start = before_sort_name.index_of_nth_char (0);
                end = before_sort_name.index_of_nth_char (1);
                var before_head_string = before_sort_name.slice (start, end).up ();
                if (head_string == before_head_string) {
                    row.set_header (null);
                    return;
                }
            }

            var header = new HeaderItem (head_string);
            row.set_header (header);
            header.show_all ();
        });

        list_box.row_activated.connect ((child) => {
            contact_selected (((ContactItem)child).individual);
        });

        this.add (scrolled);
        show_all ();
        load_contacts.begin ();
    }

    private async void load_contacts () {
        yield ContactsManager.get_default ().load_contacts ();
        /*if (list_box.get_children ().length () <= 1) {
            list_box.select_row (contact_item);
            contact_selected (individual);
        }*/
        ContactsManager.get_default ().individual_added.connect ((individual) => {add_individual (individual);});
    }

    private void add_individual (Folks.Individual individual) {
        if (individual.is_user == true)
            return;

        var contact_item = new ContactItem (individual);
        var sort_name = contact_item.get_sort_name ();
        if (sort_name == null || sort_name == "")
            return;
        list_box.add (contact_item);
        contact_item.show_all ();
    }
}

public class Dexter.HeaderItem : Gtk.ListBoxRow {
    public string character { private set; public get; }
    private Gtk.Label character_label;
    public HeaderItem (string character) {
        sensitive = false;
        this.character = character;
        character_label = new Gtk.Label ("<b>%s</b>".printf (character));
        character_label.use_markup = true;
        character_label.hexpand = true;
        character_label.halign = Gtk.Align.START;
        character_label.margin_start = 12;
        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.row_spacing = 6;
        grid.hexpand = true;
        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.hexpand = true;
        grid.add (character_label);
        grid.add (separator);
        add (grid);
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
        name_label.xalign = 0;
        name_label.use_markup = true;
        name_label.ellipsize = Pango.EllipsizeMode.END;
        name_label.margin = 6;
        name_label.margin_end = 0;
        add (name_label);
    }
    
    public string get_sort_name () {
        return name_label.label;
    }
}