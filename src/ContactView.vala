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
    private PersonEntry person_box;
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
        name_label.use_markup = true;
        name_label.xalign = 0;

        role_label = new Gtk.Label ("");
        role_label.use_markup = true;
        role_label.xalign = 0;

        name_grid.attach (avatar, 0, 0, 1, 2);
        name_grid.attach (name_label, 1, 0, 1, 1);
        name_grid.attach (role_label, 1, 1, 1, 1);

        person_box = new PersonEntry ();
        address_grid = new Widgets.EntryGrid (_("Address:"));
        phone_grid = new Widgets.EntryGrid (_("Phone:"));
        email_grid = new Widgets.EntryGrid (_("Email:"));

        flow_box = new Gtk.FlowBox ();
        flow_box.column_spacing = 12;
        flow_box.row_spacing = 6;
        flow_box.selection_mode = Gtk.SelectionMode.NONE;
        flow_box.add (phone_grid);
        flow_box.add (email_grid);
        flow_box.add (address_grid);
        flow_box.add (person_box);

        add (name_grid);
        add (flow_box);
    }

    public void set_contact (Folks.Individual individual) {
        set_name_label_text (individual.full_name);
        update_role_label (individual);

        person_box.set_contact (individual);
        avatar.add_contact (individual);
        set_email_addresses (individual);
        set_phone_numbers (individual);
        set_addresses (individual);
    }

    private void set_phone_numbers (Folks.Individual individual) {
        phone_grid.clear ();
        foreach (var phonedetail in individual.phone_numbers) {
            var types = phonedetail.get_parameter_values (Folks.AbstractFieldDetails.PARAM_TYPE);
            if (types == null) {
                phone_grid.add_parameter (new PhoneEntry (_("Other:"), (string)phonedetail.value));
                continue;
            }

            foreach (var typ in types) {
                switch (typ) {
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_HOME):
                        phone_grid.add_parameter (new PhoneEntry (_("Home:"), (string)phonedetail.value));
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_WORK):
                        phone_grid.add_parameter (new PhoneEntry (_("Work:"), (string)phonedetail.value));
                        continue;
                    case ("cell"):
                        phone_grid.add_parameter (new PhoneEntry (_("Mobile:"), (string)phonedetail.value));
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_OTHER):
                        phone_grid.add_parameter (new PhoneEntry (_("Other:"), (string)phonedetail.value));
                        continue;
                    default:
                        phone_grid.add_parameter (new PhoneEntry (typ, (string)phonedetail.value));
                        continue;
                }
            }
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
            var types = postaldetail.get_parameter_values (Folks.AbstractFieldDetails.PARAM_TYPE);
            if (types == null) {
                address_grid.add_parameter (new AddressEntry (_("Other:"), postaldetail.value));
                continue;
            }

            foreach (var typ in types) {
                switch (typ) {
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_HOME):
                        address_grid.add_parameter (new AddressEntry (_("Home:"), postaldetail.value));
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_WORK):
                        address_grid.add_parameter (new AddressEntry (_("Work:"), postaldetail.value));
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_OTHER):
                        address_grid.add_parameter (new AddressEntry (_("Other:"), postaldetail.value));
                        continue;
                    default:
                        address_grid.add_parameter (new AddressEntry (typ, postaldetail.value));
                        continue;
                }
            }
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
            var types = emaildetail.get_parameter_values (Folks.AbstractFieldDetails.PARAM_TYPE);
            if (types == null) {
                email_grid.add_parameter (new MailAddressEntry (_("Other:"), (string)emaildetail.value));
                continue;
            }

            foreach (var typ in types) {
                switch (typ) {
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_HOME):
                        email_grid.add_parameter (new MailAddressEntry (_("Home:"), (string)emaildetail.value));
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_WORK):
                        email_grid.add_parameter (new MailAddressEntry (_("Work:"), (string)emaildetail.value));
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_OTHER):
                        email_grid.add_parameter (new MailAddressEntry (_("Other:"), (string)emaildetail.value));
                        continue;
                    case ("personal"):
                        email_grid.add_parameter (new MailAddressEntry (_("Personal:"), (string)emaildetail.value));
                        continue;
                    default:
                        email_grid.add_parameter (new MailAddressEntry (typ, (string)emaildetail.value));
                        continue;
                }
            }
        }

        if (individual.email_addresses.size <= 0) {
            email_grid.hide ();
        } else {
            email_grid.show_all ();
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
    }

    private void set_name_label_text (string name) {
        name_label.set_markup ("<span size=\"large\"><b>%s</b></span>".printf (Markup.escape_text (name)));
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

        return "<big><b>%s</b></big>".printf (Markup.escape_text (role_format));
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
        header_label.xalign = 0;

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

public class PersonEntry : Gtk.ListBox {
    public PersonEntry () {
        
    }

    public void set_contact (Folks.Individual individual) {
        clear ();
        if (individual.birthday != null) {
            if (individual.birthday.get_year () > 1900) {
                add (make_entry (_("Birthday:"), individual.birthday.format (Granite.DateTime.get_default_date_format (false, true, true))));
            } else {
                add (make_entry (_("Birthday:"), individual.birthday.format (Granite.DateTime.get_default_date_format ())));
            }
            show_all ();
        } else {
            hide ();
        }
    }

    private Gtk.ListBoxRow make_entry (string tag, string entry) {
        var container = new Gtk.Grid ();
        container.row_spacing = 12;
        container.column_spacing = 6;

        var tag_label = new Gtk.Label ("<b>%s</b>".printf (tag));
        tag_label.use_markup = true;

        var entry_label = new Gtk.Label (entry);

        container.attach (tag_label, 0, 0, 1, 1);
        container.attach (entry_label, 1, 0, 1, 1);

        var box = new Gtk.ListBoxRow ();
        box.add (container);

        return box;
    }

    private void clear () {
        forall ((widget) => {
            widget.destroy ();
        });
    }
}

public class AddressEntry : Gtk.ListBoxRow {
    private GtkChamplain.Embed champlain_embed;
    private Dexter.Marker point;

    public AddressEntry (string kind, Folks.PostalAddress address) {
        var container = new Gtk.Grid ();
        container.expand = true;
        container.row_spacing = 6;
        container.column_spacing = 12;
        container.row_homogeneous = true;

        var kind_label = new Gtk.Label ("<b>%s</b>".printf (kind));
        kind_label.use_markup = true;
        kind_label.xalign = 1;

        var locality_label = new Gtk.Label (address.locality);
        locality_label.xalign = 0;
        locality_label.hexpand = true;

        champlain_embed = new GtkChamplain.Embed ();
        var view = champlain_embed.champlain_view;
        var marker_layer = new Champlain.MarkerLayer.full (Champlain.SelectionMode.SINGLE); 
        view.add_layer (marker_layer);

        point = new Dexter.Marker ();

        view.zoom_level = 14;
        view.center_on (point.latitude, point.longitude);
        marker_layer.add_marker (point);

        int current_line = 0;

        if (address.street != null && address.street != "") {
            var street_label = new Gtk.Label (address.street);
            container.attach (street_label, 3, current_line++, 4, 1);
        }

        if (address.region != null && address.region != "") {
            var region_label = new Gtk.Label (address.region);
            container.attach (region_label, 3, current_line++, 4, 1);
        }

        container.attach (champlain_embed, 0, current_line, 7, 6);
        add (container);

        compute_location.begin (address.to_string ());
    }

    private async void compute_location (string loc) {
        var forward = new Geocode.Forward.for_string (loc);
        try {
            forward.set_answer_count (1);
            var places = forward.search ();
            foreach (var place in places) {
                point.latitude = place.location.latitude;
                point.longitude = place.location.longitude;
                Idle.add (() => {
                    champlain_embed.champlain_view.go_to (point.latitude, point.longitude);
                    return false;
                });
            }
        } catch (Error error) {
            debug (error.message);
        }
    }
}

//TODO Subclass from generic entry
public class PhoneEntry : Gtk.ListBoxRow {
    public PhoneEntry (string kind, string number) {
        var container = new Gtk.Grid ();
        container.hexpand = true;
        container.vexpand = true;
        container.row_spacing = 6;
        container.column_spacing = 12;
        container.set_column_homogeneous (true);

        var kind_label = new Gtk.Label ("<b>%s</b>".printf (kind));
        kind_label.use_markup = true;
        kind_label.xalign = 1;

        var number_label = new Gtk.Label (number);
        number_label.xalign = 0;
        number_label.hexpand = true;

        container.attach (kind_label, 0, 0, 2, 1);
        container.attach (number_label, 3, 0, 4, 1);

        add (container);
    }
}

//TODO Subclass from generic Entry
public class MailAddressEntry : Gtk.ListBoxRow {
    public MailAddressEntry (string kind, string address) {
        var container = new Gtk.Grid ();
        container.hexpand = true;
        container.vexpand = true;
        container.row_spacing = 6;
        container.column_spacing = 12;
        container.set_column_homogeneous (true);

        var kind_label = new Gtk.Label ("<b>%s</b>".printf (kind));
        kind_label.use_markup = true;
        kind_label.xalign = 1;

        var address_label = new Gtk.Label (address);
        address_label.xalign = 0;
        address_label.hexpand = true;

        container.attach (kind_label, 0, 0, 2, 1);
        container.attach (address_label, 3, 0, 4, 1);

        //TODO Set Mailaction

        add (container);
    }
}