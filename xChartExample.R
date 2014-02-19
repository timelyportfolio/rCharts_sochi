#combine two very nice resources
#Ramnath Vaidyanathan's R + OpenCPU + rCharts Sochi Olympics Analysis
#Christophe Coenraets' Ionic + xCharts Sochi Olympics Dashboard

library(XML)
library(reshape2)
library(plyr)
#source directly the code from Ramnath's data gatherer
source('https://raw2.github.com/ramnathv/sochi/master/R/sochi.R')

medals <- do.call(
  rbind,
  lapply(
    c("2014", "2010", "2006", "2002", "1994", "1992", "1988", "1984"),
    function(year) {
      medals_year <- getMedalCounts(year = year)
      medals_year$Year <- year
      return(medals_year)
    }
  )
)

medals$Medal <- as.character(medals$Medal)
medals$Year <- as.numeric(medals$Year)

medals.total <- ddply(
  medals,
  .(Year,Country),
  summarize,
  Total = sum(Count)
)



top5 <- subset(
  medals.total,Year==2010
)[order(
    subset(medals.total,Year==2010)$Total,
    decreasing = TRUE
  ),][1:5,"Country"]


#xCharts in rCharts dev is out of date
#for this to work
#need to setLib here for newest
x1$setLib(
  "http://timelyportfolio.github.io/rCharts_sochi/libraries/widgets/xCharts/"
)
#or the more aggressive
#require(devtools)
#install_github("rCharts","timelyportfolio",ref="xCharts_update")

x1 <- xCharts$new()
x1$layer(
  Total ~ Year,
  group = "Country",
  data = subset(
    medals.total,
    Country %in% top5
  ) 
)
x1$set(options=list(
  xScale = 'linear',
  yScale = 'linear',
  type = 'line-dotted',
  axisPaddingLeft = 0,
  paddingLeft =  20,
  paddingRight =  0,
  axisPaddingRight =  0,
  axisPaddingTop =  5,
  yMin =  0,
  yMax =  40,
  interpolation =  "linear"
))
x1$setTemplate (
  afterScript = '
  <script>
  legend = d3.select("#" + data.dom).append("svg")
    .attr("class", "legend")
    .selectAll("g")
    .data(data.main)
    .enter()
    .append("g")
    .attr("transform", function (d, i) {
    return "translate(" + (64 + (i * 84)) + ", 0)";
  });
  
  legend.append("rect")
    .attr("width", 18)
    .attr("height", 18)
    .attr("class", function (d, i) {
    return "color" + i;
  });
  
  legend.append("text")
    .attr("x", 24)
    .attr("y", 9)
    .attr("dy", ".35em")
    .text(function (d, i) {
      return data.main[i].country;
    });
  </script>
  '
)
x1
