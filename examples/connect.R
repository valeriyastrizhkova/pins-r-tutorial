# connect.R: connects to the team's shared board on S3, and adds two helpers:
#   save_version()  saves a file or a data frame, always recording who saved it
#   history()       lists every version with its date, author and title
# Run it with source("connect.R"), or automatically with the .Rprofile in this folder.
# Fill in the bucket, folder and region once (ask your team lead).

library(pins)

Sys.setenv(AWS_PROFILE = "team")   # the profile that holds your own AWS keys

board <- board_s3(
  "your-company-bucket",           # the bucket
  prefix    = "team-inputs/",      # the team's folder in the bucket
  region    = "eu-west-1",
  versioned = TRUE                 # keep every version: never change this to FALSE
)

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
