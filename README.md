# Data version control in R with pins, in VS Code

For R users who want to learn two things: how to **keep every version of their data files** safely,
and how to **work in VS Code**. About 45 minutes.

## The whole idea in one minute

pins keeps versions of your data in a shared folder. You only need four functions:

| You want to… | For a file (Excel, CSV, PDF…) | For a data frame |
|---|---|---|
| **Save** a new version | `pin_upload()` | `pin_write()` |
| **Get** the latest version | `pin_download()` | `pin_read()` |
| **See** all versions | `pin_versions()` | `pin_versions()` |
| **Get** an old version | `pin_download(..., version = "...")` | `pin_read(..., version = "...")` |

Every save creates a new version with a title. Old versions are never overwritten, so any of them
can be retrieved at any time. There's no git, no server, and nothing to install besides the package.

## Before you start

The practice in [Step 4](#step-4--practise-on-your-laptop) needs nothing: it runs on your laptop.
To connect to your team's shared board afterwards ([Step 5](#step-5--connect-to-the-teams-board)),
ask your team lead or cloud administrator for four things:

- your own **AWS access key ID** and **secret access key**
- the **bucket** name
- the team's **folder** in that bucket, for example `team-inputs/`
- the **region**, for example `eu-west-1`

## Contents

1. [Why version your data](#why-version-your-data)
2. [Step 1 – Set up VS Code for R](#step-1--set-up-vs-code-for-r)
3. [Step 2 – VS Code in five minutes](#step-2--vs-code-in-five-minutes)
4. [Step 3 – Pins, boards and versions](#step-3--pins-boards-and-versions)
5. [Step 4 – Practise on your laptop](#step-4--practise-on-your-laptop)
6. [Step 5 – Connect to the team's board](#step-5--connect-to-the-teams-board)
7. [Step 6 – Every day: the same four things](#step-6--every-day-the-same-four-things)
8. [Five rules to remember](#five-rules-to-remember)
9. [When something goes wrong](#when-something-goes-wrong)
10. [Cheat sheet](#cheat-sheet)
11. [Using RStudio instead](#using-rstudio-instead)

---

## Why version your data

Without versioning, shared data folders end up like this:

```
client-portfolio.xlsx
client-portfolio_v2.xlsx
client-portfolio_v2_final.xlsx
client-portfolio_FINAL_use_this_one.xlsx
```

Nobody is sure which file fed which result, or who changed what. When a reviewer or auditor asks
for the exact inputs behind a figure, the answer takes hours, or doesn't exist anymore.

With pins, every save is a new, dated, titled version, and any result can be traced back to the
exact data it used.

---

## Step 1 – Set up VS Code for R

> **Skip if** you can open a `.R` file in VS Code, press **Ctrl+Enter** on a line, and see it run
> in an R terminal, and `library(pins)` works. Go to [Step 2](#step-2--vs-code-in-five-minutes).

**1. Install R and VS Code**, if you don't have them. In PowerShell (Windows key, type
`PowerShell`, Enter):

```powershell
winget install --id RProject.R -e
winget install --id Microsoft.VisualStudioCode -e
```

If `winget` isn't available, download R from [cran.r-project.org](https://cran.r-project.org) and
VS Code from [code.visualstudio.com](https://code.visualstudio.com).

**2. Install the R extension.** In VS Code, press **Ctrl+Shift+X**, search for **R**, and install
the extension by **REditorSupport**.

**3. Start R inside VS Code.** Press **Ctrl+Shift+P**, type **R: Create R terminal**, and press
Enter. An R terminal opens at the bottom. Install the packages there:

```r
install.packages(c("languageserver", "pins", "paws.storage"))
```

`languageserver` gives VS Code autocompletion and help for R. `paws.storage` lets pins talk to S3.

**4. Check it works.** Create a file `test.R` containing `print("hello")`, put the cursor on the
line and press **Ctrl+Enter**. The R terminal prints `"hello"`.

If VS Code says it can't find R, open *File → Preferences → Settings*, search for
`r.rterm.windows`, and enter the full path to `R.exe`, for example
`C:\Program Files\R\R-4.5.1\bin\R.exe`, using the version folder you actually have.

---

## Step 2 – VS Code in five minutes

> **Skip if** you already use VS Code for R. Go to [Step 3](#step-3--pins-boards-and-versions).

**Work in a folder, not in single files.** *File → Open Folder* opens a project folder, the way an
RStudio project does. The Explorer on the left shows its files, and **the R terminal starts inside
that folder**, so `source("connect.R")` and relative paths just work.

**Two kinds of terminal.** The panel at the bottom can hold several terminals. The **R terminal**
is your R console. A **PowerShell** terminal (*Terminal → New Terminal*) is for system commands,
such as the `aws` command in Step 5. Switch between them with the list on the right of the panel.

**The keys you'll use:**

| Key | What it does |
|---|---|
| **Ctrl+Enter** | Runs the current line, or the selected lines, in the R terminal |
| **Ctrl+Shift+S** | Runs the whole file (`source()`) |
| **Ctrl+Shift+P** | The Command Palette: runs any command by name, such as **R: Create R terminal** |
| **Ctrl+P** | Opens any file in the folder by typing part of its name |
| **Ctrl+`** | Shows or hides the terminal panel |

**Seeing your data and objects:**

- `View(df)` opens a data frame in a VS Code tab, as in RStudio.
- The **R** icon in the left sidebar shows the **Workspace**: every object in your session.
- `?pin_read` opens R help in a VS Code tab. Plots also open in a tab.

**Restarting R:** click the bin icon on the R terminal to close it, then press Ctrl+Enter on any
line: a fresh R terminal starts.

Coming from RStudio? See [Using RStudio instead](#using-rstudio-instead) for a translation table.

---

## Step 3 – Pins, boards and versions

- A **pin** is a named piece of data, such as `client-portfolio`: a file, or a data frame.
- A **board** is the folder where pins are kept. For practice, a folder on your laptop. For real
  work, your team's folder on Amazon S3.
- A **version** is created every time you save a pin. Its ID is the date, the time and a short
  content fingerprint, for example `20261031T093001Z-7d0b5`.

Inside, a board is just folders. After saving `client-portfolio` twice:

```
board folder
└── client-portfolio/
    ├── 20260930T101512Z-a41c9/     ← one folder per version,
    └── 20261031T093001Z-7d0b5/     ← never changed after it's written
```

**Files or data frames?** Most teams keep files, such as Excel inputs received from clients, and
only need `pin_upload()` and `pin_download()`. Use `pin_write()` and `pin_read()` when your data
lives in R as a data frame. The practice shows both.

---

## Step 4 – Practise on your laptop

> **Skip if** you've used pins before. Go to [Step 5](#step-5--connect-to-the-teams-board).

The board here is a folder on your laptop, so nothing is shared and nothing can break. In VS Code,
open any folder you like, create a file `practice.R`, and paste the code below step by step,
running each part with **Ctrl+Enter**. The complete script is also in
[`examples/01-practice.R`](examples/01-practice.R).

### Part A: versions of a data frame

**1. Create the practice board**, and a small helper that shows the history with titles:

```r
library(pins)
board <- board_folder("C:/pins-practice", versioned = TRUE)

history <- function(name) {
  v <- pin_versions(board, name)
  v$title <- vapply(v$version, function(id) {
    title <- pin_meta(board, name, version = id)$title
    if (is.null(title)) "" else title
  }, character(1))
  v[order(v$created, decreasing = TRUE), c("version", "created", "title")]
}
```

`versioned = TRUE` keeps every version: always use it. `pin_versions()` on its own lists IDs and
dates but not titles, which is why `history()` adds them. The same helper is in the team's
`connect.R`, so it works the same way in real work.

**2. Save a first version.**

```r
portfolio <- data.frame(
  company    = c("Alpine Steel", "Blue Wind", "Coastal Cement", "Delta Retail", "Echo Airlines"),
  exposure_m = c(25, 40, 18, 12, 30)
)

pin_write(board, portfolio, name = "client-portfolio", type = "rds",
          title = "Client portfolio, September")
```

**3. Change the data and save a second version.**

```r
portfolio$exposure_m[portfolio$company == "Echo Airlines"] <- 45

pin_write(board, portfolio, name = "client-portfolio", type = "rds",
          title = "Client portfolio, October")
```

**4. See the history.**

```r
history("client-portfolio")
```

**You should see** two versions, newest first, something like:

```
                 version             created                       title
2 20260930T101844Z-7d0b5 2026-09-30 10:18:44   Client portfolio, October
1 20260930T101512Z-a41c9 2026-09-30 10:15:12 Client portfolio, September
```

**5. Get the latest and the old version, and compare.** Copy the September ID from your output:

```r
latest    <- pin_read(board, "client-portfolio")
september <- pin_read(board, "client-portfolio", version = "<September ID>")

latest$exposure_m - september$exposure_m
```

**You should see** `0 0 0 0 15`: only Echo Airlines changed, by 15 million.

### Part B: versions of a file

The same with a file, using `pin_upload()` and `pin_download()`:

```r
dir.create("C:/pins-practice-files", showWarnings = FALSE)
write.csv(portfolio, "C:/pins-practice-files/portfolio.csv", row.names = FALSE)

pin_upload(board, "C:/pins-practice-files/portfolio.csv", name = "portfolio-file",
           title = "Portfolio file, October")

path <- pin_download(board, "portfolio-file")
read.csv(path)
```

`pin_download()` returns the path of a local copy that pins keeps in its cache. Read it, but don't
edit it: save changes as a new version instead.

### Try it yourself

<details>
<summary><b>1.</b> Save a November version in which Blue Wind falls to 35, and check the history.</summary>

```r
portfolio$exposure_m[portfolio$company == "Blue Wind"] <- 35
pin_write(board, portfolio, name = "client-portfolio", type = "rds",
          title = "Client portfolio, November")
history("client-portfolio")   # three versions
```
</details>

<details>
<summary><b>2.</b> What happens if you save exactly the same data again?</summary>

pins notices the content hasn't changed, prints a message, and doesn't create a new version.
`history()` still shows three versions.
</details>

<details>
<summary><b>3.</b> Which functions list every pin, and show all details of one version?</summary>

```r
pin_list(board)
pin_meta(board, "client-portfolio")      # latest version; add version = "..." for another one
```
</details>

---

## Step 5 – Connect to the team's board

> **Skip if** `source("connect.R")` and `pin_list(board)` already work for you.
> Go to [Step 6](#step-6--every-day-the-same-four-things).

You need the four things from [Before you start](#before-you-start).

**1. Store your keys once.** In a **PowerShell** terminal in VS Code (*Terminal → New Terminal*):

```powershell
winget install --id Amazon.AWSCLI -e
```

Open a new PowerShell terminal, then:

```powershell
aws configure --profile team
```

Paste your access key ID and secret access key, type the region, and press Enter for the last
question. The keys are saved in your Windows user folder, never in a project.

**2. Create a project folder** for your scripts, for example `C:\projects\my-data`, and open it in
VS Code with *File → Open Folder*.

**3. Add `connect.R`.** Copy [`examples/connect.R`](examples/connect.R) into the folder and fill in
the bucket, folder and region:

```r
# connect.R
library(pins)

Sys.setenv(AWS_PROFILE = "team")

board <- board_s3(
  "your-company-bucket",
  prefix    = "team-inputs/",
  region    = "eu-west-1",
  versioned = TRUE
)

history <- function(name) {
  v <- pin_versions(board, name)
  v$title <- vapply(v$version, function(id) {
    title <- pin_meta(board, name, version = id)$title
    if (is.null(title)) "" else title
  }, character(1))
  v[order(v$created, decreasing = TRUE), c("version", "created", "title")]
}
```

**Why a separate file?** Every pins function needs the `board` object, and R forgets it whenever
the session restarts. `connect.R` recreates it in one line, `source("connect.R")`, with the same
bucket and settings for everyone.

**4. Make it automatic.** R runs a file called `.Rprofile` whenever it starts in a folder. Create
`.Rprofile` in your project folder containing:

```r
if (interactive()) source("connect.R")
```

From now on, every new R terminal in this folder connects to the board by itself. `interactive()`
makes sure it only runs in your own sessions, not in the background R process VS Code uses for
autocompletion. A project `.Rprofile` replaces your personal one while you're in this folder. A
copy is in [`examples/.Rprofile`](examples/.Rprofile).

**5. Check the connection.** Start a new R terminal (Ctrl+Shift+P, **R: Create R terminal**), then:

```r
pin_list(board)
```

It prints the team's pins, or nothing if the board is still empty. No error means you're connected.

---

## Step 6 – Every day: the same four things

The board is ready as soon as R starts. Then:

**1. Get the latest version.**

```r
path <- pin_download(board, "client-portfolio")
```

**2. Save a new version**, always with the same name and a new title:

```r
pin_upload(board, "C:/data/client-portfolio.xlsx", name = "client-portfolio",
           title = "Client portfolio, October 2026")
```

[`examples/save-new-version.R`](examples/save-new-version.R) wraps this in a script: change its
three lines and run it with **Ctrl+Shift+S**.

**3. See the history.**

```r
history("client-portfolio")
```

**4. Get an old version**, with its ID from the history:

```r
path <- pin_download(board, "client-portfolio", version = "<version-id>")
```

For data frames, use `pin_write()` and `pin_read()` in the same way.

---

## Five rules to remember

1. **Always use the same name** for the same data. A new name starts a new pin, with no history.
2. **Always give a title**, such as "Client portfolio, October 2026". It's what `history()` shows.
3. **Never edit a downloaded file in place.** It's pins' cached copy. Work on a copy, then save it
   as a new version.
4. **Sharing with Python or Excel users?** Save data frames with `type = "csv"`, or `"parquet"` for
   large tables (it needs the `nanoparquet` package). Only R can read `"rds"`.
5. **Don't delete without asking the team.** `pin_delete()` removes a pin and all its versions, for
   everyone with access to the bucket.

<details>
<summary><b>More things pins can do</b></summary>

| Function | What it does |
|---|---|
| `pin_write(..., metadata = list(month = "2026-10"))` | Saves your own details with a version; `pin_meta()` shows them under `$user` |
| `pin_exists(board, name)` | Checks whether a pin exists |
| `pin_versions_prune(board, name, n = 24)` | Keeps only the newest 24 versions |
| `cache_browse()` | Opens the folder where pins keeps its local copies |

Two people saving the same pin at the same moment simply create two versions; the later one
becomes the latest. pins has no permissions of its own: access is controlled by the bucket.
</details>

---

## When something goes wrong

| What you see | Why | What to do |
|---|---|---|
| `object 'board' not found` | `connect.R` hasn't run in this session | Run `source("connect.R")`, or add `.Rprofile` ([Step 5](#step-5--connect-to-the-teams-board)). |
| `cannot open file 'connect.R'` | R isn't running in your project folder | Open the folder with *File → Open Folder*, then start a new R terminal. |
| An error about missing credentials | R can't find your keys | Check `aws configure list --profile team` in PowerShell, and that `connect.R` sets `AWS_PROFILE`. Then restart R. |
| `Access Denied` or `403 Forbidden` | Your keys don't give access to that bucket or folder, or the region is wrong | Check the bucket, `prefix` and `region` in `connect.R` with your team lead. |
| VS Code can't find R | The R extension doesn't know where R is installed | Set `r.rterm.windows` to the path of `R.exe` ([Step 1](#step-1--set-up-vs-code-for-r)). |
| Ctrl+Enter does nothing | The R extension isn't installed, or the file isn't saved as `.R` | Install the extension by REditorSupport, and save the file with a `.R` ending. |
| A message that the pin's hash hasn't changed | You saved identical content | Not an error: pins didn't store a duplicate. |
| A Python colleague can't read your pin | It was saved as `"rds"` | Save it again with `type = "csv"`. |

---

## Cheat sheet

| Task | Code |
|---|---|
| Connect to the team's board | `source("connect.R")`, or automatically with `.Rprofile` |
| Practice board on your laptop | `board <- board_folder("C:/pins-practice", versioned = TRUE)` |
| Save a file | `pin_upload(board, "<file>", name = "<name>", title = "<what it is>")` |
| Save a data frame | `pin_write(board, df, name = "<name>", type = "rds", title = "<what it is>")` |
| Get the latest file / data frame | `pin_download(board, "<name>")` / `pin_read(board, "<name>")` |
| See the history, with titles | `history("<name>")` |
| Get an old version | add `version = "<version-id>"` to `pin_download` or `pin_read` |
| List every pin | `pin_list(board)` |

---

## Using RStudio instead

Everything in this tutorial works in RStudio too. Only the editor actions differ:

| In VS Code | In RStudio |
|---|---|
| *File → Open Folder* | *File → New Project → Existing Directory* |
| R terminal | Console pane |
| **Ctrl+Enter** | **Ctrl+Enter** |
| **Ctrl+Shift+S** (run the whole file) | **Ctrl+Shift+Enter** |
| R icon → Workspace | Environment pane |
| Close the R terminal, then Ctrl+Enter | *Session → Restart R* |

`.Rprofile` works the same way in an RStudio project.

---

pins is actively developed. If a function behaves differently from what's shown here, check the
current documentation at [pins.rstudio.com](https://pins.rstudio.com).

*Questions or corrections: open an issue or a pull request on this repository.*
