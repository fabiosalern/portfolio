setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)

colors = c('Football' = '#F0544F', 'Casual' = '#FFD25A', 'Fishing' = '#7EB2DD')

get_theme <- function(g, colors){
  theme <- g + geom_rect(
    xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf,
    fill = "transparent", color = "black") +
    scale_color_manual(values = colors) +
    theme(panel.grid = element_blank(), panel.background = element_rect(fill = "white"))
  
  return(theme)
}

weekly <- read.csv('data/weekly.csv')
monthly <- read.csv('data/monthly.csv')
quarterly <- read.csv('data/trimestral.csv')

# Data availability
x <- read.csv('data/availability.csv')
colnames(x) <- c('Date', 'Football', 'Casual', 'Fishing')
g <- x %>% gather(Football:Fishing, key='Sector', value='Available days') %>% 
  mutate(Date=as.POSIXct(Date)) %>% 
  ggplot(aes(x=Date, y=`Available days`, color=Sector)) +
  geom_line() + 
  geom_point(aes(shape=Sector), size=3)
  
get_theme(g, colors)

ggsave('Rplots/avail.png', width=900, height=550, dpi=250, unit='px')

# MM90
x <- read.csv('data/mm90.csv')
g <- x %>% gather(Football:Fishing, key='Sector', value='Total') %>% 
  mutate(data=as.POSIXct(data)) %>% 
  ggplot(aes(x=data, y=Total, color=Sector)) +
  geom_line() +
  labs(x='Date', y='Sales')
  #geom_point(aes(shape=Sector), size=3)

get_theme(g, colors)

ggsave('Rplots/mm90.png', width=1100, height=550, dpi=250, unit='px')

# Quarter bars
quarterly$Quarter <- as.factor(quarterly$Quarter)
g <- quarterly %>% group_by(Quarter) %>% 
  summarize(Football = mean(Football), Casual = mean(Casual), Fishing = mean(Fishing)) %>% 
  gather(Football:Fishing, key='Sector', value='Sells') %>% 
  ggplot(aes(x=Quarter, y=Sells, fill=Sector)) +
  geom_bar(stat = 'identity', position = 'dodge') +
  scale_x_discrete() + 
  scale_fill_manual(values = colors)

get_theme(g, colors)

ggsave('Rplots/quarters.png', width=900, height=550, dpi=250, unit='px')

# Seasonal plot
library(lubridate)

# Extract the month number
weekly$Month <- month.abb[month(as.Date(weekly$data))]
weekly$Year <- year(as.Date(weekly$data))

weekly$Month <- factor(weekly$Month, levels=month.abb)


g <- weekly[-dim(weekly)[1], ] %>% gather(Football:Fishing, key='Sector', value='Sells') %>% 
  group_by(Year, Month, Sector) %>% 
  summarise(Sells = sum(Sells)) %>% 
  ggplot(aes(x=Year, y=Sells, color=Sector)) + 
  geom_line() +
  geom_point() +
  facet_wrap(~Month, nrow = 1)
  
get_theme(g, colors)


g <- weekly[-dim(weekly)[1], ] %>% gather(Football:Fishing, key='Sector', value='Sells') %>% 
  group_by(Month, Sector) %>% 
  summarise(Sells = mean(Sells)) %>% 
  ggplot(aes(x=Month, y=Sells, fill=Sector)) + 
  geom_bar(stat = 'identity', position = 'dodge') +
  scale_fill_manual(values=colors)

get_theme(g, colors)

ggsave('Rplots/seasonal.png', width=1300, height=550, dpi=250, unit='px')

# Correlations
library(ggcorrplot)
library(gridExtra)

cor_colors = c('#7EB2DD', '#FFFFFF', '#F0544F')
# Example correlation matrix
wly_cor_matrix <- weekly %>% select(Football:Fishing) %>% cor()
mth_cor_matrix <- monthly %>% select(Football:Fishing) %>% cor()
qtr_cor_matrix <- quarterly %>% select(Football:Fishing) %>% cor()

