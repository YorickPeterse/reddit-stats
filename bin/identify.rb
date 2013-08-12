require_relative '../lib/reddit'

# This script performs some very naive gender analysis based on the titles of
# existing posts. Note that this code is in every possible way bad (globals, no
# OO, etc, etc) but w/e, it's a hack anyway.

MALE_IDENTIFIERS   = %w{boy boys men man guy guys}
FEMALE_IDENTIFIERS = %w{girl girls women woman}

def identify(text)
  male_score   = 0
  female_score = 0
  words        = text.split(/\s+/)
  gender       = 'unknown'

  MALE_IDENTIFIERS.each do |ident|
    male_score += 1 if words.include?(ident)
  end

  FEMALE_IDENTIFIERS.each do |ident|
    female_score += 1 if words.include?(ident)
  end

  if female_score > male_score
    gender = 'female'
  elsif female_score < male_score
    gender = 'male'
  end

  return gender
end

# Too lazy for JOINs and WHERE NOT.
Post.where(:title_gender => nil, :body_gender => nil).each do |post|
  title_gender = identify(post.title)
  body_gender  = identify(post.body)

  LOGGER.info(
    "Post ##{post.id}: title gender: #{title_gender}, " \
      "body gender: #{body_gender}"
  )

  post.update(:title_gender => title_gender, :body_gender => body_gender)
end
