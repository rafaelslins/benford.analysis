context("Benford Functions")
library(benford.analysis)
test_that("Corporate Payment 1 digit, only >=10",
          {
            data(corporate.payment, envir = environment())
            cp <- corporate.payment$Amount[corporate.payment$Amount >= 10]
            expect_that(length(cp), equals(177763))
            bfd1 <- benford(cp,1)
            expect_that(bfd1$info$n.second.order,equals(64578))
            expect_that(MAD(bfd1), equals(0.01464, tolerance = 1e-03))
            expect_that(MAD(1), throws_error("Object must be of class Benford"))
            bfd2 <- benford(cp,4)
            expect_true(is.na(bfd2$MAD.conformity))
            # check if object did not change
            expect_that(bfd1, equals(benford(cp,1)))
            
          }
)
   
test_that("Corporate Payment 2 digits, only >=10",
          { 
            data(corporate.payment, envir = environment())
            cp <- corporate.payment$Amount[corporate.payment$Amount >= 10]
            expect_that(length(cp), equals(177763))
            bfd2 <- benford(cp,2)
            expect_that(bfd2$info$n.second.order,equals(64578))
            expect_that(MAD(bfd2), equals(0.00243, tolerance = 1e-03))
            expect_that(head(suspectsTable(bfd2, "abs.excess.summation"))$digits,
                        equals(c(15, 26, 10, 14, 11, 50)))
            d.test <- data.frame(number = c(50.00,1153.35,1083.45,150.00,988.35,1159.35),
                                 duplicates = c(6022,2264,1185,1056,1018,976))
            d.data <- as.data.frame(head(duplicatesTable(bfd2)))
            expect_that(d.data, equals(d.test))
            expect_that(duplicatesTable(1), throws_error("bfd must be a 'Benford' object."))
            
            # check if object did not change
            expect_that(bfd2, equals(benford(cp, 2)))
            
            # check if no warnings 
            # maybe in the future include warning if the data seems discrete
            expect_silent(benford(corporate.payment$Amount, discrete = F))
            
          }
)

test_that("Census 2009 data, 2 digits, only >=10",
          {
            data(census.2009, envir = environment())
            pop <- census.2009$pop.2009[census.2009$pop.2009 >= 10]
            expect_that(length(pop), equals(19482))
            bfd.census <- benford(pop, 2)
            expect_that(dfactor(bfd.census), equals(0.74, tolerance = 1e-03))
            expect_that(dfactor(1), throws_error("Object must be of class Benford"))
            expect_that(round(chisq(bfd.census)$statistic),is_equivalent_to(108))
            expect_that(chisq(1), throws_error("Object must be of class Benford"))
            expect_that(ks(1), throws_error("Object must be of class Benford"))
            expect_true(is.numeric(ks(bfd.census)$statistic))
            # check if object did not change
            expect_that(bfd.census, equals(benford(pop, 2)))
          }
)

test_that("Negative numbers, simulated log-normal *(-1)",
         {
           set.seed(1)
           data <- rlnorm(10000, 10, 10)
           data <- data*(-1)
           bfd  <- benford(data, sign = "negative")
           test <- structure(list(statistic = c("Mean Mantissa", "Var Mantissa", 
                                                "Ex. Kurtosis Mantissa", "Skewness Mantissa"), 
                                  values = c(0.496354817370674,0.0819078569969828, -1.18345152468828, 0.0122274722811928)), 
                             .Names = c("statistic","values"), row.names = c(NA, -4L), 
                             class = c("data.table", "data.frame"))
           mant <- mantissa(bfd)
           expect_that(test, equals(mant))
           expect_that(mantissa(1), throws_error("Object must be of class Benford"))
           # check if object did not change
           expect_that(bfd, equals( benford(data, sign = "negative")))
         }
)

