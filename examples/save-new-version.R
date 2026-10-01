# save-new-version.R: saves a new version of a file on the team's board,
# recording who saved it. Change the three lines below, then run the whole script:
# Ctrl+Shift+S in VS Code, Ctrl+Shift+Enter in RStudio.

file  <- "C:/data/client-portfolio.xlsx"            # the file to save
name  <- "client-portfolio"                         # its name on the board: keep it the same every time
title <- "Client portfolio, October 2026"           # what this version is

source("connect.R")

save_version(file, name = name, title = title)
history(name)                                       # the new version is at the top, with your name
