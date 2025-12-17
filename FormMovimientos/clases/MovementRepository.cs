using System;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace FormMovimientos.clases
{
    public static class MovementRepository
    {
        public static bool RegisterMovement(int productoId, string tipoMovimiento,
            int cantidad, string motivo, DateTime fecha, int usuarioId, int almacenId)
        {
            SqlConnection connection = null;
            SqlTransaction transaction = null;

            try
            {
                connection = DatabaseConnection.GetConnection();
                connection.Open();
                transaction = connection.BeginTransaction();

                // 1. Registrar movimiento
                string queryMovimiento = @"
                    INSERT INTO Movimientos 
                    (codigo, tipo_movimiento, producto_id, almacen_origen_id, cantidad, motivo, fecha_movimiento, usuario_registro_id, estado)
                    VALUES 
                    (@codigo, @tipo, @productoId, @almacenId, @cantidad, @motivo, @fecha, @usuarioId, 'Completado')";

                using (SqlCommand cmdMovimiento = new SqlCommand(queryMovimiento, connection, transaction))
                {
                    string codigoMovimiento = "MOV-" + DateTime.Now.ToString("yyyyMMddHHmmss");

                    cmdMovimiento.Parameters.AddWithValue("@codigo", codigoMovimiento);
                    cmdMovimiento.Parameters.AddWithValue("@tipo", tipoMovimiento);
                    cmdMovimiento.Parameters.AddWithValue("@productoId", productoId);
                    cmdMovimiento.Parameters.AddWithValue("@almacenId", almacenId);
                    cmdMovimiento.Parameters.AddWithValue("@cantidad", cantidad);
                    cmdMovimiento.Parameters.AddWithValue("@motivo", motivo);
                    cmdMovimiento.Parameters.AddWithValue("@fecha", fecha);
                    cmdMovimiento.Parameters.AddWithValue("@usuarioId", usuarioId);

                    cmdMovimiento.ExecuteNonQuery();
                }

                // 2. Actualizar stock
                string queryStock;
                if (tipoMovimiento == "Entrada")
                {
                    queryStock = "UPDATE Productos SET stock_actual = stock_actual + @cantidad WHERE id = @productoId";
                }
                else // Salida
                {
                    queryStock = "UPDATE Productos SET stock_actual = stock_actual - @cantidad WHERE id = @productoId";
                }

                using (SqlCommand cmdStock = new SqlCommand(queryStock, connection, transaction))
                {
                    cmdStock.Parameters.AddWithValue("@cantidad", cantidad);
                    cmdStock.Parameters.AddWithValue("@productoId", productoId);
                    cmdStock.ExecuteNonQuery();
                }

                transaction.Commit();
                return true;
            }
            catch (Exception ex)
            {
                if (transaction != null)
                {
                    try { transaction.Rollback(); } catch { }
                }

                MessageBox.Show(
                    "Error al registrar movimiento:\n\n" + ex.Message,
                    "Error de Base de Datos",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                return false;
            }
            finally
            {
                if (transaction != null) transaction.Dispose();
                if (connection != null && connection.State == System.Data.ConnectionState.Open)
                {
                    connection.Close();
                    connection.Dispose();
                }
            }
        }
    }
}