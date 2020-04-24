require_relative '../../ticket_creation.rb'

module TicketCreation
  module Patches
    module SettingsControllerPatch
      def self.included(base)
        base.class_eval do
          helper :tickets_from_file
        end
      end
    end
  end
end
