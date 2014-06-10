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

public class Dexter.ContactsManager : GLib.Object {
    private static ContactsManager? contacts_manager = null;
    public static ContactsManager get_default () {
        if (contacts_manager == null)
            contacts_manager = new ContactsManager ();
        return contacts_manager;
    }

    public signal void individual_added (Folks.Individual individual);
    public signal void individual_removed (Folks.Individual individual);

    private Gee.TreeMap<string, Folks.Individual> individuals;
    private ContactsManager () {
        individuals = new Gee.TreeMap<string, Folks.Individual> (null, null);
        load_contacts.begin ();
    }

    private async void load_contacts () {
        var individual_aggregator = Folks.IndividualAggregator.dup ();
        try {
            yield individual_aggregator.prepare ();
        } catch (Error e) {
            critical (e.message);
        }
        individual_aggregator.individuals_changed_detailed.connect ((changes) => {individuals_changed (changes);});
    }

    private void individuals_changed (Gee.MultiMap<Folks.Individual?, Folks.Individual?> changes) {
        for (var iterator = changes.map_iterator (); iterator.next(); iterator.has_next ()) {
            individual_added (iterator.get_value ());
        }
    }
}