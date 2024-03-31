import 'package:flutter/material.dart';
import 'package:mp3/models/card.dart';

class EditCard extends StatefulWidget {
  final Flashcard flashcard;
  final bool ifEdit; //bool val to help show if card is being edited
  const EditCard(this.flashcard, this.ifEdit, {super.key});

  @override
  State<EditCard> createState() => _EditCardState();
}

class _EditCardState extends State<EditCard> {
  final _questioncontroller = TextEditingController();
  final _answercontroller = TextEditingController();
  late Flashcard editedCard;
  bool _validateQuestion = false;
  bool _validateAnswer = false;

  @override
  void initState() {
    super.initState();
    editedCard = Flashcard.from(widget.flashcard);
    _questioncontroller.text = widget.flashcard.question;
    _answercontroller.text = widget.flashcard.answer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Edit Card')), //app bar configuration
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextFormField(
                  controller: _questioncontroller, //asks what the question should be for the card
                  decoration: InputDecoration(
                      labelText: 'Question',
                      errorText:
                          _validateQuestion ? "Question field cannot be left empty" : null),
                  onChanged: (value) => editedCard.question = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextFormField(
                  controller: _answercontroller, //asks what the answer should be for the card
                  decoration: InputDecoration(
                      labelText: 'Answer',
                      errorText:
                          _validateAnswer ? "Answer field cannot be left empty" : null),
                  onChanged: (value) => editedCard.answer = value,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                TextButton(
                  child: const Text('Save'), //saves the question/answer as a card
                  onPressed: () {
                    if (editedCard.question.isEmpty ||
                        editedCard.answer.isEmpty) {
                      setState(() {
                        _validateQuestion = _questioncontroller.text.isEmpty;
                        _validateAnswer = _answercontroller.text.isEmpty;
                      });
                    } else {
                      Navigator.of(context).pop((editedCard, 'save')); //pops off the edit page
                    }
                  },
                ),
                if (widget.ifEdit) //deletes the flashcard and goes back to deck
                  TextButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      Navigator.of(context).pop((editedCard, 'delete'));
                    },
                  ),
              ])
            ],
          ),
        ));
  }
}
