#!/usr/bin/env ruby
# waybar/scripts/weather/get_weather.rb
# frozen_string_literal: true

# Waybar weather (Open-Meteo.com)
# - Text: current temp + icon (colored via <span>)
# - Tooltip: current details + next N hours table + up to 16-day table
# - Uses weather_icons.json mapping for WMO condition glyphs
# - Emits Waybar JSON (set return-type=json, markup=true)

require 'json'
require 'set'
require 'net/http'
require 'uri'
require 'time'
require 'cgi'
require 'fileutils'

# ─── Modules ────────────────────────────────────────────────────────────────

# A module for general-purpose helper functions
#
module Utils
  class << self
    # Loads a JSON or JSONC file and parses it.
    #
    # @param path [String] Path to the JSON/JSONC file
    # @return [Hash, Array] Parsed JSON data
    # @raise [Errno::ENOENT] If file doesn't exist
    # @raise [JSON::ParserError] If file contains invalid JSON
    def load_json(path)
      file_content = File.read(path, encoding: 'utf-8')
      content_no_comments = file_content.gsub(%r{//.*$}, '')
      JSON.parse(content_no_comments)
    end

    # Parses a value into an integer, with a fallback default.
    #
    # @param val [Object] Value to parse (Numeric, String, or nil)
    # @param default [Integer] Default value if parsing fails
    # @return [Integer] Parsed integer or default
    def parse_int(val, default = 0)
      return default if val.nil? || val == ''
      return val.to_i if val.is_a?(Numeric)
      return val.to_i if val.to_s.match?(/\A-?\d+\z/)
      return val.to_f.to_i if val.to_s.match?(/\A-?\d+\.?\d*\z/)

      default
    end

    # Parses a value into a float, with a fallback default.
    def parse_float(val, default = 0.0)
      return default if val.nil? || val == ''
      return val.to_f if val.is_a?(Numeric)
      return val.to_f if val.to_s.match?(/\A-?\d+\.?\d*\z/)

      default
    end

    # Formats a Time/DateTime object into a formatted hour string.
    #
    # @param datetime [Time] The Time or DateTime object to format.
    # @param time_format [String, nil] Optional time format override ('24h' for military, '12h' for AM/PM).
    #   If nil, uses Config.time_format.
    # @param hour_display [String, nil] Optional hour display mode ('icons', 'number', 'both').
    #   If nil, uses Config.hour_display.
    # @return [String] Formatted hour string.
    def fmt_hour(datetime, time_format = nil, hour_display = nil)
      format = time_format || Config.time_format
      display_mode = hour_display || Config.hour_display

      number_str = if format == '12h'
                     datetime.strftime('%I %P') # e.g., "03 pm", "12 am"
                   else
                     datetime.strftime('%H') # e.g., "03", "15"
                   end

      icon_str = Icons.get_clock_icon(datetime.hour)

      case display_mode
      when 'icons'
        if icon_str
          # Icons mode: icon + am/pm only
          styled_icon = Icons.style_icon(icon_str, Config.colors['primary'], Config.pongo_size[:small]).rstrip
          am_pm = datetime.strftime('%P')
          "#{styled_icon} #{am_pm}"
        else
          number_str
        end
      when 'both'
        if icon_str
          styled_icon = Icons.style_icon(icon_str, Config.colors['primary'], Config.pongo_size[:small]).rstrip
          "#{styled_icon} #{number_str}"
        else
          number_str
        end
      else
        number_str
      end
    end

    def fmt_day_of_week(datestr)
      # e.g., 'Mon 10/06'
      Time.strptime(datestr, '%Y-%m-%d').strftime('%a %m/%d')
    end
  end
end

# Main configuration, merges with user config for dynamic user settings based on json file
module Config
  @settings = {
    colors: {
      'primary' => '#42A5F5',
      'cold' => 'skyblue',
      'neutral' => '#42A5F5',
      'warm' => 'khaki',
      'hot' => 'indianred',
      'pop_low' => '#EAD7FF',
      'pop_med' => '#CFA7FF',
      'pop_high' => '#BC85FF',
      'pop_vhigh' => '#A855F7',
      'divider' => '#2B3B57'
    },
    icon_type: 'nerd', # 'nerd' | 'emoji'
    icon_position: 'left', # 'left' | 'right'
    font_size: 14, # in px
    unit: 'Celsius', # 'Celsius' | 'Fahrenheit'
    hourly_number_of_hours: 24, # max 24
    daily_number_of_days: 10, # max 16
    snapshot_number_of_days: 2, # max 3, used in week view
    latitude: 'auto', # or float
    longitude: 'auto', # or float
    refresh_interval: 900, # seconds between API calls
    time_format: '24h', # '24h' or '12h'
    hour_display: 'number', # 'icons' | 'number' | 'both'
    color_weather_icons: false, # enable weather-specific icon colors
    weather_colors: {}, # weather-specific icon colors
    pongo_size: {}
  }

  SETTING_KEY_MAP = {
    'icon_type' => :icon_type,
    'icon_position' => :icon_position,
    'font_size' => :font_size,
    'unit' => :unit,
    'hourly_number_of_hours' => :hourly_number_of_hours,
    'daily_number_of_days' => :daily_number_of_days,
    'snapshot_number_of_days' => :snapshot_number_of_days,
    'latitude' => :latitude,
    'longitude' => :longitude,
    'refresh_interval' => :refresh_interval,
    'time_format' => :time_format,
    'hour_display' => :hour_display
  }.freeze

  class << self
    attr_reader :settings

    def init
      user_config = load_user_config

      # Merge colors settings
      if user_config.key?('colors') && user_config['colors'].is_a?(Hash)
        @settings[:colors].merge!(user_config['colors'])
      end

      # Merge weather_colors settings
      if user_config.key?('weather_colors') && user_config['weather_colors'].is_a?(Hash)
        @settings[:weather_colors].merge!(user_config['weather_colors'])
      end

      # Load color_weather_icons boolean
      @settings[:color_weather_icons] = user_config['color_weather_icons'] if user_config.key?('color_weather_icons')

      # Handle font size calculations
      self.set_font_size = user_config['font_size'] if user_config.key?('font_size')

      # Merge other settings
      SETTING_KEY_MAP.each do |config_key, settings_key|
        @settings[settings_key] = user_config[config_key] if user_config.key?(config_key)
      end

      # Enforce maximum limit for hourly_number_of_hours
      if @settings[:hourly_number_of_hours]
        @settings[:hourly_number_of_hours] = [[1, @settings[:hourly_number_of_hours].to_i].max, 24].min
      end

      # Enforce maximum limit for snapshot_number_of_days
      return unless @settings[:snapshot_number_of_days]

      @settings[:snapshot_number_of_days] = [[1, @settings[:snapshot_number_of_days].to_i].max, 3].min
    end

    def colors
      @settings[:colors]
    end

    def pongo_size
      @settings[:pongo_size]
    end

    def icon_type
      @settings[:icon_type]
    end

    def time_format
      @settings[:time_format]
    end

    def hour_display
      @settings[:hour_display]
    end

    def unit_c?
      @settings[:unit] == 'Celsius'
    end

    def unit
      unit_c? ? '°C' : '°F'
    end

    def precip_unit
      unit_c? ? 'mm' : 'in'
    end

    def set_color(key, value)
      @settings[:colors][key] = value
    end

    def set_font_size=(value)
      @settings[:font_size] = value
      update_pongo_sizes
    end

    private

    def update_pongo_sizes
      current_size = @settings[:font_size]
      @settings[:pongo_size] = {
        small: (current_size - 2) * 1000,
        medium: current_size * 1000,
        large: (current_size + 4) * 1000
      }
    end

    def load_user_config
      cfg_path = File.join(__dir__, 'weather_settings.jsonc')
      data = Utils.load_json(cfg_path)
      raise 'weather_settings.jsonc must be a JSON object' unless data.is_a?(Hash)

      data
    end
  end

  update_pongo_sizes
end

# Handles Icon storage, mapping, and styling
module Icons
  class << self
    def init(icon_type)
      @icon_map = load_icon_map(__dir__)
      all_ui_icons = Utils.load_json(File.join(__dir__, 'ui_icons.json'))
      @ui_icons = all_ui_icons[icon_type] || all_ui_icons['nerd']
    end

    def get_ui(key)
      keys = key.split('.')
      keys.reduce(@ui_icons) { |acc, k| acc&.[](k) }
    end

    def get_clock_icon(hour)
      # Map hour (0-23) to clock face (1-12)
      clock_hour = hour % 12
      clock_hour = 12 if clock_hour == 0
      get_ui("hour.#{clock_hour}")
    end

    def weather_icon(code, is_day)
      code = code.to_i
      icon_type = Config.icon_type

      @icon_map.each do |item|
        next unless item['code'].to_i == code

        icon_key = is_day ? "icon-#{icon_type}" : "icon-#{icon_type}-night"
        fallback_key = is_day ? "icon-#{icon_type}" : "icon-#{icon_type}"

        return item[icon_key] || item[fallback_key] || ''
      end

      ''
    end

    def weather_color(code, is_day)
      return Config.colors['primary'] unless Config.settings[:color_weather_icons]

      # Map WMO codes to weather color keys
      code = code.to_i
      color_key = case code
                  when 0, 1
                    is_day ? 'clear_day' : 'clear_night'
                  when 2
                    is_day ? 'partly_cloudy_day' : 'partly_cloudy_night'
                  when 3
                    'overcast'
                  when 45, 48
                    'fog'
                  when 51, 53
                    'drizzle'
                  when 55, 56
                    'drizzle'
                  when 57
                    'freezing_rain'
                  when 61
                    'rain'
                  when 63
                    'rain'
                  when 65, 82
                    'heavy_rain'
                  when 66, 67
                    'freezing_rain'
                  when 71, 73
                    'snow'
                  when 75, 77
                    'heavy_snow'
                  when 80, 81
                    'rain'
                  when 85
                    'snow'
                  when 86
                    'heavy_snow'
                  when 95, 96, 99
                    'thunderstorm'
                  end

      # Return the color or fall back to primary
      color_key ? Config.settings[:weather_colors][color_key] || Config.colors['primary'] : Config.colors['primary']
    end

    def style_icon(glyph, color = Config.colors['primary'], size = Config.pongo_size[:medium])
      "<span foreground='#{color}' size='#{size}'>#{glyph} </span>"
    end

    private

    def load_icon_map(script_path)
      data = Utils.load_json(File.join(script_path, 'weather_icons.json'))
      data.is_a?(Array) ? data : []
    rescue StandardError
      []
    end
  end
end

# Parses temperature into glyphs and colors
module Temperature
  SEASONAL_BIAS = ENV.fetch('SEASONAL_BIAS', '1') == '1'
  SUMMER_MONTHS = (5..9).freeze
  SHOULDER_MONTHS = [3, 4, 10].freeze
  DEFAULT_COLD_C = 5
  DEFAULT_COLD_F = 41

  class << self
    def init(unit:, bias:, month: Time.now.month)
      @unit = unit
      @seasonal_bias_enabled = bias
      @current_month = month
      @temperature_bands = build_temperature_bands
    end

    def thermometer_icon
      {
        COLD: Icons.get_ui('thermometer.cold'),
        NEUTRAL: Icons.get_ui('thermometer.neutral'),
        WARM: Icons.get_ui('thermometer.warm'),
        HOT: Icons.get_ui('thermometer.hot')
      }
    end

    def cold_band
      [thermometer_icon[:COLD], Config.colors['cold']]
    end

    def neutral_band
      [thermometer_icon[:NEUTRAL], Config.colors['neutral']]
    end

    def warm_band
      [thermometer_icon[:WARM], Config.colors['warm']]
    end

    def hot_band
      [thermometer_icon[:HOT], Config.colors['hot']]
    end

    def glyph_and_color(temp)
      found_band = @temperature_bands.find do |limit, _glyph, _color|
        temp < limit
      end
      return nil if found_band.nil?

      [found_band[1], found_band[2]]
    end

    def color(temp)
      glyph_and_color = glyph_and_color(temp)
      return unless glyph_and_color

      glyph_and_color.last
    end

    def glyph(temp)
      glyph_and_color = glyph_and_color(temp)
      return unless glyph_and_color

      glyph_and_color.first
    end

    # --- Private Helpers ---
    private

    def build_temperature_bands
      cold, neutral, warm = temperature_limits

      [
        [cold, *Temperature.cold_band],
        [neutral, *Temperature.neutral_band],
        [warm,    *Temperature.warm_band],
        [Float::INFINITY, *Temperature.hot_band]
      ]
    end

    def temperature_limits
      cold_limit = calculate_cold_limit

      if celsius?
        [cold_limit, 20, 28]
      else
        [cold_limit, 68, 82]
      end
    end

    def calculate_cold_limit
      unless @seasonal_bias_enabled
        return celsius? ? DEFAULT_COLD_C : DEFAULT_COLD_F
      end

      if celsius?
        calculate_seasonal_celsius_cold_limit
      else
        calculate_seasonal_fahrenheit_cold_limit
      end
    end

    def calculate_seasonal_celsius_cold_limit
      return 10 if SUMMER_MONTHS.cover?(@current_month)
      return 8 if SHOULDER_MONTHS.include?(@current_month)

      DEFAULT_COLD_C
    end

    def calculate_seasonal_fahrenheit_cold_limit
      celsius_limit = calculate_seasonal_celsius_cold_limit
      ((celsius_limit * 9.0 / 5.0) + 32).round
    end

    def celsius?
      @unit.to_s.strip.start_with?('°C')
    end
  end
end

# Parses Precipitation (PoP) into glyphs and colors
module Precipitation
  POP_ALERT_THRESHOLD = 60

  class << self
    def precipitation_icon
      {
        LOW: Icons.get_ui('precipitation.low'),
        HIGH: Icons.get_ui('precipitation.high')
      }
    end

    def color(pop)
      pop = [[0, pop.to_i].max, 100].min
      return Config.colors['pop_low'] if pop < 30   # 0–29
      return Config.colors['pop_med'] if pop < 60   # 30–59
      return Config.colors['pop_high'] if pop < 80  # 60–79

      Config.colors['pop_vhigh'] # 80–Infinity
    end

    def icon(pop)
      pop >= POP_ALERT_THRESHOLD ? Precipitation.precipitation_icon[:HIGH] : Precipitation.precipitation_icon[:LOW]
    end
  end
end

# Parses Moon phase into description, icons, and emoji
module MoonPhase
  KNOWN_NEW_MOON = Time.utc(2000, 1, 6, 18, 14, 0)
  LUNAR_CYCLE = 29.530588861 # Lunar cycle length in days

  class << self
    # Calculates moon phase for a given date
    # @param date [Time, String] Date to calculate phase for
    # @return [Float] Moon phase value (0-1 scale)
    def calculate_phase(date)
      date = Time.parse(date.to_s) unless date.is_a?(Time)
      days_since = (date - KNOWN_NEW_MOON) / 86_400.0

      # Calculate phase (0-1 scale)
      phase = (days_since % LUNAR_CYCLE) / LUNAR_CYCLE

      phase % 1.0
    end

    # Converts moon phase value (0-1) to phase name
    # @param phase [Float] Moon phase from API (0-1 scale)
    # @return [String] Phase name
    def phase_name(phase)
      return 'Unknown' if phase.nil?

      phase = phase.to_f

      case phase
      when 0.0...0.0625, 0.9375..1.0
        'New Moon'
      when 0.0625...0.1875
        'Waxing Crescent'
      when 0.1875...0.3125
        'First Quarter'
      when 0.3125...0.4375
        'Waxing Gibbous'
      when 0.4375...0.5625
        'Full Moon'
      when 0.5625...0.6875
        'Waning Gibbous'
      when 0.6875...0.8125
        'Last Quarter'
      when 0.8125...0.9375
        'Waning Crescent'
      else
        'Unknown'
      end
    end

    # Gets moon phase icon key for ui_icons lookup
    # @param phase [Float] Moon phase from API (0-1 scale)
    # @return [String] Icon key for Icons.get_ui lookup
    def icon_key(phase)
      return 'moon.new' if phase.nil?

      phase = phase.to_f

      case phase
      when 0.0...0.0625, 0.9375..1.0
        'moon.new'
      when 0.0625...0.1875
        'moon.waxing_crescent'
      when 0.1875...0.3125
        'moon.first_quarter'
      when 0.3125...0.4375
        'moon.waxing_gibbous'
      when 0.4375...0.5625
        'moon.full'
      when 0.5625...0.6875
        'moon.waning_gibbous'
      when 0.6875...0.8125
        'moon.last_quarter'
      when 0.8125...0.9375
        'moon.waning_crescent'
      else
        'moon.new'
      end
    end

    # Gets moon phase icon with styling
    # @param phase [Float] Moon phase from API (0-1 scale)
    # @param color [String] Optional color override
    # @param size [Integer] Optional size override
    # @return [String] Styled icon HTML
    def icon(phase, color = nil, size = nil)
      key = icon_key(phase)
      glyph = Icons.get_ui(key)
      color ||= Config.settings[:weather_colors]['clear_night'] || Config.colors['primary']
      size ||= Config.pongo_size[:small]
      Icons.style_icon(glyph, color, size)
    end

    # Formats moon phase as percentage with description
    # @param phase [Float] Moon phase from API (0-1 scale)
    # @return [String] Formatted string like "50% (Full Moon)"
    def format_phase(phase)
      return 'N/A' if phase.nil?

      percentage = (phase.to_f * 100).round
      name = phase_name(phase)
      "#{percentage}% (#{name})"
    end
  end
end

# Handles mode toggles to view different weather tooltips.
# Stores the current mode in XDG_STATE_HOME/waybar/weather_mode.
module WeatherMode
  DEFAULT = 'default'
  WEEKVIEW = 'weekview'
  MODES = [DEFAULT, WEEKVIEW].freeze
  DEFAULT_MODE = DEFAULT

  class << self
    # Gets the current display mode.
    #
    # @return [String] Current mode (DEFAULT or WEEKVIEW)
    def get
      mode = File.read(file_path, encoding: 'utf-8').strip
      MODES.include?(mode) ? mode : DEFAULT_MODE
    rescue Errno::ENOENT
      DEFAULT_MODE
    end

    # Sets the display mode.
    #
    # @param mode [String] Mode to set (must be in MODES)
    # @return [void]
    def set(mode)
      return unless MODES.include?(mode)

      File.write(file_path, mode, encoding: 'utf-8')
    end

    # Cycles to the next or previous mode.
    #
    # @param direction [String] 'next' or 'prev'
    # @return [void]
    def cycle(direction = 'next')
      current_index = MODES.index(get) || 0
      new_index = if direction == 'prev'
                    (current_index - 1) % MODES.length
                  else
                    (current_index + 1) % MODES.length
                  end
      set(MODES[new_index])
    end

    private

    def file_path
      state_home = ENV['XDG_STATE_HOME'] || File.expand_path('~/.local/state')
      dir = File.join(state_home, 'waybar')
      FileUtils.mkdir_p(dir)
      File.join(dir, 'weather_mode')
    end
  end
end

# Manages weather data caching to reduce API calls
module CacheManager
  class << self
    # Checks if cached data is still fresh based on refresh interval
    #
    # @param refresh_interval [Integer] Seconds before cache expires
    # @return [Boolean] True if cache exists and is fresh
    def fresh?(refresh_interval = 900)
      return false unless File.exist?(cache_file_path)

      cache = load_cache
      return false unless cache && cache['timestamp']

      age = Time.now.to_i - cache['timestamp'].to_i
      age < refresh_interval
    rescue StandardError
      false
    end

    # Loads cached weather data
    #
    # @return [Hash, nil] Cached data or nil if not available/invalid
    def load_cache
      return nil unless File.exist?(cache_file_path)

      content = File.read(cache_file_path, encoding: 'utf-8')
      JSON.parse(content)
    rescue StandardError
      nil
    end

    # Saves weather data to cache
    #
    # @param location [Hash] Location data with :lat, :lon, :location_name
    # @param weather_data [Hash] Weather data hash
    # @param units [Hash] Unit configuration hash
    # @param settings [Hash] Settings hash
    # @return [void]
    def save_cache(location:, weather_data:, units:, settings:)
      cache_data = {
        'timestamp' => Time.now.to_i,
        'settings' => {
          'latitude' => settings[:latitude],
          'longitude' => settings[:longitude],
          'unit' => settings[:unit]
        },
        'location' => location,
        'weather_data' => weather_data,
        'units' => units
      }

      File.write(cache_file_path, JSON.generate(cache_data), encoding: 'utf-8')
    rescue StandardError => e
      # Silently fail, caching is not critical
      warn "Cache write failed: #{e.message}" if ENV['DEBUG']
    end

    # Validates that cached settings match current settings
    #
    # @param settings [Hash] Current settings
    # @return [Boolean] True if settings match
    def settings_match?(settings)
      cache = load_cache
      return false unless cache && cache['settings'] && cache['units']

      cached_settings = cache['settings']
      cached_units = cache['units']
      settings[:latitude].to_s == cached_settings['latitude'].to_s &&
        settings[:longitude].to_s == cached_settings['longitude'].to_s &&
        settings[:unit].to_s == cached_settings['unit'].to_s &&
        Config.time_format.to_s == cached_units['time_format'].to_s
    end

    private

    def cache_file_path
      state_home = ENV['XDG_STATE_HOME'] || File.expand_path('~/.local/state')
      dir = File.join(state_home, 'waybar')
      FileUtils.mkdir_p(dir)
      File.join(dir, 'weather_cache.json')
    end
  end
end

# Handles weather data fetching and parsing
module ForecastData
  class << self
    # Resolves location coordinates from settings (auto-detect or manual).
    # If latitude or longitude is set to 'auto', uses IP geolocation.
    # Otherwise returns the configured coordinates.
    #
    # @param settings [Hash] Configuration settings hash with :latitude and :longitude keys
    # @return [Hash] Location data with :lat, :lon, and :location_name keys
    # @example Auto-detect location
    #   resolve_location({latitude: 'auto', longitude: 'auto'})
    #   # => {lat: 40.7128, lon: -74.0060, location_name: "New York, NY, USA"}
    # @example Use configured location
    #   resolve_location({latitude: 51.5074, longitude: -0.1278})
    #   # => {lat: 51.5074, lon: -0.1278, location_name: nil}
    def resolve_location(settings)
      if settings[:latitude].to_s == 'auto' || settings[:longitude].to_s == 'auto'
        geo_data = fetch_location_from_ip
        {
          lat: geo_data['lat'],
          lon: geo_data['lon'],
          location_name: geo_data['location_name']
        }
      else
        {
          lat: Utils.parse_float(settings[:latitude]),
          lon: Utils.parse_float(settings[:longitude]),
          location_name: nil
        }
      end
    end

    # Fetches location from IP address using ip-api.com
    def fetch_location_from_ip
      # Use ip-api.com for free IP geolocation (no API key required)
      # Rate limit: 45 requests/minute
      url = URI('http://ip-api.com/json/?fields=lat,lon,city,regionName,country')

      response = Net::HTTP.get_response(url)
      raise "IP geolocation error: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      raise 'Unexpected response from ip-api.com' unless data.is_a?(Hash)

      {
        'lat' => Utils.parse_float(data['lat']),
        'lon' => Utils.parse_float(data['lon']),
        'location_name' => "#{data['city']}, #{data['regionName']}, #{data['country']}"
      }
    end

    # Fetches weather forecast from Open-Meteo API.
    #
    # @param lat [Float] Latitude coordinate
    # @param lon [Float] Longitude coordinate
    # @param unit_c [Boolean] True for Celsius, false for Fahrenheit
    # @param daily_number_of_days [Integer] Number of days to forecast (max 16)
    # @return [Hash] Parsed API response with current, hourly, and daily data
    # @raise [Net::HTTPError] If API request fails
    # @raise [JSON::ParserError] If response is not valid JSON
    def fetch_openmeteo_forecast(lat, lon, unit_c, daily_number_of_days = 16)
      url = URI('https://api.open-meteo.com/v1/forecast')

      params = {
        latitude: lat,
        longitude: lon,
        current: 'temperature_2m,apparent_temperature,is_day,precipitation,weather_code',
        hourly: 'temperature_2m,precipitation_probability,precipitation,weather_code,is_day',
        daily: 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,sunrise,sunset',
        temperature_unit: unit_c ? 'celsius' : 'fahrenheit',
        precipitation_unit: unit_c ? 'mm' : 'inch',
        timezone: 'auto',
        daily_number_of_days: daily_number_of_days
      }
      url.query = URI.encode_www_form(params)

      response = Net::HTTP.get_response(url)
      raise "HTTP Error: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      raise 'Unexpected response from Open-Meteo' unless data.is_a?(Hash)

      data
    end

    # Extracts current weather conditions from API response
    def extract_current(blob, _unit, location_name = nil)
      cur = blob['current']
      timezone = blob['timezone']
      now_local = Time.parse(cur['time'])

      {
        'timezone' => timezone,
        'location_name' => location_name,
        'cond' => WeatherCode.description(cur['weather_code']),
        'code' => cur['weather_code'].to_i,
        'temp' => Utils.parse_float(cur['temperature_2m']),
        'feels' => Utils.parse_float(cur['apparent_temperature']),
        'precip_amt' => Utils.parse_float(cur['precipitation']),
        'is_day' => Utils.parse_int(cur['is_day'], 1),
        'now_local' => now_local
      }
    end

    # Builds next N hours of forecast data
    def build_next_hours(blob, now_local, limit)
      hourly = blob['hourly']
      times = hourly['time']
      temps = hourly['temperature_2m']
      pops = hourly['precipitation_probability']
      precips = hourly['precipitation']
      codes = hourly['weather_code']
      is_days = hourly['is_day']

      hours_list = []

      times.each_with_index do |time_str, i|
        dt = Time.parse(time_str)

        hours_list << {
          'dt' => dt,
          'temp' => Utils.parse_float(temps[i]),
          'pop' => Utils.parse_int(pops[i]),
          'precip' => Utils.parse_float(precips[i]),
          'cond' => WeatherCode.description(codes[i]),
          'code' => codes[i].to_i,
          'is_day' => Utils.parse_int(is_days[i], 1)
        }
      end

      next_hours = hours_list.select { |h| h['dt'] >= now_local }[0, [0, limit].max]
      next_hours = hours_list[0, [0, limit].max] if next_hours.empty? && !hours_list.empty?
      next_hours
    end

    # Builds daily forecast for next N days
    def build_next_days(blob, max_days = 16)
      daily = blob['daily']
      dates = daily['time']
      max_temps = daily['temperature_2m_max']
      min_temps = daily['temperature_2m_min']
      codes = daily['weather_code']
      precips = daily['precipitation_sum']
      pops = daily['precipitation_probability_max']
      sunrises = daily['sunrise']
      sunsets = daily['sunset']

      days = []

      dates[0...max_days].each_with_index do |date_str, i|
        days << {
          'date' => date_str,
          'max' => Utils.parse_float(max_temps[i]),
          'min' => Utils.parse_float(min_temps[i]),
          'cond' => WeatherCode.description(codes[i]),
          'code' => codes[i].to_i,
          'precip' => Utils.parse_float(precips[i]),
          'pop' => Utils.parse_int(pops[i]),
          'sunrise' => sunrises[i],
          'sunset' => sunsets[i],
          'moon_phase' => MoonPhase.calculate_phase(date_str)
        }
      end

      days
    end

    # Builds detailed 3-hour interval forecast for next N days (configurable)
    def build_next_3days_detailed(blob, now_local, num_days = 3)
      hourly = blob['hourly']
      times = hourly['time']
      temps = hourly['temperature_2m']
      pops = hourly['precipitation_probability']
      precips = hourly['precipitation']
      codes = hourly['weather_code']
      is_days = hourly['is_day']

      today = now_local.strftime('%Y-%m-%d')

      rows = []
      picked_dates = Set.new

      times.each_with_index do |time_str, i|
        dt = Time.parse(time_str)
        date_str = dt.strftime('%Y-%m-%d')

        # Skip before today
        next if date_str <= today

        # Only process 3-hour intervals
        next unless (dt.hour % 3).zero?

        picked_dates << date_str
        break if picked_dates.size > num_days

        rows << {
          'date' => date_str,
          'dt' => dt,
          'temp' => Utils.parse_float(temps[i]),
          'pop' => Utils.parse_int(pops[i]),
          'precip' => Utils.parse_float(precips[i]),
          'cond' => WeatherCode.description(codes[i]),
          'code' => codes[i].to_i,
          'is_day' => Utils.parse_int(is_days[i], 1)
        }
      end

      rows.sort_by { |r| [r['date'], r['dt']] }
    end

    # Builds a lookup hash mapping dates to [sunrise, sunset] times
    def build_astro_by_date(days)
      # Map 'YYYY-MM-DD' -> [sunrise_24h, sunset_24h]
      out = {}
      days.each do |d|
        date_str = d['date']
        sr = d['sunrise'] ? Time.parse(d['sunrise']).strftime('%H:%M') : ''
        ss = d['sunset'] ? Time.parse(d['sunset']).strftime('%H:%M') : ''
        out[date_str] = [sr, ss]
      end
      out
    end

    # Builds a lookup hash mapping dates to moon_phase values
    def build_moon_by_date(days)
      # Map 'YYYY-MM-DD' -> moon_phase (0-1 float)
      out = {}
      days.each do |d|
        date_str = d['date']
        out[date_str] = d['moon_phase']
      end
      out
    end

    # Gets today's sunrise and sunset times
    def get_sun_times(days, now_local)
      today = now_local.strftime('%Y-%m-%d')
      days.each do |d|
        next unless d['date'] == today

        sr = d['sunrise'] ? Time.parse(d['sunrise']).strftime('%H:%M') : ''
        ss = d['sunset'] ? Time.parse(d['sunset']).strftime('%H:%M') : ''
        return [sr, ss]
      end
      ['', '']
    end

    # Gets today's moon phase
    def get_moon_phase_today(days, now_local)
      today = now_local.strftime('%Y-%m-%d')
      days.each do |d|
        return d['moon_phase'] if d['date'] == today
      end
      nil
    end
  end
end

# Handles building tooltips and tables for weather display
module TooltipBuilder
  DIVIDER_CHAR = '─'
  DIVIDER_LEN = 74

  # Table headers (static width tables only)
  DAY_TABLE_HEADER_TEXT = format(
    '%-<day>9s │ %<hi>5s │ %<lo>5s │ %<pop>4s │ %<precip>7s │ Cond',
    day: 'Day', hi: 'Hi', lo: 'Lo', pop: 'PoP', precip: 'Precip'
  )

  ASTRO3D_HEADER_TEXT = format(
    '%-<date>9s │ %<rise>5s │ %<set>5s │ %<day>7s │ %<night>8s │ %<moon>10s',
    date: 'Date', rise: 'Rise', set: 'Set', day: 'Day L.', night: 'Night L.', moon: 'Moon Phase'
  )

  class << self
    def sun_icon
      {
        RISE: Icons.get_ui('sun.rise'),
        SET: Icons.get_ui('sun.set')
      }
    end

    # Calculates the appropriate column width for the hour column based on display settings.
    #
    # @return [Integer] Column width in characters
    def calculate_hour_column_width
      hour_display = Config.hour_display
      time_format = Config.time_format
      icon_type = Config.icon_type

      case hour_display
      when 'icons'
        icon_width = icon_type == 'emoji' ? 3 : 2
        icon_width + 3
      when 'both'
        icon_width = icon_type == 'emoji' ? 3 : 2
        number_width = time_format == '12h' ? 6 : 3
        icon_width + number_width
      else
        time_format == '12h' ? 6 : 3
      end
    end

    # Build the waybar status text
    def build_waybar_status(cond:, temp:, code:, is_day:, icon_pos:, fallback_icon:)
      cond_icon_raw = Icons.weather_icon(code, is_day != 0) || fallback_icon
      waybar_icon = Icons.style_icon(cond_icon_raw, Icons.weather_color(code, is_day != 0), Config.pongo_size[:small])
      left = "#{waybar_icon}#{temp.round}#{Config.unit}"
      right = "#{temp.round}#{Config.unit} #{waybar_icon}"
      (icon_pos || 'left') == 'left' ? left : right
    end

    def build_text_and_tooltip(timezone:, cond:, temp:, feels:, precip_amt:, code:, is_day:, next_hours:,
                               days:, icon_pos:, fallback_icon:,
                               sunrise:, sunset:, moon_phase: nil, location_name: nil, daily_number_of_days: 16)
      text = build_waybar_status(
        cond: cond, temp: temp, code: code, is_day: is_day,
        icon_pos: icon_pos, fallback_icon: fallback_icon
      )

      next_hours_table = make_hour_table(next_hours)
      next_days_overview_table = make_day_table(days)

      header_block = build_header_block(
        timezone: timezone, cond: cond, temp: temp, feels: feels,
        code: code, is_day: is_day, fallback_icon: fallback_icon,
        sunrise: sunrise, sunset: sunset, moon_phase: moon_phase,
        now_pop: next_hours.empty? ? nil : next_hours[0]['pop'].to_i,
        precip_amt: precip_amt, location_name: location_name
      )

      tooltip = "#{header_block}\n" \
                "<b>#{Icons.style_icon(Icons.get_ui('clock'), Config.colors['primary'],
                                       Config.pongo_size[:small])} Hourly</b>\n\n" \
                "#{next_hours_table}\n\n#{divider}\n\n" \
                "<b>#{Icons.style_icon(Icons.get_ui('calendar'), Config.colors['primary'],
                                       Config.pongo_size[:small])} Daily</b>\n\n#{next_days_overview_table}"

      [text, tooltip]
    end

    def divider(length = DIVIDER_LEN, char = DIVIDER_CHAR, color = Config.colors['divider'])
      line = char * [1, length].max
      "<span font_family='monospace' foreground='#{color}'>#{line}</span>"
    end

    # Builds a compact table for sunrise/sunset for the dates present in rows
    def make_astro3d_table(rows, astro_by_date, moon_by_date = {}, max_days = nil)
      header = "<span weight='bold'>#{ASTRO3D_HEADER_TEXT}</span>"
      # If max_days is specified, use all dates from astro_by_date instead of just from rows
      dates = if max_days
                astro_by_date.keys.sort.take(max_days)
              else
                rows.map { |r| r['date'].to_s }.uniq.sort
              end
      lines = dates.map do |date|
        sunrise, sunset = astro_by_date.fetch(date, ['', ''])
        sunrise = (sunrise.empty? ? '—' : sunrise)[0, 5]
        sunset = (sunset.empty? ? '—' : sunset)[0, 5]

        day_len, night_len = calculate_day_night_length(astro_by_date.fetch(date, ['', '']))

        # Add moon phase lookup
        moon_phase = moon_by_date.fetch(date, nil)
        moon_display = if moon_phase
                         moon_icon = MoonPhase.icon(moon_phase)
                         "#{moon_icon} #{MoonPhase.phase_name(moon_phase)}"
                       else
                         '—'
                       end

        format('%-9s │ %5s │ %5s │ %7s │ %8s │ %s',
               Utils.fmt_day_of_week(date), sunrise, sunset, day_len, night_len, moon_display)
      end

      return 'No sunrise/sunset data' if lines.empty?

      "<span font_family='monospace'>#{header}\n#{lines.join("\n")}</span>"
    end

    # Calculates day length (sunrise to sunset) and night length (24h - day length)
    #
    # @param sun_times [Array<String>] Array with [sunrise_time, sunset_time] in 'HH:MM' format
    # @return [Array<String>] Array with [day_length, night_length] in 'HH:MM' format
    def calculate_day_night_length(sun_times)
      sunrise, sunset = sun_times
      return ['—', '—'] if sunrise.empty? || sunset.empty?

      # Parse times (assuming HH:MM format)
      sunrise_parts = sunrise.split(':').map(&:to_i)
      sunset_parts = sunset.split(':').map(&:to_i)

      # Convert to minutes
      sunrise_mins = sunrise_parts[0] * 60 + sunrise_parts[1]
      sunset_mins = sunset_parts[0] * 60 + sunset_parts[1]
      day_mins = sunset_mins - sunrise_mins
      night_mins = 24 * 60 - day_mins

      # Format as HH:MM
      day_len = format('%2dh %02dm', day_mins / 60, day_mins % 60)
      night_len = format('%2dh %02dm', night_mins / 60, night_mins % 60)

      [day_len, night_len]
    end

    # Builds hourly forecast table
    def make_hour_table(next_hours)
      hr_col_width = calculate_hour_column_width
      hour_table_header_text = format(
        "%<hr>-#{hr_col_width}s │ %<temp>5s │ %<pop>4s │ %<precip>7s │ Cond",
        hr: 'Hr', temp: 'Temp', pop: 'PoP', precip: 'Precip'
      )
      header = "<span weight='bold'>#{hour_table_header_text}</span>"
      rows = []

      next_hours.each do |h|
        temp_txt = "#{h['temp'].round}#{Config.unit}".rjust(5)
        temp_col = "<span foreground='#{Temperature.color(h['temp'])}'>#{temp_txt}</span>"

        pop_txt = "#{h['pop'].to_i}%".rjust(4)
        pop_col = "<span foreground='#{Precipitation.color(h['pop'])}'>#{pop_txt}</span>"

        precip_col = format('%<val>.1f %<unit>s', val: h['precip'], unit: Config.precip_unit).rjust(7)

        glyph = Icons.weather_icon(h['code'], h['is_day'] != 0)
        icon_html = if glyph.empty?
                      ''
                    else
                      Icons.style_icon(glyph, Icons.weather_color(h['code'], h['is_day'] != 0),
                                       Config.pongo_size[:small])
                    end
        cond_cell = "#{icon_html} #{CGI.escapeHTML(h['cond'].to_s)}".strip

        rows << format("%-#{hr_col_width}s │ %s │ %s │ %s │ %s",
                       Utils.fmt_hour(h['dt']), temp_col, pop_col, precip_col, cond_cell)
      end

      return 'No hourly data' if rows.empty?

      "<span font_family='monospace'>#{header}\n#{rows.join("\n")}</span>"
    end

    # Builds daily forecast table
    def make_day_table(days)
      header = "<span weight='bold'>#{DAY_TABLE_HEADER_TEXT}</span>"
      out_rows = []

      days.each do |d|
        hi_val = d['max'].round
        lo_val = d['min'].round

        hi_txt = format('%3d%s', hi_val, Config.unit)
        lo_txt = format('%3d%s', lo_val, Config.unit)

        hi_col = "<span foreground='#{Temperature.color(d['max'])}'>#{hi_txt}</span>"
        lo_col = "<span foreground='#{Temperature.color(d['min'])}'>#{lo_txt}</span>"

        pop = [[0, d['pop'].to_i].max, 100].min
        pop_txt = format('%3d%%', pop)
        pop_col = "<span foreground='#{Precipitation.color(pop)}'>#{pop_txt}</span>"

        precip_col = format('%<val>.1f %<unit>s', val: d['precip'], unit: Config.precip_unit).rjust(7)

        cond_txt = d['cond'].to_s
        glyph = Icons.weather_icon(d['code'], true)
        icon_html = if glyph.empty?
                      ''
                    else
                      Icons.style_icon(glyph, Icons.weather_color(d['code'], true),
                                       Config.pongo_size[:small])
                    end
        cond_cell = "#{icon_html} #{CGI.escapeHTML(cond_txt)}".strip

        row = format('%-9s │ %s │ %s │ %s │ %s │ %s',
                     Utils.fmt_day_of_week(d['date']), hi_col, lo_col, pop_col, precip_col, cond_cell)
        out_rows << row
      end

      return 'No daily data' if out_rows.empty?

      "<span font_family='monospace'>#{header}\n#{out_rows.join("\n")}</span>"
    end

    # Builds 3-hour interval forecast table
    def make_3h_table(rows)
      hr_col_width = calculate_hour_column_width
      detail3h_header_text = format(
        "%-<date>9s │ %<hr>#{hr_col_width}s │ %<temp>5s │ %<pop>4s │ %<precip>7s │ Cond",
        date: 'Date', hr: 'Hr', temp: 'Temp', pop: 'PoP', precip: 'Precip'
      )
      header = "<span weight='bold'>#{detail3h_header_text}</span>"
      out = []

      rows.each do |r|
        temp_txt = "#{r['temp'].round}#{Config.unit}".rjust(5)
        temp_col = "<span foreground='#{Temperature.color(r['temp'])}'>#{temp_txt}</span>"

        pop_val = [[0, r['pop'].to_i].max, 100].min
        pop_txt = format('%3d%%', pop_val)
        pop_col = "<span foreground='#{Precipitation.color(pop_val)}'>#{pop_txt}</span>"

        precip_col = format('%<val>.1f %<unit>s', val: r['precip'], unit: Config.precip_unit).rjust(7)

        glyph = Icons.weather_icon(r['code'], r['is_day'] != 0)
        icon_html = if glyph.empty?
                      ''
                    else
                      Icons.style_icon(glyph, Icons.weather_color(r['code'], r['is_day'] != 0),
                                       Config.pongo_size[:small])
                    end
        cond_cell = "#{icon_html} #{CGI.escapeHTML(r['cond'].to_s)}".strip

        out << format("%-9s │ %#{hr_col_width}s │ %s │ %s │ %s │ %s",
                      Utils.fmt_day_of_week(r['date']), Utils.fmt_hour(r['dt']), temp_col, pop_col, precip_col, cond_cell)
      end

      return 'No 3-hour detail' if out.empty?

      "<span font_family='monospace'>#{header}\n#{out.join("\n")}</span>"
    end

    # Builds the common header block for tooltips
    def build_header_block(timezone:, cond:, temp:, feels:, code:, is_day:, fallback_icon:,
                           sunrise: nil, sunset: nil, moon_phase: nil, now_pop: nil, precip_amt: nil, location_name: nil)
      display_location = location_name || timezone || 'Local'
      location_line = format('<b>%s</b>', CGI.escapeHTML(display_location))
      tglyph, tcolor = Temperature.glyph_and_color(feels)
      current_line = format('%s %s | %s%d%s (feels %d%s)',
                            Icons.style_icon(Icons.weather_icon(code, is_day != 0) || fallback_icon,
                                             Icons.weather_color(code, is_day != 0)),
                            CGI.escapeHTML(cond),
                            Icons.style_icon(tglyph, tcolor),
                            temp.round,
                            Config.unit,
                            feels.round,
                            Config.unit)

      # optional sunrise/sunset
      astro_line = ''
      if sunrise || sunset
        astro_line = format('%s Sunrise %s | %s Sunset %s',
                            Icons.style_icon(TooltipBuilder.sun_icon[:RISE]),
                            CGI.escapeHTML(sunrise || '—'),
                            Icons.style_icon(TooltipBuilder.sun_icon[:SET]),
                            CGI.escapeHTML(sunset || '—'))
      end

      # optional moon phase
      moon_line = ''
      if moon_phase
        moon_line = format('%s Moon Phase: %s',
                           MoonPhase.icon(moon_phase),
                           CGI.escapeHTML(MoonPhase.format_phase(moon_phase)))
      end

      # optional "now" precip / PoP (colored)
      now_line = ''
      if now_pop && precip_amt
        pop_icon_html = Icons.style_icon(Precipitation.icon(now_pop), Precipitation.color(now_pop))
        now_pop_col = "<span foreground='#{Precipitation.color(now_pop)}'>#{now_pop.to_i}%</span>"
        now_line = format('%s PoP %s, Precip %.1f%s',
                          pop_icon_html, now_pop_col, precip_amt, Config.precip_unit)
      end

      parts = [location_line, '', current_line]
      parts << astro_line unless astro_line.empty?
      parts << moon_line unless moon_line.empty?
      parts << now_line unless now_line.empty?
      parts << "\n#{divider}\n"
      parts.join("\n")
    end

    # Builds week view tooltip with detailed 3-hour forecast
    def build_week_view_tooltip(timezone:, cond:, temp:, feels:, code:, is_day:, fallback_icon:,
                                three_hour_rows:, sunrise: nil, sunset: nil, moon_phase: nil,
                                now_pop: nil, precip_amt: nil, astro_by_date: nil, moon_by_date: nil,
                                location_name: nil, max_astro_days: nil, snapshot_days: nil)
      header_block = build_header_block(
        timezone: timezone, cond: cond, temp: temp, feels: feels,
        code: code, is_day: is_day, fallback_icon: fallback_icon,
        sunrise: sunrise, sunset: sunset, moon_phase: moon_phase, now_pop: now_pop,
        precip_amt: precip_amt, location_name: location_name
      )

      astro_table = make_astro3d_table(three_hour_rows, astro_by_date || {}, moon_by_date || {}, max_astro_days)
      astro_header = "<b>#{Icons.style_icon(Icons.get_ui('sun.rise'), Config.colors['primary'],
                                            Config.pongo_size[:small])} " \
                     'Sunrise / Sunset &amp; ' \
                     "#{Icons.style_icon(Icons.get_ui('moon.night'), Config.colors['primary'],
                                         Config.pongo_size[:small])} Moon Phases</b>"

      snapshot_label = snapshot_days ? "Next #{snapshot_days} Day(s) Snapshot" : 'Snapshot'
      detail_header = "<b>#{Icons.style_icon(Icons.get_ui('calendar'), Config.colors['primary'],
                                             Config.pongo_size[:small])} #{snapshot_label}</b>"
      detail_table = make_3h_table(three_hour_rows)

      "#{header_block}\n#{astro_header}\n\n#{astro_table}\n\n#{divider}\n\n#{detail_header}\n\n#{detail_table}"
    end
  end
