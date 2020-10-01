#!/usr/bin/python3

# https://raspberrypi.stackexchange.com/questions/47200/automatically-accepting-bluetooth-connections-on-a-pi-3
# Base code publiched by Emil Borconi

from __future__ import absolute_import, print_function, unicode_literals

from gi.repository import GLib as glib

import re
import dbus
import dbus.mainloop.glib
import subprocess

#relevant_ifaces = [ "org.bluez.Adapter1", "org.bluez.Device1" ]
relevant_ifaces = [ "org.bluez.Device1" ]

def set_trusted(path):
    props = dbus.Interface(bus.get_object("org.bluez", path),
                    "org.freedesktop.DBus.Properties")
    props.Set("org.bluez.Device1", "Trusted", True)

def dev_connect(path):
    dev = dbus.Interface(bus.get_object("org.bluez", path),
                            "org.bluez.Device1")
    dev.Connect()

def property_changed(interface, changed, invalidated, path):
        iface = interface[interface.rfind(".") + 1:]
        for name, value in changed.iteritems():
                val = str(value)
                print("{%s.PropertyChanged} [%s] %s = %s" % (iface, path, name,val))

def interfaces_added(path, interfaces):
        for iface in interfaces:
                if not(iface in relevant_ifaces):
                        continue
                set_trusted(path)
                dev_connect(path)

def interfaces_removed(path, interfaces):
        for iface in interfaces:
                if not(iface in relevant_ifaces):
                        continue
                print("{Removed %s} [%s]" % (iface, path))

if __name__ == '__main__':
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

        bus = dbus.SystemBus()

        bus.add_signal_receiver(interfaces_added, bus_name="org.bluez",
                        dbus_interface="org.freedesktop.DBus.ObjectManager",
                        signal_name="InterfacesAdded")

        bus.add_signal_receiver(interfaces_removed, bus_name="org.bluez",
                        dbus_interface="org.freedesktop.DBus.ObjectManager",
                        signal_name="InterfacesRemoved")

        mainloop = glib.MainLoop()
        mainloop.run()
