ActiveAdmin.register Delayed::Job do
  permit_params :priority, :attempts, :run_at, :locked_at, :failed_at, :locked_by, :queue, :last_error

  actions :all, except: [:new, :create]

  index do
    selectable_column
    id_column
    column :priority
    column :attempts
    column :run_at
    column :locked_at
    column :failed_at
    column :locked_by
    column :queue
    column :created_at
    actions
  end

  filter :priority
  filter :attempts
  filter :run_at
  filter :locked_at
  filter :failed_at
  filter :locked_by
  filter :queue
  filter :created_at

  form do |f|
    f.inputs 'Delayed_Job Details' do
      f.input :priority
      f.input :attempts
      f.input :run_at
      f.input :locked_at
      f.input :failed_at
      f.input :locked_by
      f.input :queue
    end
    f.actions
  end

end
