using System;
using System.Windows.Forms;
using FormMovimientos.clases;

namespace FormMovimientos
{
    public partial class FrmMenu : Form
    {
        // Formulario actualmente abierto
        private Form formularioActual = null;

        public FrmMenu()
        {
            InitializeComponent();
        }

        // =====================================================
        // ABRIR FORMULARIOS EN EL PANEL
        // =====================================================
        private void AbrirFormularioEnPanel(Form formulario)
        {
            if (formularioActual != null)
            {
                formularioActual.Close();
                formularioActual.Dispose();
            }

            formularioActual = formulario;
            formulario.TopLevel = false;
            formulario.FormBorderStyle = FormBorderStyle.None;
            formulario.Dock = DockStyle.Fill;
            formulario.AutoScroll = true;

            panelContenedor.Controls.Clear();
            panelContenedor.AutoScroll = true;

            panelContenedor.Controls.Add(formulario);
            panelContenedor.Tag = formulario;

            formulario.Show();
        }

        // ============================================
        // BOTÓN INICIO
        // ============================================
        private void button1_Click(object sender, EventArgs e)
        {
            if (formularioActual != null)
            {
                formularioActual.Close();
                formularioActual = null;
            }

            panelContenedor.Controls.Clear();

            PictureBox pb = new PictureBox();
            pb.Dock = DockStyle.Fill;
            pb.SizeMode = PictureBoxSizeMode.StretchImage;
            pb.Image = pictureBox6.Image;

            panelContenedor.Controls.Add(pb);
        }

        // ============================================
        // BOTÓN PRODUCTOS
        // ============================================
        private void button2_Click(object sender, EventArgs e)
        {
            AbrirFormularioEnPanel(new FrmProductos());
        }

        // ============================================
        // BOTÓN MOVIMIENTOS
        // ============================================
        private void button3_Click_1(object sender, EventArgs e)
        {
            AbrirFormularioEnPanel(new FrmMovimientos());
        }

        // ============================================
        // BOTÓN REPORTES
        // ============================================
        private void button4_Click(object sender, EventArgs e)
        {
            AbrirFormularioEnPanel(new FrmReportes());
        }

        // ============================================
        // BOTÓN PERFILES
        // ============================================
        private void button6_Click(object sender, EventArgs e)
        {
            AbrirFormularioEnPanel(new FrmPerfiles());
        }

        // ============================================
        // BOTÓN SALIR
        // ============================================
        private void button5_Click(object sender, EventArgs e)
        {
            DialogResult resultado = MessageBox.Show(
                "¿Está seguro que desea salir del sistema?",
                "Confirmar salida",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);

            if (resultado == DialogResult.Yes)
            {
                Application.Exit();
            }
        }

        // ============================================
        // LOAD DEL FORMULARIO (AQUÍ VA LA PRUEBA)
        // ============================================
        private void FrmMenu_Load(object sender, EventArgs e)
        {
            // 🔌 PROBAR CONEXIÓN A BD
            if (!DatabaseConnection.TestConnection())
            {
                MessageBox.Show(
                    "❌ No se pudo conectar a la base de datos.\nEl sistema se cerrará.",
                    "Error crítico",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Application.Exit();
                return;
            }

            // Mostrar inicio
            button1_Click(null, null);
        }

        // ============================================
        // CLICK EN LOGO (INICIO)
        // ============================================
        private void pictureBox3_Click(object sender, EventArgs e)
        {
            button1_Click(sender, e);
        }

        // ============================================
        // EVENTOS DEL DESIGNER
        // ============================================
        private void panelContenedor_Paint(object sender, PaintEventArgs e) { }
        private void pictureBox6_Click(object sender, EventArgs e) { }
        private void pictureBox1_Click(object sender, EventArgs e) { }
    }
}
