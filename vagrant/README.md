# GeoNature - tests via Vagrant

La box [Virtualbox](https://www.virtualbox.org/) est provisionnée par [Vagrant](https://www.vagrantup.com/) avec :
* GeoNature
* TaxHub
* UsersHub

Se reporter à la [documentation d'installation](https://docs.geonature.fr/installation.html) ou la  [page officielle du projet](https://geonature.fr/) pour plus d'information.

Les commandes sont exécutées dans le répertoire `vagrant`.

## Créer la box

Les variables définies dans le `Vagrantfile` permettent de créer
et de provisionner automatiquement la box en l'état. Si nécessaire, modifier les valeurs des variables
avant dans lancer le process :
```sh
vagrant up 2>&1 | tee up.log
```

Tester (admin/admin) :
* http://localhost:8881/geonature
* http://localhost:8881/taxhub
* http://localhost:8881/usershub

## Nettoyer

```sh
vagrant destroy -f
```

## Autres commandes Vagrant utiles
A exécuter dans le répertoire qui contient le `Vagrantfile` :
```sh
# Afficher l'aide
vagrant --help

# Démarrer la box
vagrant up

# Se connecter en ssh (box démarrée)
vagrant ssh

# Se connecter en ssh en root (box démarrée)
vagrant ssh -c "sudo su"

# Arrêter la box
vagrant halt
```
