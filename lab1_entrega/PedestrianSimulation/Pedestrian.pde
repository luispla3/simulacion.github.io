// ========================================
// CLASE PEDESTRIAN (PEATÓN)
// ========================================
/*
 * Representa un peatón individual con física, comportamiento y visualización.
 * Cada peatón:
 * - Se mueve según fuerzas de steering
 * - Evita colisiones con otros peatones
 * - Ajusta su velocidad según la densidad local
 * - Respeta el diagrama fundamental de peatones
 */
class Pedestrian {
  // Propiedades físicas
  PVector position;      // Posición actual (x, y)
  PVector velocity;      // Velocidad actual (vector)
  PVector acceleration;  // Aceleración actual (se resetea cada frame)
  float radius;          // Radio del peatón (tamaño físico)
  float mass;            // Masa (proporcional al área)
  
  // Comportamiento
  PVector desiredVelocity;  // Dirección deseada de movimiento
  float personalSpace;      // Radio del espacio personal, solo se usa para dibujar el peaton
  float visionRadius;       // Distancia a la que percibe otros peatones, se usa para calcular localDensity
  
  // Visualización
  color pedColor;  // Color del peatón (cambia según velocidad)
  
  /*
   * CONSTRUCTOR
   * ===========
   * Inicializa un nuevo peatón en una posición dada.
   */
  Pedestrian(float x, float y, float r) {
    // Posición inicial
    position = new PVector(x, y);
    
    // Velocidad inicial aleatoria (pequeña)
    velocity = new PVector(random(-0.5, 0.5), random(-0.5, 0.5));
    
    // Sin aceleración inicial
    acceleration = new PVector(0, 0);
    
    // Propiedades físicas
    radius = r;
    mass = PI * r * r;  // Masa proporcional al área del círculo
    
    // Configurar espacio personal y visión
    personalSpace = r * 3.5;  // Radio del espacio personal preferido
    visionRadius = r * 10;    // Distancia de percepción de otros peatones
    
    // Dirección deseada inicial (wander - vagar)
    float angle = random(TWO_PI);  // Ángulo aleatorio
    desiredVelocity = new PVector(cos(angle), sin(angle));
    desiredVelocity.mult(desiredSpeed);
    
    // Color inicial
    pedColor = color(100, 150, 255);  // Azul
  }
  
  /*
   * UPDATE - ACTUALIZAR PEATÓN
   * ==========================
   * Método principal que se ejecuta cada frame.
   * Calcula todas las fuerzas, actualiza física y resuelve colisiones.
   */
  void update() {
    // ---- 1. CALCULAR DENSIDAD LOCAL ----
    float localDensity = calculateLocalDensity();
    
    // ---- 2. AJUSTAR VELOCIDAD SEGÚN DENSIDAD (DIAGRAMA FUNDAMENTAL) ----
    float adjustedSpeed = calculateSpeedFromDensity(localDensity);
    
    // ---- 3. REDUCCIÓN DINÁMICA DE VELOCIDAD (cuando hay peatones cerca) ----
    float minDistance = Float.MAX_VALUE;
    // Buscar el peatón más cercano
    for (Pedestrian other : pedestrians) {
      if (other != this) {
        float d = PVector.dist(position, other.position);
        if (d < minDistance) minDistance = d;
      }
    }
    // Si hay alguien muy cerca, reducir velocidad (50-85%)
    float slowdownDistance = radius * 1.5;
    if (minDistance < slowdownDistance) {
      float speedReduction = map(minDistance, 0, slowdownDistance, 0.5, 0.85);
      adjustedSpeed *= speedReduction;
    }
    
    // ---- 4. CALCULAR FUERZAS ----
    PVector steeringForce = calculateSteering(adjustedSpeed);     // Dirección deseada
    PVector collisionForce = calculateCollisionAvoidance();       // Evitar colisiones
    PVector boundaryForce = calculateBoundaryForce();             // Evitar paredes
    
    // Si hay una fuerza de pared significativa, cambiar dirección deseada para alejarse
    if (boundaryForce.mag() > maxForce * 0.5) {
      // Dirección deseada = mayormente alejarse de la pared + un poco de la velocidad actual
      PVector newDirection = boundaryForce.copy();
      newDirection.mult(3);  // Dar prioridad a alejarse
      newDirection.add(velocity);  // Sumar un poco de la dirección actual
      if (newDirection.mag() > 0.1) {
        newDirection.normalize();
        desiredVelocity.set(newDirection);
        desiredVelocity.mult(desiredSpeed);
      }
    }
    
    // ---- 5. APLICAR PESOS A LAS FUERZAS ----
    // La evitación de colisiones tiene máxima prioridad
    steeringForce.mult(6);   // Peso para steering (permite reaceleración)
    collisionForce.mult(16); // Peso ALTO para colisiones
    boundaryForce.mult(13);   // Peso medio para fronteras
    
    // Aplicar todas las fuerzas
    applyForce(steeringForce);
    applyForce(collisionForce);
    applyForce(boundaryForce);
    
    // ---- 6. ACTUALIZAR FÍSICA (integración de Euler) ----
    velocity.add(acceleration);        // v = v + a
    velocity.limit(adjustedSpeed);     // Limitar a velocidad máxima ajustada
    position.add(velocity);            // p = p + v
    acceleration.mult(0);              // Resetear aceleración para el próximo frame
    
    // ---- 7. CORRECCIÓN DE POSICIÓN (separar peatones solapados) ----
    resolveCollisions();
    
    // ---- 8. ACTUALIZAR DIRECCIÓN DESEADA (wander - vagabundeo) ----
    // 2% de probabilidad cada frame de cambiar ligeramente la dirección
    if (random(1) < 0.002) {
      float angle = velocity.heading() + random(-PI, PI);
      desiredVelocity.set(cos(angle), sin(angle));
      desiredVelocity.mult(desiredSpeed);
    }
    
    // ---- 9. ACTUALIZAR COLOR SEGÚN VELOCIDAD ----
    // Rojo = lento, Verde = rápido
    float speedRatio = velocity.mag() / desiredSpeed;
    pedColor = lerpColor(color(255, 100, 100), color(100, 255, 100), speedRatio);
  }
  
