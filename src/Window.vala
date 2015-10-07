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

public class Dexter.Window : Gtk.Window {
    private Gtk.Popover addressbook_popover;
    private Gtk.ToggleButton address_books_button;
    private Granite.Widgets.Welcome welcome_view;
    private Gtk.Stack contact_stack;
    private ContactView current_view;
    public Window () {
        var headerbar = new Gtk.HeaderBar ();
        headerbar.show_close_button = true;
        set_titlebar (headerbar);
        title = _("Contacts");
        window_position = Gtk.WindowPosition.CENTER;
        set_default_size (850, 550);

        address_books_button = new Gtk.ToggleButton ();
        address_books_button.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        address_books_button.toggled.connect (() => {toggle_address_books_popover (address_books_button.active);});

        var add_contact_button = new Gtk.Button.from_icon_name ("contact-new", Gtk.IconSize.LARGE_TOOLBAR);
        add_contact_button.clicked.connect (() => {show_creation_dialog ();});

        var search_entry = new Gtk.SearchEntry ();
        search_entry.placeholder_text = _("Search contact");

        headerbar.pack_start (add_contact_button);
        headerbar.pack_end (address_books_button);
        headerbar.pack_end (search_entry);

        destroy.connect (() => {
            Gtk.main_quit ();
        });

        var contacts_list = new ContactsList ();
        var current_view = new ContactView ();
        contacts_list.contact_selected.connect (current_view.set_contact);
        contact_stack = new Gtk.Stack ();
        contact_stack.add (current_view);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.set_position (150);
        paned.pack1 (contacts_list, false, false);
        paned.pack2 (contact_stack, true, false);

        welcome_view = new Granite.Widgets.Welcome (_("No Contacts Found"), _("Try to add some"));
        welcome_view.append ("contact-new", _("Create"), _("Create a new contact"));
        welcome_view.append ("document-import", _("Import"), _("Add a vCard"));
        welcome_view.show_all ();

        var main_stack = new Gtk.Stack ();
        main_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        main_stack.add_named (paned, "main_view");
        main_stack.add_named (welcome_view, "welcome_view");
        main_stack.set_visible_child_name ("welcome_view");

        var contact_manager = ContactsManager.get_default ();
        contact_manager.individual_added.connect (() => {
            main_stack.set_visible_child_name ("main_view");
        });

        add (main_stack);
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

    public Window window;
    protected override void activate () {
        if (get_windows () != null) {
            get_windows ().data.present (); // present window if app is already running
            return;
        }

        window = new Window ();
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
