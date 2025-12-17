using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace FormMovimientos.clases
{
    public static class ProductRepository
    {
        // =====================================================
        // OBTENER CATEGORÍAS (ComboBox)
        // =====================================================
        public static DataTable GetCategories()
        {
            DataTable categorias = new DataTable();

            try
            {
                using (SqlConnection connection = DatabaseConnection.GetConnection())
                {
                    connection.Open();

                    string query = @"
                        SELECT 
                            id,
                            nombre
                        FROM Categorias
                        WHERE estado = 1
                        ORDER BY nombre";

                    using (SqlDataAdapter adapter = new SqlDataAdapter(query, connection))
                    {
                        adapter.Fill(categorias);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Error al cargar categorías:\n\n" + ex.Message,
                    "Base de Datos",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }

            return categorias;
        }

        // =====================================================
        // OBTENER TODOS LOS PRODUCTOS (DataGridView)
        // =====================================================
        public static List<Product> GetAllProducts()
        {
            List<Product> productos = new List<Product>();

            try
            {
                using (SqlConnection connection = DatabaseConnection.GetConnection())
                {
                    connection.Open();

                    string query = @"
                        SELECT 
                            p.id,
                            p.codigo,
                            p.nombre,
                            c.nombre AS categoria,
                            p.precio_venta,
                            p.stock_actual
                        FROM Productos p
                        INNER JOIN Categorias c ON p.categoria_id = c.id
                        WHERE p.es_activo = 1
                        ORDER BY p.nombre";

                    using (SqlCommand command = new SqlCommand(query, connection))
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            productos.Add(new Product
                            {
                                Id = Convert.ToInt32(reader["id"]),
                                Codigo = reader["codigo"].ToString(),
                                Nombre = reader["nombre"].ToString(),
                                Categoria = reader["categoria"].ToString(),
                                Precio = Convert.ToDecimal(reader["precio_venta"]),
                                Stock = Convert.ToInt32(reader["stock_actual"])
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Error al cargar productos:\n\n" + ex.Message,
                    "Base de Datos",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }

            return productos;
        }

        // =====================================================
        // INSERTAR PRODUCTO
        // =====================================================
        public static bool InsertProduct(
            string codigo,
            string nombre,
            int categoriaId,
            decimal precioCosto,
            decimal precioVenta,
            int stock)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnection.GetConnection())
                {
                    connection.Open();

                    string query = @"
                        INSERT INTO Productos
                        (
                            codigo,
                            nombre,
                            categoria_id,
                            unidad_medida_id,
                            precio_costo,
                            precio_venta,
                            stock_actual,
                            es_activo,
                            es_vendible,
                            usuario_creacion,
                            fecha_creacion
                        )
                        VALUES
                        (
                            @codigo,
                            @nombre,
                            @categoriaId,
                            1,
                            @precioCosto,
                            @precioVenta,
                            @stock,
                            1,
                            1,
                            1,
                            GETDATE()
                        )";

                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        command.Parameters.AddWithValue("@codigo", codigo);
                        command.Parameters.AddWithValue("@nombre", nombre);
                        command.Parameters.AddWithValue("@categoriaId", categoriaId);
                        command.Parameters.AddWithValue("@precioCosto", precioCosto);
                        command.Parameters.AddWithValue("@precioVenta", precioVenta);
                        command.Parameters.AddWithValue("@stock", stock);

                        return command.ExecuteNonQuery() > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Error al insertar producto:\n\n" + ex.Message,
                    "Base de Datos",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                return false;
            }
        }

        // =====================================================
        // ACTUALIZAR PRODUCTO
        // =====================================================
        public static bool UpdateProduct(
            string codigoOriginal,
            string codigoNuevo,
            string nombre,
            int categoriaId,
            decimal precioCosto,
            decimal precioVenta,
            int stock)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnection.GetConnection())
                {
                    connection.Open();

                    string query = @"
                        UPDATE Productos SET
                            codigo = @codigoNuevo,
                            nombre = @nombre,
                            categoria_id = @categoriaId,
                            precio_costo = @precioCosto,
                            precio_venta = @precioVenta,
                            stock_actual = @stock,
                            fecha_actualizacion = GETDATE()
                        WHERE codigo = @codigoOriginal
                          AND es_activo = 1";

                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        command.Parameters.AddWithValue("@codigoNuevo", codigoNuevo);
                        command.Parameters.AddWithValue("@nombre", nombre);
                        command.Parameters.AddWithValue("@categoriaId", categoriaId);
                        command.Parameters.AddWithValue("@precioCosto", precioCosto);
                        command.Parameters.AddWithValue("@precioVenta", precioVenta);
                        command.Parameters.AddWithValue("@stock", stock);
                        command.Parameters.AddWithValue("@codigoOriginal", codigoOriginal);

                        return command.ExecuteNonQuery() > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Error al actualizar producto:\n\n" + ex.Message,
                    "Base de Datos",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                return false;
            }
        }

        // =====================================================
        // ELIMINAR PRODUCTO (LÓGICO)
        // =====================================================
        public static bool DeleteProduct(string codigo)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnection.GetConnection())
                {
                    connection.Open();

                    string query = @"
                        UPDATE Productos
                        SET es_activo = 0,
                            fecha_actualizacion = GETDATE()
                        WHERE codigo = @codigo";

                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        command.Parameters.AddWithValue("@codigo", codigo);
                        return command.ExecuteNonQuery() > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Error al eliminar producto:\n\n" + ex.Message,
                    "Base de Datos",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                return false;
            }
        }

        // =====================================================
        // VERIFICAR SI EL CÓDIGO YA EXISTE
        // =====================================================
        public static bool ProductCodeExists(string codigo)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnection.GetConnection())
                {
                    connection.Open();

                    string query = @"
                        SELECT COUNT(*)
                        FROM Productos
                        WHERE codigo = @codigo
                          AND es_activo = 1";

                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        command.Parameters.AddWithValue("@codigo", codigo);
                        return (int)command.ExecuteScalar() > 0;
                    }
                }
            }
            catch
            {
                return false;
            }
        }
    }
}
