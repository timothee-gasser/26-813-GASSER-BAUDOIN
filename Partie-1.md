### Question 1 : 

Lorsque la topologie est complète et que le protocole OSPF a convergé, chaque routeur (R1 et R2) connaît l’ensemble des réseaux du réseau étendu.  
Pour nous, cela inclut le réseau interne `10.100.4.0/24`, le réseau de transit `10.250.0.0/24`, les réseaux internes des autres binômes, les réseaux du groupe professeur, ainsi que les adresses de loopback (/32) de tous les routeurs et les réseaux d’accès Internet.

En considérant 10 binômes étudiants et un groupe professeur, la table de routage d’un routeur contient :
- 1 réseau interne local,
- 1 réseau de transit,
- 10 réseaux internes des autres binômes,
- 1 réseau interne du groupe professeur,
- 22 routes de loopback (/32),
- 2 réseaux d’accès Internet.

On obtient ainsi un total de 37 routes dans la table de routage de chaque routeur après convergence d’OSPF.

#### Exemple de table de routage partielle – Routeur R1

| Destination      | Next-hop                     | Coût |
|------------------|------------------------------|------|
| 10.100.4.0/24    | Direct (VLAN604 - LAN)       | /    |
| 10.250.0.0/24    | Direct (réseau de transit)   | /    |
| 10.10.4.1/32     | Direct (Loopback R1)         | /    |
| 10.10.4.2/32     | via 10.250.0.8 (R2)          | /    |
| 10.100.9.0/24    | via routeur Prof (OSPF)      | /    |
| 192.168.140.0/23 | via RPROF1 (OSPF)            | /    |
| 0.0.0.0/0        | via routeur de sortie (OSPF) | /    |

#### Exemple de table de routage partielle – Routeur R2

| Destination      | Next-hop                     | Coût |
|------------------|------------------------------|------|
| 10.100.4.0/24    | Direct (VLAN604 - LAN)       | /    |
| 10.250.0.0/24    | Direct (réseau de transit)   | /    |
| 10.10.4.2/32     | Direct (Loopback R2)         | /    |
| 10.10.4.1/32     | via 10.250.0.7 (R1)          | /    |
| 10.100.1.0/24    | via OSPF (autre binôme)      | /    |
| 192.168.176.0/24 | via RPROF2 (OSPF)            | /    |
| 0.0.0.0/0        | via routeur de sortie (OSPF) | /    |

---

### Question 2 : 

Le protocole VRRP permet de fournir une passerelle par défaut virtuelle aux machines du réseau local.
Deux routeurs partagent une adresse IP virtuelle associée à une adresse MAC virtuelle.
Un routeur est élu master, l’autre est backup.
VRRP assure ainsi une haute disponibilité de la passerelle sans modification de la configuration des hôtes.

---

### Question 3 : 

Les machines A et B utilisent comme passerelle l’adresse IP virtuelle VRRP.
Le routeur master répond aux requêtes ARP avec la MAC virtuelle VRRP et achemine le trafic.
Le routeur backup surveille le master grâce aux annonces VRRP périodiques.
En cas de défaillance du master, le backup devient automatiquement master et reprend l’IP et la MAC virtuelles, ce qui garantit une bascule transparente pour les machines A et B.

---

### Question 4 :

Dans ce réseau, de nombreux routeurs et réseaux sont interconnectés (binômes étudiants et routeurs professeurs).  
Le protocole OSPF permet à chaque routeur d’échanger automatiquement les informations de routage et de connaître l’ensemble des réseaux accessibles.  
Grâce à OSPF, les routes sont mises à jour dynamiquement et un nouveau chemin est recalculé automatiquement lorsqu’un lien ou un routeur devient indisponible.  
L’utilisation du routage statique ne serait pas pertinente car elle nécessiterait une configuration manuelle sur chaque routeur et ne permettrait pas de réagir automatiquement aux pannes.  
OSPF est donc nécessaire dans cette topologie réseau.

---

### Question 5 :

show ip int brief (R1) + ip a (A)

ping A → IP_LAN_R1(10.100.4.254) = OK
ping A → IP_Lo_R1(10.10.4.1) = OK
ping A → IP_Ext_R1(10.250.0.7) = OK
ping A → 8.8.8.8 = NOK
