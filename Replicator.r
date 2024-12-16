rm(list = ls())
source("Data.r")

Replicator = R6::R6Class(
  classname = "Replicator",

  public = list(
    control_index = NULL,
    treated_index = NULL,
    random_start_time = NULL,
    replicated_index = NULL,

    initialize = function(data, seed) {
      if (!inherits(data, "Data")) stop("Argument data is not Data class!")

      set.seed(seed)
      self$control_index = which(rowSums(data$treatments) == 0)
      self$treated_index = which(rowSums(data$treatments) != 0)
      self$random_start_time = replicate(length(self$control_index),
                                sample(1:data$n_periods, 2),
                                simplify = FALSE)
      self$replicated_index = c(self$treated_index,
        rep(self$control_index, times = lengths(self$random_start_time)))
    },
    create_replicated_data = function(data) {
      cbind(unit = rep(self$replicated_index, times = data$n_periods),
        period = rep(1:data$n_periods, each = length(self$replicated_index)),
        x1 = c(private$create_replicated_x1(data)),
        x2 = c(private$create_replicated_x2(data)),
        treat = c(private$create_replicated_treatments(data)),
        start = c(private$create_replicated_start_time(data)),
        duration = c(private$create_replicated_duration(data)),
        y = c(private$create_replicated_y(data))
      )
    }
  ),

  private = list(
    create_replicated_y = function(data) {
      data$y[self$replicated_index, ]
    },
    create_replicated_x1 = function(data) {
      data$x1[self$replicated_index, ]
    },
    create_replicated_x2 = function(data) {
      data$x2[self$replicated_index, ]
    },
    create_replicated_treatments = function(data) {
      data$treatments[self$replicated_index, ]
    },
    create_replicated_start_time = function(data) {
      c(data$start_time[self$treated_index],
        unlist(self$random_start_time))
    },
    create_replicated_duration = function(data) {
      mat = matrix(1:data$n_periods,
                   sum(lengths(self$random_start_time)),
                   data$n_periods, byrow = TRUE)
      rbind(data$duration[self$treated_index,],
            pmax(mat - unlist(self$random_start_time) + 1, 0))
    }
  )
)

if (sys.nframe() == 0) {
  data = Data$new(30, 5, 1)
  replicator = Replicator$new(data, 1)
  replicator$create_replicated_data(data)
}