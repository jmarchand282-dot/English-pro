import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lesson_bank.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const EnglishProApp()); }
const navy=Color(0xFF151936), blue=Color(0xFF4F46E5), gold=Color(0xFFFFC857), pageBg=Color(0xFFF5F6FC);
const levels=['A1','A2','B1','B2','C1','C2'];

class EnglishProApp extends StatelessWidget {
 const EnglishProApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(title:'English Pro',debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:blue),scaffoldBackgroundColor:pageBg,appBarTheme:const AppBarTheme(backgroundColor:navy,foregroundColor:Colors.white)),home:const AppHome());
}
class AppHome extends StatefulWidget { const AppHome({super.key}); @override State<AppHome> createState()=>_AppHomeState(); }
class _AppHomeState extends State<AppHome> {
 late SharedPreferences prefs; late List<StudyLesson> lessons;
 Set<String> done={}; int xp=0,goal=15,streak=0; String name='Learner',lastDate=''; String? photo; bool loading=true;
 @override void initState(){super.initState();lessons=buildCurriculum();init();}
 Future<void> init() async {prefs=await SharedPreferences.getInstance();done=(prefs.getStringList('completed_v2')??[]).toSet();xp=prefs.getInt('xp_v2')??0;goal=prefs.getInt('daily_goal')??15;streak=prefs.getInt('streak')??0;name=prefs.getString('learner_name')??'Learner';lastDate=prefs.getString('last_study_date')??'';photo=prefs.getString('photo_data');if(mounted)setState(()=>loading=false);}
 Future<void> save() async {await prefs.setStringList('completed_v2',done.toList());await prefs.setInt('xp_v2',xp);await prefs.setInt('daily_goal',goal);await prefs.setInt('streak',streak);await prefs.setString('learner_name',name);await prefs.setString('last_study_date',lastDate);if(photo!=null)await prefs.setString('photo_data',photo!);}
 String get currentLevel {for(final l in levels){if(!lessons.where((x)=>x.level==l).every((x)=>done.contains(x.id)))return l;}return 'C2';}
 int count(String l)=>lessons.where((x)=>x.level==l&&done.contains(x.id)).length;
 int total(String l)=>lessons.where((x)=>x.level==l).length;
 StudyLesson? get next {for(final l in lessons){if(!done.contains(l.id))return l;}return null;}
 bool isUnlocked(StudyLesson l){final i=lessons.indexWhere((x)=>x.id==l.id);return i==0||done.contains(l.id)||done.contains(lessons[i-1].id);}
 int get todayXp=>prefs.getInt('today_xp')??0;
 Future<void> complete(StudyLesson l) async {if(done.contains(l.id))return;final n=DateTime.now();final today='${n.year}-${n.month}-${n.day}';if(lastDate!=today){final y=n.subtract(const Duration(days:1));final yesterday='${y.year}-${y.month}-${y.day}';streak=lastDate==yesterday?streak+1:1;lastDate=today;await prefs.setInt('today_xp',0);}done.add(l.id);xp+=10;await prefs.setInt('today_xp',todayXp+10);await save();if(mounted)setState((){});}
 void openLesson(StudyLesson l){if(!isUnlocked(l)){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Termine la leçon précédente pour débloquer celle-ci.')));return;}Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonPage(lesson:l,alreadyDone:done.contains(l.id),onComplete:()=>complete(l)))).then((_){if(mounted)setState((){});});}
 Future<void> pickPhoto() async {try{final f=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:65,maxWidth:420);if(f==null)return;photo=base64Encode(await f.readAsBytes());await save();if(mounted)setState((){});}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Photo impossible à charger. Réessaie.')));}}
 void profile(){final c=TextEditingController(text:name=='Learner'?'':name);showModalBottomSheet(context:context,isScrollControlled:true,builder:(ctx)=>Padding(padding:EdgeInsets.fromLTRB(22,22,22,MediaQuery.of(ctx).viewInsets.bottom+24),child:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Mon profil',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:14),GestureDetector(onTap:pickPhoto,child:avatar(photo,name,78)),TextButton.icon(onPressed:pickPhoto,icon:const Icon(Icons.photo_camera_outlined),label:const Text('Choisir une photo')),TextField(controller:c,decoration:const InputDecoration(labelText:'Ton nom',border:OutlineInputBorder())),const SizedBox(height:14),SizedBox(width:double.infinity,child:FilledButton(onPressed:()async{name=c.text.trim().isEmpty?'Learner':c.text.trim();await save();if(ctx.mounted)Navigator.pop(ctx);if(mounted)setState((){});},child:const Text('Enregistrer')))])));}
 void settings(){Navigator.push(context,MaterialPageRoute(builder:(_)=>SettingsPage(goal:goal,onGoal:(v)async{goal=v;await save();if(mounted)setState((){});},onContact:contact,onReset:reset)));}
 Future<void> contact()async{final u=Uri.parse('https://wa.me/243843478142?text=Bonjour%20English%20Pro%2C%20j%27ai%20besoin%20d%27aide.');if(!await launchUrl(u,mode:LaunchMode.externalApplication)&&mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('WhatsApp ne peut pas être ouvert.')));}
 Future<void> reset()async{final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Effacer la progression ?'),content:const Text('Toutes les leçons terminées et les XP seront supprimés sur cet appareil.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Effacer'))]));if(ok!=true)return;done.clear();xp=0;streak=0;lastDate='';await save();if(mounted)setState((){});}
 @override
 Widget build(BuildContext context) {
  if(loading) return const Scaffold(body:Center(child:CircularProgressIndicator()));
  final level=currentLevel;
  final upcoming=next;
  final completedA1=count('A1');
  final totalA1=total('A1');
  return Scaffold(
   appBar:AppBar(
    title:const Row(children:[Text('🇺🇸',style:TextStyle(fontSize:22)),SizedBox(width:8),Text('English Pro',style:TextStyle(fontWeight:FontWeight.bold))]),
    actions:[
     IconButton(onPressed:profile,icon:avatar(photo,name,30),tooltip:'Profil'),
     IconButton(onPressed:settings,icon:const Icon(Icons.settings_outlined),tooltip:'Paramètres'),
    ],
   ),
   body:SafeArea(child,ListView(padding:const EdgeInsets.fromLTRB(18,18,18,24),children:[
    Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,blue]),borderRadius:BorderRadius.circular(26)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text('BONJOUR, ${name.toUpperCase()}',style:const TextStyle(color:gold,fontSize:11,fontWeight:FontWeight.bold,letterSpacing:1.2)),
     const SizedBox(height:12),
     const Text('Hello! Welcome to English Pro',style:TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.bold,height:1.2)),
     const SizedBox(height:8),
     const Text('Apprends l’anglais étape par étape, avec des explications et des exercices.',style:TextStyle(color:Colors.white70,fontSize:14,height:1.4)),
     const SizedBox(height:20),
     SizedBox(width:double.infinity,height:62,child:FilledButton.icon(
      style:FilledButton.styleFrom(backgroundColor:gold,foregroundColor:navy,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),textStyle:const TextStyle(fontSize:18,fontWeight:FontWeight.w900,letterSpacing:1)),
      onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>CoursePathPage(lessons:lessons,done:done,currentLevel:level,levelUnlocked:(lev){final i=levels.indexOf(lev);return i<=0||count(levels[i-1])==total(levels[i-1]);},completedCount:count,totalCount:total,lessonUnlocked:isUnlocked,onOpenLesson:openLesson))),
      icon:const Icon(Icons.play_arrow_rounded,size:30),label:const Text('COMMENCER')
     ))
    ])),
    const SizedBox(height:18),
    Row(children:[
     Expanded(child:_homeStat(Icons.bolt,'$xp','XP gagnés')),
     const SizedBox(width:10),
     Expanded(child:_homeStat(Icons.local_fire_department,'$streak','Jours de série')),
    ]),
    const SizedBox(height:12),
    Container(padding:const EdgeInsets.all(17),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0xFFE7E8F2))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Row(children:[const Icon(Icons.flag_outlined,color:blue),const SizedBox(width:8),const Expanded(child:Text('Objectif quotidien',style:TextStyle(fontWeight:FontWeight.bold,color:navy))),Text('$todayXp / $goal XP',style:const TextStyle(color:blue,fontWeight:FontWeight.bold))]),
     const SizedBox(height:10),
     ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(value:(todayXp/goal).clamp(0,1),minHeight:8,color:blue,backgroundColor:const Color(0xFFE7E8F2))),
     const SizedBox(height:8),
     Text('Niveau actuel : $level • ${levelNames[level]}',style:const TextStyle(color:Colors.black54,fontSize:13)),
     const SizedBox(height:8),
     Text('Progression A1 : $completedA1 / $totalA1 leçons',style:const TextStyle(color:navy,fontWeight:FontWeight.w600)),
     const SizedBox(height:6),
     ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(value:totalA1==0?0:completedA1/totalA1,minHeight:6,color:Colors.green,backgroundColor:const Color(0xFFE7E8F2))),
    ])),
    const SizedBox(height:18),
    if(upcoming!=null) Text('Prochaine étape : ${upcoming.title}',style:const TextStyle(color:Colors.black54,fontSize:12)),
    const SizedBox(height:18),
    const Center(child:Text('CRÉÉ PAR JOSEPH MARCHAND • DÉVELOPPEUR',textAlign:TextAlign.center,style:TextStyle(color:Colors.black45,fontSize:11,fontWeight:FontWeight.w600))),
   ]))
  );
 }
 Widget _homeStat(IconData icon,String value,String label)=>Container(padding:const EdgeInsets.symmetric(vertical:16,horizontal:10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17),border:Border.all(color:const Color(0xFFE7E8F2))),child:Row(children:[Container(width:42,height:42,decoration:BoxDecoration(color:gold.withValues(alpha:.2),borderRadius:BorderRadius.circular(13)),child:Icon(icon,color:blue)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(value,style:const TextStyle(color:navy,fontSize:20,fontWeight:FontWeight.bold)),Text(label,style:const TextStyle(color:Colors.black54,fontSize:11))]))]));
 Widget stat(IconData i,String v,String label)=>Expanded(child:Container(padding:const EdgeInsets.symmetric(vertical:10),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.12),borderRadius:BorderRadius.circular(12)),child:Column(children:[Icon(i,color:gold),Text(v,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:16)),Text(label,style:const TextStyle(color:Colors.white70,fontSize:9))])));
}


