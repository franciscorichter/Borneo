library(leaflet)
library(RColorBrewer)
library(DT)
ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                sliderInput("range", "Magnitudes", min(malaysia$AMOUNT_TOTAL), max(malaysia$AMOUNT_TOTAL),
                            value = range(malaysia$AMOUNT_TOTAL), step = 0.1
                ),
                selectInput("location", "Location",
                            c('All',levels(malaysia$LOCATION))
                ),
                selectInput("family", "Family",
                            c('All',levels(malaysia$FAMILY))
                ),
                selectInput("species", "Species",
                            c('All',levels(malaysia$SPECIES))
                ),
                sliderInput("size", "Size of points", 1, 1000,
                            value = 2 , step = 10
                ),
                selectInput("colors", "Color Scheme",
                            rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                ),
                checkboxInput("legend", "Show legend", TRUE)
  ),
  absolutePanel(top = 10, left = 10,
                DT::dataTableOutput('x1')     
  )
  
)

server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    data = malaysia[malaysia$AMOUNT_TOTAL >= input$range[1] & malaysia$AMOUNT_TOTAL <= input$range[2],]
    if (input$family != "All") {
      data = data[data$FAMILY == input$family,]
    }
    if (input$location != "All") {
      data = data[data$LOCATION == input$location,]
    }
    if (input$species != "All") {
      data = data[data$SPECIES == input$species,]
    }
    data

  })
  
  output$x1 <- DT::renderDataTable(DT::datatable({
    data <- filteredData()
    data
  }))
  colorpal <- reactive({
    colorNumeric(input$colors, malaysia$AMOUNT_TOTAL)
  })
  
  output$map <- renderLeaflet({
    # the map
    leaflet(malaysia) %>% addTiles() %>%
      fitBounds(~min(LONGITUDE), ~min(LATITUDE), ~max(LONGITUDE), ~max(LATITUDE))
  })
  
  observe({
    pal <- colorpal()
    
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      addCircles(radius = input$size, weight = input$scale, color = "#777777",
                 fillColor = ~pal(AMOUNT_TOTAL), fillOpacity = 0.7, popup = ~SPECIES
      )
  })
  

  observe({
    proxy <- leafletProxy("map", data = malaysia)
    proxy %>% clearControls()
    if (input$legend) {
      pal <- colorpal()
      proxy %>% addLegend(position = "bottomright",
                          pal = pal, values = ~AMOUNT_TOTAL
      )
    }
  })
}

shinyApp(ui, server)
