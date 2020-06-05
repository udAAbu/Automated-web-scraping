library(taskscheduleR)

myscript <- system.file("extdata", "rvestscrap.R", package = "taskscheduleR")

taskscheduler_create(
  taskname = "r_web_scraping_reddit",
  rscript = myscript,
  schedule = "ONCE"
)

#delete the scheduled task if you want
taskscheduler_delete("r_web_scraping_reddit")
