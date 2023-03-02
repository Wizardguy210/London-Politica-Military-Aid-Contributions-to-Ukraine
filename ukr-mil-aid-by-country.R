library(tidyverse)
library(readxl)
library(rnaturalearth)
library(leaflet)
library(sf)

# loading in data
# These Ukraine aid data were taken from the https://www.ifw-kiel.de/topics/war-against-ukraine/ukraine-support-tracker/
# and these defense budget data was collected at https://wisevoter.com/country-rankings/military-spending-by-country/
ukr.aid.dat <- read_excel("/Users/dwaste/Desktop/London Politica/Military-Aid-Contributions-to-Ukraine/Ukraine_Support_Tracker.xlsx")
mil.dat <- read_excel("/Users/dwaste/Desktop/London Politica/Military-Aid-Contributions-to-Ukraine/mil.spending.data.xlsx")

# recoding country names to mactch
mil.dat <- mil.dat %>%
  mutate(Country = recode(country, 
                          "United States of America" = "United States",
                          "People's Republic of China" = "China"))

joined.dat <- left_join(ukr.aid.dat, mil.dat, by = "Country")

# mutating summary df for visualization
new.dat <- joined.dat %>%
  group_by(Country) %>%
  mutate(mil.aid = `Military.commitments.€.billion`  * 1000000000) %>%
  mutate(aid.over.spend = mil.aid / spending) %>%
  select(c("Country", "aid.over.spend", "mil.aid", "spending", "Total bilateral commitments % GDP"))

# loading in world map
world <- ne_countries(scale = "medium",
                      returnclass = "sf")

# recoding country names
world <- world %>%
  mutate(Country = recode(name, 
                          "Dem. Rep. Korea" = "South Korea",
                          "Czech Rep." = "Czech Republic"))

# creaing shape for ukraine
ukr.sf <- world %>%
  filter(name == "Ukraine")

# joining sf data to military data
fin.dat <- left_join(new.dat, world, by = "Country")

# allowing leaflet to map from grouped_df
fin.dat <- st_as_sf(fin.dat)

# color scale
palAid <- colorNumeric(palette = "Blues", domain = fin.dat$aid.over.spend, 1:10)

# popup form
popup.form <- paste0("<center><b>Military Aid to Ukraine as % of Defense Budget: </b>", round(fin.dat$aid.over.spend * 100, digits = 2),"%")

# creating leaflet
mil.plot <- leaflet(fin.dat) %>%
  setView(23, 35, 3) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(group = "Mil Data", fill = ~aid.over.spend, fillColor = ~palAid(aid.over.spend), weight = 4, 
            opacity = 0, label = ~Country, popup = popup.form) %>%
  addPolygons(data = ukr.sf$geometry, fillColor = "orange", opacity = 0) %>%
  addLegend("bottomleft", title = paste0("<center>Military Aid <br> to Ukraine by % of <br> 2022 National <br> Defense Budget <br>"), pal = palAid, values = ~aid.over.spend, opacity = .7, group = "Mil Dat", na.label = "",)

mil.plot


?addLegend



