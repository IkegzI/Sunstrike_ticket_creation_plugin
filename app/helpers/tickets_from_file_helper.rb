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

  # def self.tasks
  #   @tasks
  # end
  #
  def select_tracker
    Tracker.all.map { |item| [item.name, item.id] }
  end

  def select_users
    User.all.map { |item| ["#{item.firstname} #{item.lastname}", item.id] } << ["", ""]
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

  def select_user_from_document(user_name)
    if user_name.present?
      user_name = user_name.split(' ')
      # firstname: string, lastname: string
      val = User.where(firstname: user_name[1].downcase.capitalize, lastname: user_name[0].downcase.capitalize).first
      val = User.where(firstname: user_name[0].downcase.capitalize, lastname: user_name[1].downcase.capitalize).first unless val.present?
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


  def select_project
    Project.where(status: 1).map { |item| [item.name, item.id] }
  end

  def self.select_project_lead(project_id)
    binding.pry
  end


end
