
 Rmdbvis is a Shiny script written in R which allows the user to upload a MS Access db to the organization's server and allows the user to choose one table from the db, 
      viewing it online and exporting it to a .csv file or directly to memory. With a simple customisation, it allows the user to directly write the table to a personal Gdrive.
      In such a case some lines of code must be edited along with the Google secrets to access the organization's Drive. Just substitute the XXXX with your secrets in the following lines of code:
      
>options("googleAuthR.webapp.client_id" = "XXXXX.apps.googleusercontent.com")
>
>options("googleAuthR.webapp.client_secret" = "XXXX")
>
>options("googleAuthR.scopes.selected" = "https://www.googleapis.com/auth/drive")
>
>#Please specify a folder where you'd like to store temporary files
>
>cart_temp <- "/XXX/"
