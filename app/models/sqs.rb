class Sqs < ApplicationRecord
  def self.send_message(queue_name,message_json,i=0)
		if Rails.env.development?
			sqs = Aws::SQS::Client.new(region: 'ap-northeast-1',profile: "default")
		elsif Rails.env.production?
			sqs = Aws::SQS::Client.new(region: 'ap-northeast-1',profile: "RAIMU")
		end
		queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url

		send_message_result = sqs.send_message({
			queue_url: queue_url,
			message_group_id: "message_group_id-#{DateTime.now.strftime("%Y%m%d%H%M%S")}-#{i}",
			message_body: message_json,
			message_deduplication_id: "message_deduplication_id-#{DateTime.now.strftime("%Y%m%d%H%M%S")}-#{i}",
		})

		return
  end
end
