class TicketsFromFileController < ApplicationController
  def upload
  end
  def upload_file
    #:find_attachments, - найти
    #  csv = CSV.parse(File.read(files.first.diskfile), headers: true) - арсинг с заголовками
    # CSV.table(File.read(files.first.diskfile), headers: true)
    # csv.by_row[1].headers
    # csv.by_row[1].values_at
    # csv.size.times {|item| csv.by_row[item]}
    files = find_attachments
    binding.pry
  end
end
