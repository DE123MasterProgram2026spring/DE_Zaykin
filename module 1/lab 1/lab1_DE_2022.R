
# Лабораторна робота 1 ----------------------------------------------------


# Пакет dplyr 1.0.0 -------------------------------------------------------

library(dplyr)

# Основні дієслова

mutate()      # зміна даних
select()      # вибір стовпців
filter()      # фільтрація рядків
summarise()   # підсумування даних
arrange()     # впорядкування даних




# mutate() ------------------------------------------------------------------

starwars %>% 
  filter(species == "Droid")   # фільтруємо тільки дроїдів

x <- 1

sqrt(sin(cos(x)))

x |> 
  cos() |> 
  sin() |> 
  sqrt()

# df <- starwars

# select -------------------------------------------------------------

starwars |>  
  select(name, ends_with("color"))   # вибираємо ім'я і стовпці, які закінчуються на "color"



starwars %>%
  filter(species == "Droid") %>%
  select(name, ends_with("color"))   # фільтруємо дроїдів і вибираємо певні стовпці



# mutate ------------------------------------------------------------------

starwars %>% 
  mutate(name, bmi = mass / (height / 100)^2) %>%   # обчислюємо індекс маси тіла (BMI)
  select(name:mass, bmi)   # вибираємо ім'я, масу і новий стовпець BMI



# Нові функції
# select(), rename_with(), relocate() ---------------------------------------



#devtools::install_github("tidyverse/dplyr")
library(dplyr, warn.conflicts = FALSE)

# rename
# Перейменувати стовпці для усунення дублювання їхніх імен
df1 <- tibble(a = 1:5, a = 5:1, .name_repair = "minimal")
df1

class(df1)

df1 %>% rename(b = 2)   # перейменовуємо другий стовпець у "b"

# select
# звернення до стовпців за типом
df2 <- tibble(x1 = 1, x2 = "a", x3 = 2, y1 = "b", y2 = 3, y3 = "c", y4 = 4)

# числові стовпці
df2 %>% select(is.numeric)

# НЕ текстові стовпці
df2 %>% select(!is.character)

# змішаний тип звернення
# числові стовпці, назва яких починається на "x"
df2 %>% select(starts_with("x") & is.numeric)


# вибір полів за допомогою функцій any_of та all_of

vars <- c("x1", "x2", "y1", "z")
df2 %>% select(any_of(vars)) # обирає ті стовпці, які є у векторі vars

df2 %>% select(all_of(vars)) # повертає похибку, якщо хочаб одне поле не присутнє у vars


# функція rename_with
df2 %>% rename_with(toupper)   # перетворюємо назви стовпців у великі літери

df2 %>% rename_with(toupper, starts_with("x"))   # змінюємо тільки ті стовпці, що починаються на "x"

df2 %>% rename_with(toupper, is.numeric)   # змінюємо назви тільки числових стовпців


# relocate для зміни порядку стовпців
df3 <- tibble(w = 0, x = 1, y = "a", z = "b")

# перемістити стовпці "y", "z" на початок
df3 %>% relocate(y, z)

# перемістити текстові стовпці на початок
df3 %>% relocate(is.character)

# помістити стовпець "w" після "y"
df3 %>% relocate(w, .after = y)

# помістити стовпець "w" перед "y"
df3 %>% relocate(w, .before = y)

# перемістити "w" в кінець
df3 %>% relocate(w, .after = last_col())




# across() ------------------------------------------------------------------



# створюємо тестовий датафрейм
df <- tibble(g1 = as.factor(sample(letters[1:4],size = 10, replace = T )),
             g2 = as.factor(sample(LETTERS[1:3],size = 10, replace = T )),
             a  = runif(10, 1, 10),
             b  = runif(10, 10, 20),
             c  = runif(10, 15, 30),
             d  = runif(10, 1, 50))

# про що йтиметься
## копіювання коду, коли потрібно 
## провести одну й ту ж операцію з різними функціями
df %>% 
  group_by(g1, g2) %>% 
  summarise(a = mean(a), b = mean(b), c = mean(c), d = mean(c))

