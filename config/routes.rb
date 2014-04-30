Rails.application.routes.draw do
  root 'pages#root'

  get 'entries', controller: 'entries', action: 'index', as: 'all_entries'
  scope 'entry', controller: 'entries' do
    post '/create', action: 'create', as: 'create_entry'
    get ':id', action: 'show', as: 'show_entry'
    get ':id/edit', action: 'edit', as: 'edit_entry'
    put ':id', action: 'update', as: 'update_entry'
    get ':id/archive', action: 'archive', as: 'archive_entry'
  end

  devise_for :users
end
