using System;
using System.Windows.Forms;
using FormMovimientos.clases;

namespace FormMovimientos
{
    public partial class FrmMovimientos : Form
    {
        public FrmMovimientos()
        {
            InitializeComponent();
        }

        // ============================================
        //      EVENTO LOAD DEL FORMULARIO
        // ============================================
        private void FrmMovimientos_Load(object sender, EventArgs e)
        {
            CargarProductos();

            // Configurar fecha por defecto
            dtpFecha.Value = DateTime.Now;

            // Configurar NumericUpDown
            nudCantidad.Minimum = 1;
            nudCantidad.Maximum = 10000;
            nudCantidad.Value = 1;
        }

        // ============================================
        //      CARGAR PRODUCTOS EN COMBOBOX
        // ============================================
        private void CargarProductos()
        {
            try
            {
                cmbProducto.Items.Clear();

                var productos = ProductRepository.GetAllProducts();

                if (productos.Count == 0)
                {
                    MessageBox.Show(
                        "No hay productos registrados en el sistema.\n\n" +
                        "Por favor, registre productos primero desde el módulo 'Productos'.",
                        "Sin Productos",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);
                    return;
                }

                // Agregar productos al ComboBox
                foreach (var producto in productos)
                {
                    cmbProducto.Items.Add(producto);
                }

                // Seleccionar el primero
                if (cmbProducto.Items.Count > 0)
                {
                    cmbProducto.SelectedIndex = 0;
                }

                cmbProducto.DisplayMember = "Nombre"; // Mostrar el nombre del producto
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
        //      BOTÓN REGISTRAR MOVIMIENTO
        // ============================================
        private void btnRegistrar_Click(object sender, EventArgs e)
        {
            // Validar que haya un producto seleccionado
            if (cmbProducto.SelectedIndex == -1)
            {
                MessageBox.Show(
                    "Por favor, seleccione un producto.",
                    "Validación",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                cmbProducto.Focus();
                return;
            }

            // Validar que haya un tipo de movimiento seleccionado
            if (!rbEntrada.Checked && !rbSalida.Checked)
            {
                MessageBox.Show(
                    "Por favor, seleccione el tipo de movimiento (Entrada o Salida).",
                    "Validación",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                return;
            }

            // Validar cantidad
            if (nudCantidad.Value <= 0)
            {
                MessageBox.Show(
                    "La cantidad debe ser mayor a cero.",
                    "Validación",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                nudCantidad.Focus();
                return;
            }

            try
            {
                // Obtener datos del formulario
                Product productoSeleccionado = (Product)cmbProducto.SelectedItem;
                int cantidad = (int)nudCantidad.Value;
                string tipoMovimiento = rbEntrada.Checked ? "Entrada" : "Salida";
                DateTime fechaMovimiento = dtpFecha.Value;

                // Crear motivo descriptivo
                string motivo = $"{tipoMovimiento} de inventario - {productoSeleccionado.Nombre}";

                // Mostrar stock actual antes del movimiento
                int stockActual = productoSeleccionado.Stock;
                int stockNuevo = tipoMovimiento == "Entrada" ?
                    stockActual + cantidad :
                    stockActual - cantidad;

                // Validar stock negativo en salidas
                if (tipoMovimiento == "Salida" && stockNuevo < 0)
                {
                    MessageBox.Show(
                        $"Stock insuficiente.\n\n" +
                        $"Stock actual: {stockActual}\n" +
                        $"Cantidad solicitada: {cantidad}\n" +
                        $"Faltan: {cantidad - stockActual} unidades",
                        "Stock Insuficiente",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning);
                    return;
                }

                // Confirmar el movimiento
                DialogResult confirmacion = MessageBox.Show(
                    $"¿Confirmar el siguiente movimiento?\n\n" +
                    $"Producto: {productoSeleccionado.Nombre}\n" +
                    $"Tipo: {tipoMovimiento}\n" +
                    $"Cantidad: {cantidad}\n" +
                    $"Stock actual: {stockActual}\n" +
                    $"Stock después: {stockNuevo}\n" +
                    $"Fecha: {fechaMovimiento:dd/MM/yyyy}",
                    "Confirmar Movimiento",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Question);

                if (confirmacion == DialogResult.No)
                {
                    return;
                }

                // Registrar el movimiento en la base de datos
                bool exito = MovementRepository.RegisterMovement(
                    productoSeleccionado.Id,
                    tipoMovimiento,
                    cantidad,
                    motivo,
                    fechaMovimiento,
                    usuarioId: 1, // Usuario por defecto (deberías obtenerlo del sistema de login)
                    almacenId: 1  // Almacén por defecto
                );

                if (exito)
                {
                    MessageBox.Show(
                        $"✓ Movimiento Registrado Exitosamente\n\n" +
                        $"Producto: {productoSeleccionado.Nombre}\n" +
                        $"Tipo: {tipoMovimiento}\n" +
                        $"Cantidad: {cantidad}\n" +
                        $"Stock anterior: {stockActual}\n" +
                        $"Stock nuevo: {stockNuevo}",
                        "Éxito",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);

                    // Limpiar y recargar
                    LimpiarFormulario();
                    CargarProductos(); // Recargar para actualizar stocks
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Error al registrar movimiento:\n\n" + ex.Message,
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        // ============================================
        //      MÉTODO AUXILIAR - Limpiar Formulario
        // ============================================
        private void LimpiarFormulario()
        {
            rbEntrada.Checked = false;
            rbSalida.Checked = false;
            nudCantidad.Value = 1;
            dtpFecha.Value = DateTime.Now;

            if (cmbProducto.Items.Count > 0)
            {
                cmbProducto.SelectedIndex = 0;
            }

            cmbProducto.Focus();
        }

        // ============================================
        //      EVENTO AL CAMBIAR DE PRODUCTO
        // ============================================
        private void cmbProducto_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Opcional: Mostrar información del producto seleccionado
            if (cmbProducto.SelectedItem != null)
            {
                Product producto = (Product)cmbProducto.SelectedItem;

                // Podrías mostrar el stock actual en un label
                // lblStockActual.Text = $"Stock actual: {producto.Stock}";
            }
        }

        private void cmbProducto_SelectedIndexChanged_1(object sender, EventArgs e)
        {

        }
    }
}