import 'a1_course_data.dart';

class Topic {
 final String title, explanation, example, french, question;
 final List<String> options; final int answer;
 const Topic(this.title,this.explanation,this.example,this.french,this.question,this.options,this.answer);
}
class StudyLesson {
 final String id,level,title,subtitle,explanation,example,french,question,correction;
 final List<String> options; final int answer,unit,phase;
 const StudyLesson({required this.id,required this.level,required this.title,required this.subtitle,required this.explanation,required this.example,required this.french,required this.question,required this.correction,required this.options,required this.answer,required this.unit,required this.phase});
}
const curriculum = <String,List<Topic>>{
'A1':[
Topic('Greetings and introductions','Use simple greetings and introduce yourself.','Hello! My name is Sarah. Nice to meet you.','Bonjour ! Je m’appelle Sarah. Enchantée.','How do you introduce your name?',['My name is Sarah.','I name Sarah.','Me Sarah name.'],0),
Topic('The verb to be','Use am with I, is with he/she/it, and are with you/we/they.','I am a student. She is happy. They are ready.','Je suis élève. Elle est contente. Ils sont prêts.','Choose the correct sentence.',['He are tired.','They is ready.','I am a student.'],2),
Topic('Personal pronouns','Use I, you, he, she, it, we and they instead of names.','Maya is my friend. She is kind.','Maya est mon amie. Elle est gentille.','Which pronoun replaces Paul?',['He','She','They'],0),
Topic('Articles a and an','Use a before a consonant sound and an before a vowel sound.','a book • an apple • an umbrella','un livre • une pomme • un parapluie','Choose the correct phrase.',['a apple','an apple','an book'],1),
Topic('Numbers and age','Use numbers to give your age and count things.','I am sixteen years old.','J’ai seize ans.','Complete: I am ___ years old.',['sixteen','sixteens','sixteen years'],0),
Topic('Family','Learn family words and possessives.','This is my mother. Her name is Grace.','Voici ma mère. Elle s’appelle Grace.','Who is your father’s daughter?',['Your sister','Your uncle','Your grandfather'],0),
Topic('Everyday objects','Name objects with this/that and these/those.','This is a pen. Those are my books.','Ceci est un stylo. Ceux-là sont mes livres.','Choose the plural sentence.',['This are books.','Those are books.','That are books.'],1),
Topic('Have and has','Use have with I/you/we/they and has with he/she/it.','I have a phone. She has a bag.','J’ai un téléphone. Elle a un sac.','Complete: He ___ a bicycle.',['have','has','having'],1),
Topic('Present simple routines','Use the present simple for habits and routines.','I study English every evening.','J’étudie l’anglais chaque soir.','Choose the correct sentence.',['She go to school.','She goes to school.','She going school.'],1),
Topic('Days and time','Talk about days and times.','My class starts at eight o’clock.','Mon cours commence à huit heures.','Which preposition fits a clock time?',['at','on','in'],0),
Topic('Food and drinks','Ask for food politely.','I would like some water, please.','Je voudrais de l’eau, s’il vous plaît.','Choose a polite request.',['Give water now!','I would like water, please.','Water me.'],1),
Topic('There is and there are','Use there is for one item and there are for plural items.','There is a chair. There are two windows.','Il y a une chaise. Il y a deux fenêtres.','Complete: ___ three students here.',['There is','There are','There am'],1),
Topic('Questions with do','Use do/does to ask present-simple questions.','Do you speak English? Does she work here?','Parles-tu anglais ? Travaille-t-elle ici ?','Choose the correct question.',['Does he likes tea?','Do he like tea?','Does he like tea?'],2),
Topic('Can and can’t','Use can for ability and can’t for inability.','I can swim, but I can’t drive.','Je sais nager, mais je ne sais pas conduire.','Which sentence expresses ability?',['I can swim.','I can to swim.','I cans swim.'],0),
],
'A2':[
Topic('Past simple: be','Use was for I/he/she/it and were for you/we/they.','I was at home yesterday. They were at school.','J’étais à la maison hier. Ils étaient à l’école.','Complete: We ___ tired yesterday.',['was','were','are'],1),
Topic('Past simple regular verbs','Add -ed to many regular verbs for finished actions.','I watched a film last night.','J’ai regardé un film hier soir.','Past form of work?',['worked','working','works'],0),
Topic('Irregular past verbs','Learn forms such as go/went and see/saw.','She went to the market and bought fruit.','Elle est allée au marché et a acheté des fruits.','Past of go?',['goed','went','gone yesterday'],1),
Topic('Future with going to','Use be going to for plans.','We are going to visit our aunt tomorrow.','Nous allons rendre visite à notre tante demain.','Complete: I ___ going to study.',['am','is','be'],0),
Topic('Comparatives','Compare things with -er or more.','This road is longer than that road.','Cette route est plus longue que cette route-là.','A car is ___ than a bicycle.',['fast','faster','fastest'],1),
Topic('Countable and uncountable nouns','Use many with countable nouns and much with uncountable nouns.','How many books? How much water?','Combien de livres ? Combien d’eau ?','Which is correct?',['much apples','many water','many apples'],2),
Topic('Some and any','Use some in many positive statements and any in questions or negatives.','There is some rice. Is there any milk?','Il y a du riz. Y a-t-il du lait ?','Do you have ___ questions?',['some','any','much'],1),
Topic('Should and advice','Use should/shouldn’t to give advice.','You should practise every day.','Tu devrais pratiquer chaque jour.','You ___ get some rest.',['should','should to','are should'],0),
Topic('Directions','Use imperatives and place words to give directions.','Turn left at the bank, then go straight.','Tournez à gauche à la banque, puis allez tout droit.','Turn left means…',['Tourner à droite','Tourner à gauche','Continuer tout droit'],1),
Topic('Present continuous','Use am/is/are + verb-ing for actions happening now.','She is reading a message right now.','Elle lit un message en ce moment.','They ___ playing now.',['is','are','be'],1),
Topic('Present perfect','Use have/has + past participle for experience and recent events.','I have visited Lubumbashi twice.','J’ai visité Lubumbashi deux fois.','Choose the correct form.',['She has finished.','She have finished.','She finished has.'],0),
Topic('Making invitations','Invite people and accept or decline politely.','Would you like to study together?','Voudrais-tu étudier ensemble ?','Choose a polite invitation.',['Come now!','Would you like to join us?','You must join.'],1),
],
'B1':[
Topic('Present perfect vs past simple','Use past simple with finished time; present perfect for experience.','I saw that film yesterday. I have seen it twice.','J’ai vu ce film hier. Je l’ai vu deux fois.','Which fits yesterday?',['I have gone yesterday.','I went yesterday.','I go yesterday.'],1),
Topic('First conditional','Use if + present, will + verb for realistic future results.','If you practise, you will improve.','Si tu pratiques, tu progresseras.','If it rains, we ___ inside.',['stay','will stay','stayed'],1),
Topic('Second conditional','Use if + past, would + verb for hypothetical situations.','If I had time, I would read more.','Si j’avais le temps, je lirais davantage.','Choose the second conditional.',['If I have time, I call.','If I had time, I would help.','If I will have time, help.'],1),
Topic('Passive voice','Use be + past participle when the action matters more than the actor.','The bridge was built in 2010.','Le pont a été construit en 2010.','Choose the passive form.',['They built the bridge.','The bridge was built.','The bridge built them.'],1),
Topic('Reported speech','Shift tense and pronouns when reporting what someone said.','“I am tired,” she said. → She said she was tired.','« Je suis fatiguée », a-t-elle dit.','Report: “I like it,” he said.',['He said he liked it.','He said I like it.','He says he liked it yesterday.'],0),
Topic('Relative clauses','Use who for people and which/that for things.','The woman who called is my teacher.','La femme qui a appelé est mon enseignante.','The book ___ I bought…',['who','where','that'],2),
Topic('Modals of obligation','Use must/have to for obligation and don’t have to for no necessity.','You must wear a helmet.','Tu dois porter un casque.','You don’t have to means…',['It is forbidden.','It is not necessary.','You must do it.'],1),
Topic('Linking ideas','Use although, however, therefore and because to connect ideas.','Although it was late, we continued studying.','Bien qu’il soit tard, nous avons continué à étudier.','Which word introduces contrast?',['therefore','because','although'],2),
Topic('Phrasal verbs','Learn verb + particle combinations as units.','Please turn off the light.','Éteins la lumière, s’il te plaît.','Put off a meeting means…',['postpone it','start it','cancel forever'],0),
Topic('Giving opinions','State a view, give a reason and support it with an example.','I believe libraries matter because they provide free books.','Je pense que les bibliothèques sont importantes.','What should support an opinion?',['A reason or evidence','Only repetition','An unrelated story'],0),
],
'B2':[
Topic('Advanced conditionals','Combine past conditions and present results for unreal situations.','If I had studied medicine, I would be a doctor now.','Si j’avais étudié la médecine, je serais médecin aujourd’hui.','This combines…',['two present facts','a past condition and present result','a future plan'],1),
Topic('Inversion for emphasis','Use inversion after negative adverbials in formal style.','Never have I seen such a view.','Je n’ai jamais vu un tel paysage.','Choose the inverted form.',['Never I have seen it.','Never have I seen it.','Never did I saw it.'],1),
Topic('Hedging','Use may, might and appears to when evidence is limited.','The results appear to suggest a gradual change.','Les résultats semblent indiquer un changement.','Which phrase is cautious?',['It definitely proves everything.','It appears to suggest…','There is no doubt whatsoever.'],1),
Topic('Complex passive','Use passive reporting structures in formal contexts.','The policy is expected to reduce costs.','On s’attend à ce que la politique réduise les coûts.','Choose the formal passive.',['People expect the policy reduce.','The policy is expected to reduce costs.','The policy expecting costs.'],1),
Topic('Concession and contrast','Use despite, whereas and nevertheless to acknowledge opposing facts.','Despite the delay, the team delivered the project.','Malgré le retard, l’équipe a livré le projet.','Despite is followed by…',['a noun or -ing form','only a base verb','a verb with will'],0),
Topic('Collocations','Learn words that naturally occur together.','Make a decision, take responsibility, strong evidence.','Prendre une décision, assumer une responsabilité.','Which collocation is natural?',['do a decision','make a decision','build a decision'],1),
Topic('Register and tone','Choose formal, neutral or informal language for the audience.','I would appreciate your response.','Je vous serais reconnaissant de votre réponse.','Which is more formal?',['Send it now.','Could you please send it at your convenience?','Gimme it.'],1),
Topic('Argument structure','Build an argument with a claim, evidence and counterpoint.','The cost is high; however, long-term savings may outweigh it.','Le coût est élevé ; cependant, les économies peuvent le compenser.','A strong argument should…',['ignore opposing views','consider counterpoints','repeat the claim only'],1),
Topic('Past modals','Use could have, should have and must have about the past.','She must have missed the bus.','Elle a dû rater le bus.','You should have called expresses…',['past advice or criticism','future permission','present ability'],0),
Topic('Idioms in context','Understand common idioms without translating word by word.','She finally broke the ice.','Elle a enfin brisé la glace.','Break the ice means…',['damage something','make people comfortable','end a friendship'],1),
],
'C1':[
Topic('Discourse markers','Use markers to signal qualification, consequence and contrast.','That said, the evidence remains inconclusive.','Cela dit, les preuves restent non concluantes.','That said signals…',['contrast or qualification','time sequence','quotation'],0),
Topic('Subtle modality','Use modal verbs for probability, distance and diplomacy.','The proposal would appear to offer benefits.','La proposition semblerait offrir des avantages.','Which is most tentative?',['It is certainly perfect.','It would appear to offer benefits.','It offers benefits, no question.'],1),
Topic('Nominalisation','Use noun forms to make formal writing concise.','We analysed the data → our analysis of the data.','Nous avons analysé les données → notre analyse des données.','Decide becomes…',['decision','decidingly','deciderment'],0),
Topic('Cleft sentences','Use marked structures to emphasise a key point.','What matters most is consistent practice.','Ce qui compte le plus, c’est une pratique régulière.','Which emphasises the key point?',['Practice matters what.','What matters is practice.','It practice matters.'],1),
Topic('Inference','Infer attitude and meaning from context and tone.','“That’s an interesting choice” may imply polite doubt.','« C’est un choix intéressant » peut exprimer un doute poli.','Inference depends on…',['context and tone','dictionary meaning alone','word length'],0),
Topic('Academic qualification','Distinguish correlation, causation, evidence and limitations.','The findings fit, but do not prove, the hypothesis.','Les résultats concordent avec l’hypothèse sans la prouver.','Which claim is careful?',['The study proves every cause.','The findings are consistent with the hypothesis.','No evidence is needed.'],1),
Topic('Precise word choice','Choose words by connotation, register and exact meaning.','Resilient means able to recover after difficulty.','Résilient signifie capable de se rétablir après une difficulté.','A resilient person…',['recovers after setbacks','never faces problems','avoids all change'],0),
Topic('Rhetorical strategies','Recognise parallelism, contrast and emphasis.','We need not more promises, but more action.','Nous avons besoin de plus d’action, pas de promesses.','The sentence uses…',['contrast','a question tag','reported speech'],0),
Topic('Synthesising sources','Compare multiple sources and preserve attribution.','Both reports identify a trend but explain it differently.','Les deux rapports identifient une tendance, mais l’expliquent différemment.','A synthesis should…',['copy one source only','integrate and compare ideas','remove attribution'],1),
Topic('Professional diplomacy','Disagree firmly without needless confrontation.','I see the rationale; may I raise one concern?','Je comprends le raisonnement ; puis-je soulever une réserve ?','Which is diplomatic?',['Your idea is stupid.','I see the rationale, but may I raise a concern?','You are wrong, end of discussion.'],1),
],
'C2':[
Topic('Idiomatic precision','Choose idioms that fit situation, register and intended effect.','The new evidence put the matter in a different light.','Les nouvelles preuves ont changé la manière de voir la question.','Put something in a different light means…',['change its interpretation','turn off a lamp','hide the evidence'],0),
Topic('Rhetorical nuance','Analyse how wording and framing influence an audience.','The question is not whether change will come, but how we prepare.','La question est comment se préparer au changement.','The structure creates…',['contrastive emphasis','a simple past narrative','a literal instruction'],0),
Topic('Register shifting','Rephrase the same idea for academic, professional and casual contexts.','Casual: The plan fell through. Formal: The plan was unsuccessful.','Familier : le plan est tombé à l’eau. Formel : le plan n’a pas abouti.','Which is most formal?',['The plan fell through.','The plan didn’t work out.','The plan was unsuccessful.'],2),
Topic('Pragmatics','Resolve ambiguity through context and speaker intention.','Could you open the window? is usually a request.','Pourrais-tu ouvrir la fenêtre ? est généralement une demande.','Its usual function is…',['a request','a test of strength','a statement of fact'],0),
Topic('Sophisticated concession','Concede a valid point while maintaining a qualified position.','Granted, the sample is small; nevertheless, the pattern merits study.','Certes, l’échantillon est petit ; néanmoins, la tendance mérite une étude.','Granted here…',['concedes a point','grants permission','ends the argument'],0),
Topic('Lexical nuance','Distinguish near-synonyms by implication and context.','Sceptical signals doubt; cynical suggests distrust of motives.','Sceptique exprime le doute ; cynique suppose des motifs intéressés.','Which suggests distrust of motives?',['sceptical','cynical','curious'],1),
Topic('Complex sentence control','Use embedded clauses and punctuation to keep complex writing clear.','The report, revised after consultation, outlines three options.','Le rapport, révisé après consultation, présente trois options.','The clause between commas gives…',['extra information','the main verb','a command'],0),
Topic('Critical evaluation','Evaluate evidence quality, assumptions and limitations.','The conclusion is plausible, though the evidence is indirect.','La conclusion est plausible, même si les preuves sont indirectes.','Critical evaluation should…',['accept claims automatically','assess evidence and limitations','focus only on style'],1),
Topic('Irony and understatement','Recognise the gap between literal wording and intended meaning.','After a disastrous delay: “That went smoothly.”','Après un retard catastrophique : « Ça s’est bien passé. »','The phrase is likely…',['literal praise','ironic understatement','technical instruction'],1),
Topic('Editing for precision','Remove redundancy while preserving meaning.','The reason is that… is often clearer than the reason is because…','La raison est que… est souvent plus clair.','Good editing aims to…',['add repetition','preserve meaning precisely','make every sentence longer'],1),
]};
const levelNames = {'A1':'Beginner','A2':'Elementary','B1':'Intermediate','B2':'Upper-intermediate','C1':'Advanced','C2':'Proficiency'};
const phaseNames = ['Learn the idea','Guided practice','Review challenge'];
List<StudyLesson> buildCurriculum() {
 final result=<StudyLesson>[];
 // The A1 course is the 500-lesson structured course authored in docs/lessons/.
 for(final raw in a1CourseData){
  result.add(StudyLesson(
   id: raw['id'] as String,
   level: 'A1',
   title: raw['title'] as String,
   subtitle: raw['subtitle'] as String,
   explanation: raw['explanation'] as String,
   example: raw['example'] as String,
   french: raw['french'] as String,
   question: raw['question'] as String,
   correction: raw['correction'] as String,
   options: (raw['options'] as List).cast<String>(),
   answer: raw['answer'] as int,
   unit: raw['unit'] as int,
   phase: 0,
  ));
 }
 // A2-C2 keep the current course bank for now; their expanded lesson content is still to be written.
 for(final entry in curriculum.entries.where((e)=>e.key!='A1')){
  var unit=1;
  for(var i=0;i<entry.value.length;i++){
   final t=entry.value[i];
   for(var p=0;p<3;p++){
    final suffix=p==0?'':p==1?' — Practice':' — Review';
    result.add(StudyLesson(
     id:'${entry.key}-${i+1}-${p+1}',
     level:entry.key,
     title:'${(i+1).toString().padLeft(2,'0')}. ${t.title}$suffix',
     subtitle:'${phaseNames[p]} • Unit $unit',
     explanation:t.explanation,
     example:t.example,
     french:t.french,
     question:p==0?t.question:p==1?'Practice: ${t.question}':'Review: ${t.question}',
     correction:t.explanation,
     options:t.options,
     answer:t.answer,
     unit:unit,
     phase:p,
    ));
   }
   unit++;
  }
 }
 return result;
}
