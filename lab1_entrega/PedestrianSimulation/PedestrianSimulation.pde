/*
 * SIMULACIÓN DE PEATONES CON DIAGRAMA FUNDAMENTAL
 * ================================================
 * Este programa simula el comportamiento de peatones con evitación de colisiones
 * y velocidad basada en densidad, implementando el diagrama fundamental de peatones.
 * 
 * El diagrama fundamental describe la relación entre densidad y velocidad:
 * - A mayor densidad → menor velocidad
 * - Modelo de Weidmann: v = v₀ × (1 - exp(-γ × (1/ρ - 1/ρₘₐₓ)))
 */

// ========================================
// VARIABLES GLOBALES
// ========================================

// Listas de agentes y datos
ArrayList<Pedestrian> pedestrians;    // Lista de todos los peatones
ArrayList<DataPoint> dataPoints;      // Puntos de datos para el gráfico
float simulationTime = 0;             // Tiempo transcurrido en segundos
int dataCollectionInterval = 30;      // Frames entre cada recolección de datos
int framesSinceLastCollection = 0;    // Contador de frames desde última recolección

// ========================================
// ÁREA DE SIMULACIÓN (corredor)
// ========================================
float corridorX = 50;                 // Posición X del corredor
float corridorY = 150;                // Posición Y del corredor
float corridorWidth = 700;            // Ancho del corredor
float corridorHeight = 550;           // Alto del corredor

// ========================================
// ÁREA DEL GRÁFICO (diagrama fundamental)
// ========================================
float graphX = 800;                   // Posición X del gráfico
float graphY = 150;                   // Posición Y del gráfico
float graphWidth = 350;               // Ancho del gráfico
float graphHeight = 200;              // Alto del gráfico

// ========================================
// PARÁMETROS DE SIMULACIÓN
// ========================================
int numPedestrians = 20;              // Número inicial de peatones
float pedestrianRadius = 8;           // Radio de cada peatón (píxeles)
float desiredSpeed = 1.34;             // Velocidad deseada en flujo libre (m/s → píxeles/frame)
float maxForce = 0.25;                // Fuerza máxima de steering (mayor = respuesta más rápida)

// ========================================
// OPCIONES DE VISUALIZACIÓN
// ========================================
boolean showVectors = false;          // Mostrar vectores de velocidad
boolean showDensityField = true;      // Mostrar campo de densidad
boolean showGraph = true;             // Mostrar diagrama fundamental

/*
 * CONFIGURACIÓN INICIAL
 * =====================
 * Se ejecuta una vez al inicio del programa.
 * Inicializa las listas y crea los peatones en posiciones aleatorias.
 */
void setup() {
  size(1200, 700);  // Ventana de 1200x700 píxeles
  
  // Inicializar listas vacías
  pedestrians = new ArrayList<Pedestrian>();
  dataPoints = new ArrayList<DataPoint>();
  
  // Crear peatones en posiciones aleatorias dentro del corredor
  for (int i = 0; i < numPedestrians; i++) {
    // Posición X aleatoria (con margen para evitar paredes)
    float x = random(corridorX + pedestrianRadius * 2, corridorX + corridorWidth - pedestrianRadius * 2);
    // Posición Y aleatoria (con margen para evitar paredes)
    float y = random(corridorY + pedestrianRadius * 2, corridorY + corridorHeight - pedestrianRadius * 2);
    // Añadir nuevo peatón a la lista
    pedestrians.add(new Pedestrian(x, y, pedestrianRadius));
  }
}

/*
 * BUCLE PRINCIPAL
 * ===============
 * Se ejecuta 60 veces por segundo.
 * Actualiza la física, recolecta datos y dibuja todo.
 */
void draw() {
  background(30, 35, 45);  // Fondo gris oscuro
  
  // Actualizar tiempo de simulación (asumiendo 60 FPS)
  simulationTime += 1.0/60.0;
  
  // Dibujar el corredor y la visualización de densidad
  drawCorridor();
  
  // Actualizar física de todos los peatones
  for (Pedestrian p : pedestrians) {
    p.update();
  }
  
  // Dibujar todos los peatones
  for (Pedestrian p : pedestrians) {
    p.display();
  }
  
  // Recolectar datos para el diagrama fundamental cada cierto intervalo
  framesSinceLastCollection++;
  if (framesSinceLastCollection >= dataCollectionInterval) {
    collectData();
    framesSinceLastCollection = 0;
  }
  
  // Dibujar el gráfico del diagrama fundamental (si está activado)
  if (showGraph) {
    drawFundamentalDiagram();
  }
  
  // Dibujar la interfaz de usuario (panel de control)
  drawUI();
}

