import 'package:flutter/material.dart';
import 'package:mp3/models/deck.dart';

class EditDeck extends StatefulWidget {
  final Deck deck;
  final bool ifEdit; //bool val to know if deck is being edited
  const EditDeck(this.deck, this.ifEdit, {super.key});

  @override
  State<EditDeck> createState() => _EditDeckState();
}

class _EditDeckState extends State<EditDeck> {
  late Deck editedDeck;
  final _titlecontroller = TextEditingController();
  bool _validateTitle = false;

  @override
  void initState() {
    super.initState();
    editedDeck = Deck.from(widget.deck); //initialize edited deck
    _titlecontroller.text = editedDeck.title; //set title text
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Edit Deck')), //app bar config for edit deck page
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextFormField(
                  controller: _titlecontroller, // asking for title input
                  decoration: InputDecoration( 
                      labelText: 'Title',
                      errorText:
                          _validateTitle ? "Title field cannot be left empty" : null),
                  validator: (text) {
                    if (text == null || text.isEmpty) { //validates and then sets validateTitle var accordingly if not empty or null
                      return 'Can\'t be empty';
                    }
                    return null;
                  },
                  onChanged: (value) => editedDeck.title = value,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                TextButton(
                    child: const Text('Save'), //save button 
                    onPressed: () {
                      if (editedDeck.title.isEmpty) {
                        setState(() {
                          _validateTitle = _titlecontroller.text.isEmpty;
                        });
                      } else {
                        Navigator.of(context).pop((editedDeck, 'save')); //goes back to main page
                      }
                    }),
                if (widget.ifEdit) //delete and go back to main
                  TextButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      Navigator.of(context).pop((editedDeck, 'delete'));
                    },
                  ),
              ])
            ],
          ),
        ));
  }
}