end

# View building strategies using the Strategy pattern.
# Delegates to appropriate builder based on display mode.
module ViewBuilder
  class << self
    # Builds view output by selecting the appropriate strategy.
    #
    # @param mode [String] Display mode (WeatherMode::DEFAULT or WeatherMode::WEEKVIEW)
    # @param weather_data [Hash] Weather data including :cur, :days, :next_hours, etc.
    # @param settings [Hash] Configuration settings
    # @return [Array<String, String>] Text and tooltip strings for waybar display
    def build(mode, weather_data, settings)
      builder = mode == WeatherMode::WEEKVIEW ? WeekViewBuilder : DefaultViewBuilder
      builder.build(weather_data, settings)
    end
  end
end

# Default view builder - shows current conditions, hourly forecast, and daily overview.
module DefaultViewBuilder
  class << self
    # Builds the default view with hourly and daily forecast tables.
    #
    # @param weather_data [Hash] Weather data hash
    # @param settings [Hash] Configuration settings
    # @return [Array<String, String>] Text and tooltip
    def build(weather_data, settings)
      cur = weather_data[:cur]
      days = weather_data[:days]
      next_hours = weather_data[:next_hours]
      sunrise = weather_data[:sunrise]
      sunset = weather_data[:sunset]
      moon_phase = weather_data[:moon_phase]
      fallback_icon = weather_data[:fallback_icon]

      TooltipBuilder.build_text_and_tooltip(
        timezone: cur['timezone'], cond: cur['cond'], temp: cur['temp'], feels: cur['feels'],
        precip_amt: cur['precip_amt'], code: cur['code'], is_day: cur['is_day'], next_hours: next_hours,
        days: days,
        icon_pos: settings[:icon_position], fallback_icon: fallback_icon, sunrise: sunrise, sunset: sunset,
        moon_phase: moon_phase, location_name: cur['location_name'], daily_number_of_days: settings[:daily_number_of_days]
      )
    end
  end
