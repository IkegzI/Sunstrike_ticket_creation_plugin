require 'iconv'
class TicketsFromFileController < ApplicationController
  def upload
  end

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

    razdelitel = '  ' if header.rindex('   ')
    razdelitel = ',' if header.rindex(',,')
    razdelitel = ';' if header.rindex(';;')
    binding.pry
    loop do
      text = if header.index(razdelitel) > 0
               header.slice!(0..(header.index(razdelitel)))
             else
               ' '
             end
      if keys.keys.size > header_keys.size
      header_keys << (keys.keys.map do |item|
        keys[item] if text.index(item).present?
      end.compact.first)
      break if header_keys.last == :freelance?
    end
    end

    [header_keys, razdelitel]
  end

  def upload_file
    #:find_attachments, - найти
    #  csv = CSV.parse(File.read(files.first.diskfile), headers: true) - арсинг с заголовками
    # CSV.table(File.read(files.first.diskfile), headers: true)
    # csv.by_row[1].headers
    # csv.by_row[1].values_at
    # csv.size.times {|item| csv.by_row[item]}
    task = {
        tracker: '',
        theme: '',
        description: '',
        assignet_to: '',
        external_rate: '',
        fix_estimate: '',
        project_lead: '',
        art_manager: '',
        parent_task: '',
        dead_line: '',
        time_cost_estimation: ''
    }
    header = []
    tasks = []
    razdelitel = ''
    files = find_attachments
    files.each do |file|
      csv_file = File.readlines(file.diskfile)
      csv_file.each do |line|
        i = 0
        line = Iconv.iconv('utf-8', 'windows-1251', line).pop
        task = {}
        unless header.present?
          arr = header_assign_key(line)
          header = arr.first
          razdelitel = arr.last
        else
          loop do
            if line.first == "\""
              text = if line.index("\"#{razdelitel}") > 0
                       line.slice!(0..(line.index("\"#{razdelitel}")))
                     else
                       ''
                     end
            else
              text = if line.index(razdelitel) > 0
                       line.slice!(0..(line.index(razdelitel)))
                     else
                       ''
                     end
            end

            task[header[i]] = text
            break if header[i] ==  header.last
            i += 1
          end
        end
        tasks << task
      end
      binding.pry
    end
  end
end
