Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(File.join(Rails.root, 'config/sidekiq_scheduler.yml'))
    Sidekiq::Scheduler.reload_schedule!
  end
end 