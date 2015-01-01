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

public class Dexter.Widgets.EntryGrid : Gtk.Grid {
    private int y = 0;
    private Gtk.Grid content_grid;
    public EntryGrid (string title) {
        row_spacing = 6;
        column_spacing = 12;
        var title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class ("category-label");
        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.hexpand = true;
        separator.valign = Gtk.Align.CENTER;
        content_grid = new Gtk.Grid ();
        content_grid.row_spacing = 6;
        content_grid.column_spacing = 12;
        content_grid.margin_start = 12;
        var expand_grid = new Gtk.Grid ();
        expand_grid.vexpand = true;
        attach (title_label, 0, 0, 1, 1);
        attach (separator, 1, 0, 1, 1);
        attach (content_grid, 0, 1, 2, 1);
        attach (expand_grid, 0, 2, 2, 1);
    }

    public void add_parameters (Gtk.Widget start, Gtk.Widget end) {
        content_grid.attach (start, 0, y, 1, 1);
        content_grid.attach (end, 1, y, 1, 1);
        y++;
    }

    public void add_parameter (Gtk.Widget widget) {
        content_grid.attach (widget, 0, y, 2, 1);
        y++;
    }
    
    public void clear () {
        y = 0;
        foreach (var child in content_grid.get_children ()) {
            child.destroy ();
        }
    }
}
