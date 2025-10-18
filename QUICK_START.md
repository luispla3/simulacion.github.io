# 🚀 Quick Start Guide - Simulación de Peatones

## ⚡ Inicio Rápido (3 minutos)

### 1. Abrir el Proyecto

```bash
# Opción A: Desde Processing IDE
File > Open > Seleccionar "PedestrianSimulation.pde"

# Opción B: Desde línea de comandos
processing-java --sketch=/ruta/al/proyecto --run
```

### 2. Ejecutar

Presiona el botón **"Run"** (▶️) o `Ctrl+R`

### 3. Interactuar

- **Click** en el corredor → Añade un peatón
- **Presiona +/-** → Añade/quita peatones
- **Presiona V** → Activa vectores de velocidad
- **Presiona D** → Activa campo de densidad
- **Presiona G** → Activa/desactiva gráfico

---

## 📊 ¿Qué estás viendo?

### Ventana de Simulación

```
┌─────────────────────────────────────────────────┐
│ [Panel Control]      [Corredor]         [Gráfico]│
│                                                   │
│ Pedestrians: 20      ░░░░░░░░░░░░        ┌─────┐│
│ Data: 450            ░🚶🚶░░░░░░        │  📈 ││
│                      ░░🚶░🚶░░░░        │     ││
│ Controls:            ░░░░🚶░░░░░        │     ││
│  Click: Add ped      ░░░░░🚶░░░░        └─────┘│
│  V: Vectors          ░░░░░░░🚶░░                 │
│  D: Density          ░░░░░░░░░░░                 │
│  G: Graph            ░░░░░░░░░░░                 │
└─────────────────────────────────────────────────┘
```

### Elementos Visuales

| Elemento | Significado |
|----------|-------------|
| 🔵 Peatón verde | Se mueve a velocidad libre (baja densidad) |
| 🔴 Peatón rojo | Detenido o muy lento (alta densidad) |
| 🟡 Círculos rojos transparentes | Campo de densidad (más opaco = más denso) |
| 📏 Flechas amarillas | Vectores de velocidad |
| 📊 Gráfico derecha | Diagrama fundamental (densidad vs velocidad) |

---

## 🎯 Experimentos Rápidos

### Experimento 1: Efecto de Densidad (2 min)

**Objetivo**: Ver cómo la densidad afecta la velocidad

1. **Ejecuta** la simulación
2. **Presiona D** para activar campo de densidad
3. **Presiona G** para ver el gráfico
4. **Añade muchos peatones** (presiona + varias veces o click múltiple)
5. **Observa**:
   - ¿Los peatones frenan en zonas densas? ✓
   - ¿El gráfico muestra curva decreciente? ✓
   - ¿Se forman "atascos"? ✓

**Resultado esperado**: 
- Más peatones → Mayor densidad roja
- Mayor densidad → Peatones más rojos (lentos)
- Gráfico muestra curva exponencial decreciente

---

### Experimento 2: Comparar con Referencia (3 min)

**Objetivo**: Validar que tu simulación se parece a datos reales

1. **Espera 30 segundos** para que se recolecten datos
2. **Observa el gráfico**:
   - 🟢 Línea verde = Modelo de Weidmann (referencia real)
   - 🟡 Puntos amarillos = Datos de tu simulación
   - 🔴 Línea roja = Promedio de tu simulación

3. **Pregunta clave**: ¿La línea roja se acerca a la línea verde?
   - ✅ **SÍ** → Tu simulación es realista
   - ❌ **NO** → Necesitas ajustar parámetros

**Interpretación**:

```
BUENO ✓                      MALO ✗
Velocidad                    Velocidad
    ^                            ^
v₀  |●▄                      v₀  |████████████
    |   ▀▄___                    |
    |        ▀▀▄___              |
    |            ▀▀▀             |
    +-------------->             +-------------->
         Densidad                     Densidad
```

---

### Experimento 3: Colisiones (1 min)

**Objetivo**: Verificar que no hay interpenetración

1. **Presiona R** para resetear
2. **Añade 50 peatones** (click múltiple o mantén +)
3. **Presiona V** para ver vectores
4. **Observa de cerca**: ¿Los peatones se atraviesan?
   - ✅ NO → Colisión funciona bien
   - ❌ SÍ → Aumenta `collisionForce.mult(X)` en el código

