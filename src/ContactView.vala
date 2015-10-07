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

public class Dexter.ContactView : Gtk.Grid {
    private Widgets.ContactImage avatar;
    private Widgets.EntryGrid address_grid;
    private Widgets.EntryGrid phone_grid;
    private Widgets.EntryGrid email_grid;
    private Widgets.EntryGrid person_grid;
    private Gtk.Label name_label;
    private Gtk.Label role_label;
    private Gtk.FlowBox flow_box;

    public ContactView () {
        orientation = Gtk.Orientation.VERTICAL;
        expand = true;
        margin = 12;
        row_spacing = 12;
        var name_grid = new Gtk.Grid ();
        name_grid.column_spacing = 12;
        name_grid.row_spacing = 6;

        avatar = new Widgets.ContactImage (Gtk.IconSize.DIALOG);

        name_label = new Gtk.Label ("");
        name_label.get_style_context ().add_class ("h2");
        ((Gtk.Misc) name_label).xalign = 0;

        role_label = new Gtk.Label ("");
        role_label.get_style_context ().add_class ("h3");
        ((Gtk.Misc) role_label).xalign = 0;

        var name_role_grid = new Gtk.Grid ();
        name_role_grid.valign = Gtk.Align.CENTER;
        name_role_grid.orientation = Gtk.Orientation.VERTICAL;
        name_role_grid.hexpand = true;
        name_role_grid.add (name_label);
        name_role_grid.add (role_label);

        var edit_button_grid = new Gtk.Grid ();
        edit_button_grid.valign = Gtk.Align.CENTER;
        var edit_button = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.BUTTON);
        edit_button.relief = Gtk.ReliefStyle.NONE;
        edit_button_grid.add (edit_button);

        name_grid.attach (avatar, 0, 0, 1, 1);
        name_grid.attach (name_role_grid, 1, 0, 1, 1);
        name_grid.attach (edit_button_grid, 2, 0, 1, 1);

        person_grid = new Widgets.EntryGrid (_("Dates"));
        address_grid = new Widgets.EntryGrid (_("Address"));
        phone_grid = new Widgets.EntryGrid (_("Phone"));
        email_grid = new Widgets.EntryGrid (_("Email"));

        flow_box = new Gtk.FlowBox ();
        flow_box.column_spacing = 12;
        flow_box.row_spacing = 6;
        flow_box.expand = true;
        flow_box.selection_mode = Gtk.SelectionMode.NONE;
        flow_box.add (phone_grid);
        flow_box.add (email_grid);
        flow_box.add (address_grid);
        flow_box.add (person_grid);
        flow_box.set_filter_func ((fbchild) => {
            return fbchild.get_child ().visible;
        });

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (flow_box);
        scrolled.vscrollbar_policy = Gtk.PolicyType.NEVER;