  /*
   * CALCULAR DENSIDAD LOCAL
   * =======================
   * Cuenta cuántos otros peatones hay dentro del radio de visión
   * y calcula la densidad en peatones/m².
   */
  float calculateLocalDensity() {
    // Contar peatones dentro del radio de visión
    int count = 0;
    float searchRadius = visionRadius;
    
    for (Pedestrian other : pedestrians) {
      if (other != this) {
        float d = PVector.dist(position, other.position);
        if (d < searchRadius) {
          count++;
        }
      }
    }
    
    // Calcular densidad (peatones por metro cuadrado)
    // Conversión: 1 metro = 50 píxeles
    float metersRadius = searchRadius / 50.0;
    float area = PI * metersRadius * metersRadius;  // Área del círculo
    float density = count / area;
    
    return density;
  }
  
  /*
   * CALCULAR VELOCIDAD SEGÚN DENSIDAD
   * ==================================
   * Aplica el modelo de Weidmann para ajustar la velocidad según
   * la densidad local. Implementa el DIAGRAMA FUNDAMENTAL.
   */
  float calculateSpeedFromDensity(float density) {
    // Parámetros del modelo
    float v0 = desiredSpeed;  // Velocidad de flujo libre
    float rhoMax = 5.4;       // Densidad máxima (ped/m²)
    float gamma = 1.913;      // Parámetro de ajuste
    
    // Densidad máxima → casi detenido
    if (density >= rhoMax) {
      return 0.1;
    }
    
    // Densidad muy baja → flujo libre
    if (density < 0.1) {
      return v0;
    }
    
    // Modelo de decaimiento exponencial de Weidmann
    float speed = v0 * (1.0 - exp(-gamma * (1.0/density - 1.0/rhoMax)));
    
    return constrain(speed, 0.1, v0);
  }
  
  /*
   * CALCULAR FUERZA DE STEERING
   * ============================
   * Calcula la fuerza necesaria para dirigirse hacia la velocidad deseada.
   */
  PVector calculateSteering(float targetSpeed) {
    // Crear vector de velocidad deseada con la magnitud objetivo
    PVector desired = desiredVelocity.copy();
    desired.setMag(targetSpeed);
    
    // Steering = velocidad deseada - velocidad actual
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);  // Limitar a la fuerza máxima permitida
    
