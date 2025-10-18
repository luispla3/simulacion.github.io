// ========================================
// CLASE BOID
// ========================================
/*
 * Representa un boid individual con comportamiento de flocking.
 * Cada boid sigue 3 reglas simples:
 * 1. SEPARACIÓN: Evitar estar demasiado cerca de otros boids
 * 2. ALINEACIÓN: Moverse en la misma dirección que los vecinos
 * 3. COHESIÓN: Moverse hacia el centro de masa de los vecinos
 */
class Boid {
  // Propiedades físicas
  PVector position;      // Posición actual
  PVector velocity;      // Velocidad actual
  PVector acceleration;  // Aceleración actual
  float radius;          // Radio del boid
  
  // Visualización
  color boidColor;       // Color del boid
  
  /*
   * CONSTRUCTOR
   * ===========
   */
  Boid(float x, float y, float r) {
    position = new PVector(x, y);
    
    // Velocidad inicial aleatoria
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    velocity.mult(random(0.5, 1.5));
    
    acceleration = new PVector(0, 0);
    radius = r;
    
    // Color azul para boids
    boidColor = color(100, 150, 255);
  }
  
  /*
   * FLOCK - APLICAR REGLAS DE FLOCKING
   * ===================================
   * Calcula las fuerzas según las 3 reglas de Reynolds.
   */
  void flock(ArrayList<Boid> boids) {
    PVector separation = separate(boids);   // Regla 1: Separación
    PVector alignment = align(boids);       // Regla 2: Alineación
    PVector cohesion = cohere(boids);       // Regla 3: Cohesión
    PVector boundary = boundaries();        // Evitar paredes
    
    // Aplicar pesos a cada fuerza
    separation.mult(separationWeight);
    alignment.mult(alignmentWeight);
    cohesion.mult(cohesionWeight);
    boundary.mult(1.5);
    
    // Aplicar todas las fuerzas
    applyForce(separation);
    applyForce(alignment);
    applyForce(cohesion);
    applyForce(boundary);
  }
  
  /*
   * SEPARACIÓN
   * ==========
   * Evitar colisiones con vecinos cercanos.
   * Fuerza inversamente proporcional a la distancia.
   */
  PVector separate(ArrayList<Boid> boids) {
    PVector steer = new PVector(0, 0);
    int count = 0;
    
    // Revisar todos los otros boids
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      
      // Si está dentro del radio de separación
      if ((d > 0) && (d < separationRadius)) {
        // Vector que apunta alejándose del otro boid
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);  // Peso inversamente proporcional a la distancia
        steer.add(diff);
        count++;
      }
    }
    
    // Promediar
    if (count > 0) {
      steer.div(count);
    }
    
    // Implementar steering (Reynolds)
    if (steer.mag() > 0) {
      steer.normalize();
      steer.mult(maxSpeed);
      steer.sub(velocity);
      steer.limit(maxForce);
    }
    
    return steer;
  }
  
  /*
   * ALINEACIÓN
   * ==========
   * Moverse en la misma dirección que los vecinos.
   * Promediar las velocidades de los vecinos cercanos.
   */
  PVector align(ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      
      if ((d > 0) && (d < alignmentRadius)) {
        sum.add(other.velocity);
        count++;
      }
    }
    
    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(maxSpeed);
      
      // Steering = velocidad deseada - velocidad actual
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxForce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  /*
   * COHESIÓN
   * ========
   * Moverse hacia el centro de masa de los vecinos.
   */
  PVector cohere(ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      
      if ((d > 0) && (d < cohesionRadius)) {
        sum.add(other.position);
        count++;
      }
    }
    
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Dirigirse hacia ese punto
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  /*
   * SEEK - DIRIGIRSE HACIA UN OBJETIVO
   * ===================================
   * Comportamiento básico de steering hacia un punto.
   */
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);
    desired.normalize();
    desired.mult(maxSpeed);
    
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);
    return steer;
  }
  
  /*
   * BOUNDARIES - EVITAR PAREDES
   * ============================
   * Crear fuerza de repulsión cerca de las paredes.
   */
  PVector boundaries() {
    PVector force = new PVector(0, 0);
    float margin = 50;
    
    // Pared izquierda
    if (position.x < areaX + margin) {
      force.x = map(position.x, areaX, areaX + margin, maxForce * 2, 0);
    }
    
    // Pared derecha
    if (position.x > areaX + areaWidth - margin) {
      force.x = map(position.x, areaX + areaWidth - margin, 
                    areaX + areaWidth, 0, -maxForce * 2);
    }
    
    // Pared superior
    if (position.y < areaY + margin) {
      force.y = map(position.y, areaY, areaY + margin, maxForce * 2, 0);
    }
    
    // Pared inferior
    if (position.y > areaY + areaHeight - margin) {
      force.y = map(position.y, areaY + areaHeight - margin, 
                    areaY + areaHeight, 0, -maxForce * 2);
    }
    
    return force;
  }
  
  /*
   * APLICAR FUERZA
   * ==============
   */
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  
  /*
   * UPDATE - ACTUALIZAR POSICIÓN
   * =============================
   */
  void update() {
    // Actualizar velocidad
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    
    // Actualizar posición
    position.add(velocity);
    
    // Resetear aceleración
    acceleration.mult(0);
    
    // Asegurar que permanece dentro del área
    position.x = constrain(position.x, areaX + radius, areaX + areaWidth - radius);
    position.y = constrain(position.y, areaY + radius, areaY + areaHeight - radius);
    
    // Actualizar color según velocidad
    float speedRatio = velocity.mag() / maxSpeed;
    boidColor = lerpColor(color(100, 100, 255), color(100, 255, 255), speedRatio);
  }
  
  /*
   * CALCULAR DENSIDAD LOCAL
   * =======================
   * Calcula cuántos boids hay cerca para el diagrama fundamental.
   */
  float calculateLocalDensity() {
    int count = 0;
    float searchRadius = 80;  // Radio de búsqueda (píxeles)
    
    for (Boid other : boids) {
      if (other != this) {
        float d = PVector.dist(position, other.position);
        if (d < searchRadius) {
          count++;
        }
      }
    }
    
    // Calcular densidad (boids por metro cuadrado)
    // Conversión: 1 metro = 50 píxeles
    float metersRadius = searchRadius / 50.0;
    float area = PI * metersRadius * metersRadius;
    float density = count / area;
    
    return density;
  }
  
  /*
   * DISPLAY - DIBUJAR BOID
   * =======================
   */
  void display() {
    pushStyle();
    
    // Dibujar radio de percepción (si está activado)
    if (showNeighborhood) {
      noFill();
      stroke(255, 255, 0, 30);
      strokeWeight(1);
      ellipse(position.x, position.y, cohesionRadius * 2, cohesionRadius * 2);
    }
    
    // Dibujar cuerpo del boid (triángulo apuntando en dirección de movimiento)
    pushMatrix();
    translate(position.x, position.y);
    rotate(velocity.heading());
    
    // Triángulo
    fill(boidColor);
    stroke(255);
    strokeWeight(1);
    beginShape();
    vertex(radius * 1.5, 0);           // Punta
    vertex(-radius, radius * 0.7);     // Base izquierda
    vertex(-radius, -radius * 0.7);    // Base derecha
    endShape(CLOSE);
    
    popMatrix();
    
    // Dibujar vector de velocidad (si está activado)
    if (showVectors && velocity.mag() > 0.01) {
      stroke(255, 255, 0);
      strokeWeight(2);
      PVector vel = velocity.copy().mult(8);
      line(position.x, position.y, position.x + vel.x, position.y + vel.y);
    }
    
    popStyle();
  }
}