/*
 * DIBUJAR CORREDOR
 * ================
 * Dibuja las fronteras del corredor y opcionalmente el campo de densidad.
 */
void drawCorridor() {
  pushStyle();
  
  // Dibujar bordes del corredor
  stroke(100, 150, 200);  // Azul claro
  strokeWeight(3);
  noFill();
  rect(corridorX, corridorY, corridorWidth, corridorHeight);
  
  // Visualización del campo de densidad (opcional)
  if (showDensityField) {
    int gridSize = 40;  // Tamaño de cada celda de la cuadrícula
    
    // Recorrer todas las celdas de la cuadrícula
    for (int x = 0; x < corridorWidth; x += gridSize) {
      for (int y = 0; y < corridorHeight; y += gridSize) {
        float px = corridorX + x + gridSize/2;  // Centro X de la celda
        float py = corridorY + y + gridSize/2;  // Centro Y de la celda
        
        // Contar cuántos peatones están en esta celda
        int count = 0;
        float radius = gridSize * 0.7;  // Radio de búsqueda
        for (Pedestrian ped : pedestrians) {
          if (dist(px, py, ped.position.x, ped.position.y) < radius) {
            count++;
          }
        }
        
        // Dibujar círculo rojo semitransparente si hay peatones
        if (count > 0) {
          float density = count / (PI * radius * radius / 10000.0);  // Normalizar
          float alpha = map(density, 0, 10, 0, 150);  // Opacidad según densidad
          fill(255, 100, 100, alpha);  // Rojo con alpha variable
          noStroke();
          ellipse(px, py, gridSize, gridSize);
        }
      }
    }
  }
  
  popStyle();
}

/*
 * RECOLECTAR DATOS
 * ================
 * Captura la densidad local y velocidad de cada peatón
 * para construir el diagrama fundamental.
 */
void collectData() {
  // Para cada peatón, calcular y guardar densidad local y velocidad
  for (Pedestrian p : pedestrians) {
    float localDensity = p.calculateLocalDensity();  // Densidad en ped/m²
    float velocity = p.velocity.mag();               // Magnitud de la velocidad
    
    // Guardar punto de datos (densidad, velocidad)
    dataPoints.add(new DataPoint(localDensity, velocity));
  }
  
  // Limitar cantidad de datos para evitar problemas de memoria
  // Mantener solo los últimos 5000 puntos
  while (dataPoints.size() > 5000) {
    dataPoints.remove(0);  // Eliminar el más antiguo
  }
}