# новий спосіб
## тепер для таких перетворень можна
## використовувати той самий синтаксис, що і в select()
### обчислюємо середнє по стовпцях від a до d
df %>% 
  group_by(g1, g2) %>% 
  summarise(across(a:d, mean))

### або обчислюємо середнє, вибравши всі числові стовпці
df %>% 
  group_by(g1, g2) %>% 
  summarise(across(is.numeric, mean))

# ##############################
# Простий приклад
# аргументи функції across

## .cols - перший аргумент, вибір стовпців за позицією, іменем, функцією, типом даних або комбінуванням будь-яких способів
## .fns - другий аргумент, функція або список функцій, які потрібно застосувати до кожного стовпця

## обчислюємо кількість унікальних значень у текстових полях
starwars %>% 
  summarise(across(is.character, n_distinct))

## приклад із фільтрацією даних
starwars %>% 
  group_by(species) %>% 
  filter(n() > 1) %>% 
  summarise(across(c(sex, gender, homeworld), n_distinct))

## комбінуємо across з іншими обчисленнями
starwars %>% 
  group_by(homeworld) %>% 
  filter(n() > 1) %>% 
  summarise(across(is.numeric, mean, na.rm = TRUE), 
            n = n())

# ##############################
# Чому across краще за попередні функції з суфіксами _at, _if, _all

## 1. across дозволяє комбінувати різні обчислення всередині одного summarise 
## приклад зі статті
df %>%
  group_by(g1, g2) %>% 
  summarise(
    across(is.numeric, mean), 
    across(is.factor, nlevels),
    n = n(), 
  )

## робочий приклад
starwars %>% 
  group_by(species) %>% 
  summarise(across(is.character, n_distinct), 
            across(is.numeric, mean), 
            across(is.list, length), 
            n = n()
  )

## 2. зменшує кількість необхідних функцій у dplyr, що полегшує їх запам'ятовування
## 3. об'єднує можливості функцій з суфіксами _if, _at, і дозволяє об'єднувати їх можливості
## 4. across не вимагає від вас використання функції vars для вказування потрібних стовпців, як це було раніше

# ##############################
# переклад старого коду на across

## для перекладу функцій з суфіксами _at, _if, _all використовуйте такі правила
### в across першим аргументом буде:
### Для *_if() старий другий аргумент.
### Для *_at() старий другий аргумент з видаленим викликом vars().
### Для *_all(), як перший аргумент передайте функцію everything()

## приклади
df <- tibble(y_a  = runif(10, 1, 10),
             y_b  = runif(10, 10, 20),
             x    = runif(10, 15, 30),
             d    = runif(10, 1, 50))

### з _if в across
df %>% mutate_if(is.numeric, mean, na.rm = TRUE)
# ->
df %>% mutate(across(is.numeric, mean, na.rm = TRUE))

### з _at в across
df %>% mutate_at(vars(c(x, starts_with("y"))), mean, na.rm = TRUE)
# ->
df %>% mutate(across(c(x, starts_with("y")), mean, na.rm = TRUE))

### з _all в across
df %>% mutate_all(mean, na.rm = TRUE)
# ->
df %>% mutate(across(everything(), mean, na.rm = TRUE))


# Перебирання рядків функцією rowwise() -----------------------------------


# test data
df <- tibble(
  student_id = 1:4, 
  test1 = 10:13, 
  test2 = 20:23, 
  test3 = 30:33, 
  test4 = 40:43
)

df

# спроба обчислити середню оцінку за студентом
df %>% mutate(avg = mean(c(test1, test2, test3, test4)))

# використовуємо rowwise для перетворення фрейма
rf <- rowwise(df, student_id)
rf

rf %>% mutate(avg = mean(c(test1, test2, test3, test4)))

# те ж саме з використанням c_across
rf %>% mutate(avg = mean(c_across(starts_with("test"))))

# ###########################
# деякі арифметичні операції векторизировані за замовчанням
df %>% mutate(total = test1 + test2 + test3 + test4)

# цей підхід можна використовувати для обчислення середнього
df %>% mutate(avg = (test1 + test2 + test3 + test4) / 4)

