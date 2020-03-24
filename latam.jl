#Script to generate updates to the latin-american repository

#Some packages to load and work with the CSVs:
using CSV
using DataFrames
#And dates:
using Dates

#The names of the Mexican second level subdivisions:
nombres_estados_noacento = ["Aguascalientes", "Baja California", "Baja California Sur", "Campeche", "Chiapas", "Chihuahua", "Ciudad de Mexico", "Coahuila", "Colima", "Durango", "Guanajuato", "Guerrero", "Hidalgo", "Jalisco", "Michoacan", "Morelos", "Mexico", "Nayarit", "Nuevo Leon", "Oaxaca", "Puebla", "Queretaro", "Quintana Roo", "San Luis Potosi", "Sinaloa", "Sonora", "Tabasco", "Tamaulipas", "Tlaxcala", "Veracruz", "Yucatan", "Zacatecas"]
#Their abreviatures:
abreviaturas_estados = ["AGU", "BCN", "BCS", "CAM", "CHP", "CHH", "CMX", "COA", "COL", "DUR", "GUA", "GRO", "HID", "JAL", "MIC", "MOR", "MEX", "NAY", "NLE", "OAX", "PUE", "QUE", "ROO", "SLP", "SIN", "SON", "TAB", "TAM", "TLA", "VER", "YUC", "ZAC"]

#We load the data for the cases and the location of the states:
datos = CSV.read("Mexico-COVID-19/Mexico_COVID19.csv", header = 1)
coordenadas = CSV.read("COVID_databases_scripts/coordinates.csv", header = 1)
#We define some helpful tags used in the columns of the data for the cases:
column_keys = ["", "_D", "_R"]

#We define a function to update the daily files:
#date = "yyyy-mm-dd"
#update date = "yyyy-mm-ddThh:mm:ss-06:00"
function update_daily_reports(date, update_date)

    #We get some information from the date
    día = date[9:10]
    mes = date[6:7]
    año = date[1:4]

    #We make the date a proper date for Julia to work with:
    fecha = Date(date)

    #We define the location of the file to update:
    archivo = "covid-19_latinoamerica/latam_covid_19_data/latam_covid_19_daily_reports/$(año)-$(mes)-$(día).csv"

    #We use sed to delete the current values in the files:
    run(`sed -i '/Mexico/d' $(archivo)`)

    #We get the data for the day:
    datos_día = filter(row -> row[:Fecha] == fecha, datos)

    #For each state, we get the data, construct a string to put in a specific line in the file with the relevant information.
    #The line is the one that originally was allocated for us:
    for i in 1:32

        abreviatura = abreviaturas_estados[i]
        estado = nombres_estados_noacento[i]

        columnas_datos = Meta.parse.(abreviatura.*column_keys)
        positivos, fallecidos, recuperados = datos_día[columnas_datos] |> Array
        latitud, longitud = coordenadas[coordenadas.Estado .== estado, :][[:LAT_DECIMAL, :LON_DECIMAL]] |> Array

        información = "$(estado),Mexico,$(fecha_actualización),$(positivos),$(fallecidos),$(recuperados),$(latitud),$(longitud)"
        línea = 192 + i
        comando_sed = "sed -i '$(línea)i$(información)' $(archivo)"

        run(`sh -c $(comando_sed)`)
    end

    return "Done"
end

#We define the update date:
fecha_actualización = "2020-03-22T23:30:00-06:00"

#And we update the files:
dates = Date("2020-02-28"):Day(1):Date("2020-03-21")

for date in dates

    update_daily_reports(string(date), fecha_actualización)
end
