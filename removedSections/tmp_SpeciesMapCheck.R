library("googledrive")
library("data.table")
library("reproducible")

urlID <- "1ffWDDurVMVmK1Ezlgzg4Yoos_F_l01B2"
dstPath <- file.path(getwd(), "figures/speciesMaps")
spList <- fread(header = TRUE, "tables/bird_species_oct2021.csv")

# "Scientific Name", "Common Name", "Species Code"

scenarios <- c("05", seq(15, 95, 10))
Years <- seq(2011, 2091, by = 20)
fls <- data.table(drive_ls(path = as_id(urlID),
                           pattern = ".png"))

DT <- rbindlist(lapply(spList[["Species Code"]], function(BIRD){
  DT <- rbindlist(lapply(scenarios, function(SCEN){
    DT <- rbindlist(lapply(Years, function(Y){
      FL <-  paste0(BIRD, "_",SCEN,"_",Y,".png")
      fl <- fls[name == FL, ]
      if (NROW(fl) == 0){
        Available <- FALSE
      } else Available <- TRUE

      DT <- data.table(Species = BIRD,
                 Scenario = SCEN,
                 Year = Y,
                 Available = Available)
      return(DT)
    }))
  }))
}))

length(unique(DT[Available == TRUE, Species]))
unique(DT[Available == TRUE, Scenario])
DT[Available == FALSE & Year == 2031, ]

missingSp <- setdiff(spList[["Species Code"]],
                     unique(DT[Available == FALSE & Year == 2031, Species]))
# missingSpecies <- c("ALFL", "AMCR", "CONW", "EVGR", "FOSP", "GCKI", "HETH", "HOLA",
#                     "PAWA", "SOSP", "TEWA", "TRES", "WEWP", "YBFL")
# NEED TO UPLOAD MAPS FOR THESE ASAP!

availableSp <- unique(DT[Available == TRUE & Year == 2031 & Scenario == "15", Species])

lapply(availableSp, function(BIRD){
  figName <- paste0(BIRD, "_15_2031.png")
  FL <- fls[name == figName, id]
  drive_download(file = as_id(FL), path = file.path(dstPath, figName))
  })