        add (name_grid);
        add (scrolled);
    }

    public void set_contact (Folks.Individual individual) {
        name_label.label = Markup.escape_text (individual.full_name);
        update_role_label (individual);

        avatar.add_contact (individual);
        set_email_addresses (individual);
        set_phone_numbers (individual);
        set_addresses (individual);
        set_person (individual);
        flow_box.invalidate_filter ();
    }

    private void set_phone_numbers (Folks.Individual individual) {
        phone_grid.clear ();
        foreach (var phonedetail in individual.phone_numbers) {
            var kind_label = new Gtk.Label ("");
            kind_label.use_markup = true;
            ((Gtk.Misc) kind_label).xalign = 1;

            var phone_label = new Gtk.Label (phonedetail.get_normalised ());
            ((Gtk.Misc) phone_label).xalign = 0;
            phone_label.hexpand = true;
            var types = phonedetail.get_parameter_values (Folks.AbstractFieldDetails.PARAM_TYPE);
            if (types == null) {
                kind_label.label = "<b>%s</b>".printf (_("Other:"));
                phone_grid.add_parameters (kind_label, phone_label);
                continue;
            }

            if (types.contains (Folks.AbstractFieldDetails.PARAM_TYPE_HOME)) {
                kind_label.label = "<b>%s</b>".printf (_("Home:"));
            } else if (types.contains (Folks.AbstractFieldDetails.PARAM_TYPE_WORK)) {
                kind_label.label = "<b>%s</b>".printf (_("Work:"));
            } else if (types.contains (Folks.AbstractFieldDetails.PARAM_TYPE_OTHER)) {
                kind_label.label = "<b>%s</b>".printf (_("Other:"));
            } else if (types.contains ("personal")) {
                kind_label.label = "<b>%s</b>".printf (_("Personal:"));
            } else if (types.contains ("cell")) {
                kind_label.label = "<b>%s</b>".printf (_("Mobile:"));
            } else {
                kind_label.label = "<b>%s</b>".printf (types.to_array ()[0]);
            }

            phone_grid.add_parameters (kind_label, phone_label);
        }

        if (individual.phone_numbers.size <= 0) {
            phone_grid.hide ();
        } else {
            phone_grid.show_all ();
        }
    }

    private void set_addresses (Folks.Individual individual) {
        address_grid.clear ();
        foreach (var postaldetail in individual.postal_addresses) {
            var kind_label = new Gtk.Label ("");
            kind_label.use_markup = true;
            ((Gtk.Misc) kind_label).xalign = 1;

            var address = ((Folks.PostalAddress) postaldetail.value).to_string ();
            var address_label = new Gtk.Label (address);
            ((Gtk.Misc) address_label).xalign = 0;
            address_label.hexpand = true;
            var types = postaldetail.get_parameter_values (Folks.AbstractFieldDetails.PARAM_TYPE);
            if (types == null) {
                kind_label.label = "<b>%s</b>".printf (_("Other:"));
                address_grid.add_parameters (kind_label, address_label);
                continue;
            }

            if (types.contains (Folks.AbstractFieldDetails.PARAM_TYPE_HOME)) {
                kind_label.label = "<b>%s</b>".printf (_("Home:"));
            } else if (types.contains (Folks.AbstractFieldDetails.PARAM_TYPE_WORK)) {
                kind_label.label = "<b>%s</b>".printf (_("Work:"));
            } else if (types.contains (Folks.AbstractFieldDetails.PARAM_TYPE_OTHER)) {
                kind_label.label = "<b>%s</b>".printf (_("Other:"));
            } else if (types.contains ("personal")) {
                kind_label.label = "<b>%s</b>".printf (_("Personal:"));
            } else {
                kind_label.label = "<b>%s</b>".printf (types.to_array ()[0]);
            }

            address_grid.add_parameters (kind_label, address_label);
        }

        if (individual.postal_addresses.size <= 0) {
            address_grid.hide ();
        } else {
            address_grid.show_all ();
        }
    }

    private void set_email_addresses (Folks.Individual individual) {
        email_grid.clear ();

        foreach (var emaildetail in individual.email_addresses) {
            var kind_label = new Gtk.Label ("");
            kind_label.use_markup = true;
            ((Gtk.Misc) kind_label).xalign = 1;

            var address_label = new Gtk.Label ((string)emaildetail.value);
            ((Gtk.Misc) address_label).xalign = 0;
            address_label.hexpand = true;
            var types = emaildetail.get_parameter_values (Folks.AbstractFieldDetails.PARAM_TYPE);
            if (types == null) {
                kind_label.label = "<b>%s</b>".printf (_("Other:"));
                email_grid.add_parameters (kind_label, address_label);
                continue;
            }

            if (types.contains (Folks.AbstractFieldDetails.PARAM_TYPE_HOME)) {
                kind_label.label = "<b>%s</b>".printf (_("Home:"));
            } else if (types.contains (Folks.AbstractFieldDetails.PARAM_TYPE_WORK)) {
                kind_label.label = "<b>%s</b>".printf (_("Work:"));
            } else if (types.contains (Folks.AbstractFieldDetails.PARAM_TYPE_OTHER)) {
                kind_label.label = "<b>%s</b>".printf (_("Other:"));
            } else if (types.contains ("personal")) {
                kind_label.label = "<b>%s</b>".printf (_("Personal:"));
            } else {
                kind_label.label = "<b>%s</b>".printf (types.to_array ()[0]);
            }

            email_grid.add_parameters (kind_label, address_label);
        }

        if (individual.email_addresses.size <= 0) {
            email_grid.hide ();
        } else {
            email_grid.show_all ();
        }
    }

    private void set_person (Folks.Individual individual) {
        person_grid.clear ();
        if (individual.birthday != null) {
            var birthday_label = new Gtk.Label ("<b>%s</b>".printf (_("Birthday:")));
            birthday_label.use_markup = true;
            ((Gtk.Misc) birthday_label).xalign = 1;
            if (individual.birthday.get_year () > 1900) {
                var birthday_date_label = new Gtk.Label (individual.birthday.format (Granite.DateTime.get_default_date_format (false, true, true)));
                person_grid.add_parameters (birthday_label, birthday_date_label);
            } else {
                var birthday_date_label = new Gtk.Label (individual.birthday.format (Granite.DateTime.get_default_date_format ()));
                person_grid.add_parameters (birthday_label, birthday_date_label);
            }

            person_grid.show_all ();
        } else {
            person_grid.hide ();
        }
    }

    private void update_role_label (Folks.Individual individual) {
        string role_string = "";
        bool is_first = true;
        foreach (var role in individual.roles) {
            if (is_first == true) {
                role_string = format_role ((Folks.Role)role.value);
                is_first = false;
            } else {
                role_string += "\n" + format_role ((Folks.Role)role.value);
            }
        }

        role_label.label = role_string;
        if (role_string == "") {
            role_label.hide ();
        } else {
            role_label.show ();
        }
    }

    private string format_role (Folks.Role role) {
        string role_format = "";
        if (role.title != null) {
            role_format = role.title;
        }

        if (role.organisation_name != null) {
            if (role_format == "") {
                role_format = role.organisation_name;
            } else {
                role_format = _(" %s at %s").printf (role_format, role.organisation_name);
            }
        }

        if (role.role != null) {
            if (role_format == "") {
                role_format = role.role;
            } else {
                role_format = _(" %s as %s").printf (role_format, role.role);
            }
        }

        return Markup.escape_text (role_format.chug ());
    }
}

