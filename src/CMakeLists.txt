
set (CONFIG_FILE ${CMAKE_CURRENT_BINARY_DIR}/config.vala)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/config.vala.cmake ${CONFIG_FILE})

vala_precompile (VALA_C ${CMAKE_PROJECT_NAME}
    ${CONFIG_FILE}
    Window.vala
    ContactsList.vala
    ContactsManager.vala
    ContactView.vala
    Dialogs/ContactDialog.vala
    Widgets/ContactImage.vala
PACKAGES
    gobject-2.0
    glib-2.0
    gio-2.0
    gee-0.8
    gtk+-3.0
    granite
    folks
    champlain-gtk-0.12
    champlain-0.12
    clutter-1.0
    geocode-glib-1.0
OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --target-glib=2.32
    --thread
)

add_executable (${CMAKE_PROJECT_NAME} ${VALA_C})
target_link_libraries (${CMAKE_PROJECT_NAME} ${DEPS_LIBRARIES})

# Installation
install (TARGETS ${CMAKE_PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})