/*
 * DIBUJAR DIAGRAMA FUNDAMENTAL
 * ============================
 * Dibuja el gráfico de densidad vs velocidad con:
 * - Línea verde: Modelo teórico de Weidmann (referencia)
 * - Puntos amarillos: Datos crudos de la simulación
 * - Línea roja: Promedio móvil de los datos simulados
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
  text("Fundamental Diagram", graphX + graphWidth/2, graphY - 15);
  
  // Etiqueta del eje X (horizontal)
  textSize(11);
  text("Density (ped/m²)", graphX + graphWidth/2, graphY + graphHeight + 25);
  
  // Etiqueta del eje Y (vertical, rotada)
  pushMatrix();
  translate(graphX - 30, graphY + graphHeight/2);
  rotate(-PI/2);
  text("Velocity (m/s)", 0, 0);
  popMatrix();
  
  // Dibujar ejes del gráfico
  stroke(150);
  strokeWeight(1);
  line(graphX, graphY + graphHeight, graphX + graphWidth, graphY + graphHeight); // Eje X
  line(graphX, graphY, graphX, graphY + graphHeight); // Eje Y
  
  // Dibujar marcas y valores en el eje X (densidad)
  fill(200);
  textAlign(CENTER, TOP);
  textSize(9);
  for (float d = 0; d <= 10; d += 2) {
    float x = map(d, 0, 10, graphX, graphX + graphWidth);
    // Marca en el eje
    stroke(150);
    line(x, graphY + graphHeight, x, graphY + graphHeight + 5);
    // Valor numérico
    noStroke();
    text(nf(d, 0, 0), x, graphY + graphHeight + 7);
  }
  
  // Dibujar marcas y valores en el eje Y (velocidad)
  textAlign(RIGHT, CENTER);
  textSize(9);
  for (float v = 0; v <= 2.5; v += 0.5) {
    float y = map(v, 0, 2.5, graphY + graphHeight, graphY);
    // Marca en el eje
    stroke(150);
    line(graphX - 5, y, graphX, y);
    // Valor numérico
    noStroke();
    text(nf(v, 0, 1), graphX - 8, y);
  }
  
  // Dibujar curva de referencia (modelo de Weidmann) - LÍNEA VERDE
  stroke(100, 255, 100, 80);  // Verde semitransparente
  strokeWeight(2);
  noFill();
  beginShape();
  for (float d = 0; d <= 10; d += 0.1) {
    float v = calculateWeidmannVelocity(d);  // Velocidad teórica
    float x = map(d, 0, 10, graphX, graphX + graphWidth);
    float y = map(v, 0, 2.5, graphY + graphHeight, graphY);
    vertex(x, y);
  }
  endShape();
  
  // Dibujar puntos de datos de la simulación - PUNTOS AMARILLOS
  for (DataPoint dp : dataPoints) {
    float x = map(dp.density, 0, 10, graphX, graphX + graphWidth);
    float y = map(dp.velocity, 0, 2.5, graphY + graphHeight, graphY);
    
    // Solo dibujar si está dentro de los límites del gráfico
    if (x >= graphX && x <= graphX + graphWidth && y >= graphY && y <= graphY + graphHeight) {
      stroke(255, 200, 0, 100);  // Amarillo semitransparente
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
  
  // Leyenda del gráfico
  textAlign(LEFT, CENTER);
  textSize(10);
  fill(100, 255, 100);
  text("Reference (Weidmann)", graphX + 10, graphY + 20);
  fill(255, 100, 100);
  text("Simulation (avg)", graphX + 10, graphY + 35);
  fill(255, 200, 0);
  text("Raw data", graphX + 10, graphY + 50);
  
  popStyle();
}

/*
 * CALCULAR VELOCIDAD SEGÚN MODELO DE WEIDMANN
 * ============================================
 * Modelo teórico que relaciona densidad con velocidad:
 * v = v₀ × (1 - exp(-γ × (1/ρ - 1/ρₘₐₓ)))
 * 
 * Parámetros:
 *   density - Densidad de peatones (ped/m²)
 * Retorna:
 *   Velocidad esperada según el modelo (m/s)
 */
float calculateWeidmannVelocity(float density) {
  // Parámetros del modelo de Weidmann
  float v0 = 1.34;      // Velocidad de flujo libre (m/s)
  float rhoMax = 5.4;   // Densidad máxima (ped/m²)
  float gamma = 1.913;  // Parámetro de ajuste del modelo
  
  // Si la densidad es máxima o superior, velocidad = 0
  if (density >= rhoMax) {
    return 0.0;
  }
  
  // Si la densidad es muy baja, velocidad de flujo libre
  if (density < 0.1) {
    return v0;
  }
  
  // Aplicar fórmula de Weidmann (decaimiento exponencial)
  float velocity = v0 * (1.0 - exp(-gamma * (1.0/density - 1.0/rhoMax)));
  
  return constrain(velocity, 0, v0);
}

/*
 * CALCULAR PROMEDIO MÓVIL
 * =======================
 * Divide el rango de densidad en bins y calcula el promedio
 * de velocidad en cada bin para suavizar los datos.
 * 
 * Retorna:
 *   Lista de puntos (densidad, velocidad promedio)
 */
