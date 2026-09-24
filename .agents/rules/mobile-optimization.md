---
trigger: always_on
---

- Evite alocação excessiva em `_process` ou `_physics_process`.
- Prefira eventos e sinais (Signals) em vez de polling constante.