# Create the correlation matrix plot
cp1 <- ggcorrplot(wly_cor_matrix, lab = TRUE, colors = cor_colors, title = 'Weekly', type='lower') + theme(legend.position = "none")
cp2 <- ggcorrplot(mth_cor_matrix, lab = TRUE, colors = cor_colors, title = 'Monthly', type='lower') + theme(legend.position = "none")
cp3 <- ggcorrplot(qtr_cor_matrix, lab = TRUE, colors = cor_colors, title = 'Quarterly', type='lower') + theme(legend.position = "none")

get_theme(cp2)
ggsave('Rplots/mth_corr.png', width=700, height=700, dpi=250, unit='px')

grid <- grid.arrange(cp1, cp2, cp3, ncol = 3)
ggsave('Rplots/corr1.png', grid, width=1500, height=700, dpi=250, unit='px')


qt1_cor_matrix <- quarterly %>% filter(Quarter == 'Q1') %>% select(Football:Fishing) %>% cor()
qt2_cor_matrix <- quarterly %>% filter(Quarter == 'Q2') %>% select(Football:Fishing) %>% cor()
qt3_cor_matrix <- quarterly %>% filter(Quarter == 'Q3') %>% select(Football:Fishing) %>% cor()
qt4_cor_matrix <- quarterly %>% filter(Quarter == 'Q4') %>% select(Football:Fishing) %>% cor()

# Create the correlation matrix plot
cp1 <- ggcorrplot(qt1_cor_matrix, lab = TRUE, colors = cor_colors, title = 'Q1', type='lower') + theme(legend.position = "none")
cp2 <- ggcorrplot(qt2_cor_matrix, lab = TRUE, colors = cor_colors, title = 'Q2', type='lower') + theme(legend.position = "none")
cp3 <- ggcorrplot(qt3_cor_matrix, lab = TRUE, colors = cor_colors, title = 'Q3', type='lower') + theme(legend.position = "none")
cp4 <- ggcorrplot(qt4_cor_matrix, lab = TRUE, colors = cor_colors, title = 'Q4', type='lower') + theme(legend.position = "none")

grid <- grid.arrange(cp1, cp2, cp3, cp4, ncol = 2)

ggsave('Rplots/corr2.png', grid, width=1200, height=1200, dpi=250, unit='px')


# Seasonal decompositions
library(seasonal)
library(seas)
library(ggfortify)

foot_wly_ts <- ts(weekly$Football, start=c(2016, 1, 3), end=c(2023, 1, 1), frequency=52)
casu_wly_ts <- ts(weekly$Casual, start=c(2016, 1, 3), end=c(2023, 1, 1), frequency=52)
fish_wly_ts <- ts(weekly$Fishing, start=c(2016, 1, 3), end=c(2023, 1, 1), frequency=52)

foot_mth_ts <- ts(monthly$Football, start=c(2016, 1, 31), end=c(2022, 12, 31), frequency=12)
casu_mth_ts <- ts(monthly$Casual, start=c(2016, 1, 31), end=c(2022, 12, 31), frequency=12)
fish_mth_ts <- ts(monthly$Fishing, start=c(2016, 1, 31), end=c(2022, 12, 31), frequency=12)

foot_qtr_ts <- ts(quarterly$Football, start=c(2016, 1, 31), end=c(2022, 12, 31), frequency=4)
casu_qtr_ts <- ts(quarterly$Casual, start=c(2016, 1, 31), end=c(2022, 12, 31), frequency=4)
fish_qtr_ts <- ts(quarterly$Fishing, start=c(2016, 1, 31), end=c(2022, 12, 31), frequency=4)

foot_wly_ts %>% 
  stl(s.window = 'periodic') %>% 
  autoplot()

