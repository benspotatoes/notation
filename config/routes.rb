Rails.application.routes.draw do
  root 'pages#root'

  get 'ping', controller: 'pages', action: 'ping', as: 'ping'

  scope 'profile', controller: 'profile' do
    get ':id', action: 'show', as: 'show_profile'
    get ':id/edit', action: 'edit', as: 'edit_profile'
    put ':id/update', action: 'update', as: 'update_profile'
    delete ':id', action: 'destroy', as: 'destroy_profile'
  end

  scope 'entries', controller: 'entries' do
    get '/:entry_tag', action: 'index', as: 'all_entries'
    get ':entry_tag/archived', action: 'archived_entries', as: 'archived_entries'
    get ':entry_tag/by_tag/:tag', action: 'by_tag', as: 'entries_by_tag'
    post ':query', action: 'search', as: 'search_entries'
  end

  scope 'entry', controller: 'entries' do
    post '/create', action: 'create', as: 'create_entry'
    get ':id', action: 'show', as: 'show_entry'
    get ':id/edit', action: 'edit', as: 'edit_entry'
    put ':id', action: 'update', as: 'update_entry'
    get ':id/archive', action: 'archive', as: 'archive_entry'
  end

  # API business
  scope 'v1', controller: 'api' do
    post 'search', action: 'search', as: 'v1_search'
    post 'add', action: 'add_entry', as: 'v1_add_entry'
    post 'remove', action: 'remove_entry', as: 'v1_remove_entry'
  end

  devise_for :users
end
