using System;
using System.Collections;
using System.Collections.Generic;
using TestFramework;

namespace TestFramework
{
  
    public static class Assert
    {
        private static void ThrowFail(string userMessage, string defaultMessage)
        {
            string msg = string.IsNullOrEmpty(userMessage) ? defaultMessage : $"{defaultMessage} {userMessage}";
            throw new TestAssertionException(msg);
        }

        // 1.
        public static void AreEqual(object expected, object actual, string message = "")
        {
            if (!object.Equals(expected, actual))
            {
                ThrowFail(message, $"Ожидалось: <{expected}>, но было: <{actual}>.");
            }
        }
        // 2.
        public static void AreNotEqual(object notExpected, object actual, string message = "")
        {
            if (object.Equals(notExpected, actual))
            {
                ThrowFail(message, $"Ожидалось любое значение кроме: <{notExpected}>, но пришло именно оно.");
            }
        }

        // 3. 
        public static void IsTrue(bool condition, string message = "")
        {
            if (!condition)
            {
                ThrowFail(message, "Ожидалось: True, но было: False.");
            }
        }

        // 4. 
        public static void IsFalse(bool condition, string message = "")
        {
            if (condition)
            {
                ThrowFail(message, "Ожидалось: False, но было: True.");
            }
        }

        // 5. 
        public static void IsNull(object obj, string message = "")
        {
            if (obj != null)
            {
                ThrowFail(message, "Ожидалось: null, но объект не пуст.");
            }
        }

        // 6. 
        public static void IsNotNull(object obj, string message = "")
        {
            if (obj == null)
            {
                ThrowFail(message, "Ожидалось: объект не null, но пришел null.");
            }
        }

        // 7.
        public static void StringContains(string fullString, string substring, string message = "")
        {
            if (fullString == null || !fullString.Contains(substring))
            {
                ThrowFail(message, $"Строка \"{fullString}\" не содержит подстроку \"{substring}\".");
            }
        }

        // 8. 
        public static void CollectionContains<T>(IEnumerable<T> collection, T element, string message = "")
        {
            bool found = false;
            foreach (var item in collection)
            {
                if (object.Equals(item, element))
                {
                    found = true;
                    break;
                }
            }

            if (!found)
            {
                ThrowFail(message, $"Коллекция не содержит элемент <{element}>.");
            }
        }

        // 9.
        public static void IsEmpty(IEnumerable collection, string message = "")
        {
            var enumerator = collection.GetEnumerator();
            if (enumerator.MoveNext()) 
            {
                ThrowFail(message, "Коллекция должна быть пустой, но в ней есть элементы.");
            }
        }

        // 10.
        public static void Fail(string message = "Тест принудительно провален.")
        {
            throw new TestAssertionException(message);
        }

        // 11.

        public static T Throws<T>(Action action, string message = "") where T : Exception
        {
            try
            {
                action(); 
            }
            catch (T ex)
            {
                return ex;
            }
            catch (Exception ex)
            {
                ThrowFail(message, $"Ожидалось исключение типа <{typeof(T).Name}>, но было выброшено <{ex.GetType().Name}>.");
                return null;
            }

            ThrowFail(message, $"Ожидалось исключение типа <{typeof(T).Name}>, но исключение не было выброшено.");
            return null;
        }
    }
}