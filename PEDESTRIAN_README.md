# Pedestrian Simulation with Fundamental Diagram

## 📋 Descripción

Este proyecto simula el comportamiento de peatones con colisiones internas, siguiendo el **diagrama fundamental** que describe la relación entre densidad y velocidad de peatones. El diagrama fundamental es un concepto clave en la dinámica de multitudes y describe cómo la velocidad de los peatones disminuye a medida que aumenta la densidad local.

## 🎯 Objetivos del Proyecto

1. **Simular peatones realistas** con colisiones y evitación
2. **Implementar el diagrama fundamental** (relación densidad-velocidad)
3. **Comparar resultados** con datos experimentales (Weidmann, Mori-Tsukaguchi)
4. **Visualizar en tiempo real** tanto la simulación como el diagrama fundamental

## 📊 Diagrama Fundamental

El diagrama fundamental describe tres relaciones clave:

1. **Velocidad vs Densidad**: A mayor densidad, menor velocidad
2. **Flujo vs Densidad**: El flujo (ρ × v) tiene un máximo óptimo
3. **Velocidad vs Flujo**: Relación derivada de las anteriores

### Modelo de Weidmann

Este proyecto implementa el modelo de Weidmann para la relación velocidad-densidad:

```
v = v₀ × (1 - exp(-γ × (1/ρ - 1/ρₘₐₓ)))
```

Donde:
- `v₀ = 1.34 m/s`: Velocidad de flujo libre
- `γ = 1.913`: Parámetro de ajuste
- `ρₘₐₓ = 5.4 ped/m²`: Densidad máxima

## 🎮 Controles

### Teclado

| Tecla | Acción |
|-------|--------|
| **V** | Activar/desactivar vectores de velocidad |
| **D** | Activar/desactivar campo de densidad |
| **G** | Activar/desactivar gráfico del diagrama fundamental |
| **R** | Reiniciar simulación |
| **+** | Añadir peatón |
| **-** | Eliminar peatón |

### Mouse

- **Click**: Añadir peatón en la posición del cursor (dentro del corredor)

## 🧠 Características Implementadas

### 1. Cálculo de Densidad Local

Cada peatón calcula su densidad local contando cuántos otros peatones están dentro de su **radio de visión**:

```processing
float density = numberOfNeighbors / area
```

### 2. Ajuste de Velocidad Basado en Densidad

La velocidad deseada se ajusta según la densidad local usando el modelo de Weidmann:

- **Baja densidad** (< 0.1 ped/m²): Velocidad libre
- **Media densidad** (0.1 - 5.4 ped/m²): Velocidad reducida exponencialmente
- **Alta densidad** (> 5.4 ped/m²): Velocidad mínima (casi detenido)

### 3. Evitación de Colisiones

Sistema **simplificado** con 3 mecanismos básicos que trabajan en conjunto:

#### a) Repulsión Simple
Fuerza de repulsión inversamente proporcional a la distancia:

```processing
float minDist = (radius + other.radius) × 2.5;
if (d < minDist) {
  strength = map(d, 0, minDist, maxForce × 5, 0);
  repulsion = (position - other.position).normalize() × strength;
}
```

**Cómo funciona:**
- Más cerca = más fuerza de repulsión
- Usa una interpolación lineal simple (`map`)
- Fácil de ajustar cambiando el multiplicador de `minDist`

#### b) Reducción de Velocidad
Los peatones frenan automáticamente cuando detectan otros cerca:

```processing
slowdownDistance = radius × 3.5;
if (minDistance < slowdownDistance) {
  speedReduction = map(minDistance, 0, slowdownDistance, 0.4, 1.0);
  adjustedSpeed *= speedReduction;
}
```

**Efecto:**
- Si otro peatón está muy cerca (d=0): velocidad reducida al 40%
- Si está en el límite (d=slowdownDistance): velocidad normal (100%)
- Transición suave entre ambos extremos

#### c) Separación Física
Si dos peatones se solapan físicamente, se separan de inmediato:

