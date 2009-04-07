#!/usr/local/bin/ruby
require 'webrick'
include WEBrick

s = HTTPServer.new(
  :Port            => 8000,
  :DocumentRoot    => Dir::pwd + "."
)

## mount subdirectories
s.mount("/", HTTPServlet::FileHandler, ".", true)

trap("INT"){ s.shutdown }
s.start





