require_dependency 'ticket_creation'
require_relative './app/helpers/tickets_from_file_helper'

Redmine::Plugin.register :sunstrike_ticket_creation do
  name 'Sunstrike Ticket Creation Plugin plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  ON_OFF_CONST = [['Включен', 0], ['Выключен', 1]]
  YES_NO_CONST = [['Да', 0], ['Нет', 1]]


  settings default: {}, partial: 'tickets_from_file/settings/control'
end

ActionDispatch::Callbacks.to_prepare do
  SettingsController.send :include, TicketCreation::Patches::SettingsControllerPatch
end