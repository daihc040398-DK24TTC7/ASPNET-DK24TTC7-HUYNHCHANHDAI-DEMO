using System;
using System.Security.Cryptography;
using System.Text;

namespace BanGiay
{
    public static class AuthUtil
    {
        public static string HashPassword(string plainPassword)
        {
            if (string.IsNullOrWhiteSpace(plainPassword)) return string.Empty;

            using (var sha = SHA256.Create())
            {
                var bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(plainPassword));
                var sb = new StringBuilder();
                foreach (var b in bytes)
                {
                    sb.Append(b.ToString("x2"));
                }
                return sb.ToString();
            }
        }

        public static bool VerifyPassword(string plainPassword, string storedPassword)
        {
            if (string.IsNullOrEmpty(storedPassword)) return false;
            if (storedPassword == plainPassword) return true;

            var hash = HashPassword(plainPassword);
            return string.Equals(hash, storedPassword, StringComparison.OrdinalIgnoreCase);
        }
    }
}
