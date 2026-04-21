-- Создание БД и переключение на нее
CREATE DATABASE IF NOT EXISTS edu_process;
USE edu_process;

-- СОЗДАНИЕ ТАБЛИЦ
-- 
-- 1. Таблица учебных групп
CREATE TABLE groups (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL
);

-- 2. Таблица студентов
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    group_id INT,
    birth_date DATE,
    FOREIGN KEY (group_id) REFERENCES groups(group_id)
);

-- 3. Таблица преподавателей
CREATE TABLE teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    department VARCHAR(100)
);

-- 4. Таблица дисциплин
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    teacher_id INT,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
);

-- 5. Таблица оценок
CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    grade_value INT,
    grade_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- ==========================================
-- ДОБАВЛЕНИЕ ТЕСТОВЫХ ДАННЫХ
-- ==========================================
INSERT INTO groups (group_name) VALUES ('Группа А'), ('Группа Б');
INSERT INTO students (full_name, group_id, birth_date) VALUES ('Иванов И.И.', 1, '2005-04-12'), ('Петров П.П.', 2, '2004-11-20');
INSERT INTO teachers (full_name, department) VALUES ('Смирнов А.А.', 'Кафедра ИТ'), ('Кузнецова В.В.', 'Кафедра Математики');
INSERT INTO subjects (subject_name, teacher_id) VALUES ('Базы данных', 1), ('Высшая математика', 2);
INSERT INTO grades (student_id, subject_id, grade_value, grade_date) VALUES (1, 1, 5, '2023-12-15'), (2, 2, 4, '2023-12-16');

-- ==========================================
-- СОЗДАНИЕ ПРЕДСТАВЛЕНИЙ
-- ==========================================
-- 1. Список студентов с группами
CREATE VIEW vw_student_groups AS
SELECT s.full_name, g.group_name
FROM students s
JOIN groups g ON s.group_id = g.group_id;

-- 2. Список дисциплин с преподавателями
CREATE VIEW vw_subject_teachers AS
SELECT sub.subject_name, t.full_name AS teacher_name
FROM subjects sub
JOIN teachers t ON sub.teacher_id = t.teacher_id;

-- 3. Сведения об оценках
CREATE VIEW vw_student_grades AS
SELECT s.full_name, sub.subject_name, gr.grade_value, gr.grade_date
FROM grades gr
JOIN students s ON gr.student_id = s.student_id
JOIN subjects sub ON gr.subject_id = sub.subject_id;


-- РАЗГРАНИЧЕНИЕ ПРАВ ДОСТУПА
-- 
-- Группа 1: Администраторы (полный доступ)
CREATE USER 'edu_admin'@'%' IDENTIFIED BY 'admin_pass';
GRANT ALL PRIVILEGES ON edu_process.* TO 'edu_admin'@'%';

-- Группа 2: Наблюдатели (только чтение одного представления)
CREATE USER 'edu_observer'@'%' IDENTIFIED BY 'obs_pass';
GRANT SELECT ON edu_process.vw_student_grades TO 'edu_observer'@'%';

-- Группа 3: Операторы (чтение представлений, запись в одну таблицу)
CREATE USER 'edu_operator'@'%' IDENTIFIED BY 'op_pass';
GRANT SELECT ON edu_process.vw_student_groups TO 'edu_operator'@'%';
GRANT SELECT ON edu_process.vw_subject_teachers TO 'edu_operator'@'%';
GRANT SELECT ON edu_process.vw_student_grades TO 'edu_operator'@'%';
GRANT SELECT, INSERT, UPDATE ON edu_process.grades TO 'edu_operator'@'%';

-- Применение новых прав
FLUSH PRIVILEGES;
