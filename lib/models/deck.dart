import 'package:mp3/models/card.dart';
import 'package:mp3/utils/database_helper.dart';

class Deck { //deck class
  String title;
  int? id;
  List<Flashcard>? flashCards;
  int? cardsAmount;

  Deck({this.id, required this.title, this.flashCards, this.cardsAmount}); //deck main constructor

  factory Deck.fromJson(Map<String, dynamic> json) { // create deck from JSON
  final flashCardsJson = json['flashcards'] as List<dynamic>;
    return Deck(
      title: json['title'] as String,
      flashCards: flashCardsJson
        .map((flashCard) => Flashcard.fromJson(flashCard)).toList()
    );
  }

  Future<void> dbSave() async { //save deck
    id = await DatabaseHelper().insert('decks', {
      'title': title,
    });
  }

  Future<void> dbUpdate() async { //update deck
    await DatabaseHelper().update('decks', {
      'id': id,
      'title': title,
    });
  }

  Future<void> dbDelete() async { //delete deck
    await DatabaseHelper().delete('decks', id!);
  }

  Deck.from(Deck other) //create deck from existing (copy)
      : id = other.id,
        title = other.title;

  @override
  String toString() { 
    return "$id $title";
  }
}
