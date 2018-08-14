#!/usr/bin/python3

# https://raspberrypi.stackexchange.com/questions/47200/automatically-accepting-bluetooth-connections-on-a-pi-3
# Base code publiched by Emil Borconi

from __future__ import absolute_import, print_function, unicode_literals

#import gobject
from gi.repository import GObject as gobject

import re
import dbus
import dbus.mainloop.glib
import subprocess

relevant_ifaces = [ "org.bluez.Adapter1", "org.bluez.Device1" ]

def property_changed(interface, changed, invalidated, path):
        iface = interface[interface.rfind(".") + 1:]
        for name, value in changed.iteritems():
                val = str(value)
                print("{%s.PropertyChanged} [%s] %s = %s" % (iface, path, name,val))

def interfaces_added(path, interfaces):
        for iface in interfaces:
                if not(iface in relevant_ifaces):
                        continue
                try:
                        found = re.search('dev\_(..\_..\_..\_..\_..\_..)', path).group(1)
                except AttributeError:
                        found = '' # apply your error handling
                mac=found.replace("_",":")
                cmd_trust='echo "trust '+mac+' \\nquit" | bluetoothctl'
                subprocess.call(cmd_trust, shell=True)
                cmd_connect='echo "connect '+mac+' \\nquit" | bluetoothctl'
                subprocess.call(cmd_connect, shell=True)

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

        mainloop = gobject.MainLoop()
        mainloop.run()
