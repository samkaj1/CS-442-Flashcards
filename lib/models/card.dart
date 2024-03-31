import 'package:mp3/utils/database_helper.dart';

class Flashcard { //flashcard class for storing flashcards in the database
  int? id;
  String question;
  String answer;
  bool? visited;
  bool? peeked;
  int? decksId;

  Flashcard( //create flashcard obj
      {this.id, required this.question, required this.answer, this.decksId});

  factory Flashcard.fromJson(Map<String, dynamic> json) { //create flashcard from json file
    return Flashcard(
        question: json['question'] as String, answer: json['answer'] as String);
  }

  Future<void> dbSave() async { // put flashcard in db async
    id = await DatabaseHelper().insert('cards', {
      'question': question,
      'answer': answer,
      'decksId': decksId,
    });
  }

  Future<void> dbUpdate() async { //to update a card in db
    await DatabaseHelper()
        .update('cards', {'id': id, 'question': question, 'answer': answer});
  }

  Future<void> dbDelete() async { //to delete a card in db
    await DatabaseHelper().delete('cards', id!);
  }

  Flashcard.from(Flashcard other) //copy constructor
      : id = other.id,
        question = other.question,
        answer = other.answer,
        decksId = other.decksId;
}
