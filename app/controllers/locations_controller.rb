class LocationsController < ApplicationController
  before_action :set_location, only: %i[ show edit update destroy ]

  # GET /locations or /locations.json
  def index
    @locations = Location.all
  end

  # GET /locations/1 or /locations/1.json
  def show

    require 'date'
    require "open_meteo"
    require 'time'

    lat = @location.latitude
    lon = @location.longitude
    num = Location.all
    #@weather_temp = `python lib/assets/python/weather_temp.py "#{lat}" "#{lon}" "#{num.count}"`

    #def dayname
    # DAYNAMES[self.wday]
    #end

    #def abbr_dayname
    #  ABBR_DAYNAMES[self.wday]
    #end

    #today = Date.today

    #puts today.dayname
    #puts today.abbr_dayname

    OpenMeteo.configure { |config| config.logger = Logger.new("open_meteo.log") }

    client = OpenMeteo::Client.new

    location = OpenMeteo::Entities::Location.new(latitude: lat.to_d, longitude: lon.to_d)
    variables = { current: %i[weather_code temperature_2m rain snowfall cloud_cover is_day, wind_speed_10m, wind_direction_10m], daily: %i[weather_code temperature_2m_max temperature_2m_min rain_sum snowfall_sum], hourly: %i[temperature_2m rain snowfall cloud_cover visibility]}
    data = OpenMeteo::Forecast.new(client:).get(location:, variables:, model: :dwd_icon)

    currenttime = Time.now
    later = currenttime + (4 * 3600)
    later4 = currenttime + (8 * 3600)
    later8 = currenttime + (12 * 3600)
    later12 = currenttime + (16 * 3600)
    later16 = currenttime + (20 * 3600)
    later20 = currenttime + (24 * 3600)
    # Format the time as desired
    formatted_ctime = later.strftime("%Y-%m-%dT%H:00")
    formatted_l4time = later4.strftime("%Y-%m-%dT%H:00")
    formatted_l8time = later8.strftime("%Y-%m-%dT%H:00")
    formatted_l12time = later12.strftime("%Y-%m-%dT%H:00")
    formatted_l16time = later16.strftime("%Y-%m-%dT%H:00")
    formatted_l20time = later20.strftime("%Y-%m-%dT%H:00")
    @formatted_chtime = later.strftime("%Hh")
    @formatted_cl4htime = later4.strftime("%Hh")
    @formatted_cl8htime = later8.strftime("%Hh")
    @formatted_cl12htime = later12.strftime("%Hh")
    @formatted_cl16htime = later16.strftime("%Hh")
    @formatted_cl20htime = later20.strftime("%Hh")

    now = formatted_ctime

    hourly_forecast = data.hourly.items

    currenttime_forecast = hourly_forecast.find { |item| (item.time.to_time - now.to_time).abs < 60 }
    @currenttemp = currenttime_forecast.temperature_2m
    time_forecast4 = hourly_forecast.find { |item| item.time == formatted_l4time }
    @later4temp = time_forecast4.temperature_2m
    time_forecast8 = hourly_forecast.find { |item| item.time == formatted_l8time }
    @later8temp = time_forecast8.temperature_2m
    time_forecast12 = hourly_forecast.find { |item| item.time == formatted_l12time }
    @later12temp = time_forecast12.temperature_2m
    time_forecast16 = hourly_forecast.find { |item| item.time == formatted_l16time }
    @later16temp = time_forecast16.temperature_2m
    time_forecast20 = hourly_forecast.find { |item| item.time == formatted_l20time }
    @later20temp = time_forecast20.temperature_2m

    daily_forecast = data.daily.items

    today_date = (Date.today).iso8601
    today_forecast = daily_forecast.find { |item| item.time == today_date }
    tomorrow_date = (Date.today + 1).iso8601
    tomorrow_forecast = daily_forecast.find { |item| item.time == tomorrow_date }
    tomorrow_2_date = (Date.today + 2).iso8601
    @tomorrow_2_name = (Date.today + 2).strftime('%a')
    tomorrow_2_forecast = daily_forecast.find { |item| item.time == tomorrow_2_date }
    @tomorrow_3_name = (Date.today + 3).strftime('%a')
    tomorrow_3_date = (Date.today + 3).iso8601
    tomorrow_3_forecast = daily_forecast.find { |item| item.time == tomorrow_3_date }
    @tomorrow_4_name = (Date.today + 4).strftime('%a')
    tomorrow_4_date = (Date.today + 4).iso8601
    tomorrow_4_forecast = daily_forecast.find { |item| item.time == tomorrow_4_date }
    tomorrow_5_date = (Date.today + 5).iso8601
    tomorrow_5_forecast = daily_forecast.find { |item| item.time == tomorrow_5_date }

    # Get the maximum temperature for tomorrow
    @max_temp_tomorrow = tomorrow_forecast.temperature_2m_max
    @min_temp_tomorrow = tomorrow_forecast.temperature_2m_min
    @rain_tomorrow = tomorrow_forecast.rain_sum.to_i
    @snow_tomorrow = tomorrow_forecast.snowfall_sum
    @max_temp_tomorrow2 = tomorrow_2_forecast.temperature_2m_max
    @min_temp_tomorrow2 = tomorrow_2_forecast.temperature_2m_min
    @snow_tomorrow2 = tomorrow_2_forecast.snowfall_sum
    @rain_tomorrow2 = tomorrow_2_forecast.rain_sum.to_i
    @max_temp_tomorrow3 = tomorrow_3_forecast.temperature_2m_max
    @min_temp_tomorrow3 = tomorrow_3_forecast.temperature_2m_min
    @snow_tomorrow3 = tomorrow_3_forecast.snowfall_sum
    @rain_tomorrow3 = tomorrow_3_forecast.rain_sum.to_i
    @max_temp_tomorrow4 = tomorrow_4_forecast.temperature_2m_max
    @min_temp_tomorrow4 = tomorrow_4_forecast.temperature_2m_min
    @snow_tomorrow4 = tomorrow_4_forecast.snowfall_sum
    @rain_tomorrow4 = tomorrow_4_forecast.rain_sum.to_i
    @max_temp_tomorrow5 = tomorrow_5_forecast.temperature_2m_max
    @min_temp_tomorrow5 = tomorrow_5_forecast.temperature_2m_min

    @is_day = data.current.instance_variable_get(:@item).instance_variable_get(:@raw_json)["is_day"]
    @cloud_today = data.current.instance_variable_get(:@item).instance_variable_get(:@raw_json)["cloud_cover"]
    @snow_today = data.current.instance_variable_get(:@item).instance_variable_get(:@raw_json)["snowfall"]
    @output = data.current.instance_variable_get(:@item).instance_variable_get(:@raw_json)["temperature_2m"]
    @wind_speed = data.current.instance_variable_get(:@item).instance_variable_get(:@raw_json)["wind_speed_10m"]
    @wind_dir = data.current.instance_variable_get(:@item).instance_variable_get(:@raw_json)["wind_direction_10m"]
    #@rain_today_s = data.daily.instance_variable_get(:@item).instance_variable_get(:@raw_json)["rain_sum"]
    @rain_today_s = today_forecast.rain_sum
    #rain_today_tets = today_forecast.rain_sum
    #puts currenttime
    #@rain_today = rain_today_s.to_i
    #puts data.daily.inspect
    #puts data.hourly
    #puts ""
    #puts data.hourly&.items&.first(5)&.map(&:raw_json)
    #puts ""
    #puts "Weather code symbol: :#{data.hourly&.items&.first&.weather_code_symbol}"



  end

  # GET /locations/new
  def new
    @location = Location.new
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations or /locations.json
  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to location_url(@location), notice: "Location was successfully created." }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to location_url(@location), notice: "Location was successfully updated." }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1 or /locations/1.json
  def destroy


    @location.destroy!

    respond_to do |format|
      format.html { redirect_to locations_url, notice: "Location was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def location_params
      params.require(:location).permit(:address, :latitude, :longitude)
    end
end