---

### Experimento 4: Cambiar Densidad en Tiempo Real (2 min)

**Objetivo**: Ver respuesta dinámica del sistema

1. **Empieza con pocos peatones** (5-10)
2. **Presiona D y G** para ver densidad y gráfico
3. **Gradualmente añade más** (presiona + cada 3 segundos)
4. **Observa cómo cambia**:
   - Color de peatones: Verde → Amarillo → Naranja → Rojo
   - Campo de densidad: Transparente → Opaco
   - Gráfico: Puntos se mueven hacia la derecha (mayor densidad)

---

## 🔧 Problemas Comunes y Soluciones

### ❌ "El gráfico está vacío"

**Causa**: No hay suficientes datos aún

**Solución**: 
- Espera 30-60 segundos
- Añade más peatones (mínimo 10)
- Verifica que `showGraph = true`

---

### ❌ "Los peatones se atraviesan"

**Causa**: Fuerza de colisión muy baja

**Solución**: En `PedestrianSimulation.pde`, línea ~217, cambia:
```processing
// ANTES:
collisionForce.mult(3.0);

// DESPUÉS:
collisionForce.mult(5.0);  // ← Aumenta este número
```

---

### ❌ "Movimiento muy errático/tembloroso"

**Causa**: Fuerzas demasiado fuertes para la masa

**Solución**: Reduce la fuerza o aumenta la masa:
```processing
// Opción A: Reducir fuerza
maxForce = 0.1;  // era 0.15

// Opción B: Aumentar masa
mass = PI * r * r * 2;  // era PI * r * r
```

---

### ❌ "El gráfico no se parece a la referencia"

**Causa posible 1**: Parámetros incorrectos

**Solución**: Verifica estos valores en el código:
```processing
desiredSpeed = 2.0;        // Velocidad base
personalSpace = r * 2.5;   // Espacio personal
visionRadius = r * 10;     // Radio de visión
```

**Causa posible 2**: No suficiente variedad de densidad

**Solución**: Varía la cantidad de peatones entre 5 y 60

---

## 🎮 Controles Completos

### Teclado

| Tecla | Acción | Efecto Visual |
|-------|--------|---------------|
| **V** | Toggle vectors | Muestra/oculta flechas amarillas |
| **D** | Toggle density | Muestra/oculta círculos rojos |
| **G** | Toggle graph | Muestra/oculta diagrama fundamental |
| **R** | Reset | Reinicia con configuración inicial |
| **+** | Add pedestrian | Añade 1 peatón aleatorio |
| **-** | Remove pedestrian | Quita 1 peatón |

### Mouse

| Acción | Efecto |
|--------|--------|
| **Click** dentro del corredor | Añade peatón en esa posición |
| **Click** fuera del corredor | Sin efecto |

---

## 📈 Entender el Gráfico

### Ejes

```
Velocidad (m/s)
    ^
2.5 |
    |
2.0 |
    |
1.5 |    🟢 Línea verde: Weidmann (referencia)
    |    🟡 Puntos amarillos: Datos instantáneos
1.0 |    🔴 Línea roja: Tu simulación (promedio)
    |
0.5 |
    |
0.0 +---------------------------------------->
    0   1   2   3   4   5   6   7   8   9  10
              Densidad (peatones/m²)
```

### Interpretación

| Región | Densidad | Velocidad | ¿Qué significa? |
|--------|----------|-----------|-----------------|
| **Flujo libre** | < 0.5 ped/m² | ≈ v₀ (máxima) | Peatones caminan libremente sin obstáculos |
| **Transición** | 0.5 - 2 ped/m² | v₀/2 | Empiezan a sentir presencia de otros |
| **Congestionado** | 2 - 4 ped/m² | v₀/4 | Deben frenar significativamente |
| **Atasco** | > 4 ped/m² | ≈ 0 | Casi detenidos, shoulder-to-shoulder |

### Curvas de Referencia

**🟢 Verde (Weidmann)**: Basada en datos experimentales de peatones reales en corredores. Es tu objetivo.

**Fórmula**:
```
v = 1.34 × (1 - exp(-1.913 × (1/ρ - 1/5.4)))
```

---

## 🎯 Objetivos de Validación

### ✅ Tu simulación es BUENA si:

