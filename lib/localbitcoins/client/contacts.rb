require 'open-uri'

module LocalBitcoins
  module Contacts

    def contact_mark_as_paid(contact_id)
      data = oauth_request(:post, "/api/contact_mark_as_paid/#{contact_id}/")
      Hashie::Mash.new(data)
    end

    def contact_message_post(contact_id, msg)
      data = oauth_request(:post, "/api/contact_message_post/#{contact_id}/", {:msg=>msg})
      Hashie::Mash.new(data)
    end

    def contact_messages(contact_id)
      data = oauth_request(:get, "/api/contact_messages/#{contact_id}/")
      Hashie::Mash.new(data)
    end

    def contact_dispute(contact_id)
      data = oauth_request(:post, "/api/contact_dispute/#{contact_id}/")
      Hashie::Mash.new(data)
    end

    def contact_cancel(contact_id)
      data = oauth_request(:post, "/api/contact_cancel/#{contact_id}/")
      Hashie::Mash.new(data)
    end

    def contact_fund(contact_id)
      data = oauth_request(:post, "/api/contact_fund/#{contact_id}/")
      Hashie::Mash.new(data)
    end

    def contact_create(ad_id, amount, message=nil)
      data = oauth_request(:post, "/api/contact_create/#{ad_id}/", {:amount=>amount, :message=>message})
      Hashie::Mash.new(data['actions.contact_url'])
      #MERGE OR NO? .merge(data['data.funded']
    end

    def contact_info(contacts)
      data = oauth_request(:get, '/api/contact_info/', {:contacts=>contacts})
      Hashie::Mash.new(data)
    end

    def open_active_contacts(contact_type = nil)
      contact_type<<'/' if !contact_type.nil? rescue nil
      data = oauth_request(:get, "/api/dashboard/#{contact_type}")
      Hashie::Mash.new(data)
    end

    def released_contacts(contact_type = nil)
      contact_type<<'/' if !contact_type.nil? rescue nil
      data = oauth_request(:get, "/api/dashboard/released/#{contact_type}")
      Hashie::Mash.new(data)
    end

    def canceled_contacts(contact_type = nil)
      contact_type<<'/' if !contact_type.nil? rescue nil
      data = oauth_request(:get, "/api/dashboard/canceled/#{contact_type}")
      Hashie::Mash.new(data)
    end

    def closed_contacts(contact_type = nil)
      contact_type<<'/' if !contact_type.nil? rescue nil
      data = oauth_request(:get, "/api/dashboard/closed/#{contact_type}")
      Hashie::Mash.new(data)
    end
  end
end