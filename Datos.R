#Carga de los datos
library(jsonlite); library(xlsx)

#Cargamos datos climatologia aeropuerto de Palma
Clima2015 <- read.xlsx("../Dades/Climatologia/Datos2015.xlsx",sheetIndex = 1)
Clima2016 <- read.xlsx("../Dades/Climatologia/Datos2016.xlsx",sheetIndex = 1)
Clima2016 <- Clima2016[-60,]  #Eliminamos el 29/02/2016 porque este año era bisiesto
Clima2017 <- read.xlsx("../Dades/Climatologia/Datos2017.xlsx",sheetIndex = 1)
Clima2018 <- read.xlsx("../Dades/Climatologia/Datos2018SEP.xlsx",sheetIndex = 1)
#Clima2018 <- Clima2018[-182:-210,]  #Datos de 2018 hasta 30/06

#Cargamos datos consumo electrico
archivoEner <- "../Dades/Electricidad/DemandaEnBalearesMallorca2015.json"
dataEner <- file(archivoEner, open = "r")
dataEner <- readLines(dataEner)
Consumo2015 <- fromJSON(dataEner)

archivoEner <- "../Dades/Electricidad/DemandaEnBalearesMallorca2016.json"
dataEner <- file(archivoEner, open = "r")
dataEner <- readLines(dataEner)
Consumo2016 <- fromJSON(dataEner)
Consumo2016 <- Consumo2016[-60,]  #Eliminamos el 29/02/2016 porque este año era bisiesto

archivoEner <- "../Dades/Electricidad/DemandaEnBalearesMallorca2017.json"
dataEner <- file(archivoEner, open = "r")
dataEner <- readLines(dataEner)
Consumo2017 <- fromJSON(dataEner)

archivoEner <- "../Dades/Electricidad/DemandaEnBalearesMallorca2018SEP.json"
dataEner <- file(archivoEner, open = "r")
dataEner <- readLines(dataEner)
Consumo2018 <- fromJSON(dataEner)


rm(archivoEner, dataEner) #Eliminamos variables que ya no vamos a usar


#Unificamos la nomenclatura de la lista Clima y consumo
Consumo2015$datetime <- Clima2015$fecha
names(Consumo2015)[length(Consumo2015)] <- "fecha"

Consumo2016$datetime <- Clima2016$fecha
names(Consumo2016)[length(Consumo2016)] <- "fecha"

Consumo2017$datetime <- Clima2017$fecha
names(Consumo2017)[length(Consumo2017)] <- "fecha"

Consumo2018$datetime <- Clima2018$fecha
names(Consumo2018)[length(Consumo2018)] <- "fecha"


#Cálculos a partir de los datos disponibles

#Sensación térmica, Temp=temperatura (ºC) V=viento(km/h)
sensacion <- function(Temp, V, H=68){
  if (-50 < Temp && Temp< 10){
    sensacion = 13.1267 + 0.6215*Temp - 11.37*V^(0.16) + 0.3965 * Temp*V^(0.16)
  }else if (Temp>26 && H>40){
    sensacion = -8.78469476+1.61139411*Temp+2.338548839*H-0.14611605*Temp*H-0.012308094*Temp^2-0.016424828*H^2+
      0.002211732*Temp^2*H+0.00072546*Temp*H^2-0.000003582*Temp^2*H^2
  }else{
    sensacion=Temp
  }
  return(sensacion)
}

CalculoSensacion <- function(d){
  sens <- 0
  for (i in c(1:nrow(d))){
    sens[i] <- sensacion(d$tmed[i], d$velmedia[i])
  }
  d <- cbind(d,sens)
  names(d)[length(d)] <- "sensacion"
  return(d)
}

Clima2015 <- CalculoSensacion(Clima2015)
Clima2016 <- CalculoSensacion(Clima2016)
Clima2017 <- CalculoSensacion(Clima2017)
Clima2018 <- CalculoSensacion(Clima2018)

#Calculamos días de la semana
DOW <- function(datos){
  DOW <- rep(0, nrow(datos))
  for (i in c(1:nrow(datos))){
    if (datos$Dia[i] %% 7 ==1){
      DOW[i] <- 7
    }else{
      DOW[i] <- (datos$Dia[i]+6) %% 7
    }
  }
  return(DOW)
}

