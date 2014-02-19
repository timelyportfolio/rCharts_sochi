---
title: rCharts Sankeys of 2014 Sochi Olympics Medals
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
jshead:
  - "http://d3js.org/d3.v3.js"
---



<style>
iframe.rChart{
  height: 700px !important;
}

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
  
# rCharts Sankeys of 2014 Sochi Olympics Medals

I love to see [rCharts](http://rcharts.io) in the wild, so [this tweet from @GjTch](https://twitter.com/GjTch/statuses/436015015183663104)

<blockquote class="twitter-tweet" lang="en"><p>Sochi and sankey diagram with <a href="https://twitter.com/search?q=%23rstats&amp;src=hash">#rstats</a> and <a href="https://twitter.com/search?q=%23rCharts&amp;src=hash">#rCharts</a> site: <a href="http://t.co/NMVjcHKD3c">http://t.co/NMVjcHKD3c</a></p>&mdash; Guib. Tch (@GjTch) <a href="https://twitter.com/GjTch/statuses/436015015183663104">February 19, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

inspired me to spend a couple minutes to demonstrate how quickly we can iterate through interactive charts to find what we like best.  With [slidify](http://slidify.org) combined with [rCharts](http://rcharts.io), I can even document as I iterate for a very rapid exploratory workflow.

### Get Data
<small class = "text-muted"><a href="https://gist.github.com/ramnathv/4b810adae24f168d4330">Thanks Ramnath</a></small>


```r
library(XML); library(reshape2); library(plyr)
options(stringsAsFactors = F)
standings = readHTMLTable(
  'http://www.sochi2014.com/en/medal-standings',
  which = 1,
  colClasses = c('character', 'character', rep('numeric', 4)),
)

standings_m = melt(
  subset(standings, Total > 0),
  id = c('Country', 'Rank'),
  variable.name = 'Medal',
  value.name = 'Count'
)
mm <- subset(standings_m,select=c(Country, Medal, Count))
colnames(mm) <- c("target","source","value")
```


### Original Look

When I saw the original, I felt like the Total seemed redundant and a little strange.


```r
library(rCharts)
#first Sankey look
sankeyPlot <- rCharts$new()
#We need to tell R where the Sankey library is.
#and fortunately we can use the Internet
sankeyPlot$setLib('http://timelyportfolio.github.io/rCharts_d3_sankey/')
#since chart.html is in layouts/chart.html rCharts knows where it is
#so we don't have to do this step
#sankeyPlot$setTemplate(script = "rCharts_d3_sankey-gh-pages/layouts/chart.html")
sankeyPlot$set(
  data = mm,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 900,
  height = 600
)
#to make dev branch happy
#if not using newest dev then ignore
sankeyPlot$setTemplate(afterScript = '<script></script')
sankeyPlot
```

<iframe src='
assets/fig/unnamed-chunk-3.html
' scrolling='no' seamless
class='rChart http://timelyportfolio.github.io/rCharts_d3_sankey/ '
id=iframe-
chart21f01ee01ce1
></iframe>
<style>iframe.rChart{ width: 100%; height: 400px;}</style>


### Sankey Look 2

So my first thought was to make the Total a target with Countries as a source.


```r
#factor from reshape even though stringsAsFactors=F
#convert to character
#then make total a target for countries
mm$source <- as.character(mm$source)
mm[which(mm$source=="Total"),][,1:3] <- mm[which(mm$source=="Total"),][,c(2,1,3)]

sankeyPlot$params$data <- mm
sankeyPlot
```

<iframe src='
assets/fig/unnamed-chunk-4.html
' scrolling='no' seamless
class='rChart http://timelyportfolio.github.io/rCharts_d3_sankey/ '
id=iframe-
chart21f01ee01ce1
></iframe>
<style>iframe.rChart{ width: 100%; height: 400px;}</style>


### Sankey Look 3

However, Total seemed odd when all the way to the right for my left-to-right brain.


```r
#for little different look
#change total to be on right
mm2 <- mm
colnames(mm2)[1:2] <- c("source","target")
sankeyPlot$params$data <- mm2
sankeyPlot
```

<iframe src='
assets/fig/unnamed-chunk-5.html
' scrolling='no' seamless
class='rChart http://timelyportfolio.github.io/rCharts_d3_sankey/ '
id=iframe-
chart21f01ee01ce1
></iframe>
<style>iframe.rChart{ width: 100%; height: 400px;}</style>


### Sankey Look 4

I was happy with Look 3 but I just had to try one last look.  In this one, Total is source with Medals target.  Strangely (I have not explored), Silver is 73 while Bronze and Gold are 75.  This does not make sense, but I will leave to someone else to figure it out.


```r
#for another look make total a target for medals
mm3 <- ddply(
  subset(mm2, source != "Total"),
  .(target),
  summarize,
  value = sum(value)
)
mm3$source <- "Total"
mm3 <- rbind(
  subset(mm, target != "Total"),
  mm3
)
#colnames(mm3)[1:2] <- c("source","target")

sankeyPlot$params$data <- mm3
sankeyPlot
```

<iframe src='
assets/fig/unnamed-chunk-6.html
' scrolling='no' seamless
class='rChart http://timelyportfolio.github.io/rCharts_d3_sankey/ '
id=iframe-
chart21f01ee01ce1
></iframe>
<style>iframe.rChart{ width: 100%; height: 400px;}</style>


### Thanks
Thanks [@ramnath_vaidya](http://twitter.com/ramnath_vaidya) and [@GjTch](http://twitter.com/GjTch) and of course Mike Bostock for the d3.

### Poke and Prod
Please poke and prod me at my [Github repo](http://github.com/timelyportfolio/rCharts_sochi).

### Additional rCharts Sankey
For some additional reference on `rCharts` Sankeys, see this [set of posts](http://timelyportfolio.blogspot.com/search/label/sankey).

For lots of Sankeys from lots of sources, see [this site devoted to Sankey diagrams](http://www.sankey-diagrams.com/).
