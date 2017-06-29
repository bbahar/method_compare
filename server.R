library(shiny)
library(mcr)
library(shinydashboard)
library(rhandsontable)
library(rmarkdown)

shinyServer(function(input, output, session) {
  
  datasetInput <- reactive({
    if (is.null(input$hot)) {
      mat <- data.frame('X'= round(c(rep(NA, 10)), digits = 2),
                        'Y'= round(c(rep(NA, 10)), digits = 2))
    } else {
      mat <- hot_to_r(input$hot)
    }
  })
  
  output$plot1 <- renderPlot({
    
    a <- datasetInput()
    if (is.null(a)) {
      return(NULL)} else {
        names(a) <- c('M1', 'M2')
        data1 <- try(mcreg(a$M1, a$M2,
                       mref.name = input$m1, mtest.name = input$m2, 
                       na.rm = TRUE), silent = TRUE)
        try(MCResult.plotDifference(data1, plot.type = input$batype,
                                add.grid = TRUE), silent = TRUE)
        
      }
    
  })
  
  output$plot2 <- renderPlot({
    
    a <- datasetInput()
    if (is.null(a)) {
      return(NULL)} else {
        names(a) <- c("M1", "M2")
        data1 <- try(mcreg(a$M1, a$M2, error.ratio = input$syx, 
                       method.reg = input$regmodel, method.ci = input$cimethod,
                       method.bootstrap.ci = input$metbootci, 
                       slope.measure = "radian", na.rm = TRUE), silent = TRUE)
        try(MCResult.plot(data1, ci.area = input$ciarea,
                      add.legend = input$legend, identity = input$identity,
                      add.cor = input$addcor, x.lab = input$m1,
                      y.lab = input$m2, cor.method = input$cormet,
                      equal.axis = TRUE, add.grid = TRUE, 
                      na.rm = TRUE), silent = TRUE)
        
      }
    
  })

  output$plot3 <- renderPlot({
    
    a <- datasetInput()
    if (is.null(a)) {
      return(NULL)} else {
        names(a) <- c("M1", "M2")
        data1 <- try(mcreg(a$M1, a$M2, error.ratio = input$syx, 
                       method.reg = input$regmodel, method.ci = input$cimethod,
                       method.bootstrap.ci = input$metbootci, slope.measure = "radian",
                       mref.name = input$var1, mtest.name = input$var2, 
                       na.rm = TRUE), silent = TRUE)
        try(compareFit(data1), silent = TRUE)
        
      }
    
  })  
  
  
  output$summary <- renderPrint({
    
    a <- datasetInput()
    if (is.null(a)) {
      return(NULL)} else {
        names(a) <- c("M1", "M2")
        data1 <- try(mcreg(a$M1, a$M2, error.ratio = input$syx, 
                       method.reg = input$regmodel, method.ci = input$cimethod,
                       method.bootstrap.ci = input$metbootci, slope.measure = "radian",
                       mref.name = input$m1, mtest.name = input$m2, 
                       na.rm = TRUE), silent = TRUE)
        try(printSummary(data1), silent = TRUE)
      }
    
  })
  
  output$hot <- renderRHandsontable({
    a <- datasetInput()
    rhandsontable(a, height = 482) %>%
      hot_col(col = 'X', format = '0.00', type = 'numeric') %>%
      hot_col(col = 'Y', format = '0.00', type = 'numeric')
    
  })
  
  output$downloadReport <- downloadHandler(
    filename = function() {
      paste(paste(input$m1,'vs.',input$m2, '@', Sys.Date()), sep = '.', switch(
        input$format, PDF = 'pdf', HTML = 'html'
      ))
    },
    content = function(file) {
      
      src <- normalizePath('report.Rmd')
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, 'report.Rmd')
      out <- rmarkdown::render('report.Rmd', switch(
        input$format,
        PDF = pdf_document(), HTML = html_document(), Word = word_document()
      ))
      file.rename(out, file)
      
    }
    
  )
  
})
