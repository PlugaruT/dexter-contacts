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
        list_box = new Gtk.ListBox ();
        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.vexpand = true;
        scrolled.add (list_box);
        list_box.row_activated.connect ((child) => {
            contact_selected (((ContactItem)child).individual);
        });

        this.add (scrolled);
        show_all ();
        ContactsManager.get_default ().individual_added.connect ((individual) => {add_individual.begin (individual);});
    }

    private async void add_individual (Folks.Individual individual) {
        if (individual.is_user == true)
            return;

        var contact_item = new ContactItem (individual);
        list_box.add (contact_item);
        contact_item.show_all ();
        if (list_box.get_children ().length () <= 1) {
            list_box.select_row (contact_item);
            contact_selected (individual);
        }
    }
}


public class Dexter.ContactItem : Gtk.ListBoxRow {
    public Folks.Individual individual;
    private Widgets.ContactImage avatar_image;
    private Gtk.Label name_label;
    public ContactItem (Folks.Individual individual) {
        this.individual = individual;
        var main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.HORIZONTAL;
        main_grid.margin = 6;
        main_grid.row_spacing = 6;
        main_grid.column_spacing = 12;
        main_grid.expand = true;
        
        avatar_image = new Widgets.ContactImage (Gtk.IconSize.DIALOG, individual);

        string name = null;
        var structured_name = individual.structured_name;
        if (structured_name != null) {
            
        }

        if (individual.full_name != null) {
            name = individual.full_name;
        } else {
            name = individual.nickname;
        }

        name_label = new Gtk.Label (name);
        main_grid.add (avatar_image);
        main_grid.add (name_label);
        add (main_grid);
    }
}