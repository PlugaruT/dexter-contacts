public class Dexter.ContactDialog : Gtk.Dialog {
    public enum Type {
        ADD,
        EDIT
    }

    private Type contact_type { get; private set; }

    private Gtk.Stack stack;
    private Granite.Widgets.ModeButton mode_button;

    private Gtk.Grid info_panel;

    private Gtk.Grid location_panel;
    private GtkChamplain.Embed embed_map;
    private Marker point;
    private bool map_selected = false;

    private Gtk.Grid avatar_panel;
    private Gtk.Grid links_panel;

    public ContactDialog () {
        Object (use_header_bar: 1);

        //if (date_time != null) {
            title = _("Add Contact");
            contact_type = Type.ADD;
        /*} else {
            title = _("Edit Contact");
            contact_type = Type.EDIT;
        }*/

        // Dialog properties
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        type_hint = Gdk.WindowTypeHint.DIALOG;

        // Build dialog
        build_dialog (contact_type == Type.ADD);
    }

    void build_dialog (bool add_event) {
        var grid = new Gtk.Grid ();
        grid.row_spacing = 6;
        grid.column_spacing = 12;
        stack = new Gtk.Stack ();

        mode_button = new Granite.Widgets.ModeButton ();
        var info_icon = new Gtk.Image.from_icon_name ("office-address-book-symbolic", Gtk.IconSize.BUTTON);
        info_icon.tooltip_text = _("General Informations");
        mode_button.append (info_icon);
        var location_icon = new Gtk.Image.from_icon_name ("mark-location-symbolic", Gtk.IconSize.BUTTON);
        location_icon.tooltip_text = _("Location");
        mode_button.append (location_icon);
        var avatar_icon = new Gtk.Image.from_icon_name ("insert-image-symbolic", Gtk.IconSize.BUTTON);
        avatar_icon.tooltip_text = _("Picture");
        mode_button.append (avatar_icon);
        var links_icon = new Gtk.Image.from_icon_name ("insert-link-symbolic", Gtk.IconSize.BUTTON);
        links_icon.tooltip_text = _("Linked to");
        mode_button.append (links_icon);
        mode_button.selected = 0;
        mode_button.mode_changed.connect ((widget) => {
            switch (mode_button.selected) {
                case 0:
                    stack.set_visible_child_name ("infopanel");
                    break;
                case 1:
                    stack.set_visible_child_name ("locationpanel");
                    break;
                case 2:
                    stack.set_visible_child_name ("avatarpanel");
                    break;
                case 3:
                    stack.set_visible_child_name ("linkspanel");
                    break;
            }
        });

        build_infopanel ();
        build_locationpanel ();
        build_avatarpanel ();
        build_linkspanel ();

        stack.add_named (info_panel, "infopanel");
        stack.add_named (location_panel, "locationpanel");
        stack.add_named (avatar_panel, "avatarpanel");
        stack.add_named (links_panel, "linkspanel");

        var buttonbox = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
        buttonbox.margin_right = 12;
        buttonbox.margin_left = 12;
        buttonbox.baseline_position = Gtk.BaselinePosition.CENTER;
        buttonbox.set_layout (Gtk.ButtonBoxStyle.END);

        Gtk.Button create_button = new Gtk.Button ();
        create_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        create_button.clicked.connect (save_dialog);
        if (add_event == true) {
            create_button.label = _("Create Contact");
        } else {
            create_button.label = _("Save Changes");
        }

        if (add_event == false) {
            var delete_button = new Gtk.Button.with_label (_("Delete Contact"));
            delete_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            delete_button.clicked.connect (remove_contact);
            buttonbox.add (delete_button);
            buttonbox.set_child_secondary (delete_button, true);
            buttonbox.set_child_non_homogeneous (delete_button, true);
        }

        buttonbox.add (create_button);

        grid.attach (stack, 0, 0, 1, 1);
        grid.attach (buttonbox, 0, 1, 1, 1);

        ((Gtk.Container)get_content_area ()).add (grid);
        ((Gtk.HeaderBar)get_header_bar ()).set_custom_title (mode_button);

        stack.set_visible_child_name ("infopanel");
    }

    private void build_infopanel () {
        info_panel = new Gtk.Grid ();
    }

    private void build_locationpanel () {
        location_panel = new Gtk.Grid ();

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
        location_panel.add (embed_map);
    }

    private void build_avatarpanel () {
        avatar_panel = new Gtk.Grid ();
    }

    private void build_linkspanel () {
        links_panel = new Gtk.Grid ();
    }

    private void save_dialog () {
        this.destroy();
    }

    private void remove_contact () {
        this.destroy();
    }
}

public class Dexter.Marker : Champlain.Marker {
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