#!/usr/bin/env bash -x
time ruby -r "charlotte" -e "ARGV.each{|arg| puts arg; puts File.binread(arg).detect_encoding.to_s.gsub('ASCII-8BIT','BINARY'); puts ''}" -- $(find "$@" -type f)
