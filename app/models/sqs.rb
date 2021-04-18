class Sqs < ApplicationRecord
  def self.send_message(search_word,site_domain,scraping_id,i)
		queue_name = "scr-queue.fifo"
		msg_b = {search_word: "#{search_word}",domain: "#{site_domain}",scraping_id: "#{scraping_id}"}.to_json

		sqs = Aws::SQS::Client.new(region: 'ap-northeast-1')
		queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url

		send_message_result = sqs.send_message({
			queue_url: queue_url,
			message_group_id: "message_group_id-#{DateTime.now.strftime("%Y%m%d%H%M%S")}-#{i}",
			message_body: msg_b,
			message_deduplication_id: "message_deduplication_id-#{DateTime.now.strftime("%Y%m%d%H%M%S")}-#{i}",
		})

		return
  end
end
