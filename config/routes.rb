Rails.application.routes.draw do
  root 'pages#root'

  scope 'users', controller: 'users' do
    get ':id', action: 'show', as: 'show_user'
    get ':id/edit', action: 'edit', as: 'edit_user'
    put ':id/update', action: 'update', as: 'update_user'
    delete ':id', action: 'destroy', as: 'destroy_user'
  end

  scope 'entries', controller: 'entries' do
    get '/', action: 'index', as: 'all_entries'
    get 'archived', action: 'archived_entries', as: 'archived_entries'
    get 'by_tag/:tag', action: 'by_tag', as: 'entries_by_tag'
  end

  scope 'entry', controller: 'entries' do
    post '/create', action: 'create', as: 'create_entry'
    get ':id', action: 'show', as: 'show_entry'
    get ':id/edit', action: 'edit', as: 'edit_entry'
    put ':id', action: 'update', as: 'update_entry'
    get ':id/archive', action: 'archive', as: 'archive_entry'
  end

  devise_for :users
end
