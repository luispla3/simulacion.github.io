/*
 * SIMULACIÓN DE BOIDS CON DIAGRAMA FUNDAMENTAL
 * =============================================
 * Este programa simula el comportamiento de boids (bandada/flocking) 
 * y recolecta datos de densidad vs velocidad para comparar con el modelo de Weidmann.
 * 
 * Los boids siguen 3 reglas simples:
 * 1. SEPARACIÓN: Evitar colisiones con vecinos cercanos
 * 2. ALINEACIÓN: Moverse en la misma dirección que los vecinos
 * 3. COHESIÓN: Moverse hacia el centro del grupo de vecinos
 */

// ========================================
// VARIABLES GLOBALES
// ========================================

// Listas de agentes y datos
ArrayList<Boid> boids;                   // Lista de todos los boids
ArrayList<DataPoint> dataPoints;         // Puntos de datos para el gráfico
float simulationTime = 0;                // Tiempo transcurrido en segundos
int dataCollectionInterval = 30;         // Frames entre cada recolección de datos
int framesSinceLastCollection = 0;       // Contador de frames desde última recolección

// ========================================
// ÁREA DE SIMULACIÓN (espacio de vuelo)
// ========================================
float areaX = 50;                        // Posición X del área
float areaY = 150;                       // Posición Y del área
float areaWidth = 700;                   // Ancho del área
float areaHeight = 550;                  // Alto del área

// ========================================
// ÁREA DEL GRÁFICO (diagrama fundamental)
// ========================================
float graphX = 800;                      // Posición X del gráfico
float graphY = 150;                      // Posición Y del gráfico
float graphWidth = 350;                  // Ancho del gráfico
float graphHeight = 200;                 // Alto del gráfico

// ========================================
// PARÁMETROS DE SIMULACIÓN DE BOIDS
// ========================================
int numBoids = 20;                       // Número inicial de boids
float boidRadius = 8;                    // Radio de cada boid (píxeles)
float maxSpeed = 2.0;                    // Velocidad máxima
float maxForce = 0.05;                   // Fuerza máxima de steering

// Pesos de las reglas de flocking
float separationWeight = 1.5;            // Peso de la separación
float alignmentWeight = 1.0;             // Peso de la alineación
float cohesionWeight = 1.0;              // Peso de la cohesión

// Radios de percepción
float separationRadius = 25;             // Radio para separación
float alignmentRadius = 50;              // Radio para alineación
float cohesionRadius = 50;               // Radio para cohesión

// ========================================
// OPCIONES DE VISUALIZACIÓN
// ========================================
boolean showVectors = false;             // Mostrar vectores de velocidad
boolean showNeighborhood = false;        // Mostrar radio de percepción
boolean showGraph = true;                // Mostrar diagrama fundamental

/*
 * CONFIGURACIÓN INICIAL
 * =====================
 * Se ejecuta una vez al inicio del programa.
 */
void setup() {
  size(1200, 700);  // Ventana de 1200x700 píxeles
  
  // Inicializar listas vacías
  boids = new ArrayList<Boid>();
  dataPoints = new ArrayList<DataPoint>();
  
  // Crear boids en posiciones aleatorias dentro del área
  for (int i = 0; i < numBoids; i++) {
    float x = random(areaX + boidRadius * 2, areaX + areaWidth - boidRadius * 2);
    float y = random(areaY + boidRadius * 2, areaY + areaHeight - boidRadius * 2);
    boids.add(new Boid(x, y, boidRadius));
  }
}

/*
 * BUCLE PRINCIPAL
 * ===============
 * Se ejecuta 60 veces por segundo.
 */
void draw() {
  background(30, 35, 45);  // Fondo gris oscuro
  
  // Actualizar tiempo de simulación (asumiendo 60 FPS)
  simulationTime += 1.0/60.0;
  
  // Dibujar el área de simulación
  drawArea();
  
  // Actualizar física de todos los boids
  for (Boid b : boids) {
    b.flock(boids);  // Aplicar reglas de flocking
    b.update();      // Actualizar posición
  }
  
  // Dibujar todos los boids
  for (Boid b : boids) {
    b.display();
  }
  
  // Recolectar datos para el diagrama fundamental
  framesSinceLastCollection++;
  if (framesSinceLastCollection >= dataCollectionInterval) {
    collectData();
    framesSinceLastCollection = 0;
  }
  
  // Dibujar el gráfico del diagrama fundamental
  if (showGraph) {
    drawFundamentalDiagram();
  }
  
  // Dibujar la interfaz de usuario
  drawUI();
}

/*
 * DIBUJAR ÁREA DE SIMULACIÓN
 * ===========================
 * Dibuja las fronteras del área de vuelo.
 */
void drawArea() {
  pushStyle();
  
  // Dibujar bordes del área
  stroke(100, 150, 200);  // Azul claro
  strokeWeight(3);
  noFill();
  rect(areaX, areaY, areaWidth, areaHeight);
  
  popStyle();
}