const a1UnitTitles=<int,String>{
 1:'Premiers contacts, sons et alphabet',
 2:'Phrases de base et grammaire essentielle',
 3:'Atelier spécial des verbes',
 4:'Personnes, famille et descriptions',
 5:'Temps, calendrier et vie quotidienne',
 6:'Maison, ville et déplacements',
 7:'Nourriture, repas et achats',
 8:'École, loisirs, sports et relations sociales',
 9:'Actions en cours, météo et communication pratique',
 10:'Conversations, compréhension et validation A1',
};
class CoursePathPage extends StatelessWidget {
 final List<StudyLesson> lessons; final Set<String> done; final String currentLevel;
 final bool Function(String) levelUnlocked; final int Function(String) completedCount; final int Function(String) totalCount;
 final bool Function(StudyLesson) lessonUnlocked; final Future<void> Function(StudyLesson) onOpenLesson;
 const CoursePathPage({super.key,required this.lessons,required this.done,required this.currentLevel,required this.levelUnlocked,required this.completedCount,required this.totalCount,required this.lessonUnlocked,required this.onOpenLesson});
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('Mon parcours')),
  body:ListView(padding:const EdgeInsets.all(16),children:[
   const Text('Choisis ton parcours',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold,color:navy)),
   const SizedBox(height:6),
   const Text('Les niveaux et sous-chapitres se débloquent dans l’ordre. Termine les étapes pour continuer.',style:TextStyle(color:Colors.black54,height:1.4)),
   const SizedBox(height:14),
   ...levels.map((lev){
    final unlocked=levelUnlocked(lev); final finished=completedCount(lev)==totalCount(lev);
    return Card(color:Colors.white,margin:const EdgeInsets.only(bottom:11),child:ListTile(
     contentPadding:const EdgeInsets.all(14),
     leading:Container(width:48,height:48,decoration:BoxDecoration(color:unlocked?blue.withValues(alpha:.12):const Color(0xFFF0F0F5),borderRadius:BorderRadius.circular(14)),child:Icon(unlocked?Icons.menu_book:Icons.lock,color:unlocked?blue:Colors.grey)),
     title:Text('$lev • ${levelNames[lev]}',style:const TextStyle(fontWeight:FontWeight.bold,color:navy)),
     subtitle:Text('${completedCount(lev)} / ${totalCount(lev)} leçons terminées'),
     trailing:Icon(finished?Icons.check_circle:unlocked?Icons.chevron_right:Icons.lock,color:finished?Colors.green:unlocked?blue:Colors.grey),
     onTap:!unlocked?(){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Termine le niveau précédent pour déverrouiller celui-ci.')));}:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>SubchapterPage(level:lev,lessons:lessons,done:done,lessonUnlocked:lessonUnlocked,onOpenLesson:onOpenLesson))),
    ));
   })
  ])
 );
}
class SubchapterPage extends StatefulWidget {
 final String level; final List<StudyLesson> lessons; final Set<String> done;
 final bool Function(StudyLesson) lessonUnlocked; final Future<void> Function(StudyLesson) onOpenLesson;
 const SubchapterPage({super.key,required this.level,required this.lessons,required this.done,required this.lessonUnlocked,required this.onOpenLesson});
 @override State<SubchapterPage> createState()=>_SubchapterPageState();
}
class _SubchapterPageState extends State<SubchapterPage>{
 @override Widget build(BuildContext context){
  final levelLessons=widget.lessons.where((l)=>l.level==widget.level).toList();
  final units=levelLessons.map((l)=>l.unit).toSet().toList()..sort();
  return Scaffold(appBar:AppBar(title:Text('${widget.level} • Sous-chapitres')),body:ListView(padding:const EdgeInsets.all(16),children:[
   Text('${widget.level} — ${levelNames[widget.level]}',style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:navy)),
   const SizedBox(height:6),
   const Text('Un sous-chapitre se déverrouille après la validation de toutes les leçons du précédent.',style:TextStyle(color:Colors.black54)),
   const SizedBox(height:14),
   ...units.map((unit){
    final list=levelLessons.where((l)=>l.unit==unit).toList();
    final doneCount=list.where((l)=>widget.done.contains(l.id)).length;
    final unlocked=unit==units.first||levelLessons.where((l)=>l.unit<unit).every((l)=>widget.done.contains(l.id));
    final finished=doneCount==list.length;
    final title=widget.level=='A1'?(a1UnitTitles[unit]??'Sous-chapitre $unit'):'Sous-chapitre $unit • ${list.first.title}';
    return Card(color:Colors.white,margin:const EdgeInsets.only(bottom:11),child:ListTile(
     contentPadding:const EdgeInsets.all(14),
     leading:Container(width:46,height:46,decoration:BoxDecoration(color:unlocked?blue.withValues(alpha:.12):const Color(0xFFF0F0F5),borderRadius:BorderRadius.circular(13)),child:Icon(finished?Icons.check_circle:unlocked?Icons.play_circle_outline:Icons.lock,color:finished?Colors.green:unlocked?blue:Colors.grey)),
     title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold,color:navy)),
     subtitle:Text('${doneCount} / ${list.length} leçons'),
     trailing:Icon(unlocked?Icons.chevron_right:Icons.lock,color:unlocked?blue:Colors.grey),
     onTap:!unlocked?(){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Termine le sous-chapitre précédent pour débloquer celui-ci.')));}:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>UnitLessonsPage(level:widget.level,unit:unit,title:title,lessons:list,done:widget.done,lessonUnlocked:widget.lessonUnlocked,onOpenLesson:widget.onOpenLesson))).then((_){if(mounted)setState((){});}),
    ));
   })
  ]));
 }
}
class UnitLessonsPage extends StatefulWidget {
 final String level; final int unit; final String title; final List<StudyLesson> lessons; final Set<String> done;
 final bool Function(StudyLesson) lessonUnlocked; final Future<void> Function(StudyLesson) onOpenLesson;
 const UnitLessonsPage({super.key,required this.level,required this.unit,required this.title,required this.lessons,required this.done,required this.lessonUnlocked,required this.onOpenLesson});
 @override State<UnitLessonsPage> createState()=>_UnitLessonsPageState();
}
class _UnitLessonsPageState extends State<UnitLessonsPage>{
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text('${widget.level} • Leçons')),body:ListView(padding:const EdgeInsets.all(16),children:[
  Text(widget.title,style:const TextStyle(fontSize:21,fontWeight:FontWeight.bold,color:navy)),
  const SizedBox(height:6),
  Text('${widget.done.where((id)=>widget.lessons.any((l)=>l.id==id)).length} / ${widget.lessons.length} leçons terminées',style:const TextStyle(color:Colors.black54)),
  const SizedBox(height:12),
  ...widget.lessons.map((lesson){
   final finished=widget.done.contains(lesson.id);final unlocked=widget.lessonUnlocked(lesson);
   return Container(margin:const EdgeInsets.only(bottom:8),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:finished?Colors.green.withValues(alpha:.45):const Color(0xFFE6E7F0))),child:ListTile(
    leading:CircleAvatar(backgroundColor:finished?const Color(0xFFE3F6E9):unlocked?blue.withValues(alpha:.1):const Color(0xFFF0F0F5),child:Icon(finished?Icons.check:unlocked?Icons.play_arrow:Icons.lock,color:finished?Colors.green:unlocked?blue:Colors.grey)),
    title:Text(lesson.title,style:TextStyle(fontSize:14,fontWeight:FontWeight.w600,color:unlocked||finished?navy:Colors.grey)),
    subtitle:Text(lesson.subtitle,style:const TextStyle(fontSize:11)),
    trailing:const Icon(Icons.chevron_right,size:18),
    onTap:()=>widget.onOpenLesson(lesson).then((_){if(mounted)setState((){});}),
   ));
  })
 ]));
}

