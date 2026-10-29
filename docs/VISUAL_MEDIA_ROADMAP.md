# English Pro — Feuille de route visuelle et multimédia

## Décision de la phase actuelle

Mettre en pause l'ajout de nouvelles leçons. Conserver les leçons intégrées et concentrer le travail sur l'identité visuelle, les médias pédagogiques et l'expérience utilisateur Android.

## Principes

- Android installable en priorité ; la version Web est reportée.
- Fonctionnement hors connexion prioritaire pour le parcours essentiel.
- Utiliser des images locales optimisées lorsque c'est possible.
- Les vidéos en ligne doivent afficher clairement qu'une connexion est nécessaire et proposer une expérience économe en données.
- Ne pas ajouter de dépendance lourde sans nécessité.
- Ne pas présenter une fonctionnalité comme terminée avant son intégration et son test sur Android.

## Priorités

### 1. Identité visuelle
- Créer une identité officielle English Pro avec un symbole EP distinctif.
- Harmoniser le bleu, le violet et l'or dans l'interface.
- Ajouter un logo réutilisable dans l'accueil et l'écran de démarrage.
- Préparer l'icône Android et vérifier qu'elle est réellement utilisée par le build.

### 2. Images pédagogiques
- Créer une bibliothèque d'images optimisées par thème : objets, école, corps humain, nourriture, ville, voyage, travail et émotions.
- Afficher une carte visuelle avec image, mot anglais, traduction française et bouton d'écoute.
- Prévoir un texte alternatif et un remplacement en cas d'image manquante.
- Garder les images essentielles dans les ressources locales pour l'usage hors ligne.

### 3. Vidéos
- Ajouter une rubrique Vidéos distincte du parcours principal.
- Organiser les vidéos par niveau et thème.
- Prévoir titre, durée, sous-titres ou transcription et niveau de difficulté.
- Les vidéos hébergées en ligne ne doivent pas bloquer les leçons hors connexion.
- N'utiliser que des vidéos autorisées ou créées pour l'application ; ne pas intégrer des liens non vérifiés.

### 4. Améliorations fonctionnelles
- Mieux organiser les accès à la bibliothèque, au livre de référence et à JoBot.
- Renforcer les exercices d'écoute et de prononciation.
- Améliorer les états de chargement, erreurs et absence de connexion.
- Tester profil, photo, progression, verrouillage, rappels, voix et redémarrage de l'application.

### 5. Contrôle qualité
- Lancer l'analyse Dart et les tests après chaque modification.
- Générer un APK de test après les changements significatifs.
- Tester sur un appareil Android réel.
- Garder la barrière de qualité des contenus ; ne pas falsifier ni affaiblir les tests de curriculum pour obtenir un build vert.

## Hors périmètre pour cette phase
- Ajouter davantage de leçons A2–C2.
- Publication sur le Play Store.
- Dépendance obligatoire à un serveur payant.
