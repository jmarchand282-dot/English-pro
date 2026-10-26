import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'lesson_bank.dart';

final FlutterLocalNotificationsPlugin localNotifications=FlutterLocalNotificationsPlugin();
Future<void> initializeLocalNotifications() async {
 tz_data.initializeTimeZones();
 try { final zone=await FlutterTimezone.getLocalTimezone(); tz.setLocalLocation(tz.getLocation(zone.identifier)); } catch (_) {}
 const android=AndroidInitializationSettings('@mipmap/ic_launcher');
 await localNotifications.initialize(const InitializationSettings(android:android));
}
Future<void> scheduleDailyReminder({required int hour,required int minute,required bool sound}) async {
 await localNotifications.cancel(100);
 final now=tz.TZDateTime.now(tz.local);
 var scheduled=tz.TZDateTime(tz.local,now.year,now.month,now.day,hour,minute);
 if(!scheduled.isAfter(now)) scheduled=scheduled.add(const Duration(days:1));
 await localNotifications.zonedSchedule(100,'English Pro','Il est temps de pratiquer ton anglais !',scheduled,NotificationDetails(android:AndroidNotificationDetails(sound?'english_pro_reminders_sound':'english_pro_reminders_silent','Rappels English Pro',channelDescription:'Rappel quotidien pour réviser les leçons',importance:Importance.high,priority:Priority.high,playSound:sound)),androidScheduleMode:AndroidScheduleMode.inexactAllowWhileIdle,uiLocalNotificationDateInterpretation:UILocalNotificationDateInterpretation.absoluteTime,matchDateTimeComponents:DateTimeComponents.time);
}
Future<void> cancelDailyReminder() async { await localNotifications.cancel(100); }
Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); try { await initializeLocalNotifications(); } catch (_) {} runApp(const EnglishProApp()); }
const navy=Color(0xFF151936), blue=Color(0xFF4F46E5), gold=Color(0xFFFFC857), pageBg=Color(0xFFF5F6FC);
const levels=['A1','A2','B1','B2','C1','C2'];

