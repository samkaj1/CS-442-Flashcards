import 'package:flutter/material.dart';
import 'package:mp3/models/deck.dart';
import 'package:mp3/models/card.dart';
import 'package:mp3/utils/database_helper.dart';
import 'package:mp3/views/edit_card.dart';
import 'package:mp3/views/quiz_page.dart';

class CardsList extends StatefulWidget {
  final Deck deck;
  const CardsList(this.deck, {super.key});

  @override
  State<CardsList> createState() => _CardsListState();
}

class _CardsListState extends State<CardsList> {
  late Future<List<Flashcard>> _flashCards;
  bool _showSortByAlphabeticalOrder = false; //for alphabetic sorting of cards

  @override
  void initState() {
    super.initState();
    _flashCards = _loadDataFromDB();
  }

  Future<List<Flashcard>> _loadDataFromDB() async { //load  all the flashcards from DB
    final flashCards =
        await DatabaseHelper().query('cards', where: 'decksId = ${widget.deck.id!}');
    return flashCards
        .map((e) => Flashcard(
            id: e['id'] as int,
            question: e['question'] as String,
            answer: e['answer'] as String,
            decksId: e['decksId'] as int))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxiCount = 3;
    double minTileWidth = 130;
    double availableWidth = MediaQuery.of(context).size.width;
    crossAxiCount = availableWidth ~/ minTileWidth; //tilda for int division but overall to make screen adaptive and set sizes based on cards and screen size
    return FutureBuilder(
        future: _flashCards,
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(), //loading symbol while data is loading in
              ),
            );
          } else {
            var flashCards = snapshot.data as List<Flashcard>;
            if (_showSortByAlphabeticalOrder) {
              flashCards.sort((a, b) =>
                  a.question.toLowerCase().compareTo(b.question.toLowerCase())); //sort alphabetically
            } else {
              flashCards.sort((a, b) => a.id!.compareTo(b.id!));
            }
            return Scaffold(
                appBar: AppBar(
                  title: FittedBox(
                      fit: BoxFit.fitWidth, child: Text('${widget.deck.title} Deck')),
                  foregroundColor: Colors.white, //change title text to white
                  backgroundColor: Colors.blue, //change app bar bg to blue
                  actions: <Widget>[
                    !_showSortByAlphabeticalOrder
                        ? IconButton(
                            icon: const Icon( //add sort by icon and what it will do when pressed
                              Icons.sort_by_alpha,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                flashCards.sort((a, b) => a.question
                                    .toLowerCase()
                                    .compareTo(b.question.toLowerCase()));
                                _showSortByAlphabeticalOrder =
                                    !_showSortByAlphabeticalOrder;
                              });
                            },
                          )
                        : IconButton( //add sort by time icon, when added
                            icon: const Icon(
                              Icons.access_time_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                flashCards
                                    .sort((a, b) => a.id!.compareTo(b.id!));
                                _showSortByAlphabeticalOrder =
                                    !_showSortByAlphabeticalOrder;
                              });
                            },
                          ),
                    IconButton( //play button for quiz
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute<Flashcard>(builder: (context) {
                              List<Flashcard> shuffledList = flashCards.toList();
                              shuffledList.shuffle(); //shuffles flashcards each time play is clicked
                          return QuizPage(
                            flashcards: shuffledList,
                            quizTitle: widget.deck.title,
                          );
                        }));
                      },
                    )
                  ],
                ),
                floatingActionButton: FloatingActionButton( //adding blue circle add button to add flashcards
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add),
                    onPressed: () {
                      _addFlashCard(flashCards, widget.deck.id!);
                    }),
                body: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxiCount),
                    padding: const EdgeInsets.all(4),
                    itemCount: flashCards.length,
                    itemBuilder: (context, index) {
                      return Card( //card details
                          color: Colors.lightBlue[100],
                          child: Container(
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  InkWell(onTap: () {
                                    _editCard(flashCards, flashCards[index]);
                                  }),
                                  Center(
                                      child: Text(flashCards[index].question,
                                          textAlign: TextAlign.center)),
                                ],
                              )));
                    }));
          }
        });
  }

  Future<void> _editCard(List<Flashcard> cards, Flashcard card) async { //edit card async function
    var result = await Navigator.of(context)
        .push(MaterialPageRoute<(Flashcard, String)>(builder: (context) {
      return EditCard(card, true);
    }));

    if (!mounted) return;
    if (result != null) {
      if (result.$2 == "save") {
        setState(() {
          card.question = result.$1.question;
          card.answer = result.$1.answer;
        });
        await card.dbUpdate();
      } else if (result.$2 == "delete") {
        setState(() {
          widget.deck.cardsAmount = widget.deck.cardsAmount! - 1;
          cards.remove(card);
        });
        await card.dbDelete();
      }
    }
  }

  Future<void> _addFlashCard(List<Flashcard> flashCards, int deckId) async { //add card aync function
    var result = await Navigator.of(context)
        .push(MaterialPageRoute<(Flashcard, String)>(builder: (context) {
      return EditCard(
          Flashcard(question: '', answer: '', decksId: deckId), false);
    }));

    if (!mounted) return;
    if (result != null) {
      await result.$1.dbSave();
      setState(() {
        widget.deck.cardsAmount = widget.deck.cardsAmount! + 1;
        flashCards.add(result.$1);
      });
    }
  }
}
