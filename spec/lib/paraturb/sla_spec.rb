# encoding: utf-8
require 'spec_helper'

describe 'paraturb slas' do
	before(:each) do
		@api_host = "https://api.parature.com"
		@token = "token"
		@account_id = 123
		@dept_id = 456

		@parature = Paraturb::Paraturb.new({:api_host => @api_host,:token => @token,:account_id => @account_id,:dept_id => @dept_id})

		@parature_responses = {
			:multiple_slas => "﻿<?xml version='1.0' encoding='utf-8'?><Entities total='7'><Sla id='1'><Name>System Default</Name></Sla><Sla id='3'><Name>Registered</Name></Sla><Sla id='7'><Name>Beta User</Name></Sla></Entities>"
		}

		stub_request(:get, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Sla.*|).to_return(:status => 200,:body => @parature_responses[:multiple_slas])
	end

	it "should get all slas" do
		response = @parature.slas
		response.count.should == 3
	end

	it "should return a single sla id by name" do
		response = @parature.find_sla_by_name('Beta User')
		response.to_i.should == 7
	end

	it "should return false if no sla matches a name" do
		response = @parature.find_sla_by_name('Does Not Exist')
		response.should == false
	end
end