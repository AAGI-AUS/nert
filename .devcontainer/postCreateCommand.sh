sudo apt-get -y update
sudo apt-get install -y libudunits2-dev libgdal-dev libgeos-dev libproj-dev qpdf

R -e "pak::pak('moodymudskipper/devtag')"
