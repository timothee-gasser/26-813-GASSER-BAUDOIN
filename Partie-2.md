# Partie II : Supervision et métrologie avec SNMP

# 4.1 Configuration de SNMPv3 dans les routeurs

### Question 9 :
Commande pour obtenir le sysLcoccation de R1:
`snmpget -v3 -l authPriv -u snmpuser -a SHA -A auth_pass -x AES -X crypt_pass 10.100.4.252 SNMPv2-MIB::sysLocation.0`

Cette commande donne en sortie :
` SNMPv2-MIB::sysLocation.0 = STRING: Salle TP - Groupe 4`

---

### Question 10 :

SNMP utilise l'encodage ASN1 avec BER(Basic encoding rules)

---
