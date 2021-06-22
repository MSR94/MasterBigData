library(forecast); library(ggplot2)

TRAIN <- read.csv("./TRAIN.csv")
TEST <- read.csv("./TEST.csv")
TEST$X <- NULL
TRAIN$X <- NULL

#Consideramos únicamente la variable que define la demanda
Demand <- TRAIN[,32]
tsdata<-ts(Demand,start=c(1),frequency=365)
modelo<-auto.arima(tsdata)

#Visualizar los parámetros que aproximan la serie temporal
summary(modelo)

#Pronóstico de los próximos 365 días con una confianza del 95%
pronostico<- forecast(modelo,365,level=95)
plot((pronostico), main="Pronóstico de 2018 con el modelo ARIMA")


#Comparar demanda pronosticada con real de 2018
z <- TRAIN[c(1:365),]
DMDReal <- c(TEST$dda, rep(NA,92))
ejes <- aes(DiaAño, Demanda)
gg <- ggplot(z, ejes)+ geom_line(aes(z$dia, pronostico$mean, colour = "Pronosticada"))+
  geom_line(aes(z$dia, DMDReal, colour = "Real")) +
  scale_colour_manual(name=" ", values=c(Real="red", Pronosticada="black"), guide=guide_legend( legend.position=c(1,1),  label.position = "right", nrow=3, byrow=F))+
  theme_classic()+ ggtitle("Pronóstico de 2018")
plot(gg)


#% d'ERROR MAPE
(sum(abs( pronostico$fitted[1:273] -  Consumo2018$value   )/Consumo2018$value  )/273) *100
#8.25% d'error
#ERROR MSE
sum((pronostico$fitted[1:273] - Consumo2018$value)^2)/nrow(Consumo2018)

#R^2
SSE = sum((pronostico$fitted[1:273] - Consumo2018$value)^2)
SST = sum(Consumo2018$value^2)
1-SSE/SST


Dias2018 <- seq(as.Date("01/01/2018", format = "%d/%m/%Y"), as.Date("31/12/2018", format = "%d/%m/%Y"), by=1)
cortes <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct")
z <- TEST
DMDReal <- c(TEST$dda)
ejes <- aes(Month, Demand (MWh))
gg <- ggplot(z, ejes)+  geom_line(aes(z$dia, DMDReal[c(1:273)] , colour = "Real")) +
  geom_line(aes(z$dia, pronostico$mean[c(1:273)], colour = "ARIMA"))+
  scale_x_continuous(breaks = seq(1,273, 30), labels=cortes ) +
  scale_colour_manual(name=" ", values=c(Real="black", ARIMA="red"), guide=guide_legend( legend.position=c(1,1),  label.position = "right", nrow=3, byrow=F))+
  theme_classic()+ ggtitle("Real energetic demand an forecast using ARIMA")
plot(gg)
