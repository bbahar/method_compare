library(shiny)
library(mcr)
library(shinydashboard)
library(rhandsontable)
library(rmarkdown)

shinyServer(function(input, output, session) {
  
  datasetInput <- reactive({
    if (is.null(input$hot)) {
      mat <- data.frame(Method1=abs(rnorm(10,1,10)), 
                        Method2=abs(rnorm(10,1,10)))
    } else {
      mat <- hot_to_r(input$hot)
    }
  })
  
  output$plot1 <- renderPlot({
    
    a <- datasetInput()
    if (is.null(a)) {
      return(NULL)} else {
        names(a) <- c('M1', 'M2')
        data1 <- mcreg(a$M1,a$M2,
                       mref.name=input$m1, mtest.name=input$m2)
        MCResult.plotDifference(data1, plot.type=input$batype,
                                add.grid = TRUE)
        
      }
    
  })
  
  output$plot2 <- renderPlot({
    
    a <- datasetInput()
    if (is.null(a)) {
      return(NULL)} else {
        names(a) <- c("M1", "M2")
        data1 <- mcreg(a$M1,a$M2, error.ratio = input$syx, 
                       method.reg = input$regmodel, method.ci = input$cimethod,
                       method.bootstrap.ci = input$metbootci)
        MCResult.plot(data1, ci.area=input$ciarea,
                      add.legend=input$legend, identity=input$identity,
                      add.cor=input$addcor, x.lab=input$m1,
                      y.lab=input$m2, cor.method=input$cormet,
                      equal.axis = TRUE, add.grid = TRUE)
        
      }
    
  })
  
  output$summary <- renderPrint({
    
    a <- datasetInput()
    if (is.null(a)) {
      return(NULL)} else {
        names(a) <- c("M1", "M2")
        data1 <- mcreg(a$M1,a$M2, error.ratio = input$syx, 
                       method.reg = input$regmodel, method.ci = input$cimethod,
                       method.bootstrap.ci = input$metbootci,
                       mref.name = input$m1, mtest.name = input$m2)
        printSummary(data1)
      }
    
  })
  
  output$hot <- renderRHandsontable({
    a <- datasetInput()
    rhandsontable(a)
    
  })
  
  output$downloadReport <- downloadHandler(
    filename = function() {
      paste('my-report', sep = '.', switch(
        input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
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