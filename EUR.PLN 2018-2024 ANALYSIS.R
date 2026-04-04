#========================================================
# Analiza kursu EUR/PLN w 3 okresach: bazowy, COVID, wojna
#========================================================

library(ggplot2)
library(boot)
library(tseries)
library(nortest)
install.packages("boot")
library(boot)
library(dplyr)
#----------------------------------------
# FUNKCJE POMOCNICZE
#----------------------------------------
# Logarytmiczne stopy zwrotu w %
get_returns <- function(price) {
  return(log(price[-1] / price[-length(price)])*100)
}

# Bootstrap dla średniej
boot_mean <- function(data, index) {
  return(mean(data[index]))
}

# Bootstrap dla wariancji
boot_var <- function(data, index) {
  return(var(data[index]))
}

#----------------------------------------
# 1. OKRES BAZOWY 2018-2020
#----------------------------------------
EURPLNbaza <- read.csv("C:/licencjat_R/EURPLN 2018-2024 ANALYSIS/data/EURPLNbaza.csv", stringsAsFactors = FALSE)
head(EURPLNbaza)
# Sprawdzenie nazw kolumn
colnames(EURPLNbaza)

# Konwersja kolumny z datą na format Date
EURPLNbaza$DATA <- as.Date(substr(EURPLNbaza$Local.time, 1, 10), format="%d.%m.%Y")

library(ggplot2)

ggplot(EURPLNbaza, aes(x=DATA, y=Close)) +
  geom_line(color="darkblue", size=1) +
  labs(title="Kurs EUR/PLN (2018-2020)", x="Data", y="Kurs") +
  theme_minimal() +
  theme(text=element_text(family="Arial"), axis.text.x=element_text(angle=45,hjust=1))

probBaza <- get_returns(EURPLNbaza$Close)
mean(probBaza)
sd(probBaza, na.rm=TRUE)
var(probBaza)
t.test(probBaza, mu=0)
shapiro.test(probBaza)

# Bootstrap średniej i wariancji
set.seed(123)
bootBaza_mean <- boot(probBaza, boot_mean, R=10000)
bootBaza_var <- boot(probBaza, boot_var, R=10000)
boot.ci(bootBaza_mean, type="perc")
boot.ci(bootBaza_var, type="perc")

#----------------------------------------
# 2. OKRES COVID 2020-2022
#----------------------------------------
EURPLNcovid <- read.csv("C:/licencjat_R/EURPLN 2018-2024 ANALYSIS/data/EURPLNcovid.csv", stringsAsFactors = FALSE)
EURPLNcovid$DATA <- as.Date(substr(EURPLNcovid$Local.time,1,10), format="%d.%m.%Y")

ggplot(EURPLNcovid, aes(x=DATA, y=Close)) +
  geom_line(color="darkblue", size=1) +
  labs(title="Kurs EUR/PLN (2020-2022)", x="Data", y="Kurs") +
  theme_minimal() +
  theme(text=element_text(family="Arial"), axis.text.x=element_text(angle=45,hjust=1))

probCovid <- get_returns(EURPLNcovid$Close)
mean(probCovid)
sd(probCovid, na.rm=TRUE)
var(probCovid)
t.test(probCovid, mu=0)
shapiro.test(probCovid)

set.seed(123)
bootCovid_mean <- boot(probCovid, boot_mean, R=10000)
bootCovid_var <- boot(probCovid, boot_var, R=10000)
boot.ci(bootCovid_mean, type="perc")
boot.ci(bootCovid_var, type="perc")

# Porównanie okresów bazowego i COVID
var.test(probBaza, probCovid)
t.test(probBaza, probCovid, alternative="greater", var.equal=TRUE)

# Bootstrap różnicy średnich
boot_diff_means <- function(data, index){
  idx1 <- sample(seq_along(data[[1]]), replace=TRUE)
  idx2 <- sample(seq_along(data[[2]]), replace=TRUE)
  return(mean(data[[2]][idx2]) - mean(data[[1]][idx1]))
}
data_list <- list(probBaza, probCovid)
set.seed(123)
boot_res_comp <- boot(data_list, boot_diff_means, R=10000)
boot.ci(boot_res_comp, type="perc")

#----------------------------------------
# 3. OKRES WOJNY 2022-2024
#----------------------------------------
EURPLNwojna <- read.csv("C:/licencjat_R/EURPLN 2018-2024 ANALYSIS/data/EURPLNcovid.csv", stringsAsFactors = FALSE)
EURPLNwojna$DATA <- as.Date(substr(EURPLNwojna$Local.time,1,10), format="%d.%m.%Y")

ggplot(EURPLNwojna, aes(x=DATA, y=Close)) +
  geom_line(color="darkblue", size=1) +
  labs(title="Kurs EUR/PLN (2022-2024)", x="Data", y="Kurs") +
  theme_minimal() +
  theme(text=element_text(family="Arial"), axis.text.x=element_text(angle=45,hjust=1))

probWojna <- get_returns(EURPLNwojna$Close)
mean(probWojna)
sd(probWojna, na.rm=TRUE)
var(probWojna)
t.test(probWojna, mu=0)
shapiro.test(probWojna)

set.seed(123)
bootWojna_mean <- boot(probWojna, boot_mean, R=10000)
bootWojna_var <- boot(probWojna, boot_var, R=10000)
boot.ci(bootWojna_mean, type="perc")
boot.ci(bootWojna_var, type="perc")

# Porównanie bazowy vs wojna
var.test(probBaza, probWojna)
t.test(probBaza, probWojna, alternative="greater", var.equal=FALSE)

# Bootstrap różnicy średnich i wariancji
boot_diff_means_wojna <- function(data, index){
  idx1 <- sample(seq_along(data[[1]]), replace=TRUE)
  idx2 <- sample(seq_along(data[[2]]), replace=TRUE)
  return(mean(data[[2]][idx2]) - mean(data[[1]][idx1]))
}
data_list_wojna <- list(probBaza, probWojna)
set.seed(123)
boot_res_wojna <- boot(data_list_wojna, boot_diff_means_wojna, R=10000)
boot.ci(boot_res_wojna, type="perc")
# Dla okresu bazowego

#wykresy
png("EURPLNbaza.png", width=800, height=600)
ggplot(EURPLNbaza, aes(x=DATA, y=Close)) + geom_line(color="blue") +
  labs(title="Kurs EUR/PLN 2018-2020", x="Data", y="Kurs")
dev.off()

# Dla okresu COVID
png("EURPLNcovid.png", width=800, height=600)
ggplot(EURPLNcovid, aes(x=DATA, y=Close)) + geom_line(color="red") +
  labs(title="Kurs EUR/PLN 2020-2022", x="Data", y="Kurs")
dev.off()

# Dla okresu wojny
png("EURPLNwojna.png", width=800, height=600)
ggplot(EURPLNwojna, aes(x=DATA, y=Close)) + geom_line(color="green") +
  labs(title="Kurs EUR/PLN 2022-2024", x="Data", y="Kurs")
dev.off()

#----------------------------------------
# KONIEC ANALIZY
#----------------------------------------