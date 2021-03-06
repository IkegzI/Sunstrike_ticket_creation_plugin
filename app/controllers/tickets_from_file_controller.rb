require 'iconv'
class TicketsFromFileController < ApplicationController
  include TicketsFromFileHelper

  @files = ''

  def upload
    binding.pry
    @files
  end

  def header_assign_key(header)
    keys = {
        'Трекер' => :tracker_id,
        'Тема' => :subject,
        'Описание' => :description,
        'Назначена' => :assigned_to_id,
        'Внешний рейт' => :external_rate,
        'Фиксированный эстимейт?' => :fix_estimate,
        'Проджект лид' => :project_lead,
        'Арт-менеджер' => :art_manager,
        'Родительская задача' => :parent_id,
        'Срок завершения' => :due_date,
        'Оценка временных затрат' => :estimated_hours,
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
        tracker_id: '',
        subject: '',
        description: '',
        assigned_to_id: '',
        external_rate: '',
        fix_estimate: '',
        project_lead: '',
        art_manager: '',
        parent_id: '',
        due_date: '',
        estimated_hours: '',
        freelancer?: ''
    }
    @header = []
    tasks = []
    razdelitel = ''
    @files = find_attachments.present? ? find_attachments : @files
    @files.each do |file|
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
              begin
                task[:due_date] = Date.parse(task[:due_date]).to_s
              rescue
                puts "Date is not correct"
              end
              hash_select_str = {'Да' => 1, 'Нет' => 0}

              task[:fix_estimate] = task[:fix_estimate].downcase.capitalize
              task[:fix_estimate] = 'Да' if task[:fix_estimate] != 'Нет'
              task[:fix_estimate] = hash_select_str[task[:fix_estimate]]

              task[:freelance?] = task[:freelance?].downcase.capitalize
              task[:freelance?] = 'Нет' if task[:freelance?] != 'Да'
              task[:freelance?] = hash_select_str[task[:freelance?]]

              task[:project_lead] = user_id_find(task[:project_lead])
              task[:art_manager] = user_id_find(task[:art_manager])
              task[:tracker_id] = user_id_find(task[:tracker_id])
              task[:assigned_to_id] = user_id_find(task[:assigned_to_id])
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
    @project_id = params[:project_id].to_i
    # @tasks = tasks
    @tasks = tasks
    render action: 'render_tasks'
  end

  def create_task
    @tasks = params[:issues]
    @project_id = params[:project].to_i
    begin
      @header = params[:header].keys
    rescue
      @header = params[:header]
    end
    user = params[:user].to_i
    issues_new = {}
    errors_validate = {}
    parent_hash = {}
    @tasks.keys.each do |k|

      issue = Issue.new(
          tracker_id: @tasks[k][:tracker_id],
          subject: @tasks[k][:subject],
          description: @tasks[k][:description],
          assigned_to_id: @tasks[k][:assigned_to_id],
          parent_id: @tasks[k][:parent_id],
          due_date: @tasks[k][:due_date],
          estimated_hours: @tasks[k][:estimated_hours],
          project_id: @project_id,
          author: User.current
      )
      begin
        if @tasks[k][:custom][:project_lead] == 'non'
          @tasks[k][:custom][:project_lead] = ''
        else
          issue.custom_field_values.select { |cf| cf.custom_field_id == Setting.plugin_Sunstrike_ticket_creation_plugin['sunstrike_project_lead_id'].to_i }.first.value = @tasks[k][:custom][:project_lead] if Setting.plugin_Sunstrike_ticket_creation_plugin['sunstrike_project_lead_id'] != 'non'
        end
      rescue
        @tasks[k][:custom][:project_lead] = '' if @tasks[k][:custom][:project_lead] == 'non'
        puts 'Project-lead is not find!'
      end
      begin
        @tasks[k][:custom][:art_manager] = '' if @tasks[k][:custom][:art_manager] == 'non'
        issue.custom_field_values.select { |cf| cf.custom_field_id == Setting.plugin_Sunstrike_ticket_creation_plugin['sunstrike_art_manager_id'].to_i }.first.value = @tasks[k][:custom][:art_manager] if Setting.plugin_Sunstrike_ticket_creation_plugin['sunstrike_art_manager_id'] != 'non'
      rescue
        @tasks[k][:custom][:art_manager] = '' if @tasks[k][:custom][:art_manager] == 'non'
        puts 'Art-manager is not find!'
      end
      begin
        issue.custom_field_values.select { |cf| cf.custom_field_id == Setting.plugin_Sunstrike_ticket_creation_plugin['sunstrike_freelance_id'].to_i }.first.value = @tasks[k][:custom][:freelancer?].to_i
      rescue
        puts 'Value is not correct!'
      end
      begin
        issue.custom_field_values.select { |cf| cf.custom_field_id == Setting.plugin_Sunstrike_ticket_creation_plugin['sunstrike_fix_estimate_id'].to_i }.first.value = @tasks[k][:custom][:fix_estimate].to_i
      rescue
        puts 'Value is not correct!'
      end
      begin
        issue.custom_field_values.select { |cf| cf.custom_field_id == Setting.plugin_Sunstrike_ticket_creation_plugin['sunstrike_out_rate_id'].to_i }.first.value = @tasks[k][:custom][:external_rate] if Setting.plugin_Sunstrike_ticket_creation_plugin['sunstrike_out_rate_id'] != 'non'
      rescue
        puts 'Value is not correct!'
      end

      if issue.validate
        issues_new[k] = issue
      else
        errors_validate[k] = issue.errors
      end

    end
    unless errors_validate.keys.present?
      i = 0
      root_id_parent = nil
      issues_new.each_key { |key| issues_new[key].save }
      issues_new.each_key do |key|
        if issues_new[key].parent_id.to_i > 0
          parent_id_in_hash = issues_new[key].parent_id.to_s
          id_issue = Issue.find(issues_new[parent_id_in_hash].id)
          root_id_parent = id_issue.id if root_id_parent.nil?
          Issue.find(issues_new[key].id).update(parent_id: root_id_parent)
          Issue.find(issues_new[key].id).parent_issue_id = root_id_parent
          Issue.find(issues_new[key].id).update(lft: i, rgt: i + 1)
          Issue.find(issues_new[key].id).reload
          Issue.find(issues_new[key].id).update(parent_id: id_issue.id)
          i += 2
        else
          issues_new[key].update(parent_id: nil)
          root_id_parent = nil
          i = 0
        end
      end
      redirect_to issues_path, :notice => 'Задачи успешно созданы!', :error => ''
    else
      # redirect_to tickets_from_file_upload_errors_path, :flash => { :error => (errors_validate.keys.map{|k| ["Задача #{k}. ", errors_validate[k].full_messages].join('')}.join("/\r")) }
      flash[:error] = (errors_validate.keys.map { |k| ["Задача #{k}. ", errors_validate[k].full_messages].join('<br>') }.join("<br>"))
      # flash[:error] = errors_validate.keys.map { |k| errors_validate[k].full_messages.join('') }
      render action: 'render_tasks_with_errors'
    end
  end

  def render_tasks
    @tasks
  end

  def delete
    a = RolesType.find_by(role_id: params[:id].to_i, type_roles_id: params[:type_id].to_i)
    if a
      a.destroy
    end
    redirect_to plugin_settings_path('Sunstrike_ticket_creation_plugin')
  end

  def add
    RolesType.create(role_id: params[:id].to_i, type_roles_id: params[:type_id].to_i)
    redirect_to plugin_settings_path('Sunstrike_ticket_creation_plugin')
  end

  def freelance_val
    CustomField.find(Setting.plugin_Sunstrike_ticket_creation_plugin['sunstrike_freelance_id'].to_i)
  end

end
