# STA6105 assignment 2
# exercises from R for Data Science (Wickham & Grolemund), chapters 1 to 8
# Steven Wasonga

library(tidyverse)
library(nycflights13)


# Chapter 1 data visualisation

# first steps
ggplot(data = mpg)
# just an empty grey plot, nothing has been mapped yet

nrow(mtcars)
ncol(mtcars)
# 32 rows and 11 columns

?mpg
# drv is the type of drive train. f = front wheel, r = rear wheel, 4 = four wheel drive

ggplot(data = mpg) +
  geom_point(mapping = aes(x = cyl, y = hwy))

ggplot(data = mpg) + geom_point(mapping = aes(x = drv, y = class))
# both variables are categorical so the points just sit on a grid,
# you cant tell how many cars are at each point so it is not useful

# aesthetic mappings
# q1 color = "blue" is inside aes() so ggplot treats "blue" like a variable. it has to go outside
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")

# q2 categorical: manufacturer, model, trans, drv, fl, class
# continuous: displ, year, cyl, cty, hwy (year and cyl only have a few values though)
# printing mpg or glimpse() shows <chr> for the categorical ones
glimpse(mpg)

# q3
ggplot(mpg) + geom_point(aes(displ, hwy, color = cty))
ggplot(mpg) + geom_point(aes(displ, hwy, size = cty))
# ggplot(mpg) + geom_point(aes(displ, hwy, shape = cty))
# shape gives an error, a continuous variable can not be mapped to shape
# colour becomes a gradient instead of separate colours, size is a range instead of steps

# q4 same variable on two aesthetics works, the legend is just combined
ggplot(mpg) + geom_point(aes(displ, hwy, color = drv, shape = drv))

# q5 stroke changes the width of the border, for shapes 21-24 which have a border and a fill
ggplot(mpg) + geom_point(aes(displ, hwy), shape = 21, fill = "white", stroke = 2)

# q6
ggplot(mpg) + geom_point(aes(displ, hwy, colour = displ < 5))
# it creates a TRUE/FALSE variable on the fly and colours by that

# facets
ggplot(mpg) + geom_point(aes(displ, hwy)) + facet_wrap(~ cty)
# q1 faceting on a continuous variable gives a panel for every value, too many panels

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)
# q3 the . means do not facet in that direction, first is rows by drv, second is columns by cyl

# q5 nrow and ncol set the number of rows/columns of panels. facet_grid does not need them
# because the number of levels of the two variables already fixes the layout
# q6 the screen is wider than it is tall so more levels fit better in the columns

# geometric objects
# q1 line chart geom_line(), boxplot geom_boxplot(), histogram geom_histogram(), area geom_area()

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  geom_smooth(se = FALSE)
# q2 i expected points coloured by drv and one line for each drv without the grey band, which is what came out

# q3 show.legend = FALSE hides the legend for that layer
# q4 se adds the confidence band around the smooth line
# q5 the two graphs look the same, the second one just repeats data and mapping in each layer

# q6 recreating the six graphs
ggplot(mpg, aes(displ, hwy)) + geom_point() + geom_smooth(se = FALSE)
ggplot(mpg, aes(displ, hwy)) + geom_point() + geom_smooth(aes(group = drv), se = FALSE)
ggplot(mpg, aes(displ, hwy, color = drv)) + geom_point() + geom_smooth(se = FALSE)
ggplot(mpg, aes(displ, hwy)) + geom_point(aes(color = drv)) + geom_smooth(se = FALSE)
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth(aes(linetype = drv), se = FALSE)
ggplot(mpg, aes(displ, hwy)) +
  geom_point(size = 4, color = "white") +
  geom_point(aes(colour = drv))

# statistical transformations
# q1 the default geom for stat_summary is pointrange
ggplot(diamonds) +
  geom_pointrange(aes(x = cut, y = depth), stat = "summary",
     fun.min = min, fun.max = max, fun = median)
# fun.y, fun.ymin and fun.ymax in the book are deprecated now, its fun, fun.min and fun.max

# q2 geom_col uses the y values as they are (stat identity), geom_bar counts the rows
demo <- tribble(
  ~a, ~b,
  "bar_1", 20,
  "bar_2", 30,
  "bar_3", 40
)
ggplot(demo) + geom_col(aes(x = a, y = b))

# q5
ggplot(diamonds) + geom_bar(aes(x = cut, y = after_stat(prop)))
# all bars are height 1 because prop is calculated within each cut separately
ggplot(diamonds) + geom_bar(aes(x = cut, y = after_stat(prop), group = 1))
# ..prop.. from the book still runs but gives a warning, after_stat() is the new way

