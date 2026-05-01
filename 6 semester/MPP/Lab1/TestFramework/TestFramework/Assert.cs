using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq.Expressions;

namespace TestFramework
{
    public static class Assert
    {
        // Вспомогательный метод для генерации ошибки
        private static void ThrowFail(string userMessage, string defaultMessage)
        {
            string msg = string.IsNullOrEmpty(userMessage) ? defaultMessage : $"{defaultMessage} {userMessage}";
            throw new TestAssertionException(msg);
        }

        #region Стандартные проверки

        public static void AreEqual(object expected, object actual, string message = "")
        {
            if (!object.Equals(expected, actual))
                ThrowFail(message, $"Ожидалось: <{expected}>, но было: <{actual}>.");
        }

        public static void IsTrue(bool condition, string message = "")
        {
            if (!condition) ThrowFail(message, "Ожидалось: True, но было: False.");
        }

        public static void IsFalse(bool condition, string message = "")
        {
            if (condition) ThrowFail(message, "Ожидалось: False, но было: True.");
        }

        public static void IsNull(object obj, string message = "")
        {
            if (obj != null) ThrowFail(message, "Ожидалось: null, но объект не пуст.");
        }

        public static void IsNotNull(object obj, string message = "")
        {
            if (obj == null) ThrowFail(message, "Ожидалось: не null, но пришел null.");
        }

        public static void StringContains(string fullString, string substring, string message = "")
        {
            if (fullString == null || !fullString.Contains(substring))
                ThrowFail(message, $"Строка \"{fullString}\" не содержит \"{substring}\".");
        }

        public static T Throws<T>(Action action, string message = "") where T : Exception
        {
            try { action(); }
            catch (T ex) { return ex; }
            catch (Exception ex)
            {
                ThrowFail(message, $"Ожидалось исключение {typeof(T).Name}, но было {ex.GetType().Name}.");
            }
            ThrowFail(message, $"Ожидалось исключение {typeof(T).Name}, но оно не возникло.");
            return null;
        }

        #endregion

        #region Продвинутая проверка (Expression Trees)

        public static void That(Expression<Func<bool>> expression, string message = "")
        {
            var func = expression.Compile();
            bool result = func();

            if (!result)
            {
                string details = DeconstructExpression(expression.Body);
                ThrowFail(message, $"Условие не выполнено! [ {details} ]");
            }
        }

        private static string DeconstructExpression(Expression expr)
        {
            if (expr is BinaryExpression binary)
            {
                var leftValue = GetValue(binary.Left);
                var rightValue = GetValue(binary.Right);
                string op = GetOperatorSymbol(binary.NodeType);

                return $"{leftValue} {op} {rightValue} (структура: {binary.Left} {op} {binary.Right})";
            }

            return $"{expr} => {GetValue(expr)}";
        }

     
        private static object GetValue(Expression expr)
        {
            try
            {
                var objectMember = Expression.Convert(expr, typeof(object));
                var getterLambda = Expression.Lambda<Func<object>>(objectMember);
                return getterLambda.Compile()();
            }
            catch
            {
                return "???"; 
            }
        }

        private static string GetOperatorSymbol(ExpressionType type)
        {
            return type switch
            {
                ExpressionType.Equal => "==",
                ExpressionType.NotEqual => "!=",
                ExpressionType.GreaterThan => ">",
                ExpressionType.GreaterThanOrEqual => ">=",
                ExpressionType.LessThan => "<",
                ExpressionType.LessThanOrEqual => "<=",
                ExpressionType.AndAlso => "&&",
                ExpressionType.OrElse => "||",
                _ => type.ToString()
            };
        }

        #endregion
    }
}