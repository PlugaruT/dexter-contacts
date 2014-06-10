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

    private enum ListColumn {
        ICON = 0,
        NAME,
        CONTACT,
        N_COLUMNS
    }

    private Gtk.ListStore list_store;
    private Gtk.TreeView view;
    private Folks.AvatarCache avatar_cache;
    public ContactsList () {
        list_store = new Gtk.ListStore (ListColumn.N_COLUMNS, typeof (GLib.Icon), typeof (string), typeof (Folks.Individual));
        avatar_cache = Folks.AvatarCache.dup ();

        var cellpixbuf = new Gtk.CellRendererPixbuf ();
        cellpixbuf.stock_size = Gtk.IconSize.DIALOG;
        var icon_column = new Gtk.TreeViewColumn.with_attributes ("Icon", cellpixbuf, "gicon", ListColumn.ICON);
        var name_column = new Gtk.TreeViewColumn.with_attributes ("Name", new Gtk.CellRendererText (), "markup", ListColumn.NAME);

        view = new Gtk.TreeView.with_model (list_store);
        view.expand = true;
        view.append_column (icon_column);
        view.append_column (name_column);
        view.activate_on_single_click = true;
        view.headers_visible = false;
        view.row_activated.connect ((path, column) => {
            Gtk.TreeIter iter;
            list_store.get_iter (out iter, path);
            GLib.Value val;
            list_store.get_value (iter, ListColumn.CONTACT, out val);
            contact_selected ((Folks.Individual)val.get_object ());
        });
        this.add (view);
        show_all ();
        ContactsManager.get_default ().individual_added.connect ((individual) => {add_individual.begin (individual);});
    }

    private async void add_individual (Folks.Individual individual) {
        if (individual.is_user == true)
            return;

        bool first = false;
        Gtk.TreeIter iter;
        if (list_store.get_iter_first (out iter) == false)
            first = true;
        list_store.append (out iter);
        Icon avatar = individual.avatar;
        if (avatar == null)
            try {
            avatar = yield avatar_cache.load_avatar (individual.id);
            } catch (Error e) {
                critical (e.message);
            }
        if (avatar == null)
            avatar = new ThemedIcon ("avatar-default");
        list_store.set (iter, ListColumn.ICON, avatar, ListColumn.NAME, individual.full_name, ListColumn.CONTACT, individual);
        if (first == true) {
            var selection = view.get_selection ();
            selection.select_iter (iter);
            contact_selected (individual);
        }
    }
}