end

# Week view builder - shows detailed 3-hour interval forecast and sunrise/sunset times.
module WeekViewBuilder
  class << self
    # Builds the week view with 3-hour intervals and astronomy data.
    #
    # @param weather_data [Hash] Weather data hash
    # @param settings [Hash] Configuration settings
    # @return [Array<String, String>] Text and tooltip
    def build(weather_data, settings)
      cur = weather_data[:cur]
      next_hours = weather_data[:next_hours]
      sunrise = weather_data[:sunrise]
      sunset = weather_data[:sunset]
      moon_phase = weather_data[:moon_phase]
      fallback_icon = weather_data[:fallback_icon]
      blob = weather_data[:blob]
      days = weather_data[:days]

      snapshot_days = ForecastData.build_next_3days_detailed(blob, cur['now_local'], settings[:snapshot_number_of_days])
      astro_by_date = ForecastData.build_astro_by_date(days)
      moon_by_date = ForecastData.build_moon_by_date(days)

      text = TooltipBuilder.build_waybar_status(
        cond: cur['cond'], temp: cur['temp'], code: cur['code'], is_day: cur['is_day'],
        icon_pos: settings[:icon_position], fallback_icon: fallback_icon
      )

      tooltip = TooltipBuilder.build_week_view_tooltip(
        timezone: cur['timezone'], cond: cur['cond'], temp: cur['temp'], feels: cur['feels'],
        code: cur['code'], is_day: cur['is_day'], fallback_icon: fallback_icon,
        three_hour_rows: snapshot_days,
        sunrise: sunrise, sunset: sunset, moon_phase: moon_phase,
        now_pop: next_hours.empty? ? nil : next_hours[0]['pop'].to_i,
        precip_amt: cur['precip_amt'], astro_by_date: astro_by_date,
        moon_by_date: moon_by_date,
        location_name: cur['location_name'],
        max_astro_days: settings[:daily_number_of_days],
        snapshot_days: settings[:snapshot_number_of_days]
      )

      [text, tooltip]
    end
  end
