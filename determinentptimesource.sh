#!/bin/sh
ntpq -p | grep "*" | cut -d " " -f 1 | cut -d "*" -f 2

