using Gtk;

class Slack.Main : GLib.Object {

    public static int main(string[] args) {
        Gtk.init (ref args);

        var client = new SlackClient ();
        // Write to stdout
        client.write_user_msg.connect ((user, message) => {
            stdout.printf("%s sent to channel: %s\n", user.name, message);
        });
        var connected_user = new SlackUser("clofresh");
        client.login(connected_user);

        GLib.Timeout.add(3000, () => {
            var fake_user = new SlackUser("fake_guy");
            client.write_user_msg(fake_user, "hey!");
            return true;
        });

        client.show_all ();

        Gtk.main ();
        return 0;
    }
}

public class SlackUser : Object {
    private string _name;
    public string name {
        get { return _name; }
    }
    public SlackUser(string name) {
        this._name = name;
    }
}

public class SlackClient : Window {
    public signal void write_user_msg(SlackUser user, string message);

    private Gtk.Button send_button;
    private Gtk.TextView input_view;

    public SlackClient () {
        // Prepare Gtk.Window:
        this.title = "My Gtk.TextView";
        this.window_position = Gtk.WindowPosition.CENTER;
        this.destroy.connect (Gtk.main_quit);
        this.set_default_size (400, 400);

        // Box:
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 1);
        this.add (box);

        var channel_window = new Gtk.ScrolledWindow (null, null);
        var channel_view = new Gtk.TextView ();
        channel_view.set_wrap_mode (Gtk.WrapMode.WORD);
        channel_view.buffer.text = "Welcome\n";
        box.pack_start (channel_window, true, true, 0);
        channel_window.add (channel_view);

        // A ScrolledWindow:
        var input_window = new Gtk.ScrolledWindow (null, null);
        box.pack_start (input_window, true, true, 0);

        // The TextView:
        this.input_view = new Gtk.TextView ();
        this.input_view.set_wrap_mode (Gtk.WrapMode.WORD);
        this.input_view.buffer.text = "";
        input_window.add (this.input_view);

        // Write to channel buffer
        this.write_user_msg.connect ((user, message) => {
            // Insert the message at the end
            Gtk.TextIter ? insert_iter = null;
            channel_view.buffer.get_end_iter(out insert_iter);
            var line = user.name + ": " + message + "\n";
            channel_view.buffer.insert(ref insert_iter, line, line.length);

            // Scroll to the bottom
            var vadj = channel_window.vadjustment;
            channel_window.vadjustment.set_value(vadj.upper - vadj.page_size);
        });

        // A Button:
        this.send_button = new Gtk.Button.with_label ("Send");
        box.pack_start (this.send_button, false, true, 0);
    }

    public void login(SlackUser user) {
        this.send_button.clicked.connect (() => {
            this.write_user_msg(user, this.input_view.buffer.text);
            this.input_view.buffer.text = "";
        });
    }
}

/*
   var iter = Gtk.TextIter();
   input_view.buffer.get_start_iter(out iter);
   Gdk.Pixbuf image;
   try {
   image = new Gdk.Pixbuf.from_file("image.jpg");
   } catch (Error e) {
   error("%s", e.message);
   }
   image = image.scale_simple(32, 32, Gdk.InterpType.NEAREST);
   input_view.buffer.insert_pixbuf (iter, image);
 */
