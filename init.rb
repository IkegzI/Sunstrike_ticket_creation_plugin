require_dependency 'ticket_creation'

Redmine::Plugin.register :Sunstrike_ticket_creation_plugin do
  name 'Sunstrike Ticket Creation Plugin plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  ON_OFF_CONST = [['Включен', 0], ['Выключен', 1]]
  YES_NO_CONST = [['Да', 0], ['Нет', 1]]
  NO_YES_CONST = [['Да', 1], ['Нет', 0]]
  YES_NO_STR_CONST = ['Да', 'Нет']


  settings default: {}, partial: 'tickets_from_file/settings/control'
end

ActionDispatch::Callbacks.to_prepare do
  SettingsController.send :include, TicketCreation::Patches::SettingsControllerPatch
end