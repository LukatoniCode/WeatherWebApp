import openmeteo_requests

import requests_cache
import pandas as pd
from retry_requests import retry

import sys

# Setup the Open-Meteo API client with cache and retry on error
cache_session = requests_cache.CachedSession('.cache', expire_after = 3600)
retry_session = retry(cache_session, retries = 10, backoff_factor = 0.2)
openmeteo = openmeteo_requests.Client(session = retry_session)

# Make sure all required weather variables are listed here
# The order of variables in hourly or daily is important to assign them correctly below
url = "https://api.open-meteo.com/v1/forecast"
params = {
	"latitude": sys.argv[1],
	"longitude": sys.argv[2],
	"current": ["temperature_2m", "apparent_temperature"],
	"timezone": "auto",
	"forecast_days": 1,
	"models": "meteofrance_seamless"
}
responses = openmeteo.weather_api(url, params=params)

# Process first location. Add a for-loop for multiple locations or weather models
response = responses[0]
#print(f"Coordinates {response.Latitude()}°N {response.Longitude()}°E")
#print(f"Elevation {response.Elevation()} m asl")
#print(f"Timezone {response.Timezone()} {response.TimezoneAbbreviation()}")
#print(f"Timezone difference to GMT+0 {response.UtcOffsetSeconds()} s")

# Current values. The order of variables needs to be the same as requested.
current = response.Current()
current_temperature_2m = current.Variables(0).Value()
current_apparent_temperature = current.Variables(1).Value()

#print(f"Current time {current.Time()}")
print(int(current_temperature_2m))
#print(int(current_apparent_temperature))

#print(sys.argv[1])

#print(sys.argv[2])

