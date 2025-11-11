# trivia

Trivia questions, courtesy of the [Open Trivia Database](https://opentdb.com). Features both "one at a time" and "quiz" modes.

"One at a time" mode allows you to pick a category (or a wildcard) and answer a randomly selected question from the database. You get immediate feedback on whether you were right or wrong.

"Quiz" mode lets you queue up a certain number of questions matching certain category/difficulty restrictions and answer them all in a row. Feedback comes at the very end of the quiz.

## To run

Mount as `usr2` and `cd "/usr2"; run "startup"`. This will open a menu that lets you choose which mode of trivia you would like.

## Notes

In quiz mode, it's possible to accidentally make a quiz that is impossible to generate (for example, there are only 10 easy questions in the Musicals and Theatres category, so a quiz restricted to just that category/difficulty combination with more than 10 questions can't be done). The quiz mode should quickly realize when this is the case and tell you to make changes.
