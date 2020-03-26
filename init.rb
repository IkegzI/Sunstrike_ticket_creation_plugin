Redmine::Plugin.register :sunstrike_ticket_creation_plugin do
  name 'Sunstrike Ticket Creation Plugin plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

ON_OFF_CONST = [['Включен', 0], ['Выключен', 1]]
settings default: {}, partial: 'ticket/settings/setting'
  # require_dependency 'ssr_freelance'

end
ActionDispatch::Callbacks.to_prepare do
  # SettingsController.send :include, SsrFreelance::Patches::SettingsControllerPatch
end