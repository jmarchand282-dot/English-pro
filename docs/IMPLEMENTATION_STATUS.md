# English Pro — État du projet et prochaines étapes

Dernière mise à jour : 2026-10-30

## État vérifié

- [x] Plan pédagogique A1 défini : 10 sous-chapitres de 50 leçons chacun.
- [x] Dix fichiers de contenu A1 créés dans `docs/lessons/`.
- [x] Décompte automatisé des fichiers : 50 leçons par sous-chapitre, soit 500 au total.
- [x] Cahier des charges Android enregistré dans `docs/ANDROID_APP_SPEC.md`.
- [x] Plan détaillé des objectifs A1 enregistré dans `docs/A1_CURRICULUM_PLAN.md`.
- [ ] Relecture pédagogique complète des 500 leçons.
- [ ] Ajouter plusieurs exercices variés par leçon (le prototype actuel a un quiz principal par leçon).
- [x] Contrôle automatique de l’unicité des titres, questions, exemples et explications A1 ajouté aux tests CI.
- [ ] Vérification pédagogique approfondie des réponses, traductions, distracteurs et naturel de l’anglais.
- [x] Conversion des 500 brouillons A1 en données Dart structurées et branchement au moteur de cours.
- [x] Premier test de positionnement (8 questions) et création initiale du profil.
- [x] Refonte de l’accueil : bouton COMMENCER, XP, progression et accès aux paramètres.
- [x] Écrans séparés des niveaux, sous-chapitres et leçons, avec verrouillage séquentiel.
- [x] Après la validation réussie d'un sous-chapitre, fermeture automatique de son écran et ouverture du sous-chapitre suivant ; analyse Dart passée sur le commit `dc4a18d`.
- [x] Règles de verrouillage corrigées : une conversation de validation est requise avant le sous-chapitre suivant et toutes les conversations d’un niveau avant le niveau suivant.
- [x] Moteur d’apprentissage : explication avant quiz, correction après erreur, nouvelle tentative et progression séquentielle.
- [x] Conversation guidée distincte du quiz à la fin de chaque sous-chapitre ; à tester en situation réelle.
- [x] Profil local avec nom et photo (à confirmer lors d’un test sur téléphone).
- [x] Mode sombre, rappel quotidien avec choix d’heure, sonnerie du rappel, objectif quotidien et contact.
- [x] Livre de référence consultable et JoBot local qui recherche dans le cours installé.
- [x] Correction d'un défaut de recherche JoBot : les champs de leçon sont désormais réellement analysés au lieu de chaînes de substitution littérales ; synonymes français supplémentaires ajoutés (commit `22f574d`).
- [x] Lecture vocale, test de reconnaissance de prononciation à titre indicatif et pictogrammes pertinents ; reste à tester hors connexion.
- [x] Pipeline CI : analyse Dart, tests automatisés du programme A1, puis compilation APK (à confirmer sur le dernier commit).
- [ ] Installation et tests réels sur Android : profil/photo, progression, conversations, rappels et fonctions vocales.

## Comptage réel des leçons actuellement intégrées

| Niveau | Leçons intégrées actuellement | Objectif | État |
|---|---:|---:|---|
| A1 | 500 | 500 | Brouillons intégrés ; relecture pédagogique encore requise |
| A2 | 250 | 500 | 250 leçons rédigées dans les unités 1 à 5 ; 5 unités restent à créer |
| B1 | 30 | 500 | Incomplet |
| B2 | 30 | 500 | Incomplet |
| C1 | 30 | 500 | Incomplet |
| C2 | 30 | 500 | Incomplet |



**Barrière de livraison ajoutée le 27 octobre 2026 :** les tests CI exigent désormais, pour chacun des six niveaux, exactement 500 leçons, 10 sous-chapitres de 50 et 500 titres, questions, exemples et explications distincts. Le pipeline doit échouer tant que les contenus actuels ne satisfont pas ces critères. Un APK compilé avant réussite de ces contrôles n’est pas une livraison finale.

A2 compte maintenant 250 leçons réparties dans cinq unités : passé, projets futurs, comparaisons, présent perfect et communication quotidienne, puis plans et interactions futures. Les cinq autres unités A2 restent à créer. Les niveaux A2 à C2 ne doivent pas être présentés comme terminés. Leurs petites banques actuelles sont des prototypes, pas les 500 leçons promises par le cahier des charges. En outre, plusieurs entrées actuelles A2–C2 sont générées comme variantes « Learn / Practice / Review » d’une même question; le nombre de lignes ne signifie donc pas que le contenu pédagogique est distinct. Ces banques doivent être remplacées par des leçons et exercices réellement différents.

## Phase visuelle et multimédia — travaux en cours

