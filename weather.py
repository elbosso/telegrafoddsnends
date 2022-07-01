#!/usr/bin/env python3
from influxdb import InfluxDBClient
import requests
import json
import datetime


client = InfluxDBClient(host='192.168.10.2', port=8086)


databases = client.get_list_database()


databaseAlreadyThere =False


for item in databases:
    if item['name'] == '<your db name>':
        databaseAlreadyThere = True


if databaseAlreadyThere == False:
    client.create_database('monitoring')


client.switch_database('monitoring')


headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:10.0) Gecko/20100101 Firefox/10.0'
}

print('https://api.met.no/weatherapi/locationforecast/2.0/.json?lat=50.716944&lon=11.3275')
response = requests.get('https://api.met.no/weatherapi/locationforecast/2.0/.json?lat=50.716944&lon=11.3275', headers=headers)
print(response.content)
data = json.loads(response.content.decode('utf-8'))
timeseries=data['properties']['timeseries']
lon=data['geometry']['coordinates'][0]
lat=data['geometry']['coordinates'][1]
height=str(float(data['geometry']['coordinates'][2])*0.3048)
json_bodies=[]
for timeserie in timeseries:
    stats = {}
    data=timeserie['data']['instant']['details']
    for x in data:
        if isinstance(data[x],dict)==False:
            stats[x] = data[x]
    if 'next_1_hours' in timeserie['data'].keys():
        stats['precipitation_amount']=timeserie['data']['next_1_hours']['details']['precipitation_amount']
    json_body = []
    jb={}
    jb["measurement"]="WeatherForecast"
    tags={}
    tags["Server"]="192.168.10.2"
    tags["Longitude"]=lon
    tags["Latitude"]=lat
    tags["Height"]=height
    tags["Location"]="Rudolstadt"
    jb["tags"]=tags
    jb["time"]=timeserie['time']
    jb["fields"]=stats
    json_body.append(jb)
    client.write_points(json_body)