1. **La curva roja sigue la verde** (RMSE < 0.3)
2. **No hay interpenetración** (peatones nunca se superponen)
3. **Frenado suave** (no hay cambios bruscos de velocidad)
4. **Colores coherentes** (Verde en baja densidad, rojo en alta)

### ⚠️ Necesitas mejorar si:

1. **Curva roja muy diferente a verde**
   → Ajusta `calculateSpeedFromDensity()`
   
2. **Peatones se atraviesan**
   → Aumenta peso de `collisionForce`
   
3. **Movimiento muy errático**
   → Reduce `maxForce` o aumenta `mass`
   
4. **No responden a densidad**
   → Verifica `calculateLocalDensity()`

---

## 📚 Siguientes Pasos

### Nivel Básico (ya funciona)
- ✅ Simulación funcional
- ✅ Colisiones
- ✅ Diagrama fundamental
- ✅ Visualizaciones

### Nivel Intermedio (lee `ADVANCED_FEATURES.md`)
- ⚙️ Añadir objetivos específicos
- ⚙️ Flujo bidireccional
- ⚙️ Diferentes tipos de peatones
- ⚙️ Exportar datos a CSV

### Nivel Avanzado
- 🔬 Modelo de Helbing (fuerza social)
- 🔬 Escenarios de evacuación
- 🔬 Análisis de formación de carriles
- 🔬 Validación con múltiples modelos

---

## 💡 Tips para Demos y Presentaciones

### Demo 1: "Efecto de Densidad" (30 seg)
1. Empieza con 5 peatones (todos verdes, rápidos)
2. Pausa y comenta: "Baja densidad, velocidad libre"
3. Añade hasta 40 peatones
4. Pausa y comenta: "Alta densidad, peatones frenan automáticamente"

### Demo 2: "Validación Científica" (1 min)
1. Muestra el gráfico
2. Señala la línea verde: "Este es el modelo de Weidmann, basado en datos reales"
3. Señala la línea roja: "Esta es nuestra simulación"
4. Comenta: "Como se ve, nuestra curva sigue la referencia, validando el realismo"

### Demo 3: "Diferencia con Boids" (1 min)
1. Abre `COMPARISON_BOIDS_VS_PEDESTRIANS.md`
2. Muestra tabla comparativa
3. Enfatiza: "Boids no considera densidad, por eso no sirve para peatones"

---

## 🆘 Soporte

### Si algo no funciona:

1. **Lee el error** en la consola de Processing
2. **Verifica** que Processing está actualizado (3.5+ recomendado)
3. **Revisa** `PEDESTRIAN_README.md` para detalles técnicos
4. **Consulta** `ADVANCED_FEATURES.md` para mejoras

### Archivos del Proyecto:

```
📁 Proyecto
├── 📄 PedestrianSimulation.pde  ← CÓDIGO PRINCIPAL (abre este)
├── 📄 QUICK_START.md            ← Esta guía
├── 📄 PEDESTRIAN_README.md      ← Documentación completa
├── 📄 COMPARISON_BOIDS_VS_PEDESTRIANS.md  ← Comparación
├── 📄 ADVANCED_FEATURES.md      ← Características avanzadas
└── 📄 pedestrian.properties     ← Configuración Processing
```

---

## ✨ Checklist de Primera Ejecución

- [ ] ✅ Abrí `PedestrianSimulation.pde` en Processing
- [ ] ✅ Presioné Run (▶️)
- [ ] ✅ Veo el corredor con peatones moviéndose
- [ ] ✅ Activé vectores (V) y veo flechas amarillas
- [ ] ✅ Activé densidad (D) y veo círculos rojos
- [ ] ✅ Activé gráfico (G) y veo 3 elementos (verde, amarillo, rojo)
- [ ] ✅ Añadí peatones con click y ví que aparecen
- [ ] ✅ Esperé 30 segundos y vi que el gráfico se llena de datos
- [ ] ✅ La curva roja se parece a la curva verde ✓

### Si completaste todos los pasos: ¡ÉXITO! 🎉

Tu simulación funciona correctamente. Ahora puedes:
- Experimentar con parámetros
- Implementar características avanzadas
- Exportar datos para análisis
- Crear tus propios escenarios

---

**¡Disfruta explorando la dinámica de peatones! 🚶‍♂️🚶‍♀️📊**

