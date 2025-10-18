// ========================================
// CLASE DATAPOINT
// ========================================
/*
 * Punto de datos para el diagrama fundamental.
 * Almacena una medición de (densidad, velocidad).
 */
class DataPoint {
  float density;   // Densidad local (ped/m²)
  float velocity;  // Velocidad del peatón (píxeles/frame)
  
  DataPoint(float d, float v) {
    density = d;
    velocity = v;
  }
}

