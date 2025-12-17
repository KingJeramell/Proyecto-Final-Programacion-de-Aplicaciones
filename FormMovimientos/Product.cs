using System;

namespace FormMovimientos.clases
{
    /// <summary>
    /// Clase que representa un producto del inventario
    /// </summary>
    public class Product
    {
        public int Id { get; set; }
        public string Codigo { get; set; }
        public string Nombre { get; set; }
        public string Categoria { get; set; }
        public decimal Precio { get; set; }
        public int Stock { get; set; }

        public Product()
        {
            Id = 0;
            Codigo = "";
            Nombre = "";
            Categoria = "";
            Precio = 0;
            Stock = 0;
        }

        public Product(int id, string codigo, string nombre, string categoria, decimal precio, int stock)
        {
            Id = id;
            Codigo = codigo;
            Nombre = nombre;
            Categoria = categoria;
            Precio = precio;
            Stock = stock;
        }

        public override string ToString()
        {
            return $"{Codigo} - {Nombre}";
        }
    }
}