final ValueNotifier<ThemeMode> appThemeMode=ValueNotifier<ThemeMode>(ThemeMode.light);
class EnglishProApp extends StatelessWidget {
 const EnglishProApp({super.key});
 @override Widget build(BuildContext context)=>ValueListenableBuilder<ThemeMode>(
  valueListenable:appThemeMode,
  builder:(context,mode,_)=>MaterialApp(
   title:'English Pro',
   debugShowCheckedModeBanner:false,
   theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:blue),scaffoldBackgroundColor:pageBg,appBarTheme:const AppBarTheme(backgroundColor:navy,foregroundColor:Colors.white)),
   darkTheme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:blue,brightness:Brightness.dark),scaffoldBackgroundColor:const Color(0xFF101326),appBarTheme:const AppBarTheme(backgroundColor:navy,foregroundColor:Colors.white)),
   themeMode:mode,
   home:const AppHome(),
  ),
 );
}
class AppHome extends StatefulWidget { const AppHome({super.key}); @override State<AppHome> createState()=>_AppHomeState(); }
class _AppHomeState extends State<AppHome> {
 late SharedPreferences prefs; late List<StudyLesson> lessons;
 Set<String> done={},conversationsDone={}; int xp=0,goal=15,streak=0; String name='Learner',lastDate='',placementLevel='A1'; String? photo; bool loading=true,needsOnboarding=true,darkMode=false,remindersEnabled=false,reminderSound=true; int reminderHour=18,reminderMinute=0;
 @override void initState(){super.initState();lessons=buildCurriculum();init();}
 Future<void> init() async {prefs=await SharedPreferences.getInstance();done=(prefs.getStringList('completed_v2')??[]).toSet();xp=prefs.getInt('xp_v2')??0;goal=prefs.getInt('daily_goal')??15;streak=prefs.getInt('streak')??0;name=prefs.getString('learner_name')??'Learner';lastDate=prefs.getString('last_study_date')??'';photo=prefs.getString('photo_data');placementLevel=prefs.getString('placement_level')??'A1';darkMode=prefs.getBool('dark_mode')??false;appThemeMode.value=darkMode?ThemeMode.dark:ThemeMode.light;remindersEnabled=prefs.getBool('reminders_enabled')??false;reminderSound=prefs.getBool('reminder_sound')??true;reminderHour=prefs.getInt('reminder_hour')??18;reminderMinute=prefs.getInt('reminder_minute')??0;if(remindersEnabled){try{await scheduleDailyReminder(hour:reminderHour,minute:reminderMinute,sound:reminderSound);}catch(_){}}needsOnboarding=!(prefs.getBool('profile_setup_complete')??false);if(mounted)setState(()=>loading=false);}
 Future<void> save() async {await prefs.setStringList('completed_v2',done.toList());await prefs.setInt('xp_v2',xp);await prefs.setInt('daily_goal',goal);await prefs.setInt('streak',streak);await prefs.setString('learner_name',name);await prefs.setString('last_study_date',lastDate);await prefs.setBool('dark_mode',darkMode);await prefs.setBool('reminders_enabled',remindersEnabled);await prefs.setBool('reminder_sound',reminderSound);await prefs.setInt('reminder_hour',reminderHour);await prefs.setInt('reminder_minute',reminderMinute);if(photo!=null)await prefs.setString('photo_data',photo!);}
 String get currentLevel {for(final l in levels){if(!lessons.where((x)=>x.level==l).every((x)=>done.contains(x.id)))return l;}return 'C2';}
 int count(String l)=>lessons.where((x)=>x.level==l&&done.contains(x.id)).length;
 int total(String l)=>lessons.where((x)=>x.level==l).length;
 StudyLesson? get next {for(final l in lessons){if(!done.contains(l.id))return l;}return null;}
 bool isUnlocked(StudyLesson l){final i=lessons.indexWhere((x)=>x.id==l.id);return i==0||done.contains(l.id)||done.contains(lessons[i-1].id);}
 int get todayXp=>prefs.getInt('today_xp')??0;
 Future<void> complete(StudyLesson l) async {if(done.contains(l.id))return;final n=DateTime.now();final today='${n.year}-${n.month}-${n.day}';if(lastDate!=today){final y=n.subtract(const Duration(days:1));final yesterday='${y.year}-${y.month}-${y.day}';streak=lastDate==yesterday?streak+1:1;lastDate=today;await prefs.setInt('today_xp',0);}done.add(l.id);xp+=10;await prefs.setInt('today_xp',todayXp+10);await save();if(mounted)setState((){});}
 Future<void> openLesson(StudyLesson l) async {if(!isUnlocked(l)){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Termine la leçon précédente pour débloquer celle-ci.')));return;}await Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonPage(lesson:l,alreadyDone:done.contains(l.id),onComplete:()=>complete(l))));if(mounted)setState((){});}
 Future<void> pickPhoto() async {try{final f=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:65,maxWidth:420);if(f==null)return;photo=base64Encode(await f.readAsBytes());await save();if(mounted)setState((){});}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Photo impossible à charger. Réessaie.')));}}
 void profile(){final c=TextEditingController(text:name=='Learner'?'':name);showModalBottomSheet(context:context,isScrollControlled:true,builder:(ctx)=>Padding(padding:EdgeInsets.fromLTRB(22,22,22,MediaQuery.of(ctx).viewInsets.bottom+24),child:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Mon profil',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:14),GestureDetector(onTap:pickPhoto,child:avatar(photo,name,78)),TextButton.icon(onPressed:pickPhoto,icon:const Icon(Icons.photo_camera_outlined),label:const Text('Choisir une photo')),TextField(controller:c,decoration:const InputDecoration(labelText:'Ton nom',border:OutlineInputBorder())),const SizedBox(height:14),SizedBox(width:double.infinity,child:FilledButton(onPressed:()async{name=c.text.trim().isEmpty?'Learner':c.text.trim();await save();if(ctx.mounted)Navigator.pop(ctx);if(mounted)setState((){});},child:const Text('Enregistrer')))])));}
 void settings(){Navigator.push(context,MaterialPageRoute(builder:(_)=>SettingsPage(goal:goal,darkMode:darkMode,onDarkMode:(v)async{darkMode=v;appThemeMode.value=v?ThemeMode.dark:ThemeMode.light;await save();if(mounted)setState((){});},remindersEnabled:remindersEnabled,reminderSound:reminderSound,reminderTime:TimeOfDay(hour:reminderHour,minute:reminderMinute),onReminderToggle:(v)async{remindersEnabled=v;if(v){try{await localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();await scheduleDailyReminder(hour:reminderHour,minute:reminderMinute,sound:reminderSound);}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Impossible d’activer le rappel. Vérifie les autorisations de notification.')));}}else{await cancelDailyReminder();}await save();if(mounted)setState((){});},onReminderTime:(t)async{reminderHour=t.hour;reminderMinute=t.minute;if(remindersEnabled){try{await scheduleDailyReminder(hour:reminderHour,minute:reminderMinute,sound:reminderSound);}catch(_){}}await save();if(mounted)setState((){});},onReminderSound:(v)async{reminderSound=v;if(remindersEnabled){try{await scheduleDailyReminder(hour:reminderHour,minute:reminderMinute,sound:reminderSound);}catch(_){}}await save();if(mounted)setState((){});},onGoal:(v)async{goal=v;await save();if(mounted)setState((){});},onContact:contact,onReset:reset,onBook:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ReferenceBookPage(lessons:lessons))),onChat:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>OfflineChatPage(lessons:lessons))))));}
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
   body:ListView(padding:const EdgeInsets.fromLTRB(18,18,18,24),children:[
    Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,blue]),borderRadius:BorderRadius.circular(26)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text('BONJOUR, ${name.toUpperCase()}',style:const TextStyle(color:gold,fontSize:11,fontWeight:FontWeight.bold,letterSpacing:1.2)),
     const SizedBox(height:12),
     const Text('Hello! Welcome to English Pro',style:TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.bold,height:1.2)),
     const SizedBox(height:8),
     const Text('Apprends l’anglais étape par étape, avec des explications et des exercices.',style:TextStyle(color:Colors.white70,fontSize:14,height:1.4)),
     const SizedBox(height:20),
     SizedBox(width:double.infinity,height:62,child:FilledButton.icon(
      style:FilledButton.styleFrom(backgroundColor:gold,foregroundColor:navy,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),textStyle:const TextStyle(fontSize:18,fontWeight:FontWeight.w900,letterSpacing:1)),
      onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>CoursePathPage(lessons:lessons,done:done,conversationsDone:conversationsDone,currentLevel:level,levelUnlocked:(lev){final i=levels.indexOf(lev);return i<=0||count(levels[i-1])==total(levels[i-1]);},completedCount:count,totalCount:total,lessonUnlocked:isUnlocked,onOpenLesson:openLesson,onConversationComplete:(lev,unit)async{conversationsDone.add('${lev}-U${unit}');await save();if(mounted)setState((){});}))),
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
     Text('Niveau conseillé par le test : $placementLevel • ${levelNames[placementLevel]}',style:const TextStyle(color:Colors.black54,fontSize:13)),
     const SizedBox(height:4),
     Text('Le parcours reste progressif : A1 se termine avant le déverrouillage de A2.',style:TextStyle(color:Colors.blueGrey.shade700,fontSize:12)),
     const SizedBox(height:8),
     Text('Progression A1 : $completedA1 / $totalA1 leçons',style:const TextStyle(color:navy,fontWeight:FontWeight.w600)),
     const SizedBox(height:6),
     ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(value:totalA1==0?0:completedA1/totalA1,minHeight:6,color:Colors.green,backgroundColor:const Color(0xFFE7E8F2))),
    ])),
    const SizedBox(height:18),
    if(upcoming!=null) Text('Prochaine étape : ${upcoming.title}',style:const TextStyle(color:Colors.black54,fontSize:12)),
    const SizedBox(height:18),
    const Center(child:Text('CRÉÉ PAR JOSEPH MARCHAND • DÉVELOPPEUR',textAlign:TextAlign.center,style:TextStyle(color:Colors.black45,fontSize:11,fontWeight:FontWeight.w600))),
   ])
  );
 }
 Widget _homeStat(IconData icon,String value,String label)=>Container(padding:const EdgeInsets.symmetric(vertical:16,horizontal:10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17),border:Border.all(color:const Color(0xFFE7E8F2))),child:Row(children:[Container(width:42,height:42,decoration:BoxDecoration(color:gold.withValues(alpha:.2),borderRadius:BorderRadius.circular(13)),child:Icon(icon,color:blue)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(value,style:const TextStyle(color:navy,fontSize:20,fontWeight:FontWeight.bold)),Text(label,style:const TextStyle(color:Colors.black54,fontSize:11))]))]));
 Widget stat(IconData i,String v,String label)=>Expanded(child:Container(padding:const EdgeInsets.symmetric(vertical:10),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.12),borderRadius:BorderRadius.circular(12)),child:Column(children:[Icon(i,color:gold),Text(v,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:16)),Text(label,style:const TextStyle(color:Colors.white70,fontSize:9))])));
}