# position adjustments
ggplot(mpg, aes(cty, hwy)) + geom_point()
ggplot(mpg, aes(cty, hwy)) + geom_jitter()
# q1 overplotting, many cars have the same cty and hwy so points are on top of each other. jitter fixes it
# q2 width and height control how much jitter
ggplot(mpg, aes(cty, hwy)) + geom_jitter(width = 0.3, height = 0.3)
# q3 geom_count makes the point bigger where more cars overlap instead of moving them
ggplot(mpg, aes(cty, hwy)) + geom_count()
# q4 default position for geom_boxplot is dodge2
ggplot(mpg, aes(class, hwy, colour = drv)) + geom_boxplot()

# coordinate systems
# q1 pie chart
ggplot(diamonds, aes(x = factor(1), fill = clarity)) +
  geom_bar(width = 1) +
  coord_polar(theta = "y")

# q2 labs() changes the title, axis labels and legend titles
ggplot(mpg, aes(class, hwy)) + geom_boxplot() + coord_flip() +
  labs(title = "Highway mpg by class", x = NULL, y = "highway mpg")

# q4 hwy is always higher than cty, all the points are above the 45 degree line.
# geom_abline draws the line y = x and coord_fixed keeps it at 45 degrees
ggplot(mpg, aes(cty, hwy)) +
  geom_point() +
  geom_abline() +
  coord_fixed()


# Chapter 2 workflow basics

# q1 the second name is typed with a dotless i so R sees a different object
my_variable <- 10
my_variable

# q2
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))
filter(mpg, cyl == 8)
filter(diamonds, carat > 3)
# dota -> data, fliter -> filter, = -> ==, diamond -> diamonds

# q3 alt+shift+k opens the keyboard shortcuts. same thing from Help > Keyboard Shortcuts Help


# Chapter 3 dplyr

# filter q1
filter(flights, arr_delay >= 120)
filter(flights, dest %in% c("IAH", "HOU"))
filter(flights, carrier %in% c("UA", "AA", "DL"))
filter(flights, month %in% 7:9)
filter(flights, arr_delay > 120, dep_delay <= 0)
filter(flights, dep_delay >= 60, dep_delay - arr_delay > 30)
filter(flights, dep_time <= 600 | dep_time == 2400)

# q2 between(x, left, right) is short for x >= left & x <= right
filter(flights, between(month, 7, 9))

# q3
sum(is.na(flights$dep_time))
colSums(is.na(flights))
# 8255 flights have no dep_time. dep_delay, arr_time, arr_delay and air_time are also missing
# for these, so they are most likely cancelled flights

# q4
NA ^ 0
NA | TRUE
FALSE & NA
NA * 0
# anything to the power 0 is 1, anything OR TRUE is TRUE, anything AND FALSE is FALSE.
# NA * 0 is still NA because the NA could be Inf and Inf * 0 is NaN

# arrange
arrange(flights, desc(is.na(dep_time)), dep_time)
# q1 is.na() is TRUE for the missing ones so desc() puts them at the top

arrange(flights, desc(dep_delay))
arrange(flights, dep_delay)
# q2 most delayed is HA 51 on 9 Jan, 1301 minutes. earliest left 43 minutes early (B6 97)

arrange(flights, desc(distance / air_time))
# q3 fastest by speed is DL 1499 LGA to ATL, 762 miles in 65 minutes

arrange(flights, desc(distance))
arrange(flights, distance)
# q4 longest is JFK to HNL (4983 miles), shortest is EWR to LGA (17 miles)

# select q1
select(flights, dep_time, dep_delay, arr_time, arr_delay)
select(flights, starts_with("dep_"), starts_with("arr_"))
select(flights, matches("^(dep|arr)_(time|delay)$"))
select(flights, 4, 6, 7, 9)

# q2 the column only comes once
select(flights, year, month, year)

# q3 one_of() picks columns named in a character vector. it is superseded now, any_of() and all_of() do it
vars <- c("year", "month", "day", "dep_delay", "arr_delay")
select(flights, any_of(vars))

# q4 the helpers ignore case by default so TIME still matches
select(flights, contains("TIME"))
select(flights, contains("TIME", ignore.case = FALSE))

# mutate q1 minutes since midnight. %% 1440 turns 2400 (midnight) into 0
flights_times <- mutate(flights,
  dep_time_mins = (dep_time %/% 100 * 60 + dep_time %% 100) %% 1440,
  sched_dep_time_mins = (sched_dep_time %/% 100 * 60 + sched_dep_time %% 100) %% 1440
)
select(flights_times, dep_time, dep_time_mins, sched_dep_time, sched_dep_time_mins)

# q4 10 most delayed. min_rank gives tied flights the same rank
flights %>%
  mutate(r = min_rank(desc(dep_delay))) %>%
  filter(r <= 10) %>%
  arrange(r) %>%
  select(r, carrier, flight, dep_delay)

