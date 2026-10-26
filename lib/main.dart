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
 Future<void> contact()async{final u=Uri.parse('https://wa.me/243986230968?text=Bonjour%20English%20Pro%2C%20j%27ai%20besoin%20d%27aide.');if(!await launchUrl(u,mode:LaunchMode.externalApplication)&&mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('WhatsApp ne peut pas être ouvert.')));}
 Future<void> reset()async{final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Effacer la progression ?'),content:const Text('Toutes les leçons terminées et les XP seront supprimés sur cet appareil.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Effacer'))]));if(ok!=true)return;done.clear();xp=0;streak=0;lastDate='';await save();if(mounted)setState((){});}
 @override
 Widget build(BuildContext context) {
  if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
  final level = currentLevel;
  final current = lessons.where((x) => x.level == level).toList();
  final upcoming = next;
  return Scaffold(
   appBar: AppBar(
    title: const Row(children: [Icon(Icons.auto_awesome, color: gold), SizedBox(width: 8), Text('English Pro', style: TextStyle(fontWeight: FontWeight.bold))]),
    actions: [
     IconButton(onPressed: profile, icon: avatar(photo, name, 30), tooltip: 'Profil'),
     IconButton(onPressed: settings, icon: const Icon(Icons.settings_outlined), tooltip: 'Paramètres'),
    ],
   ),
   body: ListView(
    padding: const EdgeInsets.all(16),
    children: [
     Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [navy, blue]), borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Text('BON RETOUR, ${name.toUpperCase()}', style: const TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
       const SizedBox(height: 9),
       const Text('Chaque leçon te rapproche de ton objectif.', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
       const SizedBox(height: 7),
       Text('Niveau actuel : $level • ${levelNames[level]}', style: const TextStyle(color: Colors.white70)),
       const SizedBox(height: 17),
       Row(children: [stat(Icons.bolt, '$xp', 'XP'), const SizedBox(width: 8), stat(Icons.local_fire_department, '$streak', 'JOURS'), const SizedBox(width: 8), stat(Icons.menu_book, '${done.length}', 'LEÇONS')]),
      ]),
     ),
     const SizedBox(height: 14),
     Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Row(children: [const Icon(Icons.flag_outlined, color: blue), const SizedBox(width: 8), const Expanded(child: Text('Objectif quotidien', style: TextStyle(fontWeight: FontWeight.bold))), Text('$todayXp / $goal XP', style: const TextStyle(color: blue, fontWeight: FontWeight.bold))]),
       const SizedBox(height: 10),
       ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (todayXp / goal).clamp(0, 1), minHeight: 8, color: blue, backgroundColor: const Color(0xFFE7E8F2))),
      ]),
     ),
     if (upcoming != null) ...[
      const SizedBox(height: 16),
      Container(
       padding: const EdgeInsets.all(17),
       decoration: BoxDecoration(color: const Color(0xFFFFF7E5), borderRadius: BorderRadius.circular(18)),
       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('REPRENDRE MON PARCOURS', style: TextStyle(color: Color(0xFF946200), fontWeight: FontWeight.bold, fontSize: 11)),
        const SizedBox(height: 8),
        Text(upcoming.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
        Text(upcoming.subtitle, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => openLesson(upcoming), icon: const Icon(Icons.play_arrow), label: const Text('Continuer'))),
       ]),
      ),
     ],
     const SizedBox(height: 22),
     const Text('Mon parcours', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy)),
     const SizedBox(height: 4),
     const Text('Les niveaux se débloquent automatiquement. Termine chaque leçon.', style: TextStyle(color: Colors.black54)),
     const SizedBox(height: 12),
     ...levels.map((lev) {
      final all = lessons.where((x) => x.level == lev).toList();
      final completedCount = count(lev);
      final index = levels.indexOf(lev);
      final levelUnlocked = index == 0 || count(levels[index - 1]) == total(levels[index - 1]);
      final active = lev == level;
      return Container(
       margin: const EdgeInsets.only(bottom: 12),
       padding: const EdgeInsets.all(14),
       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: active ? blue : const Color(0xFFE5E6F0), width: active ? 2 : 1)),
       child: Column(children: [
        Row(children: [
         Container(width: 44, height: 44, decoration: BoxDecoration(color: levelUnlocked ? blue.withValues(alpha: .1) : const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(13)), child: Icon(levelUnlocked ? Icons.school_outlined : Icons.lock_outline, color: levelUnlocked ? blue : Colors.grey)),
         const SizedBox(width: 10),
         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$lev • ${levelNames[lev]}', style: const TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 15)), Text('$completedCount / ${all.length} étapes terminées', style: const TextStyle(color: Colors.black54, fontSize: 12))])),
         if (completedCount == all.length) const Icon(Icons.check_circle, color: Colors.green),
         if (!levelUnlocked) const Icon(Icons.lock, color: Colors.grey),
        ]),
        const SizedBox(height: 9),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: all.isEmpty ? 0 : completedCount / all.length, minHeight: 7, color: completedCount == all.length ? Colors.green : blue, backgroundColor: const Color(0xFFE8E9F3))),
        if (active) ...[
         const SizedBox(height: 8),
         ...current.map((lesson) {
          final canOpen = isUnlocked(lesson);
          final finishedLesson = done.contains(lesson.id);
          return ListTile(
           dense: true,
           contentPadding: EdgeInsets.zero,
           leading: CircleAvatar(backgroundColor: finishedLesson ? const Color(0xFFE3F6E9) : canOpen ? blue.withValues(alpha: .1) : const Color(0xFFF0F0F5), child: Icon(finishedLesson ? Icons.check : canOpen ? Icons.play_arrow : Icons.lock, color: finishedLesson ? Colors.green : canOpen ? blue : Colors.grey)),
           title: Text(lesson.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: canOpen || finishedLesson ? navy : Colors.grey)),
           subtitle: Text(lesson.subtitle, style: const TextStyle(fontSize: 11)),
           trailing: const Icon(Icons.chevron_right, size: 18),
           onTap: () => openLesson(lesson),
          );
         }),
        ] else if (levelUnlocked && completedCount < all.length)
         const Padding(padding: EdgeInsets.only(top: 8), child: Align(alignment: Alignment.centerLeft, child: Text('Ce niveau se débloquera dans le parcours après le précédent.', style: TextStyle(fontSize: 12, color: Colors.black54)))),
       ]),
      );
     }),
     const SizedBox(height: 12),
     const Center(child: Text('English Pro • Créé par Joseph Marchand', style: TextStyle(color: Colors.black45, fontSize: 11))),
    ],
   ),
  );
 }
 Widget stat(IconData i,String v,String label)=>Expanded(child:Container(padding:const EdgeInsets.symmetric(vertical:10),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.12),borderRadius:BorderRadius.circular(12)),child:Column(children:[Icon(i,color:gold),Text(v,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:16)),Text(label,style:const TextStyle(color:Colors.white70,fontSize:9))])));
}

