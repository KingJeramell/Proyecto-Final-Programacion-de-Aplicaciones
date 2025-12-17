using System;
using System.Data;
using System.Windows.Forms;
using FormMovimientos.clases;

namespace FormMovimientos
{
    public partial class FrmProductos : Form
    {
        private DataTable categorias;

        public FrmProductos()
        {
            InitializeComponent();
        }

        // ============================================
        //      EVENTO LOAD
        // ============================================
        private void FrmProductos_Load(object sender, EventArgs e)
        {
            // Configurar el DataGridView
            dgvProductos.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgvProductos.MultiSelect = false;
            dgvProductos.ReadOnly = true;

            // Cargar categorías en el ComboBox
            CargarCategorias();

            // Cargar productos desde la base de datos
            CargarProductos();
        }

        // ============================================
        //      CARGAR CATEGORÍAS
        // ============================================
        private void CargarCategorias()
        {
            try
            {
                categorias = ProductRepository.GetCategories();

                if (categorias != null && categorias.Rows.Count > 0)
                {
                    cmbCategoria.DataSource = categorias;
                    cmbCategoria.DisplayMember = "nombre";
                    cmbCategoria.ValueMember = "id";
                    cmbCategoria.SelectedIndex = 0;
                }
                else
                {
                    MessageBox.Show(
                        "No se encontraron categorías en la base de datos.\n\n" +
                        "Por favor, verifica que la base de datos esté correctamente configurada.",
                        "Sin Categorías",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Error al cargar categorías:\n\n" + ex.Message,
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        // ============================================
        //      CARGAR PRODUCTOS DESDE BD
        // ============================================
        private void CargarProductos()
        {
            try
            {
                dgvProductos.Rows.Clear();

                var productos = ProductRepository.GetAllProducts();

                foreach (var producto in productos)
                {
                    dgvProductos.Rows.Add(
                        producto.Codigo,
                        producto.Nombre,
                        producto.Categoria,
                        producto.Precio.ToString("N2"),
                        producto.Stock.ToString()
                    );
                }

                // Actualizar DataStore para otros formularios
                DataStore.Productos = productos;
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Error al cargar productos:\n\n" + ex.Message,
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        // ============================================
        //      BOTÓN GUARDAR
        // ============================================
        private void btnGuardar_Click_1(object sender, EventArgs e)
        {
            // Validar campos obligatorios
            if (string.IsNullOrWhiteSpace(txtCodigo.Text))
            {
                MessageBox.Show("Por favor, ingrese el código del producto.", "Campo Requerido",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtCodigo.Focus();
                return;
            }

            if (string.IsNullOrWhiteSpace(txtNombre.Text))
            {
                MessageBox.Show("Por favor, ingrese el nombre del producto.", "Campo Requerido",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtNombre.Focus();
                return;
            }

            if (cmbCategoria.SelectedValue == null)
            {
                MessageBox.Show("Por favor, seleccione una categoría.", "Campo Requerido",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                cmbCategoria.Focus();
                return;
            }

            // Validar precio
            decimal precio;
            if (string.IsNullOrWhiteSpace(txtPrecio.Text) || !decimal.TryParse(txtPrecio.Text, out precio) || precio <= 0)
            {
                MessageBox.Show("Por favor, ingrese un precio válido mayor a cero.", "Precio Inválido",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtPrecio.Focus();
                return;
            }

            // Validar stock
            int stock = 0;
            if (!string.IsNullOrWhiteSpace(txtStock.Text))
            {
                if (!int.TryParse(txtStock.Text, out stock) || stock < 0)
                {
                    MessageBox.Show("Por favor, ingrese un stock válido.", "Stock Inválido",
                        MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    txtStock.Focus();
                    return;
                }
            }

            // Verificar si el código ya existe
            if (ProductRepository.ProductCodeExists(txtCodigo.Text.Trim()))
            {
                MessageBox.Show("Ya existe un producto con este código.", "Código Duplicado",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtCodigo.Focus();
                return;
            }

            // Insertar producto en la base de datos
            int categoriaId = Convert.ToInt32(cmbCategoria.SelectedValue);
            decimal precioCosto = precio * 0.6m; // Estimado: 60% del precio de venta

            bool exito = ProductRepository.InsertProduct(
                txtCodigo.Text.Trim(),
                txtNombre.Text.Trim(),
                categoriaId,
                precioCosto,
                precio,
                stock
            );

            if (exito)
            {
                MessageBox.Show("Producto guardado exitosamente.", "Éxito",
                    MessageBoxButtons.OK, MessageBoxIcon.Information);

                // Recargar productos
                CargarProductos();
                LimpiarCampos();
            }
        }

        // ============================================
        //      BOTÓN EDITAR
        // ============================================
        private void btnEditar_Click_1(object sender, EventArgs e)
        {
            if (dgvProductos.CurrentRow == null)
            {
                MessageBox.Show("Por favor, seleccione un producto para editar.", "No hay selección",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Validar campos
            if (string.IsNullOrWhiteSpace(txtCodigo.Text) || string.IsNullOrWhiteSpace(txtNombre.Text))
            {
                MessageBox.Show("Por favor, complete los campos obligatorios.", "Campos Requeridos",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Validar precio
            decimal precio;
            if (!decimal.TryParse(txtPrecio.Text, out precio) || precio <= 0)
            {
                MessageBox.Show("Por favor, ingrese un precio válido.", "Precio Inválido",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Validar stock
            int stock;
            if (!int.TryParse(txtStock.Text, out stock) || stock < 0)
            {
                MessageBox.Show("Por favor, ingrese un stock válido.", "Stock Inválido",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Obtener código original
            string codigoOriginal = dgvProductos.CurrentRow.Cells[0].Value?.ToString() ?? "";

            // Verificar código duplicado (excepto el actual)
            if (txtCodigo.Text.Trim() != codigoOriginal)
            {
                if (ProductRepository.ProductCodeExists(txtCodigo.Text.Trim()))
                {
                    MessageBox.Show("Ya existe un producto con este código.", "Código Duplicado",
                        MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
            }

            // Actualizar producto
            int categoriaId = Convert.ToInt32(cmbCategoria.SelectedValue);
            decimal precioCosto = precio * 0.6m;

            bool exito = ProductRepository.UpdateProduct(
                codigoOriginal,
                txtCodigo.Text.Trim(),
                txtNombre.Text.Trim(),
                categoriaId,
                precioCosto,
                precio,
                stock
            );

            if (exito)
            {
                MessageBox.Show("Producto actualizado correctamente.", "Éxito",
                    MessageBoxButtons.OK, MessageBoxIcon.Information);

                CargarProductos();
                LimpiarCampos();
            }
        }

        // ============================================
        //      BOTÓN ELIMINAR
        // ============================================
        private void btnEliminar_Click(object sender, EventArgs e)
        {
            if (dgvProductos.CurrentRow == null)
            {
                MessageBox.Show("Por favor, seleccione un producto para eliminar.", "No hay selección",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string codigo = dgvProductos.CurrentRow.Cells[0].Value?.ToString() ?? "";
            string nombreProducto = dgvProductos.CurrentRow.Cells[1].Value?.ToString() ?? "este producto";

            DialogResult confirmacion = MessageBox.Show(
                $"¿Está seguro de que desea eliminar '{nombreProducto}'?\n\n" +
                "Esta acción desactivará el producto en el sistema.",
                "Confirmar Eliminación",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question
            );

            if (confirmacion == DialogResult.Yes)
            {
                bool exito = ProductRepository.DeleteProduct(codigo);

                if (exito)
                {
                    MessageBox.Show("Producto eliminado exitosamente.", "Éxito",
                        MessageBoxButtons.OK, MessageBoxIcon.Information);

                    CargarProductos();
                    LimpiarCampos();
                }
            }
        }

        // ============================================
        //      EVENTO CELLCLICK - Cargar datos
        // ============================================
        private void dgvProductos_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0 && e.RowIndex < dgvProductos.Rows.Count)
            {
                DataGridViewRow fila = dgvProductos.Rows[e.RowIndex];

                txtCodigo.Text = fila.Cells[0].Value?.ToString() ?? "";
                txtNombre.Text = fila.Cells[1].Value?.ToString() ?? "";

                // Buscar la categoría en el ComboBox
                string categoria = fila.Cells[2].Value?.ToString() ?? "";
                for (int i = 0; i < cmbCategoria.Items.Count; i++)
                {
                    DataRowView item = (DataRowView)cmbCategoria.Items[i];
                    if (item["nombre"].ToString() == categoria)
                    {
                        cmbCategoria.SelectedIndex = i;
                        break;
                    }
                }

                txtPrecio.Text = fila.Cells[3].Value?.ToString() ?? "";
                txtStock.Text = fila.Cells[4].Value?.ToString() ?? "";
            }
        }

        // ============================================
        //      MÉTODO AUXILIAR - Limpiar campos
        // ============================================
        private void LimpiarCampos()
        {
            txtCodigo.Clear();
            txtNombre.Clear();
            txtPrecio.Clear();
            txtStock.Clear();
            if (cmbCategoria.Items.Count > 0)
                cmbCategoria.SelectedIndex = 0;
            txtCodigo.Focus();
            dgvProductos.ClearSelection();
        }

        // ============================================
        //      EVENTOS DEL DESIGNER
        // ============================================
        private void FrmProductos_Activated(object sender, EventArgs e)
        {
            dgvProductos.Invalidate();
        }

        private void label3_Click(object sender, EventArgs e)
        {
        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {
        }

        private void cmbCategoria_SelectedIndexChanged(object sender, EventArgs e)
        {
        }
    }
}