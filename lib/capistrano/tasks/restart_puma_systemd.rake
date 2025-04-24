# Custom Capistrano task to restart Puma via systemd after deploy

namespace :puma do
  desc "Restart Puma via systemd"
  task :systemd_restart do
    on roles(:app) do
      # Reinicia o serviço Puma via systemd
      execute :sudo, :systemctl, :restart, "puma_candeiasesperanca"
    end
  end
end

# Hook para rodar após o deploy:publishing
after 'deploy:publishing', 'puma:systemd_restart' 