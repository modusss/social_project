# Seed para relacionar todas as famílias existentes ao primeiro usuário do sistema
puts "Iniciando processo de relacionamento de famílias ao primeiro usuário..."

# Verificar se existe algum usuário no sistema
if User.exists?
  # Obter o primeiro usuário
  first_user = User.first
  puts "Usuário encontrado: #{first_user.name} (ID: #{first_user.id}, Email: #{first_user.email})"
  
  # Contar quantas famílias existem antes da atualização
  total_families = Family.count
  puts "Total de famílias encontradas: #{total_families}"
  
  # Atualizar todas as famílias para terem o primeiro usuário como criador
  if total_families > 0
    # Usar update_all para operação em massa (mais eficiente)
    updated_count = Family.where(created_by_user_id: nil).update_all(created_by_user_id: first_user.id)
    
    puts "#{updated_count} famílias foram relacionadas ao usuário #{first_user.name}"
    puts "#{total_families - updated_count} famílias já estavam atribuídas a outros usuários"
  else
    puts "Não existem famílias no sistema para atualizar."
  end
else
  puts "ERRO: Não foi possível relacionar as famílias pois não existe nenhum usuário no sistema."
  puts "Por favor, crie pelo menos um usuário antes de executar este seed."
end

puts "Processo de relacionamento de famílias concluído!"