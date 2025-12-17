using System;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace FormMovimientos.clases
{
    /// <summary>
    /// Maneja la conexión a la base de datos INVENTARIO_GRANIX
    /// </summary>
    public static class DatabaseConnection
    {
        // 🔒 CADENA DE CONEXIÓN DEFINITIVA
        private static readonly string connectionString =
            @"Data Source=DESKTOP-HD0VV4B\SQLEXPRESS01;
              Initial Catalog=INVENTARIO_GRANIX;
              Integrated Security=True;
              TrustServerCertificate=True;";

        /// <summary>
        /// Retorna una nueva conexión SQL
        /// </summary>
        public static SqlConnection GetConnection()
        {
            return new SqlConnection(connectionString);
        }

        /// <summary>
        /// Prueba la conexión con la base de datos
        /// </summary>
        public static bool TestConnection()
        {
            try
            {
                using (SqlConnection conn = GetConnection())
                {
                    conn.Open();
                    return true;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "❌ Error de conexión a la base de datos\n\n" +
                    ex.Message +
                    "\n\nVerifica:\n" +
                    "1. SQL Server (SQLEXPRESS01) está ejecutándose\n" +
                    "2. La base de datos INVENTARIO_GRANIX existe\n" +
                    "3. Estás ejecutando el proyecto en esta misma computadora",
                    "Error de Conexión",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );

                return false;
            }
        }

        /// <summary>
        /// Devuelve la cadena de conexión actual
        /// </summary>
        public static string GetConnectionString()
        {
            return connectionString;
        }
    }
}
