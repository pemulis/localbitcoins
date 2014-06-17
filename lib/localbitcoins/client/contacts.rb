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

    def open_active_contacts(contact_type = nil)
      contact_type<<'/' if !contact_type.nil? rescue nil
      oauth_request(:get, "/api/dashboard/#{contact_type}")
    end

    def released_contacts(contact_type = nil)
      contact_type<<'/' if !contact_type.nil? rescue nil
      oauth_request(:get, "/api/dashboard/released/#{contact_type}")
    end

    def canceled_contacts(contact_type = nil)
      contact_type<<'/' if !contact_type.nil? rescue nil
      oauth_request(:get, "/api/dashboard/canceled/#{contact_type}")
    end

    def closed_contacts(contact_type = nil)
      contact_type<<'/' if !contact_type.nil? rescue nil
      oauth_request(:get, "/api/dashboard/closed/#{contact_type}")
    end
  end
end