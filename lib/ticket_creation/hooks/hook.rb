require_relative '../../ticket_creation'

module TicketCreation
  module Hook
    class SunstrikeTicketCreationPluginHookListener < Redmine::Hook::ViewListener
      render_on(:view_layouts_base_content, partial: 'tickets_from_file/script_link_add')
    end
  end
end
