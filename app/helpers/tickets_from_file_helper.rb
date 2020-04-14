module TicketsFromFileHelper

  def header_assign_key(header)
    keys = {
        'Трекер' => :tracker,
        'Тема' => :theme,
        'Описание' => :description,
        'Назначена' => :assignet_to,
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
      header_keys << keys.keys.map{|item| keys[item] if text.index(item) > 0}.compact.first
      break if header[0..1] == "\r\n"
    end
    binding.pry

    header_keys
  end

end
