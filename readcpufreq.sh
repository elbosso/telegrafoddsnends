#!/bin/sh
lscpu |grep "U MHz"|rev|cut -d " " -f 1|rev

