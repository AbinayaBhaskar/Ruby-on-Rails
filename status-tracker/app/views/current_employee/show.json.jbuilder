json.partial! 'employee', locals: { employee: @employee }

json.team_members @employee.accessible_team_members.each do |employee|
  json.partial! 'employee', locals: { employee: }
end
