using System;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;
using FormMovimientos.clases;

namespace FormMovimientos
{
    public partial class FrmPerfiles : Form
    {
        private string usuarioSeleccionado = null;

        public FrmPerfiles()
        {
            InitializeComponent();
        }

        private void FrmPerfiles_Load(object sender, EventArgs e)
        {
            ConfigurarGrid();
            CargarComboBoxes();
            CargarUsuarios();
        }

        private void ConfigurarGrid()
        {
            dgvUsuarios.AutoGenerateColumns = true;
            dgvUsuarios.AllowUserToAddRows = false;
            dgvUsuarios.ReadOnly = true;
            dgvUsuarios.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgvUsuarios.MultiSelect = false;
        }

        private void CargarUsuarios(int? rolId = null)
        {
            try
            {
                using (SqlConnection cn = DatabaseConnection.GetConnection())
                {
                    cn.Open();

                    string sql = @"
                        SELECT 
                            u.usuario AS Usuario,
                            (u.nombre + ' ' + u.apellido) AS NombreCompleto,
                            r.nombre AS Rol,
                            r.id AS RolId,
                            u.estado AS Estado
                        FROM Usuarios u
                        INNER JOIN Roles r ON u.rol_id = r.id";

                    if (rolId.HasValue)
                        sql += " WHERE r.id = @rolId";

                    SqlCommand cmd = new SqlCommand(sql, cn);

                    if (rolId.HasValue)
                        cmd.Parameters.AddWithValue("@rolId", rolId.Value);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    dgvUsuarios.DataSource = dt;

                    if (dgvUsuarios.Columns.Contains("RolId"))
                        dgvUsuarios.Columns["RolId"].Visible = false;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error al cargar usuarios: " + ex.Message);
            }
        }

        private void CargarComboBoxes()
        {
            try
            {
                using (SqlConnection cn = DatabaseConnection.GetConnection())
                {
                    cn.Open();

                    SqlDataAdapter da = new SqlDataAdapter(
                        "SELECT id, nombre FROM Roles WHERE estado = 1", cn);

                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    cmbFiltroRol.DataSource = dt.Copy();
                    cmbFiltroRol.DisplayMember = "nombre";
                    cmbFiltroRol.ValueMember = "id";
                    cmbFiltroRol.SelectedIndex = -1;

                    cmbRol.DataSource = dt;
                    cmbRol.DisplayMember = "nombre";
                    cmbRol.ValueMember = "id";
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error al cargar roles: " + ex.Message);
            }
        }

        private void cmbFiltroRol_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cmbFiltroRol.SelectedValue == null || cmbFiltroRol.SelectedValue is DataRowView)
            {
                CargarUsuarios();
                return;
            }

            CargarUsuarios(Convert.ToInt32(cmbFiltroRol.SelectedValue));
        }

        // ==============================
        // GRID
        // ==============================
        private void dgvUsuarios_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            dgvUsuarios_CellClick(sender, e);
        }

        private void dgvUsuarios_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0) return;

            usuarioSeleccionado =
                dgvUsuarios.Rows[e.RowIndex].Cells["Usuario"].Value.ToString();

            txtUsuario.Text = usuarioSeleccionado;
            txtUsuario.Enabled = false;

            txtNombreCompleto.Text =
                dgvUsuarios.Rows[e.RowIndex].Cells["NombreCompleto"].Value.ToString();

            cmbRol.SelectedValue =
                dgvUsuarios.Rows[e.RowIndex].Cells["RolId"].Value;

            chkActivo.Checked =
                Convert.ToInt32(dgvUsuarios.Rows[e.RowIndex].Cells["Estado"].Value) == 1;
        }

        // ==============================
        // GUARDAR USUARIO (FIX DEFINITIVO)
        // ==============================
        private void GuardarUsuario()
        {
            if (txtUsuario.Text.Trim() == "" || txtNombreCompleto.Text.Trim() == "")
            {
                MessageBox.Show("Complete todos los campos");
                return;
            }

            string contrasenaPorDefecto = "1234";

            string[] partes = txtNombreCompleto.Text.Trim().Split(' ');
            string nombre = partes[0];
            string apellido = partes.Length > 1 ? partes[1] : "";

            try
            {
                using (SqlConnection cn = DatabaseConnection.GetConnection())
                {
                    cn.Open();
                    SqlCommand cmd;

                    if (usuarioSeleccionado == null)
                    {
                        cmd = new SqlCommand(@"
                            INSERT INTO Usuarios 
                            (usuario, nombre, apellido, contrasena, rol_id, estado)
                            VALUES 
                            (@usuario, @nombre, @apellido, @contrasena, @rol, @estado)", cn);

                        cmd.Parameters.AddWithValue("@contrasena", contrasenaPorDefecto);
                    }
                    else
                    {
                        cmd = new SqlCommand(@"
                            UPDATE Usuarios
                            SET nombre = @nombre,
                                apellido = @apellido,
                                rol_id = @rol,
                                estado = @estado
                            WHERE usuario = @usuario", cn);
                    }

                    cmd.Parameters.AddWithValue("@usuario", txtUsuario.Text.Trim());
                    cmd.Parameters.AddWithValue("@nombre", nombre);
                    cmd.Parameters.AddWithValue("@apellido", apellido);
                    cmd.Parameters.AddWithValue("@rol", cmbRol.SelectedValue);
                    cmd.Parameters.AddWithValue("@estado", chkActivo.Checked ? 1 : 0);

                    cmd.ExecuteNonQuery();
                }

                MessageBox.Show("Perfil guardado correctamente");
                LimpiarFormulario();
                CargarUsuarios();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error al guardar el usuario: " + ex.Message);
            }
        }

        // ==============================
        // BOTÓN GUARDAR (EXIGIDO POR DESIGNER)
        // ==============================
        private void btnGuardar_Click(object sender, EventArgs e)
        {
            GuardarUsuario();
        }

        // ==============================
        // LIMPIAR FORMULARIO
        // ==============================
        private void LimpiarFormulario()
        {
            txtUsuario.Clear();
            txtUsuario.Enabled = true;
            txtNombreCompleto.Clear();
            cmbRol.SelectedIndex = 0;
            chkActivo.Checked = true;
            usuarioSeleccionado = null;
        }

        // ==============================
        // EVENTO EXIGIDO POR DESIGNER
        // ==============================
        private void txtContrasena_TextChanged(object sender, EventArgs e)
        {
            // No se usa, pero DEBE existir
        }
    }
}
