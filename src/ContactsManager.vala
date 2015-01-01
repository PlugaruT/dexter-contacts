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

public class Dexter.ContactsManager : GLib.Object {
    private static ContactsManager? contacts_manager = null;
    public static ContactsManager get_default () {
        if (contacts_manager == null)
            contacts_manager = new ContactsManager ();
        return contacts_manager;
    }

    public signal void individual_added (Folks.Individual individual);
    public signal void individual_removed (Folks.Individual individual);
    public signal void individual_modified (Folks.Individual old_individual, Folks.Individual new_individual);
    public signal void prepared ();

    private Folks.IndividualAggregator individual_aggregator;

    private ContactsManager () {
        individual_aggregator = Folks.IndividualAggregator.dup ();
        individual_aggregator.individuals_changed_detailed.connect (individuals_has_changed);
        individual_aggregator.prepare.begin ();
        individual_aggregator.notify["is-quiescent"].connect (() => {prepared ();});
    }

    public void individuals_has_changed (Gee.MultiMap<Folks.Individual?,Folks.Individual?> changes) {
        changes.map_iterator ().foreach ((key, val) => {
            // It's an addition if key is null
            if (key == null) {
                if (val.is_user == true)
                    return true;

                individual_added (val);
                return true;
            }

            // It's a removal if value is null
            if (val == null) {
                individual_removed (key);
                return true;
            }

            // Otherwise it's a modification
            individual_modified (key, val);
            return true;
        });
    }

    public List<Folks.Individual> get_contacts () {
        var individuals_list = new List<Folks.Individual> ();
        foreach (var individual in individual_aggregator.individuals.values) {
            individuals_list.append (individual);
        }

        return individuals_list;
    }
}