# q5
1:3 + 1:10
# the shorter vector gets recycled, there is a warning because 10 is not a multiple of 3

# q6 cos, sin, tan, acos, asin, atan, atan2 and cospi, sinpi, tanpi. see ?Trig

# summarise
not_cancelled <- flights %>%
  filter(!is.na(dep_delay), !is.na(arr_delay))

# q2 same output without count()
not_cancelled %>% count(dest)
not_cancelled %>% group_by(dest) %>% summarise(n = n())

not_cancelled %>% count(tailnum, wt = distance)
not_cancelled %>% group_by(tailnum) %>% summarise(n = sum(distance))

# q3 arr_delay is the more important one, a flight can depart and then get diverted
# so it has dep_delay but no arr_delay

# q4
cancelled_day <- flights %>%
  mutate(cancelled = is.na(arr_delay) | is.na(dep_delay)) %>%
  group_by(year, month, day) %>%
  summarise(prop_cancelled = mean(cancelled),
            avg_delay = mean(dep_delay, na.rm = TRUE))

ggplot(cancelled_day, aes(avg_delay, prop_cancelled)) + geom_point()
# days with more cancellations also have higher average delays, probably bad weather days

# q5
flights %>%
  group_by(carrier) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
  arrange(desc(arr_delay))
# F9 (Frontier) has the worst average arrival delay

# q7 sort = TRUE in count() sorts by n, saves an arrange()
not_cancelled %>% count(dest, sort = TRUE)

# grouped mutates and filters
# q2 worst on time record, only planes with at least 20 flights
flights %>%
  filter(!is.na(arr_delay)) %>%
  group_by(tailnum) %>%
  summarise(n = n(), on_time = mean(arr_delay <= 0), avg_delay = mean(arr_delay)) %>%
  filter(n >= 20) %>%
  arrange(on_time)

# q3
flights %>%
  group_by(hour) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
  arrange(arr_delay)
# fly early morning (5 to 7am), delays build up as the day goes on

# q4 total delay per destination and each flights share of it
flights %>%
  filter(arr_delay > 0) %>%
  group_by(dest) %>%
  mutate(total_delay = sum(arr_delay),
         prop_delay = arr_delay / total_delay) %>%
  select(dest, carrier, flight, arr_delay, total_delay, prop_delay) %>%
  arrange(dest, desc(prop_delay))


# Chapter 4 workflow scripts
# no code here. the tip i picked is ctrl+shift+c which comments/uncomments selected lines,
# and ctrl+shift+m for the pipe. diagnostics also warn about unused variables,
# missing arguments and variables used but not defined


# Chapter 5 exploratory data analysis

# variation q1
summary(select(diamonds, x, y, z))
ggplot(diamonds) + geom_histogram(aes(x), binwidth = 0.1)
ggplot(diamonds) + geom_histogram(aes(y), binwidth = 0.1) + coord_cartesian(xlim = c(0, 12))
ggplot(diamonds) + geom_histogram(aes(z), binwidth = 0.1) + coord_cartesian(xlim = c(0, 12))
# x and y have almost the same distribution so they are the length and width,
# z is smaller so it is the depth. there are zeros and a few very big y and z values which must be errors

# q2
ggplot(diamonds, aes(price)) + geom_histogram(binwidth = 100)
ggplot(filter(diamonds, price < 2500), aes(price)) + geom_histogram(binwidth = 10)
# there are no diamonds priced around $1500, a gap in the data. also price is right skewed

# q3
diamonds %>%
  filter(carat >= 0.99, carat <= 1) %>%
  count(carat)
# 23 diamonds at 0.99 and 1558 at 1 carat. probably rounded up since 1 carat sells for more

# q4
ggplot(diamonds) + geom_histogram(aes(price)) + coord_cartesian(xlim = c(100, 5000))
ggplot(diamonds) + geom_histogram(aes(price)) + xlim(100, 5000)
# xlim() removes the data outside the limits before the bins are made so the edge bars go missing,
# coord_cartesian() only zooms. without binwidth it uses 30 bins and gives a message

# missing values
# q1 geom_histogram drops the NAs with a warning. in geom_bar NA is shown as its own bar
# because for a categorical variable it is just another category
# q2 na.rm = TRUE removes the NAs before mean() or sum() is calculated

# covariation q1 cancelled vs not cancelled, using density so the groups can be compared
flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>%
  ggplot(aes(sched_dep_time, after_stat(density), colour = cancelled)) +
  geom_freqpoly(binwidth = 1/4)

# q2
ggplot(diamonds, aes(carat, price)) + geom_point(alpha = 0.05)
ggplot(diamonds, aes(cut, carat)) + geom_boxplot()
# carat is what drives price. fair diamonds tend to be bigger, so they look more expensive than ideal ones

