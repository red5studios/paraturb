module Paraturb
	class Paraturb
		def slas
			response = request({:object_type => 'Sla'})
			return response.css('Sla')
		end

		def find_sla_by_name(sla)
			sla_record = slas.find { |s| s.css("Name").first.content == sla }
			return sla_record.attributes['id'].value if sla_record
			return false
		end
	end
end