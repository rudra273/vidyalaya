import 'python_models.dart';

// ─── Beginner chapters (B1–B4) ────────────────────────────────────────────────
//
// English-only v1. Every CodeBlock's expectedOutput is verified against the
// real interpreter by test/data/python_course_test.dart, so these can't drift.

const pythonBeginnerChapters = <PythonChapter>[
  // ── B1: Hello, Python! ──────────────────────────────────────────────────────
  PythonChapter(
    id: 'b1_hello',
    level: PythonLevel.beginner,
    title: 'Hello, Python!',
    subtitle: 'Your very first lines of code',
    emoji: '👋',
    lessons: [
      PythonLesson(
        id: 'b1_l1',
        title: 'What is Python?',
        blocks: [
          TextBlock(
            "Python is a **programming language** — a way to give a computer "
            "step-by-step instructions. You write the steps, and the computer "
            "does exactly what you say. 🤖",
          ),
          TextBlock(
            "Python is famous for being easy to read. It almost looks like "
            "plain English! Let's make the computer say something.",
          ),
          CodeBlock(
            code: "print(\"Hello, Python!\")",
            expectedOutput: "Hello, Python!\n",
          ),
          TextBlock(
            "**print()** shows a message on the screen. Whatever you put inside "
            "the quotes is what appears. Tap **Run** to try it!",
          ),
        ],
      ),
      PythonLesson(
        id: 'b1_l2',
        title: 'The print() command',
        blocks: [
          TextBlock(
            "You can print as many lines as you like. Each **print()** puts its "
            "message on its own new line.",
          ),
          CodeBlock(
            code: "print(\"My name is Asha.\")\n"
                "print(\"I am learning to code!\")",
            expectedOutput: "My name is Asha.\nI am learning to code!\n",
          ),
          TextBlock(
            "The words inside quotes are called a **string** — that's just a "
            "fancy word for text. You can use single quotes '…' or double "
            "quotes \"…\", both work.",
          ),
          ChallengeBlock(
            prompt: "Change the message to print YOUR name!",
            starterCode: "print(\"My name is ____\")",
            hint: "Type your name between the quotes, replacing the ____.",
          ),
        ],
      ),
      PythonLesson(
        id: 'b1_l3',
        title: 'Emoji art',
        blocks: [
          TextBlock(
            "Strings can hold anything you can type — even emojis! Let's make "
            "a little celebration banner. 🎉",
          ),
          CodeBlock(
            code: "print(\"🎉 Welcome! 🎉\")\n"
                "print(\"⭐ You are a coder now ⭐\")",
            expectedOutput: "🎉 Welcome! 🎉\n⭐ You are a coder now ⭐\n",
          ),
          ChallengeBlock(
            prompt: "Make your own two-line emoji banner!",
            starterCode: "print(\"🚀 Code time! 🚀\")\n"
                "print(\"🌟 Let's go 🌟\")",
            hint: "Change the words and pick any emojis you like.",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which command shows a message on the screen?",
        options: ["show()", "print()", "say()", "display()"],
        correctIndex: 1,
        explanation: "print() is Python's command for showing output.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What do we call text inside quotes, like \"hello\"?",
        options: ["A number", "A loop", "A string", "A function"],
        correctIndex: 2,
        explanation: "Text inside quotes is called a string.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What does this print?",
        code: "print(\"Hi\")\nprint(\"Bye\")",
        options: ["Hi Bye", "Hi\nBye", "HiBye", "print Hi Bye"],
        correctIndex: 1,
        explanation: "Each print() puts its message on a new line.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which of these is a valid string?",
        options: ["hello", "\"hello\"", "print", "3 + 4"],
        correctIndex: 1,
        explanation: "A string must be wrapped in quotes.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What does this print?",
        code: "print(\"⭐⭐⭐\")",
        options: ["⭐⭐⭐", "star star star", "3 stars", "⭐"],
        correctIndex: 0,
        explanation: "print() shows exactly what's inside the quotes.",
      ),
    ],
  ),

  // ── B2: Variables & Numbers ─────────────────────────────────────────────────
  PythonChapter(
    id: 'b2_variables',
    level: PythonLevel.beginner,
    title: 'Variables & Numbers',
    subtitle: 'Store values and do maths',
    emoji: '🔢',
    lessons: [
      PythonLesson(
        id: 'b2_l1',
        title: 'What is a variable?',
        blocks: [
          TextBlock(
            "A **variable** is like a labelled tiffin box 🍱 — it stores a "
            "value so you can use it later. You make one with an `=` sign.",
          ),
          CodeBlock(
            code: "score = 42\nprint(score)",
            expectedOutput: "42\n",
          ),
          TextBlock(
            "Here `score` is the label and `42` is what's inside. When you "
            "print `score`, Python shows what's stored in it.",
          ),
          ChallengeBlock(
            prompt: "Make a variable called age and print it.",
            starterCode: "age = 12\nprint(age)",
            expectedOutput: "12\n",
            hint: "Change the number, then Run to see it print.",
          ),
        ],
      ),
      PythonLesson(
        id: 'b2_l2',
        title: 'Doing maths',
        blocks: [
          TextBlock(
            "Python is a great calculator. It knows `+` add, `-` subtract, "
            "`*` multiply and `/` divide.",
          ),
          CodeBlock(
            code: "print(5 + 3)\nprint(10 - 4)\nprint(6 * 7)",
            expectedOutput: "8\n6\n42\n",
          ),
          TextBlock(
            "You can store the answer in a variable, too:",
          ),
          CodeBlock(
            code: "runs = 45 + 37\nprint(runs)",
            expectedOutput: "82\n",
          ),
        ],
      ),
      PythonLesson(
        id: 'b2_l3',
        title: 'Cricket run-rate',
        blocks: [
          TextBlock(
            "Let's use maths for something real. **Run rate** = runs ÷ overs. "
            "Notice `/` always gives a decimal answer.",
          ),
          CodeBlock(
            code: "runs = 90\novers = 10\nprint(runs / overs)",
            expectedOutput: "9.0\n",
          ),
          ChallengeBlock(
            prompt: "A team scored 120 runs in 20 overs. "
                "Find the run rate.",
            starterCode: "runs = 120\novers = 20\nprint(runs / overs)",
            expectedOutput: "6.0\n",
            hint: "Divide runs by overs using /.",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What symbol stores a value in a variable?",
        options: ["==", "=", "+", ":"],
        correctIndex: 1,
        explanation: "A single = stores (assigns) a value to a variable.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What does this print?",
        code: "x = 4\ny = 6\nprint(x + y)",
        options: ["46", "10", "x + y", "24"],
        correctIndex: 1,
        explanation: "x is 4 and y is 6, so x + y is 10.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What does 7 / 2 print?",
        code: "print(7 / 2)",
        options: ["3", "3.5", "4", "7/2"],
        correctIndex: 1,
        explanation: "The / operator always gives a decimal, so 7 / 2 is 3.5.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which symbol multiplies two numbers?",
        options: ["x", "*", "×", "by"],
        correctIndex: 1,
        explanation: "Python uses * for multiplication.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What is printed?",
        code: "total = 3 * 4\nprint(total)",
        options: ["34", "7", "12", "total"],
        correctIndex: 2,
        explanation: "3 * 4 is 12, stored in total and then printed.",
      ),
    ],
  ),

  // ── B3: Playing with Text ───────────────────────────────────────────────────
  PythonChapter(
    id: 'b3_text',
    level: PythonLevel.beginner,
    title: 'Playing with Text',
    subtitle: 'Join, repeat and build strings',
    emoji: '✍️',
    lessons: [
      PythonLesson(
        id: 'b3_l1',
        title: 'Joining strings',
        blocks: [
          TextBlock(
            "You can stick strings together with `+`. This is called "
            "**joining** (or concatenation — a big word for a simple idea!).",
          ),
          CodeBlock(
            code: "first = \"Rani\"\nprint(\"Hello, \" + first + \"!\")",
            expectedOutput: "Hello, Rani!\n",
          ),
          TextBlock(
            "Careful: `+` joins **text with text**. To join a number, turn it "
            "into text first with `str()`.",
          ),
          CodeBlock(
            code: "age = 11\nprint(\"I am \" + str(age) + \" years old\")",
            expectedOutput: "I am 11 years old\n",
          ),
        ],
      ),
      PythonLesson(
        id: 'b3_l2',
        title: 'Repeating with *',
        blocks: [
          TextBlock(
            "Multiplying a string by a number **repeats** it. Great for making "
            "patterns and lines! ⭐",
          ),
          CodeBlock(
            code: "print(\"⭐\" * 5)\nprint(\"=\" * 10)",
            expectedOutput: "⭐⭐⭐⭐⭐\n==========\n",
          ),
          ChallengeBlock(
            prompt: "Print a row of 8 hearts.",
            starterCode: "print(\"❤️\" * 3)",
            hint: "Change the number 3 to 8.",
          ),
        ],
      ),
      PythonLesson(
        id: 'b3_l3',
        title: 'len() and f-strings',
        blocks: [
          TextBlock(
            "**len()** counts how many letters are in a string.",
          ),
          CodeBlock(
            code: "word = \"banana\"\nprint(len(word))",
            expectedOutput: "6\n",
          ),
          TextBlock(
            "An **f-string** is the easiest way to mix words and values. Put "
            "an `f` before the quote, then wrap any value in `{ }`.",
          ),
          CodeBlock(
            code: "name = \"Dev\"\nscore = 95\nprint(f\"{name} scored {score}!\")",
            expectedOutput: "Dev scored 95!\n",
          ),
          ChallengeBlock(
            prompt: "Use an f-string to say your favourite number.",
            starterCode: "num = 7\nprint(f\"My favourite number is {num}\")",
            hint: "Change num, keep the {num} inside the f-string.",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What does this print?",
        code: "print(\"ha\" * 3)",
        options: ["ha3", "hahaha", "ha ha ha", "6"],
        correctIndex: 1,
        explanation: "Multiplying a string repeats it, so \"ha\" * 3 is hahaha.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What does len(\"cat\") give?",
        options: ["cat", "1", "3", "0"],
        correctIndex: 2,
        explanation: "len() counts the letters — \"cat\" has 3.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What does this print?",
        code: "print(\"a\" + \"b\" + \"c\")",
        options: ["abc", "a b c", "a+b+c", "3"],
        correctIndex: 0,
        explanation: "+ joins strings with no space, giving abc.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "To join a number to text with +, you first use…",
        options: ["int()", "len()", "str()", "print()"],
        correctIndex: 2,
        explanation: "str() turns a number into text so + can join it.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What does this print?",
        code: "n = 5\nprint(f\"n is {n}\")",
        options: ["n is n", "n is {n}", "n is 5", "5"],
        correctIndex: 2,
        explanation: "In an f-string, {n} is replaced by the value 5.",
      ),
    ],
  ),

  // ── B4: Talking Programs (input) ────────────────────────────────────────────
  PythonChapter(
    id: 'b4_input',
    level: PythonLevel.beginner,
    title: 'Talking Programs',
    subtitle: 'Ask the user a question',
    emoji: '💬',
    lessons: [
      PythonLesson(
        id: 'b4_l1',
        title: 'Asking with input()',
        blocks: [
          TextBlock(
            "**input()** pauses your program and asks the user to type "
            "something. Whatever they type comes back as a string.",
          ),
          CodeBlock(
            code: "name = input(\"What is your name? \")\n"
                "print(\"Hi \" + name + \"!\")",
            expectedOutput: "What is your name? Meera\nHi Meera!\n",
            presetInputs: ["Meera"],
          ),
          TextBlock(
            "When you Run this, a little box will pop up for you to type your "
            "answer. Try it! 💬",
          ),
        ],
      ),
      PythonLesson(
        id: 'b4_l2',
        title: 'Numbers from input',
        blocks: [
          TextBlock(
            "input() always gives **text**, even if the user types a number. "
            "To do maths, convert it with **int()** (whole number) or "
            "**float()** (decimal).",
          ),
          CodeBlock(
            code: "age = int(input(\"Your age? \"))\n"
                "print(\"Next year you'll be \" + str(age + 1))",
            expectedOutput: "Your age? 12\nNext year you'll be 13\n",
            presetInputs: ["12"],
          ),
          ChallengeBlock(
            prompt: "Ask for a number and print its double.",
            starterCode: "n = int(input(\"Give a number: \"))\n"
                "print(n * 2)",
            hint: "int(input(...)) reads a number; multiply it by 2.",
            presetInputs: ["8"],
          ),
        ],
      ),
      PythonLesson(
        id: 'b4_l3',
        title: 'Samosa shop bill',
        blocks: [
          TextBlock(
            "Let's build a tiny shop program! Ask how many samosas, then show "
            "the bill. Each samosa costs ₹12. 🥟",
          ),
          CodeBlock(
            code: "count = int(input(\"How many samosas? \"))\n"
                "bill = count * 12\n"
                "print(f\"Your bill is ₹{bill}\")",
            expectedOutput: "How many samosas? 5\nYour bill is ₹60\n",
            presetInputs: ["5"],
          ),
          ChallengeBlock(
            prompt: "Change the price to ₹15 per samosa and try again.",
            starterCode: "count = int(input(\"How many samosas? \"))\n"
                "bill = count * 15\n"
                "print(f\"Your bill is ₹{bill}\")",
            hint: "Just change 12 to 15.",
            presetInputs: ["4"],
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What does input() give you?",
        options: ["A number", "A string (text)", "A list", "Nothing"],
        correctIndex: 1,
        explanation: "input() always returns text, even for typed numbers.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "To turn typed text into a whole number, you use…",
        options: ["str()", "int()", "len()", "print()"],
        correctIndex: 1,
        explanation: "int() converts text like \"12\" into the number 12.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "If the user types 10, what prints?",
        code: "n = int(input())\nprint(n + 5)",
        options: ["105", "15", "n + 5", "10"],
        correctIndex: 1,
        explanation: "int() makes 10 a number, so 10 + 5 is 15.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Why might int(input()) be needed instead of input()?",
        options: [
          "To make text louder",
          "So you can do maths with the answer",
          "To print faster",
          "It is never needed",
        ],
        correctIndex: 1,
        explanation: "Maths needs numbers, and input() gives text — so we "
            "convert it with int().",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "If the user types 3, what prints?",
        code: "c = int(input())\nprint(c * 12)",
        options: ["312", "36", "c * 12", "15"],
        correctIndex: 1,
        explanation: "3 * 12 is 36.",
      ),
    ],
  ),
];
