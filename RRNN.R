library(MASS); library(neuralnet); library(ggplot2)
library(factoextra)

#Función que entrena
Prediccion <- function(TRAIN, TEST){
  DATOS <- rbind(TRAIN, TEST)
  n <- nrow(DATOS)
  
  #Normalizamos los datos
  max <- apply(TRAIN, 2, max)
  min <- apply(TRAIN, 2, min)
  TRAIN_nrm <- as.data.frame(scale(TRAIN, center = min, scale = max - min))
  TEST_nrm <- as.data.frame(scale(TEST, center = min, scale = max - min))
  
  nms  <- names(TRAIN_nrm)
  frml <- as.formula(paste("dda ~", paste(nms[!nms %in% "dda"], collapse = " + ")))
  
  #Modelo
  RRNN <- neuralnet(frml,
                    data          = TRAIN_nrm,
                    hidden = c(5,2),
                    threshold     = 0.01,   # ver Notas para detalle
                    algorithm     = "rprop+",
                    stepmax = 1e+06,
                    rep = 1
  )
  
  #Predicción
  prediction  <- compute(RRNN,within(TEST_nrm,rm(dda)))
  
  # se transoforma el valor escalar al valor nominal original
  value.predict <- prediction$net.result*(max(DATOS$dda)-min(DATOS$dda))+min(DATOS$dda)
  value.real    <- (TEST_nrm$dda)*(max(DATOS$dda)-min(DATOS$dda))+min(DATOS$dda)
  
  #Suma error quadrático
  SEQ <- sum((value.real - value.predict)^2)/nrow(TEST_nrm)
  #Error porcentual absoluto medio
  MAPE <- sum(abs( value.predict -  value.real   )/value.real  )/nrow(TEST_nrm) *100
  
  
  
  SSE = sum((value.predict - value.real)^2)
  SST = sum(value.real^2)
  1-SSE/SST
  
  
  
  #pediction  <- compute(RRNN,within(TRAIN_nrm,rm(dda)))
  #value.predict <- pediction$net.result*(max(DATOS$dda)-min(DATOS$dda))+min(DATOS$dda)
  #value.real    <- (TRAIN_nrm$dda)*(max(DATOS$dda)-min(DATOS$dda))+min(DATOS$dda)
  
  #sum(abs( value.predict -  value.real   )/value.real  )/nrow(TRAIN_nrm) *100
  
  # Gráfica Errores
  #qplot(x=value.real, y=value.predict, geom=c("point","smooth"),  #method="lm", 
  #      main=paste("Real Vs Prediccion. Summa de Error Cuadratico=", round(SEQ,2)))
  # Red
  #plot(RRNN)
  return(c(SEQ, MAPE))
  #return(MAPE)
}


##Cargamos los datos
TEST <- read.csv("./TEST.csv", stringsAsFactors = FALSE) 
TRAIN <- read.csv("./TRAIN.csv", header=TRUE)
TEST$X <- NULL
TRAIN$X <- NULL



#Para evitar la aleatoriedad inicial del modelo, se ejecuta 10 veces para cada conjunto de datos
## y se calcula el promedio
SEQ = rep(0,10) 
MAPE = rep(0,10)
Error <- c(0,0)
for (i in c(1:10)){
  Error <-  Prediccion(TRAIN, TEST)
  SEQ[i] <- Error[1]
  MAPE[i] <- Error[2]
}


SEQ = sort(SEQ)
MAPE = sort(MAPE)
mean(SEQ[3:8])
mean(MAPE[3:8])


ejes <- aes(Mes, Demanda)
cortes <- c("Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct")
gg <- ggplot(TEST, ejes)+ geom_line(aes(TEST$dia, value.predict, colour = "Pronosticada"))+
  geom_line(aes(TEST$dia, value.real, colour = "Real")) + scale_x_continuous(breaks = seq(1,273, 30), labels=cortes ) +
  scale_colour_manual(name=" ", values=c(Real="black", Pronosticada="red"), 
                      guide=guide_legend( legend.position=c(1,1), label.position = "right", nrow=3, byrow=F))+ 
  theme_classic() + ggtitle("Demanda energética real y pronosticada de 2018 usando RRNN")
plot(gg)




