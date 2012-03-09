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


		def add_attachment(ticket_id,attachment_name,attachment_data)
			if ticket_data = ticket(ticket_id)
				# Before uploading a file, it's necessary to get a upload URL from Parature
				if upload = fetch_one('Upload',request({:object_type => 'Ticket',:operation => 'upload'}))
					upload_uri = upload.attributes['href'].value.gsub("&amp;","&")

					# With the resulting URI, upload the file using CURL
					@http_response = Curl::Easy.new(upload_uri)
					@http_response.multipart_form_post = true

					post_field = Curl::PostField.content('file',attachment_data)
					post_field.remote_file = attachment_name
					post_field.content_type = 'application/octet-stream'
					if @http_response.http_post(post_field)

						# The response from Parature will include the attachment guid
						upload_response = parse_response(@http_response.body_str)
						upload_guid = upload_response.css("guid").first.content

						# Now the ticket record needs to be updated to include the attached file
						attachment_string = "<Attachment><Guid>#{upload_guid}</Guid><Name>#{attachment_name}</Name></Attachment>"

						# If the ticket does not have attachments yet, we'll need to create the Ticket_Attahments element
						if ticket_data.css("Ticket_Attachments").count == 0
							attachments = Nokogiri::XML::Node.new "Ticket_Attachments",ticket_data
							ticket_data.add_child(attachments)
						else
							attachments = ticket_data.css("Ticket_Attachments").first
						end
						attachments.add_child(attachment_string)

						return fetch_one('Ticket',request({
							:object_type => 'Ticket',
							:object_id => ticket_id,
							:operation => 'update',
							:put => ticket_data.to_s
						}))
					end
				end
			end

			return false
		end
	end
end