class _PlacementQuestion {
 final String question,explanation; final List<String> options; final int answer;
 const _PlacementQuestion(this.question,this.explanation,this.options,this.answer);
}
const _placementQuestions=< _PlacementQuestion>[
 _PlacementQuestion('I ___ a student.','Avec I, la forme du verbe to be au présent est am.',['am','is','are'],0),
 _PlacementQuestion('She ___ football every Sunday.','Le présent simple décrit une habitude ; avec she, le verbe prend -s.',['play','plays','playing'],1),
 _PlacementQuestion('Yesterday, we ___ a film.','Yesterday indique le passé ; watch devient watched au passé simple.',['watch','watched','watching'],1),
 _PlacementQuestion('I have lived here ___ 2020.','Since indique le point de départ d’une durée ; for indique sa longueur.',['for','since','during'],1),
 _PlacementQuestion('If I ___ more time, I would travel.','Dans cette hypothèse irréelle, la proposition avec if utilise le past simple : had.',['have','had','will have'],1),
 _PlacementQuestion('Despite ___ tired, she kept working.','Après despite, on peut utiliser un nom ou une forme en -ing : being tired.',['be','being','was'],1),
 _PlacementQuestion('Had I known, I ___ earlier.','Cette inversion conditionnelle renvoie à une situation passée irréelle : would have left.',['would leave','would have left','will leave'],1),
 _PlacementQuestion('The proposal, ___ merits remain contested, was approved.','Whose indique la possession et peut se rapporter à une chose : the proposal’s merits.',['which','whose','who'],1),
];
const _welcomePhrases=<String>['HELLO! WELCOME TO ENGLISH PRO','LET’S LEARN ENGLISH TOGETHER!','PRACTICE MAKES PERFECT!'];
const _welcomeTranslations=<String>['Bonjour, bienvenue dans English Pro.','Apprenons l’anglais ensemble.','C’est en pratiquant qu’on progresse.'];
class OnboardingPage extends StatefulWidget {
 final String initialName; final String? photo; final Future<void> Function() onPickPhoto; final Future<void> Function(String,int) onComplete;
 const OnboardingPage({super.key,required this.initialName,required this.photo,required this.onPickPhoto,required this.onComplete});
 @override State<OnboardingPage> createState()=>_OnboardingPageState();
}
class _OnboardingPageState extends State<OnboardingPage>{
 late final TextEditingController nameController=TextEditingController(text:widget.initialName=='Learner'?'':widget.initialName);
 int page=0,index=0,score=0,welcomePhrase=0;int? selected;bool checked=false,saving=false;Timer? welcomeTimer;
 @override void initState(){super.initState();welcomeTimer=Timer.periodic(const Duration(seconds:3),(_){if(mounted)setState(()=>welcomePhrase=(welcomePhrase+1)%_welcomePhrases.length);});}
 @override void dispose(){welcomeTimer?.cancel();nameController.dispose();super.dispose();}
 @override Widget build(BuildContext context){
  final q=_placementQuestions[index];
  return Scaffold(
   body:SafeArea(child:ListView(padding:const EdgeInsets.all(22),children:[
    const SizedBox(height:12),
    const Center(child:Text('🇺🇸',style:TextStyle(fontSize:48))),
    const SizedBox(height:8),
    Center(child:SizedBox(height:54,child:AnimatedSwitcher(duration:const Duration(milliseconds:450),transitionBuilder:(child,animation)=>FadeTransition(opacity:animation,child:SlideTransition(position:Tween<Offset>(begin:const Offset(0,.15),end:Offset.zero).animate(animation),child:child)),child:Text(_welcomePhrases[welcomePhrase],key:ValueKey(welcomePhrase),textAlign:TextAlign.center,style:const TextStyle(color:blue,fontSize:19,fontWeight:FontWeight.w900))))),
    const SizedBox(height:6),
    Center(child:AnimatedSwitcher(duration:const Duration(milliseconds:300),child:Text(_welcomeTranslations[welcomePhrase],key:ValueKey('translation-$welcomePhrase'),style:const TextStyle(color:Colors.black54)))),
    const SizedBox(height:22),
    if(page==0)...[
     const Text('1. Créons ton profil',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:navy)),
     const SizedBox(height:14),
     Center(child:GestureDetector(onTap:()=>widget.onPickPhoto(),child:avatar(widget.photo,nameController.text,54))),
     Center(child:TextButton.icon(onPressed:()=>widget.onPickPhoto(),icon:const Icon(Icons.photo_camera_outlined),label:const Text('Ajouter une photo'))),
     TextField(controller:nameController,decoration:const InputDecoration(labelText:'Ton nom',hintText:'Entre ton nom',border:OutlineInputBorder(),prefixIcon:Icon(Icons.person_outline))),
     const SizedBox(height:18),
     SizedBox(height:54,child:FilledButton(onPressed:()=>setState(()=>page=1),child:const Text('FAIRE LE TEST DE NIVEAU →',style:TextStyle(fontWeight:FontWeight.bold))))
    ] else if(page==1)...[
     Row(children:[const Expanded(child:Text('2. Test de positionnement',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold,color:navy))),Text('${index+1}/${_placementQuestions.length}',style:const TextStyle(color:blue,fontWeight:FontWeight.bold))]),
     const SizedBox(height:8),
     LinearProgressIndicator(value:(index+1)/_placementQuestions.length,color:blue,backgroundColor:const Color(0xFFE7E8F2),minHeight:7),
     const SizedBox(height:20),
     Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,blue]),borderRadius:BorderRadius.circular(20)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('CHOISIS LA BONNE RÉPONSE',style:TextStyle(color:gold,fontWeight:FontWeight.bold,fontSize:11)),
      const SizedBox(height:12),
      Text(q.question,style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold))
     ])),
     const SizedBox(height:14),
     ...List.generate(q.options.length,(i){final sel=selected==i,correct=checked&&i==q.answer,wrong=checked&&sel&&i!=q.answer;return Container(margin:const EdgeInsets.only(bottom:9),child:InkWell(onTap:checked?null:()=>setState(()=>selected=i),borderRadius:BorderRadius.circular(14),child:Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:correct?const Color(0xFFE8F8ED):wrong?const Color(0xFFFFEEEE):sel?const Color(0xFFEEEEFF):Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:correct?Colors.green:wrong?Colors.red:sel?blue:const Color(0xFFE4E6F0),width:sel||correct?2:1)),child:Text(q.options[i],style:const TextStyle(color:navy,fontSize:16)))));}),
     if(checked)Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:selected==q.answer?const Color(0xFFE8F8ED):const Color(0xFFFFF4DF),borderRadius:BorderRadius.circular(13)),child:Text(selected==q.answer?'Bonne réponse ! ${q.explanation}':'Réponse correcte : ${q.options[q.answer]}. ${q.explanation}',style:const TextStyle(color:navy,height:1.4))),
     const SizedBox(height:16),
     SizedBox(height:52,child:FilledButton(onPressed:(){
      if(!checked){if(selected==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisis une réponse.')));return;}setState(()=>checked=true);if(selected==q.answer)score++;return;}
      if(selected!=q.answer){setState((){selected=null;checked=false;});return;}
      if(index<_placementQuestions.length-1){setState((){index++;selected=null;checked=false;});}else{setState(()=>page=2);}
     },child:Text(!checked?'VÉRIFIER':selected!=q.answer?'RÉESSAYER':index<_placementQuestions.length-1?'QUESTION SUIVANTE':'VOIR MON RÉSULTAT')))
    ] else...[
     const Text('3. Ton résultat',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:navy)),
     const SizedBox(height:16),
     Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,blue]),borderRadius:BorderRadius.circular(22)),child:Column(children:[
      const Icon(Icons.emoji_events_outlined,color:gold,size:48),
      const SizedBox(height:10),
      Text('$score / ${_placementQuestions.length}',style:const TextStyle(color:Colors.white,fontSize:30,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      Text('Niveau conseillé : ${score<=2?'A1':score<=3?'A2':score<=4?'B1':score<=5?'B2':score<=6?'C1':'C2'}',style:const TextStyle(color:gold,fontSize:18,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      const Text('Ce test donne une première indication. Pour apprendre solidement, ton parcours commence par A1 et les niveaux suivants se débloquent après validation.',textAlign:TextAlign.center,style:TextStyle(color:Colors.white,height:1.4))
     ])),
     const SizedBox(height:18),
     SizedBox(height:56,child:FilledButton(onPressed:saving?null:()async{setState(()=>saving=true);await widget.onComplete(nameController.text,score);},child:const Text('ENTRER DANS ENGLISH PRO',style:TextStyle(fontWeight:FontWeight.bold))))
    ]
   ]))
  );
 }
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
 final List<StudyLesson> lessons; final Set<String> done,conversationsDone; final String currentLevel;
 final bool Function(String) levelUnlocked; final int Function(String) completedCount; final int Function(String) totalCount;
 final bool Function(StudyLesson) lessonUnlocked; final Future<void> Function(StudyLesson) onOpenLesson; final Future<void> Function(String,int) onConversationComplete;
 const CoursePathPage({super.key,required this.lessons,required this.done,required this.conversationsDone,required this.currentLevel,required this.levelUnlocked,required this.completedCount,required this.totalCount,required this.lessonUnlocked,required this.onOpenLesson,required this.onConversationComplete});
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
     onTap:!unlocked?(){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Termine le niveau précédent pour déverrouiller celui-ci.')));}:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>SubchapterPage(level:lev,lessons:lessons,done:done,conversationsDone:conversationsDone,lessonUnlocked:lessonUnlocked,onOpenLesson:onOpenLesson,onConversationComplete:onConversationComplete))),
    ));
   })
  ])
 );
}
class SubchapterPage extends StatefulWidget {
 final String level; final List<StudyLesson> lessons; final Set<String> done,conversationsDone;
 final bool Function(StudyLesson) lessonUnlocked; final Future<void> Function(StudyLesson) onOpenLesson; final Future<void> Function(String,int) onConversationComplete;
 const SubchapterPage({super.key,required this.level,required this.lessons,required this.done,required this.conversationsDone,required this.lessonUnlocked,required this.onOpenLesson,required this.onConversationComplete});
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
     subtitle:Text('$doneCount / ${list.length} leçons'),
     trailing:Icon(unlocked?Icons.chevron_right:Icons.lock,color:unlocked?blue:Colors.grey),
     onTap:!unlocked?(){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Termine le sous-chapitre précédent pour débloquer celui-ci.')));}:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>UnitLessonsPage(level:widget.level,unit:unit,title:title,lessons:list,done:widget.done,conversationsDone:widget.conversationsDone,lessonUnlocked:widget.lessonUnlocked,onOpenLesson:widget.onOpenLesson,onConversationComplete:widget.onConversationComplete))).then((_){if(mounted)setState((){});}),
    ));
   })
  ]));
 }
}
class UnitLessonsPage extends StatefulWidget {
 final String level; final int unit; final String title; final List<StudyLesson> lessons; final Set<String> done,conversationsDone;
 final bool Function(StudyLesson) lessonUnlocked; final Future<void> Function(StudyLesson) onOpenLesson; final Future<void> Function(String,int) onConversationComplete;
 const UnitLessonsPage({super.key,required this.level,required this.unit,required this.title,required this.lessons,required this.done,required this.conversationsDone,required this.lessonUnlocked,required this.onOpenLesson,required this.onConversationComplete});
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

String lessonIllustration(StudyLesson lesson){
 final text='${lesson.title} ${lesson.example}'.toLowerCase();
 if(text.contains('foot')||text.contains('pied'))return '🦶';
 if(text.contains('hand')||text.contains('main'))return '✋';
 if(text.contains('head')||text.contains('tête'))return '🧠';
 if(text.contains('eye')||text.contains('eyes')||text.contains('visage'))return '👀';
 if(text.contains('apple')||text.contains('pomme'))return '🍎';
 if(text.contains('banana')||text.contains('banane'))return '🍌';
 if(text.contains('orange'))return '🍊';
 if(text.contains('fruit')||text.contains('food')||text.contains('nourriture'))return '🍎';
 if(text.contains('eat')||text.contains('repas')||text.contains('dinner')||text.contains('breakfast'))return '🍽️';
 if(text.contains('drink')||text.contains('water')||text.contains('boisson'))return '🥤';
 if(text.contains('family')||text.contains('mother')||text.contains('father')||text.contains('sister')||text.contains('brother'))return '👨‍👩‍👧‍👦';
 if(text.contains('house')||text.contains('bedroom')||text.contains('kitchen')||text.contains('maison'))return '🏠';
 if(text.contains('bus')||text.contains('car')||text.contains('transport'))return '🚌';
 if(text.contains('weather')||text.contains('rain')||text.contains('sunny')||text.contains('météo'))return '🌦️';
 if(text.contains('football')||text.contains('soccer'))return '⚽';
 if(text.contains('basketball'))return '🏀';
 if(text.contains('color')||text.contains('couleur'))return '🎨';
 if(text.contains('shop')||text.contains('buy')||text.contains('price')||text.contains('magasin'))return '🛍️';
 if(text.contains('time')||text.contains('calendar')||text.contains('heure')||text.contains('date'))return '🗓️';
 if(text.contains('book')||text.contains('read')||text.contains('lesson')||text.contains('school'))return '📚';
 if(text.contains('listen')||text.contains('pronunciation')||text.contains('audio'))return '🎧';
 if(text.contains('phone')||text.contains('call')||text.contains('text'))return '📱';
 if(text.contains('sleep')||text.contains('bed')||text.contains('wake up'))return '🛏️';
 if(text.contains('hello')||text.contains('greeting')||text.contains('salut'))return '👋';
 return '';
}

class LessonPage extends StatefulWidget {
 final StudyLesson lesson; final bool alreadyDone; final Future<void> Function() onComplete;
 const LessonPage({super.key,required this.lesson,required this.alreadyDone,required this.onComplete});
 @override State<LessonPage> createState()=>_LessonPageState();
}
class _LessonPageState extends State<LessonPage>{
 int? selected; bool checked=false,finished=false,listening=false,quizStarted=false,timedOut=false; int secondsLeft=10; Timer? quizTimer; String recognized='';
 final FlutterTts tts=FlutterTts(); final SpeechToText speech=SpeechToText();
 @override void dispose(){quizTimer?.cancel();tts.stop();speech.stop();super.dispose();}
 void startQuiz(){quizTimer?.cancel();setState((){quizStarted=true;secondsLeft=10;timedOut=false;selected=null;checked=false;});quizTimer=Timer.periodic(const Duration(seconds:1),(timer){if(secondsLeft<=1){timer.cancel();if(mounted)setState((){secondsLeft=0;timedOut=true;checked=true;});}else if(mounted){setState(()=>secondsLeft--);}});}
 String targetPhrase(StudyLesson l){var t=l.example.split(' = ').first.trim();t=t.split(' / ').first.trim();return t.replaceFirst(RegExp(r'^[^:]+:\s*'), '').trim();}
 Future<void> speakText(String text,{bool french=false})async{try{await tts.setLanguage(french?'fr-FR':'en-US');await tts.setSpeechRate(french?0.48:0.42);await tts.speak(text);}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('La voix n’est pas disponible sur cet appareil.')));}}
 Future<void> testPronunciation()async{
  try{
   final available=await speech.initialize(onStatus:(status){if(status=='done'||status=='notListening'){if(mounted)setState(()=>listening=false);}},onError:(_){if(mounted)setState(()=>listening=false);});
   if(!available){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('La reconnaissance vocale n’est pas disponible. Vérifie la langue et les autorisations du téléphone.')));return;}
   setState((){recognized='';listening=true;});
   await speech.listen(listenOptions:SpeechListenOptions(localeId:'en_US',listenFor:const Duration(seconds:8),pauseFor:const Duration(seconds:3)),onResult:(result){if(mounted)setState(()=>recognized=result.recognizedWords);if(result.finalResult&&mounted)setState(()=>listening=false);});
  }catch(_){if(mounted){setState(()=>listening=false);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Impossible de démarrer le test vocal.')));}}
 }
 int? pronunciationPercent(String target,String heard){
  final expected=target.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'),' ').split(RegExp(r'\s+')).where((w)=>w.isNotEmpty).toSet();
  final spoken=heard.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'),' ').split(RegExp(r'\\s+')).where((w)=>w.isNotEmpty).toSet();
  if(expected.isEmpty||spoken.isEmpty)return null;
  return ((expected.where(spoken.contains).length/expected.length)*100).round();
 }
 @override Widget build(BuildContext context){
  final l=widget.lesson;
  final isCorrect=checked&&selected==l.answer;
  return Scaffold(
   appBar:AppBar(title:Text('${l.level} • Leçon'),leading:IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.close))),
   body:SafeArea(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(18,14,18,8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text(l.title,style:const TextStyle(color:navy,fontWeight:FontWeight.bold,fontSize:20)),
     if(lessonIllustration(l).isNotEmpty)Padding(padding:const EdgeInsets.only(top:8,bottom:4),child:Row(children:[Text(lessonIllustration(l),style:const TextStyle(fontSize:32)),const SizedBox(width:9),const Text('Aide visuelle',style:TextStyle(color:Colors.black54,fontSize:12))])),
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
      Text(l.french,style:const TextStyle(color:Colors.white70,height:1.5)),
      Align(alignment:Alignment.centerRight,child:TextButton.icon(onPressed:()=>speakText(targetPhrase(l)),icon:const Icon(Icons.volume_up,color:gold),label:const Text('Écouter en anglais',style:TextStyle(color:Colors.white))))
     ])),
     const SizedBox(height:22),
     const Text('VÉRIFIE TA COMPRÉHENSION',style:TextStyle(color:blue,fontWeight:FontWeight.bold,letterSpacing:1)),
     const SizedBox(height:9),
     Row(children:[Expanded(child:Text(l.question,style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold,color:navy))),IconButton(onPressed:()=>speakText(l.question,french:RegExp(r'\b(quelle|quel|comment|que|complète|choisis|dans|trouve|lequel|laquelle)\b',caseSensitive:false).hasMatch(l.question)),icon:const Icon(Icons.volume_up,color:blue),tooltip:'Écouter la question')]),
     const SizedBox(height:12),
     if(!quizStarted)SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:startQuiz,icon:const Icon(Icons.timer_outlined),label:const Text('DÉMARRER LE QUIZ • 10 SECONDES'))),
     if(quizStarted&&!checked)Padding(padding:const EdgeInsets.only(bottom:10),child:Row(children:[const Icon(Icons.timer_outlined,color:blue),const SizedBox(width:6),Text('Temps restant : $secondsLeft s',style:TextStyle(color:secondsLeft<=3?Colors.red:blue,fontWeight:FontWeight.bold))])),
     ...List.generate(l.options.length,(i){
      final sel=selected==i,correct=checked&&i==l.answer,wrong=checked&&sel&&i!=l.answer;
      final border=correct?Colors.green:wrong?Colors.red:sel?blue:const Color(0xFFE4E6F0);
      return Container(margin:const EdgeInsets.only(bottom:9),child:InkWell(
       onTap:(!quizStarted||checked)?null:()=>setState(()=>selected=i),
       borderRadius:BorderRadius.circular(14),
       child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:correct?const Color(0xFFE8F8ED):wrong?const Color(0xFFFFEEEE):sel?const Color(0xFFEEEEFF):Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:border,width:sel||correct?2:1)),
        child:Row(children:[Expanded(child:Text(l.options[i],style:const TextStyle(color:navy,fontSize:15))),if(correct)const Icon(Icons.check_circle,color:Colors.green),if(wrong)const Icon(Icons.cancel,color:Colors.red)])
       )
      ));
     }),
     SizedBox(width:double.infinity,child:OutlinedButton.icon(onPressed:listening?()=>speech.stop():testPronunciation,icon:Icon(listening?Icons.stop_circle_outlined:Icons.mic_none),label:Text(listening?'Arrêter l’écoute (8 s)':'Tester ma prononciation'))),
     if(recognized.isNotEmpty)Container(width:double.infinity,margin:const EdgeInsets.only(top:4,bottom:10),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFFEEEEFF),borderRadius:BorderRadius.circular(12)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Résultat vocal indicatif',style:TextStyle(color:navy,fontWeight:FontWeight.bold)),
      const SizedBox(height:5),
      Text('Phrase cible : ${targetPhrase(l)}',style:const TextStyle(color:navy)),
      Text('Reconnu : $recognized',style:const TextStyle(color:navy)),
      if(pronunciationPercent(targetPhrase(l),recognized)!=null)Text('Correspondance des mots : ${pronunciationPercent(targetPhrase(l),recognized)}% • ce n’est pas une note parfaite de prononciation.',style:const TextStyle(color:navy,fontSize:12)),
      const SizedBox(height:4),
      const Text('La reconnaissance dépend du microphone et de la langue vocale installée. Elle peut fonctionner différemment hors connexion.',style:TextStyle(color:Colors.black54,fontSize:11))
     ])),
     if(checked)Container(width:double.infinity,margin:const EdgeInsets.only(top:4),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:isCorrect?const Color(0xFFE8F8ED):const Color(0xFFFFF4DF),borderRadius:BorderRadius.circular(14)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(isCorrect?'Bonne réponse !':timedOut?'Temps écoulé — on corrige ensemble':'On corrige ensemble',style:TextStyle(fontWeight:FontWeight.bold,color:isCorrect?Colors.green.shade800:Colors.brown.shade800,fontSize:16)),
      const SizedBox(height:6),
      Text(isCorrect?'Tu as bien compris cette question.':'Réponse correcte : ${l.options[l.answer]}',style:const TextStyle(fontWeight:FontWeight.w600,color:navy)),
      const SizedBox(height:6),
      Text(l.correction,style:const TextStyle(color:navy,height:1.45))
     ]))
    ]))),
    Padding(padding:const EdgeInsets.all(18),child:SizedBox(width:double.infinity,child:FilledButton(
     onPressed:()async{
      if(finished){Navigator.pop(context);return;}
      if(!quizStarted){startQuiz();return;}
      if(!checked){
       if(selected==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisis une réponse pour continuer.')));return;}
       quizTimer?.cancel();setState(()=>checked=true);return;
      }
      if(!isCorrect){setState((){selected=null;checked=false;quizStarted=false;secondsLeft=10;timedOut=false;});return;}
      quizTimer?.cancel();await widget.onComplete();
      if(mounted)setState(()=>finished=true);
     },
     child:Text(finished?'Retour au parcours':!quizStarted?'Démarrer le quiz • 10 s':!checked?'Vérifier ma réponse':isCorrect?'Terminer • +10 XP':'Réessayer après correction')
    )))
   ]))
  );
 }
}