class LessonPage extends StatefulWidget {
 final StudyLesson lesson; final bool alreadyDone; final Future<void> Function() onComplete;
 const LessonPage({super.key,required this.lesson,required this.alreadyDone,required this.onComplete});
 @override State<LessonPage> createState()=>_LessonPageState();
}
class _LessonPageState extends State<LessonPage>{
 int? selected; bool checked=false,finished=false; int attempts=0;
 @override Widget build(BuildContext context){
  final l=widget.lesson;
  final isCorrect=checked&&selected==l.answer;
  return Scaffold(
   appBar:AppBar(title:Text('${l.level} • Leçon'),leading:IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.close))),
   body:SafeArea(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(18,14,18,8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text(l.title,style:const TextStyle(color:navy,fontWeight:FontWeight.bold,fontSize:20)),
     const SizedBox(height:8),
     ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(value:finished?1:checked?.72:.42,minHeight:7,color:blue,backgroundColor:const Color(0xFFE7E8F2))),
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
       setState(()=>checked=true);attempts++;return;
      }
      if(!isCorrect){setState(()=>{selected=null,checked=false});return;}
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
 const Text('À PROPOS ET CONTACT',style:TextStyle(color:blue,fontWeight:FontWeight.bold,letterSpacing:1)),const SizedBox(height:10),Card(color:Colors.white,child:Column(children:[const ListTile(leading:Icon(Icons.person_outline,color:blue),title:Text('Créé par Joseph Marchand'),subtitle:Text('English Pro • parcours A1 à C2')),const ListTile(leading:Icon(Icons.chat,color:Colors.green),title:Text('WhatsApp'),subtitle:Text('+243 986 230 968')),ListTile(leading:const Icon(Icons.open_in_new,color:Colors.green),title:const Text('Nous contacter sur WhatsApp'),trailing:const Icon(Icons.chevron_right),onTap:onContact)])),const SizedBox(height:18),Card(color:Colors.white,child:ListTile(leading:const Icon(Icons.restart_alt,color:Colors.red),title:const Text('Réinitialiser ma progression'),subtitle:const Text('Effacer les leçons terminées et les XP'),onTap:onReset)),const SizedBox(height:18),const Center(child:Text('English Pro • Version 2.0',style:TextStyle(color:Colors.black45)))
 ]));
}
Widget avatar(String? data,String name,double size){Widget child;if(data!=null){try{child=Image.memory(base64Decode(data),width:size,height:size,fit:BoxFit.cover);}catch(_){child=Text(name.isEmpty?'E':name[0].toUpperCase());}}else{child=Text(name.isEmpty?'E':name[0].toUpperCase());}return CircleAvatar(radius:size/2,backgroundColor:gold,child:ClipOval(child:SizedBox(width:size,height:size,child:Center(child:child))));}