```processing
if (d < minDistance) {
  overlap = minDistance - d;
  direction = (position - other.position).normalize();
  position += direction × overlap × 0.5; // Cada uno se mueve la mitad
}
```

**Propósito:** Garantizar que nunca haya penetración visible entre peatones.

### 4. Espacio Personal

Cada peatón mantiene un "espacio personal" (≈ 2.5 × diámetro físico) que prefiere mantener libre. El sistema de repulsión simple mantiene esta distancia naturalmente.

### 5. Fuerzas de Frontera

Los peatones evitan los límites del corredor mediante fuerzas suaves que aumentan cerca de las paredes.

### 6. Comportamiento de Wandering

Los peatones cambian su dirección deseada ocasionalmente, simulando exploración o navegación hacia diferentes objetivos.

## 📈 Visualizaciones

### 1. Campo de Densidad

Muestra la densidad local en diferentes regiones del corredor mediante círculos semi-transparentes rojos. Mayor opacidad = mayor densidad.

### 2. Diagrama Fundamental en Tiempo Real

Gráfico que muestra tres tipos de datos:

- **Curva verde**: Modelo de referencia (Weidmann)
- **Puntos amarillos**: Datos instantáneos de cada peatón
- **Curva roja**: Promedio móvil de la simulación

### 3. Vectores de Velocidad

Flechas amarillas que muestran la dirección y magnitud de la velocidad de cada peatón.

### 4. Código de Color de Peatones

Los peatones cambian de color según su velocidad actual:
- **Rojo**: Detenido o muy lento
- **Verde**: A velocidad libre
- **Intermedio**: Velocidades medias

## 🔬 Comparación con Datos Reales

El proyecto compara los resultados con:

1. **Modelo de Weidmann**: Curva de referencia basada en estudios empíricos
2. **Datos de Mori y Tsukaguchi**: Referenciados en el paper de ResearchGate

### ¿Cómo evaluar el realismo?

La simulación es realista si:

1. La curva roja (simulación) se aproxima a la curva verde (referencia)
2. A baja densidad, los peatones se mueven a velocidad libre
3. A alta densidad, la velocidad disminuye significativamente
4. No hay interpenetración de peatones (colisiones físicas)

## 🛠️ Parámetros Ajustables

Puedes modificar estos parámetros en el código para experimentar:

### Parámetros Globales

```processing
int numPedestrians = 20;           // Número inicial de peatones
float pedestrianRadius = 8;         // Radio de cada peatón
float desiredSpeed = 1.6;           // Velocidad deseada (flujo libre) - OPTIMIZADO
float maxForce = 0.25;              // Fuerza máxima de steering - AUMENTADO
```

### Parámetros de Peatones

```processing
personalSpace = radius * 3.5;       // Espacio personal - OPTIMIZADO
visionRadius = radius * 10;         // Radio de visión
```

### Pesos de Fuerzas

En el método `update()` de la clase `Pedestrian`:

```processing
steeringForce.mult(0.5);           // Peso de dirección deseada - REDUCIDO
collisionForce.mult(10.0);         // Peso de evitación de colisión - MUY ALTO
boundaryForce.mult(2.5);           // Peso de fronteras
```

## 🔍 Detalles Técnicos

### Conversión de Unidades

- **1 metro = 50 píxeles**
- Las densidades se calculan en ped/m²
- Las velocidades internas están en píxeles/frame, convertidas conceptualmente a m/s

### Recolección de Datos

- Los datos se recolectan cada 30 frames
- Se almacenan hasta 5000 puntos (luego se eliminan los más antiguos)
- Cada punto representa (densidad_local, velocidad) de un peatón

### Promedio Móvil

El gráfico calcula un promedio móvil dividiendo el rango de densidad en 20 bins y promediando las velocidades en cada bin.

## 🚀 Mejoras Posibles

### 1. Diferentes Escenarios

