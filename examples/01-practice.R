# Practice with pins on your own laptop: the same steps as Step 4 of the tutorial.
# Run it part by part with Ctrl+Enter. Nothing here touches shared storage.

library(pins)

# ---- Part A: versions of a data frame -------------------------------------

# 1. The practice board, and a helper that shows the history with titles
board <- board_folder("C:/pins-practice", versioned = TRUE)

history <- function(name) {
  v <- pin_versions(board, name)
  v$title <- vapply(v$version, function(id) {
    title <- pin_meta(board, name, version = id)$title
    if (is.null(title)) "" else title
  }, character(1))
  v[order(v$created, decreasing = TRUE), c("version", "created", "title")]
}

# 2. Save a first version
portfolio <- data.frame(
  company    = c("Alpine Steel", "Blue Wind", "Coastal Cement", "Delta Retail", "Echo Airlines"),
  exposure_m = c(25, 40, 18, 12, 30)
)
pin_write(board, portfolio, name = "client-portfolio", type = "rds",
          title = "Client portfolio, September")

# 3. Change the data and save a second version
portfolio$exposure_m[portfolio$company == "Echo Airlines"] <- 45
pin_write(board, portfolio, name = "client-portfolio", type = "rds",
          title = "Client portfolio, October")

# 4. See the history: two versions, newest first
history("client-portfolio")

# 5. Get the latest and the old version, and compare (paste the September ID)
latest    <- pin_read(board, "client-portfolio")
september <- pin_read(board, "client-portfolio", version = "<September ID>")
latest$exposure_m - september$exposure_m      # 0 0 0 0 15

# ---- Part B: versions of a file ------------------------------------------

dir.create("C:/pins-practice-files", showWarnings = FALSE)
write.csv(portfolio, "C:/pins-practice-files/portfolio.csv", row.names = FALSE)

pin_upload(board, "C:/pins-practice-files/portfolio.csv", name = "portfolio-file",
           title = "Portfolio file, October")

path <- pin_download(board, "portfolio-file")
read.csv(path)
