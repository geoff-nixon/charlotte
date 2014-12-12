#!/usr/bin/env bash -x
time ruby -e "require 'charlock_holmes'; require 'charlock_holmes/string'; ARGV.each{|arg| if File.file?(arg) && File.readable?(arg); puts arg; puts File.binread(arg).detect_encoding; puts ''; end}" $(find "$@" -type f)