ArrayList<PVector> calculateMovingAverage() {
  ArrayList<PVector> avgPoints = new ArrayList<PVector>();
  
  // Crear 20 bins (intervalos) para agrupar densidades similares
  int numBins = 20;
  float binWidth = 10.0 / numBins;  // Ancho de cada bin
  
  for (int i = 0; i < numBins; i++) {
    float minDensity = i * binWidth;        // Límite inferior del bin
    float maxDensity = (i + 1) * binWidth;  // Límite superior del bin
    
    float sumVelocity = 0;
    int count = 0;
    
    // Promediar todos los puntos que caen en este bin
    for (DataPoint dp : dataPoints) {
      if (dp.density >= minDensity && dp.density < maxDensity) {
        sumVelocity += dp.velocity;
        count++;
      }
    }
    
    // Solo incluir bins con suficientes datos (mínimo 5 puntos)
    if (count > 5) {
      float avgDensity = (minDensity + maxDensity) / 2;  // Centro del bin
      float avgVelocity = sumVelocity / count;           // Promedio
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
  
  // Panel de control (fondo semitransparente)
  fill(0, 0, 0, 180);
  noStroke();
  rect(10, 10, 280, 120);
  
  // Título
  fill(255);
  textAlign(LEFT, TOP);
  textSize(14);
  text("Pedestrian Simulation", 20, 20);
  
  // Estadísticas de la simulación
  textSize(11);
  fill(200);
  text("Pedestrians: " + pedestrians.size(), 20, 45);
  text("Data points: " + dataPoints.size(), 20, 60);
  text("Time: " + nf(simulationTime, 0, 1) + "s", 20, 75);
  
  // Instrucciones de control
  textSize(10);
  text("Controls:", 20, 95);
  text("  Click: Add pedestrian", 20, 108);
  text("  V: Toggle vectors | D: Toggle density | G: Toggle graph", 20, 121);
  text("  R: Reset | +/-: Add/Remove pedestrians", 20, 134);
  
  // Indicadores de estado (lado derecho)
  textAlign(RIGHT, TOP);
  fill(showVectors ? color(100, 255, 100) : color(100));
  text("Vectors: " + (showVectors ? "ON" : "OFF"), 270, 45);
  fill(showDensityField ? color(100, 255, 100) : color(100));
  text("Density: " + (showDensityField ? "ON" : "OFF"), 270, 60);
  fill(showGraph ? color(100, 255, 100) : color(100));
  text("Graph: " + (showGraph ? "ON" : "OFF"), 270, 75);
  
  popStyle();
}

/*
 * MANEJADOR DE TECLADO
 * ====================
 * Responde a las teclas presionadas por el usuario.
 */
void keyPressed() {
  if (key == 'v' || key == 'V') {
    // Alternar visualización de vectores
    showVectors = !showVectors;
  } 
  else if (key == 'd' || key == 'D') {
    // Alternar visualización del campo de densidad
    showDensityField = !showDensityField;
  } 
  else if (key == 'g' || key == 'G') {
    // Alternar visualización del gráfico
    showGraph = !showGraph;
  } 
  else if (key == 'r' || key == 'R') {
    // Reiniciar simulación completamente
    pedestrians.clear();
    dataPoints.clear();
    simulationTime = 0;
    
    // Crear nuevos peatones en posiciones aleatorias
    for (int i = 0; i < numPedestrians; i++) {
      float x = random(corridorX + pedestrianRadius * 2, corridorX + corridorWidth - pedestrianRadius * 2);
      float y = random(corridorY + pedestrianRadius * 2, corridorY + corridorHeight - pedestrianRadius * 2);
      pedestrians.add(new Pedestrian(x, y, pedestrianRadius));
    }
  } 
  else if (key == '+' || key == '=') {
    // Añadir un peatón en posición aleatoria
    float x = random(corridorX + pedestrianRadius * 2, corridorX + corridorWidth - pedestrianRadius * 2);
    float y = random(corridorY + pedestrianRadius * 2, corridorY + corridorHeight - pedestrianRadius * 2);
    pedestrians.add(new Pedestrian(x, y, pedestrianRadius));
  } 
  else if (key == '-' || key == '_') {
    // Eliminar el último peatón
    if (pedestrians.size() > 0) {
      pedestrians.remove(pedestrians.size() - 1);
    }
  }
}

/*
 * MANEJADOR DE MOUSE
 * ==================
 * Añade un peatón donde el usuario hace click (si está dentro del corredor).
 */
void mousePressed() {
  // Verificar si el click está dentro del corredor
  if (mouseX > corridorX && mouseX < corridorX + corridorWidth &&
      mouseY > corridorY && mouseY < corridorY + corridorHeight) {
    // Añadir peatón en la posición del mouse
    pedestrians.add(new Pedestrian(mouseX, mouseY, pedestrianRadius));
  }
}