/*
 * RECOLECTAR DATOS
 * ================
 * Captura la densidad local y velocidad de cada boid
 * para construir el diagrama fundamental.
 */
void collectData() {
  for (Boid b : boids) {
    float localDensity = b.calculateLocalDensity();  // Densidad en boids/m²
    float velocity = b.velocity.mag();               // Magnitud de la velocidad
    
    // Guardar punto de datos (densidad, velocidad)
    dataPoints.add(new DataPoint(localDensity, velocity));
  }
  
  // Limitar cantidad de datos para evitar problemas de memoria
  while (dataPoints.size() > 5000) {
    dataPoints.remove(0);
  }
}

/*
 * DIBUJAR DIAGRAMA FUNDAMENTAL
 * ============================
 * Dibuja el gráfico de densidad vs velocidad.
 * A diferencia de los peatones, los boids NO seguirán el modelo de Weidmann.
 */
void drawFundamentalDiagram() {
  pushStyle();
  
  // Fondo del gráfico
  fill(20, 25, 35);
  stroke(100);
  strokeWeight(2);
  rect(graphX, graphY, graphWidth, graphHeight);
  
  // Título del gráfico
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("Fundamental Diagram (Boids)", graphX + graphWidth/2, graphY - 15);
  
  // Etiquetas de los ejes
  textSize(11);
  text("Density (boids/m²)", graphX + graphWidth/2, graphY + graphHeight + 25);
  
  pushMatrix();
  translate(graphX - 30, graphY + graphHeight/2);
  rotate(-PI/2);
  text("Velocity (m/s)", 0, 0);
  popMatrix();
  
  // Dibujar ejes
  stroke(150);
  strokeWeight(1);
  line(graphX, graphY + graphHeight, graphX + graphWidth, graphY + graphHeight); // Eje X
  line(graphX, graphY, graphX, graphY + graphHeight); // Eje Y
  
  // Marcas del eje X (densidad)
  fill(200);
  textAlign(CENTER, TOP);
  textSize(9);
  for (float d = 0; d <= 10; d += 2) {
    float x = map(d, 0, 10, graphX, graphX + graphWidth);
    stroke(150);
    line(x, graphY + graphHeight, x, graphY + graphHeight + 5);
    noStroke();
    text(nf(d, 0, 0), x, graphY + graphHeight + 7);
  }
  
  // Marcas del eje Y (velocidad)
  textAlign(RIGHT, CENTER);
  textSize(9);
  for (float v = 0; v <= 2.5; v += 0.5) {
    float y = map(v, 0, 2.5, graphY + graphHeight, graphY);
    stroke(150);
    line(graphX - 5, y, graphX, y);
    noStroke();
    text(nf(v, 0, 1), graphX - 8, y);
  }
  
  // Dibujar curva de referencia de Weidmann (para comparación) - LÍNEA VERDE
  stroke(100, 255, 100, 80);
  strokeWeight(2);
  noFill();
  beginShape();
  for (float d = 0; d <= 10; d += 0.1) {
    float v = calculateWeidmannVelocity(d);
    float x = map(d, 0, 10, graphX, graphX + graphWidth);
    float y = map(v, 0, 2.5, graphY + graphHeight, graphY);
    vertex(x, y);
  }
  endShape();
  
  // Dibujar puntos de datos de la simulación - PUNTOS AZULES
  for (DataPoint dp : dataPoints) {
    float x = map(dp.density, 0, 10, graphX, graphX + graphWidth);
    float y = map(dp.velocity, 0, 2.5, graphY + graphHeight, graphY);
    
    if (x >= graphX && x <= graphX + graphWidth && y >= graphY && y <= graphY + graphHeight) {
      stroke(100, 150, 255, 100);  // Azul semitransparente
      strokeWeight(2);
      point(x, y);
    }
  }
  
  // Dibujar promedio móvil - LÍNEA ROJA
  if (dataPoints.size() > 10) {
    ArrayList<PVector> avgPoints = calculateMovingAverage();
    stroke(255, 100, 100);  // Rojo
    strokeWeight(3);
    noFill();
    beginShape();
    for (PVector p : avgPoints) {
      float x = map(p.x, 0, 10, graphX, graphX + graphWidth);
      float y = map(p.y, 0, 2.5, graphY + graphHeight, graphY);
      if (x >= graphX && x <= graphX + graphWidth && y >= graphY && y <= graphY + graphHeight) {
        vertex(x, y);
      }
    }
    endShape();
  }
  
  // Leyenda
  textAlign(LEFT, CENTER);
  textSize(10);
  fill(100, 255, 100);
  text("Reference (Weidmann)", graphX + 10, graphY + 20);
  fill(255, 100, 100);
  text("Boids (avg)", graphX + 10, graphY + 35);
  fill(100, 150, 255);
  text("Raw data", graphX + 10, graphY + 50);
  
  popStyle();
}

