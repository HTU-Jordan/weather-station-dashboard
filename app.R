oldw <- getOption("warn")
options(warn = -1)
source("./global.R")
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Define UI for application
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
header <- dashboardHeader(title = tags$img(id = "logo", src="htu-logo.jpg"))


sidebar <- dashboardSidebar(disable = TRUE)
body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),


  fluidPage(
    fluidRow(
      infoBoxOutput("air_temp_box", width = 2),
      infoBoxOutput("rel_humidity_box", width = 2),
      infoBoxOutput("wind_speed_box", width = 3),
      infoBoxOutput("air_d_box", width = 2),
      infoBoxOutput("solar_rad_box", width = 3)),

    br(),
    fluidRow(
      box(width = 12,
          title = "Daily Temperature",
          status = "primary",
          solidHeader = TRUE,
          plotOutput("temperature_plot", height = "150px"))

    ),
    fluidRow(
      box(width = 3,
          height = "661px",
          title = "Description",
          status = "primary",
          solidHeader = TRUE,
          h3("Sources"),
          p("For the code, please visit the following link: ", a("www.github.com/HTU-Jordan/weather-station-dashboard")),
          h3("Daily Temperature"),
          p("The plot on the top shows the lowest, highest and mean (average) temperature of the day."),
          p("The smaller the window, the cloudier the day, as clouds trap infrared energy and prevent sunlight reaching the earth, hence minimizing how much the earth cools and how much it heats."),
          h3("Wind Rose Plot"),
          p("The wind rose plot shows the winds with the highest power and hence containing the highest kinetic energy. The plot is also called a pollution rose, due to how effectively it shows the distribution of pollutants in the air."),
          h3("Air Density and Relative Humidity"),
          p("We discovered an inverse correlation between Air Density and Relative Humidity. Counter-intuitively, we found that generally when the humidity rises, the air density drops, and vice versa. The data was scaled and normalized such that both Air Density and Relative Humidity are between 0 and 1.")),
      box(width = 5,
          title = "Wind Power",
          status = "primary",
          solidHeader = TRUE,
          plotOutput("windrose", height = "600px")),
      box(width = 4,
             title = "Air Density and Relative Humidity",
             status = "primary",
             solidHeader = TRUE,
             plotOutput("density_humidity", height = "600px"))
      ),

    div(class = "footer",
        includeHTML("www//footer.html")
    )
  )
)