library(forecast)
g <- foot_mth_ts %>% ggmonthplot() + geom_point(size=1) + labs(y='Sales') 
get_theme(g)
ggsave('Rplots/seas_foot.png', width=1000, height=500, dpi=250, unit='px')

g <- casu_mth_ts %>% ggmonthplot() + geom_point(size=1) + labs(y='Sales') 
get_theme(g)
ggsave('Rplots/seas_casu.png', width=1000, height=500, dpi=250, unit='px')

g <- fish_mth_ts %>% ggmonthplot() + geom_point(size=1) + labs(y='Sales') 
get_theme(g)
ggsave('Rplots/seas_fish.png', width=1000, height=500, dpi=250, unit='px')
  
# Correlograms
library(grid)

plot_acf <- function(acf_, k, title, ylab){
  n <- length(acf_$lag)-1
  g <- autoplot(acf_) +
    theme_bw() +
    scale_x_continuous(
      breaks = acf_$lag,
      labels = ifelse(c(0:n) %% k == 0, 0:n, '')
    ) + labs(title=title, y=ylab)
  return(get_theme(g))
}

acf1 <- acf(diff(foot_wly_ts), lag=120) 
acf2 <- acf(diff(casu_wly_ts), lag=120) 
acf3 <- acf(diff(fish_wly_ts), lag=120)

pacf1 <- pacf(diff(foot_wly_ts), lag=120) 
pacf2 <- pacf(diff(casu_wly_ts), lag=120) 
pacf3 <- pacf(diff(fish_wly_ts), lag=120)

grid <- grid.arrange(plot_acf(acf1, 12, '', 'ACF'), plot_acf(pacf1, 12, '', 'PACF'), ncol=2)
title <- textGrob("Football", gp = gpar(fontsize = 14))
final_grid <- grid.arrange(title, grid, ncol = 1, heights = c(0.1, 0.9))
ggsave('Rplots/foot_wly_correlog.png', final_grid, width=1500, height=700, dpi=250, unit='px')

grid <- grid.arrange(plot_acf(acf2, 12, '', 'ACF'), plot_acf(pacf2, 12, '', 'PACF'), ncol=2)
title <- textGrob("Casual", gp = gpar(fontsize = 14))
final_grid <- grid.arrange(title, grid, ncol = 1, heights = c(0.1, 0.9))
ggsave('Rplots/casu_wly_correlog.png', final_grid, width=1500, height=700, dpi=250, unit='px')

grid <- grid.arrange(plot_acf(acf3, 12, '', 'ACF'), plot_acf(pacf3, 12, '', 'PACF'), ncol=2)
title <- textGrob("Fishing", gp = gpar(fontsize = 14))
final_grid <- grid.arrange(title, grid, ncol = 1, heights = c(0.1, 0.9))
ggsave('Rplots/fish_wly_correlog.png', final_grid, width=1500, height=700, dpi=250, unit='px')


acf4 <- acf(diff(foot_mth_ts), lag=36)
acf5 <- acf(diff(casu_mth_ts), lag=36)
acf6 <- acf(diff(fish_mth_ts), lag=36)

pacf4 <- pacf(diff(foot_mth_ts), lag=36)
pacf5 <- pacf(diff(casu_mth_ts), lag=36)
pacf6 <- pacf(diff(fish_mth_ts), lag=36)

grid <- grid.arrange(plot_acf(acf4, 4, '', 'ACF'), plot_acf(pacf4, 4, '', 'PACF'), ncol=2)
title <- textGrob("Football", gp = gpar(fontsize = 14))
final_grid <- grid.arrange(title, grid, ncol = 1, heights = c(0.1, 0.9))
ggsave('Rplots/foot_mth_correlog.png', final_grid, width=1500, height=700, dpi=250, unit='px')

grid <- grid.arrange(plot_acf(acf5, 4, '', 'ACF'), plot_acf(pacf5, 4, '', 'PACF'), ncol=2)
title <- textGrob("Casual", gp = gpar(fontsize = 14))
final_grid <- grid.arrange(title, grid, ncol = 1, heights = c(0.1, 0.9))
ggsave('Rplots/casu_mth_correlog.png', final_grid, width=1500, height=700, dpi=250, unit='px')