- **Corredor unidireccional**: Todos los peatones van en la misma dirección
- **Flujo bidireccional**: Dos grupos caminando en direcciones opuestas
- **Intersecciones**: Peatones cruzando en diferentes ángulos
- **Evacuación**: Salida de emergencia (bottleneck)

### 2. Heterogeneidad

- Diferentes velocidades deseadas por peatón
- Diferentes radios (adultos, niños, personas con mochilas)
- Grupos sociales que se mantienen juntos

### 3. Modelos Adicionales

- Modelo de Fuerza Social (Helbing)
- Modelo de Autómata Celular
- Modelo de Campos de Costo

### 4. Métricas Adicionales

- Diagrama de flujo vs densidad
- Tiempo de evacuación
- Patrones de formación de carriles
- Análisis de clusters

## 📚 Referencias

### Papers Fundamentales

1. **Weidmann, U.** (1993). "Transporttechnik der Fussgänger"
   - Modelo fundamental de velocidad-densidad

2. **Mori, M. & Tsukaguchi, H.** (1987). "A new method for evaluation of level of service in pedestrian facilities"
   - Datos empíricos del diagrama fundamental

3. **Helbing, D. & Molnár, P.** (1995). "Social force model for pedestrian dynamics"
   - Modelo de fuerza social

### Recursos Adicionales

- ResearchGate: Fundamental diagrams and speed-density relations
- Pedestrian and Evacuation Dynamics Conference (PED)
- TraffGo HT: Pedestrian dynamics software

## 💡 Conceptos Clave

### Diagrama Fundamental

El diagrama fundamental es análogo al de tráfico vehicular, pero con características únicas:

- **Forma de la curva**: Típicamente exponencial decreciente
- **Velocidad libre**: 1.2 - 1.4 m/s para peatones
- **Densidad máxima**: 5-6 ped/m² (shoulder-to-shoulder)

### Diferencias con Boids

Los **Boids** (Reynolds) son buenos para simulación de bandadas, pero no para peatones porque:

1. No consideran el espacio personal de forma realista
2. No implementan el diagrama fundamental
3. Prioridad diferente en las fuerzas (cohesión vs evitación)
4. No modelan el comportamiento de frenado realista

### Comportamiento de Frenado

Los peatones no frenan instantáneamente:

1. Perciben la alta densidad adelante
2. Reducen gradualmente su velocidad deseada (hasta 40% en proximidad extrema)
3. Mantienen distancia de seguridad
4. Se detienen solo si es necesario

Este comportamiento está implementado mediante:
- Cálculo continuo de densidad local
- Ajuste suave de velocidad según el modelo de Weidmann
- Reducción dinámica de velocidad (desaceleración del 40-100%)
- Fuerzas de repulsión progresivas

## 🎓 Uso Académico

Este proyecto es ideal para:

- Estudios de dinámica de multitudes
- Comparación de modelos de peatones
- Análisis de seguridad (evacuaciones)
- Diseño de espacios públicos
- Investigación en simulación multi-agente

## 📊 Interpretación de Resultados

### Gráfico Ideal

Tu gráfico debería mostrar:

1. **Región de flujo libre** (densidad baja): Puntos cerca de v₀
2. **Región de transición** (densidad media): Curva decreciente
3. **Región congestionada** (densidad alta): Velocidades muy bajas

### Problemas Comunes

Si el gráfico no se parece al esperado:

1. **Demasiada dispersión**: Aumentar `dataCollectionInterval`
2. **No hay efecto de densidad**: Revisar cálculo de densidad local
3. **Colisiones constantes**: Aumentar `personalSpace` o `collisionForce`
4. **Movimiento no realista**: Ajustar pesos de fuerzas

## 🔧 Solución de Problemas

### Los peatones se atraviesan

**Este problema ha sido resuelto con el sistema simplificado:**
- ✅ Repulsión simple inversamente proporcional a la distancia
- ✅ Reducción dinámica de velocidad cerca de otros peatones (40-100%)
- ✅ Corrección directa de posición con `resolveCollisions()`
- ✅ Peso de colisión muy alto (10.0×)

