
# Cargar librerias --------------------------------------------------------
install.packages("pacman")
library(pacman)
p_load(tidyverse,janitor, jsonlite,leaflet,leaflet.extras,sf,Rcpp)


# Carga de datos -------------------------------------------------------
url_ = 'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/'


# a -----------------------------------------------------------------------
## a.i -----------------------------------------------------------------------
### Limpieza de datos -------------------------------------------------------
data <- fromJSON(url_)

ds_raw <- data$ListaEESSPrecio

ds_f <- ds_raw %>% clean_names() %>% 
  type_convert(locale = locale(decimal_mark = (","))) %>% as_tibble()

## a.ii -------------------------------------------------------------------

### Crear columna low cost --------------------------------------------------
ds_f %>% distinct(rotulo) %>% view()
tradicionales <- c('REPSOL', 'CEPSA', 'GALP', 'SHELL', 'BP', 'PETRONOR', 'AVIA', 'Q8', 'CAMPSA', 'BONAREA') 
ds_low_cost <- ds_f %>% mutate(low_cost = !rotulo %in% tradicionales)

## a.iii -------------------------------------------------------------------
### Creacion tablas para mapas ----------------------------------------------
top10_mas_caras <- ds_low_cost %>%
  select(rotulo,precio_gasoleo_a,latitud,longitud_wgs84) %>% 
  arrange(desc(precio_gasoleo_a), rotulo) %>% head(10)

top20_mas_baratas <- ds_low_cost %>% 
  select(rotulo,precio_gasoleo_a,latitud,longitud_wgs84) %>% 
  arrange(precio_gasoleo_a,rotulo) %>% head(20)

### Mapas interactivos top --------------------------------------------------
top10_mas_caras %>% leaflet() %>% addTiles() %>%
  addCircleMarkers(lng = ~longitud_wgs84,lat = ~latitud)

top20_mas_baratas %>% leaflet() %>% addTiles() %>% 
  addCircleMarkers(lng = ~longitud_wgs84,lat = ~latitud)


# b -----------------------------------------------------------------------
## b.i ---------------------------------------------------------------------
### Creación columna municipios sin grandes ciudades ------------------------
ds_grandes_ciudades <- c('Madrid','Barcelona', 'Sevilla', 'Valencia')

ds_gc_municipios <- ds_low_cost %>% 
  mutate(municipios = !municipio %in% ds_grandes_ciudades)


###  Gasolineras por municipios sin grandes ciudades en low cost --------

n_gal_low_cost_municipios <- ds_gc_municipios %>% 
  select(municipios, low_cost) %>% group_by(municipios) %>%  count(low_cost) %>% filter(municipios == TRUE) %>% view()


### stats de precio max, min y promedio sin grandes ciudades -------------------------------------------------------------------
stats_gasoleo_95_premium_municipios <- ds_gc_municipios %>%
  select(municipios,precio_gasolina_95_e5_premium) %>% summary(precio_gasolina_95_e5_premium)

stats_gasolea_a_municipios <-  ds_gc_municipios %>% 
  select(municipios,precio_gasoleo_a) %>% summary(precio_gasoleo_a)


## b.ii --------------------------------------------------------------------
### archivos csv ------------------------------------------------------------
write_excel_csv(ds_gc_municipios, 'informe_no_grandes_ciudades_222c2974')


# c -----------------------------------------------------------------------
## c.i ---------------------------------------------------------------------
### Añadir la columna población al dataset y crear columna municipio --------

pob <- readxl::read_excel('pobmun21.xlsx', skip = 1)

pob_def <- pob %>% select(NOMBRE,POB21) %>% 
  clean_names() %>% rename(municipio=nombre)

ds_w_pob <- inner_join(ds_low_cost,pob_def,by="municipio")


## c. ii -------------------------------------------------------------------
### top10 no 24h ni insulares agrupadas por low cost--------------------------------------------------

ds_idccaa_insulares <- c('04','05','18','19')

ds_peninsulares <- ds_w_pob %>% 
  mutate(idccaa_peninsulares = !idccaa %in% ds_idccaa_insulares) %>% filter(idccaa_peninsulares == 'TRUE') %>% select(municipio,pob21) %>% filter(pob21 > 15000) %>% unique()


### archivos csv ------------------------------------------------------------
write_excel_csv(ds_peninsulares,'informe_peninsulares')


