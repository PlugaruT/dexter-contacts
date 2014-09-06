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
    private Widgets.ContactImage avatar;
    private Body address_grid;
    private Body phone_grid;
    private Body email_grid;
    private PersonEntry person_box;
    private Gtk.Label name_label;
    private Gtk.Label role_label;

    public ContactView () {
        orientation = Gtk.Orientation.VERTICAL;
        expand = true;
        margin = 12;
        row_spacing = 12;
        var name_grid = new Gtk.Grid ();

        avatar = new Widgets.ContactImage (Gtk.IconSize.DIALOG);

        name_label = new Gtk.Label ("");
        name_label.use_markup = true;
        name_label.margin_left = 12;

        role_label = new Gtk.Label ("");
        role_label.use_markup = true;

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

        name_grid.attach (avatar, 0, 0, 2, 2);
        name_grid.attach (name_label, 2, 0, 1, 3);
        name_grid.attach (role_label, 2, 1, 1, 3);

        var centered_name_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        centered_name_box.hexpand = true;
        centered_name_box.pack_start (name_grid, true, true, 6);
        
        person_box = new PersonEntry ();
        address_grid = new Body (_("Address:"));
        phone_grid = new Body (_("Phone:"));
        email_grid = new Body (_("Email:"));

        var container = new Gtk.ScrolledWindow (null, null);
        var sub_grid = new Gtk.Grid ();

        sub_grid.expand = true;
        sub_grid.orientation = Gtk.Orientation.VERTICAL;
        sub_grid.margin = 18;
        sub_grid.row_spacing = 12;
        sub_grid.set_column_homogeneous (true);

	    var left_grid = new Gtk.Grid ();
	    var right_grid = new Gtk.Grid ();

        left_grid.attach (person_box, 0, 0, 3, 3);
	    left_grid.attach (address_grid, 0, 3, 3, 3);
	    right_grid.attach (phone_grid, 0, 0, 3, 3);
	    right_grid.attach (email_grid, 0, 3, 6, 3);

        sub_grid.attach (left_grid, 0, 0, 5, 5);
        sub_grid.attach (right_grid, 5, 0, 5, 5);

        container.add (sub_grid);

        add (centered_name_box);
        add (container);
    }

    public void set_contact (Folks.Individual individual) {
        set_name_label_text (individual.full_name);

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
        
        person_box.set_contact (individual);        

        avatar.add_contact (individual);
        role_label.label = role_string;

        /*
         * Emails
         */
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
            show_all ();
        }

        /*
         * Phone numbers
         */
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
            show_all ();
        }

        /*
         * Addresses
         */
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
            show_all ();
        }
    }

    private void set_name_label_text (string name) {
        name_label.set_markup ("<big>%s</big>".printf (Markup.escape_text (name)));
    }

    private string format_role (Folks.Role role) {
        return "";
    }
}

public class Dexter.Body : Gtk.Grid {
    private Gtk.Label header_label;
    private Gtk.ListBox list;

    public Body (string header) {
        hexpand = true;
        row_spacing = 12;
        column_spacing = 6;

        header_label = new Gtk.Label ("<big><b>%s</b></big>".printf (header));
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
        
        var name = individual.structured_name;
           
        if (name != null) {
            if(name.given_name != null)
                add (make_entry (_("Given name"), name.given_name));
                  
            if (name.family_name != null)
                add (make_entry (_("Family name"), name.family_name));
        }
           
        if (individual.birthday != null)
            add (make_entry (_("Birthday"), individual.birthday.format ("%d.%m.%Y")));   
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
        container.hexpand = true;
        container.vexpand = true;
        container.row_spacing = 12;
        container.column_spacing = 6;
        container.row_homogeneous = true;

        var kind_label = new Gtk.Label ("<b>%s</b>".printf (kind));
        kind_label.use_markup = true;

        

        var locality_label = new Gtk.Label (address.locality);


        champlain_embed = new GtkChamplain.Embed ();
        var view = champlain_embed.champlain_view;
        var marker_layer = new Champlain.MarkerLayer.full (Champlain.SelectionMode.SINGLE); 
        view.add_layer (marker_layer);
        
        point = new Dexter.Marker ();
        
        compute_location.begin (address.to_string ());

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
    }
    
    private async void compute_location (string loc) {
        SourceFunc callback = compute_location.callback;    
   
        var forward = new Geocode.Forward.for_string (loc);
            
        try {
            forward.set_answer_count (1);
            var places = forward.search ();
            foreach (var place in places) {
                point.latitude = place.location.latitude;
                point.longitude = place.location.longitude;
                champlain_embed.champlain_view.go_to (point.latitude, point.longitude);
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
        container.row_spacing = 12;
        container.column_spacing = 6;
        container.set_column_homogeneous (true);

        var kind_label = new Gtk.Label ("<b>%s</b>".printf (kind));
        kind_label.use_markup = true;

        var number_label = new Gtk.Label (number);

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
        container.row_spacing = 12;
        container.column_spacing = 6;
        container.set_column_homogeneous (true);

        var kind_label = new Gtk.Label ("<b>%s</b>".printf (kind));
        kind_label.use_markup = true;

        var address_label = new Gtk.Label (address);

        container.attach (kind_label, 0, 0, 2, 1);
        container.attach (address_label, 3, 0, 4, 1);

        //TODO Set Mailaction

        add (container);
    }
}