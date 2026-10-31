# English Pro — Feuille de route visuelle et multimédia

## Décision de la phase actuelle

Conserver les pictogrammes et émojis déjà présents comme repères légers et solutions de secours, mais les compléter par une véritable bibliothèque d'images pédagogiques originales, optimisées et disponibles hors connexion. Les images doivent être utilisées dans la galerie, dans les leçons et dans JoBot.

## Principes

- Android installable en priorité ; la version Web est reportée.
- Fonctionnement hors connexion prioritaire pour le parcours essentiel.
- Les images pédagogiques essentielles sont intégrées aux ressources locales de l'application ; aucune image distante ne doit être nécessaire pour comprendre une leçon.
- Préférer des images originales ou des ressources dont la licence autorise clairement la redistribution dans l'application.
- Optimiser les dimensions et le poids des fichiers ; prévoir un texte alternatif et un pictogramme de secours.
- Les images de personnes doivent être respectueuses, diversifiées et adaptées au contexte pédagogique ; montrer des actions et mouvements compréhensibles.
- Ne pas présenter une fonctionnalité comme terminée avant son intégration et son test sur Android.

## Priorités

### 1. Identité visuelle
- Utiliser le drapeau américain comme symbole principal d'English Pro, sans monogramme EP en remplacement.
- Harmoniser le bleu, le violet et l'or dans l'interface.
- Vérifier l'icône Android réellement utilisée par le build.

### 2. Bibliothèque de vraies images
- Conserver les émojis et stickers comme compléments et solutions de secours.
- Ajouter des images réelles ou des illustrations originales de qualité sur les thèmes : personnes et portraits, famille, corps humain, vêtements, objets, école, maison, nourriture, animaux, nature, ville, transports, voyage, métiers, émotions, sports et actions/mouvements.
- Chaque entrée de la bibliothèque doit avoir un identifiant stable, le mot anglais, sa traduction française, une phrase exemple, un nom de fichier local, un texte alternatif et éventuellement une catégorie.
- Prévoir des images montrant clairement les verbes d'action : run, walk, jump, read, write, eat, drink, swim, drive, open, close, carry, sit, stand, dance, etc.
- Créer des cartes avec image, mot anglais, traduction, phrase courte et lecture audio.
- Les images essentielles doivent fonctionner en mode avion.

### 3. Illustrations intégrées aux leçons
- Ajouter un champ d'illustration facultatif aux données de leçon, sans casser les leçons existantes.
- Associer les images au sens de la leçon et à ses exemples, et non uniquement à un mot-clé approximatif.
- Insérer l'image dans la leçon près de l'explication ou de l'exemple, avec légende bilingue et texte alternatif.
- Commencer par les sous-chapitres A1 et A2 les plus visuels, puis étendre progressivement aux niveaux B1 à C2.
- Si une image n'existe pas, afficher proprement le pictogramme actuel.

### 4. JoBot — assistant pédagogique enrichi
- Améliorer la recherche locale avec les leçons, le livre de référence, le vocabulaire, les verbes, les exemples et les questions fréquentes.
- Répondre en français ou en anglais selon la langue de la question, avec explications simples, exemples corrigés et renvoi vers une leçon pertinente.
- JoBot doit pouvoir afficher les images pédagogiques locales pertinentes dans ses réponses.
- Ne pas prétendre répondre à toutes les questions : le mode hors ligne ne peut répondre qu'à partir de sa base locale et doit signaler ses limites.
- Étudier un mode IA en ligne facultatif pour les questions hors base, uniquement avec une architecture sécurisée, une information claire sur Internet et les coûts, et sans clé API secrète intégrée à l'application.
- Les fonctions essentielles doivent rester disponibles sans compte ni serveur.

### 5. Vidéos
- Garder une rubrique Vidéos distincte du parcours principal.
- Organiser les vidéos par niveau et thème.
- Prévoir titre, durée, sous-titres ou transcription et niveau de difficulté.
- Les vidéos hébergées en ligne ne doivent pas bloquer les leçons hors connexion.
- N'utiliser que des vidéos autorisées ou créées pour l'application ; ne pas intégrer des liens non vérifiés.

### 6. Contrôle qualité
- Lancer l'analyse Dart et les tests après chaque modification.
- Vérifier que toutes les images déclarées existent dans les assets et que les chemins sont valides.
- Tester galerie, leçons et JoBot en mode avion.
- Mesurer le poids de l'APK et optimiser les images trop lourdes.
- Générer un APK de test après les changements significatifs et tester sur un appareil Android réel.
- Garder la barrière de qualité des contenus ; ne pas falsifier ni affaiblir les tests de curriculum pour obtenir un build vert.

## Hors périmètre pour cette phase
- Publication sur le Play Store.
- Dépendance obligatoire à un serveur payant.
- Promesse d'un chatbot hors ligne capable de répondre à toutes les questions du monde.

## Exigence visuelle renforcée — niveaux B1 à C2

Les leçons B1, B2, C1 et C2 doivent intégrer des supports visuels pédagogiques directement dans le contenu, en particulier juste après ou à côté de l'explication concernée, avant les exemples et les exercices lorsque cela facilite la compréhension.

- Ajouter une petite illustration ou une photo pertinente dans les leçons qui enseignent un objet, un animal, un lieu, une profession, une émotion, une action, un mouvement, un phénomène ou une situation concrète.
- Afficher sous chaque visuel le mot ou l'expression en anglais, sa traduction française et, si utile, une phrase d'exemple bilingue.
- Utiliser les émojis comme repères complémentaires pour rendre le contenu vivant, jamais comme substituts systématiques aux vraies images.
- Pour les verbes d'action, choisir des images qui montrent clairement le mouvement (run, jump, swim, carry, throw, climb, dance, etc.). Ajouter de petites animations sobres (apparition en fondu, léger zoom ou mouvement illustratif) lorsque cela améliore la compréhension ; éviter les animations distrayantes et préserver les performances Android.
- Les illustrations doivent correspondre précisément à la notion enseignée, pas être ajoutées au hasard pour décorer.
- Les images et animations pédagogiques essentielles doivent être locales et fonctionner hors connexion. Prévoir une solution de secours avec pictogramme/émoji si une ressource manque.
- Garder une mise en page compacte et lisible : illustration de taille modérée, explication en dessous ou à côté, légende bilingue et texte alternatif.
- Appliquer cette règle aux quatre niveaux avancés B1, B2, C1 et C2, en privilégiant les leçons où le visuel apporte une vraie valeur pédagogique. Les notions abstraites (argumentation, grammaire avancée, registre, rhétorique) peuvent utiliser des schémas simples, des icônes ou des mini-scénarios plutôt qu'une photo artificielle.
