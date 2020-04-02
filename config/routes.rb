# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get '/tickets_from_file/upload'
post '/tickets_from_file/upload' => 'tickets_from_file#upload_file'
