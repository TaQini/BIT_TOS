#!/bin/sh
java net.tinyos.tools.PrintfClient -comm serial@/dev/ttyUSB$1:telosb
