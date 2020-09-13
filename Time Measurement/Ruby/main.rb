#! /usr/bin/env ruby

require_relative "./analyze.rb"
require_relative "./execute.rb"
require_relative "./docs.rb"
require_relative "./lib.rb"

d=DataStore.new

argAnalyze(d)

case d.mode
	when CM::MAIN    then Execute.main(d)
	when CM::HELP    then help()
	when CM::VERSION then version()
end