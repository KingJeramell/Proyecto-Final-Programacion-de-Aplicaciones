using System;
using System.Data;
using System.Linq;
using System.Windows.Forms;
using FormMovimientos.clases;

namespace FormMovimientos
{
    public partial class FrmReportes : Form
    {
        public FrmReportes()
        {
            InitializeComponent();
        }

        // ============================================
        //      EVENTO LOAD DEL FORMULARIO
        // ============================================
        private void FrmReportes_Load(object sender, EventArgs e)
        {
            ConfigurarDataGridView();
            CargarCategorias();
            MostrarTodosLosProductos();
        }

        // ============================================
        //      CONFIGURAR DATAGRIDVIEW
        // ============================================
        private void ConfigurarDataGridView()
        {
            dgvReportes.Columns.Clear();

            dgvReportes.AllowUserToAddRows = false;
            dgvReportes.ReadOnly = true;
            dgvReportes.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgvReportes.MultiSelect = false;
            dgvReportes.RowHeadersVisible = false;
            dgvReportes.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None;
            dgvReportes.BackgroundColor = System.Drawing.Color.White;

            dgvReportes.Columns.Add("Codigo", "Código");
            dgvReportes.Columns.Add("Nombre", "Nombre del Producto");
            dgvReportes.Columns.Add("Categoria", "Categoría");
            dgvReportes.Columns.Add("Precio", "Precio Unitario");
            dgvReportes.Columns.Add("Stock", "Stock");
            dgvReportes.Columns.Add("ValorTotal", "Valor Total");

            dgvReportes.Columns["Codigo"].Width = 100;
            dgvReportes.Columns["Nombre"].Width = 220;
            dgvReportes.Columns["Categoria"].Width = 130;
            dgvReportes.Columns["Precio"].Width = 110;
            dgvReportes.Columns["Stock"].Width = 80;
            dgvReportes.Columns["ValorTotal"].Width = 110;

            dgvReportes.Columns["Codigo"].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dgvReportes.Columns["Stock"].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dgvReportes.Columns["Precio"].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
            dgvReportes.Columns["ValorTotal"].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
        }

