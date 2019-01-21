library(shiny)
library(mcr)
library(shinydashboard)
library(rhandsontable)
library(rmarkdown)

dashboardPage(
  dashboardHeader(title = "Method Comparison"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Information", tabName = "info", 
               icon = icon("info", "fa-lg")
               ),
      menuItem("Data", tabName = "data", 
               icon = icon("table", "fa-lg")
               ),
      menuItem("Plots", tabName = "plots",
               icon = icon("line-chart", "fa-lg"),
               menuSubItem("Scatter Plot", tabName = "subitem2"),
               menuSubItem("Coefficient Plot", tabName = "subitem3"),
               menuSubItem("Bland-Altman Plot", tabName = "subitem1")
               ),
      menuItem("Statistics", tabName = "stats",
               icon = icon("users", "fa-lg")
               ),
      menuItem("Download", tabName = "download",
               icon = icon("download", "fa-lg")
               )
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "info",
              h2("Method Comparison and Bias Estimation Using R and Shiny"),
              br(),
              h4('This website is a product of R programming language(1) and shiny(2) web application framework. Statistics are based on mcr package(3). Shinydashboard(4), rhandsontable(5) and pander(6) are used for website construction. Rmarkdown(7) is used for converting results into document files.'),
#              br(),
              h4('How to:'),
              h4('1. Copy/paste or manually enter your data using the "Data" tab and 
                 enter method names.'),
              h4('2. See your data distribution and choose statistical tests using the "Plots" tab.'),
              h4('3. See the statistical evaluation of the selected data using the "Statistics" tab and 
                 download using the "Download" tab.'),
              br(),
              h4('References and packages:'),
              h5("1. R: A language and environment for statistical computing. 
                 R Foundation for Statistical Computing, Vienna, Austria.",
                  a('https://www.R-project.org',
                  href = "https://www.R-project.org")),
              h5("2. shiny: Web Application Framework for R.",
                 a("http://CRAN.R-project.org/package=shiny", 
                  href = "http://CRAN.R-project.org/package=shiny")),
              h5("3. mcr: Method Comparison Regression.",
                 a('http://CRAN.R-project.org/package=mcr',
                  href = "http://CRAN.R-project.org/package=mcr")),
              h5("4. shinydashboard: Create Dashboards with 'Shiny'.",
                 a('http://rstudio.github.io/shinydashboard',
                  href = "http://rstudio.github.io/shinydashboard")),
              h5("5. rhandsontable: Interface to the 'Handsontable.js' Library.",
                 a('http://jrowen.github.io/rhandsontable',
                  href = "http://jrowen.github.io/rhandsontable")),
              h5("6. pander: An R Pandoc Writer.",
                 a('http://rapporter.github.io/pander',
                  href = "http://rapporter.github.io/pander")),
              h5("7. rmarkdown: Dynamic Documents for R.",
                 a('http://rmarkdown.rstudio.com',
                 href = "http://rmarkdown.rstudio.com")),
              br(),
              h4('For any questions or concerns please contact:', 
                 a("Burak Bahar, MD", href = "mailto:burakbaharmd@gmail.com"))
              ),
      tabItem(tabName = "data",
              box(title = "Enter Data", status = 'info',
                  rHandsontableOutput("hot")
                  ),
              box(title = 'Enter Method Names', status = 'info',
                  textInput('m1', label = h4('X'),
                            value = 'Reference Method'),
                  textInput('m2', label = h4('Y'),
                            value = 'Test Method')
                  )
      ),
      tabItem(tabName = "subitem1",
              box(title = "Bland-Altman Plot", status = 'info', width = 8,
                  plotOutput("plot1")
                  ),
              box(title = "Options", status='info', width = 4,
                  selectInput('batype', h5('Bland-Altman Plot Type'), 
                              choices=list('0.5*(X+Y) vs. Y-X' = 3,
                                           'X vs. Y-X' = 1,
                                           'rank(X) vs. Y-X' = 5,
                                           '0.5*(X+Y) vs. (Y-X)/X' = 4,                                       
                                           'X vs. (Y-X)/X' = 2,
                                           'rank(X) vs. (Y-X)/X' = 6,
                                           'sqrt(X*Y) vs. Y/X' = 7,
                                           '0.5*(X+Y) vs. (Y-X) / (0.5*(X+Y))' = 8
                                           )
                              )
                  )
      ),
      tabItem(tabName = "subitem2",
              box(title = "Scatter Plot", status='info', width = 8,
                  plotOutput("plot2")
                  ),
              box(title = "Options", status='info', width = 4,
                  selectInput('regmodel', h5('Regression Model'), 
                              choices=list('Ordinary Least Square' = 'LinReg',
                                           'Weighted Ordinary Least Square' = 'WLinReg',
                                           'Deming' = 'Deming',
                                           'Weighted Deming' = 'WDeming',
                                           'Passing-Bablok' = 'PaBa',
                                           'Passing-Bablok Large Dataset' = 'PaBaLarge')
                              ),
                  fixedRow(
                    column(6,
                    selectInput('cimethod', h5('CI Method'), 
                                choices=list('Analytical' = 'analytical',
                                             'Jackknife' = 'jackknife',
                                             'Bootstrap' = 'bootstrap'
                                             )
                                )
                           )
                    ,
                    column(6, selectInput('metbootci',h5('Bootstrap CI Method'),
                                          choices = list('BCa' = 'BCa',
                                                         'Quantile' = 'quantile')
                                          )
                           )
                  ),
                  fixedRow(
                    column(6, selectInput('cormet',h5('Correlation Method'),
                                          choices = list('Pearson' = 'pearson',
                                                         'Spearman' = 'spearman',
                                                         'Kendall' = 'kendall'
                                          )
                    )
                    ),
                    column(6, numericInput('syx', h5('Error Ratio'), value = 1)
                           )
                  ),
                  fixedRow(
                    column(6,  
                           checkboxInput('identity', 'Add identity line', value = TRUE),
                           checkboxInput('ciarea', 'Add CI Area', value = TRUE)
                           ),
                    column(6,
                           checkboxInput('legend', 'Add Legend', value = TRUE),
                           checkboxInput('addcor', 'Add Correlation',value = TRUE)
                           )
                    )
                  )
      ),
      tabItem(tabName = 'subitem3',
            box(title = 'Coefficient Plot', status='info', width = 12, 
            plotOutput('plot3')
              )
            ),
      tabItem(tabName = 'subitem4',
            box(title = '', status = 'info', width = 6,
            plotOutput('plot4')  
              ),
            box(title = '', status = 'info', width = 6,
                plotOutput('plot5')  
            )            
            ),
      tabItem(tabName = "stats",
              box(title = "Statistics", status = 'info', width = 12,
              verbatimTextOutput("summary")
              )
      ),
      tabItem(tabName = "download",
              box(title = "Download Report", status = 'info',
              radioButtons('format', h5('Document format'), 
                           c('PDF', 'HTML'),
                           inline = TRUE),
              downloadButton('downloadReport')
              )
          )
      )
    )
  )