/*
 * CALCULAR VELOCIDAD SEGÚN MODELO DE WEIDMANN
 * ============================================
 * Modelo de referencia para comparación (línea verde en el gráfico).
 */
float calculateWeidmannVelocity(float density) {
  float v0 = 1.34;
  float rhoMax = 5.4;
  float gamma = 1.913;
  
  if (density >= rhoMax) {
    return 0.0;
  }
  
  if (density < 0.1) {
    return v0;
  }
  
  float velocity = v0 * (1.0 - exp(-gamma * (1.0/density - 1.0/rhoMax)));
  
  return constrain(velocity, 0, v0);
}

/*
 * CALCULAR PROMEDIO MÓVIL
 * =======================
 * Agrupa los datos en bins y calcula promedios.
 */
ArrayList<PVector> calculateMovingAverage() {
  ArrayList<PVector> avgPoints = new ArrayList<PVector>();
  
  int numBins = 20;
  float binWidth = 10.0 / numBins;
  
  for (int i = 0; i < numBins; i++) {
    float minDensity = i * binWidth;
    float maxDensity = (i + 1) * binWidth;
    
    float sumVelocity = 0;
    int count = 0;
    
    for (DataPoint dp : dataPoints) {
      if (dp.density >= minDensity && dp.density < maxDensity) {
        sumVelocity += dp.velocity;
        count++;
      }
    }
    
    if (count > 5) {
      float avgDensity = (minDensity + maxDensity) / 2;
      float avgVelocity = sumVelocity / count;
      avgPoints.add(new PVector(avgDensity, avgVelocity));
    }
  }
  
  return avgPoints;
}

/*
 * DIBUJAR INTERFAZ DE USUARIO
 * ============================
 * Dibuja el panel de control con información y controles.
 */
void drawUI() {
  pushStyle();
  
  // Panel de control
  fill(0, 0, 0, 180);
  noStroke();
  rect(10, 10, 280, 120);
  
  // Título
  fill(255);
  textAlign(LEFT, TOP);
  textSize(14);
  text("Boids Simulation", 20, 20);
  
  // Estadísticas
  textSize(11);
  fill(200);
  text("Boids: " + boids.size(), 20, 45);
  text("Data points: " + dataPoints.size(), 20, 60);
  text("Time: " + nf(simulationTime, 0, 1) + "s", 20, 75);
  
  // Instrucciones
  textSize(10);
  text("Controls:", 20, 95);
  text("  Click: Add boid", 20, 108);
  text("  V: Toggle vectors | N: Toggle neighborhood | G: Toggle graph", 20, 121);
  text("  R: Reset | +/-: Add/Remove boids", 20, 134);
  
  // Indicadores de estado
  textAlign(RIGHT, TOP);
  fill(showVectors ? color(100, 255, 100) : color(100));
  text("Vectors: " + (showVectors ? "ON" : "OFF"), 270, 45);
  fill(showNeighborhood ? color(100, 255, 100) : color(100));
  text("Neighborhood: " + (showNeighborhood ? "ON" : "OFF"), 270, 60);
  fill(showGraph ? color(100, 255, 100) : color(100));
  text("Graph: " + (showGraph ? "ON" : "OFF"), 270, 75);
  
  popStyle();
}

/*
 * MANEJADOR DE TECLADO
 * ====================
 */
void keyPressed() {
  if (key == 'v' || key == 'V') {
    showVectors = !showVectors;
  } 
  else if (key == 'n' || key == 'N') {
    showNeighborhood = !showNeighborhood;
  } 
  else if (key == 'g' || key == 'G') {
    showGraph = !showGraph;
  } 
  else if (key == 'r' || key == 'R') {
    // Reiniciar simulación
    boids.clear();
    dataPoints.clear();
    simulationTime = 0;
    
    for (int i = 0; i < numBoids; i++) {
      float x = random(areaX + boidRadius * 2, areaX + areaWidth - boidRadius * 2);
      float y = random(areaY + boidRadius * 2, areaY + areaHeight - boidRadius * 2);
      boids.add(new Boid(x, y, boidRadius));
    }
  } 
  else if (key == '+' || key == '=') {
    // Añadir un boid
    float x = random(areaX + boidRadius * 2, areaX + areaWidth - boidRadius * 2);
    float y = random(areaY + boidRadius * 2, areaY + areaHeight - boidRadius * 2);
    boids.add(new Boid(x, y, boidRadius));
  } 
  else if (key == '-' || key == '_') {
    // Eliminar el último boid
    if (boids.size() > 0) {
      boids.remove(boids.size() - 1);
    }
  }
}

/*
 * MANEJADOR DE MOUSE
 * ==================
 */
void mousePressed() {
  // Verificar si el click está dentro del área
  if (mouseX > areaX && mouseX < areaX + areaWidth &&
      mouseY > areaY && mouseY < areaY + areaHeight) {
    boids.add(new Boid(mouseX, mouseY, boidRadius));
  }
}

