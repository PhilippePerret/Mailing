# Mailing manuel

Ce petit module permet d’effectuer des mailings très facilement.

Utilisation simple :

~~~ruby
# Dans un fichier ruby

MAILS = ['mon.mail@chez.moi', 'autre.mail@chez.lui']
DATA_MAIL = {
	from: 'moi@chez.moi',
  subject: "Un message de mailing liste",
  message: "<p>Le message à envoyer</p>"
}

require '/Users/philippeperret/Programmes/Mailing/mailing.rb'

# => procède à l'envoi du message aux adresses de MAILS.
~~~

---

## Texte du message dans un fichier 

Le texte du message — qui doit toujours être en `HTML`, peut être spécifié dans un fichier, par son chemin d’accès absolu.

Si c’est un fichier `Markdown`, il sera transformé en code `HTML`.

---

## Sujet dans le fichier markdonw

Le sujet du message peut être stipulé dans le fichier `Markdown` grâce à une entête de métadonnée définissant `subject`.

~~~markdown
---
subject: Le sujet du message
---
Bonjour,

Vous allez recevoir ce message dont le titre est dans le fichier.
~~~



---

## Fichiers joints

On stipule les fichiers joints à envoyer dans la propriété `:attachments` des données du mail `DATA_MAIL`. 

C’est une liste `Array` dont chaque élément définit un fichier joint (on peut utiliser la propriété `attachment` — au singulier — s’il y a un seul fichier joint).

Chaque élément peut être simplement le chemin absolu du fichier si son nom dans le mail doit rester le même. Par exemple :

~~~ruby
DATA_MAIL = {
  from: 'phil@chez.lui',
  message: '/path/to/file.md',
  attachments: [
    '/path/to/image.jpg',
    '/path/to/fichier.pdf'
  ]
 }
~~~

Sinon, si le nom doit changer, on peut utiliser :

~~~ruby
DATA_MAIL = {
  from: 'phil@chez.lui',
  message: '/path/to/file.md',
  attachments: [
    {path:'/path/to/image.jpg', name:'autre-nom.jpg'},
    '/path/to/fichier.pdf'
  ]
 }
~~~

---

## Délai entre les envois

Par défaut, pour essayer d’éviter d’être pris pour un spam, les mails sont envoyés toutes les 30 secondes. On peut modifier ce temps en définissant `DELAI_ENTRE_MESSAGES` :

~~~ruby
# ...

DELAI_ENTRE_MESSAGES = 10 # secondes

require '/Users/philippeperret/Programmes/Mailing/mailing.rb'


~~~