end

# Parses weather code descriptions
module WeatherCode
  WMO_CODE_DESCRIPTIONS = {
    0 => 'Clear sky',
    1 => 'Mainly clear',
    2 => 'Partly cloudy',
    3 => 'Overcast',
    45 => 'Fog',
    48 => 'Depositing rime fog',
    51 => 'Light drizzle',
    53 => 'Moderate drizzle',
    55 => 'Dense drizzle',
    56 => 'Light freezing drizzle',
    57 => 'Dense freezing drizzle',
    61 => 'Slight rain',
    63 => 'Moderate rain',
    65 => 'Heavy rain',
    66 => 'Light freezing rain',
    67 => 'Heavy freezing rain',
    71 => 'Slight snow fall',
    73 => 'Moderate snow fall',
    75 => 'Heavy snow fall',
    77 => 'Snow grains',
    80 => 'Slight rain showers',
    81 => 'Moderate rain showers',
    82 => 'Violent rain showers',
    85 => 'Slight snow showers',
    86 => 'Heavy snow showers',
    95 => 'Thunderstorm',
    96 => 'Thunderstorm with slight hail',
    99 => 'Thunderstorm with heavy hail'
  }.freeze

  class << self
    def description(code)
      WMO_CODE_DESCRIPTIONS[code.to_i] || 'Unknown'
    end
  end