# також можна використовувати деякі спеціальні функції
# для обчислення деяких статистик
df %>% mutate(
  min = pmin(test1, test2, test3, test4), 
  max = pmax(test1, test2, test3, test4), 
  string = paste(test1, test2, test3, test4, sep = "-")
)
# всі векторизовані функції працюватимуть швидше ніж rowwise
# але rowwise дозволяє векторизувати будь-яку функцію

# ###################################
# робота зі стовпцями і списками
df <- tibble(
  x = list(1, 2:3, 4:6),
  y = list(TRUE, 1, "a"),
  z = list(sum, mean, sd)
)

# мм можемо перебором обробити кожен список
df %>% 
  rowwise() %>% 
  summarise(
    x_length = length(x),
    y_type = typeof(y),
    z_call = z(1:5)
  )

# ##################################
# симуляція випадкових даних
df <- tribble(
  ~id, ~ n, ~ min, ~ max,
  1,   3,     0,     1,
  2,   2,    10,   100,
  3,   2,   100,  1000,
)

# використовуємо rowwise для симуляції даних
df %>%
  rowwise(id) %>%
  mutate(data = list(runif(n, min, max)))

df %>%
  rowwise(id) %>%
  summarise(x = runif(n, min, max))

# ##################################
# функція nest_by дозволяє створювати стовпці списки
by_cyl <- mtcars %>% nest_by(cyl)
by_cyl

# такий підхід зручно використовувати при побудові лінійної моделі
# використовуємо mutate для підгонки модели під кожну групу даних
by_cyl <- by_cyl %>% mutate(model = list(lm(mpg ~ wt, data = data)))
by_cyl

#тепер за допомогою summarise 
# можна вилучати зведення або коефіцієнти побудованої моделі
by_cyl %>% summarise(broom::glance(model))
by_cyl %>% summarise(broom::tidy(model))



# summarise() -------------------------------------------------------------

#devtools::install_github("tidyverse/dplyr")
library(dplyr)

# Основні зміни
# тепер sumarise може повернути вектор довільної довжини
# дата фрейм любой размерности

# #######################################################
# тестовs дані
# #######################################################
df <- tibble(
  grp = rep(1:2, each = 5), 
  x = c(rnorm(5, -0.25, 1), rnorm(5, 0, 1.5)),
  y = c(rnorm(5, 0.25, 1), rnorm(5, 0, 0.5)),
)

df

# отримаємо мінімальні та максимальні значення для кожної 
# групи і помістимо ці значення в рядки

df %>% 
  group_by(grp) %>% 
  summarise(rng = range(x))

## функція range повертає вектор довжиною 2
range(df$x)
## але функція summarise розгортає його,
## наводячи кожне зі значень, що повертаються в новий рядок

# те ж саме, але для стовпців
df %>% 
  group_by(grp) %>% 
  summarise(tibble(min = min(x), mean = mean(x)))

# #######################################################
# Розрахунок квантілєй
# #######################################################
df %>% 
  group_by(grp) %>% 
  summarise(x = quantile(x, c(0.25, 0.5, 0.75)), q = c(0.25, 0.5, 0.75))

# можемо уникнути дублювання коду і написати функцію для обчислення квантиля
quibble <- function(x, q = c(0.25, 0.5, 0.75)) {
  tibble(x = quantile(x, q), q = q)
}

# використовуємо власну функцію у summarise
df %>% 
  group_by(grp) %>% 
  summarise(quibble(x, c(0.25, 0.5, 0.75)))

# допрацюємо функцію таким чином 
# щоб назви стовпця підтягнулися з аргумена
quibble2 <- function(x, q = c(0.25, 0.5, 0.75)) {
  tibble("{{ x }}" := quantile(x, q), "{{ x }}_q" := q)
}

df %>% 
  group_by(grp) %>% 
  summarise(quibble2(x, c(0.25, 0.5, 0.75)))


# ми не надавали імена нових стовпців всередині summarise
# тому що якщо функція повертає об'єкт складної структури
# ми отримаємо вкладені дата фрейми

out <- df %>% 
  group_by(grp) %>% 
  summarise(quantile = quibble2(y, c(0.25, 0.75)))

