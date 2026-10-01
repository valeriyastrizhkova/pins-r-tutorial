# Practice with pins on your own laptop: the same steps as Step 4 of the tutorial.
# Run it part by part with Ctrl+Enter. Nothing here touches shared storage.

library(pins)

# ---- Setup: the practice board and the two helpers ------------------------

board <- board_folder("C:/pins-practice", versioned = TRUE)

# Save a new version of a file or a data frame, always recording who saved it
save_version <- function(x, name, title, type = "rds") {
  who <- list(author = Sys.info()[["user"]])
  if (is.data.frame(x)) {
    pin_write(board, x, name = name, type = type, title = title, metadata = who)
  } else {
    pin_upload(board, x, name = name, title = title, metadata = who)
  }
}

# Every version of a pin, newest first, with who saved it and its title
history <- function(name) {
  v <- pin_versions(board, name)
  meta <- lapply(v$version, function(id) pin_meta(board, name, version = id))
  v$author <- vapply(meta, function(m) if (is.null(m$user$author)) "unknown" else m$user$author, character(1))
  v$title  <- vapply(meta, function(m) if (is.null(m$title)) "" else m$title, character(1))
  v[order(v$created, decreasing = TRUE), c("version", "created", "author", "title")]
}

# ---- Part A: versions of a data frame -------------------------------------

portfolio <- data.frame(
  company    = c("Alpine Steel", "Blue Wind", "Coastal Cement", "Delta Retail", "Echo Airlines"),
  exposure_m = c(25, 40, 18, 12, 30)
)
save_version(portfolio, name = "client-portfolio", title = "Client portfolio, September")

portfolio$exposure_m[portfolio$company == "Echo Airlines"] <- 45
save_version(portfolio, name = "client-portfolio", title = "Client portfolio, October")

# The history: date, author (your Windows login name) and title of every version
history("client-portfolio")

# Get the latest and the old version, and compare (paste the September ID)
latest    <- pin_read(board, "client-portfolio")
september <- pin_read(board, "client-portfolio", version = "<September ID>")
latest$exposure_m - september$exposure_m      # 0 0 0 0 15

# ---- Part B: versions of a file ------------------------------------------

dir.create("C:/pins-practice-files", showWarnings = FALSE)
write.csv(portfolio, "C:/pins-practice-files/portfolio.csv", row.names = FALSE)

save_version("C:/pins-practice-files/portfolio.csv", name = "portfolio-file",
             title = "Portfolio file, October")

path <- pin_download(board, "portfolio-file")
read.csv(path)
