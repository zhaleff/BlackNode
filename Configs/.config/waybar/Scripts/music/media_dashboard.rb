#!/usr/bin/env ruby
# media_dashboard.rb
# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

# --- Spotify Control ---
def spotify_metadata
  status = `playerctl -p spotify status 2>/dev/null`.strip
  return nil unless $?.success?

  artist = `playerctl -p spotify metadata artist 2>/dev/null`.strip
  title = `playerctl -p spotify metadata title 2>/dev/null`.strip
  { status: status, artist: artist, title: title }
end

def spotify_play_pause
  system('playerctl -p spotify play-pause')
end

def spotify_next
  system('playerctl -p spotify next')
end

def spotify_previous
  system('playerctl -p spotify previous')
end

# --- News Feed (Hacker News Top Stories) ---
def fetch_news
  uri = URI('https://hacker-news.firebaseio.com/v0/topstories.json')
  top_ids = JSON.parse(Net::HTTP.get(uri))[0..4]

  stories = top_ids.map do |id|
    story_uri = URI("https://hacker-news.firebaseio.com/v0/item/#{id}.json")
    story = JSON.parse(Net::HTTP.get(story_uri))
    { title: story['title'], url: story['url'] }
  end
  stories
rescue => e
  [{ title: "Error: #{e.message}", url: '' }]
end

# --- Main Script (Waybar Output) ---
def waybar_output
  metadata = spotify_metadata

  if metadata
    icon = metadata[:status] == 'Playing' ? '' : ''
    text = "#{icon} #{metadata[:artist]} - #{metadata[:title]}"
    tooltip = "Click to open dashboard"
    class_name = metadata[:status] == 'Playing' ? 'playing' : 'paused'
  else
    text = "󰝚 Spotify"
    tooltip = "Spotify not playing"
    class_name = 'inactive'
  end

  puts JSON.generate(text: text, tooltip: tooltip, class: class_name)
end

# --- Dashboard Menu (Rofi) ---
def show_dashboard
  metadata = spotify_metadata
  stories = fetch_news

  # Construir opciones del menú
  menu_items = []
  if metadata
    status_icon = metadata[:status] == 'Playing' ? '󰏤' : '󰐊'
    menu_items << "#{status_icon} #{metadata[:status] == 'Playing' ? 'Pause' : 'Play'} | spotify_toggle"
    menu_items << "󰒮 Next | spotify_next"
    menu_items << "󰒭 Previous | spotify_prev"
  else
    menu_items << "󰝚 Open Spotify | open_spotify"
  end
  menu_items << "---"
  stories.each_with_index do |story, idx|
    title = story[:title].length > 50 ? "#{story[:title][0..47]}..." : story[:title]
    menu_items << "#{idx + 1}. #{title} | open_news_#{idx}"
  end

  selected = `printf '%s\n' "#{menu_items.join('\n')}" | rofi -dmenu -i -p "Dashboard" -theme-str 'window {width: 50%;}'`.strip
  return if selected.empty?

  action = selected.split('|').last.strip
  case action
  when 'spotify_toggle'
    spotify_play_pause
  when 'spotify_next'
    spotify_next
  when 'spotify_prev'
    spotify_previous
  when 'open_spotify'
    system('spotify &')
  when /^open_news_(\d+)/
    idx = Regexp.last_match(1).to_i
    system("xdg-open '#{stories[idx]['url']}'") if stories[idx] && !stories[idx]['url'].empty?
  end
end

# --- Entry Point ---
if ARGV.include?('--dashboard')
  show_dashboard
else
  waybar_output
end