class LessonPage extends StatefulWidget {
 final StudyLesson lesson; final bool alreadyDone; final Future<void> Function() onComplete;
 const LessonPage({super.key,required this.lesson,required this.alreadyDone,required this.onComplete});
 @override State<LessonPage> createState()=>_LessonPageState();
}
class _LessonPageState extends State<LessonPage>{
 int? selected; bool checked=false,finished=false;
 @override Widget build(BuildContext context){
  final l=widget.lesson;
  final isCorrect=checked&&selected==l.answer;
  return Scaffold(
   appBar:AppBar(title:Text('${l.level} • Leçon'),leading:IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.close))),
   body:SafeArea(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(18,14,18,8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text(l.title,style:const TextStyle(color:navy,fontWeight:FontWeight.bold,fontSize:20)),
     const SizedBox(height:8),
     ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(value: finished ? 1 : (checked ? 0.72 : 0.42),minHeight:7,color:blue,backgroundColor:const Color(0xFFE7E8F2))),
     const SizedBox(height:7),
     Text('Étudie, réponds, puis lis la correction avant de continuer.',style:TextStyle(color:Colors.blueGrey.shade700,fontSize:12))
    ])),
    Expanded(child:SingleChildScrollView(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Container(width:double.infinity,padding:const EdgeInsets.all(19),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,blue]),borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('APPRENDS D’ABORD',style:TextStyle(color:gold,fontWeight:FontWeight.bold,letterSpacing:1.1)),
      const SizedBox(height:12),
      Text(l.explanation,style:const TextStyle(color:Colors.white,fontSize:17,height:1.45)),
      const SizedBox(height:17),
      Container(width:double.infinity,padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.13),borderRadius:BorderRadius.circular(14)),child:Text(l.example,style:const TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.w600,height:1.5))),
      const SizedBox(height:8),
      Text(l.french,style:const TextStyle(color:Colors.white70,height:1.5))
     ])),
     const SizedBox(height:22),
     const Text('VÉRIFIE TA COMPRÉHENSION',style:TextStyle(color:blue,fontWeight:FontWeight.bold,letterSpacing:1)),
     const SizedBox(height:9),
     Text(l.question,style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold,color:navy)),
     const SizedBox(height:12),
     ...List.generate(l.options.length,(i){
      final sel=selected==i,correct=checked&&i==l.answer,wrong=checked&&sel&&i!=l.answer;
      final border=correct?Colors.green:wrong?Colors.red:sel?blue:const Color(0xFFE4E6F0);
      return Container(margin:const EdgeInsets.only(bottom:9),child:InkWell(
       onTap:checked?null:()=>setState(()=>selected=i),
       borderRadius:BorderRadius.circular(14),
       child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:correct?const Color(0xFFE8F8ED):wrong?const Color(0xFFFFEEEE):sel?const Color(0xFFEEEEFF):Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:border,width:sel||correct?2:1)),
        child:Row(children:[Expanded(child:Text(l.options[i],style:const TextStyle(color:navy,fontSize:15))),if(correct)const Icon(Icons.check_circle,color:Colors.green),if(wrong)const Icon(Icons.cancel,color:Colors.red)])
       )
      ));
     }),
     if(checked)Container(width:double.infinity,margin:const EdgeInsets.only(top:4),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:isCorrect?const Color(0xFFE8F8ED):const Color(0xFFFFF4DF),borderRadius:BorderRadius.circular(14)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(isCorrect?'Bonne réponse !':'On corrige ensemble',style:TextStyle(fontWeight:FontWeight.bold,color:isCorrect?Colors.green.shade800:Colors.brown.shade800,fontSize:16)),
      const SizedBox(height:6),
      Text(isCorrect?'Tu as bien compris cette question.':'Réponse correcte : ${l.options[l.answer]}',style:const TextStyle(fontWeight:FontWeight.w600,color:navy)),
      const SizedBox(height:6),
      Text(l.correction,style:const TextStyle(color:navy,height:1.45))
     ]))
    ]))),
    Padding(padding:const EdgeInsets.all(18),child:SizedBox(width:double.infinity,child:FilledButton(
     onPressed:()async{
      if(finished){Navigator.pop(context);return;}
      if(!checked){
       if(selected==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisis une réponse pour continuer.')));return;}
       setState(()=>checked=true);return;
      }
      if(!isCorrect){setState((){selected=null;checked=false;});return;}
      await widget.onComplete();
      if(mounted)setState(()=>finished=true);
     },
     child:Text(finished?'Retour au parcours':!checked?'Vérifier ma réponse':isCorrect?'Terminer • +10 XP':'Réessayer après correction')
    )))
   ]))
  );
 }
}

