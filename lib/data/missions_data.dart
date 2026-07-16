import '../models/mission.dart';

/// The full mission library — 200+ hand-written daily missions across 20
/// positive-psychology categories. [MissionEngine] selects from this list
/// while avoiding recent repeats.
class MissionsData {
  MissionsData._();

  static final List<Mission> all = [
    ..._gratitude,
    ..._kindness,
    ..._relationships,
    ..._health,
    ..._exercise,
    ..._productivity,
    ..._mindfulness,
    ..._learning,
    ..._reading,
    ..._creativity,
    ..._nature,
    ..._family,
    ..._friends,
    ..._confidence,
    ..._communication,
    ..._selfCare,
    ..._finance,
    ..._digitalDetox,
    ..._communityService,
    ..._emotionalGrowth,
  ];

  static List<Mission> _build(
    String prefix,
    MissionCategory category,
    List<String> titles,
  ) {
    return List.generate(
      titles.length,
      (i) => Mission(
        id: '${prefix}_${(i + 1).toString().padLeft(2, '0')}',
        title: titles[i],
        category: category,
      ),
    );
  }

  static final _gratitude = _build('grat', MissionCategory.gratitude, [
    'Write three things you\'re grateful for.',
    'Thank someone who helped shape who you are.',
    'Notice one small comfort you usually take for granted.',
    'Write a gratitude letter you don\'t have to send.',
    'Name one challenge you\'re secretly grateful for.',
    'Appreciate your body for one thing it did for you today.',
    'Text someone "thank you for being you" — no context needed.',
    'List three people who made your week better.',
    'Write down a memory that still makes you smile.',
    'Find gratitude in something that annoyed you yesterday.',
    'Say thank you out loud to the next person who helps you.',
  ]);

  static final _kindness = _build('kind', MissionCategory.kindness, [
    'Compliment someone sincerely.',
    'Help someone without expecting anything in return.',
    'Leave an encouraging comment for a stranger online.',
    'Pay for someone\'s coffee or a small treat.',
    'Give up your seat or your place in line for someone.',
    'Write a kind note and leave it somewhere for a stranger to find.',
    'Check in on someone who\'s been quiet lately.',
    'Offer to carry something heavy for a person nearby.',
    'Give a genuine compliment to someone you rarely talk to.',
    'Let someone merge, cross, or go ahead of you today.',
    'Send an encouraging message to someone having a hard week.',
  ]);

  static final _relationships = _build('rel', MissionCategory.relationships, [
    'Reach out to someone you\'ve lost touch with.',
    'Tell someone specifically why you appreciate them.',
    'Plan a small moment of connection with someone this week.',
    'Ask a loved one a question you\'ve never asked before.',
    'Apologize for something small you\'ve been holding onto.',
    'Give someone your full, undistracted attention for 15 minutes.',
    'Share something vulnerable with someone you trust.',
    'Write down what makes your closest relationship strong.',
    'Say "I love you" or "I appreciate you" to someone today.',
    'Resolve one small tension with honesty and warmth.',
  ]);

  static final _health = _build('heal', MissionCategory.health, [
    'Drink enough water today.',
    'Go to bed 30 minutes earlier tonight.',
    'Eat one extra serving of fruit or vegetables.',
    'Take a full deep-breathing break for two minutes.',
    'Stretch for five minutes before bed.',
    'Skip one sugary drink and swap it for water.',
    'Check in with how your body feels right now.',
    'Take the stairs instead of the elevator today.',
    'Prepare a wholesome meal instead of ordering out.',
    'Track how you slept last night and note one improvement.',
  ]);

  static final _exercise = _build('exer', MissionCategory.exercise, [
    'Walk outside for twenty minutes.',
    'Do a 10-minute home workout — no equipment needed.',
    'Take a walk without your phone.',
    'Try five minutes of stretching first thing in the morning.',
    'Go for a jog, even a short one.',
    'Dance to three songs like nobody\'s watching.',
    'Do 20 squats, 20 push-ups (or modified), and 20 sit-ups.',
    'Take a walking break for every hour you sit today.',
    'Try a new form of movement you\'ve never done before.',
    'Walk or bike somewhere you\'d normally drive.',
  ]);

