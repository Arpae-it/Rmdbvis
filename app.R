library(shiny)
library(dplyr)
library(DT)
library (RCurl)
library(shinyjs)
library(shinydashboard)
library(googledrive)
library(googleAuthR)
#Here you must provide your googleAuth secrets in order to login to your organization's Gdrive
options("googleAuthR.webapp.client_id" = "XXXX.apps.googleusercontent.com")
options("googleAuthR.webapp.client_secret" = "XXXX")
options("googleAuthR.scopes.selected" = "https://www.googleapis.com/auth/drive")
#Please specify a folder where you'd like to store temporary files
cart_temp <- "/temp/"
get_email <- function() {
  f <-
    gar_api_generator(
      "https://openidconnect.googleapis.com/v1/userinfo",
      "POST",
      data_parse_function = function(x)
        x$email,
      checkTrailingSlash = FALSE
    )
  f()
}

options(shiny.maxRequestSize = 300 * 1024 ^ 2)
# Define UI for data download app ----
httr::set_config(httr::config(ssl_verifypeer = 0L))
ui = dashboardPage(
  dashboardHeader(title = 'Visualizza MDB',
                  tags$li(
                    a(href = 'http://www.arpae.it',
                      icon("power-off"),
                      title = "Torna ad Arpae"),
                    class = "dropdown"
                  )),
  dashboardSidebar(
    width = 300,
    useShinyjs(),
    
    
    htmlOutput("mail"),
    googleAuthUI("loginButton"),
    
    fileInput('file1', '',
              accept = ('text/csv')),
    actionButton("button", "Carica tabella su drive"),
    
    uiOutput("sc_camp")
    
    
    
    
    
  ),
  
  # Main panel for displaying outputs ----
  dashboardBody(fluidRow(box(
    dataTableOutput ("tabelle")
  )))
)


server <- function(input, output, session) {
  shinyjs::hide("button")
  access_token <-
    callModule(googleAuth, "loginButton", login_text = "Accesso @arpae")
  condizione = FALSE
  
  email <- reactive({
    with_shiny(f = get_email,
               shiny_access_token = access_token())
    
  })
  observe({
    validate
    
    
    if (!is.null(access_token())) {
      if (!is.null(input$file1)) {
        show(id = "button")
      }
    }
  })
  
  observeEvent(input$button, {
    t <- access_token()
    drive_auth(token = t, scopes = "https://www.googleapis.com/auth/drive.readonly")
    inFile <- input$file1
    dlist <- mdb.get(inFile$datapath, tables = input$lm)
    write.csv(dlist,
              file = paste0(cart_temp, input$lm, "_", Sys.Date(), ".csv"))
    drive_upload(
      paste0(cart_temp, input$lm, "_", Sys.Date(), ".csv"),
      overwrite = TRUE,
      type = "spreadsheet"
    )
    session$sendCustomMessage(type = 'testmessage',
                              message = 'Thank you for clicking')
    condizione = TRUE
  })
  output$mail <- renderText({
    ciccio = paste("<span style=\"color:red\">Non sei loggato, per favore loggati qui sotto</span>")
    if (!is.null(access_token())) {
      ciccio = "Sei loggato puoi caricare i dati della tabella sul tuo drive"
      if (is.null(input$file1)) {
        ciccio = "Sei loggato ma devi ancora caricare un mdb"
      }
    }
    return(ciccio)
  })
  output$tabelle <- renderDataTable({
    validate(need(input$file1 != "", "Per favore carica un file .mdb"))
    # if (!is.null(input$glink)){
    inFile <- input$file1
    
    d <- mdb.get(inFile$datapath)
    if (!is.null(input$lm)) {
      dlist <- mdb.get(inFile$datapath, tables = input$lm)
    }
    
    
    DT::datatable(
      dlist,
      extensions = 'Buttons',
      
      options = list(
        paging = TRUE,
        searching = TRUE,
        fixedColumns = TRUE,
        autoWidth = TRUE,
        ordering = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv')
      )
    )
  })
  
  output$sc_camp <- renderUI({
    inFile <- input$file1
    
    d <- mdb.get(inFile$datapath)
    dlist <- mdb.get(inFile$datapath, tables = TRUE)
    if (!is.null(dlist)) {
      selectInput("lm",
                  "Scegli la tabella",
                  choices = (dlist),
                  multiple = FALSE)
    }
    
  })
  
}
# Create Shiny app ----
shinyApp(ui, server)