#Calculamos los días festivos según el año
#http://www.caib.es/sites/calendarilaboral/es/aao_2017/
FEST <- function(year){
  festivo <- rep(0,365)
  festivo[1]=1; festivo[6]=1; festivo[60]=1; festivo[121]=1;festivo[227]=1; 
  festivo[285]=1; festivo[305]=1; festivo[340]=1; festivo[342]=1; festivo[359]=1
  if(year == 2015){
    festivo[92:96]=1;
  }else if(year==2016){
    festivo[83:87]=1;
    festivo[360]=1
  }else if(year==2017){
    festivo[103:107]=1;
  }else if(year==2018){
    festivo[88:92]=1;
    festivo <- festivo[-274:-365]
  }
  return(festivo)
}

#Demanda, temperatura y sensación de los últimos días
Historico <- function(datos, year, diasPrevios){
  tmed <- 0
  value <- 0
  sens <- 0
  #Valores de dia 31, 30, 29, 28, 27, 26, 25 del año anterior (en este orden)
  if (year == 2015){
    temperatura <- c(7.3, 5.9, 7.8, 10.8, 11.1, 8.6, 9.2)
    sensacion <- c(7.26, 5.86, 7.68, 10.8, 11.1, 9.65, 10.7 )
    demanda <- c(13067.80, 13498.65, 13139.10, 11210.61, 11440.15, 10894.86, 10441.93)
  }else if (year==2016){
    temperatura <- c(11.7, 10.8, 12.2, 12.7, 12.7, 12.2, 13)
    sensacion <- c(11.7, 10.8, 12.2, 12.7, 12.7, 12.2, 13)
    demanda <- c(11432.292, 11518.367, 11581.023, 11564.176, 10125.251, 10132.067, 9881.676)
  }else if (year==2017){
    temperatura <- c(9.6, 9.1, 10.6, 12.2, 11.3, 12.5, 11.8)
    sensacion <- c(12.12, 11.29, 10.6, 12.2, 11.3, 12.5, 11.8)
    demanda <- c( 12286.19, 12482.77, 12191.23, 12035.75, 12161.94, 10627.14, 10466.99)
  }else if(year==2018){
    temperatura <- c(12.1, 13.5, 11.3, 14, 14.6, 12.8, 12.8)
    sensacion <- c(12.1, 13.5, 11.3, 14, 14.6, 12.8, 12.8)
    demanda <- c(11700.130, 11452.455, 12573.703, 12590.801, 12526.442, 11385.921, 11007.664)
  }
  for (i in c(1:diasPrevios)){
    tmed[i] <-  temperatura[i]
    sens[i] <- sensacion[i]
    value[i] <- demanda[i]
  }
  for (i in c((diasPrevios+1):nrow(datos))){
    tmed[i] <- datos$tmed[i-diasPrevios]
    sens[i] <- datos$sensacion[i-diasPrevios]
    value[i] <- datos$value[i-diasPrevios]
  }
  return(cbind(tmed, sens, value))
}

#Creamos nuevas variables RRNN"año" con toda la información disponible
RRNN2015 <- data.frame(Clima2015$dia, Clima2015$tmed, Clima2015$tmin, Clima2015$tmax, Clima2015$sensacion, Consumo2015$value)
colnames(RRNN2015) <- c("Dia", "tmed","tmin","tmax", "sensacion", "value")
RRNN2016 <- data.frame(Clima2016$dia, Clima2016$tmed, Clima2016$tmin, Clima2016$tmax, Clima2016$sensacion, Consumo2016$value)
colnames(RRNN2016) <- c("Dia", "tmed","tmin","tmax", "sensacion", "value")
RRNN2017 <- data.frame(Clima2017$dia, Clima2017$tmed, Clima2017$tmin, Clima2017$tmax, Clima2017$sensacion, Consumo2017$value)
colnames(RRNN2017) <- c("Dia", "tmed","tmin","tmax", "sensacion", "value")
RRNN2018 <- data.frame(Clima2018$dia, Clima2018$tmed, Clima2018$tmin, Clima2018$tmax, Clima2018$sensacion, Consumo2018$value)
colnames(RRNN2018) <- c("Dia", "tmed","tmin","tmax", "sensacion", "value")


