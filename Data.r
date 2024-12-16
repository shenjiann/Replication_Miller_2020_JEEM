rm(list = ls())

Data = R6::R6Class(
  classname = "Data",

  public = list(
    seed = NULL,
    n_units = NULL,
    n_periods = NULL,
    y = NULL,
    x1 = NULL,
    x2 = NULL,
    tau = NULL,
    duration = NULL,
    start_time = NULL,
    treatments = NULL,

    initialize = function(n_units, n_periods, seed) {
      self$n_units = n_units
      self$n_periods = n_periods
      self$seed = seed
      set.seed(self$seed)
      self$x1 = matrix(runif(self$n_units * self$n_periods),
                       self$n_units, self$n_periods)
      self$x2 = matrix(runif(self$n_units * self$n_periods),
                       self$n_units, self$n_periods)
      private$treated_probs = private$create_treated_probs()
      self$start_time = private$create_start_time()
      self$treatments = private$create_treatments()
      self$duration = private$create_duration()
      private$error = private$create_error()
      self$tau = private$create_tau()
      self$y = self$treatments * self$tau + private$error
      cat("data created: n_units", self$n_units,
          "; n_periods", self$n_periods,
          "; seed", self$seed, "\n")
    }
  ),

  private = list(
    treated_probs = NULL,
    error = NULL,

    create_treated_probs = function() {
      matrix(0.02, self$n_units, self$n_periods)
    },
    create_start_time = function() {
      mat = matrix(
        rbinom(self$n_periods * self$n_units, 1, private$treated_probs),
        nrow = self$n_units,
        ncol = self$n_periods
      )
      apply(mat, 1, function(row) {
        idx = which(row == 1)
        if (length(idx) == 0) (0) else idx[1]
      })
    },
    create_treatments = function() {
      mat = matrix(1:self$n_periods, self$n_units, self$n_periods, byrow = TRUE)
      treatments = (mat >= self$start_time) * 1
      treatments[which(self$start_time == 0), ] = 0
      return(treatments)
    },
    create_duration = function() {
      mat = matrix(1:self$n_periods, self$n_units, self$n_periods, byrow = TRUE)
      self$treatments * (mat - self$start_time + 1)
    },
    create_error = function() {
      matrix(
        rnorm(self$n_periods * self$n_units, 0, 1),
        self$n_units,
        self$n_periods
      )
    },
    create_tau = function() {
      if_x2_leq_05 = matrix(as.numeric(self$x2 <= 0.5),
                            self$n_units,
                            self$n_periods)
      duration = self$duration
      start_time = self$start_time
      duration[is.na(self$duration)] = 0
      start_time[is.na(self$start_time)] = 0
      5 * if_x2_leq_05 + duration - 0.025 * (duration^2) +
        0.001 * duration * if_x2_leq_05 + 0.2 * start_time
    }
  )
)

if (sys.nframe() == 0) {
  data = Data$new(100, 10, 1)
  View(data$duration)
  View(data$start_time)
  View(data$treatments)
  View(data$tau)
  View(data$y)
  View(data$x2)
}