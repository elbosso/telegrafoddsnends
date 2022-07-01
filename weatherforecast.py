#!/usr/bin/env python3
from influxdb import InfluxDBClient
import requests
import json
import datetime
import socket

#host of the influxdb used to store the data
influxhost=''
#port of the influxdb used to store the data
influxport=
#username for accessing the influxdb used to store the data
influxusername''
#password for accessing the influxdb used to store the data
influxpassword=''
#name of the influxdb database used to store the data
monitoringdbname=''
#user agent (python requests standard user agent is blocked by the api
useragent='Mozilla/5.0 (X11; Linux x86_64; rv:10.0) Gecko/20100101 Firefox/10.0'
#latitude of the location the forecast is wanted for (german: Breitengrad)
latitude=
#longitude of the location the forecast is wanted for (german: Längengrad)
longitude=
#API url
url='https://api.met.no/weatherapi/locationforecast/2.0/.json?lat={latitude}&lon={longitude}'.format(latitude=latitude,longitude=longitude)
#name of the location the forecast is wanted for (german: Längengrad)
locality=""
#value for the host tag when writing to the influxdb
monitoringhost=socket.getfqdn()
#if you want the ip address rather than the hosts name, do
#monitoringhost=socket.gethostbyname(socket.getfqdn())

client = InfluxDBClient(host=influxhost, port=influxport)
#if influx requires authentication, use the following line instead of the one above:
#client = InfluxDBClient(host=influxhost, port=influxport,username=influxusername, password=influxpasword)

databases = client.get_list_database()


databaseAlreadyThere =False


for item in databases:
    if item['name'] == monitoringdbname:
        databaseAlreadyThere = True


if databaseAlreadyThere == False:
    client.create_database(monitoringdbname)


client.switch_database(monitoringdbname)


headers = {
    'User-Agent': useragent
}

#print(url)
response = requests.get(url, headers=headers)
#print(response.content)
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
    tags["Server"]=monitoringhost
    tags["Longitude"]=lon
    tags["Latitude"]=lat
    tags["Height"]=height
    tags["Location"]=locality
    jb["tags"]=tags
    jb["time"]=timeserie['time']
    jb["fields"]=stats
    json_body.append(jb)
    client.write_points(json_body)




