require 'rubygems'
require 'bundler/setup'

environment = :test

Bundler.require(:default, environment)

require 'webmock/rspec'
require 'rspec'
require_relative '../lib/paraturb'