  static final _productivity = _build('prod', MissionCategory.productivity, [
    'Complete one difficult task you\'ve been avoiding.',
    'Write your top three priorities for tomorrow tonight.',
    'Clear your inbox down to zero, even briefly.',
    'Break a big goal into one small, doable first step.',
    'Tidy your workspace for ten focused minutes.',
    'Time-block one hour of deep, distraction-free work.',
    'Finish a task you started but never completed.',
    'Say no to one thing that doesn\'t serve your priorities.',
    'Write a short plan for a goal you\'ve been putting off.',
    'Batch three small errands into one efficient trip.',
  ]);

  static final _mindfulness = _build('mind', MissionCategory.mindfulness, [
    'Sit quietly and just breathe for five minutes.',
    'Eat one meal today without any screens.',
    'Notice five things you can see, hear, and feel right now.',
    'Practice a short body scan before bed.',
    'Pause and take three slow breaths before reacting to something.',
    'Spend two minutes simply watching your breath.',
    'Do one task today with your full, undivided attention.',
    'Notice a moment of stress and name it without judgment.',
    'Try a guided meditation, even a short one.',
    'Set an intention for the day before you check your phone.',
  ]);

  static final _learning = _build('learn', MissionCategory.learning, [
    'Learn one new idea and write it down.',
    'Watch or read something that teaches you a new skill.',
    'Ask someone knowledgeable a genuine question.',
    'Look up the meaning behind a word you use but never defined.',
    'Learn a fact about a topic completely outside your field.',
    'Teach someone else something you learned recently.',
    'Try to explain a complex idea in one simple sentence.',
    'Spend fifteen minutes on a course or tutorial.',
    'Learn a new word and use it in conversation today.',
    'Reflect on one lesson a recent mistake taught you.',
  ]);

  static final _reading = _build('read', MissionCategory.reading, [
    'Read ten pages.',
    'Read one chapter of a book you\'ve been meaning to start.',
    'Read an article about something you know nothing about.',
    'Reread a passage that once meant a lot to you.',
    'Read a poem slowly, twice.',
    'Start a book that\'s been sitting on your shelf.',
    'Read something uplifting before bed instead of scrolling.',
    'Share a quote from something you read with a friend.',
    'Read the introduction of a book outside your usual genre.',
    'Spend fifteen quiet minutes reading, phone in another room.',
  ]);

  static final _creativity = _build('create', MissionCategory.creativity, [
    'Doodle or sketch something for five minutes, no judgment.',
    'Write a short poem about your day.',
    'Rearrange something in your space to make it feel fresh.',
    'Take a creative photo of something ordinary.',
    'Free-write for five minutes without stopping to edit.',
    'Make up a short story with a happy ending.',
    'Try a new recipe and make it your own.',
    'Hum or sing a tune you just made up.',
    'Design your dream day, in as much detail as you like.',
    'Make something with your hands, however small.',
  ]);

  static final _nature = _build('nat', MissionCategory.nature, [
    'Spend a few minutes noticing the sky today.',
    'Sit outside for ten minutes without your phone.',
    'Touch grass, literally — go barefoot for a moment if you can.',
    'Water a plant or start growing something new.',
    'Take a photo of something beautiful in nature.',
    'Open a window and breathe fresh air for two minutes.',
    'Go for a walk somewhere green.',
    'Watch the sunrise or sunset today.',
    'Identify one plant, bird, or tree you\'ve never noticed before.',
    'Bring a small piece of nature — a flower, a leaf — into your space.',
  ]);

  static final _family = _build('fam', MissionCategory.family, [
    'Call your parents.',
    'Tell a family member something you admire about them.',
    'Share a favorite memory with a sibling or relative.',
    'Ask an older family member about their life story.',
    'Send a family group message just to say hi.',
    'Plan a small family moment for this week.',
    'Write down a family tradition you want to keep alive.',
    'Thank a family member for something specific they did.',
    'Look through old family photos and share one.',
    'Offer to help a family member with something on their plate.',
  ]);

  static final _friends = _build('friend', MissionCategory.friends, [
    'Message a friend you haven\'t spoken to in a while.',
    'Plan a hangout with a friend, even a small one.',
    'Tell a friend exactly why their friendship matters to you.',
    'Send a friend a meme or song that reminded you of them.',
    'Introduce two friends who\'d genuinely get along.',
    'Celebrate a friend\'s recent win, big or small.',
    'Invite a friend to join you on today\'s mission.',
    'Ask a friend how they\'re really doing — and listen.',
    'Surprise a friend with a small thoughtful gesture.',
    'Make plans to see a friend in person soon.',
  ]);

