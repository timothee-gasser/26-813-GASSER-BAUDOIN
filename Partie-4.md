# Partie IV : Projet Prometheus / Grafana / Netflow / Logs

### Question 24 : 


1. Installation de Docker sur les VM

Nous avons commencé par installer Docker sur la machine virtuelle (ici machine A).

Commandes : `
sudo dnf update -y
/ sudo dnf install -y dnf-plugins-core
/ sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
/ sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`

2. Création des fichiers YAML

Nous avons ensuite créé les fichiers de configuration YAML nécessaires au projet, notamment pour :

- Prometheus
- SNMP exporter
- Graphana

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

Exemple equête SNMP depuis Prometheus : `ifDescr / up`

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

<img width="1653" height="739" alt="image" src="https://github.com/user-attachments/assets/c4a83957-45b7-476d-bff1-ab42224864d0" />


Lorsque le test iperf a été arrêté, le trafic est revenu à la normale, ce qui a confirmé que la supervision fonctionnait correctement et reflétait bien l’activité réelle du réseau.



## Question 25 :

Prometheus est un système open source de monitoring conçu pour collecter, stocker et exploiter des métriques sous forme de séries temporelles. Son architecture repose sur un modèle de collecte de type pull : le serveur Prometheus interroge périodiquement les systèmes à superviser via des endpoints HTTP afin de récupérer leurs métriques. Chaque donnée collectée est horodatée et associée à des labels permettant d’identifier précisément l’origine, le type de ressource et le contexte de la mesure.

Le composant central est le serveur Prometheus. Celui-ci planifie les opérations de collecte (scrape), interroge les cibles configurées et stocke les résultats dans une base de données locale optimisée pour les séries temporelles (TSDB). Cette base est conçue pour gérer efficacement de grandes quantités de données numériques évoluant dans le temps, avec un accès rapide pour l’analyse historique ou temps réel.

Les éléments supervisés sont appelés targets. Il peut s’agir de serveurs, d’applications, de conteneurs, d’équipements réseau ou de services cloud. Les targets doivent exposer leurs métriques via un endpoint compatible avec Prometheus. Lorsque ce n’est pas possible, on utilise des exportateurs. Un exportateur est un composant intermédiaire chargé de récupérer des informations via un protocole spécifique (SNMP, système d’exploitation, base de données, etc.) et de les transformer en métriques compréhensibles par Prometheus.

Dans un contexte réseau, SNMP Exporter joue ce rôle en interrogeant les équipements via le protocole SNMP. Il récupère notamment les compteurs d’interface (octets entrants et sortants, erreurs, paquets, état du lien) et les convertit en métriques Prometheus. Cela permet de superviser des routeurs, commutateurs ou firewalls sans modifier leur configuration interne.

Prometheus fonctionne sans agent lourd installé sur les machines surveillées. La collecte s’effectue depuis le serveur central, ce qui simplifie le déploiement et la maintenance. Le fichier de configuration définit les cibles, les intervalles de collecte, les paramètres d’accès et les labels associés. Prometheus peut également utiliser des mécanismes de découverte automatique pour adapter dynamiquement la liste des cibles dans des environnements évolutifs.

Les données collectées sont stockées localement sur le serveur Prometheus. La rétention dépend de l’espace disque disponible et de la configuration choisie. Cette base permet d’analyser l’évolution des performances dans le temps, d’identifier des tendances ou de diagnostiquer des incidents passés.

Prometheus intègre également un système d’alerting. Des règles peuvent être définies pour détecter des situations anormales, par exemple une interface saturée, une machine indisponible ou une absence de trafic. Lorsqu’une condition est vérifiée pendant une durée donnée, une alerte est déclenchée. Ces alertes sont généralement envoyées vers Alertmanager, qui se charge de les regrouper, d’éviter les duplications et de les transmettre vers des canaux de notification externes (mail, messagerie, ticketing).

L’interface web de Prometheus permet d’explorer les métriques collectées et de tester des requêtes, mais elle reste limitée pour un usage opérationnel. Pour la visualisation avancée, on utilise généralement Grafana.

Grafana est une plateforme open source de visualisation de données capable de se connecter à de nombreuses sources, dont Prometheus. Elle permet de construire des tableaux de bord interactifs affichant les métriques sous forme de graphiques temporels, jauges, histogrammes ou tableaux. Les dashboards sont composés de panneaux indépendants, chacun exécutant une requête vers la source de données.

Grafana ne stocke pas les métriques lui-même ; il agit comme une couche d’affichage et d’analyse. Les utilisateurs peuvent créer des visualisations adaptées aux besoins opérationnels, par exemple l’utilisation CPU d’un serveur, le débit d’une interface réseau ou la disponibilité d’un service. Les dashboards peuvent être partagés entre utilisateurs et actualisés en temps réel.

Grafana permet également d’ajouter des variables pour filtrer dynamiquement les données (choix d’une machine, d’une interface ou d’un site). Cela facilite l’analyse d’infrastructures comportant de nombreux équipements. Des annotations peuvent être ajoutées pour marquer des événements importants, comme un déploiement ou une panne.

Dans un environnement de supervision réseau, la chaîne complète de fonctionnement est la suivante :

- les équipements réseau exposent des informations via SNMP  
- SNMP Exporter interroge ces équipements et convertit les OID en métriques Prometheus  
- le serveur Prometheus collecte régulièrement ces métriques et les stocke  
- Grafana interroge Prometheus pour afficher les données sous forme graphique  

Cette architecture permet de mesurer précisément les performances du réseau, notamment les débits d’interface, les taux d’erreur ou l’état des liens. En observant l’évolution des compteurs d’octets, il est possible de calculer le trafic réel et d’identifier les périodes de forte charge.

L’utilisation conjointe de Prometheus et Grafana est particulièrement adaptée aux infrastructures modernes, notamment virtualisées ou conteneurisées. Les deux outils sont open source, extensibles et largement adoptés dans les environnements DevOps et cloud-native. Leur déploiement sous forme de conteneurs Docker facilite la mise en place rapide d’une plateforme de supervision reproductible.

En résumé, Prometheus assure la collecte, le stockage et l’analyse des métriques, tandis que Grafana fournit une interface de visualisation avancée permettant d’exploiter ces données. Ensemble, ils constituent une solution complète de supervision technique capable de fournir une vision détaillée et en temps réel du fonctionnement d’un système ou d’un réseau.

