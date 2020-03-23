#Script to generate updates to the latin-american repository

#Some packages to load and work with the CSVs:
using CSV
using DataFrames

#The names of the Mexican second level subdivisions:
nombres_estados_noacento = ["Aguascalientes", "Baja California", "Baja California Sur", "Campeche", "Chiapas", "Chihuahua", "Ciudad de Mexico", "Coahuila", "Colima", "Durango", "Guanajuato", "Guerrero", "Hidalgo", "Jalisco", "Michoacan", "Morelos", "Mexico", "Nayarit", "Nuevo Leon", "Oaxaca", "Puebla", "Queretaro", "Quintana Roo", "San Luis Potosi", "Sinaloa", "Sonora", "Tabasco", "Tamaulipas", "Tlaxcala", "Veracruz", "Yucatan", "Zacatecas"]
nombres_completos_estados_noacento = uppercase.(["Aguascalientes", "Baja California", "Baja California Sur", "Campeche", "Chiapas", "Chihuahua", "Ciudad de Mexico", "Coahuila de Zaragoza", "Colima", "Durango", "Guanajuato", "Guerrero", "Hidalgo", "Jalisco", "Michoacan de Ocampo", "Morelos", "Mexico", "Nayarit", "Nuevo Leon", "Oaxaca", "Puebla", "Queretaro", "Quintana Roo", "San Luis Potosi", "Sinaloa", "Sonora", "Tabasco", "Tamaulipas", "Tlaxcala", "Veracruz de Ignacio de la Llave", "Yucatan", "Zacatecas"])
#The capitals of the states:
capitales_estados_noacento = uppercase.(["Aguascalientes", "Mexicali", "La Paz", "San Francisco de Campeche", "Tuxtla Gutierrez", "Chihuahua", "Cuauhtemoc", "Saltillo", "Colima", "Victoria de Durango", "Guanajuato", "Chilpancingo de los Bravo", "Pachuca de Soto", "Guadalajara", "Morelia", "Cuernavaca", "Toluca de Lerdo", "Tepic", "Monterrey", "Oaxaca de Juarez", "Heroica Puebla de Zaragoza", "Santiago de Queretaro", "Chetumal", "San Luis Potosi", "Culiacan Rosales", "Hermosillo", "Villahermosa", "Ciudad Victoria", "Tlaxcala de Xicohtencatl", "Xalapa-Enriquez", "Merida", "Zacatecas"])

#We load the data:
datos = CSV.read("COVID_databases_scripts/AGEEML_2020322203623.csv", header = 1)

#We generate a blank dataframe:
datos_estados = DataFrame()

#For each state, we filter the location of the capital and append it to the blank dataframe:
for i in 1:32

	estado = filter(row -> row[:NOM_ENT] == nombres_completos_estados_noacento[i], datos)
	filter!(row -> row[:NOM_LOC] == capitales_estados_noacento[i], estado)
	filter!(row -> row[:CVE_LOC] == 1, estado)
	append!(datos_estados, estado)
end

#We add the camelcase, brief, names:
datos_estados[:Estado] = nombres_estados_noacento

#And we select the columns we're interested in:
datos_ubicación = datos_estados[!, [:Estado, :LAT_DECIMAL, :LON_DECIMAL]]

#We save the results:
CSV.write("COVID_databases_scripts/coordinates.csv", datos_ubicación)
