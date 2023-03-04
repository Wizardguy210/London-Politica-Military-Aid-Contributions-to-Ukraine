library(rsconnect)

rsconnect::setAccountInfo(name='dwaste', token='A8AB271C70FF169B419D32805FDD416F', 
                          secret='STElusclC9dAh74x08UVRFciunHPywId8bJx4e8a')

rsconnect::deployApp('/Users/dwaste/Desktop/London-Politica/Military-Aid-Contributions-to-Ukraine/Ukr-Mil-Aid-Leaflet-Plot.html')

