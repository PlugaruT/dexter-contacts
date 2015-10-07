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

/* 
 * This widget auto-updates his image when the contact changes his avatar.
 * It draws circle icons following the current trend.
 */
public class Dexter.Widgets.ContactImage : Gtk.Stack {
    private Gtk.IconSize icon_size;
    private Gtk.Widget current_image = null;
    private bool default_avatar = true;
    private int PADDING = 3;
    
    public ContactImage (Gtk.IconSize icon_size, Folks.Individual? individual = null) {
        this.icon_size = icon_size;
        valign = Gtk.Align.CENTER;
        halign = Gtk.Align.CENTER;
        transition_type = Gtk.StackTransitionType.CROSSFADE;

        var force_size_image = new Gtk.Image.from_icon_name ("avatar-default", icon_size);
        add (force_size_image);
        show_default_avatar ();

        if (individual != null) {
            add_contact (individual);
        }

        show_all ();
    }

    public void add_contact (Folks.Individual individual) {
        if (individual.avatar != null && default_avatar == true) {
            show_avatar_from_loadable_icon (individual.avatar);
        } else {
            show_default_avatar ();
        }

        individual.notify["avatar"].connect (() => {
            if (individual.avatar != null && default_avatar == true) {
                show_avatar_from_loadable_icon (individual.avatar);
            } else {
                show_default_avatar ();
            }
        });
    }

    private void show_avatar_from_loadable_icon (LoadableIcon icon) {
        var box = new Gtk.EventBox ();
        box.get_style_context ().add_class ("avatar");
        box.show_all ();
        box.draw.connect ((cr) => {
            try {
                var width = box.get_allocated_width ();
                var height = box.get_allocated_height ();
                int size = (int) double.min (width, height) - 2* PADDING;
                var style_context = box.get_style_context ();
                var stream = icon.load (size, null);
                var img_pixbuf = new Gdk.Pixbuf.from_stream_at_scale (stream, size, size, true);
                cr.set_operator (Cairo.Operator.OVER);
                var x = (width-size)/2;
                var y = (height-size)/2;
                Granite.Drawing.Utilities.cairo_rounded_rectangle (cr, x, y, size, size, size/2);
                Gdk.cairo_set_source_pixbuf (cr, img_pixbuf, x, y);
                cr.fill_preserve ();
                style_context.render_background (cr, x, y, size, size);
                style_context.render_frame (cr, x, y, size, size);
            } catch (Error e) {
                critical (e.message);
                return false;
            }

            return true;
        });
        show_avatar_image (box);
    }

    private void show_default_avatar () {
        show_avatar_image (new Gtk.Image.from_icon_name ("avatar-default", icon_size));
        default_avatar = true;
    }

    private void show_avatar_image (Gtk.Widget image) {
        add (image);
        image.show ();
        set_visible_child (image);
        if (current_image != null)
            current_image.destroy ();
        current_image = image;
    }
}
