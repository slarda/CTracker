require 'active_support/concern'

MALE = 1
FEMALE = 2
PLAYER = 1
PARENT_OF = 2
COACH = 3
FAN = 4

BOOTS = 1
GUARDS = 2
GLOVES = 3
SHINPADS = 4

# Create basic positions
Position.where(position: 'Goalkeeper', sport: 'Soccer').first_or_create!
p_mf = Position.where(position: 'Midfielder', sport: 'Soccer').first_or_create!
Position.where(position: 'Defender', sport: 'Soccer').first_or_create!
Position.where(position: 'Forward', sport: 'Soccer').first_or_create!

puts 'Loading basic seeds...'

a1 = Association.where(name: 'Football Federation Victoria').first_or_create!(
    description: 'Football Federation Victoria', url: 'http://www.footballfedvic.com.au/',
    location: 'Melbourne, Australia')

c1 = nil
t1 = nil

u1 = User.where(email: 'wtfiwtz@gmail.com').first_or_create!(first_name: 'Nigel', last_name: 'Sheridan-Smith',
                                                             gender: MALE, role: PLAYER, password: 'K3EporrDUxuy4F',
                                                             agree_terms: true, assoc: a1, club: c1, team: t1,
                                                             disable_notification: true, super_admin: true)
u2 = User.where(email: 'conharbis@conharbis.com').first_or_create!(first_name: 'Con', last_name: 'Harbis',
                                                                   gender: MALE, role: PLAYER,
                                                                   password: 'K3EporrDUxuy4F', agree_terms: true,
                                                                   assoc: a1, club: c1, team: t1,
                                                                   disable_notification: true, super_admin: true)

# Load up the CSV files
class CsvLoader
  include Games::Csv
  include Clubs::Logos
  include ContactDetails::Csv
  include Gear::Csv
end
CsvLoader.setup_uniqueness_check

# Games and clubs first, then players
# TODO: Load data prior to 2015 too
data_files = Dir[ Rails.root.join('data', 'games', '**', '*.csv') ].reject { |p| File.directory? p }.sort # '2015',
data_files.each do |csv_file|
  next if csv_file.include?('Players')
  puts "Loading game stats... #{csv_file}"
  CsvLoader.load_game_stats csv_file, true
end

data_files.each do |csv_file|
  next unless csv_file.include?('Players')
  puts "Loading player stats... #{csv_file}"
  CsvLoader.load_player_stats csv_file, true
end

puts 'Updating all games...'
Game.all.each do |game|
  game.reset_player_stats!
  game.save!
end

puts 'Loading logos...'
CsvLoader.load_logos

# Craig Metcalfe
craig_metcalfe = User.where(first_name: 'Craig', last_name: 'Metcalfe').first
if craig_metcalfe
  craig_metcalfe.avatar = File.new(Rails.root.join('data', 'avatars', 'craig-metcalfe-small.jpg'))
  craig_metcalfe.save!
end

puts 'Loading venues...'
CsvLoader.load_venues(Rails.root.join('data', 'venues', 'venues.csv'))

puts 'Loading equipment...'
CsvLoader.load_gear(Rails.root.join('data', 'gear', 'gear.csv'))


# Do the Oakleigh Club as a sample
oakleigh_cannons = Club.where(name: 'Oakleigh Cannons FC').first
if oakleigh_cannons
  oakleigh_cannons.description = 'The Oakleigh Cannons FC was established in 1972. Initially it was the creation of ' \
                                 'a few young Soccer enthusiasts who funded the establishment of the club themselves.'
  oakleigh_cannons.facebook = 'oakleigh.cannons'
  oakleigh_cannons.twitter = 'oakcannonsfc'
  oakleigh_cannons.google_plus = '113241200373839479238'
  oc_venue = oakleigh_cannons.build_location(address1: 'Jack Edwards Reserve ( Melways 69 H9 )',
                                             address2: 'Edward Street', suburb: 'Oakleigh', state: 'Victoria',
                                             zipcode: '3121', country: 'Australia', phone1: '(+61) 3 9568 8618',
                                             email: 'oakleighcannons@internode.on.net',
                                             website: 'http://www.oakleighcannonsfc.com.au/',
                                             latitude: -37.9061, longitude: 145.099)
  oc_venue.save!
  oakleigh_cannons.save!
end

# Con's profile details
u2_club = Club.where(name: 'Oakleigh Cannons FC').first
if u2_club
  u2_team = u2_club.teams.where(name: 'U18 - PS4 NPL EAST VIC').first
  u2.update_attributes(position: 'Midfielder', nationality: 'Australia', club: u2_club, team: u2_team,
                       nickname: 'Harbs', dob: DateTime.parse('1975-09-16'))
  u2pp = u2.create_player_profile(player_no: 8, height_cm: 168, weight_kg: 65, handedness: :right_foot)

  u2.results.create(played_game: true, sport: 'Soccer', goals: 1, own_goals: 0, subst_on: 0,
                    subst_off: 0, home_or_away: 2, minutes_played: 90,
                    specialized: { :penalty_goals => 0, :assists => 2, :yellow_cards => 1, :red_cards => 0 },
                    game_id: Game.where(ref: 'U18-PS4NPLEastVICPMSSOCF20150315').first, team_id: u2_team)

  u2.results.create(played_game: true, sport: 'Soccer', goals: 1, own_goals: 0, subst_on: 0,
                    subst_off: 0, home_or_away: 2, minutes_played: 90,
                    specialized: { :penalty_goals => 0, :assists => 0, :yellow_cards => 0, :red_cards => 1 },
                    game_id: Game.where(ref: 'U18-PS4NPLEastVICSMFOCF20150510').first, team_id: u2_team)

  u2.results.create(played_game: true, sport: 'Soccer', goals: 0, own_goals: 0, subst_on: 0,
                    subst_off: 0, home_or_away: 2, minutes_played: 0,
                    specialized: { :penalty_goals => 0, :assists => 0, :yellow_cards => 0, :red_cards => 0 },
                    game_id: Game.where(ref: 'U18-PS4NPLEastVICHUFOCF20150322').first, team_id: u2_team,
                    notes: '- I have some test notes here\n- I played a great game and hit the post\n- Very sore as ' \
                           'was fouled constantly')
end

# Create equipment
adidas = Brand.where(name: 'Adidas').first_or_create!
nike = Brand.where(name: 'Nike').first_or_create!
b3 = Brand.where(name: 'GuardMark').first_or_create!
b4 = Brand.where(name: 'FeatherGlove').first_or_create!
b5 = Brand.where(name: 'ShinDigs').first_or_create!

Equipment.where(brand: adidas, model: 'All Weather Boots').first_or_create!(equipment_type: BOOTS)
Equipment.where(brand: b3, model: 'GuardStop').first_or_create!(equipment_type: GUARDS)
Equipment.where(brand: b4, model: 'Glove Model').first_or_create!(equipment_type: GLOVES)
Equipment.where(brand: b5, model: 'Shins First').first_or_create!(equipment_type: SHINPADS)

