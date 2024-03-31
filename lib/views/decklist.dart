import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:mp3/utils/database_helper.dart';
import 'package:mp3/models/deck.dart';
import 'package:mp3/models/card.dart';
import 'package:mp3/views/edit_deck.dart';
import 'package:mp3/views/card_list.dart';


class DeckList extends StatefulWidget {
  const DeckList({super.key});

  @override
  State<DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  late Future<List<Deck>> _data;

  @override
  void initState() { //load in DB
    super.initState();
    _data = _loadDataDB();
  }

  List<Deck> deckListJson(String str) { //convert json data to deck objects
    final jsonData = json.decode(str);
    return List<Deck>.from(jsonData.map((x) => Deck.fromJson(x)));
  }

  Future<List<Deck>> _loadDataJSONtoDB() async {  //load in the data from the json file to the db
    final data = await rootBundle.loadString('assets/flashcards.json');
    List<Deck> jsonDecks = deckListJson(data);
    if (jsonDecks.isNotEmpty) {
      for (Deck deck in jsonDecks) {
        await deck.dbSave();
        for (Flashcard flashcard in deck.flashCards!) {
          flashcard.decksId = deck.id;
          await flashcard.dbSave();
        }
      }
    }
    return jsonDecks;
  }

  Future<List<Deck>> _loadDataDB() async { //get decks from db
    final decks = await DatabaseHelper().query('decks');
    final cardsAmount = await DatabaseHelper().getCardsAmount();
    return decks
        .map((e) => Deck(
            id: e['id'] as int,
            title: e['title'] as String,
            cardsAmount: (cardsAmount[e['id']] ?? 0)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxiCount = 2;
    double minTileWidth = 190;
    double availableWidth = MediaQuery.of(context).size.width; //responsiveness same as card_list for screen size
    crossAxiCount = availableWidth ~/ minTileWidth;
    return FutureBuilder<List<Deck>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            final decks = snapshot.data as List<Deck>;
            return Scaffold(
              appBar: AppBar(
                title: const Text("Flashcard Decks"), //creation of app bar and details
                foregroundColor: Colors.white,
                centerTitle: true,
                backgroundColor: Colors.blue,
                actions: <Widget>[
                  IconButton(
                    icon: const Icon( // download button 
                      Icons.download_sharp,
                      color: Colors.white,
                    ),
                    onPressed: () async {  //when pressed, start process of JSON -> DB -> decks on screen
                      _loadDataJSONtoDB().then((value) => {
                            setState(() {
                              _data = _loadDataDB();
                            })
                          });
                    },
                  )
                ],
              ),
              body: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxiCount),
                  padding: const EdgeInsets.all(4),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Card(
                        color: Colors.yellow[100],
                        child: Container(
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                InkWell(onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<Deck>(builder: (context) {
                                      return CardsList(decks[index]);
                                    }),
                                  ).then((_) => setState(() => {}));
                                }),
                                Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Text(decks[index].title,
                                          textAlign: TextAlign.center),
                                      if (decks[index].cardsAmount != null)
                                        Text(
                                            "(${decks[index].cardsAmount} cards)", //list # of cards in deck
                                            textAlign: TextAlign.center)
                                      else
                                        const Text("(0 cards)", //if cards is null, show 0
                                            textAlign: TextAlign.center)
                                    ])),
                                Positioned( //edit button on the top right corner
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    color: Colors.blue,
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _editDeck(decks, decks[index]);
                                    },
                                  ),
                                ),
                              ],
                            )));
                  }),
              floatingActionButton: FloatingActionButton( //add button at bottom right corner
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
                onPressed: () {
                  _addDeck(decks);
                },
              ),
            );
          }
        });
  }

  Future<void> _editDeck(List<Deck> decks, Deck deck) async { //async edit deck function
    var result = await Navigator.of(context)
        .push(MaterialPageRoute<(Deck, String)>(builder: (context) {
      return EditDeck(deck, true);
    }));

    if (!mounted) return;
    if (result != null) {
      if (result.$2 == "save") {
        setState(() {
          deck.title = result.$1.title;
        });
        await deck.dbUpdate();
      } else if (result.$2 == "delete") {
        await deck.dbDelete();
        await DatabaseHelper().deleteFlashCardByDeckId('cards', deck.id!);
        setState(() {
          decks.remove(deck);
        });
      }
    }
  }

  Future<void> _addDeck(List<Deck> decks) async { //add deck async function
    var result = await Navigator.of(context)
        .push(MaterialPageRoute<(Deck, String)>(builder: (context) {
      return EditDeck(Deck(title: '', cardsAmount: 0), false);
    }));

    if (!mounted) return;
    if (result != null) {
      setState(() {
        result.$1.cardsAmount = 0;
        decks.add(result.$1);
      });
      await result.$1.dbSave();
    }
  }
}
