### Question 1 : 

Lorsque la topologie est complète et que le protocole OSPF a convergé, chaque routeur (R1 et R2) connaît l’ensemble des réseaux du réseau étendu.  
Pour nous, cela inclut le réseau interne `10.100.4.0/24`, le réseau de transit `10.250.0.0/24`, les réseaux internes des autres binômes, les réseaux du groupe professeur, ainsi que les adresses de loopback (/32) de tous les routeurs et les réseaux d’accès Internet.

En considérant 10 binômes étudiants et un groupe professeur, la table de routage d’un routeur contient :
- 1 réseau interne local,
- 1 réseau de transit,
- 10 réseaux internes des autres binômes,
- 1 réseau interne du groupe professeur,
- 22 routes de loopback (/32), (10 binômes de groupe + 1 Prof soit en tout 22 adresses)
- 2 réseaux d’accès Internet.

On obtient ainsi un total de 37 routes dans la table de routage de chaque routeur après convergence d’OSPF.

#### Exemple de table de routage partielle – Routeur R1

| Destination      | Next-hop                     | Coût |
|------------------|------------------------------|------|
| 10.100.4.0/24    | Direct (VLAN604 - LAN)       | 0    |
| 10.250.0.0/24    | Direct (réseau de transit)   | 0    |
| 10.10.4.1/32     | Direct (Loopback R1)         | 0    |
| 10.10.4.2/32     | via 10.250.0.8 (R2)          | 2    |
| 10.100.9.0/24    | via routeur Prof (OSPF)      | 2    |
| 192.168.140.0/23 | via RPROF1 (OSPF)            | 2    |
| 0.0.0.0/0        | via routeur de sortie (OSPF) | 2    |

#### Exemple de table de routage partielle – Routeur R2

| Destination      | Next-hop                     | Coût |
|------------------|------------------------------|------|
| 10.100.4.0/24    | Direct (VLAN604 - LAN)       | 0    |
| 10.250.0.0/24    | Direct (réseau de transit)   | 0    |
| 10.10.4.2/32     | Direct (Loopback R2)         | 0    |
| 10.10.4.1/32     | via 10.250.0.7 (R1)          | 2    |
| 10.100.1.0/24    | via OSPF (autre binôme)      | 2    |
| 192.168.176.0/24 | via RPROF2 (OSPF)            | 2    |
| 0.0.0.0/0        | via routeur de sortie (OSPF) | 2    |

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
Le commutateur apprend cette MAC virtuelle dans sa table de commutation et associe cette adresse MAC au port sur lequel est connecté le routeur master.  
Le routeur backup surveille le master grâce aux annonces VRRP périodiques.  
En cas de défaillance du master, le backup devient automatiquement master et reprend l’IP et la MAC virtuelles, ce qui provoque une mise à jour de la table de commutation du switch et garantit une bascule transparente pour les machines A et B.

---

### Question 4 :

Dans cette topologie, les routeurs R1 et R2 sont connectés au réseau interne 10.X.Y.0/24 et au réseau de transit 10.250.0.0/24, tandis que RPROF1 assure la sortie vers le réseau 192.168.176.0/24 et Internet.  
Le protocole OSPF permet à R1, R2 et RPROF1 d’échanger automatiquement leurs informations de routage afin que chaque routeur connaisse les réseaux accessibles (réseau interne, réseau de transit et réseau de sortie).  
Grâce à OSPF, si un lien entre R1, R2 et le réseau de transit devient indisponible, les routeurs recalculent automatiquement les chemins vers RPROF1.  
L’utilisation de routes statiques entre R1, R2 et RPROF1 nécessiterait une configuration manuelle sur chaque routeur et ne permettrait pas de s’adapter automatiquement aux pannes.  
OSPF est donc nécessaire dans cette topologie pour assurer un routage automatique et résilient vers le routeur de sortie RPROF1.

---

### Question 5 :

Test après configuration ip des interface : 

Depuis A ping → IP_Lo_R1(10.10.4.1) = OK

Depuis A ping → IP_Ext_R1(10.250.0.7) = OK

Depuis A ping → 8.8.8.8 = NOK

---

### Question 6 : 

Test fonctionnement OSPF :

show ip ospf neighbor = on voit les routes de nos voisin

ping A → IP_Lo_GRP6(10.10.6.1) = OK

ping A → 8.8.8.8 = OK0

ping A → IP_Lan_GRP9(10.100.9.254) = ok

ping R1 source lo → IP_Lan_GRP9(10.100.9.254) = ok

---

### Question 7 :
Commande saisie pour ce connectez directement sur R1 via le bastion.

`ssh -J etudiant@192.168.176.3:2222 admin@10.250.0.7`

---

### Question 8 :

Pour tester le fonctionnement de VRRP, nous lançons un ping continu depuis la machine A vers l’adresse 8.8.8.8, qui fonctionne correctement.  
Nous vérifions au préalable le rôle des routeurs à l’aide de la commande show vrrp brief afin d’identifier le routeur master.  
Nous éteignons ensuite le routeur master ; le second routeur passe automatiquement en master.  
Lors de cette bascule, nous observons une coupure d’environ 3 secondes, puis le ping depuis A vers Internet reprend normalement.  
Cette coupure est cohérente avec la configuration VRRP, car le temps de détection du master (Master Advertisement Interval) est d’environ 3,6 secondes.  
Nous vérifions également que le ping vers l’adresse IP virtuelle VRRP fonctionne toujours.  
Un traceroute vers 8.8.8.8 permet de vérifier par quel routeur transitent les paquets.  
Enfin, lorsque le routeur initial est rallumé, le routeur actuellement master repasse en backup et le routeur prioritaire redevient master ; lors de ce retour, nous observons une coupure d’environ une seconde.

Nous avons également vérifié le fonctionnement dans les autres cas de figure : coupure uniquement de l’interface LAN du routeur master, coupure de l’interface de transit vers l’extérieur, et arrêt du routeur backup.  
Dans tous les cas, l’état VRRP est contrôlé à l’aide de show vrrp brief et la continuité de service est validée par des pings continus vers internet.  
Nous avons aussi vérifié l’accessibilité des routeurs à partir des deux machines ainsi que la connectivité entre les deux routeurs à l’aide de pings avec adresse source.  
Enfin, nous avons contrôlé la résolution ARP de l’adresse IP virtuelle sur les machines afin de vérifier que la MAC virtuelle reste identique avant et après les bascules.


