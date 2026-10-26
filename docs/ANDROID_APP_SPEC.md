# English Pro — Spécification fonctionnelle Android

**Projet :** English Pro  
**Responsable du projet :** Joseph Marchand  
**Plateforme de la phase actuelle :** Android uniquement (APK installable).  
**Priorité technique :** apprentissage hors connexion, sauvegarde locale, interface adaptée aux écrans de téléphone.  
**Important :** ce document décrit le comportement attendu. Il ne signifie pas que ces fonctions sont déjà implémentées.

## 1. Parcours de première ouverture

1. Afficher un écran d’introduction court avec un drapeau américain, une animation légère et le texte « HELLO! WELCOME TO ENGLISH PRO ».
2. Afficher quelques salutations en anglais avec leur traduction, puis passer à la configuration initiale.
3. Demander le nom et la photo de profil. Le profil pourra être modifié plus tard.
4. Faire passer un test de positionnement progressif : vocabulaire, grammaire, lecture et compréhension. Ajouter une évaluation orale seulement si le dispositif et les outils disponibles la prennent réellement en charge.
5. Estimer un niveau de départ A1–C2 et expliquer le résultat. Le test ne doit pas permettre de sauter les sous-chapitres verrouillés.
6. Enregistrer localement le profil, le résultat de placement et la progression.

## 2. Accueil

L’accueil doit rester simple et ne pas afficher la liste des leçons.

Éléments attendus :
- Logo de l’application avec drapeau américain comme signe visuel principal.
- Nom et avatar de l’élève.
- Un grand bouton lumineux « COMMENCER » qui ouvre le parcours au bon endroit.
- XP, série quotidienne et progression globale, visibles sous le bouton.
- Accès aux paramètres et au profil en haut de l’écran.
- Aucun chapitre ni liste de leçons détaillée directement sur l’accueil.

Les boutons doivent avoir un libellé clair, un état actif et une fonction réelle. Les effets lumineux doivent rester lisibles et accessibles.

## 3. Parcours des niveaux et sous-chapitres

- Niveaux dans l’ordre : A1, A2, B1, B2, C1, C2.
- Objectif pédagogique : 500 leçons distinctes par niveau, en 10 sous-chapitres de 50 leçons.
- Un écran séparé par niveau ; un écran séparé par sous-chapitre ; une page de leçon individuelle.
- Le sous-chapitre 1 du niveau de départ est accessible après le test de positionnement.
- Les autres sous-chapitres sont verrouillés.
- Le sous-chapitre suivant ne s’ouvre qu’après validation des 50 leçons, des activités requises et d’une conversation de validation.
- Le niveau suivant s’ouvre après la validation du dixième sous-chapitre et de l’évaluation finale.
- Une progression déjà enregistrée doit être conservée si l’application est fermée ou redémarrée.
- Le système doit empêcher de contourner le verrouillage en appuyant sur une carte verrouillée ou en ouvrant un écran directement.

## 4. Lecteur de leçon

Chaque leçon doit présenter, dans cet ordre adapté à son contenu :
1. Objectif de la leçon.
2. Explications détaillées en français.
3. Exemples anglais-français avec contexte.
4. Prononciation écrite et audio américain lorsque les fichiers sont fournis.
5. Images, dessins, pictogrammes ou emojis utiles, surtout pour le vocabulaire concret des débutants.
6. Formes affirmatives, négatives, interrogatives et exemples de temps verbaux lorsqu’ils sont pertinents.
7. Exercices guidés, puis exercices autonomes.
8. Correction expliquée et résumé.
9. Activité corrective si l’élève fait une erreur.
10. Critères de réussite et enregistrement de la progression.

Le contenu doit rester spécifique à l’objectif. Les questions ne doivent pas être simplement répétées entre les étapes d’apprentissage, de pratique et de révision.

## 5. Quiz et erreurs

- Utiliser plusieurs types d’exercices : choix multiples, association, phrase à compléter, remise en ordre, traduction contextualisée, compréhension d’un dialogue et réponse libre lorsque la validation peut être faite correctement.
- La voix peut lire la question lorsque l’audio est disponible.
- Proposer un compte à rebours de 10 secondes dans les exercices qui le justifient, avec option de désactivation dans les réglages ou les activités de découverte.
- Après une mauvaise réponse, expliquer la règle, montrer un exemple correct et proposer un exercice ciblé.
- Ne pas punir les erreurs par une perte de progression déjà acquise.
- Définir des seuils de réussite explicites ; la simple réponse à une question ne doit pas valider une leçon entière.

## 6. Conversations et prononciation

- À la fin de chaque sous-chapitre, une conversation contextualisée doit vérifier l’usage réel des notions.
- Les conversations sont distinctes des quiz à choix multiples.
- Prévoir des dialogues avec personnages illustrés et petites animations légères quand elles sont utiles à la compréhension.
- Enregistrer la voix de l’élève uniquement avec une action explicite et indiquer clairement quand l’enregistrement commence et se termine.
- La reconnaissance vocale et l’évaluation automatique de prononciation doivent être activées seulement si une solution adaptée est disponible. Ne pas prétendre mesurer précisément l’accent si le système ne le permet pas.
- Priorité aux fichiers audio intégrés pour les phrases pédagogiques courantes, afin de permettre l’écoute hors ligne.

