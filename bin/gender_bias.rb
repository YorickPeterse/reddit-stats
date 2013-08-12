require_relative '../lib/reddit'

# This script uses the gender results of each post title to see if there's a
# bias towards a particular gender. This analysis is, similar to the
# identification process, super naive. The code is also shit.

genders = %w{male female}

posts = DB[:posts].select { [:title_gender, count(:id).as(:value)] }
  .where(:title_gender => genders)
  .group(:title_gender)

ratio = DB[:posts].select { [:title_gender, sum(:comments).as(:value)] }
  .where(:title_gender => genders)
  .group(:title_gender)

upvotes = DB[:posts].select { [:title_gender, sum(:upvotes).as(:upvotes), sum(:downvotes).as(:downvotes)] }
  .where(:title_gender => genders)
  .group(:title_gender)

puts '## Posts classified as male/female:'
puts

posts.each do |post|
  puts "#{post[:title_gender]}: #{post[:value]}"
end

puts
puts '## Male/female ratio for comments:'
puts

ratio.each do |post|
  puts "#{post[:title_gender]}: #{post[:value]}"
end

puts
puts '## Male/female upvotes:'
puts

upvotes.each do |post|
  puts "#{post[:title_gender]}: upvotes: #{post[:upvotes]}, " \
    "downvotes: #{post[:downvotes]}"
end
