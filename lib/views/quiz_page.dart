import 'package:flutter/material.dart';
import 'package:mp3/models/card.dart';

class QuizPage extends StatefulWidget { //creates class with quiz title and flashcards
  final String quizTitle; 
  final List<Flashcard> flashcards;

  const QuizPage(
      {super.key, required this.flashcards, required this.quizTitle});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> { //state variables including index, visitedcount, peeked cards, and if the answer was shown
  int currentIndex = 0;
  int visitedCount = 1;
  int peekedCount = 0;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    widget.flashcards.shuffle(); //shuffle cards
    if (widget.flashcards.isNotEmpty) {
      widget.flashcards[0].visited = true;
      widget.flashcards[0].peeked = false;
      for (int i = 1; i < widget.flashcards.length; i++) {
        widget.flashcards[i].visited = false;
        widget.flashcards[i].peeked = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: FittedBox(
                fit: BoxFit.fitWidth, child: Text('${widget.quizTitle} Quiz'))),
        body: widget.flashcards.isNotEmpty
            ? Center(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      flex: 3,
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Card(
                            color: showAnswer
                                ? Colors.green[100]
                                : Colors.blue[100],
                            child: SizedBox(
                              child: Center(
                                  child: showAnswer == false
                                      ? Text(
                                          widget.flashcards[currentIndex]
                                              .question,
                                          style: const TextStyle(fontSize: 30),
                                          textAlign: TextAlign.center)
                                      : Text(
                                          widget
                                              .flashcards[currentIndex].answer,
                                          style: const TextStyle(fontSize: 30),
                                          textAlign: TextAlign.center)),
                            ),
                          ))),
                  Expanded(
                      flex: 2,
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon( //icon for back button
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 25,
                              ),
                              onPressed: () {
                                setState(() { //changes to index and visited if needed
                                  showAnswer = false;
                                  currentIndex - 1 >= 0
                                      ? currentIndex--
                                      : currentIndex =
                                          widget.flashcards.length -
                                              (currentIndex * -1) -
                                              1;
                                  if (widget.flashcards[currentIndex].visited ==
                                      false) {
                                    widget.flashcards[currentIndex].visited =
                                        true;
                                    visitedCount++;
                                  }
                                });
                              },
                            ),
                            IconButton( //icon for flipping b/t Q/A
                              icon: Icon(
                                Icons.flip_to_front_sharp,
                                color: showAnswer == true
                                    ? Colors.green
                                    : Colors.black,
                                size: 25,
                              ),
                              onPressed: () {
                                setState(() {
                                  showAnswer = !showAnswer; // to toggle between question/answer
                                  if (widget.flashcards[currentIndex].peeked ==
                                      false) {
                                    widget.flashcards[currentIndex].peeked =
                                        true;
                                    peekedCount++;
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                                size: 25,
                              ),
                              onPressed: () {
                                setState(() {
                                  showAnswer = false;
                                  currentIndex + 1 == widget.flashcards.length
                                      ? currentIndex = 0
                                      : currentIndex++;
                                  if (widget.flashcards[currentIndex].visited ==
                                      false) {
                                    widget.flashcards[currentIndex].visited =
                                        true;
                                    visitedCount++;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "Seen $visitedCount of ${widget.flashcards.length} cards",
                                      style: const TextStyle(fontSize: 20))
                                ])),
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "Peeked $peekedCount of $visitedCount answers", //text for # of peeked cards
                                      style: const TextStyle(fontSize: 20)
                                  )
                                ]
                            )
                        )
                      ])
                  )
                ]),
              )
            : Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                          flex: 3,
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Card(
                                color: showAnswer
                                    ? Colors.green[100]
                                    : Colors.blue[100],
                                child: const SizedBox(
                                  child: Center(
                                      child: Text("No Questions to Available to Show",
                                          style: TextStyle(fontSize: 30),
                                          textAlign: TextAlign.center
                                      )
                                  ),
                                ),
                              )
                          )
                        )
                    ]
                ),
              )
    );
  }
}
