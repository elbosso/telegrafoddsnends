#!/bin/sh
#reads the ntp peer from the output of the ntpq command
ntpq -p | grep "\*" | cut -d " " -f 1 | cut -d "*" -f 2

