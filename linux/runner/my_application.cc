#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#include <gio/gio.h>
#include <gtk/gtk.h>
#include <glib.h>
#include <glib-object.h>
#include <cstring>
#include <cstdlib>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  GFile* open_file;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  g_clear_pointer(&self->open_file, g_object_unref);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

// Load a window icon from the bundled assets directory.
static GdkPixbuf* load_app_icon(void) {
  GdkPixbuf* pixbuf = nullptr;
  GError* error = nullptr;

  // 1) Try embedded GResource first (for apps built with --dump-assets).
  pixbuf = gdk_pixbuf_new_from_resource("/assets/frames_fullbody/CRS_icon_squinted_eye.png",
                                        &error);
  if (pixbuf != nullptr) {
    return pixbuf;
  }
  if (error != nullptr) {
    g_warning("app icon: resource lookup failed: %s", error->message);
    g_error_free(error);
    error = nullptr;
  }

  // 2) Fall back to filesystem path (Flutter bundle layout):
  //    <bundle>/data/flutter_assets/assets/frames_fullbody/CRS_icon_squinted_eye.png
  const char* assets_dir = g_getenv("FLUTTER_ASSETS_DIR");
  if (assets_dir == nullptr || std::strlen(assets_dir) == 0) {
    // Default: relative to the bundle directory (running from bundle root)
    assets_dir = ".";  // current working directory when launched from bundle
  }
  // Build path: <assets_dir>/data/flutter_assets/assets/frames_fullbody/...
  const gchar* icon_rel = "data/flutter_assets/assets/frames_fullbody/CRS_icon_squinted_eye.png";
  g_autofree gchar* icon_path = g_build_filename(assets_dir, icon_rel, nullptr);
  if (icon_path != nullptr) {
    pixbuf = gdk_pixbuf_new_from_file(icon_path, &error);
    if (pixbuf != nullptr) {
      g_message("app icon: loaded from filesystem: %s", icon_path);
      return pixbuf;
    }
    if (error != nullptr) {
      g_warning("app icon: filesystem load failed: %s", error->message);
      g_error_free(error);
      error = nullptr;
    }
  }

  g_warning("failed to load app icon from both resource and filesystem");
  return nullptr;
}

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  GtkWidget* window = gtk_widget_get_toplevel(GTK_WIDGET(view));

  // Apply the application icon to the native window.
  GdkPixbuf* icon = load_app_icon();
  if (icon != nullptr) {
    GdkPixbuf* scaled = gdk_pixbuf_scale_simple(icon, 32, 32,
                                                 GDK_INTERP_BILINEAR);
    gtk_window_set_icon(GTK_WINDOW(window), scaled);
    g_object_unref(scaled);
    g_object_unref(icon);
  }

  // If a file was opened with this instance, print its path for diagnostic
  // purposes. The Dart side can also receive it via a method channel
  // if needed (see the Linux channel setup).
  if (self->open_file != nullptr) {
    const gchar* file_path = g_file_get_path(self->open_file);
    g_message("Amadeus received file-open request: %s", file_path);
    g_free((gpointer)file_path);
    self->open_file = nullptr;
  }

  gtk_widget_show(window);
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "amadeus");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "amadeus");
  }

  gtk_window_set_default_size(window, 1280, 720);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  // If the application was invoked with additional arguments, treat the first
  // one as a file to open (e.g. from a file manager double-click or .desktop
  // file association with MimeType).  The running instance receives this
  // invocation when the app is already active (NON_UNIQUE flag).
  self->open_file = nullptr;
  if (self->dart_entrypoint_arguments != nullptr &&
      self->dart_entrypoint_arguments[0] != nullptr &&
      g_strcmp0(self->dart_entrypoint_arguments[0], "open") == 0) {
    // Arguments: [binary, "open", <file-path-or-uri>, ...]
    if (self->dart_entrypoint_arguments[1] != nullptr) {
      g_autoptr(GFile) file = g_file_new_for_uri(
          self->dart_entrypoint_arguments[1]);
      if (file != nullptr && g_file_query_exists(file, nullptr)) {
        self->open_file = g_object_ref(file);
      }
    }
  } else {
    // Plain invocation (e.g. double-clicked from file manager with a
    // MimeType association, or `amadeus file.txt`).  The first extra
    // argument is treated as the file to open.
    if (self->dart_entrypoint_arguments[0] != nullptr) {
      g_autoptr(GFile) file = g_file_new_for_path(self->dart_entrypoint_arguments[0]);
      if (file != nullptr && g_file_query_exists(file, nullptr)) {
        self->open_file = g_object_ref(file);
      }
    }
  }

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // Perform any actions required at application startup.
  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // Perform any actions required at application shutdown.
  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE, nullptr));
}
