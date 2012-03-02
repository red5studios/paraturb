module Paraturb
	class Paraturb
		def create_ticket(params)
			body = build_request('Ticket',params)

			fetch_one('Ticket',request({
				:object_type => 'Ticket',
				:post => body
			}))
		end

		def tickets(options = {})
			response = request({
				:object_type => 'Ticket',
				:params => {:_pageSize_ => 50}
			})

			response.css('Ticket')
		end

		def ticket(id)
			fetch_one('Ticket',request({
				:object_type => 'Ticket',
				:object_id => id
			}))
		end
	end
end