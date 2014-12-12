#!/usr/bin/env bash -x
time ruby -e "require 'rchardet'; ARGV.each{|arg| if File.file?(arg) && File.readable?(arg); puts arg; puts CharDet.detect(File.binread(arg)); puts ''; end}" $(find "$@" -type f)
