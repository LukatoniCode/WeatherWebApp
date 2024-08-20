import openmeteo_requests

import requests_cache
import pandas as pd
from retry_requests import retry

# Setup the Open-Meteo API client with cache and retry on error
cache_session = requests_cache.CachedSession('.cache', expire_after = 3600)
retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
openmeteo = openmeteo_requests.Client(session = retry_session)

# Make sure all required weather variables are listed here
# The order of variables in hourly or daily is important to assign them correctly below
url = "https://api.open-meteo.com/v1/forecast"
params = {
	"latitude": 45.8144,
	"longitude": 15.978,
	"current": ["temperature_2m", "relative_humidity_2m", "apparent_temperature", "is_day", "rain", "snowfall", "cloud_cover", "wind_speed_10m", "wind_direction_10m"],
	"hourly": "temperature_2m",
	"timezone": "Europe/Berlin"
}
responses = openmeteo.weather_api(url, params=params)

# Process first location. Add a for-loop for multiple locations or weather models
response = responses[0]
print(f"Coordinates {response.Latitude()}°N {response.Longitude()}°E\n")
print(f"Elevation {response.Elevation()} m asl")
print(f"Timezone {response.Timezone()} {response.TimezoneAbbreviation()}\n")
print(f"Timezone difference to GMT+0 {response.UtcOffsetSeconds()} s\n")

# Current values. The order of variables needs to be the same as requested.
current = response.Current()
current_temperature_2m = current.Variables(0).Value()
current_relative_humidity_2m = current.Variables(1).Value()
current_apparent_temperature = current.Variables(2).Value()
current_is_day = current.Variables(3).Value()
current_rain = current.Variables(4).Value()
current_snowfall = current.Variables(5).Value()
current_cloud_cover = current.Variables(6).Value()
current_wind_speed_10m = current.Variables(7).Value()
current_wind_direction_10m = current.Variables(8).Value()

print(f"Current time {current.Time()} \n")
print(f"Current temperature_2m {current_temperature_2m}\n")
print(f"Current relative_humidity_2m {current_relative_humidity_2m}\n")
print(f"Current apparent_temperature {current_apparent_temperature}\n")
print(f"Current is_day {current_is_day}\n")
print(f"Current rain {current_rain}\n")
print(f"Current snowfall {current_snowfall}\n")
print(f"Current cloud_cover {current_cloud_cover}\n")
print(f"Current wind_speed_10m {current_wind_speed_10m}\n")
print(f"Current wind_direction_10m {current_wind_direction_10m}\n")

# Process hourly data. The order of variables needs to be the same as requested.
#hourly = response.Hourly()
#hourly_temperature_2m = hourly.Variables(0).ValuesAsNumpy()

#hourly_data = {"date": pd.date_range(
#	start = pd.to_datetime(hourly.Time(), unit = "s", utc = True),
#	end = pd.to_datetime(hourly.TimeEnd(), unit = "s", utc = True),
#	freq = pd.Timedelta(seconds = hourly.Interval()),
#	inclusive = "left"
#)}
#hourly_data["temperature_2m"] = hourly_temperature_2m

#hourly_dataframe = pd.DataFrame(data = hourly_data)
#print(hourly_dataframe)


