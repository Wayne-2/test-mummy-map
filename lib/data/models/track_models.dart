class MealItem {
  final String id;
  final String mealTime;
  final String name;
  final String imagePath;
  final int prepMins;
  final int cookMins;
  final int servings;
  final String description;
  final List<IngredientGroup> ingredientGroups;
  final List<PrepGroup> prepGroups;
  final double priceValue;

  const MealItem({
    required this.id,
    required this.mealTime,
    required this.name,
    required this.imagePath,
    required this.prepMins,
    required this.cookMins,
    required this.servings,
    required this.description,
    required this.ingredientGroups,
    required this.prepGroups,
    required this.priceValue,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['id']?.toString() ?? '',
      mealTime: json['mealTime'] ?? 'Breakfast',
      name: json['name'] ?? 'Unknown Meal',
      imagePath: json['imagePath'] ?? 'assets/placeholder.png',
      prepMins: json['prepMins'] ?? 0,
      cookMins: json['cookMins'] ?? 0,
      servings: json['servings'] ?? 1,
      description: json['description'] ?? '',
      ingredientGroups: [], // Simplify for now
      prepGroups: [], // Simplify for now
      priceValue: (json['priceValue'] ?? 0).toDouble(),
    );
  }

  String get price =>
      '₦${priceValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

class IngredientGroup {
  final String title;
  final List<String> items;

  const IngredientGroup({required this.title, required this.items});
}

class PrepGroup {
  final String title;
  final List<String> steps;

  const PrepGroup({required this.title, required this.steps});
}

class Vendor {
  final String id;
  final String name;
  final String imagePath;
  final double rating;
  final String days;
  final String openTime;
  final String closeTime;
  final String address;
  final double pricePerWeek;

  const Vendor({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.days,
    required this.openTime,
    required this.closeTime,
    required this.address,
    required this.pricePerWeek,
  });

  String get priceLabel =>
      '₦${pricePerWeek.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

class WeightEntry {
  final DateTime date;
  final int week;
  final double weightLb;

  const WeightEntry({
    required this.date,
    required this.week,
    required this.weightLb,
  });

  double get change => weightLb - kStartWeight;
}

class ExerciseDay {
  final int dayNumber;
  final String trainingTime;
  final String done;
  bool completed;

  ExerciseDay({
    required this.dayNumber,
    required this.trainingTime,
    required this.done,
    this.completed = false,
  });
}

class ExerciseLevel {
  final int level;
  final List<ExerciseDay> days;

  const ExerciseLevel({required this.level, required this.days});
}

class ExerciseSet {
  final String name;
  final String timing;
  final int repeats;
  final bool isPulse;

  const ExerciseSet({
    required this.name,
    required this.timing,
    required this.repeats,
    this.isPulse = false,
  });
}

const double kStartWeight = 133.3;
const double kTargetWeight = 162.3;

final kMeals = [
  MealItem(
    id: 'm1',
    mealTime: 'Breakfast',
    name: 'Akamu (pap) with milk & moi moi',
    imagePath: 'assets/meals/akamu.png',
    prepMins: 5,
    cookMins: 10,
    servings: 1,
    priceValue: 5000,
    description:
        'Akamu (pap) with milk and moi moi is a nourishing combo rich in energy, protein, calcium, and iron perfect for supporting a pregnant woman\'s strength, baby\'s development, and preventing anemia.',
    ingredientGroups: const [
      IngredientGroup(
        title: 'Akamu (Pap)',
        items: [
          '1 cup of fermented corn paste (akamu/ogi/pap)',
          '1½ cups of water (for mixing)',
          '1 cup of hot water (for thickening)',
          'Evaporated milk or powdered milk (to taste)',
          'Sugar or honey (optional)',
          'A pinch of salt (optional)',
        ],
      ),
      IngredientGroup(
        title: 'Moi Moi',
        items: [
          '2 cups of peeled black-eyed beans',
          '1 medium onion',
          '2 red bell peppers (tatashe)',
          '1 scotch bonnet pepper (atarodo)',
          '3 tbsp vegetable oil',
          '2 boiled eggs (optional)',
          'Salt to taste',
          '1 tsp seasoning powder',
        ],
      ),
    ],
    prepGroups: const [
      PrepGroup(
        title: 'Akamu (Pap)',
        steps: [
          'Place the fermented akamu paste in a bowl.',
          'Add 1½ cups of cold water and stir until smooth.',
          'Boil 1 cup of water and pour into the mixture while stirring.',
          'Return to low heat, stir until thick and cooked through.',
          'Add milk, sugar, or salt to taste.',
        ],
      ),
      PrepGroup(
        title: 'Moi Moi',
        steps: [
          'Blend peeled beans, onions, red peppers, and scotch bonnet with enough water into a smooth paste.',
          'Pour into a bowl, add oil, salt, and seasoning. Mix well.',
          'Add eggs if desired. Spoon into foil packs or cups.',
          'Steam for 45–60 mins until firm.',
        ],
      ),
    ],
  ),
  MealItem(
    id: 'm2',
    mealTime: 'Mid-Morning Snack',
    name: 'A handful of groundnuts & banana',
    imagePath: 'assets/meals/groundnuts.png',
    prepMins: 2,
    cookMins: 0,
    servings: 1,
    priceValue: 5000,
    description:
        'A quick protein and energy boost packed with healthy fats, potassium, and natural sugars.',
    ingredientGroups: const [
      IngredientGroup(
        title: 'Snack',
        items: ['1 handful of roasted groundnuts', '1 medium ripe banana'],
      ),
    ],
    prepGroups: const [
      PrepGroup(title: 'Snack', steps: ['Serve groundnuts alongside banana. No cooking required.']),
    ],
  ),
  MealItem(
    id: 'm3',
    mealTime: 'Lunch',
    name: 'Rice with vegetables & fish stew',
    imagePath: 'assets/meals/rice_stew.png',
    prepMins: 10,
    cookMins: 30,
    servings: 1,
    priceValue: 5000,
    description:
        'A balanced meal rich in carbohydrates, omega-3 fatty acids, and vitamins to support fetal development.',
    ingredientGroups: const [
      IngredientGroup(
        title: 'Rice & Stew',
        items: [
          '2 cups of parboiled rice',
          '2 medium tomatoes',
          '1 red bell pepper',
          '200g fish fillet',
          '1 medium onion',
          'Vegetable oil',
          'Salt & seasoning to taste',
        ],
      ),
    ],
    prepGroups: const [
      PrepGroup(
        title: 'Rice & Stew',
        steps: [
          'Cook rice in salted water until tender.',
          'Blend tomatoes, pepper, and half the onion.',
          'Fry onion in oil, add blended mix and cook for 15 mins.',
          'Add fish and seasoning. Simmer for 10 mins.',
          'Serve stew over rice.',
        ],
      ),
    ],
  ),
  MealItem(
    id: 'm4',
    mealTime: 'Afternoon Snack',
    name: 'Garden eggs with peanut butter',
    imagePath: 'assets/meals/garden_eggs.png',
    prepMins: 2,
    cookMins: 15,
    servings: 1,
    priceValue: 5000,
    description:
        'Rich in fibre, antioxidants, and healthy fats. Great for blood sugar control during pregnancy.',
    ingredientGroups: const [
      IngredientGroup(
        title: 'Snack',
        items: ['4 garden eggs', '2 tbsp natural peanut butter'],
      ),
    ],
    prepGroups: const [
      PrepGroup(
        title: 'Snack',
        steps: ['Wash garden eggs.', 'Boil for 10–15 mins until tender.', 'Serve with peanut butter for dipping.'],
      ),
    ],
  ),
  MealItem(
    id: 'm5',
    mealTime: 'Dinner',
    name: 'Ofe Akwu (palm nut soup) with fufu',
    imagePath: 'assets/meals/ofe_akwu.png',
    prepMins: 15,
    cookMins: 45,
    servings: 1,
    priceValue: 5000,
    description:
        'A hearty, nutrient-dense soup packed with vitamins A, E, and K alongside healthy fats and protein.',
    ingredientGroups: const [
      IngredientGroup(
        title: 'Soup',
        items: [
          '2 cups of palm nuts (or 1 tin palm nut cream)',
          '400g assorted meat or fish',
          '1 medium onion',
          'Crayfish to taste',
          'Salt & seasoning',
          'Uziza or scent leaves (optional)',
        ],
      ),
    ],
    prepGroups: const [
      PrepGroup(
        title: 'Soup',
        steps: [
          'Cook palm nuts until soft, pound, and extract cream.',
          'Cook meat with onion, salt, and seasoning.',
          'Add palm nut cream and bring to a boil.',
          'Add crayfish, fish, and leaves. Simmer 15 mins.',
          'Serve with fufu.',
        ],
      ),
    ],
  ),
];

final kVendors = [
  Vendor(
    id: 'v1',
    name: 'Mama Africa',
    imagePath: 'assets/vendors/mama_africa.png',
    rating: 3.5,
    days: 'Mon - Sun',
    openTime: '9:15AM',
    closeTime: '6:30PM',
    address: '13th Akungagamu Drive, Plot 126, Lagos',
    pricePerWeek: 5000,
  ),
  Vendor(
    id: 'v2',
    name: 'My Food by Hilda',
    imagePath: 'assets/vendors/my_food_hilda.png',
    rating: 4.5,
    days: 'Mon - Sat',
    openTime: '7:30AM',
    closeTime: '8:00PM',
    address: '13th Akungagamu Drive, Plot 126, Lagos',
    pricePerWeek: 5000,
  ),
  Vendor(
    id: 'v3',
    name: 'Mama Cee',
    imagePath: 'assets/vendors/mama_cee.png',
    rating: 4.0,
    days: 'Mon - Sun',
    openTime: '8:00AM',
    closeTime: '7:00PM',
    address: '45 Ikorodu Road, Lagos',
    pricePerWeek: 5000,
  ),
];

final kExerciseLevels = List.generate(
  6,
  (li) => ExerciseLevel(
    level: li + 1,
    days: List.generate(
      7,
      (di) => ExerciseDay(
        dayNumber: di + 1,
        trainingTime: '39m 58s',
        done: '0s',
        completed: li == 0 && di == 0,
      ),
    ),
  ),
);

const kLevel1Day1Exercises = [
  ExerciseSet(
    name: 'Classic Kegel',
    timing: '3s X 3s',
    repeats: 10,
    isPulse: false,
  ),
  ExerciseSet(
    name: 'Pulse Kegel',
    timing: 'Quick Pulse 10s',
    repeats: 3,
    isPulse: true,
  ),
];

final kWeightEntries = <WeightEntry>[
  WeightEntry(
    date: DateTime(2025, 4, 1),
    week: 5,
    weightLb: 129.9,
  ),
];