Si aún ocurre, puedes:
- Aumentar aún más el peso de `collisionForce` (actualmente 10.0)
- Reducir `desiredSpeed` (actualmente 1.6)
- Aumentar `personalSpace` (actualmente radius × 3.5)

### El gráfico está vacío

- Esperar más tiempo (necesita recolectar datos)
- Verificar que hay suficientes peatones
- Ajustar los límites del gráfico

### Movimiento muy errático

- Reducir `maxForce`
- Aumentar la masa de los peatones
- Suavizar el cambio de dirección en wandering

## 📝 Notas de Implementación

### Por qué funciona

1. **Densidad local como señal**: Los peatones "sienten" la densidad a su alrededor
2. **Ajuste de velocidad basado en densidad**: La velocidad deseada se reduce según el diagrama fundamental
3. **Sistema simplificado de 3 mecanismos para colisiones**:
   - **Mecanismo 1**: Reducción dinámica de velocidad cerca de otros (40-100%)
   - **Mecanismo 2**: Fuerzas de repulsión simple lineales
   - **Mecanismo 3**: Corrección directa de posición para casos de solapamiento
4. **Fuerzas ponderadas**: Prioridad muy alta para colisión (10.0×) sobre dirección deseada (0.5×)
5. **Transiciones suaves**: Interpolación lineal simple usando `map()`

### Limitaciones

1. **2D simplificado**: No considera altura ni tercer dimensión
2. **Sin grupos sociales**: Los peatones son independientes
3. **Comportamiento homogéneo**: Todos tienen los mismos parámetros
4. **Sin obstáculos**: Solo hay paredes en los límites

---

**Autor**: Simulación de Peatones para el estudio del Diagrama Fundamental  
**Basado en**: Modelos de Weidmann y conceptos de dinámica de peatones  
**Framework**: Processing (Java)

---

## 🚀 Mejoras y Optimizaciones Implementadas

Esta implementación incluye varias mejoras sobre modelos básicos de peatones:

### 1. Sistema Simplificado de Repulsión
Se implementa una **repulsión lineal simple** que es fácil de entender y ajustar:
- Usa la función `map()` para interpolación lineal
- Más cerca = más fuerza de forma proporcional
- Sin ecuaciones complejas (exponenciales, cúbicas, etc.)

Esto crea un comportamiento predecible y fácil de parametrizar.

### 2. Reducción Dinámica de Velocidad
Los peatones reducen su velocidad **automáticamente** (40-100%) cuando detectan proximidad de otros, incluso antes de que las fuerzas de repulsión actúen. Esto es más realista que el comportamiento puramente reactivo.

### 3. Corrección de Posición Post-Física
Después de actualizar posiciones, se ejecuta una corrección directa que:
- Detecta penetraciones residuales
- Separa físicamente los peatones (50% cada uno)
- Garantiza **cero penetraciones** incluso a alta velocidad

### 4. Balanceo Optimizado de Fuerzas
Las fuerzas de colisión tienen **prioridad 20× superior** (10.0 vs 0.5) sobre el steering, garantizando que la evitación siempre prevalece sobre el objetivo de movimiento.

### 5. Velocidad Calibrada
La velocidad base está optimizada (1.6 m/s) para aproximarse mejor al modelo teórico de Weidmann en el diagrama fundamental.

## 🎯 Conclusión

Este proyecto demuestra que las **reglas simples de comportamiento individual** pueden generar patrones emergentes complejos que coinciden con datos empíricos reales. La clave está en:

1. **Calcular densidad local correctamente**
2. **Ajustar velocidad según densidad (diagrama fundamental)**
3. **Implementar evitación de colisiones con mecanismos simples y efectivos**
4. **Balancear las fuerzas apropiadamente con prioridad en seguridad**
5. **Usar interpolaciones lineales simples para transiciones naturales**

La comparación con el modelo de Weidmann te permite validar si tu simulación es realista. La línea roja (simulación) debería aproximarse a la línea verde (modelo teórico). ¡Experimenta con diferentes parámetros y escenarios!