end

# ─── Main runner ────────────────────────────────────────────────────────────
def main
  if ARGV.empty?
    run_weather_update
  else
    handle_cli_args(ARGV)
  end
end

private def handle_cli_args(args)
  arg = args[0]
  if %w[--next --toggle].include?(arg)
    WeatherMode.cycle
  elsif arg == '--prev'
    WeatherMode.cycle('prev')
  elsif arg == '--set' && args.length > 1
    WeatherMode.set(args[1])
  else
    run_weather_update
  end
end

# Initialize configuration modules
private def initialize_app_config(settings)
  Config.init
  Icons.init(settings[:icon_type])

  Temperature.init(
    unit: Config.unit,
    bias: Temperature::SEASONAL_BIAS,
    month: Time.now.month
  )
end

# Fetch and build all weather data structures
private def fetch_weather_data(lat, lon, settings, location_name)
  blob = ForecastData.fetch_openmeteo_forecast(lat, lon, Config.unit_c?, settings[:daily_number_of_days])
  cur = ForecastData.extract_current(blob, Config.unit, location_name)
  days = ForecastData.build_next_days(blob, settings[:daily_number_of_days])
  next_hours = ForecastData.build_next_hours(blob, cur['now_local'], settings[:hourly_number_of_hours])
  sunrise, sunset = ForecastData.get_sun_times(days, cur['now_local'])
  moon_phase = ForecastData.get_moon_phase_today(days, cur['now_local'])
  fallback_icon = Icons.weather_icon(cur['code'], cur['is_day'] != 0) || ''

  { blob: blob, cur: cur, days: days, next_hours: next_hours, sunrise: sunrise, sunset: sunset,
    moon_phase: moon_phase, fallback_icon: fallback_icon }
