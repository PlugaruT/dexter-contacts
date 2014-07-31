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

public class Dexter.Window : Gtk.Window {
    private Gtk.Popover addressbook_popover;
    private Gtk.ToggleButton address_books_button;
    public Window () {
        var headerbar = new Gtk.HeaderBar ();
        headerbar.show_close_button = true;
        set_titlebar (headerbar);
        title = _("Contacts");
        window_position = Gtk.WindowPosition.CENTER;
        set_default_size (850, 550);

        address_books_button = new Gtk.ToggleButton ();
        address_books_button.image = new Gtk.Image.from_icon_name ("office-address-book", Gtk.IconSize.LARGE_TOOLBAR);
        address_books_button.toggled.connect (() => {toggle_address_books_popover (address_books_button.active);});

        var add_contact_button = new Gtk.Button.from_icon_name ("contact-new", Gtk.IconSize.LARGE_TOOLBAR);
        add_contact_button.clicked.connect (() => {show_creation_dialog ();});

        var search_entry = new Gtk.SearchEntry ();
        search_entry.placeholder_text = _("Search contact…");

        headerbar.pack_start (address_books_button);
        headerbar.pack_start (add_contact_button);
        headerbar.pack_end (search_entry);

        destroy.connect (() => {
            Gtk.main_quit ();
        });

        var contacts_list = new ContactsList ();
        var contact_view = new ContactView ();
        contacts_list.contact_selected.connect (contact_view.set_contact);

        var thinpaned = new Granite.Widgets.ThinPaned (Gtk.Orientation.HORIZONTAL);
        thinpaned.set_position (150);
        thinpaned.pack1 (contacts_list, false, false);
        thinpaned.pack2 (contact_view, true, false);
        add (thinpaned);
        show_all ();
    }

    private void show_creation_dialog () {
        var contact_dialog = new ContactDialog ();
        contact_dialog.transient_for = this;
        contact_dialog.show_all ();
    }

    private void toggle_address_books_popover (bool active) {
        if (active == false) {
            if (addressbook_popover == null)
                return;
            addressbook_popover.hide ();
            addressbook_popover.destroy ();
        } else {
            addressbook_popover = new Gtk.Popover (address_books_button);
            addressbook_popover.add (new Gtk.Label ("Address books HERE"));
            addressbook_popover.hide.connect (() => {address_books_button.active = false;});
            addressbook_popover.show.connect (() => {address_books_button.active = true;});
            addressbook_popover.show_all ();
        }
    }
}

public class Dexter.App : Granite.Application {

    construct {
        // This allows opening files. See the open() method below.
        flags |= ApplicationFlags.HANDLES_OPEN;

        // App info
        /*build_data_dir = Build.DATADIR;
        build_pkg_data_dir = Build.PKG_DATADIR;
        build_release_name = Build.RELEASE_NAME;
        build_version_info = Build.VERSION_INFO;*/
        build_version = "0.2.0";

        program_name = "Contacts";
        exec_name = "dexter-contacts";

        app_copyright = "2012-2014";
        application_id = "org.pantheon.dexter-contacts";
        app_icon = "x-office-address-book";
        app_launcher = exec_name+".desktop";
        app_years = "2012-2014";

        main_url = "https://launchpad.net/dexter-contacts";
        bug_url = "https://bugs.launchpad.net/dexter-contacts/+filebug";
        help_url = "http://elementaryos.org/answers/+/dexter/all/newest";
        translate_url = "https://translations.launchpad.net/dexter-contacts";

        about_authors = {"Corentin Noël <tintou@mailoo.org>", null};

        about_artists = {null};
    }

    protected override void activate () {
        // Create the window of this application and show it
        var window = new Window ();
        window.show_all ();
        Gtk.main ();
    }

    public static int main (string[] args) {
        Gtk.init (ref args);
        Clutter.init (ref args);
        var app = new App ();
        return app.run (args);
    }
}