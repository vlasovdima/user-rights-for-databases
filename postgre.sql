-- Создание БД (выполнять от лица пользователя postgres)
-- CREATE DATABASE edu_process;
-- \c edu_process

-- ==========================================
-- СОЗДАНИЕ ТАБЛИЦ И ДАННЫХ
-- ==========================================
CREATE TABLE groups (
    group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL
);

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    group_id INT REFERENCES groups(group_id),
    birth_date DATE
);

CREATE TABLE teachers (
    teacher_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    department VARCHAR(100)
);

CREATE TABLE subjects (
    subject_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    teacher_id INT REFERENCES teachers(teacher_id)
);

CREATE TABLE grades (
    grade_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(student_id),
    subject_id INT REFERENCES subjects(subject_id),
    grade_value INT,
    grade_date DATE
);

-- Тестовые данные
INSERT INTO groups (group_name) VALUES ('Группа А'), ('Группа Б');
INSERT INTO students (full_name, group_id, birth_date) VALUES ('Иванов И.И.', 1, '2005-04-12'), ('Петров П.П.', 2, '2004-11-20');
INSERT INTO teachers (full_name, department) VALUES ('Смирнов А.А.', 'Кафедра ИТ'), ('Кузнецова В.В.', 'Кафедра Математики');
INSERT INTO subjects (subject_name, teacher_id) VALUES ('Базы данных', 1), ('Высшая математика', 2);
INSERT INTO grades (student_id, subject_id, grade_value, grade_date) VALUES (1, 1, 5, '2023-12-15'), (2, 2, 4, '2023-12-16');

-- ==========================================
-- СОЗДАНИЕ ПРЕДСТАВЛЕНИЙ
-- ==========================================
CREATE VIEW vw_student_groups AS
SELECT s.full_name, g.group_name
FROM students s JOIN groups g ON s.group_id = g.group_id;

CREATE VIEW vw_subject_teachers AS
SELECT sub.subject_name, t.full_name AS teacher_name
FROM subjects sub JOIN teachers t ON sub.teacher_id = t.teacher_id;

CREATE VIEW vw_student_grades AS
SELECT s.full_name, sub.subject_name, gr.grade_value, gr.grade_date
FROM grades gr JOIN students s ON gr.student_id = s.student_id JOIN subjects sub ON gr.subject_id = sub.subject_id;

-- ==========================================
-- РАЗГРАНИЧЕНИЕ ПРАВ ДОСТУПА
-- ==========================================
-- Создание ролей
CREATE ROLE role_admin;
CREATE ROLE role_observer;
CREATE ROLE role_operator;

-- Разрешаем ролям использовать схему public (необходимо для PostgreSQL 15+)
GRANT USAGE ON SCHEMA public TO role_admin, role_observer, role_operator;

-- Группа 1: Администраторы (полный доступ ко всему)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_admin;

-- Группа 2: Наблюдатели (чтение одного представления)
GRANT SELECT ON vw_student_grades TO role_observer;

-- Группа 3: Операторы (чтение представлений, запись в одну таблицу)
GRANT SELECT ON vw_student_groups, vw_subject_teachers, vw_student_grades TO role_operator;
GRANT SELECT, INSERT, UPDATE ON grades TO role_operator;
GRANT USAGE, SELECT ON SEQUENCE grades_grade_id_seq TO role_operator;

-- пользователи
CREATE USER 'edu_admin'@'localhost' IDENTIFIED BY 'admin_pass';
GRANT ALL PRIVILEGES ON edu_process.* TO 'edu_admin'@'localhost';

CREATE USER 'edu_observer'@'localhost' IDENTIFIED BY 'obs_pass';
GRANT SELECT ON edu_process.vw_student_grades TO 'edu_observer'@'localhost';

CREATE USER 'edu_operator'@'localhost' IDENTIFIED BY 'op_pass';
GRANT SELECT ON edu_process.vw_student_groups TO 'edu_operator'@'localhost';
GRANT SELECT ON edu_process.vw_subject_teachers TO 'edu_operator'@'localhost';
GRANT SELECT ON edu_process.vw_student_grades TO 'edu_operator'@'localhost';
GRANT SELECT, INSERT, UPDATE ON edu_process.grades TO 'edu_operator'@'localhost';

FLUSH PRIVILEGES;
