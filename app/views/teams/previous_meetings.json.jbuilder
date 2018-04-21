first = true
json.team1 do
  json.array! @team1 do |game|
    json.id game.id
    res = game.win_or_lose(@team, false)
    json.result res
    json.date game.start_date_s
    klass = res.eql?('W') ? 'win' : (res.eql?('D') ? 'draw' : (res.eql?('L') ? 'loss' : ''))
    if first and not klass.eql?('')
      first = false
      klass += ' first'
    end
    json.klass klass
  end
end

first = true
json.team2 do
  json.array! @team2 do |game|
    json.id game.id
    res = game.win_or_lose(@other_team, false)
    json.result res
    json.date game.start_date_s
    klass = res.eql?('W') ? 'win' : (res.eql?('D') ? 'draw' : (res.eql?('L') ? 'loss' : ''))
    if first and not klass.eql?('')
      first = false
      klass += ' first'
    end
    json.klass klass
  end
end