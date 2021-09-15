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
abreviaturas_estados_ISO = ["MX-AGU", "MX-BCN", "MX-BCS", "MX-CAM", "MX-CHP", "MX-CHH", "MX-CMX", "MX-COA", "MX-COL", "MX-DUR", "MX-GUA", "MX-GRO", "MX-HID", "MX-JAL", "MX-MIC", "MX-MOR", "MX-MEX", "MX-NAY", "MX-NLE", "MX-OAX", "MX-PUE", "MX-QUE", "MX-ROO", "MX-SLP", "MX-SIN", "MX-SON", "MX-TAB", "MX-TAM", "MX-TLA", "MX-VER", "MX-YUC", "MX-ZAC"]

#We load the data for the cases and the location of the states:
datos = CSV.read("Mexico-COVID-19/Mexico_COVID19_CTD.csv", header = 1, DataFrame)
#coordenadas = CSV.read("COVID_databases_scripts/coordinates.csv", header = 1)
#We define some helpful tags used in the columns of the data for the cases:
#Recovered cases are no longer reported from March 23 onwards
column_keys = ["", "_D", "_R"]

#We define a function to update the daily files:
function update_daily_reports(;update_date = round(now(UTC), Dates.Second))

    if Time(now()) < Time(19)
        date = today() - Day(1)
    else
        date = today()
    end

    #We define the location of the file to update:
    archivo = "covid-19_latinoamerica/latam_covid_19_data/daily_reports/$(string(date)).csv"

    #We use sed to delete the current values in the files:
    run(`sed -i '/Mexico/d' $(archivo)`)

    #We get the data for the day:
    datos_día = filter(row -> row[:Fecha] == date, datos)

    #For each state, we get the data, construct a string to put in a specific line in the file with the relevant information.
    #The line is the one that originally was allocated for us:
    for i in 1:32

        abreviatura = abreviaturas_estados[i]
        abreviatura_ISO = abreviaturas_estados_ISO[i]
        estado = nombres_estados_noacento[i]

        columnas_datos = Meta.parse.(abreviatura.*column_keys)
        positivos, fallecidos, recuperados = datos_día[!, columnas_datos] |> Array

        información = "$(abreviatura_ISO),Mexico,$(estado),$(update_date),$(positivos),$(fallecidos),$(recuperados)"

        #Issue #59 in the latam repo: missing => blank

        información = replace(información, r"missing" => s"")

        línea = 259 + i
        comando_sed = "sed -i '$(línea)i$(información)' $(archivo)"

        run(`sh -c $(comando_sed)`)
    end

    return "Done"
end

update_daily_reports()
