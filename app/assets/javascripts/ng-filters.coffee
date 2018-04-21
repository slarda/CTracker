## Custom filters ######################################################################################################

# Unique - return a list of unique entries by checking a particular attribute
ngApp.filter 'uniqueOnAttribute', () ->
  (items, attribute) ->
    return [] unless items?
    filtered = []
    for item in items
      found = false
      for existing in filtered
        if existing[attribute] == item[attribute]
          found = true
          break;
      filtered.push(item) unless found
    filtered

ngApp.filter 'filterBySeason', () ->
  (items, attribute) ->
    return [] unless items?
    filtered = (item for item in items when item.season == attribute)

ngApp.filter 'filterByYearEmpty', () ->
  (items, attribute) ->
    return [] unless items?
    filtered = (item for item in items when new Date(item.start_date).getFullYear() == attribute)
    return filtered.length == 0

ngApp.filter 'getValidSeasons', () ->
  (items) ->
    return [] unless items?
    seasons = []
    for item in items
      curr_season = item.season
      seasons.push(curr_season) unless curr_season in seasons
    seasons.sort().reverse()

ngApp.filter 'equipmentType', () ->
  (items, kind) ->
    return [] unless items?
    boots = []
    for item in items
      boots.push(item) if item.equipment_type is kind
    boots