dia <- c(1:31, 1:28, 1:31, 1:30, 1:31, 1:30, 1:31, 1:31, 1:30, 1:31, 1:30, 1:31)
mes <- c(rep(1,31), rep(2,28), rep(3,31),rep(4,30), rep(5,31), rep(6,30), 
         rep(7,31), rep(8,31),rep(9,30), rep(10,31), rep(11,30), rep(12,31))

RRNN2015 <- cbind(dia, mes, rep(2015, 365), DOW(RRNN2015),FEST(2015), Historico(RRNN2015, 2015, 1),  Historico(RRNN2015, 2015, 2),
                  Historico(RRNN2015, 2015, 3), Historico(RRNN2015, 2015, 4), Historico(RRNN2015, 2015, 5), 
                  Historico(RRNN2015, 2015, 6), Historico(RRNN2015, 2015, 7),   RRNN2015)
RRNN2016 <- cbind(dia, mes, rep(2016, 365), DOW(RRNN2016),FEST(2016), Historico(RRNN2016, 2016, 1),  Historico(RRNN2016, 2016, 2), 
                  Historico(RRNN2016, 2016, 3),Historico(RRNN2016, 2016, 4),  Historico(RRNN2016, 2016, 5), 
                  Historico(RRNN2016, 2016, 6), Historico(RRNN2016, 2016, 7),   RRNN2016)
RRNN2017 <- cbind(dia, mes, rep(2017, 365), DOW(RRNN2017),FEST(2017),  Historico(RRNN2017, 2017, 1),  Historico(RRNN2017, 2017, 2), 
                  Historico(RRNN2017, 2017, 3),Historico(RRNN2017, 2017, 4), Historico(RRNN2017, 2017, 5),
                  Historico(RRNN2017, 2017, 6),  Historico(RRNN2017, 2017, 7), RRNN2017)

dia <- c(1:31, 1:28, 1:31, 1:30, 1:31, 1:30, 1:31, 1:31, 1:30)#, 1:31, 1:30, 1:31)
mes <- c(rep(1,31), rep(2,28), rep(3,31),rep(4,30), rep(5,31), rep(6,30), 
         rep(7,31), rep(8,31),rep(9,30))#, rep(10,31), rep(11,30), rep(12,31))
RRNN2018 <- cbind(dia, mes, rep(2018, 273), DOW(RRNN2018),FEST(2018), Historico(RRNN2018, 2018, 1), Historico(RRNN2018, 2018, 2),
                  Historico(RRNN2018, 2018, 3), Historico(RRNN2018, 2018, 4), Historico(RRNN2018, 2018, 5),
                  Historico(RRNN2018, 2018, 6), Historico(RRNN2018, 2018, 7),    RRNN2018)

#Unificamos nombres de las columnas
colnames(RRNN2015) <- c("DiaMes", "Mes", "año","DOW", "Festivo", "tmed_1", "sens_1", "value_1","tmed_2","sens_2", "value_2", "tmed_3",
                        "sens_3", "value_3", "tmed_4","sens_4","value_4", "tmed_5","sens_5","value_5", "tmed_6","sens_6","value_6", 
                        "tmed_7", "sens_7","value_7", "dia", "tmed", "tmin", "tmax", "sensacion", "dda")
colnames(RRNN2016) <- colnames(RRNN2015)
colnames(RRNN2017) <- colnames(RRNN2015)
colnames(RRNN2018) <- colnames(RRNN2015)

#RRNN(año) son las tablas con toda la información que tenemos disponible
#Dividimos el conjunto en datos de entrenamiento (años 2015-2017) y datos evaluación (año 2018)
TRAIN <- rbind(RRNN2015, RRNN2016, RRNN2017)
TEST <- RRNN2018

#Guardamos las variables para poder cargarlas directamente la próxima vez
#write.csv(TRAIN, file = "TRAIN.csv")
#write.csv(TEST, file = "TEST.csv")