- [x] Feuille de route visuelle et multimédia créée dans `docs/VISUAL_MEDIA_ROADMAP.md`.
- [x] Marque vectorielle English Pro ajoutée à l’en-tête et à l’accueil ; elle ne dépend pas d’une image distante.
- [x] Accès « Images & mots » et « Vidéos » ajouté à l’accueil.
- [x] Première grille de 12 cartes de vocabulaire illustrées avec prononciation TTS ; cartes utilisables hors connexion.
- [x] Première rubrique vidéo avec recherches YouTube externes et avertissement clair sur la connexion nécessaire.
- [ ] Vérifier l’analyse Dart, les tests et la compilation APK sur le commit multimédia.
- [x] Analyse Dart passée et APK de test généré sur le commit `dc4a18d` ; les tests curriculum restent en échec car A2–C2 sont incomplets. Le nouvel essai après correction JoBot est en cours.
- [ ] Tester l’interface sur un téléphone Android, notamment la prononciation et l’ouverture des liens vidéo.
- [ ] Remplacer progressivement les pictogrammes par des illustrations pédagogiques originales optimisées, puis vérifier leur poids et leur affichage hors connexion.

## Qualité du contenu — point important

Les 500 leçons existent maintenant sous forme de **premiers brouillons pédagogiques**. Le décompte a été vérifié, mais cela ne signifie pas que chaque leçon a déjà été relue par un enseignant ou testée dans l’application. En particulier, les activités d’intégration et certaines leçons de communication doivent être enrichies et contrôlées avant de les considérer comme définitives.

Le plan de départ prévoit des centaines de leçons distinctes par niveau. Seul le contenu A1 est actuellement rédigé en brouillon ; les contenus A2, B1, B2, C1 et C2 restent à produire selon la même méthode. Les fonctionnalités audio, reconnaissance de prononciation, animation et chatbot ne doivent pas être présentées comme disponibles avant leur intégration et leurs tests.

## Ordre de travail restant

1. Terminer la vérification CI du commit `22f574d` (analyse, tests et compilation) et corriger toute régression.
2. Relire pédagogiquement les 500 leçons A1 : exactitude grammaticale, traductions, distracteurs et exemples américains naturels.
3. Ajouter plusieurs exercices réellement distincts par leçon et renforcer les activités correctives.
4. Écrire et intégrer 500 leçons distinctes pour chacun des niveaux A2, B1, B2, C1 et C2 ; la feuille de route seule ne remplace pas ces contenus.
5. Installer l’APK sur un téléphone et tester profil/photo, sauvegarde, verrouillage, conversations, rappels, voix et fonctionnement hors ligne.
6. Ne publier l’APK final qu’après ces travaux et vérifications.

## Paramètres produit à respecter

- Phase actuelle : application Android installable ; Web reporté.
- Hors connexion en priorité.
- Parcours A1 → A2 → B1 → B2 → C1 → C2.
- 10 sous-chapitres par niveau, 50 leçons par sous-chapitre comme objectif de contenu.
- Contact WhatsApp dans les paramètres : +243 843478142.
- Mention de création : « CRÉÉ PAR JOSEPH MARCHAND — DÉVELOPPEUR ».


## Nouvelle demande — vraies images et JoBot enrichi

Demande validée pour la prochaine phase :
- [ ] Conserver les pictogrammes/émojis actuels comme secours, mais ajouter une bibliothèque de vraies images pédagogiques locales.
- [ ] Couvrir personnes, corps, objets, lieux, animaux, métiers, émotions, sports et mouvements/actions.
- [ ] Afficher des images pertinentes dans les cartes de vocabulaire.
- [ ] Ajouter des illustrations directement dans les leçons A1 et A2 en priorité, puis dans les autres niveaux, avec légende bilingue et texte alternatif.
- [ ] Ajouter un champ d'image facultatif aux données des leçons et un repli sûr vers les pictogrammes.
- [ ] Enrichir JoBot pour rechercher dans les leçons, exemples, vocabulaire, verbes et livre de référence.
- [ ] Permettre à JoBot d'afficher les images pédagogiques locales pertinentes.
- [ ] Définir clairement les limites du mode hors ligne ; étudier une IA en ligne facultative et sécurisée sans clé API dans l'APK.
- [ ] Vérifier les ressources locales, le mode avion, le poids de l'APK, les tests et l'installation Android.

État au début de cette demande : la galerie contient 12 cartes utilisant des émojis ; les leçons montrent un pictogramme contextuel ; JoBot effectue une recherche textuelle locale dans le contenu de cours et indique lorsqu'il ne trouve pas de réponse. Aucune bibliothèque de photographies/illustrations pédagogiques locales n'est encore intégrée.
