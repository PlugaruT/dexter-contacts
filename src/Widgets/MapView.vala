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

public class Dexter.Widgets.MapView : Gtk.Frame {
    private GtkChamplain.Embed embed_map;
    private Marker point;
    private bool map_selected = false;
    public MapView () {
        
    }

    construct {
        embed_map = new GtkChamplain.Embed ();
        var view = embed_map.champlain_view;
        var marker_layer = new Champlain.MarkerLayer.full (Champlain.SelectionMode.SINGLE);
        view.add_layer (marker_layer);

        // Load the location
        point = new Marker ();
        point.drag_finish.connect (() => {
            map_selected = true;
        });
        view.zoom_level = 8;
        view.center_on (point.latitude, point.longitude);
        marker_layer.add_marker (point);
        add (embed_map);
    }

    public void set_point (double latitude, double longitude, bool go_to = true) {
        point.latitude = latitude;
        point.longitude = longitude;
        if (go_to) {
            embed_map.champlain_view.go_to (point.latitude, point.longitude);
        }
    }

    public class Marker : Champlain.Marker {
        public Marker () {
            try {
                Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file ("%s/LocationMarker.svg".printf (Build.PKGDATADIR));
                Clutter.Image image = new Clutter.Image ();
                image.set_data (pixbuf.get_pixels (),
                              pixbuf.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
                              pixbuf.width,
                              pixbuf.height,
                              pixbuf.rowstride);
                content = image;
                set_size (pixbuf.width, pixbuf.height);
                translation_x = -pixbuf.width/2;
                translation_y = -pixbuf.height;
            } catch (Error e) {
                critical (e.message);
            }
        }
    }
}
