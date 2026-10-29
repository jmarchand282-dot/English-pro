import 'dart:math';
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
 String get currentLevel {for(final l in levels){final levelLessons=lessons.where((x)=>x.level==l).toList();if(levelLessons.isEmpty||levelLessons.any((x)=>!done.contains(x.id)))return l;final units=levelLessons.map((x)=>x.unit).toSet();if(units.any((unit)=>!conversationsDone.contains('$l-U$unit')))return l;}return 'C2';}
 int count(String l)=>lessons.where((x)=>x.level==l&&done.contains(x.id)).length;
 int total(String l)=>lessons.where((x)=>x.level==l).length;
 StudyLesson? get next {for(final l in lessons){if(!done.contains(l.id))return l;}return null;}
 bool isUnlocked(StudyLesson l)=>isLessonUnlockedInCurriculum(lesson:l,lessons:lessons,completedLessonIds:done,completedConversationKeys:conversationsDone);
 int get todayXp=>prefs.getInt('today_xp')??0;
 Future<void> complete(StudyLesson l) async {if(done.contains(l.id))return;final n=DateTime.now();final today='${n.year}-${n.month}-${n.day}';if(lastDate!=today){final y=n.subtract(const Duration(days:1));final yesterday='${y.year}-${y.month}-${y.day}';streak=lastDate==yesterday?streak+1:1;lastDate=today;await prefs.setInt('today_xp',0);}done.add(l.id);xp+=10;await prefs.setInt('today_xp',todayXp+10);await save();if(mounted)setState((){});}
 bool isLevelUnlocked(String lev)=>isLevelUnlockedInCurriculum(level:lev,lessons:lessons,completedLessonIds:done,completedConversationKeys:conversationsDone);
 Future<void> openLesson(StudyLesson l) async {if(!isUnlocked(l)){final i=lessons.indexWhere((x)=>x.id==l.id);var message='Termine la leçon précédente pour débloquer celle-ci.';if(i>0){final previous=lessons[i-1];if(done.contains(previous.id)&&previous.level==l.level&&previous.unit!=l.unit){message='Termine la conversation de validation du sous-chapitre précédent.';}else if(done.contains(previous.id)&&previous.level!=l.level){message='Valide les conversations de tous les sous-chapitres du niveau précédent.';}}ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message)));return;}await Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonPage(lesson:l,alreadyDone:done.contains(l.id),onComplete:()=>complete(l))));if(mounted)setState((){});}
 Future<void> pickPhoto() async {try{final f=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:65,maxWidth:420);if(f==null)return;photo=base64Encode(await f.readAsBytes());await save();if(mounted)setState((){});}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Photo impossible à charger. Réessaie.')));}}
 void profile(){final c=TextEditingController(text:name=='Learner'?'':name);showModalBottomSheet(context:context,isScrollControlled:true,builder:(ctx)=>Padding(padding:EdgeInsets.fromLTRB(22,22,22,MediaQuery.of(ctx).viewInsets.bottom+24),child:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Mon profil',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:14),GestureDetector(onTap:pickPhoto,child:avatar(photo,name,78)),TextButton.icon(onPressed:pickPhoto,icon:const Icon(Icons.photo_camera_outlined),label:const Text('Choisir une photo')),TextField(controller:c,decoration:const InputDecoration(labelText:'Ton nom',border:OutlineInputBorder())),const SizedBox(height:14),SizedBox(width:double.infinity,child:FilledButton(onPressed:()async{name=c.text.trim().isEmpty?'Learner':c.text.trim();await save();if(ctx.mounted)Navigator.pop(ctx);if(mounted)setState((){});},child:const Text('Enregistrer')))])));}
 void settings(){Navigator.push(context,MaterialPageRoute(builder:(_)=>SettingsPage(goal:goal,darkMode:darkMode,onDarkMode:(v)async{darkMode=v;appThemeMode.value=v?ThemeMode.dark:ThemeMode.light;await save();if(mounted)setState((){});},remindersEnabled:remindersEnabled,reminderSound:reminderSound,reminderTime:TimeOfDay(hour:reminderHour,minute:reminderMinute),onReminderToggle:(v)async{remindersEnabled=v;if(v){try{await localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();await scheduleDailyReminder(hour:reminderHour,minute:reminderMinute,sound:reminderSound);}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Impossible d’activer le rappel. Vérifie les autorisations de notification.')));}}else{await cancelDailyReminder();}await save();if(mounted)setState((){});},onReminderTime:(t)async{reminderHour=t.hour;reminderMinute=t.minute;if(remindersEnabled){try{await scheduleDailyReminder(hour:reminderHour,minute:reminderMinute,sound:reminderSound);}catch(_){}}await save();if(mounted)setState((){});},onReminderSound:(v)async{reminderSound=v;if(remindersEnabled){try{await scheduleDailyReminder(hour:reminderHour,minute:reminderMinute,sound:reminderSound);}catch(_){}}await save();if(mounted)setState((){});},onGoal:(v)async{goal=v;await save();if(mounted)setState((){});},onContact:contact,onReset:reset,onBook:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ReferenceBookPage(lessons:lessons))),onChat:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>OfflineChatPage(lessons:lessons))))));}
 Future<void> contact()async{final u=Uri.parse('https://wa.me/243843478142?text=Bonjour%20English%20Pro%2C%20j%27ai%20besoin%20d%27aide.');if(!await launchUrl(u,mode:LaunchMode.externalApplication)&&mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('WhatsApp ne peut pas être ouvert.')));}
 Future<void> reset()async{final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Effacer la progression ?'),content:const Text('Toutes les leçons terminées et les XP seront supprimés sur cet appareil.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Effacer'))]));if(ok!=true)return;done.clear();conversationsDone.clear();xp=0;streak=0;lastDate='';await prefs.setInt('today_xp',0);await save();if(mounted)setState((){});}
 @override
 Widget build(BuildContext context) {
  if(loading) return const Scaffold(body:Center(child:CircularProgressIndicator()));
  final level=currentLevel;
  final upcoming=next;
  final completedA1=count('A1');
  final totalA1=total('A1');
  return Scaffold(
   appBar:AppBar(
    title:const Row(children:[EnglishProBrandMark(size:34),SizedBox(width:9),Text('English Pro',style:TextStyle(fontWeight:FontWeight.bold))]),
    actions:[
     IconButton(onPressed:profile,icon:avatar(photo,name,30),tooltip:'Profil'),
     IconButton(onPressed:settings,icon:const Icon(Icons.settings_outlined),tooltip:'Paramètres'),
    ],
   ),
   body:ListView(padding:const EdgeInsets.fromLTRB(18,18,18,24),children:[
    Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,blue]),borderRadius:BorderRadius.circular(26)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Row(children:[EnglishProBrandMark(size:46),SizedBox(width:12),Expanded(child:Text('ENGLISH PRO • LEARN EVERY DAY',style:TextStyle(color:gold,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1.0)))]),
     const SizedBox(height:16),
     Text('BONJOUR, ${name.toUpperCase()}',style:const TextStyle(color:gold,fontSize:11,fontWeight:FontWeight.bold,letterSpacing:1.2)),
     const SizedBox(height:12),
     const Text('Hello! Welcome to English Pro',style:TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.bold,height:1.2)),
     const SizedBox(height:8),
     const Text('Apprends l’anglais étape par étape, avec des explications et des exercices.',style:TextStyle(color:Colors.white70,fontSize:14,height:1.4)),
     const SizedBox(height:20),
     SizedBox(width:double.infinity,height:62,child:FilledButton.icon(
      style:FilledButton.styleFrom(backgroundColor:gold,foregroundColor:navy,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),textStyle:const TextStyle(fontSize:18,fontWeight:FontWeight.w900,letterSpacing:1)),
      onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>CoursePathPage(lessons:lessons,done:done,conversationsDone:conversationsDone,currentLevel:level,levelUnlocked:isLevelUnlocked,completedCount:count,totalCount:total,lessonUnlocked:isUnlocked,onOpenLesson:openLesson,onConversationComplete:(lev,unit)async{conversationsDone.add('$lev-U$unit');await save();if(mounted)setState((){});}))),
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
     Text('Niveau actuel : $level • ${levelNames[level]}',style:const TextStyle(color:navy,fontWeight:FontWeight.w600,fontSize:13)),
     const SizedBox(height:4),
     Text('Niveau conseillé par le test : $placementLevel • ${levelNames[placementLevel]}',style:const TextStyle(color:Colors.black54,fontSize:13)),
     const SizedBox(height:4),
     Text('Le parcours reste progressif : A1 se termine avant le déverrouillage de A2.',style:TextStyle(color:Colors.blueGrey.shade700,fontSize:12)),
     const SizedBox(height:8),
     Text('Progression A1 : $completedA1 / $totalA1 leçons',style:const TextStyle(color:navy,fontWeight:FontWeight.w600)),
     const SizedBox(height:6),
     ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(value:totalA1==0?0:completedA1/totalA1,minHeight:6,color:Colors.green,backgroundColor:const Color(0xFFE7E8F2))),
    ])),
    const SizedBox(height:18),
    const Text('DÉCOUVRIR',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900,letterSpacing:1.2,color:navy)),
    const SizedBox(height:10),
    Row(children:[
     Expanded(child:_discoveryCard(context,icon:Icons.photo_library_outlined,title:'Images & mots',subtitle:'Vocabulaire illustré',color:blue,onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const MultimediaHubPage())))),
     const SizedBox(width:12),
     Expanded(child:_discoveryCard(context,icon:Icons.play_circle_outline,title:'Vidéos',subtitle:'Écoute et dialogues',color:const Color(0xFF7C3AED),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const MultimediaHubPage(initialTab:1))))),
    ]),
    const SizedBox(height:18),
    if(upcoming!=null) Text('Prochaine étape : ${upcoming.title}',style:const TextStyle(color:Colors.black54,fontSize:12)),
    const SizedBox(height:18),
    const Center(child:Text('CRÉÉ PAR JOSEPH MARCHAND • DÉVELOPPEUR',textAlign:TextAlign.center,style:TextStyle(color:Colors.black45,fontSize:11,fontWeight:FontWeight.w600))),
   ])
  );
 }
 Widget _discoveryCard(BuildContext context,{required IconData icon,required String title,required String subtitle,required Color color,required VoidCallback onTap})=>Material(
  color:Colors.white,borderRadius:BorderRadius.circular(18),
  child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(18),child:Container(
   padding:const EdgeInsets.all(15),
   decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0xFFE7E8F2))),
   child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Container(width:44,height:44,decoration:BoxDecoration(color:color.withValues(alpha:.12),borderRadius:BorderRadius.circular(14)),child:Icon(icon,color:color,size:27)),
    const SizedBox(height:12),Text(title,style:const TextStyle(color:navy,fontWeight:FontWeight.w800,fontSize:15)),
    const SizedBox(height:4),Text(subtitle,style:const TextStyle(color:Colors.black54,fontSize:11)),
   ]),
  )),
 );
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
    const Center(child:EnglishProBrandMark(size:72)),
    const SizedBox(height:8),
    const Center(child:Text('ENGLISH PRO',style:TextStyle(color:navy,fontSize:15,fontWeight:FontWeight.w900,letterSpacing:2))),
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
     SizedBox(height:54,child:FilledButton(onPressed:(){if(nameController.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Entre ton nom pour créer ton profil.')));return;}setState(()=>page=1);},child:const Text('FAIRE LE TEST DE NIVEAU →',style:TextStyle(fontWeight:FontWeight.bold))))
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
    final previousUnits=units.where((u)=>u<unit).toList();
    final previousUnit=previousUnits.isEmpty?null:previousUnits.last;
    final unlocked=previousUnit==null||(levelLessons.where((l)=>l.unit==previousUnit).every((l)=>widget.done.contains(l.id))&&widget.conversationsDone.contains('${widget.level}-U$previousUnit'));
    final conversationValidated=widget.conversationsDone.contains('${widget.level}-U$unit');
    final finished=doneCount==list.length&&conversationValidated;
    final title=widget.level=='A1'?(a1UnitTitles[unit]??'Sous-chapitre $unit'):'Sous-chapitre $unit • ${list.first.title}';
    return Card(color:Colors.white,margin:const EdgeInsets.only(bottom:11),child:ListTile(
     contentPadding:const EdgeInsets.all(14),
     leading:Container(width:46,height:46,decoration:BoxDecoration(color:unlocked?blue.withValues(alpha:.12):const Color(0xFFF0F0F5),borderRadius:BorderRadius.circular(13)),child:Icon(finished?Icons.check_circle:unlocked?Icons.play_circle_outline:Icons.lock,color:finished?Colors.green:unlocked?blue:Colors.grey)),
     title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold,color:navy)),
     subtitle:Text('$doneCount / ${list.length} leçons • ${conversationValidated?'conversation validée':'conversation à valider'}'),
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
 @override Widget build(BuildContext context){
  final completed=widget.lessons.where((l)=>widget.done.contains(l.id)).length;
  final allLessonsDone=completed==widget.lessons.length;
  final conversationKey='${widget.level}-U${widget.unit}';
  final conversationValidated=widget.conversationsDone.contains(conversationKey);
  return Scaffold(appBar:AppBar(title:Text('${widget.level} • Leçons')),body:ListView(padding:const EdgeInsets.all(16),children:[
   Text(widget.title,style:const TextStyle(fontSize:21,fontWeight:FontWeight.bold,color:navy)),
   const SizedBox(height:6),
   Text('$completed / ${widget.lessons.length} leçons terminées',style:const TextStyle(color:Colors.black54)),
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
   }),
   const SizedBox(height:12),
   Card(color:Colors.white,child:ListTile(
    leading:Icon(conversationValidated?Icons.check_circle:allLessonsDone?Icons.forum_outlined:Icons.lock,color:conversationValidated?Colors.green:allLessonsDone?blue:Colors.grey,size:30),
    title:const Text('Conversation de validation',style:TextStyle(fontWeight:FontWeight.bold,color:navy)),
    subtitle:Text(conversationValidated?'Conversation validée — sous-chapitre terminé':allLessonsDone?'Réponds naturellement dans une conversation pour débloquer la suite':'Termine toutes les leçons pour ouvrir la conversation'),
    trailing:Icon(conversationValidated?Icons.check_circle:allLessonsDone?Icons.chevron_right:Icons.lock,color:conversationValidated?Colors.green:allLessonsDone?blue:Colors.grey),
    onTap:!allLessonsDone?(){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Termine les leçons de ce sous-chapitre avant la conversation.')));}:()async{
     await Navigator.push(context,MaterialPageRoute(builder:(_)=>ConversationValidationPage(level:widget.level,unit:widget.unit,title:widget.title,onComplete:()=>widget.onConversationComplete(widget.level,widget.unit))));
     if(mounted)setState((){});
    },
   )),
  ]));
 }
}



class _ConversationTurn{
 final String prompt; final List<String> options; final int answer; final String explanation;
 const _ConversationTurn(this.prompt,this.options,this.answer,this.explanation);
}
List<_ConversationTurn> _conversationTurns(String level,int unit){
 if(level!='A1'){return const [
  _ConversationTurn('Can you tell me more about that?', ['Certainly. Here is one example.','I am ten years old.','Turn left at the corner.'],0,'Cette réponse continue la conversation et donne un exemple.'),
  _ConversationTurn('What is your opinion?', ['I think it is useful.','At seven o’clock.','I have two brothers.'],0,'I think… sert à exprimer une opinion.'),
  _ConversationTurn('Could you explain that again?', ['Of course. Let me explain it another way.','It costs five dollars.','I am wearing a coat.'],0,'Cette réponse répond directement à la demande de clarification.'),
  _ConversationTurn('How would you summarize your idea?', ['The main point is that practice helps us improve.','My name is Alex.','The bus stop is near the bank.'],0,'Un résumé présente l’idée principale en une phrase claire.'),
 ];}
 switch(unit){
  case 1:return const [
   _ConversationTurn('Hello! What’s your name?',['My name is Alex.','I’m fine, thanks.','See you tomorrow.'],0,'My name is… sert à se présenter.'),
   _ConversationTurn('How are you?',['I’m fine, thanks. And you?','I’m twelve years old.','It’s blue.'],0,'I’m fine, thanks est une réponse naturelle à How are you?'),
   _ConversationTurn('Nice to meet you.',['Nice to meet you too.','Where is the bus?','I like rice.'],0,'Too signifie aussi : Nice to meet you too.'),
   _ConversationTurn('Could you spell your name, please?',['A-L-E-X.','I’m from Canada.','At seven o’clock.'],0,'Spell demande de donner les lettres du nom.'),
  ];
  case 2:return const [
   _ConversationTurn('What is this?',['It’s a book.','I’m fifteen.','Go straight.'],0,'It’s a… identifie un objet singulier.'),
   _ConversationTurn('Are you ready?',['Yes, I am.','Yes, I do.','Yes, I can.'],0,'La réponse courte reprend be : Yes, I am.'),
   _ConversationTurn('Who is she?',['She is my sister.','It is on the table.','I am fine.'],0,'Who demande l’identité d’une personne.'),
   _ConversationTurn('Where is the pen?',['It’s on the table.','I am a student.','It’s expensive.'],0,'Where demande un lieu ; on indique la position de l’objet.'),
  ];
  case 3:return const [
   _ConversationTurn('What do you want to learn?',['I want to learn English.','I want English learns.','I learning English.'],0,'Want to + verbe exprime une action souhaitée.'),
   _ConversationTurn('Do you like music?',['Yes, I do.','Yes, I am.','Yes, I can.'],0,'La réponse courte à Do you…? reprend do.'),
   _ConversationTurn('Can you help me?',['Yes, of course. What do you need?','I’m ten o’clock.','It’s blue.'],0,'Can you help me? demande de l’aide ; la réponse propose d’aider.'),
   _ConversationTurn('How do you get to school?',['I go by bus.','I am bus.','I go school bus.'],0,'By bus indique le moyen de transport.'),
  ];
  case 4:return const [
   _ConversationTurn('Who is that woman?',['She is my aunt.','It is under the table.','I’m hungry.'],0,'Aunt signifie tante.'),
   _ConversationTurn('What does your brother look like?',['He is tall and friendly.','He is at seven.','He likes rice yesterday.'],0,'Pour décrire une personne, utilise he is + adjectifs.'),
   _ConversationTurn('What are you wearing?',['I’m wearing a blue shirt.','I’m wear a blue shirt.','I wearing yesterday.'],0,'I’m wearing décrit les vêtements portés.'),
   _ConversationTurn('Whose bag is this?',['It’s mine.','It’s my.','I mine bag.'],0,'Mine remplace my + nom.'),
  ];
  case 5:return const [
   _ConversationTurn('What time do you wake up?',['I wake up at six.','I’m wake at six.','I wake up Monday six.'],0,'Les habitudes utilisent le présent simple.'),
   _ConversationTurn('What day is it today?',['It’s Tuesday.','It’s seven dollars.','I’m a teacher.'],0,'La réponse donne un jour de la semaine.'),
   _ConversationTurn('How often do you study English?',['I study every day.','I am study yesterday.','I study at the blue.'],0,'Every day indique une fréquence quotidienne.'),
   _ConversationTurn('Are you free on Saturday?',['Yes, I’m free.','Yes, I free at.','I’m yesterday.'],0,'I’m free signifie je suis disponible.'),
  ];
  case 6:return const [
   _ConversationTurn('Excuse me, where is the bank?',['Go straight and turn left.','I’m twelve years old.','I’d like a sandwich.'],0,'Go straight et turn left sont des consignes de direction.'),
   _ConversationTurn('Is it far from here?',['No, it’s near the park.','I’m wearing a coat.','It costs two dollars.'],0,'Near signifie près de.'),
   _ConversationTurn('How can I get to the station?',['You can take the bus.','I have two sisters.','I’m hungry.'],0,'Take the bus indique un moyen de transport.'),
   _ConversationTurn('Where is the library?',['It’s next to the school.','It’s a red.','I can library.'],0,'Next to signifie à côté de.'),
  ];
  case 7:return const [
   _ConversationTurn('What would you like to drink?',['I’d like some water, please.','I’m from Canada.','Turn right.'],0,'I’d like est une formule polie pour commander.'),
   _ConversationTurn('How much is the sandwich?',['It’s five dollars.','I’m five years.','It is on the table.'],0,'How much is…? demande un prix.'),
   _ConversationTurn('For here or to go?',['To go, please.','At seven o’clock.','I’m a student.'],0,'To go signifie à emporter.'),
   _ConversationTurn('Anything else?',['No, that’s all, thank you.','I’m your name.','Turn left.'],0,'That’s all signifie ce sera tout.'),
  ];
  case 8:return const [
   _ConversationTurn('What do you do for fun?',['I play football with my friends.','I’m at seven.','It’s under the desk.'],0,'Cette réponse décrit une activité de loisir.'),
   _ConversationTurn('Would you like to play basketball?',['I’d love to!','I’m twelve o’clock.','I’m play yesterday.'],0,'I’d love to accepte une invitation avec enthousiasme.'),
   _ConversationTurn('Can you swim?',['No, I can’t.','No, I’m not.','No, I don’t can.'],0,'La réponse courte reprend can/can’t.'),
   _ConversationTurn('When can we meet?',['How about Saturday?','It is my book.','I like the red.'],0,'How about Saturday? propose un autre moment.'),
  ];
  case 9:return const [
   _ConversationTurn('What are you doing?',['I’m studying now.','I study yesterday now.','I am study.'],0,'Le présent continu décrit une action en cours.'),
   _ConversationTurn('What’s the weather like?',['It’s rainy and windy.','It’s seven o’clock.','I’m from Canada.'],0,'Rainy et windy décrivent la météo.'),
   _ConversationTurn('Sorry, I didn’t understand.',['Could you say that again, please?','I’m wearing shoes.','It costs two dollars.'],0,'Cette expression demande de répéter.'),
   _ConversationTurn('Can you help me? I’m lost.',['Of course. Where do you need to go?','I like apples.','Good night.'],0,'La réponse aide la personne et poursuit la conversation.'),
  ];
  default:return const [
   _ConversationTurn('Hello! Can you introduce yourself?',['Hi, I’m Alex. I’m from Canada.','Turn left at the corner.','It costs five dollars.'],0,'Une présentation donne le prénom et peut donner le pays d’origine.'),
   _ConversationTurn('What do you usually do every day?',['I go to school and study English.','I am go yesterday.','The book is under.'],0,'Le présent simple décrit une routine.'),
   _ConversationTurn('Could you repeat the question?',['Of course. I’ll say it more slowly.','I’m hungry.','It’s blue.'],0,'Une réponse utile confirme que l’on va répéter plus lentement.'),
   _ConversationTurn('What would you like to do this weekend?',['I’d like to play football with my friends.','I am fourteen o’clock.','Where is my name?'],0,'I’d like to + verbe permet de parler d’un projet ou d’un souhait.'),
  ];
 }
}
List<_ConversationTurn> _shuffleConversation(List<_ConversationTurn> turns){
 final random=Random();
 return turns.map((turn){
  final options=turn.options.toList();
  final correctText=options[turn.answer];
  options.shuffle(random);
  return _ConversationTurn(turn.prompt,options,options.indexOf(correctText),turn.explanation);
 }).toList();
}
class ConversationValidationPage extends StatefulWidget{
 final String level; final int unit; final String title; final Future<void> Function() onComplete;
 const ConversationValidationPage({super.key,required this.level,required this.unit,required this.title,required this.onComplete});
 @override State<ConversationValidationPage> createState()=>_ConversationValidationPageState();
}
class _ConversationValidationPageState extends State<ConversationValidationPage>{
 late final List<_ConversationTurn> turns;
 final FlutterTts tts=FlutterTts();
 int index=0;int? selected;bool checked=false,finished=false,saving=false;
 @override void initState(){super.initState();turns=_shuffleConversation(_conversationTurns(widget.level,widget.unit));}
 @override void dispose(){tts.stop();super.dispose();}
 Future<void> speakPrompt(String text)async{try{await tts.setLanguage('en-US');await tts.setSpeechRate(0.42);await tts.speak(text);}catch(_){}}
 @override Widget build(BuildContext context){
  final turn=turns[index];final correct=checked&&selected==turn.answer;
  return Scaffold(appBar:AppBar(title:const Text('Conversation de validation')),body:ListView(padding:const EdgeInsets.all(18),children:[
   Text(widget.title,style:const TextStyle(color:navy,fontSize:21,fontWeight:FontWeight.bold)),
   const SizedBox(height:8),
   Text('Échange ${index+1} sur ${turns.length} • Réponds comme dans une vraie conversation.',style:const TextStyle(color:Colors.black54)),
   const SizedBox(height:14),
   Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,blue]),borderRadius:BorderRadius.circular(20)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('INTERLOCUTEUR',style:TextStyle(color:gold,fontWeight:FontWeight.bold,fontSize:11)),
    const SizedBox(height:10),
    Row(children:[Expanded(child:Text(turn.prompt,style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.bold))),IconButton(onPressed:()=>speakPrompt(turn.prompt),icon:const Icon(Icons.volume_up,color:gold))])
   ])),
   const SizedBox(height:14),
   ...List.generate(turn.options.length,(i){final sel=selected==i,good=checked&&i==turn.answer,bad=checked&&sel&&i!=turn.answer;return Container(margin:const EdgeInsets.only(bottom:9),child:InkWell(onTap:checked?null:()=>setState(()=>selected=i),borderRadius:BorderRadius.circular(14),child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:good?const Color(0xFFE8F8ED):bad?const Color(0xFFFFEEEE):sel?const Color(0xFFEEEEFF):Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:good?Colors.green:bad?Colors.red:sel?blue:const Color(0xFFE4E6F0),width:sel||good?2:1)),child:Row(children:[Expanded(child:Text(turn.options[i],style:const TextStyle(color:navy))),if(good)const Icon(Icons.check_circle,color:Colors.green),if(bad)const Icon(Icons.cancel,color:Colors.red)]))));}),
   if(checked)Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:correct?const Color(0xFFE8F8ED):const Color(0xFFFFF4DF),borderRadius:BorderRadius.circular(13)),child:Text(correct?'Bonne réponse. ${turn.explanation}':'Réponse conseillée : ${turn.options[turn.answer]}. ${turn.explanation}',style:const TextStyle(color:navy,height:1.4))),
   if(finished)Container(margin:const EdgeInsets.only(top:14),padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFFE8F8ED),borderRadius:BorderRadius.circular(14)),child:const Text('Conversation réussie ! Tu as terminé les quatre échanges. Valide maintenant pour déverrouiller le sous-chapitre suivant.',style:TextStyle(color:navy,height:1.4))),
   const SizedBox(height:18),
   SizedBox(height:54,child:FilledButton(onPressed:()async{
    if(finished){if(saving)return;setState(()=>saving=true);await widget.onComplete();if(context.mounted)Navigator.pop(context);return;}
    if(!checked){if(selected==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisis une réponse pour continuer la conversation.')));return;}setState(()=>checked=true);return;}
    if(!correct){setState((){selected=null;checked=false;});return;}
    if(index<turns.length-1){setState((){index++;selected=null;checked=false;});}else{setState(()=>finished=true);}
   },child:Text(finished?'VALIDER LA CONVERSATION':!checked?'RÉPONDRE':correct?index<turns.length-1?'CONTINUER LA CONVERSATION':'TERMINER LA CONVERSATION':'RÉESSAYER APRÈS LA CORRECTION')))
  ]));
 }
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
 int? selected; bool checked=false,finished=false,listening=false,quizStarted=false,timedOut=false; int secondsLeft=10; Timer? quizTimer; String recognized=''; late List<String> displayOptions; late int correctIndex;
 final FlutterTts tts=FlutterTts(); final SpeechToText speech=SpeechToText();
 @override void initState(){super.initState();displayOptions=widget.lesson.options.toList();final correctText=displayOptions[widget.lesson.answer];displayOptions.shuffle(Random());correctIndex=displayOptions.indexOf(correctText);}
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
  final spoken=heard.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'),' ').split(RegExp(r'\s+')).where((w)=>w.isNotEmpty).toSet();
  if(expected.isEmpty||spoken.isEmpty)return null;
  return ((expected.where(spoken.contains).length/expected.length)*100).round();
 }
 @override Widget build(BuildContext context){
  final l=widget.lesson;
  final isCorrect=checked&&selected==correctIndex;
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
     ...List.generate(displayOptions.length,(i){
      final sel=selected==i,correct=checked&&i==correctIndex,wrong=checked&&sel&&i!=correctIndex;
      final border=correct?Colors.green:wrong?Colors.red:sel?blue:const Color(0xFFE4E6F0);
      return Container(margin:const EdgeInsets.only(bottom:9),child:InkWell(
       onTap:(!quizStarted||checked)?null:()=>setState(()=>selected=i),
       borderRadius:BorderRadius.circular(14),
       child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:correct?const Color(0xFFE8F8ED):wrong?const Color(0xFFFFEEEE):sel?const Color(0xFFEEEEFF):Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:border,width:sel||correct?2:1)),
        child:Row(children:[Expanded(child:Text(displayOptions[i],style:const TextStyle(color:navy,fontSize:15))),if(correct)const Icon(Icons.check_circle,color:Colors.green),if(wrong)const Icon(Icons.cancel,color:Colors.red)])
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
      Text(isCorrect?'Tu as bien compris cette question.':'Réponse correcte : ${displayOptions[correctIndex]}',style:const TextStyle(fontWeight:FontWeight.w600,color:navy)),
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



class MultimediaHubPage extends StatefulWidget {
 final int initialTab;
 const MultimediaHubPage({super.key,this.initialTab=0});
 @override State<MultimediaHubPage> createState()=>_MultimediaHubPageState();
}
class _MultimediaHubPageState extends State<MultimediaHubPage> with SingleTickerProviderStateMixin {
 late final TabController tabs;
 final FlutterTts tts=FlutterTts();
 final List<Map<String,String>> words=[
  {'emoji':'📚','en':'Book','fr':'Livre','pron':'book'},{'emoji':'✏️','en':'Pencil','fr':'Crayon','pron':'pencil'},
  {'emoji':'🎒','en':'School bag','fr':'Sac d’école','pron':'school bag'},{'emoji':'🍎','en':'Apple','fr':'Pomme','pron':'apple'},
  {'emoji':'💧','en':'Water','fr':'Eau','pron':'water'},{'emoji':'🍞','en':'Bread','fr':'Pain','pron':'bread'},
  {'emoji':'👁️','en':'Eye','fr':'Œil','pron':'eye'},{'emoji':'👂','en':'Ear','fr':'Oreille','pron':'ear'},
  {'emoji':'👄','en':'Mouth','fr':'Bouche','pron':'mouth'},{'emoji':'🏠','en':'House','fr':'Maison','pron':'house'},
  {'emoji':'🚍','en':'Bus','fr':'Bus','pron':'bus'},{'emoji':'💻','en':'Computer','fr':'Ordinateur','pron':'computer'},
 ];
 final List<Map<String,String>> videos=[
  {'title':'Prononciation américaine','subtitle':'Sons, alphabet et mots fréquents','query':'American English pronunciation for beginners'},
  {'title':'Dialogues de la vie quotidienne','subtitle':'Saluer, se présenter et demander de l’aide','query':'English conversation for beginners with subtitles'},
  {'title':'Anglais à l’école','subtitle':'Phrases utiles en classe','query':'English classroom phrases for students beginner'},
  {'title':'Compréhension orale lente','subtitle':'Écouter des phrases simples','query':'slow English listening practice beginner subtitles'},
 ];
 @override void initState(){super.initState();tabs=TabController(length:2,vsync:this,initialIndex:widget.initialTab);}
 @override void dispose(){tabs.dispose();tts.stop();super.dispose();}
 Future<void> speak(String value) async {try{await tts.setLanguage('en-US');await tts.setSpeechRate(0.38);await tts.speak(value);}catch(_){}}
 Future<void> openVideo(String query) async {
  final uri=Uri.https('www.youtube.com','/results',{'search_query':query});
  try {if(!await launchUrl(uri,mode:LaunchMode.externalApplication)&&mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Impossible d’ouvrir les vidéos. Vérifie ta connexion.')));}}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Vérifie ta connexion Internet puis réessaie.')));}
 }
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('Médias English Pro'),bottom:TabBar(controller:tabs,tabs:const [Tab(icon:Icon(Icons.photo_library_outlined),text:'Images & mots'),Tab(icon:Icon(Icons.play_circle_outline),text:'Vidéos')])),
  body:TabBarView(controller:tabs,children:[
   ListView(padding:const EdgeInsets.all(16),children:[
    Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,blue]),borderRadius:BorderRadius.circular(20)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Row(children:[EnglishProBrandMark(size:42),SizedBox(width:12),Expanded(child:Text('SEE IT. SAY IT. LEARN IT.',style:TextStyle(color:gold,fontWeight:FontWeight.w900,letterSpacing:1)))]),
     SizedBox(height:10),Text('Regarde l’illustration, mémorise le mot anglais et écoute sa prononciation.',style:TextStyle(color:Colors.white,height:1.4)),
     SizedBox(height:8),Text('Ces cartes sont disponibles hors connexion.',style:TextStyle(color:Colors.white70,fontSize:12)),
    ])),
    const SizedBox(height:16),
    GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:words.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,mainAxisSpacing:12,crossAxisSpacing:12,childAspectRatio:1.15),itemBuilder:(context,i){
     final w=words[i];return Card(color:Theme.of(context).cardColor,clipBehavior:Clip.antiAlias,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18),side:const BorderSide(color:Color(0xFFE7E8F2))),child:Padding(padding:const EdgeInsets.all(12),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      Text(w['emoji']!,style:const TextStyle(fontSize:35)),const SizedBox(height:6),Text(w['en']!,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:16)),
      Text(w['fr']!,style:TextStyle(color:Theme.of(context).colorScheme.onSurfaceVariant,fontSize:12)),
      IconButton(onPressed:()=>speak(w['pron']!),icon:const Icon(Icons.volume_up_rounded,color:blue),tooltip:'Écouter la prononciation'),
     ])));
    }),
   ]),
   ListView(padding:const EdgeInsets.all(16),children:[
    Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFFEDE9FE),borderRadius:BorderRadius.circular(18)),child:const Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Icon(Icons.wifi,color:Color(0xFF6D28D9),size:28),SizedBox(width:12),Expanded(child:Text('Les vidéos s’ouvrent sur YouTube et nécessitent une connexion Internet. Choisis de préférence une vidéo avec sous-titres.',style:TextStyle(color:Color(0xFF312E81),height:1.4))),
    ])),
    const SizedBox(height:14),
    ...videos.map((v)=>Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(
     leading:Container(width:48,height:48,decoration:BoxDecoration(color:const Color(0xFFEDE9FE),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.play_arrow_rounded,color:Color(0xFF6D28D9),size:30)),
     title:Text(v['title']!,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Padding(padding:const EdgeInsets.only(top:4),child:Text(v['subtitle']!)),
     trailing:const Icon(Icons.open_in_new),onTap:()=>openVideo(v['query']!),
    ))),
   ]),
  ]),
 );
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


/// Reusable vector-style brand mark; no network image is required.
class EnglishProBrandMark extends StatelessWidget {
  final double size;
  const EnglishProBrandMark({super.key, this.size = 42});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6366F1), Color(0xFF312E81)],
      ),
      borderRadius: BorderRadius.circular(size * 0.28),
      border: Border.all(color: gold.withValues(alpha: 0.95), width: 1.5),
      boxShadow: [BoxShadow(color: blue.withValues(alpha: 0.22), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    alignment: Alignment.center,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Text('E', style: TextStyle(color: Colors.white, fontSize: size * 0.56, fontWeight: FontWeight.w900, height: 1)),
        Positioned(
          right: size * 0.10,
          bottom: size * 0.06,
          child: Container(
            width: size * 0.34,
            height: size * 0.34,
            decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(size * 0.10)),
            alignment: Alignment.center,
            child: Text('P', style: TextStyle(color: navy, fontSize: size * 0.22, fontWeight: FontWeight.w900, height: 1)),
          ),
        ),
      ],
    ),
  );
}
