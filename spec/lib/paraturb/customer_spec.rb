require 'spec_helper'

describe 'paraturb customers' do
	before(:each) do
		@api_host = "https://api.parature.com"
		@token = "token"
		@account_id = 123
		@dept_id = 456

		@parature = Paraturb::Paraturb.new({:api_host => @api_host,:token => @token,:account_id => @account_id,:dept_id => @dept_id})
		@parature_responses = {
			:single_customer => "<?xml version=\"1.0\" encoding=\"utf-8\"?><Entities total=\"1\"><Customer id='123'></Customer></Entities>",
			:multiple_customers => "<?xml version=\"1.0\" encoding=\"utf-8\"?><Entities total=\"2\"><Customer id='123'></Customer><Customer id='456'></Customer></Entities>",
			:create_success => "<?xml version=\"1.0\" encoding=\"utf-8\"?><Customer id=\"123\" />",
			:create_fail => "<?xml version=\"1.0\" encoding=\"utf-8\"?><Error />",
			:no_customers => "<?xml version=\"1.0\" encoding=\"utf-8\"?><Entities total=\"0\"></Entities>",
		}
	end

	it "should get a customer by id" do
		stub_request(:get, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Customer/123.*|).to_return(:status => 200,:body => @parature_responses[:single_customer])
		response = @parature.customer(123)

		response.attributes['id'].value.to_i.should == 123
	end

	it "should return false if a customer with a given id does not exist" do
				stub_request(:get, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Customer/123.*|).to_return(:status => 200,:body => @parature_responses[:no_customers])
		response = @parature.customer(123)

		response.should == false
	end

	it "should get a customer given a username" do
		stub_request(:get, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Customer/.*|).to_return(:status => 200,:body => @parature_responses[:single_customer])

		response = @parature.find_customer_by_username('test_user')
		@parature.http_request_url.should =~ %r|User_Name=test_user|
		response.attributes['id'].value.should == "123"
	end

	it "should return nothing when no users are found" do
		stub_request(:get, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Customer/.*|).to_return(:status => 200,:body => @parature_responses[:no_customers])
		response = @parature.find_customer_by_username('test_user')
		response.should == false
	end

	it "should get a customer given an email address" do
		stub_request(:get, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Customer/.*|).to_return(:status => 200,:body => @parature_responses[:multiple_customers])

		response = @parature.find_customer_by_email('test@test.com')
		@parature.http_request_url.should =~ %r|Email=test@test.com|
		response.count.should == 2
	end

	it "should be able to create a customer" do
		stub_request(:post, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Customer.*|).to_return(:status => 200,:body => @parature_responses[:create_success])

		response = @parature.create_customer({
			'Email' => 'test@test.com',
			'First_Name' => 'First',
			'Last_Name' => 'Last',
			'Sla' => ['Sla',{'id' => 7}],
			'Status' => ['Status',{'id' => 2}],
			'User_Name' => 'test_user',
			'Password' => 'pass',
			'Password_Confirm' => 'pass'
		})

		@parature.http_post_body.should == "<?xml version=\"1.0\"?>\n<Customer>\n  <Email>test@test.com</Email>\n  <First_Name>First</First_Name>\n  <Last_Name>Last</Last_Name>\n  <Sla>\n    <Sla id=\"7\"/>\n  </Sla>\n  <Status>\n    <Status id=\"2\"/>\n  </Status>\n  <User_Name>test_user</User_Name>\n  <Password>pass</Password>\n  <Password_Confirm>pass</Password_Confirm>\n</Customer>\n"
		response.attributes['id'].value.to_i.should == 123
	end

	it "should return false if it cannot create a customer record" do
		stub_request(:post, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Customer.*|).to_return(:status => 200,:body => @parature_responses[:create_fail])
		response = @parature.create_customer({
			'Email' => 'test@test.com',
			'First_Name' => 'First',
			'Last_Name' => 'Last',
			'Sla' => ['Sla',{'id' => 7}],
			'Status' => ['Status',{'id' => 2}],
			'User_Name' => 'test_user',
			'Password_Confirm' => 'pass'
		})

		response.should == false
	end
end