test_that("Both signs, simulated log-normal and plots",
          {
            set.seed(1)
            data <- rlnorm(1000, 10, 10)
            data <- data*c(1, -1)
            bfd <- benford(data, sign = "both", discrete = FALSE)
            expect_error(plot.Benford(1))
            expect_error(plot(bfd, except = "xxx", select = NULL))
            expect_error(plot(bfd, select = "xxx"))
            plot(bfd, except = c("none"))
            plot(bfd, except = c("mantissa","abs diff", "second order") )
            plot(bfd, except = c("mantissa","abs diff", "second order", "summation") )
            plot(bfd, except = c("mantissa","abs diff", "second order", "summation", 
                                 "chi square"))
            plot(bfd, except = c("mantissa","abs diff", "second order", "summation", 
                                 "chi square", "ex summation"))
            plot(bfd, except = c("digits","rootogram digits", "rootogram second order", "summation", "mantissa","abs diff", "chi squared", "ex summation"))
            plot(bfd, except = c("mantissa","abs diff", "second order", "summation", 
                                 "chi square", "ex summation"), err.bounds = TRUE)
            plot(bfd, except = "none", select = NULL)
            plot(bfd, except = "mantissa", select = NULL)
            plot(bfd, select = "all", err.bounds = TRUE)
            plot(bfd, select = "rootogram digits", err.bounds = TRUE)
            plot(bfd, select = "second order")
            plot(bfd, select = "mantissa")
            plot(bfd, select = "abs diff")
            plot(bfd, select = "rootogram second order")
            plot(bfd, select = c("digits","rootogram digits", "rootogram second order", "summation", "mantissa","abs diff", "legend"))
            
            # check if object did not change
            expect_that(bfd, equals(benford(data, sign = "both", discrete = FALSE)))
          }
)


test_that("Exact printing, this sould not be tested on CRAN!",
          {
            skip_on_cran()
            skip_on_travis()
            set.seed(1)
            data <- rlnorm(1000, 10, 10)
            data <- data*c(1, -1)
            bfd <- benford(data, sign = "both", discrete = FALSE)
            print <- capture.output(print(bfd))
            test_print <- c("", "Benford object:", " ", "Data: data ", "Number of observations used = 1000 ", 
                            "Number of obs. for second order = 995 ", "First digits analysed = 2", 
                            "", "Mantissa: ", "", "   Statistic  Value", "        Mean  0.476", 
                            "         Var  0.084", " Ex.Kurtosis -1.205", "    Skewness  0.076", 
                            "", "", "The 5 largest deviations: ", "", "  digits absolute.diff", 
                            "1     10         13.61", "2     18         12.52", "3     31          9.21", 
                            "4     11          9.21", "5     15          8.03", "", "Stats:", 
                            "", "\tPearson's Chi-squared test", "", "data:  data", "X-squared = 83.095, df = 89, p-value = 0.6564", 
                            "", "", "\tMantissa Arc Test", "", "data:  data", "L2 = 0.0013529, df = 2, p-value = 0.2585", 
                            "", "","\tKolmogorov-Smirnov test","","data:  data","D = 0.039781, critical value = 0.043007",
                            "", "Mean Absolute Deviation (MAD): 0.002609809", "MAD Conformity - Nigrini (2012): Nonconformity", 
                            "Distortion Factor: -6.228274", "", "Remember: Real data will never conform perfectly to Benford's Law. You should not focus on p-values!"
            )
            expect_that(print, equals(test_print))
          }
)

test_that("Internal function",
          {
            x <- seq(0.1, 0.9, length.out = 9)
            y <- seq(0.9, 0.1, length.out = 9)
            expect_equal(round(sum(z.stat.bfd(x, y, 100))), 108)
          }
)

test_that("Regular printing -- no comparisons",
          {
            set.seed(1)
            data <- rlnorm(1000, 10, 10)
            data <- data*c(1, -1)
            bfd <- benford(data, sign = "both", discrete = FALSE)
            print <- capture.output(print(bfd))
            expect_error(print.Benford(1))
          }
)



