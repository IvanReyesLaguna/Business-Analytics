
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

## a.ii --------------------------------------------------------------------

stats_gasoleo_a <- ds_low_cost %>% select(precio_gasoleo_a) %>% summary(precio_gasoleo_a)
### Analisis recogido en la memoria -------------------------------------------------------
  

## a.iii -------------------------------------------------------------------
### Crear columna low cost --------------------------------------------------
ds_f %>% distinct(rotulo) %>% view()
tradicionales <- c('REPSOL', 'CEPSA', 'GALP', 'SHELL', 'BP', 'PETRONOR', 'AVIA', 'Q8', 'CAMPSA', 'BONAREA') 
ds_low_cost <- ds_f %>% mutate(low_cost = !rotulo %in% tradicionales)


### Comunidades autonomas ---------------------------------------------------
precio_promedio_ccaa <- ds_low_cost %>% select(precio_gasoleo_a,precio_gasolina_95_e5,idccaa,rotulo) %>% group_by(idccaa) %>% 
  summarise(gasoleo_a = mean(precio_gasoleo_a, na.rm = TRUE),  gasolina_95= mean(precio_gasolina_95_e5, na.rm = TRUE),
            gasolina_91= mean(precio_gasolina_95_e5, na.rm = TRUE),gasolina_93= mean(precio_gasolina_95_e5, na.rm = TRUE)) %>%  view()

### Provincias --------------------------------------------------------------
precio_promedio_provincias <- ds_low_cost %>% select(precio_gasoleo_a,precio_gasolina_95_e5,provincia,rotulo) %>% group_by(provincia) %>% 
  summarise(gasoleo_a = mean(precio_gasoleo_a, na.rm = TRUE),  gasolina_95= mean(precio_gasolina_95_e5, na.rm = TRUE),
            gasolina_91= mean(precio_gasolina_95_e5, na.rm = TRUE),gasolina_93= mean(precio_gasolina_95_e5, na.rm = TRUE))


## a.iv -------------------------------------------------------------------
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


## a.v ---------------------------------------------------------------------
### archivos csv ------------------------------------------------------------
write.csv(precio_promedio_ccaa,"low_cost_222c2978_ccaa")
write.csv(precio_promedio_provincias,"low_cost_222c2978_provincias")


# b -----------------------------------------------------------------------
## b.i ---------------------------------------------------------------------
### Madrid ------------------------------------------------------------------
# numero de gasolineras
n_gal_madrid <-  ds_low_cost %>%
  select(idccaa) %>% count(idccaa) %>% filter(idccaa == '13') %>% view()

# numero de low cost y no low cost 
n_lowcost_madrid <- ds_low_cost %>%
  select(idccaa, low_cost)  %>% filter(idccaa == '13') %>%  count(low_cost) %>% view()

# stats de precio max, min y promedio
stats_gasoleo_a_madrid <- ds_low_cost %>%
  select(precio_gasoleo_a, idccaa) %>% filter(idccaa == '13') %>%
  summary(precio_gasoleo_a) %>%  view()

stats_gasoleo_95_premium_madrid <- ds_low_cost %>%
  select(precio_gasolina_95_e5_premium, idccaa) %>% filter(idccaa == '13') %>%
  summary(precio_gasolina_95_e5_premium) %>%  view()

### Barcelona ---------------------------------------------------------------
# numero de gasolineras
n_gal_barcelona <-  ds_low_cost %>% 
  select(idccaa) %>% count(idccaa) %>% filter(idccaa == '09') %>%  view()

# numero de low cost y no low cost 
n_lowcost_barcelona <-  ds_low_cost %>% 
  select(idccaa, low_cost)  %>% filter(idccaa == '09') %>%  count(low_cost) %>% view()

## b.ii --------------------------------------------------------------------
# stats de precio max, min y promedio
stats_gasoleo_a_barcelona <- ds_low_cost %>% 
  select(precio_gasoleo_a, idccaa) %>% filter(idccaa == '09') %>%
  summary(precio_gasoleo_a) %>%  view()

stats_gasoleo_95_premium_barcelona <- ds_low_cost %>% 
  select(precio_gasolina_95_e5_premium, idccaa) %>% filter(idccaa == '09') %>%
  summary(precio_gasolina_95_e5_premium) %>%  view()



# b. iii ------------------------------------------------------------------
### archivos csv ------------------------------------------------------------
write.csv(n_lowcost_madrid,'informe_MAD_BCN_222c2978_13')
write.csv(n_lowcost_barcelona,'informe_MAD_BCN_222c2978_09')



# c -----------------------------------------------------------------------
## c.i ---------------------------------------------------------------------
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


## c.ii --------------------------------------------------------------------
### archivos csv ------------------------------------------------------------
write_excel_csv(ds_gc_municipios, 'informe_no_grandes_ciudades_222c2974')


# d -----------------------------------------------------------------------
## d.i ---------------------------------------------------------------------
### tabla gasolineras 24h sin columna horarios ----------------------------------------------
ds_low_cost %>% count(horario, sort = TRUE) %>% view()
no_24h <- ds_low_cost %>% filter(horario == 'L-D: 24H') %>% select(!horario) %>% view()


## d.ii --------------------------------------------------------------------
### archivos csv ------------------------------------------------------------
write_excel_csv(x = no_24h,'no_24horas')


# e -----------------------------------------------------------------------
## e.i ---------------------------------------------------------------------
### Añadir la columna población al dataset y crear columna municipio --------

pob <- readxl::read_excel('pobmun21.xlsx', skip = 1)

pob_def <- pob %>% select(NOMBRE,POB21) %>% 
  clean_names() %>% rename(municipio=nombre)

ds_w_pob <- inner_join(ds_low_cost,pob_def,by="municipio")


## e.ii --------------------------------------------------------------------
### Competencia en radio de kms ---------------------------------------------


top_ten_alcobendas <- ds_low_cost %>% 
  select(latitud,longitud_wgs84,municipio,low_cost, rotulo) %>% 
  filter(municipio == 'Alcobendas') %>%  view()


mapa_km <- top_ten_alcobendas %>% leaflet() %>% addTiles() %>%
  addCircleMarkers(lng = ~longitud_wgs84,lat = ~latitud, opacity = 1) %>%
  addDrawToolbar(targetGroup = 'km', editOptions = editToolbarOptions(selectedPathOptions = selectedPathOptions())) %>%
  addStyleEditor() %>% addMeasurePathToolbar()


## e.iii -------------------------------------------------------------------
### top10 no 24h ni insulares agrupadas por low cost--------------------------------------------------

ds_idccaa_insulares <- c('04','05')

ds_peninsulares <- ds_low_cost %>% 
  mutate(idccaa_peninsulares = !idccaa %in% ds_idccaa_insulares) %>% filter(idccaa_peninsulares == 'TRUE') %>% 
  filter(horario != 'L-D: 24H') %>% select(low_cost,horario,municipio) %>% view()

top10_municipio_gasolineras_lowcost <- ds_peninsulares %>% 
  group_by(municipio) %>%  count(low_cost) %>% arrange(desc(n)) %>% head(10) %>% view()


### archivos csv ------------------------------------------------------------
write.csv(top10_municipio_gasolineras_lowcost,'informe_top_ten_222c2974')


