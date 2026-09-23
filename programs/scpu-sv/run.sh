#!/bin/bash
iverilog -g2012 -o sim src/*.sv tb/*.sv && vvp sim
