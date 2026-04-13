# 26-813-GASSER-BAUDOIN - Groupe 4

[Partie I – Etude théorique préparatoire](Partie-1.md)

[Partie II – Supervision et métrologie avec SNMP](Partie-2.md)

[Partie III – Script bash de mesure de débit en SNMP](Partie-3.md)

[Partie IV –  Projet Prometheus / Grafana / Netflow / Logs](Partie-4.md)

[Schema Réseau](etrs813_schema.png)


---

## Architecture des dossiers

```text
26-813-GASSER-BAUDOIN-main/
├── README.md                         # Fichier principal du projet
├── Partie-1.md                       # Étude théorique préparatoire
├── Partie-2.md                       # Supervision et métrologie avec SNMP
├── Partie-3.md                       # Script Bash de mesure de débit SNMP
├── Partie-4.md                       # Projet Prometheus / Grafana / NetFlow / Logs
├── etrs813_schema.png                # Schéma réseau du projet
│
├── grafana/                          # Dashboards Grafana exportés en JSON
│   ├── Ktranslate.json               # Dashboard lié aux métriques NetFlow / ktranslate
│   ├── Supervision_Routeurs_Cisco_SNMP.json
│   │                                 # Dashboard de supervision SNMP des routeurs Cisco
│   ├── Supervision_Web_Blackbox.json # Dashboard de supervision HTTP via Blackbox Exporter
│   └── Supervision_machine_B.json    # Dashboard de supervision système de la machine B
│
├── machine_A/                        # Scripts et stack de supervision côté machine A
│   ├── snmp-1.sh                     # Script initial de mesure / évolution du débit en SNMP
│   ├── snmp-4.sh                     # Version améliorée du script SNMP
│   ├── snmp_generic.sh               # Version générique du script de mesure SNMP
│   │
│   └── monitoring/                   # Environnement Docker de supervision principal
│       ├── docker-compose.yml        # Déploiement Prometheus, SNMP Exporter, Grafana, ktranslate
│       ├── prometheus/
│       │   └── prometheus.yml        # Configuration des jobs Prometheus
│       └── snmp_exporter/
│           └── snmp.yml              # Configuration SNMP Exporter (modules / auth / OID)
│
└── machine_B/                        # Services supervisés sur la machine B
    ├── docker-compose.yml            # Déploiement du serveur web, node-exporter, blackbox-exporter
    ├── docker-compose_web.yml        # Variante de déploiement web + node-exporter
    ├── blackbox.yml                  # Configuration des sondes HTTP Blackbox Exporter
    ├── index.html                    # Page d’accueil du serveur web
    ├── page1.html                    # Page de test 1
    ├── page2.html                    # Page de test 2
    ├── script_ktranslate.sh          # Génération de trafic HTTP pour tests NetFlow
    ├── test_cpu_load.sh              # Script de charge CPU pour tests de supervision
    ├── test_http_load.sh             # Script de charge HTTP
    └── test_page1_down.sh            # Script simulant l’indisponibilité d’une page
```

---

