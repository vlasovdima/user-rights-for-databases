import psycopg2
from psycopg2 import errors

# Настройки подключения к БД [cite: 33]
DB_CONFIG = {
    'dbname': 'edu_process',
    'host': 'localhost',
    'port': '5432'
}

def test_access(user, password):
    print(f"\n--- Тестирование пользователя: {user} ---")
    try:
        conn = psycopg2.connect(**DB_CONFIG, user=user, password=password)
        conn.autocommit = True
        cursor = conn.cursor()

        # Тест 1: Чтение представления vw_student_grades (Разрешено всем 3 группам)
        try:
            cursor.execute("SELECT * FROM vw_student_grades LIMIT 1;")
            print("УСПЕХ: Чтение vw_student_grades выполнено.")
        except Exception as e:
            print(f"ОТКАЗ: Чтение vw_student_grades запрещено. ({e})")

        # Тест 2: Запись в таблицу grades (Разрешено Админу и Оператору, запрещено Наблюдателю) [cite: 92, 96]
        try:
            cursor.execute("INSERT INTO grades (student_id, subject_id, grade_value, grade_date) VALUES (1, 2, 5, '2023-12-20');")
            print("УСПЕХ: Запись в таблицу grades выполнена.")
        except errors.InsufficientPrivilege as e:
            print("ОТКАЗ: Запись в таблицу grades запрещена (Ожидаемое поведение).")
            conn.rollback() # Сброс транзакции после ошибки

        # Тест 3: Удаление из таблицы students (Разрешено только Админу) [cite: 87, 91, 97]
        try:
            cursor.execute("DELETE FROM students WHERE student_id = 999;")
            print("УСПЕХ: Доступ к удалению из students предоставлен.")
        except errors.InsufficientPrivilege as e:
            print("ОТКАЗ: Удаление из таблицы students запрещено (Ожидаемое поведение).")
            conn.rollback()

        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Ошибка подключения: {e}")

if __name__ == "__main__":
    # Тест под Наблюдателем (Группа 2)
    test_access('edu_observer', 'obs_pass')
    
    # Тест под Оператором (Группа 3)
    test_access('edu_operator', 'op_pass')