end

# Generate text and tooltip based on mode
private def generate_output(mode, weather_data, settings)
  ViewBuilder.build(mode, weather_data, settings)
end

# Recursively converts hash string keys to symbols, handling nested structures
private def symbolize_keys(obj)
  case obj
  when Hash
    obj.transform_keys(&:to_sym).transform_values { |v| symbolize_keys(v) }
  when Array
    obj.map { |item| symbolize_keys(item) }
  else
    obj
  end
end

# Converts cached weather data structure to use symbol keys
# Note: Only symbolize top-level keys; keep nested structures with string keys
# as the existing code expects string keys for accessing nested data
private def symbolize_weather_data(data)
  return data unless data.is_a?(Hash)

  result = data.transform_keys(&:to_sym)

  # Restore Time objects that were serialized as strings
  if result[:cur] && result[:cur]['now_local'].is_a?(String)
    result[:cur]['now_local'] = Time.parse(result[:cur]['now_local'])
  end

  # Restore Time objects in hourly forecast
  if result[:next_hours].is_a?(Array)
    result[:next_hours].each do |hour|
      hour['dt'] = Time.parse(hour['dt']) if hour['dt'].is_a?(String)
    end
  end

  result
end

# Main application logic
private def run_weather_update(force_refresh: false)
  settings = Config.settings
  mode = WeatherMode.get
  initialize_app_config(settings)

  # Check cache freshness and settings match
  refresh_interval = settings[:refresh_interval] || 900
  use_cache = !force_refresh &&
              CacheManager.fresh?(refresh_interval) &&
              CacheManager.settings_match?(settings)

  if use_cache
    # Load from cache
    cache = CacheManager.load_cache
    symbolize_keys(cache['location'])
    weather_data = symbolize_weather_data(cache['weather_data'])
  else
    # Fetch fresh data from API
    location = ForecastData.resolve_location(settings)
    weather_data = fetch_weather_data(
      location[:lat], location[:lon], settings, location[:location_name]
    )
    # Save to cache
    CacheManager.save_cache(
      location: location,
      weather_data: weather_data,
      units: { unit_c: Config.unit_c?, unit: Config.unit, precip_unit: Config.precip_unit,
               time_format: Config.time_format },
      settings: settings
    )
  end

  text, tooltip = generate_output(mode, weather_data, settings)
  classes = [
    'weather',
    mode == WeatherMode::WEEKVIEW ? 'mode-weekview' : 'mode-default',
    weather_data[:next_hours].any? && weather_data[:next_hours][0]['pop'].to_i >= 60 ? 'pop-high' : 'pop-low'
  ]
  out = { text: text, tooltip: tooltip, alt: weather_data[:cur]['cond'], class: classes }
  puts JSON.generate(out)

# --- Error Handling ---
rescue Net::HTTPError, SocketError, Timeout::Error => e
  sleep 2
  puts JSON.generate(text: '…', tooltip: "network error: #{e.message}")
rescue JSON::ParserError, KeyError => e
  puts JSON.generate(text: '', tooltip: "parse error: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
rescue StandardError => e
  puts JSON.generate(text: '!', tooltip: "unexpected error: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
end

main if __FILE__ == $PROGRAM_NAME
