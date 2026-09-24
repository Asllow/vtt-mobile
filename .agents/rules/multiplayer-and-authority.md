---
trigger: always_on
---

- O servidor/host é a ÚNICA fonte de verdade. Clientes apenas enviam requisições (@rpc("any_peer", "call_remote", "reliable")).
- O broadcast de estado deve vir exclusivamente do servidor (@rpc("authority", "call_remote", "reliable")).
- Nunca confie em coordenadas vindas do cliente; valide se a célula está dentro dos limites (GridManager.is_cell_valid()).