        // ============================================
        //      CARGAR CATEGORÍAS
        // ============================================
        private void CargarCategorias()
        {
            try
            {
                cmbCategoriaFiltro.Items.Clear();
                cmbCategoriaFiltro.Items.Add("-- Todas las categorías --");

                DataTable categorias = ProductRepository.GetCategories();

                if (categorias != null)
                {
                    foreach (DataRow row in categorias.Rows)
                    {
                        cmbCategoriaFiltro.Items.Add(row["nombre"].ToString());
                    }
                }

                if (cmbCategoriaFiltro.Items.Count > 0)
                {
                    cmbCategoriaFiltro.SelectedIndex = 0;
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
        //      BOTÓN "MOSTRAR TODO"
        // ============================================
        private void btnMostrarTodo_Click(object sender, EventArgs e)
        {
            MostrarTodosLosProductos();
        }

        private void MostrarTodosLosProductos()
        {
            try
            {
                dgvReportes.Rows.Clear();

                var productos = ProductRepository.GetAllProducts();

                if (productos.Count == 0)
                {
                    MessageBox.Show(
                        "No hay productos registrados en el sistema.\n\n" +
                        "Por favor, agregue productos primero desde el módulo de 'Gestión de Productos'.",
                        "Sin datos",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);
                    return;
                }

                decimal valorTotalInventario = 0;
                int stockTotalInventario = 0;

                foreach (var producto in productos.OrderBy(p => p.Codigo))
                {
                    decimal valorTotal = producto.Precio * producto.Stock;
                    valorTotalInventario += valorTotal;
                    stockTotalInventario += producto.Stock;

                    dgvReportes.Rows.Add(
                        producto.Codigo,
                        producto.Nombre,
                        producto.Categoria,
                        "$" + producto.Precio.ToString("N2"),
                        producto.Stock.ToString(),
                        "$" + valorTotal.ToString("N2")
                    );
                }

                // Limpiar filtros
                txtNombreFiltro.Clear();
                cmbCategoriaFiltro.SelectedIndex = 0;

                MessageBox.Show(
                    $"✓ Reporte generado exitosamente\n\n" +
                    $"Total de productos: {productos.Count}\n" +
                    $"Stock total: {stockTotalInventario:N0} unidades\n" +
                    $"Valor total del inventario: ${valorTotalInventario:N2}",
                    "Reporte Completo",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Error al generar reporte:\n\n" + ex.Message,
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        // ============================================
        //      BOTÓN "FILTRAR"
        // ============================================
        private void btnFiltrar_Click(object sender, EventArgs e)
        {
            FiltrarProductos();
        }

        private void FiltrarProductos()
        {
            try
            {
                dgvReportes.Rows.Clear();

                string categoriaSeleccionada = cmbCategoriaFiltro.SelectedItem?.ToString() ?? "";
                string nombreBusqueda = txtNombreFiltro.Text.Trim().ToLower();

                if ((string.IsNullOrEmpty(categoriaSeleccionada) || categoriaSeleccionada.StartsWith("--")) &&
                    string.IsNullOrEmpty(nombreBusqueda))
                {
                    MessageBox.Show(
                        "No ha aplicado ningún filtro.\n\n" +
                        "Por favor, seleccione una categoría o escriba un nombre para buscar.",
                        "Sin filtros",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);
                    return;
                }

                var productos = ProductRepository.GetAllProducts();
                var productosFiltrados = productos.AsEnumerable();

                // Filtrar por categoría
                if (!string.IsNullOrEmpty(categoriaSeleccionada) && !categoriaSeleccionada.StartsWith("--"))
                {
                    productosFiltrados = productosFiltrados.Where(p =>
                        p.Categoria.Equals(categoriaSeleccionada, StringComparison.OrdinalIgnoreCase));
                }

                // Filtrar por nombre o código
                if (!string.IsNullOrEmpty(nombreBusqueda))
                {
                    productosFiltrados = productosFiltrados.Where(p =>
                        p.Nombre.ToLower().Contains(nombreBusqueda) ||
                        p.Codigo.ToLower().Contains(nombreBusqueda)
                    );
                }

                var resultados = productosFiltrados.OrderBy(p => p.Codigo).ToList();

                if (resultados.Count == 0)
                {
                    MessageBox.Show(
                        "No se encontraron productos con los filtros aplicados.\n\n" +
                        "Intente con otros criterios de búsqueda.",
                        "Sin resultados",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning);
                    return;
                }

                decimal valorTotal = 0;
                int stockTotal = 0;

                foreach (var producto in resultados)
                {
                    decimal valor = producto.Precio * producto.Stock;
                    valorTotal += valor;
                    stockTotal += producto.Stock;

                    dgvReportes.Rows.Add(
                        producto.Codigo,
                        producto.Nombre,
                        producto.Categoria,
                        "$" + producto.Precio.ToString("N2"),
                        producto.Stock.ToString(),
                        "$" + valor.ToString("N2")
                    );
                }

                string mensajeFiltros = "Filtros aplicados:\n";
                if (!string.IsNullOrEmpty(categoriaSeleccionada) && !categoriaSeleccionada.StartsWith("--"))
                {
                    mensajeFiltros += $"• Categoría: {categoriaSeleccionada}\n";
                }
                if (!string.IsNullOrEmpty(nombreBusqueda))
                {
                    mensajeFiltros += $"• Búsqueda: '{txtNombreFiltro.Text}'\n";
                }

                MessageBox.Show(
                    $"✓ Filtrado completado\n\n" +
                    mensajeFiltros + "\n" +
                    $"Productos encontrados: {resultados.Count}\n" +
                    $"Stock total: {stockTotal:N0} unidades\n" +
                    $"Valor total: ${valorTotal:N2}",
                    "Resultados del Filtro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Error al filtrar productos:\n\n" + ex.Message,
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        // ============================================
        //      EVENTO OPCIONAL: Enter para filtrar
        // ============================================
        private void txtNombreFiltro_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                FiltrarProductos();
                e.Handled = true;
            }
        }

        // ============================================
        //      EVENTOS DEL DESIGNER
        // ============================================
        private void cmbCategoriaFiltro_SelectedIndexChanged_1(object sender, EventArgs e)
        {
            // Opcional: Filtrar automáticamente al cambiar categoría
        }
    }
}