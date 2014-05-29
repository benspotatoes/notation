Rails.application.routes.draw do
  root 'pages#root'

  scope 'profile', controller: 'profile' do
    get ':id', action: 'show', as: 'show_profile'
    get ':id/edit', action: 'edit', as: 'edit_profile'
    put ':id/update', action: 'update', as: 'update_profile'
    delete ':id', action: 'destroy', as: 'destroy_profile'
  end

  scope 'entries', controller: 'entries' do
    scope 'now' do
      get '/', action: 'index', as: 'all_note_entries'
      get 'archived', action: 'archived_entries', as: 'archived_note_entries'
      get 'by_tag/:tag', action: 'by_tag', as: 'note_entries_by_tag'
    end
  end

  scope 'entry', controller: 'entries' do
    scope 'now' do
      post '/create', action: 'create', as: 'create_note_entry'
      get ':id', action: 'show', as: 'show_note_entry'
      get ':id/edit', action: 'edit', as: 'edit_note_entry'
      put ':id', action: 'update', as: 'update_note_entry'
      get ':id/archive', action: 'archive', as: 'archive_note_entry'
    end
  end

  # API business
  scope 'v1', controller: 'api' do
    post 'add', action: 'add_entry', as: 'v1_add_entry'
    post 'remove', action: 'remove_entry', as: 'v1_remove_entry'
  end

  devise_for :users
end
