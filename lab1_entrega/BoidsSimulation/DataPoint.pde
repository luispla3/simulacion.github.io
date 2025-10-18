// ========================================
// CLASE DATAPOINT
// ========================================
/*
 * Punto de datos para el diagrama fundamental.
 * Almacena una medición de (densidad, velocidad).
 */
class DataPoint {
  float density;   // Densidad local (boids/m²)
  float velocity;  // Velocidad del boid (píxeles/frame)
  
  DataPoint(float d, float v) {
    density = d;
    velocity = v;
  }
}

