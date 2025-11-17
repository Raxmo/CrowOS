#!/bin/sh
# Load X resources
xrdb -merge ~/.Xresources

# Start i3
exec i3
