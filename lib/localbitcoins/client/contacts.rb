require 'open-uri'

module LocalBitcoins
  module Contacts

    def contact_mark_as_paid(contact_id)
      oauth_request(:post, "/api/contact_mark_as_paid/#{contact_id}/")
    end

    def contact_message_post(contact_id, msg)
      oauth_request(:post, "/api/contact_message_post/#{contact_id}/", {:msg=>msg})
    end

    def contact_messages(contact_id)
      oauth_request(:get, "/api/contact_messages/#{contact_id}/")
    end

    def contact_dispute(contact_id)
      oauth_request(:post, "/api/contact_dispute/#{contact_id}/")
    end

    def contact_cancel(contact_id)
      oauth_request(:post, "/api/contact_cancel/#{contact_id}/")
    end

    def contact_fund(contact_id)
      oauth_request(:post, "/api/contact_fund/#{contact_id}/")
    end

    def contact_create(contact_id, amount, message=nil)
      data = oauth_request(:post, "/api/contact_create/#{contact_id}/", {:amount=>amount, :message=>message})
      data['actions.contact_url']
      data['data.funded']
    end

    def contact_info(contacts)
      oauth_request(:get, '/api/contact_info/', {:contacts=>contacts})
    end
  end
end