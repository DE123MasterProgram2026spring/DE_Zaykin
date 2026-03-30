Sys.setlocale("LC_ALL", "en_US.UTF-8")

library(writexl)
library(tibble)
library(dplyr)

set.seed(42)

students <- tibble(
  student_id = sprintf("STU%03d", 1:30),
  full_name = c(
    "Іванов Олексій", "Петренко Марія", "Коваленко Дмитро",
    "Сидоренко Анна", "Бондаренко Артем", "Шевченко Олена",
    "Мельник Богдан", "Ткаченко Вікторія", "Кравченко Ігор",
    "Олійник Катерина", "Лисенко Максим", "Гончаренко Юлія",
    "Мороз Андрій", "Павленко Софія", "Руденко Тарас",
    "Захарченко Дарина", "Левченко Микола", "Савченко Аліна",
    "Поліщук Євген", "Кузьменко Надія", "Василенко Роман",
    "Литвиненко Ірина", "Герасименко Сергій", "Марченко Олександра",
    "Демченко Владислав", "Тимошенко Тетяна", "Остапенко Денис",
    "Клименко Валерія", "Романенко Павло", "Яковенко Людмила"
  ),
  group = rep(c("КІ-21", "КІ-22", "КН-21"), each = 10),
  faculty = rep(c("ФІТ", "ФІТ", "ФЕМ"), each = 10)
)

generate_grades <- function(student_ids, mean_exam = 75, mean_project = 78) {
  n <- length(student_ids)
  tibble(
    student_id = student_ids,
    exam_score = pmin(100, pmax(30, round(rnorm(n, mean_exam, 12)))),
    project_score = pmin(100, pmax(30, round(rnorm(n, mean_project, 10))))
  )
}

grades_math_s1 <- generate_grades(students$student_id, 72, 76)
grades_physics_s1 <- generate_grades(students$student_id, 68, 74)
grades_cs_s1 <- generate_grades(students$student_id, 80, 82)

write_xlsx(
  list(
    students = students,
    grades_math = grades_math_s1,
    grades_physics = grades_physics_s1,
    grades_cs = grades_cs_s1
  ),
  "data/semester1.xlsx"
)

grades_math_s2 <- generate_grades(students$student_id, 74, 78)
grades_physics_s2 <- generate_grades(students$student_id, 70, 76)
grades_cs_s2 <- generate_grades(students$student_id, 82, 84)

write_xlsx(
  list(
    students = students,
    grades_math = grades_math_s2,
    grades_physics = grades_physics_s2,
    grades_cs = grades_cs_s2
  ),
  "data/semester2.xlsx"
)

top_s1 <- bind_rows(
  grades_math_s1 %>% mutate(total = 0.6 * exam_score + 0.4 * project_score),
  grades_physics_s1 %>% mutate(total = 0.6 * exam_score + 0.4 * project_score),
  grades_cs_s1 %>% mutate(total = 0.6 * exam_score + 0.4 * project_score)
) %>%
  group_by(student_id) %>%
  summarise(avg_total = mean(total)) %>%
  filter(avg_total >= 75) %>%
  pull(student_id)

top_s2 <- bind_rows(
  grades_math_s2 %>% mutate(total = 0.6 * exam_score + 0.4 * project_score),
  grades_physics_s2 %>% mutate(total = 0.6 * exam_score + 0.4 * project_score),
  grades_cs_s2 %>% mutate(total = 0.6 * exam_score + 0.4 * project_score)
) %>%
  group_by(student_id) %>%
  summarise(avg_total = mean(total)) %>%
  filter(avg_total >= 75) %>%
  pull(student_id)

scholarship_s1_ids <- sample(top_s1, min(15, length(top_s1)))
scholarship_s2_ids <- sample(top_s2, min(12, length(top_s2)))

social_ids <- sample(setdiff(students$student_id, c(scholarship_s1_ids, scholarship_s2_ids)), 5)

scholarships <- bind_rows(
  tibble(
    student_id = scholarship_s1_ids,
    semester = "S1",
    scholarship_type = "academic",
    amount = sample(c(1500, 2000, 2500), length(scholarship_s1_ids), replace = TRUE)
  ),
  tibble(
    student_id = scholarship_s2_ids,
    semester = "S2",
    scholarship_type = "academic",
    amount = sample(c(1500, 2000, 2500), length(scholarship_s2_ids), replace = TRUE)
  ),
  tibble(
    student_id = rep(social_ids, 2),
    semester = rep(c("S1", "S2"), each = length(social_ids)),
    scholarship_type = "social",
    amount = 1200
  )
)

write.csv(scholarships, "data/scholarships.csv", row.names = FALSE)

cat("Дані успішно згенеровано!\n")
cat("  - data/semester1.xlsx\n")
cat("  - data/semester2.xlsx\n")
cat("  - data/scholarships.csv\n")