grid <- grid.arrange(plot_acf(acf6, 4, '', 'ACF'), plot_acf(pacf6, 4, '', 'PACF'), ncol=2)
title <- textGrob("Fishing", gp = gpar(fontsize = 14))
final_grid <- grid.arrange(title, grid, ncol = 1, heights = c(0.1, 0.9))
ggsave('Rplots/fish_mth_correlog.png', final_grid, width=1500, height=700, dpi=250, unit='px')

acf7 <- acf(diff(foot_qtr_ts), lag=12)
acf8 <- acf(diff(casu_qtr_ts), lag=12) 
acf9 <- acf(diff(fish_qtr_ts), lag=12) 

pacf7 <- pacf(diff(foot_qtr_ts), lag=12)
pacf8 <- pacf(diff(casu_qtr_ts), lag=12)
pacf9 <- pacf(diff(fish_qtr_ts), lag=12)

grid <- grid.arrange(plot_acf(acf7, 1, '', 'ACF'), plot_acf(pacf7, 1, '', 'PACF'), ncol=2)
title <- textGrob("Football", gp = gpar(fontsize = 14))
final_grid <- grid.arrange(title, grid, ncol = 1, heights = c(0.1, 0.9))
ggsave('Rplots/foot_qtr_correlog.png', final_grid, width=1500, height=700, dpi=250, unit='px')

grid <- grid.arrange(plot_acf(acf8, 1, '', 'ACF'), plot_acf(pacf8, 1, '', 'PACF'), ncol=2)
title <- textGrob("Casual", gp = gpar(fontsize = 14))
final_grid <- grid.arrange(title, grid, ncol = 1, heights = c(0.1, 0.9))
ggsave('Rplots/casu_qtr_correlog.png', final_grid, width=1500, height=700, dpi=250, unit='px')

grid <- grid.arrange(plot_acf(acf9, 1, '', 'ACF'), plot_acf(pacf9, 1, '', 'PACF'), ncol=2)
title <- textGrob("Fishing", gp = gpar(fontsize = 14))
final_grid <- grid.arrange(title, grid, ncol = 1, heights = c(0.1, 0.9))
ggsave('Rplots/fish_qtr_correlog.png', final_grid, width=1500, height=700, dpi=250, unit='px')

# Plot predictions
# SARIMAX
weekly <- read.csv('data/weekly.csv')
monthly <- read.csv('data/monthly.csv')
quarterly <- read.csv('data/quarterly.csv')

foot_mth_pred <- read.csv('data/predictions/SARIMAX/foot_mth.csv')
colnames(foot_mth_pred) <- c('data', 'Sells', 'low_ci', 'upp_ci')
foot_mth_pred['set'] <- 'Forecast'
foot_mth_pred['Sector'] <- 'Football'

casu_mth_pred <- read.csv('data/predictions/SARIMAX/casu_mth.csv')
colnames(casu_mth_pred) <- c('data', 'Sells', 'low_ci', 'upp_ci')
casu_mth_pred['set'] <- 'Forecast'
casu_mth_pred['Sector'] <- 'Casual'

fish_mth_pred <- read.csv('data/predictions/SARIMAX/fish_mth.csv')
colnames(fish_mth_pred) <- c('data', 'Sells', 'low_ci', 'upp_ci')
fish_mth_pred['set'] <- 'Forecast'
fish_mth_pred['Sector'] <- 'Fishing'

x <- monthly %>% gather(Football:Fishing, key='Sector', value='Sells')
#x['line'] <- 'avg'

x['set'] <- 'Real'
x['low_ci'] <- NA
x['upp_ci'] <- NA

x <- rbind(x, foot_mth_pred)
x <- rbind(x, casu_mth_pred)
x <- rbind(x, fish_mth_pred)

