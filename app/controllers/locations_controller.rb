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
    variables = { current: %i[weather_code temperature_2m rain], daily: %i[weather_code temperature_2m_max temperature_2m_min]}
    data = OpenMeteo::Forecast.new(client:).get(location:, variables:, model: :dwd_icon)

    daily_forecast = data.daily.items

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
    @max_temp_tomorrow2 = tomorrow_2_forecast.temperature_2m_max
    @min_temp_tomorrow2 = tomorrow_2_forecast.temperature_2m_min
    @max_temp_tomorrow3 = tomorrow_3_forecast.temperature_2m_max
    @min_temp_tomorrow3 = tomorrow_3_forecast.temperature_2m_min
    @max_temp_tomorrow4 = tomorrow_4_forecast.temperature_2m_max
    @min_temp_tomorrow4 = tomorrow_4_forecast.temperature_2m_min
    @max_temp_tomorrow5 = tomorrow_5_forecast.temperature_2m_max
    @min_temp_tomorrow5 = tomorrow_5_forecast.temperature_2m_min

    #puts data.current.inspect
    @output = data.current.instance_variable_get(:@item).instance_variable_get(:@raw_json)["temperature_2m"]
    @rain_today = data.current.instance_variable_get(:@item).instance_variable_get(:@raw_json)["rain"]
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
