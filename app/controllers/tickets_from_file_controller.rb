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
        assigned_to: '',
        external_rate: '',
        fix_estimate: '',
        project_lead: '',
        art_manager: '',
        parent_task: '',
        dead_line: '',
        time_cost_estimation: '',
        freelancer?: ''
    }
    @header = []
    tasks = []
    razdelitel = ''
    files = find_attachments
    files.each do |file|
      csv_file = File.readlines(file.diskfile)
      csv_file.each_with_index do |line, index|
        i = 0
        line = Iconv.iconv('utf-8', 'windows-1251', line).pop
        task = {}
        unless @header.present?
          arr = header_assign_key(line)
          @header = arr.first
          razdelitel = arr.last
        else
          loop do
            if line.first == "\""
              text = if line.index("\"#{razdelitel}") > 0 and line.size > 2
                       line.slice!(0..(line.index("\"#{razdelitel}") + 1))
                     else
                       ''
                     end
            else
              text = if line.index(razdelitel) and line.size > 2
                       line.slice!(0..(line.index(razdelitel)))
                     else
                       ''
                     end
            end
            text.slice!(text.size - 1) if text.last == razdelitel
            task[@header[i]] = text unless text.nil?


            if @header[i] == @header.last
              task[:freelance?] = task[:freelance?].downcase.capitalize
              task[:freelance?] = 'Нет' if task[:freelance?] != 'Да'
              break
            end
            i += 1
          end
          task[:issue] = index
          if task[:dead_line].present?
            if task[:dead_line].split('.').size > 1
              task[:dead_line] = task[:dead_line].split('.').reverse.join('-')
            end
          end

          tasks << task if task.present?
        end
      end
    end
    @project_id = Project.find(params[:project_id].to_i).id
    @tasks = tasks
    render action: 'render_tasks'
  end

  def create_task
    issues = params[:issues]
    project = params[:project].to_i
    user = params[:user].to_i
    issues_new = {}
    errors_validate = {}
    parent_hash = {}
    issues.keys.each do |k|

      issue = Issue.new(
          tracker_id: issues[k][:tracker_id],
          subject: issues[k][:subject],
          description: issues[k][:description],
          assigned_to_id: issues[k][:assigned_to_id],
          parent_id: issues[k][:parent_id],
          due_date: issues[k][:due_date],
          estimated_hours: issues[k][:estimated_hours],
          project_id: project,
          author: User.current
      )
      issue.custom_field_values.select { |cf| cf.custom_field_id == Setting.plugin_sunstrike_ticket_creation['sunstrike_project_lead_id'].to_i }.first.value = issues[k][:custom][:project_lead] if Setting.plugin_sunstrike_ticket_creation['sunstrike_project_lead_id'] != 'non'
      issue.custom_field_values.select { |cf| cf.custom_field_id == Setting.plugin_sunstrike_ticket_creation['sunstrike_art_manager_id'].to_i }.first.value = issues[k][:custom][:art_manager] if Setting.plugin_sunstrike_ticket_creation['sunstrike_art_manager_id'] != 'non'
      issue.custom_field_values.select { |cf| cf.custom_field_id == Setting.plugin_sunstrike_ticket_creation['sunstrike_freelance_id'].to_i }.first.value = issues[k][:custom][:freelancer?] if Setting.plugin_sunstrike_ticket_creation['sunstrike_freelance_id'] != 'non'
      issue.custom_field_values.select { |cf| cf.custom_field_id == Setting.plugin_sunstrike_ticket_creation['sunstrike_fix_estimate_id'].to_i }.first.value = issues[k][:custom][:fix_estimate] if Setting.plugin_sunstrike_ticket_creation['sunstrike_fix_estimate_id'] != 'non'
      issue.custom_field_values.select { |cf| cf.custom_field_id == Setting.plugin_sunstrike_ticket_creation['sunstrike_out_rate_id'].to_i }.first.value = issues[k][:custom][:external_rate] if Setting.plugin_sunstrike_ticket_creation['sunstrike_out_rate_id'] != 'non'

      if issue.validate
        issues_new[k] = issue
      else
        errors_validate[k] = issue.errors.messages
      end

    end
    unless errors_validate.keys.present?
      issues_new.each_key { |key| issues_new[key].save }
      binding.pry
      issues_new.each_key do |key|
        if issues_new[key].parent_id > 0
          issues_new[key].update(parent_id: issues_new[issues_new[key].parent_id.to_s].id)
        else
          issues_new[key].update(parent_id: nil)
        end
      end
  end

  binding.pry
  redirect_to issues_path

end


def render_tasks
  @tasks
end

end
