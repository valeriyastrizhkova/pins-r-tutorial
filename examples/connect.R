# connect.R: connects to the team's shared board on S3.
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

# history("client-portfolio"): every version of a pin, newest first, with its title
history <- function(name) {
  v <- pin_versions(board, name)
  v$title <- vapply(v$version, function(id) {
    title <- pin_meta(board, name, version = id)$title
    if (is.null(title)) "" else title
  }, character(1))
  v[order(v$created, decreasing = TRUE), c("version", "created", "title")]
}
