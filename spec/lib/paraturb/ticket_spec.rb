require 'spec_helper'

describe 'paraturb tickets' do
	before(:each) do
		@api_host = "https://api.parature.com"
		@token = "token"
		@account_id = 123
		@dept_id = 456

		@parature = Paraturb::Paraturb.new({:api_host => @api_host,:token => @token,:account_id => @account_id,:dept_id => @dept_id})
		@parature_responses = {
			:single_ticket => "<?xml version=\"1.0\" encoding=\"utf-8\"?><Entities total=\"1\"><Ticket id='789'></Ticket></Entities>",
			:multiple_tickets => "<?xml version=\"1.0\" encoding=\"utf-8\"?><Entities total=\"2\"><Ticket id='890'></Ticket><Ticket id='456'></Ticket></Entities>",
			:create_success => "<?xml version=\"1.0\" encoding=\"utf-8\"?><Ticket id=\"789\" uid=\"#{@account_id}/#{@dept_id}/Ticket/789\"
  href=\"#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Ticket/789\" service-desk-uri=\"#{@api_host}/ics/tt/ticketDetail.asp?ticketNum=789\" />",
			:create_fail => "<?xml version=\"1.0\" encoding=\"utf-8\"?><Error />",
			:no_tickets => "<?xml version=\"1.0\" encoding=\"utf-8\"?><Entities total=\"0\"></Entities>",
		}
	end

	it "should get a ticket given an id" do
		stub_request(:get, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Ticket/789.*|).to_return(:status => 200,:body => @parature_responses[:single_ticket])

		response = @parature.ticket(789)
		response.attributes['id'].value.to_i.should == 789
	end

	it "should return false for a nonexistent tiket" do
		stub_request(:get, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Ticket/789.*|).to_return(:status => 200,:body => @parature_responses[:no_tickets])

		response = @parature.ticket(789)
		response.should == false
	end

	it "should get a list of tickets" do
		stub_request(:get, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Ticket.*|).to_return(:status => 200,:body => @parature_responses[:multiple_tickets])
		response = @parature.tickets
		response.count.should == 2
	end

	it "should create a ticket" do
		stub_request(:post, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Ticket.*|).to_return(:status => 200,:body => @parature_responses[:create_success])

		response = @parature.create_ticket({
			'Ticket_Customer' => ['Customer',{'id' => 1}],
			'Custom_Field36' => 'Test Ticket',
			'Custom_Field39' => ['Option',{'id' => 22}]
		})

		@parature.http_post_body.should == "<?xml version=\"1.0\"?>\n<Ticket>\n  <Ticket_Customer>\n    <Customer id=\"1\"/>\n  </Ticket_Customer>\n  <Custom_Field id=\"36\">Test Ticket</Custom_Field>\n  <Custom_Field id=\"39\">\n    <Option id=\"22\"/>\n  </Custom_Field>\n</Ticket>\n"
		response.attributes['id'].value.to_i.should == 789
	end

	it "should return false if it cannot create a ticket" do
		stub_request(:post, %r|#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/Ticket.*|).to_return(:status => 200,:body => @parature_responses[:create_fail])

		response = @parature.create_ticket({
			'Ticket_Customer' => ['Customer',{'id' => 1}],
			'Custom_Field36' => 'Test Ticket',
			'Custom_Field39' => ['Option',{'id' => 22}]
		})

		response.should == false
	end
end