## 7. Vocabulaire et verbes

Chaque nouvelle entrée doit contenir :
- mot ou expression ;
- catégorie grammaticale ;
- sens et traduction en français ;
- prononciation ;
- exemple anglais naturel et traduction ;
- contexte d’utilisation ;
- formes grammaticales utiles, si applicable ;
- illustration ou pictogramme lorsqu’il apporte une aide réelle.

Les verbes doivent être traités de manière approfondie : base verbale, troisième personne, passé, participe passé lorsque pertinent, négations, questions, phrases d’exemple et expressions courantes. Un même mot peut réapparaître dans des révisions, dialogues et exemples, mais ne doit pas être réintroduit artificiellement comme une nouvelle entrée.

## 8. Chatbot pédagogique hors ligne

- L’assistant doit répondre à des questions d’élèves à partir d’une base pédagogique locale.
- Les réponses doivent être classées par thème, niveau, notion, erreurs courantes et formulations alternatives de questions.
- Objectif à long terme : une base de réponses riche pouvant atteindre 10 000 entrées si chacune apporte une réponse utile et vérifiée.
- Afficher une réponse honnête lorsque la question n’est pas couverte, plutôt que d’inventer une règle.
- Fournir des exemples, une explication simple et un renvoi vers la leçon correspondante.
- Une base locale de réponses n’équivaut pas à un modèle conversationnel général ; ses limites doivent être visibles.

## 9. Livre de référence

Ajouter une bibliothèque intégrée consultable par sections : grammaire, verbes, vocabulaire, expressions américaines, prononciation, erreurs fréquentes et fiches de révision. Le livre doit fonctionner hors ligne et utiliser les mêmes définitions validées que les cours afin d’éviter les contradictions.

## 10. Paramètres

Inclure :
- mode clair et mode sombre ;
- préférences sonores et volume ;
- notifications et rappels quotidiens ;
- choix de l’heure du rappel, activation/désactivation et jours ;
- objectif quotidien d’apprentissage ;
- préférences de quiz et compte à rebours ;
- gestion du profil et de la photo ;
- consultation de la progression ;
- aide et contact WhatsApp : +243 843478142 ;
- information de création : « CRÉÉ PAR JOSEPH MARCHAND — DÉVELOPPEUR » ;
- réinitialisation de la progression avec confirmation explicite ;
- informations de confidentialité et fonctionnement hors ligne.

## 11. Fonctionnement hors connexion

- Leçons, explications, quiz, progression et livre doivent être disponibles localement.
- Les préférences et les résultats doivent persister après fermeture de l’application.
- Les ressources audio et visuelles doivent être intégrées et optimisées, dans la limite de la taille du paquet.
- Toute fonction qui nécessite un service externe (par exemple une reconnaissance vocale avancée) doit être clairement distinguée des fonctions hors ligne.
- Aucun serveur payant ne doit être indispensable au parcours principal de l’apprenant.

## 12. Identité visuelle et ergonomie

- Palette lumineuse et attrayante, avec bleu, violet et touches dorées ; assurer un contraste suffisant.
- Boutons importants visibles et clairement étiquetés ; éviter les boutons décoratifs sans fonction.
- Mise en page adaptée aux petits écrans, sans titres coupés ni éléments qui sortent du cadre du téléphone.
- Navigation par écrans successifs ; ne pas afficher tous les niveaux, sous-chapitres et leçons sur une même page.
- Animations courtes, légères et pédagogiques ; éviter les ressources décoratives qui alourdissent l’application.
- Le drapeau américain peut être le symbole demandé, mais l’application reste une marque originale English Pro.

## 13. Tests obligatoires avant livraison

- Test de première ouverture, création du profil et test de positionnement.
- Vérification de chaque état verrouillé et déverrouillé.
- Vérification du passage sous-chapitre → conversation → validation → sous-chapitre suivant.
- Fermeture et réouverture de l’application pour vérifier la persistance.
- Utilisation en mode avion pour les fonctionnalités annoncées hors ligne.
- Test des rappels, des sons, du mode sombre, du profil et du contact.
- Vérification des erreurs de contenu, des réponses des quiz et des corrections.
- Compilation de l’APK release et installation réelle sur Android.
- Pas de déclaration de fonction terminée avant un test réel.

## 14. Ordre d’implémentation

1. Finaliser le plan des cours et rédiger les contenus A1.
2. Définir le format de données des leçons et le moteur de progression.
3. Créer le flux de première ouverture et le test de positionnement.
4. Refaire l’accueil et la navigation par niveaux/sous-chapitres.
5. Construire le lecteur de leçon, les corrections et les conversations de validation.
6. Ajouter XP, rappels, paramètres et livre.
7. Intégrer progressivement audio, illustrations et chatbot local.
8. Compiler et tester l’APK après chaque grande étape.

Aucune fonctionnalité ne doit être déclarée terminée simplement parce qu’un bouton ou un écran existe.
