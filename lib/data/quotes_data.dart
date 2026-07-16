class QuotesData {
  QuotesData._();

  static const List<String> quotes = [
    'Small positive actions create extraordinary lives.',
    'Happiness is not a destination, it\'s a way of traveling.',
    'You don\'t have to see the whole staircase, just take the first step.',
    'Progress, not perfection.',
    'Every day is a fresh chance to choose joy.',
    'Consistency turns small habits into a whole new life.',
    'Gratitude turns what we have into enough.',
    'Kindness is a language everyone understands.',
    'The days are long, but the habit compounds.',
    'You are allowed to be a work in progress.',
    'A little progress each day adds up to big results.',
    'Your future self is built from today\'s small choices.',
    'Joy is found in the ordinary, if you look for it.',
    'Showing up is half the victory.',
    'You are exactly where you need to be to start.',
    'One good habit today is worth a thousand tomorrows.',
    'Be proud of every small step forward.',
    'Positivity is a practice, not a personality trait.',
    'Growth happens in the space between comfort and courage.',
    'Celebrate the version of you that keeps showing up.',
  ];

  static String forDay(int dayOfYear) => quotes[dayOfYear % quotes.length];
}