class ReferenceBookPage extends StatefulWidget{
 final List<StudyLesson> lessons;
 const ReferenceBookPage({super.key,required this.lessons});
 @override State<ReferenceBookPage> createState()=>_ReferenceBookPageState();
}
class _ReferenceBookPageState extends State<ReferenceBookPage>{
 String query='';
 @override Widget build(BuildContext context){
  final q=query.trim().toLowerCase();
  final filtered=widget.lessons.where((l)=>q.isEmpty||'${l.title} ${l.explanation} ${l.example}'.toLowerCase().contains(q)).toList();
  return Scaffold(appBar:AppBar(title:const Text('Livre de référence')),body:Column(children:[
   Padding(padding:const EdgeInsets.all(16),child:TextField(onChanged:(v)=>setState(()=>query=v),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),labelText:'Rechercher une notion, un verbe ou une expression',border:OutlineInputBorder()))),
   Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Align(alignment:Alignment.centerLeft,child:Text('${filtered.length} résultats • hors connexion',style:const TextStyle(color:Colors.black54,fontSize:12)))),
   const SizedBox(height:8),
    Expanded(
     child: filtered.isEmpty
      ? const Center(child:Text('Aucun résultat. Essaie un mot plus simple.'))
      : ListView.builder(
       padding:const EdgeInsets.fromLTRB(16,0,16,16),
       itemCount:filtered.length,
       itemBuilder:(context,i){
        final l=filtered[i];
        return Card(
         color:Colors.white,
         margin:const EdgeInsets.only(bottom:8),
         child:ListTile(
          title:Text(l.title,style:const TextStyle(fontWeight:FontWeight.bold,color:navy)),
          subtitle:Text('${l.level} • ${l.subtitle}',maxLines:2,overflow:TextOverflow.ellipsis),
          trailing:const Icon(Icons.chevron_right),
          onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ReferenceEntryPage(lesson:l))),
         ),
        );
       },
      ),
    ),
  ]));
 }
}
class ReferenceEntryPage extends StatelessWidget{
 final StudyLesson lesson;
 const ReferenceEntryPage({super.key,required this.lesson});
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(lesson.level)),body:ListView(padding:const EdgeInsets.all(18),children:[
  Text(lesson.title,style:const TextStyle(color:navy,fontSize:23,fontWeight:FontWeight.bold)),
  const SizedBox(height:14),
  Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,blue]),borderRadius:BorderRadius.circular(20)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const Text('EXPLICATION',style:TextStyle(color:gold,fontWeight:FontWeight.bold)),
   const SizedBox(height:8),
   Text(lesson.explanation,style:const TextStyle(color:Colors.white,fontSize:17,height:1.5)),
   const SizedBox(height:18),
   const Text('EXEMPLE',style:TextStyle(color:gold,fontWeight:FontWeight.bold)),
   const SizedBox(height:8),
   Text(lesson.example,style:const TextStyle(color:Colors.white,fontSize:16,height:1.5)),
   const SizedBox(height:8),
   Text(lesson.french,style:const TextStyle(color:Colors.white70,height:1.4)),
  ])),
  const SizedBox(height:16),
  const Text('CORRECTION / À RETENIR',style:TextStyle(color:blue,fontWeight:FontWeight.bold)),
  const SizedBox(height:6),
  Text(lesson.correction,style:const TextStyle(color:navy,fontSize:16,height:1.5))
 ]));
}
class OfflineChatPage extends StatefulWidget{
 final List<StudyLesson> lessons;
 const OfflineChatPage({super.key,required this.lessons});
 @override State<OfflineChatPage> createState()=>_OfflineChatPageState();
}
class _OfflineChatPageState extends State<OfflineChatPage>{
 final controller=TextEditingController();
 final scrollController=ScrollController();
 final messages=<Map<String,String>>[
  {'role':'bot','text':'Salut ! Je suis JoBot, ton aide pédagogique hors connexion. Pose une question sur une leçon, un verbe ou une expression du cours.'}
 ];
 @override void dispose(){controller.dispose();scrollController.dispose();super.dispose();}
 String answer(String question){
  final q=question.toLowerCase().replaceAll(RegExp(r'[^a-zàâçéèêëîïôûùüÿñæœ0-9 ]'),' ');
  final terms=q.split(RegExp(r'\s+')).where((w)=>w.length>2).toSet();
  if(terms.isEmpty)return 'Écris une question ou un mot, par exemple « eat », « to be », « present simple » ou « comment dire merci ».';
  final scored=widget.lessons.map((l){
   final text='${l.title} ${l.explanation} ${l.example} ${l.french}'.toLowerCase();
   var score=0;
   for(final term in terms){if(l.title.toLowerCase().contains(term)){score+=4;}else if(text.contains(term)){score++;}}
   return (lesson:l,score:score);
  }).where((x)=>x.score>0).toList()..sort((a,b)=>b.score.compareTo(a.score));
  if(scored.isEmpty)return 'Je n’ai pas encore trouvé une réponse précise dans le cours installé. Essaie un mot-clé plus court, ou consulte le Livre de référence. JoBot utilise une base locale : il ne connaît pas encore toutes les questions possibles.';
  final best=scored.take(2).toList();
  return best.map((x)=>'Leçon : ${x.lesson.title}\nExplication : ${x.lesson.explanation}\nExemple : ${x.lesson.example}\nEn français : ${x.lesson.french}\nÀ retenir : ${x.lesson.correction}').join('\n\n---\n\n');
 }
 void send(){
  final q=controller.text.trim();if(q.isEmpty)return;
  setState(()=>messages.add({'role':'user','text':q}));
  controller.clear();
  setState(()=>messages.add({'role':'bot','text':answer(q)}));
  WidgetsBinding.instance.addPostFrameCallback((_){if(scrollController.hasClients)scrollController.animateTo(scrollController.position.maxScrollExtent,duration:const Duration(milliseconds:250),curve:Curves.easeOut);});
 }
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('JoBot • hors connexion')),body:Column(children:[
  const Padding(padding:EdgeInsets.all(12),child:Text('JoBot recherche dans le cours installé. Pour les questions hors de sa base, il te le dira au lieu d’inventer une réponse.',style:TextStyle(color:Colors.black54,fontSize:12))),
  Expanded(child:ListView.builder(controller:scrollController,padding:const EdgeInsets.all(14),itemCount:messages.length,itemBuilder:(context,i){final m=messages[i],isUser=m['role']=='user';return Align(alignment:isUser?Alignment.centerRight:Alignment.centerLeft,child:Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(13),constraints:const BoxConstraints(maxWidth:340),decoration:BoxDecoration(color:isUser?blue:Colors.white,borderRadius:BorderRadius.circular(16),border:isUser?null:Border.all(color:const Color(0xFFE6E7F0))),child:Text(m['text']??'',style:TextStyle(color:isUser?Colors.white:navy,height:1.4))));})),
  SafeArea(top:false,child:Padding(padding:const EdgeInsets.fromLTRB(12,6,12,12),child:Row(children:[Expanded(child:TextField(controller:controller,onSubmitted:(_)=>send(),minLines:1,maxLines:4,decoration:const InputDecoration(hintText:'Écris ta question…',border:OutlineInputBorder()))),const SizedBox(width:8),IconButton.filled(onPressed:send,icon:const Icon(Icons.send),tooltip:'Envoyer')]))),
 ]));
}

