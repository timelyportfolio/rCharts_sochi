---
title: rCharts + xCharts of Olympics Medals
author: Timely Portfolio
github: {user: timelyportfolio, repo: rCharts_sochi, branch: "gh-pages"}
framework: bootstrap
mode: selfcontained
highlighter: prettify
hitheme: twitter-bootstrap
assets:
  css:
  - "http://fonts.googleapis.com/css?family=Raleway:300"
  - "http://fonts.googleapis.com/css?family=Oxygen"
---



<style>
body{
  font-family: 'Oxygen', sans-serif;
  font-size: 16px;
  line-height: 24px;
}

h1,h2,h3,h4 {
  font-family: 'Raleway', sans-serif;
}

.container { width: 900px; }

h3 {
  background-color: #D4DAEC;
  text-indent: 100px; 
}

h4 {
  text-indent: 100px;
}
</style>
  
<a href="https://github.com/timelyportfolio/rCharts_sochi"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png" alt="Fork me on GitHub"></a>
  
# rCharts + xCharts of Olympics Medals

I thought it would be nice to combine two very nice resources:
- [Ramnath Vaidyanathan's R + OpenCPU + rCharts Sochi Olympics Analysis]()
- [Christophe Coenraets' Ionic + xCharts Sochi Olympics Dashboard]()


```r
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
#install this rCharts branch with update xCharts
#require(devtools)
#install_github("rCharts","timelyportfolio",ref="xCharts_update")

x1 <- xCharts$new()

x1$layer(
  Total ~ Year,
  groups = "Country",
  data = subset(
    medals.total,
    Country %in% top5
  ),
  type = "line-dotted"
)
x1$set(
  xScale = 'linear',
  yScale = 'linear'
)
x1$set(options=list(
  axisPaddingLeft = 0,
  paddingLeft =  20,
  paddingTop = 40,
  paddingRight =  0,
  axisPaddingRight =  0,
  axisPaddingTop =  5,
  yMin =  0,
  yMax =  40,
  xMin = 1981,
  xMax = 2015,
  interpolation =  "linear"
))
x1$setTemplate (
  afterScript = '
  <script>
  legend = d3.select("#" + params.id).select("svg").append("g")
    .attr("class", "legend")
    .selectAll("g")
    .data(data.main)
    .enter()
    .append("g")
    .attr("transform", function (d, i) {
    return "translate(" + (84 + (i * 120)) + ", 0)";
  });
  
  legend.append("rect")
    .attr("width", 18)
    .attr("height", 18)
    .style("fill", function (d, i) {
      return d3.select(".color" + i + " .line").style("stroke")
  });
  
  legend.append("text")
    .attr("x", 24)
    .attr("y", 9)
    .attr("dy", ".35em")
    .text(function (d, i) {
      return data.main[i].Country;
    });
  </script>
  '
)
x1
```

<iframe src='
assets/fig/unnamed-chunk-2.html
' scrolling='no' seamless
class='rChart xcharts '
id=iframe-
chart1bc86ed69aa
></iframe>
<style>iframe.rChart{ width: 100%; height: 400px;}</style>

