library(factoextra)
library(ggplot2)

#Análisis componentes principales
TEST <- read.csv("./TEST.csv", stringsAsFactors = FALSE) 
TRAIN <- read.csv("./TRAIN.csv", header=TRUE)
TEST$X <- NULL
TRAIN$X <- NULL

DMDTEST <- TEST[,32]
DMDTRAIN <- TRAIN[,32]

TEST[,32] <- NULL
TRAIN[,32] <- NULL

DATOS <- rbind(TRAIN, TEST)


#Varianza de cada columna
apply(DATOS, 2, var) #2 indica por columnas

#Para perder la gran variabilidad entre las variables, vamos a escalarlas
pca <- prcomp(DATOS, center = TRUE, scale = TRUE)

prop_varianza <- pca$sdev^2 / sum(pca$sdev^2)

prop_varianza_acum <- cumsum(prop_varianza)

ggplot(data = data.frame(prop_varianza_acum, pc = 1:31),
       aes(x = pc, y = prop_varianza_acum, group = 1)) +
  geom_point() + geom_line() + theme_bw() +
  labs(x = "Componente principal",
       y = "Prop. varianza explicada acumulada")

#Gráfica acumulada
ggplot(data = data.frame(prop_varianza_acum, pc = factor(1:31)),
       aes(x = pc, y = prop_varianza_acum, group = 1)) +
  geom_point() +geom_line() +
  geom_label(aes(label = round(prop_varianza_acum,2))) +
  theme_bw() + labs(x = "Componentes principales", 
                    y = "Prop. varianza explicada acumulada")


# Variables que más contribuyen a PC1
fviz_contrib(pca, choice = "var", axes = 1, top = 32, title ="Contribución de la primera componente")


#Elegimos 8 componentes principales para mantener 95% de la información 
pcTra<- matrix(rep(0,1095*8),ncol=8,byrow=T) 
pcTes <- matrix(rep(0,273*8),ncol=8,byrow=T)

for (i in c(1:8)){ pcTra[,i] <- apply(pca$rotation[,i]*TRAIN, 1, sum)
pcTes[,i] <- apply(pca$rotation[,i]*TEST, 1, sum) }

#Añadimos al conjunto de datos las nuevas dimensiones 
TRAIN <- cbind(TRAIN,pcTra) 
TEST <- cbind(TEST, pcTes)

#Quitamos las variables que están correlacionadas 
TRAIN[,1:31] <- NULL
TEST[,1:31] <- NULL

#Añadimos columnas de demanda al final 
TRAIN <- cbind(TRAIN, DMDTRAIN) 
TEST <-cbind(TEST, DMDTEST)

colnames(TRAIN) <- c("pc1", "pc2", "pc3","pc4","pc5","pc6","pc7","pc8","dda")
colnames(TEST) <- c("pc1", "pc2","pc3","pc4","pc5","pc6","pc7","pc8", "dda")
