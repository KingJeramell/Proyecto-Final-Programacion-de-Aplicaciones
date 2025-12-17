using System;
using System.Collections.Generic;

namespace FormMovimientos.clases
{
    /// <summary>
    /// Almacén estático para compartir datos entre formularios
    /// </summary>
    public static class DataStore
    {
        // Lista estática de productos compartida entre formularios
        public static List<Product> Productos { get; set; }

        // Constructor estático - se ejecuta automáticamente la primera vez que se accede a la clase
        static DataStore()
        {
            Productos = new List<Product>();
        }
    }
}