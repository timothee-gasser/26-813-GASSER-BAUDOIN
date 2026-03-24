
# 🔧 Configuration correcte NetFlow sur ton routeur

## 1. Créer un exporter

```bash
conf t

flow exporter EXPORTER
 destination 10.100.4.1
 transport udp 2055
 export-protocol netflow-v9
```

---

## 2. Créer un record

```bash
flow record RECORD
 match ipv4 source address
 match ipv4 destination address
 match transport source-port
 match transport destination-port
 match ip protocol
 collect counter bytes
 collect counter packets
```

---

## 3. Créer un monitor

```bash
flow monitor MONITOR
 record RECORD
 exporter EXPORTER
```

---

## 4. Appliquer sur les interfaces

```bash
interface GigabitEthernet1
 ip flow monitor MONITOR input
 ip flow monitor MONITOR output

interface GigabitEthernet2
 ip flow monitor MONITOR input
 ip flow monitor MONITOR output
```