str(out)



# звертаємось до вкладеного фрейму
out$y
# або до його стовпців
# за змістом така конструкція нагадує об'єднані імена стовпців в електронних таблицях
out$quantile$y_q
# summarise + rowwise

# ця комбінація функцій тепер може замінити purrr і apply
tibble(path = dir(pattern = "\\.csv$")) %>% 
  rowwise(path) %>% 
  summarise(readr::read_csv(path))

# #######################################################
# Попередні підходи
# #######################################################
# обчислюємо квантилі
df %>% 
  group_by(grp) %>% 
  summarise(y = list(quibble(y, c(0.25, 0.75)))) %>% 
  tidyr::unnest(y)
df %>% 
  group_by(grp) %>% 
  do(quibble(.$y, c(0.25, 0.75)))

# summarise() -------------------------------------------------------------
# summarise + .groups
starwars %>% 
  group_by(homeworld, species) %>% 
  summarise(n = n())
## аргумент .groups
### .groups = "drop_last" видалить останню групу
### .groups = "drop" видалить все групування
### .groups = "keep" зберегти все групування
### .groups = "rowwise" розділить фрейм на групи як rowwise()
# rows_*()
## rows_update(x, y) оновлює рядки в таблиці x знайдені в таблиці y
## rows_patch(x, y) працює аналогічно rows_update() але замінює тільки NA
## rows_insert(x, y) додає рядки в таблицю x з таблиці y
## rows_upsert(x, y) оновлює знайдені рядки в x і додає не знайдені з таблиці y
## rows_delete(x, y) видаляє рядки з x знайдені в таблиці y.
# Створюємо тестові дані
df <- tibble(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)
df
new <- tibble(a = c(4, 5), b = c("d", "e"), c = c(3.5, 4.5))
new
# Базові приклади
## додаємо нові рядки
df %>% rows_insert(new)
## row_insert поверне помилку якщо ми спробуємо додати вже існуючий рядок
df %>% rows_insert(tibble(a = 3, b = "c"))
## якщо ви хочете оновити існуюче значення необхідно використовувати row_update
df %>% rows_update(tibble(a = 3, b = "c"))
## але rows_update поверне помилку якщо ви спробуєте оновити неіснуюче значення
df %>% rows_update(tibble(a = 4, b = "d"))
## rows_patch заповнить тільки пропущені значення по ключу
df %>% 
  rows_patch(tibble(a = 2:3, b = "B"))
## rows_upsert також ви можете додавати нові і замінювати існуючі значення 
## функцією rows_upsert
df %>% 
  rows_upsert(tibble(a = 3, b = "c")) %>% 
  rows_upsert(tibble(a = 4, b = "d"))
# ################################
# РОЗБЕРЕМО аргументи трохи більш детально
set.seed(555)
# менеджери
managers <- c("Paul", "Alex", "Tim", "Bill", "John")
# товари
products <- tibble(name  = paste0("product_", LETTERS), 
                   price = round(runif(n = length(LETTERS), 100, 400), 0))
# функція генерації куплених товарів
prod_list <- function(prod_list, size_min, size_max) {
  
  prod <- tibble(product = sample(prod_list, 
                                  size = round(runif(1, size_min, size_max), 0) ,
                                  replace = F))
  return(prod)
}
# генеруємо продажі
sales <- tibble(id         = 1:200,
                manager_id = sample(managers, size = 200, replace = T),
                refund     = FALSE,
                refund_sum = 0)
# генеруємо списки куплених товарів
sale_proucts <-
  sales %>%
  rowwise(id) %>%
  summarise(prod_list(products$name, 1, 6)) %>%
  left_join(products, by = c("product" = "name"))
# об'єднуємо продажі з товарами
sales <- left_join(sales, sale_proucts, by = "id")
# повернення
refund <- sample_n(sales, 25) %>%
  mutate( refund = TRUE,
          refund_sum = price * 0.9) %>%
  select(-price, -manager_id) 
# відмічаємо повернення в таблиці продажів
sales %>%
  rows_update(refund)
# аргумент by
result <-
  sales %>%
  rows_update(refund, by = c("id", "product"))