public class Dexter.Body : Gtk.Grid {
    private Gtk.Label header_label;
    private Gtk.ListBox list;

    public Body (string header) {
        expand = true;
        row_spacing = 12;
        column_spacing = 6;

        header_label = new Gtk.Label ("<big><b>%s</b></big>".printf (header));
        header_label.hexpand = true;
        header_label.use_markup = true;
        ((Gtk.Misc) header_label).xalign = 0;

        list = new Gtk.ListBox ();
        list.set_selection_mode (Gtk.SelectionMode.NONE);

        attach (header_label, 0, 0, 3, 1);
        attach (list, 1, 1, 3, 4);
    }

    public void add_parameter (Gtk.ListBoxRow row) {
        list.prepend (row);
    }

    public void clear () {
        list.forall ((widget) => {
            widget.destroy ();
        });
    }
}

public class Dexter.AddressEntry : Gtk.ListBoxRow {
    private Widgets.MapView map_view;

    public AddressEntry (string kind, Folks.PostalAddress address) {
        var container = new Gtk.Grid ();
        container.expand = true;
        container.row_spacing = 12;
        container.column_spacing = 6;
        container.row_homogeneous = true;

        var kind_label = new Gtk.Label ("<b>%s</b>".printf (kind));
        kind_label.use_markup = true;
        ((Gtk.Misc) kind_label).xalign = 1;

        var locality_label = new Gtk.Label (address.locality);
        ((Gtk.Misc) locality_label).xalign = 0;
        locality_label.hexpand = true;

        map_view = new Widgets.MapView ();

        int current_line = 0;

        if (address.street != null && address.street != "") {
            var street_label = new Gtk.Label (address.street);
            container.attach (street_label, 3, current_line++, 4, 1);
        }

        if (address.region != null && address.region != "") {
            var region_label = new Gtk.Label (address.region);
            container.attach (region_label, 3, current_line++, 4, 1);
        }

        container.attach (map_view, 0, current_line, 7, 6);
        add (container);

        compute_location.begin (address.to_string ());
    }

    private async void compute_location (string loc) {
        var forward = new Geocode.Forward.for_string (loc);
        try {
            forward.set_answer_count (1);
            var places = forward.search ();
            foreach (var place in places) {
                Idle.add (() => {
                    map_view.set_point (place.location.latitude, place.location.longitude);
                    return false;
                });
            }
        } catch (Error error) {
            debug (error.message);
        }
    }
}
