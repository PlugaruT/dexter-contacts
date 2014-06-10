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

public class Dexter.ContactView : Gtk.Grid {
    private Gtk.Image avatar;
    private FieldBody address_grid;
    private FieldBody phone_grid;
    private FieldBody email_grid;
    private Gtk.Label name_label;
    private Gtk.Label role_label;
    public ContactView () {
        orientation = Gtk.Orientation.VERTICAL;
        expand = true;
        margin = 12;
        row_spacing = 12;
        var name_grid = new Gtk.Grid ();
        avatar = new Gtk.Image.from_icon_name ("avatar-default", Gtk.IconSize.DIALOG);
        name_label = new Gtk.Label ("");
        name_label.use_markup = true;
        role_label = new Gtk.Label ("");
        role_label.use_markup = true;
        name_grid.attach (avatar, 0, 0, 1, 2);
        name_grid.attach (name_label, 1, 0, 1, 1);
        name_grid.attach (role_label, 1, 1, 1, 1);
        var centered_name_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        centered_name_box.hexpand = true;
        centered_name_box.set_center_widget (name_grid);
        address_grid = new FieldBody (_("Address:"));
        phone_grid = new FieldBody (_("Phone:"));
        email_grid = new FieldBody (_("Email:"));
        add (centered_name_box);
        add (address_grid);
        add (phone_grid);
        add (email_grid);
    }

    public void set_contact (Folks.Individual individual) {
        name_label.label = "<big>%s</big>".printf (individual.full_name);

        /*
         * Role Label
         */
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

        /*
         * Emails
         */
        email_grid.clear ();
        foreach (var emaildetail in individual.email_addresses) {
            var types = emaildetail.get_parameter_values (Folks.AbstractFieldDetails.PARAM_TYPE);
            if (types == null) {
                email_grid.add_parameter (_("Other:"), (string)emaildetail.value);
                continue;
            }

            foreach (var typ in types) {
                switch (typ) {
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_HOME):
                        email_grid.add_parameter (_("Home:"), (string)emaildetail.value);
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_WORK):
                        email_grid.add_parameter (_("Work:"), (string)emaildetail.value);
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_OTHER):
                        email_grid.add_parameter (_("Other:"), (string)emaildetail.value);
                        continue;
                    case ("personal"):
                        email_grid.add_parameter (_("Personal:"), (string)emaildetail.value);
                        continue;
                    default:
                        email_grid.add_parameter (typ, (string)emaildetail.value);
                        continue;
                }
            }
        }

        if (individual.email_addresses.size <= 0) {
            email_grid.hide ();
        } else {
            show_all ();
        }

        /*
         * Phone numbers
         */
        phone_grid.clear ();
        foreach (var phonedetail in individual.phone_numbers) {
            var types = phonedetail.get_parameter_values (Folks.AbstractFieldDetails.PARAM_TYPE);
            if (types == null) {
                phone_grid.add_parameter (_("Other:"), (string)phonedetail.value);
                continue;
            }

            foreach (var typ in types) {
                switch (typ) {
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_HOME):
                        phone_grid.add_parameter (_("Home:"), (string)phonedetail.value);
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_WORK):
                        phone_grid.add_parameter (_("Work:"), (string)phonedetail.value);
                        continue;
                    case ("cell"):
                        phone_grid.add_parameter (_("Mobile:"), (string)phonedetail.value);
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_OTHER):
                        phone_grid.add_parameter (_("Other:"), (string)phonedetail.value);
                        continue;
                    default:
                        phone_grid.add_parameter (typ, (string)phonedetail.value);
                        continue;
                }
            }
        }

        if (individual.phone_numbers.size <= 0) {
            phone_grid.hide ();
        } else {
            show_all ();
        }

        /*
         * Addresses
         */
        address_grid.clear ();
        foreach (var postaldetail in individual.postal_addresses) {
            var types = postaldetail.get_parameter_values (Folks.AbstractFieldDetails.PARAM_TYPE);
            if (types == null) {
                address_grid.add_parameter (_("Other:"), (string)postaldetail.value);
                continue;
            }

            foreach (var typ in types) {
                switch (typ) {
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_HOME):
                        address_grid.add_parameter (_("Home:"), (string)postaldetail.value);
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_WORK):
                        address_grid.add_parameter (_("Work:"), (string)postaldetail.value);
                        continue;
                    case (Folks.AbstractFieldDetails.PARAM_TYPE_OTHER):
                        address_grid.add_parameter (_("Other:"), (string)postaldetail.value);
                        continue;
                    default:
                        address_grid.add_parameter (typ, (string)postaldetail.value);
                        continue;
                }
            }
        }

        if (individual.postal_addresses.size <= 0) {
            address_grid.hide ();
        } else {
            show_all ();
        }
    }

    private string format_role (Folks.Role role) {
        return "";
    }
}

public class Dexter.FieldBody : Gtk.Grid {
    private Gtk.Label header_label;
    int row = 1;
    public FieldBody (string header) {
        hexpand = true;
        row_spacing = 12;
        column_spacing = 6;
        header_label = new Gtk.Label ("<b>%s</b>".printf (header));
        header_label.use_markup = true;
        header_label.xalign = 0;
        attach (header_label, 0, 0, 3, 1);
    }

    public void add_parameter (string left_string, string right_string) {
        var left_label = new Gtk.Label (left_string);
        left_label.xalign = 1;
        var right_label = new Gtk.Label (right_string);
        right_label.xalign = 0;
        attach (left_label, 1, row, 1, 1);
        attach (right_label, 2, row, 1, 1);
        row++;
    }

    public void clear () {
        forall ((widget) => {
            if (widget != header_label)
                widget.destroy ();
        });
    }
}