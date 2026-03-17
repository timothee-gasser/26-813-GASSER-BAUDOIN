# Partie IV : Projet Prometheus / Grafana / Netflow / Logs

### Question 24 : Rédiger une procédure de tests et éventuellement de scripts de tests. 


1. Installation de Docker sur les VM

Nous avons commencé par installer Docker sur les différentes machines virtuelles.

Commandes : `
sudo dnf update -y
/ sudo dnf install -y dnf-plugins-core
/ sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
/ sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`

2. Création des fichiers YAML

Nous avons ensuite créé les fichiers de configuration YAML nécessaires au projet, notamment pour :

- Prometheus
- SNMP
- les autres services utiles à la supervision

Fichiers utilisés dans le projet :

- [`docker-compose.yml`](docker-compose.yml)
- [`prometheus.yml`](prometheus.yml)
- [`snmp.yml`](snmp.yml)

3. Vérification du démarrage des conteneurs Docker

Une fois les fichiers créés, nous avons lancé les conteneurs et vérifié qu’ils fonctionnaient correctement.

Commande : docker ps

4. Vérification de l’accès à Prometheus

Après le lancement des conteneurs, nous avons vérifié que Prometheus était bien accessible depuis un navigateur à l’adresse suivante :

- [Prometheus](http://192.168.141.112:9090)

Cette étape nous a permis de confirmer que le service était bien lancé et accessible sur le réseau.

5. Vérification de la récupération des interfaces avec SNMP

Nous avons ensuite utilisé les commandes `snmpwalk` pour vérifier que les interfaces réseau des équipements étaient bien détectées.

Cela nous a permis de confirmer que la collecte SNMP fonctionnait correctement et que les informations nécessaires à la supervision étaient bien disponibles.

Exemple de commande : `snmpwalk -v2c -c 123test123 10.100.4.253 ifDescr`

6. Liaison de Grafana avec Prometheus

Une fois la collecte vérifiée, nous avons relié Grafana à Prometheus afin de pouvoir afficher les métriques sous forme de Dashboard.

Grafana est accessible à l’adresse :

- [Grafana](http://192.168.141.112:3000)

Login : admin / Password : admin123

7. Création du dashboard Grafana

Nous avons ensuite créé un dashboard Grafana pour visualiser les métriques récupérées depuis Prometheus.

Fichers :

- [`dashboards/`](./dashboards/)

8. Test de charge avec iperf

Enfin, nous avons réalisé un test avec iperf entre nos deux PC de manière à faire passer le trafic par le routeur.

Pendant le test, nous avons observé sur le dashboard Grafana une augmentation de la charge réseau sur les interfaces concernées.

Lorsque le test iperf a été arrêté, le trafic est revenu à la normale, ce qui a confirmé que la supervision fonctionnait correctement et reflétait bien l’activité réelle du réseau.