ui <- shinyUI(
    dashboardPage(title = "HTU Weather Station Dashboard",
                  skin = "black",
                  header,
                  sidebar,
                  body
    )
)
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Define server logic for application
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
server <- function(input, output, session) {



  # ----------------------------------------------------------------------------
  # Define Reactive Functions
  # ----------------------------------------------------------------------------
  data_now <- reactive({
    invalidateLater(15000, session)
    read.table(file = filepath1, sep=",", skip = 4, quote= "", col.names = cols)
  })

  sql_data <- reactive({
    invalidateLater(15000, session)
    con <- connect_to_db()
    reactive_data <- sqlQuery(con,
                              "select top 15840 * from perMINUTE",
                              stringsAsFactors = FALSE,
                              as.is = c(T, F))
    odbcCloseAll()
    reactive_data_DT <- as.POSIXct(reactive_data$ts, format="%Y-%m-%d %H:%M:%S", tz="EET")
    reactive_data[-2] <- data.frame(sapply(reactive_data[-2], as.numeric))
    reactive_data$ts <- reactive_data_DT
    reactive_data <- reactive_data[order(reactive_data$ts),]
    return(reactive_data)
  })

  sql_data_hour <- reactive({
    invalidateLater(15000, session)
    con <- connect_to_db()
    reactive_data <- sqlQuery(con,
                              "select top 168 * from perHOUR",
                              stringsAsFactors = FALSE,
                              as.is = c(T, F))
    odbcCloseAll()
    reactive_data_DT <- as.POSIXct(reactive_data$ts, format="%Y-%m-%d %H:%M:%S", tz="EET")
    reactive_data[-2] <- data.frame(sapply(reactive_data[-2], as.numeric))
    reactive_data$ts <- reactive_data_DT
    reactive_data <- reactive_data[order(reactive_data$ts),]
    odbcCloseAll()
    return(reactive_data)
  })

  reactive_air_temp <- reactive({
    invalidateLater(10000, session)
    reactive_data <- data_now()
    x1 <- tail(reactive_data$temp, 1)
  })
  reactive_wind_power <- reactive({
    invalidateLater(10000, session)
    x2 <<- round(wind_power_function(reactive_air_density(), data_now()), 2)
  })
  reactive_wind_speed <- reactive({
    invalidateLater(10000, session)
    reactive_data <- data_now()
    x3 <- tail(reactive_data$ws, 1)
  })
  reactive_wind_direction <- reactive({
    invalidateLater(10000, session)
    reactive_data <- data_now()
    x4 <- tail(reactive_data$wd, 1)
  })
  reactive_rel_humidity <- reactive({
    invalidateLater(10000, session)
    reactive_data <- data_now()
    x5 <- tail(reactive_data$rh, 1)
  })
  reactive_solar_rad <- reactive({
    invalidateLater(10000, session)
    reactive_data <- data_now()
    x6 <- tail(reactive_data$srad, 1)
  })

  reactive_air_density <- reactive({
    invalidateLater(10000, session)
    reactive_data <- data_now()
    x7 <<- air_density_function(reactive_data)
  })

  windrose_data <- reactive({
    invalidateLater(10000, session)
    x <- tail(sql_data(), 100)
    y <- NULL
    density <- (air_density_function(x))
    y$wp <- wind_power_function(density, x)
    y$ws <- x$ws
    y$wd <- as.integer(x$wd, 100)
    y <- data.frame(y)
  })

  temperature_data <- reactive({
    invalidateLater(10000, session)
    x <- sql_data()
    y <- NULL
    y$temp <- x$temp
    y$ts <- x$ts
    y <- data.frame(y)
  })
  # ----------------------------------------------------------------------------
  # Define InfoBoxes
  # ----------------------------------------------------------------------------

  output$air_temp_box <- renderInfoBox({
    infoBox("Air Temp", paste(reactive_air_temp(), "\u2103"), icon = icon("thermometer-half"), fill = TRUE, color = "aqua", width = 2)
  })
  output$solar_rad_box <- renderInfoBox({
    infoBox("Solar Radiation", paste(reactive_solar_rad(), "kW/m^2"), icon = icon("sun-o"), fill = TRUE, color = "maroon", width = 2)
  })
  output$wind_power_box <- renderInfoBox({
    infoBox("Wind Power", paste(reactive_wind_power(), "W/m^2"), icon = icon("thermometer-half"), fill = TRUE, color = "yellow", width = 2)
  })
  output$wind_speed_box <- renderInfoBox({
    infoBox("Wind Speed", paste(reactive_wind_speed(), "m/s"), icon = icon("wind"), fill = TRUE, color = "blue", width = 2)
  })
  output$wind_direction_box <- renderInfoBox({
    infoBox("Wind Directon", paste(reactive_wind_direction(), "\u00B0"), icon = icon("list"), fill = TRUE, color = "light-blue", width = 2)
  })
  output$rel_humidity_box <- renderInfoBox({
    infoBox("Humidity", paste(reactive_rel_humidity(), "%"), icon = icon("tint"), fill = TRUE, color = "light-blue", width = 2)
  })
  output$air_d_box <- renderInfoBox({
    infoBox("Air Density",
            paste(reactive_air_density(), "kg/m^3"),
            icon = icon("rho"),
            fill = TRUE,
            color = "navy",
            width = 2)
  })

  # ----------------------------------------------------------------------------
  # Define Plots
  # ----------------------------------------------------------------------------

  z <- c("dodgerblue4", "dodgerblue4", "gray", "firebrick", "firebrick")

  output$windrose <- renderPlot({
    pollutionRose(mydata = windrose_data(), ws = "ws", pollutant = "wp", cols = z, annotate = FALSE)
  })

  output$density_humidity <- renderPlot({
    invalidateLater(10000)
    df <- sql_data_hour()
    subtract_month <- tail(df$ts, 1) %m-% months(1)
    df <- subset(df, ts > subtract_month)
    dh_df <- NULL
    dh_df$ts <- df$ts
    dh_df$density <- norm_data(air_density_function(reactive_data = df))
    dh_df$humidity <- norm_data(df$rh)
    dh_df <- data.frame(dh_df)
    dh_df <- melt(dh_df, id=c("ts"))
    ggplot(dh_df) + geom_line(aes(x=ts, y=value, colour=variable), size = 1.1) +
      geom_point(aes(x = ts, y = value, colour = variable), size = 5, shape = 1) +
      scale_colour_manual(values=c("firebrick", "steelblue")) +
      theme_minimal() +
      theme(legend.position = "bottom", axis.title.x=element_blank())

    })

  output$temperature_plot <- renderPlot({
    invalidateLater(10000)
    # Create daily factor
    df <- sql_data()
    subtract_month <- tail(df$ts, 1) %m-% months(1)
    df <- subset(df, ts > subtract_month)
    df$day <- factor(df$ts)
    t0 <- strptime(df$ts, "%Y-%m-%d %H:%M:%S")
    df$day <- format(t0, "%Y-%m-%d")
    df_agg <- aggregate(df$temp, by = list(df$day), function(x) {
      c(max = max(x), min = min(x)) })

    xdf <- NULL
    xdf$day <- df_agg$Group.1
    xdf$max <- df_agg$x[, 1]
    xdf$min <- df_agg$x[, 2]
    xdf$avg <- (xdf$max + xdf$min) / 2
    xdf <- data.frame(xdf)

    ggplot(xdf, aes(x = day, y = avg, ymin = min, ymax = max)) +
      geom_line(aes(y = max), color = "steelblue", size = 1, group = 1) +
      geom_line(aes(y = min), color = "steelblue", size = 1, group = 1) +
      geom_pointrange(color = "black", size= 0.75) +
      geom_point(aes(y = max), color = "steelblue", size = 3.5) +
      geom_point(aes(y = min), color = "steelblue", size = 3.5) +
      theme_minimal() +
      ylab("Air Temperature") +
      theme(axis.title.x=element_blank())
  })

  # session$onSessionEnded(stopApp)
}

options(warn = oldw)
# ------------------------------------------------------------------------------
# Run Application
# ------------------------------------------------------------------------------
suppressWarnings(shinyApp(ui = ui, server = server))
