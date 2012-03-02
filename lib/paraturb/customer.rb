module Paraturb
	class Paraturb
		def find_customer(params)
			response = request({
				:object_type => 'Customer',
				:params => params
			})

			response.css('Customer')
		end

		def find_customer_by_email(email)
			find_customer({'Email' => email})
		end

		def find_customer_by_username(username)
			fetch_one('Customer',find_customer({'User_Name' => username}))
		end

		def create_customer(params)
			body = build_request('Customer',params)
			fetch_one('Customer',request({
				:object_type => 'Customer',
				:post => body
			}))
		end

		def customer(id)
			fetch_one('Customer',request({
				:object_type => 'Customer',
				:object_id => id
			}))
		end
	end
end