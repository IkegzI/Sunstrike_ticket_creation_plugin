module TicketsFromFileHelper

  def header_assign_key(header)
    keys = {
        'Трекер' => :tracker,
        'Тема' => :theme,
        'Описание' => :description,
        'Назначена' => :assigned_to,
        'Внешний рейт' => :external_rate,
        'Фиксированный эстимейт?' => :fix_estimate,
        'Проджект лид' => :project_lead,
        'Арт-менеджер' => :art_manager,
        'Родительская задача' => :parent_task,
        'Срок завершения' => :dead_line,
        'Оценка временных затрат' => :time_cost_estimation,
        'Делает фрилансер?' => :freelance?
    }
    header_keys = []
    razdelitel = header[1][-3]
    loop do
      if header.first == "\""
        text = header.slice!(0..header.index("\"#{razdelitel}"))
      else
        text = header.slice!(0..header.index(razdelitel))
      end
      header_keys << keys.keys.map { |item| keys[item] if text.index(item) > 0 }.compact.first
      break if header[0..1] == "\r\n"
    end
    header_keys
  end

  def select_tracker
    Project.find((params[:project_id] || params[:project]).to_i).trackers.map { |item| [item.name, item.id] }
  end

  def select_users
    User.all.map { |item| ["#{item.firstname} #{item.lastname}", item.id] } << ["", "non"]
  end

  def select_tracer_from_document(tracker_name)
    if tracker_name.present?
      val = Tracker.find_by(name: tracker_name.downcase.capitalize)
      if val.present?
        val = val.id
      else
        val = ''
      end
    else
      val = ''
    end
    val
  end

  def select_tracer_from_document_on_id(tracker_id)
    if tracker_id.present?
      val = Tracker.find(tracker_id.to_i)
      if val.present?
        val = val.id
      else
        val = ''
      end
    else
      val = ''
    end
    val
  end

  # def select_user_from_document(user_name)
  #   #   if user_name.present?
  #   #     user_name = user_name.split(' ')
  #   #     # firstname: string, lastname: string
  #   #     unless user_name[0].to_i > 0
  #   #       val = User.where(firstname: user_name[1].downcase.capitalize, lastname: user_name[0].downcase.capitalize).first
  #   #       val = User.where(firstname: user_name[0].downcase.capitalize, lastname: user_name[1].downcase.capitalize).first unless val.present?
  #   #     else
  #   #       val = User.find(user_name[0].to_i)
  #   #     end
  #   #     if val.present?
  #   #       val = val.id
  #   #     else
  #   #       val = ''
  #   #     end
  #   #   else
  #   #     val = ''
  #   #   end
  #   #   val
  #   # end


  def select_project
    Project.where(status: 1).map { |item| [item.name, item.id] }
  end

  def role_art_manager
    @art_manager = Role.find_by(name: 'Арт-менеджер')
    return @art_manager = @art_manager.members.where(project_id: params[:project_id].to_i) if @art_manager.present?
  end

  def select_art_manager
    role_art_manager unless @art_manager.present?
    if @art_manager.present?
      @art_manager_for_selector = @art_manager.map { |item| ["#{item.lastname} #{item.firstname}", item.id] }
    else
      @art_manager_for_selector = ["нет данных"]
    end
  end

  # def role_project_lead
  #   @project_lead = Role.find_by(name: ['Арт-менеджер', 'Ведущий художник', 'Ведущий арт-менеджер'])
  #   return @project_lead = @project_lead.members.where(project_id: params[:project_id].to_i) if @project_lead.present?
  # end
  #
  # def select_project_lead
  #   role_project_lead unless @project_lead.present?
  #   if @project_lead.present?
  #     @project_lead_for_selector = @project_lead.map { |item| ["#{item.lastname} #{item.firstname}", item.id] }
  #   else
  #     @project_lead_for_selector = ["нет данных"]
  #   end
  #   @project_lead_for_selector
  # end

  def select_custom_fields
    IssueCustomField.all.map { |field| [field.name, field.id] }.insert(0, ['<--не выбрано-->', 'non'])
  end

  def select_role
    Role.all.map { |item| [item.name, item.id] }
  end

  def select_roles_prl
    begin
      users_arr = []
      cf_roles_ids = CustomField.find(Setting.plugin_Sunstrike_ticket_creation_plugin['sunstrike_project_lead_id']).format_store[:user_role]
      roles_by_users = Project.find((params[:project_id] || params[:project]).to_i).users_by_role.map { |item| item }
      cf_roles = roles_by_users.select { |role| cf_roles_ids.include?(role.first.id.to_s) }
      cf_roles.map! { |item| item.last.each { |user| users_arr << user } }
      users_arr.map { |item| [item.name, item.id] }.insert(0, ['<--нет данных-->', 'non'])
    rescue
      [['<--нет данных-->', 'non']]
    end
  end

  def selected_role_prl_user
    select_roles_prl.each do |role|

    end
  end

  def select_roles_am
    begin
      users_arr = []
      cf_roles_ids = CustomField.find(Setting.plugin_Sunstrike_ticket_creation_plugin['sunstrike_art_manager_id']).format_store[:user_role]
      roles_by_users = Project.find((params[:project_id] || params[:project]).to_i).users_by_role.map { |item| item }
      cf_roles = roles_by_users.select { |role| cf_roles_ids.include?(role.first.id.to_s) }
      cf_roles.map! { |item| item.last.each { |user| users_arr << user } }
      users_arr.map { |item| [item.name, item.id] }.insert(0, ['<--нет данных-->', 'non'])
    rescue
      [['<--нет данных-->', 'non']]
    end
  end

  def selected_am
    RolesType.where(type_roles_id: 2).map { |item| [item.role.name, item.role_id] }
  end

  def user_id_find(full_name)
    names_arr = full_name.chomp.split(' ')
    names_arr.map! { |name| name if name.present? }.compact
    # firstname: string, lastname: string
    user = User.find_by(firstname: names_arr.first, lastname: names_arr.last)
    user = User.find_by(firstname: names_arr.last, lastname: names_arr.first) unless user.present?

    begin
      return user.id
    rescue
      return 'non'
    end
  end

end