    return steer;
  }
  
  /*
   * CALCULAR EVITACIÓN DE COLISIONES
   * =================================
   * Sistema de repulsión: fuerza inversamente proporcional
   * a la distancia. Más cerca = más fuerza de repulsión.
   */
  PVector calculateCollisionAvoidance() {
    PVector totalRepulsion = new PVector(0, 0);
    
    // Revisar todos los otros peatones
    for (Pedestrian other : pedestrians) {
      if (other != this) {
        float d = PVector.dist(position, other.position);
        float minDist = (radius + other.radius) * 1.5;  // Distancia mínima deseada
        
        // Si está dentro de la distancia mínima
        if (d < minDist && d > 0.01) {
          // Vector de repulsión (apunta alejándose del otro)
          PVector repulsion = PVector.sub(position, other.position);
          repulsion.normalize();
          
          // Fuerza inversamente proporcional a la distancia (interpolación lineal)
          // d=0 → fuerza máxima, d=minDist → fuerza = 0
          float strength = map(d, 0, minDist, maxForce * 17, 0);
          repulsion.mult(strength);
          totalRepulsion.add(repulsion);
        } 
        else if (d <= 0.01) {
          // Caso de emergencia: están exactamente en la misma posición
          // Empujar en dirección aleatoria
          PVector emergency = PVector.random2D();
          emergency.mult(maxForce * 10);
          totalRepulsion.add(emergency);
        }
      }
    }
    
    return totalRepulsion;
  }
  
  /*
   * RESOLVER COLISIONES
   * ===================
   * Separación física DIRECTA cuando dos peatones se solapan.
   * Este es el último recurso que garantiza cero penetraciones.
   */
  void resolveCollisions() {
    // Revisar todos los otros peatones
    for (Pedestrian other : pedestrians) {
      if (other != this) {
        float d = PVector.dist(position, other.position);
        float minDistance = radius + other.radius;  // Suma de los radios
        
        // Si se están solapando físicamente
        if (d < minDistance && d > 0.01) {
          float overlap = minDistance - d;  // Cantidad de solapamiento
          
          // Vector de separación
          PVector direction = PVector.sub(position, other.position);
          direction.normalize();
          
          // Mover este peatón la mitad del solapamiento
          // (el otro peatón se moverá su mitad cuando le toque)
          direction.mult(overlap * 0.5);
          position.add(direction);
        }
        else if (d <= 0.01) {
          // Caso extremo: exactamente en la misma posición
          PVector emergency = PVector.random2D();
          emergency.mult(radius);
          position.add(emergency);
        }
      }
    }
    
    // Asegurar que el peatón permanece dentro del corredor
    position.x = constrain(position.x, corridorX + radius, corridorX + corridorWidth - radius);
    position.y = constrain(position.y, corridorY + radius, corridorY + corridorHeight - radius);
  }
  
  /*
   * CALCULAR FUERZA DE PAREDES
   * =============================
   * Crea una fuerza de repulsión suave cerca de las paredes del corredor.
   * La fuerza aumenta gradualmente al acercarse a la pared.
   */
  PVector calculateBoundaryForce() {
    PVector force = new PVector(0, 0);
    float margin = radius * 10;  // Zona de influencia de la pared (aumentada)
    
    // Pared izquierda
    if (position.x < corridorX + margin) {
      force.x = map(position.x, corridorX, corridorX + margin, maxForce * 2, 0);
    }
    
    // Pared derecha
    if (position.x > corridorX + corridorWidth - margin) {
      force.x = map(position.x, corridorX + corridorWidth - margin, 
                    corridorX + corridorWidth, 0, -maxForce * 2);
    }
    
    // Pared superior
    if (position.y < corridorY + margin) {
      force.y = map(position.y, corridorY, corridorY + margin, maxForce * 2, 0);
    }
    
    // Pared inferior
    if (position.y > corridorY + corridorHeight - margin) {
      force.y = map(position.y, corridorY + corridorHeight - margin, 
                    corridorY + corridorHeight, 0, -maxForce * 2);
    }
    
    return force;
  }
  
  /*
   * APLICAR FUERZA
   * ==============
   * Añade una fuerza a la aceleración del peatón.
   * Usa la segunda ley de Newton: F = m×a → a = F/m
   */
  void applyForce(PVector force) {
    PVector f = force.copy();
    f.div(mass);            // a = F / m
    acceleration.add(f);    // Acumular aceleración
  }
  
  /*
   * DISPLAY - DIBUJAR PEATÓN
   * =========================
   * Dibuja el peatón y opcionalmente su espacio personal y vectores.
   */
  void display() {
    pushStyle();
    
    // Dibujar espacio personal (solo si se muestran vectores)
    if (showVectors) {
      noFill();
      stroke(255, 255, 0, 50);  // Amarillo semitransparente
      strokeWeight(1);
      ellipse(position.x, position.y, personalSpace * 2, personalSpace * 2);
    }
    
    // Dibujar cuerpo del peatón (círculo)
    fill(pedColor);  // Color según velocidad
    stroke(255);     // Borde blanco
    strokeWeight(1);
    ellipse(position.x, position.y, radius * 2, radius * 2);
    
    // Dibujar indicador de dirección (flecha)
    if (velocity.mag() > 0.1) {
      pushMatrix();
      translate(position.x, position.y);
      rotate(velocity.heading());  // Rotar según dirección de movimiento
      
      // Línea de la flecha
      stroke(255);
      strokeWeight(2);
      line(0, 0, radius, 0);
      
      // Punta de la flecha
      fill(255);
      noStroke();
      triangle(radius, 0, radius - 4, -2, radius - 4, 2);
      
      popMatrix();
    }
    
    // Dibujar vector de velocidad (solo si está activado)
    if (showVectors && velocity.mag() > 0.01) {
      stroke(255, 255, 0);  // Amarillo
      strokeWeight(2);
      PVector vel = velocity.copy().mult(5);  // Amplificar para visualización
      line(position.x, position.y, position.x + vel.x, position.y + vel.y);
    }
    
    popStyle();
  }
}

