# Japan Domestic

library(XML)
library(rvest)
library(stringr)

load(file = 'dataJ.Rda')

movie <- c()
id <- c()
date <- c()
link <- c()
image <- c()
rm(dataCurrent)

for (i in 1:303) {
      
      fileUrl <- paste("http://www.javmoo.xyz/cn/released/currentPage/", i, sep = "")
      web <- try(read_html(fileUrl), silent = T)
      if (identical(class(web), "try-error")){
            next()
      }
     
      combo <- try(html_nodes(web, '#waterfall span') %>% html_text())
      movieNew = try(str_trim(str_extract(combo, '.*(?=\\s.*\\w{2,6}-\\d{1,3}\\s\\/)')))
      idNew = try(str_extract(combo, '\\w{2,6}-\\d{1,3}'))
      dateNew = try(str_extract(combo, '\\d{4}-\\d{1,2}-\\d{1,2}'))
      linkNew = try(html_nodes(web, '.movie-box') %>% xml_attr('href'))
      imageNew = try(html_nodes(web, '#waterfall img') %>% xml_attr('src'))
      
      movie = c(movie, movieNew)
      id = c(id, idNew)
      date = c(date, dateNew)
      link = c(link, linkNew)
      image = c(image, imageNew)
      
      if (i %% 20 == 0) {
            Sys.sleep(30)
      }

}

dataCurrent <- data.frame(Movie = movie,
                          ID = id,
                          Date = date,
                          Link = link,
                          Image = image,
                          stringsAsFactors = FALSE)

dataCurrent$Movie = as.character(dataCurrent$Movie)
dataCurrent$ID = as.character(dataCurrent$ID)
dataCurrent$Date = as.Date(as.character(dataCurrent$Date), format = '%Y-%m-%d')
dataCurrent$Link = as.character(dataCurrent$Link)
dataCurrent$Image = as.character(dataCurrent$Image)

dataJ = data.frame(rbind(dataJ, dataCurrent))
dataJ = dataJ[!duplicated(dataJ$ID),]
dataJ = dataJ[order(dataJ[,'Date'], decreasing = T),]
rname = c(1:nrow(dataJ))
rownames(dataJ) = rname

# save data
save(dataJ, file = 'dataJ.Rda')