class SettingsPage extends StatelessWidget{
 final int goal; final ValueChanged<int> onGoal; final bool darkMode,remindersEnabled,reminderSound; final TimeOfDay reminderTime; final ValueChanged<bool> onDarkMode,onReminderToggle,onReminderSound; final ValueChanged<TimeOfDay> onReminderTime; final VoidCallback onContact,onReset,onBook,onChat;
 const SettingsPage({super.key,required this.goal,required this.darkMode,required this.onDarkMode,required this.remindersEnabled,required this.reminderSound,required this.reminderTime,required this.onReminderToggle,required this.onReminderTime,required this.onReminderSound,required this.onGoal,required this.onContact,required this.onReset,required this.onBook,required this.onChat});
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Paramètres')),body:ListView(padding:const EdgeInsets.all(18),children:[
 const Text('APPRENTISSAGE',style:TextStyle(color:blue,fontWeight:FontWeight.bold,letterSpacing:1)),const SizedBox(height:10),Card(color:Colors.white,child:Column(children:[const ListTile(leading:Icon(Icons.flag_outlined,color:blue),title:Text('Objectif quotidien'),subtitle:Text('Choisis ton objectif en XP par jour')),Padding(padding:const EdgeInsets.symmetric(horizontal:14),child:Wrap(spacing:7,children:[10,15,20,30,50].map((v)=>ChoiceChip(label:Text('$v XP'),selected:goal==v,onSelected:(_)=>onGoal(v))).toList())),const SizedBox(height:10),const Divider(),const ListTile(leading:Icon(Icons.offline_bolt,color:blue),title:Text('Apprentissage hors ligne'),subtitle:Text('Les leçons et la progression sont enregistrées sur cet appareil.')),const Divider(height:1),SwitchListTile(secondary:const Icon(Icons.dark_mode_outlined,color:blue),title:const Text('Mode sombre'),subtitle:const Text('Activer le thème sombre de l’application'),value:darkMode,onChanged:onDarkMode),const Divider(height:1),SwitchListTile(secondary:const Icon(Icons.notifications_active_outlined,color:blue),title:const Text('Rappel quotidien'),subtitle:const Text('Recevoir un rappel pour pratiquer l’anglais'),value:remindersEnabled,onChanged:onReminderToggle),ListTile(leading:const Icon(Icons.access_time,color:blue),title:const Text('Heure du rappel'),subtitle:Text(reminderTime.format(context)),trailing:const Icon(Icons.chevron_right),onTap:()async{final picked=await showTimePicker(context:context,initialTime:reminderTime);if(picked!=null)onReminderTime(picked);}),SwitchListTile(secondary:const Icon(Icons.notifications_outlined,color:blue),title:const Text('Sonnerie du rappel'),subtitle:const Text('Activer ou couper le son des rappels'),value:reminderSound,onChanged:remindersEnabled?onReminderSound:null)])),const SizedBox(height:18),
 const Text('OUTILS D’APPRENTISSAGE',style:TextStyle(color:blue,fontWeight:FontWeight.bold,letterSpacing:1)),const SizedBox(height:10),Card(color:Colors.white,child:Column(children:[ListTile(leading:const Icon(Icons.menu_book,color:blue),title:const Text('Livre de référence'),subtitle:const Text('Rechercher une règle, un mot ou une leçon hors ligne'),trailing:const Icon(Icons.chevron_right),onTap:onBook),const Divider(height:1),ListTile(leading:const Icon(Icons.chat_bubble_outline,color:blue),title:const Text('JoBot — aide pédagogique'),subtitle:const Text('Pose une question sur les notions du cours'),trailing:const Icon(Icons.chevron_right),onTap:onChat)])),const SizedBox(height:18),const Text('À PROPOS ET CONTACT',style:TextStyle(color:blue,fontWeight:FontWeight.bold,letterSpacing:1)),const SizedBox(height:10),Card(color:Colors.white,child:Column(children:[const ListTile(leading:Icon(Icons.person_outline,color:blue),title:Text('CRÉÉ PAR JOSEPH MARCHAND'),subtitle:Text('DÉVELOPPEUR • English Pro A1 à C2')),const ListTile(leading:Icon(Icons.chat,color:Colors.green),title:Text('WhatsApp'),subtitle:Text('+243 843 478 142')),ListTile(leading:const Icon(Icons.open_in_new,color:Colors.green),title:const Text('Nous contacter sur WhatsApp'),trailing:const Icon(Icons.chevron_right),onTap:onContact)])),const SizedBox(height:18),Card(color:Colors.white,child:ListTile(leading:const Icon(Icons.restart_alt,color:Colors.red),title:const Text('Réinitialiser ma progression'),subtitle:const Text('Effacer les leçons terminées et les XP'),onTap:onReset)),const SizedBox(height:18),const Center(child:Text('English Pro • Version 2.0',style:TextStyle(color:Colors.black45)))
 ]));
}
Widget avatar(String? data,String name,double size){Widget child;if(data!=null){try{child=Image.memory(base64Decode(data),width:size,height:size,fit:BoxFit.cover);}catch(_){child=Text(name.isEmpty?'E':name[0].toUpperCase());}}else{child=Text(name.isEmpty?'E':name[0].toUpperCase());}return CircleAvatar(radius:size/2,backgroundColor:gold,child:ClipOval(child:SizedBox(width:size,height:size,child:Center(child:child))));}
