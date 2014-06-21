#!/usr/bin/env ruby

require 'rubygems'
require 'win32/Console/ANSI' if RUBY_PLATFORM =~ /mingw/
require 'commander/import'

require 'Bento'
require 'Confetti'

require_relative 'Commands/mkact.rb'
# require_relative 'Commands/mkview.rb'
require_relative 'Commands/mark.rb'
require_relative 'Commands/merge.rb'
require_relative 'Commands/build.rb'
require_relative 'Commands/newver.rb'
require_relative 'Commands/nomerge.rb'
require_relative 'Commands/release.rb'

HighLine::use_color = false

program :name, 'tt - Confetti'
program :version, '1.0.0'
program :description, 'A configuration management system.'

default_command :help
 
command :mkact   do |c| Confetti::Commands::MkAct.command(c) ; end
# command :lsact do |c| Confetti::Commands::LsAct.command(c) ; end
# command :mkview do |c| Confetti::Commands::Mkview.command(c) ; end
command :mark    do |c| Confetti::Commands::Mark.command(c) ; end
command :merge   do |c| Confetti::Commands::Merge.command(c) ; end
command :build   do |c| Confetti::Commands::Build.command(c) ; end
command :release do |c| Confetti::Commands::Release.command(c) ; end
command :newver  do |c| Confetti::Commands::NewVer.command(c) ; end
command :nomerge do |c| Confetti::Commands::NoMerge.command(c) ; end
