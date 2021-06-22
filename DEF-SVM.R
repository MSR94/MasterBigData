library(e1071); library(ggplot2)

#Carga de datos
DTRAIN <- TRAIN
DTEST <- TEST

#Regresión svm
nms  <- names(DTRAIN)
frml <- as.formula(paste("dda ~", paste(nms[!nms %in% "dda"], collapse = " + ")))
model <- svm(frml, DTRAIN)
predictedY <- predict(model, DTEST)


Dias2018 <- seq(as.Date("01/01/2018", format = "%d/%m/%Y"), as.Date("31/12/2018", format = "%d/%m/%Y"), by=1)
cortes <- c("Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct")
z <- c(1:273)
ejes <- aes(Mes, Demanda (MWh))
gg <- ggplot(TEST, ejes) + geom_line(aes(z, DTEST$dda, col="Real")) + geom_line(aes(z, predictedY[1:273], col = "Pronosticada"))+
  scale_x_continuous(breaks = seq(1,273, 30), labels=cortes ) +
  scale_colour_manual(name=" ", values=c(Real="black", Pronosticada="red"), guide=guide_legend( legend.position= "bottom",  label.position = "left", nrow=3, byrow=F))+  
  theme_classic() + ggtitle("Demanda Energética real y pronosticada con el modelo SVM")
plot(gg)



#% d'ERROR MAPE
(sum(abs( predictedY[1:273] -  DTEST$dda)/ DTEST$dda  )/273) *100

#ERROR MSE
sum((predictedY[1:273] -  DTEST$dda)^2)/nrow(DTEST)

#R^2
SSE = sum((predictedY[1:273] - DTEST$dda)^2)
SST = sum(DTEST$dda^2)
1-SSE/SST




#Error train
pedictedY <- predict(model, DTRAIN)
(sum(abs( pedictedY[1:1095] -  DTRAIN$dda)/ DTRAIN$dda  )/1095) *100

SSE = sum((pedictedY[1:1095] - DTRAIN$dda)^2)
SST = sum(DTRAIN$dda^2)
1-SSE/SST