  static final _confidence = _build('conf', MissionCategory.confidence, [
    'Write your biggest achievement this week.',
    'Stand tall and give yourself a genuine compliment.',
    'Do one small thing today that scares you a little.',
    'List three strengths you\'re proud to have.',
    'Speak up about an idea you\'d normally keep quiet.',
    'Wear something that makes you feel like yourself.',
    'Recall a time you overcame something hard.',
    'Say no to something without over-explaining.',
    'Ask for something you need or want.',
    'Celebrate progress, not just the finish line, today.',
  ]);

  static final _communication = _build('comm', MissionCategory.communication, [
    'Have a real conversation instead of texting today.',
    'Practice really listening without planning your reply.',
    'Say something kind to a stranger.',
    'Ask someone a thoughtful follow-up question today.',
    'Tell someone clearly what you need from them.',
    'Give someone feedback with warmth and honesty.',
    'Start a conversation with someone new.',
    'Express appreciation out loud instead of just thinking it.',
    'Clarify a misunderstanding instead of letting it sit.',
    'Practice saying "tell me more" instead of jumping in.',
  ]);

  static final _selfCare = _build('self', MissionCategory.selfCare, [
    'Smile at five people today.',
    'Take fifteen minutes today just for you, no guilt.',
    'Say something kind to yourself in the mirror.',
    'Give yourself permission to rest today.',
    'Do one small thing that always makes you feel better.',
    'Unplug from a stressful conversation for a while.',
    'Treat yourself the way you\'d treat a good friend today.',
    'Take a warm shower or bath slowly, without rushing.',
    'Write yourself a short, kind note for tomorrow.',
    'Do one thing today purely because it brings you joy.',
  ]);

  static final _finance = _build('fin', MissionCategory.finance, [
    'Check your spending from this week without judgment.',
    'Save a small amount today, even just a little.',
    'Skip one unnecessary purchase today.',
    'Write down one financial goal for this month.',
    'Review one subscription you might not need anymore.',
    'Set aside a few minutes to plan next week\'s budget.',
    'Learn one new thing about saving or investing.',
    'Celebrate one smart money decision you made recently.',
    'Track every expense today, just for awareness.',
    'Give yourself credit for one financial habit you\'re proud of.',
  ]);

  static final _digitalDetox = _build('digi', MissionCategory.digitalDetox, [
    'Spend one hour away from social media.',
    'Turn off non-essential notifications for the day.',
    'Leave your phone in another room during a meal.',
    'Take a full evening without screens.',
    'Do a task you\'d normally scroll through phone-free.',
    'Set a screen-time goal for today and stick to it.',
    'Replace one scrolling break with a short walk.',
    'Unfollow or mute one account that doesn\'t lift you up.',
    'Charge your phone outside the bedroom tonight.',
    'Notice how you feel after 30 minutes without your phone.',
  ]);

  static final _communityService =
      _build('serv', MissionCategory.communityService, [
        'Help someone in your community today.',
        'Pick up litter you pass on a walk.',
        'Donate something you no longer need.',
        'Volunteer a small amount of your time this week.',
        'Support a local business with your visit or a review.',
        'Check on an elderly neighbor.',
        'Share a resource that could genuinely help someone.',
        'Leave a generous, honest review for someone who earned it.',
        'Offer your skills to help someone for free today.',
        'Contribute to a cause you believe in, however small.',
      ]);

  static final _emotionalGrowth = _build('emo', MissionCategory.emotionalGrowth, [
    'Name an emotion you\'re feeling right now without judging it.',
    'Write about a fear and one small step past it.',
    'Forgive yourself for one small mistake today.',
    'Reflect on how far you\'ve come this month.',
    'Sit with a difficult feeling for two minutes instead of avoiding it.',
    'Write a letter to your future self.',
    'Identify one pattern you\'d like to change, gently.',
    'Celebrate an emotional win — staying calm, being honest, asking for help.',
    'Journal about what "happiness" means to you today.',
    'Practice self-compassion the way you would for a friend.',
  ]);
}
