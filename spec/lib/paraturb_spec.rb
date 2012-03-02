require 'spec_helper'

describe Paraturb::Paraturb do
	before(:each) do
		@api_host = "https://api.parature.com"
		@token = "token"
		@account_id = 123
		@dept_id = 456

		@parature = Paraturb::Paraturb.new({:api_host => @api_host,:token => @token,:account_id => @account_id,:dept_id => @dept_id})
	end

	it "should generate a proper request url" do
		@parature.request_url({
			:object_type => 'Ticket',
			:object_id => 789
		})["#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Ticket/789?_token_=#{@token}"].should == "#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Ticket/789?_token_=#{@token}"
	end

	it "should attempt a get request" do
		stub_request(:get, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Ticket/789.*|).to_return(:status => 200,:body => "<status>Success</status>")

		response = @parature.request({
			:object_type => 'Ticket',
			:object_id => 789
		})

		response.status.content.should == "Success"
	end

	it "should attempt a post request with a post parameter" do
		stub_request(:post, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Ticket.*|).to_return(:status => 200,:body => "<status>Success</status>")

		response = @parature.request({
			:object_type => 'Ticket',
			:post => "Test"
		})

		response.status.content.should == "Success"
	end

	it "should do a schema request using a shortcut method" do
		stub_request(:get, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Ticket/schema?.*|).to_return(:status => 200,:body => "<status>Success</status>")

		response = @parature.schema('Ticket')

		response.status.content.should == "Success"
	end
end