# two categorical variables q1 proportion of each cut within a colour
diamonds %>%
  count(color, cut) %>%
  group_by(color) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(color, cut, fill = prop)) +
  geom_tile()

# q2
flights %>%
  group_by(month, dest) %>%
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  group_by(dest) %>%
  filter(n() == 12) %>%
  ungroup() %>%
  ggplot(aes(factor(month), dest, fill = dep_delay)) +
  geom_tile() +
  labs(x = "month")
# too many destinations to read, i dropped the ones that dont have all 12 months.
# ordering dest by delay would help too

# two continuous variables
# q2 carat partitioned by price
ggplot(diamonds, aes(cut_number(price, 10), carat)) +
  geom_boxplot() +
  coord_flip() +
  labs(x = "price")

# q3 big diamonds vary a lot more in price than small ones, which i expected since cut, colour
# and clarity matter more once the stone is big

# q4 cut, carat and price together
ggplot(diamonds, aes(carat, price)) +
  geom_hex() +
  facet_wrap(~ cut)


# Chapter 6 workflow projects
# no exercises, i set up an rstudio project for this unit and turned off saving .RData


# Chapter 7 tibbles

# q1 a tibble prints only the first 10 rows and shows the column types, and class() has tbl_df
mtcars
as_tibble(mtcars)
class(as_tibble(mtcars))

# q2
df <- data.frame(abc = 1, xyz = "a")
df$x
df[, "xyz"]
df[, c("abc", "xyz")]

tbl <- tibble(abc = 1, xyz = "a")
tbl$x
tbl[, "xyz"]
tbl[, c("abc", "xyz")]
# data.frame does partial matching, df$x gives the xyz column, and [ gives a vector for one column.
# a tibble returns NULL with a warning and [ always gives back a tibble

# q3 [[ ]] with the name stored in the object, $ will not work here
var <- "mpg"
as_tibble(mtcars)[[var]]

# q4
annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)
annoying$`1`
ggplot(annoying, aes(`1`, `2`)) + geom_point()
annoying <- mutate(annoying, `3` = `2` / `1`)
annoying <- rename(annoying, one = `1`, two = `2`, three = `3`)
annoying

# q5 enframe() turns a named vector into a tibble with name and value columns
enframe(c(a = 1, b = 2, c = 3))

# q6 tibble.max_extra_cols in the book. in the current version the option is pillar.max_extra_cols


# Chapter 8 data import
# newer readr (2.2) wants literal text wrapped in I(), it still works without but gives a warning

# q1 fields separated by |
read_delim(I("a|b\n1|2"), delim = "|")

# q2 common arguments: col_names, col_types, locale, na, quoted_na, quote, trim_ws, n_max, guess_max, progress

# q4
read_delim(I("x,y\n1,'a,b'"), delim = ",", quote = "'")

# q5
read_csv(I("a,b\n1,2,3\n4,5,6"))
# only 2 column names but 3 values per row. my version joined the last two values into b (23, 56)
read_csv(I("a,b,c\n1,2\n1,2,3,4"))
# first row is short so c is NA, second row has 4 values and the last two got joined into c (34)
read_csv(I("a,b\n\"1"))
# the quote is never closed
read_csv(I("a,b\n1,2\na,b"))
# the header is repeated as a row so both columns are read as character
read_csv(I("a;b\n1;3"))
# separated by ; so needs read_csv2()
read_csv2(I("a;b\n1;3"))

# parsing a vector
# q1 the important locale() arguments are decimal_mark, grouping_mark, date_format, time_format,
# tz and encoding

# q2 same character for both gives an error
try(locale(decimal_mark = ",", grouping_mark = ","))
locale(decimal_mark = ",")$grouping_mark
locale(grouping_mark = ".")$decimal_mark
# setting decimal_mark to "," changes grouping_mark to "." and the other way round

# q3 date_format and time_format set the default format, useful when a file always uses the same one
parse_date("01/02/2015", locale = locale(date_format = "%d/%m/%Y"))

# q5 read_csv2() is for files that use ; between fields and , as the decimal mark

# q7
d1 <- "January 1, 2010"
d2 <- "2015-Mar-07"
d3 <- "06-Jun-2017"
d4 <- c("August 19 (2015)", "July 1 (2015)")
d5 <- "12/30/14"
t1 <- "1705"
t2 <- "11:15:10.12 PM"

parse_date(d1, "%B %d, %Y")
parse_date(d2, "%Y-%b-%d")
parse_date(d3, "%d-%b-%Y")
parse_date(d4, "%B %d (%Y)")
parse_date(d5, "%m/%d/%y")
parse_time(t1, "%H%M")
parse_time(t2, "%I:%M:%OS %p")
