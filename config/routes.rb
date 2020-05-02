# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get '/tickets_from_file/upload'
get '/tickets_from_file/upload_errors' => 'tickets_from_file#upload_file'
post '/tickets_from_file/upload' => 'tickets_from_file#upload_file'
post '/tickets_from_file/create_task' => 'tickets_from_file#create_task'
post '/tickets_from_file/create_task'
get '/tickets_from_file/render_tasks'
post '/stc/(:type_id)/add/(:id)' => 'tickets_from_file#add'
post '/stc/(:type_id)/delete/(:id)' => 'tickets_from_file#delete'