fc_colors = c('Real' = '#F0544F', 'Forecast' = '#7EB2DD')

g <- x %>% 
  mutate(data=as.POSIXct(data), Sector=factor(Sector, levels=c('Football', 'Casual', 'Fishing'))) %>%
  filter(data > as.POSIXct("2021-01-01")) %>% 
  ggplot(aes(x=data, y=Sells, color=set)) +
  geom_line() +
  geom_point() +
  geom_ribbon(aes(ymin = low_ci, ymax = upp_ci), fill = "#7EB2DD", alpha = 0.2) +
  facet_wrap(~Sector, ncol=1, scales = 'free_y')

get_theme(g, fc_colors)
ggsave('Rplots/sarimax_mth.png', width=1200, height=1000, dpi=250, unit='px')

# XGBoost
foot_mth_pred <- read.csv('data/predictions/XGBOOST/foot_mth.csv')
colnames(foot_mth_pred) <- c('data', 'Sells')
foot_mth_pred['set'] <- 'Forecast'
foot_mth_pred['Sector'] <- 'Football'

casu_mth_pred <- read.csv('data/predictions/XGBOOST/casu_mth.csv')
colnames(casu_mth_pred) <- c('data', 'Sells')
casu_mth_pred['set'] <- 'Forecast'
casu_mth_pred['Sector'] <- 'Casual'

fish_mth_pred <- read.csv('data/predictions/XGBOOST/fish_mth.csv')
colnames(fish_mth_pred) <- c('data', 'Sells')
fish_mth_pred['set'] <- 'Forecast'
fish_mth_pred['Sector'] <- 'Fishing'

x <- monthly %>% gather(Football:Fishing, key='Sector', value='Sells')

x['set'] <- 'Real'

x <- rbind(x, foot_mth_pred)
x <- rbind(x, casu_mth_pred)
x <- rbind(x, fish_mth_pred)

fc_colors = c('Real' = '#F0544F', 'Forecast' = '#7EB2DD')

g <- x %>% 
  mutate(data=as.POSIXct(data)) %>%
  filter(data > as.POSIXct("2021-01-01")) %>% 
  ggplot(aes(x=data, y=Sells, color=set)) +
  geom_line() +
  geom_point() +
  facet_wrap(~Sector, ncol=1, scales = 'free_y')

get_theme(g, fc_colors)

# LSTM
foot_mth_pred <- read.csv('data/predictions/LSTM/foot_mth.csv')
colnames(foot_mth_pred) <- c('data', 'Sells')
foot_mth_pred['set'] <- 'Forecast'
foot_mth_pred['Sector'] <- 'Football'

casu_mth_pred <- read.csv('data/predictions/LSTM/casu_mth.csv')
colnames(casu_mth_pred) <- c('data', 'Sells')
casu_mth_pred['set'] <- 'Forecast'
casu_mth_pred['Sector'] <- 'Casual'

fish_mth_pred <- read.csv('data/predictions/LSTM/fish_mth.csv')
colnames(fish_mth_pred) <- c('data', 'Sells')
fish_mth_pred['set'] <- 'Forecast'
fish_mth_pred['Sector'] <- 'Fishing'

x <- monthly %>% gather(Football:Fishing, key='Sector', value='Sells')

x['set'] <- 'Real'

x <- rbind(x, foot_mth_pred)
x <- rbind(x, casu_mth_pred)
x <- rbind(x, fish_mth_pred)

fc_colors = c('Real' = '#F0544F', 'Forecast' = '#7EB2DD')

g <- x %>% 
  mutate(data=as.POSIXct(data)) %>%
  filter(data > as.POSIXct("2021-01-01")) %>% 
  ggplot(aes(x=data, y=Sells, color=set)) +
  geom_line() +
  geom_point() +
  facet_wrap(~Sector, ncol=1, scales = 'free_y')

get_theme(g, fc_colors)