class SettingsPage extends StatelessWidget{
 final int goal; final ValueChanged<int> onGoal; final VoidCallback onContact,onReset;
 const SettingsPage({super.key,required this.goal,required this.onGoal,required this.onContact,required this.onReset});
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Paramètres')),body:ListView(padding:const EdgeInsets.all(18),children:[
 const Text('APPRENTISSAGE',style:TextStyle(color:blue,fontWeight:FontWeight.bold,letterSpacing:1)),const SizedBox(height:10),Card(color:Colors.white,child:Column(children:[const ListTile(leading:Icon(Icons.flag_outlined,color:blue),title:Text('Objectif quotidien'),subtitle:Text('Choisis ton objectif en XP par jour')),Padding(padding:const EdgeInsets.symmetric(horizontal:14),child:Wrap(spacing:7,children:[10,15,20,30,50].map((v)=>ChoiceChip(label:Text('$v XP'),selected:goal==v,onSelected:(_)=>onGoal(v))).toList())),const SizedBox(height:10),const Divider(),const ListTile(leading:Icon(Icons.offline_bolt,color:blue),title:Text('Apprentissage hors ligne'),subtitle:Text('Les leçons et la progression sont enregistrées sur cet appareil.'))])),const SizedBox(height:18),
 const Text('À PROPOS ET CONTACT',style:TextStyle(color:blue,fontWeight:FontWeight.bold,letterSpacing:1)),const SizedBox(height:10),Card(color:Colors.white,child:Column(children:[const ListTile(leading:Icon(Icons.person_outline,color:blue),title:Text('CRÉÉ PAR JOSEPH MARCHAND'),subtitle:Text('DÉVELOPPEUR • English Pro A1 à C2')),const ListTile(leading:Icon(Icons.chat,color:Colors.green),title:Text('WhatsApp'),subtitle:Text('+243 843 478 142')),ListTile(leading:const Icon(Icons.open_in_new,color:Colors.green),title:const Text('Nous contacter sur WhatsApp'),trailing:const Icon(Icons.chevron_right),onTap:onContact)])),const SizedBox(height:18),Card(color:Colors.white,child:ListTile(leading:const Icon(Icons.restart_alt,color:Colors.red),title:const Text('Réinitialiser ma progression'),subtitle:const Text('Effacer les leçons terminées et les XP'),onTap:onReset)),const SizedBox(height:18),const Center(child:Text('English Pro • Version 2.0',style:TextStyle(color:Colors.black45)))
 ]));
}
Widget avatar(String? data,String name,double size){Widget child;if(data!=null){try{child=Image.memory(base64Decode(data),width:size,height:size,fit:BoxFit.cover);}catch(_){child=Text(name.isEmpty?'E':name[0].toUpperCase());}}else{child=Text(name.isEmpty?'E':name[0].toUpperCase());}return CircleAvatar(radius:size/2,backgroundColor:gold,child:ClipOval(child:SizedBox(width:size,height:size,child:Center(child:child))));}
