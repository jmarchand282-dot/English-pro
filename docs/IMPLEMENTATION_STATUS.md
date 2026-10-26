# English Pro — État du projet et prochaines étapes

Dernière mise à jour : 2026-10-26

## État vérifié

- [x] Plan pédagogique A1 défini : 10 sous-chapitres de 50 leçons chacun.
- [x] Dix fichiers de contenu A1 créés dans `docs/lessons/`.
- [x] Décompte automatisé des fichiers : 50 leçons par sous-chapitre, soit 500 au total.
- [x] Cahier des charges Android enregistré dans `docs/ANDROID_APP_SPEC.md`.
- [x] Plan détaillé des objectifs A1 enregistré dans `docs/A1_CURRICULUM_PLAN.md`.
- [ ] Relecture pédagogique complète des 500 leçons.
- [ ] Vérification approfondie des réponses de quiz, des traductions et de la non-répétition du contenu.
- [x] Conversion des 500 brouillons A1 en données Dart structurées et branchement au moteur de cours.
- [x] Premier test de positionnement (8 questions) et création initiale du profil.
- [x] Refonte de l’accueil : bouton COMMENCER, XP, progression et accès aux paramètres.
- [x] Écrans séparés des niveaux, sous-chapitres et leçons, avec verrouillage séquentiel.
- [x] Moteur d’apprentissage : explication avant quiz, correction après erreur, nouvelle tentative et progression séquentielle.
- [ ] Conversations finales distinctes des quiz : à enrichir et tester dans l’application.
- [ ] Profil local avec nom et photo.
- [x] Mode sombre, rappel quotidien avec choix d’heure, sonnerie du rappel, objectif quotidien et contact.
- [x] Livre de référence consultable et JoBot local qui recherche dans le cours installé.
- [x] Lecture vocale, test de reconnaissance de prononciation à titre indicatif et pictogrammes pertinents ; reste à tester hors connexion.
- [ ] Compilation de l’APK release, installation et tests réels sur Android (compilation GitHub Actions en cours).

## Qualité du contenu — point important

Les 500 leçons existent maintenant sous forme de **premiers brouillons pédagogiques**. Le décompte a été vérifié, mais cela ne signifie pas que chaque leçon a déjà été relue par un enseignant ou testée dans l’application. En particulier, les activités d’intégration et certaines leçons de communication doivent être enrichies et contrôlées avant de les considérer comme définitives.

Le plan de départ prévoit des centaines de leçons distinctes par niveau. Seul le contenu A1 est actuellement rédigé en brouillon ; les contenus A2, B1, B2, C1 et C2 restent à produire selon la même méthode. Les fonctionnalités audio, reconnaissance de prononciation, animation et chatbot ne doivent pas être présentées comme disponibles avant leur intégration et leurs tests.

## Ordre de travail restant

1. Relire et améliorer les brouillons A1, en priorité les quiz, les explications après erreur et les conversations.
2. Définir un format de données structuré pour les leçons, leurs réponses, les médias et les critères de validation.
3. Intégrer le contenu A1 dans le moteur de cours Android.
4. Refaire les écrans et le verrouillage de progression conformément au cahier des charges.
5. Ajouter les fonctions de profil, paramètres et apprentissage hors connexion.
6. Compiler et tester l’APK sur Android avant de déclarer une fonction terminée.

## Paramètres produit à respecter

- Phase actuelle : application Android installable ; Web reporté.
- Hors connexion en priorité.
- Parcours A1 → A2 → B1 → B2 → C1 → C2.
- 10 sous-chapitres par niveau, 50 leçons par sous-chapitre comme objectif de contenu.
- Contact WhatsApp dans les paramètres : +243 843478142.
- Mention de création : « CRÉÉ PAR JOSEPH MARCHAND — DÉVELOPPEUR ».
