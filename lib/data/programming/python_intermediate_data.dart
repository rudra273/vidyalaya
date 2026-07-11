import 'python_models.dart';

// ─── Intermediate chapters (I1–I3) ────────────────────────────────────────────
// Every CodeBlock's expectedOutput is verified against the real interpreter by
// test/data/python_course_test.dart.

const pythonIntermediateChapters = <PythonChapter>[
  // ── I1: Making Decisions ────────────────────────────────────────────────────
  PythonChapter(
    id: 'i1_decisions',
    level: PythonLevel.intermediate,
    title: 'Making Decisions',
    subtitle: 'if, elif and else',
    emoji: '🤔',
    lessons: [
      PythonLesson(
        id: 'i1_l1',
        title: 'True or False?',
        blocks: [
          TextBlock(
            "Computers make decisions by asking **yes/no** questions. The "
            "answer is a **bool** — either `True` or `False`.",
          ),
          CodeBlock(
            code: "print(5 > 3)\nprint(2 == 4)\nprint(10 >= 10)",
            expectedOutput: "True\nFalse\nTrue\n",
          ),
          TextBlock(
            "We compare with: `>` greater, `<` less, `>=` at least, `<=` at "
            "most, `==` equal, and `!=` not equal.",
          ),
        ],
      ),
      PythonLesson(
        id: 'i1_l2',
        title: 'if and else',
        blocks: [
          TextBlock(
            "**if** runs some code only when a question is `True`. Notice the "
            "colon `:` and the indented lines underneath.",
          ),
          CodeBlock(
            code: "age = 15\nif age >= 13:\n    print(\"You are a teenager!\")",
            expectedOutput: "You are a teenager!\n",
          ),
          TextBlock(
            "Add **else** to run different code when the question is `False`.",
          ),
          CodeBlock(
            code: "marks = 35\nif marks >= 40:\n    print(\"Pass\")\nelse:\n    print(\"Try again\")",
            expectedOutput: "Try again\n",
          ),
          ChallengeBlock(
            prompt: "Change marks to 72 so it prints Pass.",
            starterCode: "marks = 35\nif marks >= 40:\n    print(\"Pass\")\nelse:\n    print(\"Try again\")",
            expectedOutput: "Pass\n",
            hint: "Change the number stored in marks.",
          ),
        ],
      ),
      PythonLesson(
        id: 'i1_l3',
        title: 'The marksheet grader',
        blocks: [
          TextBlock(
            "**elif** (else-if) lets you check many cases in order. Python "
            "stops at the first one that's `True`. 🏆",
          ),
          CodeBlock(
            code: "score = 92\n"
                "if score >= 90:\n"
                "    print(\"Topper! 🏆\")\n"
                "elif score >= 70:\n"
                "    print(\"Great job!\")\n"
                "elif score >= 40:\n"
                "    print(\"Passed\")\n"
                "else:\n"
                "    print(\"Keep practising\")",
            expectedOutput: "Topper! 🏆\n",
          ),
          ChallengeBlock(
            prompt: "Set score to 55 and predict which message shows.",
            starterCode: "score = 55\n"
                "if score >= 90:\n"
                "    print(\"Topper! 🏆\")\n"
                "elif score >= 70:\n"
                "    print(\"Great job!\")\n"
                "elif score >= 40:\n"
                "    print(\"Passed\")\n"
                "else:\n"
                "    print(\"Keep practising\")",
            expectedOutput: "Passed\n",
            hint: "55 is not ≥90 or ≥70, but it is ≥40.",
          ),
        ],
      ),
      PythonLesson(
        id: 'i1_l4',
        title: 'Combining with and / or',
        blocks: [
          TextBlock(
            "Use **and** when BOTH must be true, **or** when AT LEAST ONE must "
            "be true, and **not** to flip true/false.",
          ),
          CodeBlock(
            code: "temp = 32\nif temp > 30 and temp < 40:\n    print(\"Warm day 🌤️\")",
            expectedOutput: "Warm day 🌤️\n",
          ),
          CodeBlock(
            code: "day = \"Sunday\"\nif day == \"Saturday\" or day == \"Sunday\":\n    print(\"Weekend!\")",
            expectedOutput: "Weekend!\n",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What type of value is True?",
        options: ["A string", "A number", "A bool", "A list"],
        correctIndex: 2,
        explanation: "True and False are bool (boolean) values.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "x = 8\nif x > 10:\n    print(\"big\")\nelse:\n    print(\"small\")",
        options: ["big", "small", "8", "nothing"],
        correctIndex: 1,
        explanation: "8 is not greater than 10, so the else branch runs.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which keyword checks another condition after if?",
        options: ["elseif", "elif", "orif", "then"],
        correctIndex: 1,
        explanation: "Python uses elif (short for else-if).",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "print(True and False)",
        options: ["True", "False", "and", "1"],
        correctIndex: 1,
        explanation: "and needs BOTH to be True; one is False, so it's False.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "With score = 70, what prints?",
        code: "score = 70\nif score >= 90:\n    print(\"A\")\nelif score >= 60:\n    print(\"B\")\nelse:\n    print(\"C\")",
        options: ["A", "B", "C", "70"],
        correctIndex: 1,
        explanation: "70 isn't ≥90 but is ≥60, so B prints.",
      ),
    ],
  ),

  // ── I2: Loops with for & range ──────────────────────────────────────────────
  PythonChapter(
    id: 'i2_for_loops',
    level: PythonLevel.intermediate,
    title: 'Loops: for & range',
    subtitle: 'Repeat without repeating yourself',
    emoji: '🔁',
    lessons: [
      PythonLesson(
        id: 'i2_l1',
        title: 'The for loop',
        blocks: [
          TextBlock(
            "A **for loop** repeats code. **range(n)** counts from 0 up to "
            "(but not including) n.",
          ),
          CodeBlock(
            code: "for i in range(5):\n    print(i)",
            expectedOutput: "0\n1\n2\n3\n4\n",
          ),
          TextBlock(
            "Each time round, `i` becomes the next number. This is much shorter "
            "than writing five print lines!",
          ),
        ],
      ),
      PythonLesson(
        id: 'i2_l2',
        title: 'range with start and step',
        blocks: [
          TextBlock(
            "**range(start, stop)** begins at start. **range(start, stop, "
            "step)** jumps by step each time.",
          ),
          CodeBlock(
            code: "for n in range(2, 6):\n    print(n)",
            expectedOutput: "2\n3\n4\n5\n",
          ),
          CodeBlock(
            code: "for n in range(0, 11, 2):\n    print(n)",
            expectedOutput: "0\n2\n4\n6\n8\n10\n",
          ),
          ChallengeBlock(
            prompt: "Print the odd numbers from 1 to 9.",
            starterCode: "for n in range(1, 10, 2):\n    print(n)",
            expectedOutput: "1\n3\n5\n7\n9\n",
            hint: "Start at 1 and step by 2.",
          ),
        ],
      ),
      PythonLesson(
        id: 'i2_l3',
        title: 'Multiplication tables',
        blocks: [
          TextBlock(
            "Every student memorises tables — let's make Python print one! We "
            "use an f-string to show the sum neatly.",
          ),
          CodeBlock(
            code: "for i in range(1, 6):\n    print(f\"7 x {i} = {7 * i}\")",
            expectedOutput: "7 x 1 = 7\n7 x 2 = 14\n7 x 3 = 21\n7 x 4 = 28\n7 x 5 = 35\n",
          ),
          ChallengeBlock(
            prompt: "Print the table of 9 up to 9 x 5.",
            starterCode: "for i in range(1, 6):\n    print(f\"9 x {i} = {9 * i}\")",
            expectedOutput: "9 x 1 = 9\n9 x 2 = 18\n9 x 3 = 27\n9 x 4 = 36\n9 x 5 = 45\n",
            hint: "Change 7 to 9 in both places.",
          ),
        ],
      ),
      PythonLesson(
        id: 'i2_l4',
        title: 'Star patterns',
        blocks: [
          TextBlock(
            "Combine loops with string repeat `*` to draw shapes. A growing "
            "triangle of stars! ⭐",
          ),
          CodeBlock(
            code: "for i in range(1, 5):\n    print(\"⭐\" * i)",
            expectedOutput: "⭐\n⭐⭐\n⭐⭐⭐\n⭐⭐⭐⭐\n",
          ),
          ChallengeBlock(
            prompt: "Make the triangle 6 rows tall.",
            starterCode: "for i in range(1, 5):\n    print(\"⭐\" * i)",
            expectedOutput: "⭐\n⭐⭐\n⭐⭐⭐\n⭐⭐⭐⭐\n⭐⭐⭐⭐⭐\n⭐⭐⭐⭐⭐⭐\n",
            hint: "range(1, 5) gives 4 rows — change 5 to 7 for 6 rows.",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "How many lines does this print?",
        code: "for i in range(4):\n    print(\"hi\")",
        options: ["3", "4", "5", "0"],
        correctIndex: 1,
        explanation: "range(4) gives 0,1,2,3 — that's 4 times.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What does range(2, 5) produce?",
        code: "for i in range(2, 5):\n    print(i)",
        options: ["2 3 4 5", "2 3 4", "0 1 2 3 4", "2 5"],
        correctIndex: 1,
        explanation: "It starts at 2 and stops before 5: 2, 3, 4.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "In range(0, 10, 2), what is the 2?",
        options: ["The start", "The stop", "The step (jump)", "A mistake"],
        correctIndex: 2,
        explanation: "The third number is the step — how much to jump each time.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints on the last line?",
        code: "for i in range(1, 4):\n    print(\"#\" * i)",
        options: ["#", "##", "###", "####"],
        correctIndex: 2,
        explanation: "The last i is 3, so \"#\" * 3 is ###.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Why use a for loop instead of many print lines?",
        options: [
          "It looks cooler",
          "To repeat without rewriting the same code",
          "Loops are faster to type only",
          "You never should",
        ],
        correctIndex: 1,
        explanation: "Loops let you repeat work without copying code.",
      ),
    ],
  ),

  // ── I3: Loops with while, break, continue ───────────────────────────────────
  PythonChapter(
    id: 'i3_while_loops',
    level: PythonLevel.intermediate,
    title: 'Loops: while & break',
    subtitle: 'Loop until something changes',
    emoji: '🚀',
    lessons: [
      PythonLesson(
        id: 'i3_l1',
        title: 'The while loop',
        blocks: [
          TextBlock(
            "A **while loop** keeps going as long as its question stays `True`. "
            "Make sure something changes inside, or it will loop forever!",
          ),
          CodeBlock(
            code: "count = 1\nwhile count <= 3:\n    print(count)\n    count += 1",
            expectedOutput: "1\n2\n3\n",
          ),
          TextBlock(
            "Here `count += 1` adds 1 each time. Once count becomes 4, the "
            "question `count <= 3` is `False` and the loop stops.",
          ),
        ],
      ),
      PythonLesson(
        id: 'i3_l2',
        title: 'Countdown rocket',
        blocks: [
          TextBlock(
            "Let's count DOWN instead by subtracting. 3… 2… 1… Liftoff! 🚀",
          ),
          CodeBlock(
            code: "n = 3\nwhile n > 0:\n    print(n)\n    n -= 1\nprint(\"🚀 Liftoff!\")",
            expectedOutput: "3\n2\n1\n🚀 Liftoff!\n",
          ),
          ChallengeBlock(
            prompt: "Start the countdown from 5.",
            starterCode: "n = 3\nwhile n > 0:\n    print(n)\n    n -= 1\nprint(\"🚀 Liftoff!\")",
            expectedOutput: "5\n4\n3\n2\n1\n🚀 Liftoff!\n",
            hint: "Change the first line to n = 5.",
          ),
        ],
      ),
      PythonLesson(
        id: 'i3_l3',
        title: 'break and continue',
        blocks: [
          TextBlock(
            "**break** jumps out of a loop early. **continue** skips the rest "
            "of this round and goes to the next.",
          ),
          CodeBlock(
            code: "for i in range(1, 10):\n    if i == 4:\n        break\n    print(i)",
            expectedOutput: "1\n2\n3\n",
          ),
          CodeBlock(
            code: "for i in range(1, 6):\n    if i == 3:\n        continue\n    print(i)",
            expectedOutput: "1\n2\n4\n5\n",
          ),
          ChallengeBlock(
            prompt: "Print numbers 1 to 8, but skip 5 using continue.",
            starterCode: "for i in range(1, 9):\n    if i == 5:\n        continue\n    print(i)",
            expectedOutput: "1\n2\n3\n4\n6\n7\n8\n",
            hint: "continue skips printing when i is 5.",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "A while loop keeps going as long as its condition is…",
        options: ["False", "True", "zero", "empty"],
        correctIndex: 1,
        explanation: "It repeats while the condition stays True.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What might cause an accidental forever-loop?",
        options: [
          "Using print()",
          "Forgetting to change the loop variable",
          "Using a number",
          "Adding a comment",
        ],
        correctIndex: 1,
        explanation: "If nothing changes, the condition stays True forever.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "for i in range(1, 6):\n    if i == 3:\n        break\n    print(i)",
        options: ["1 2", "1 2 3", "1 2 3 4 5", "3"],
        correctIndex: 0,
        explanation: "break stops the loop at i == 3, so only 1 and 2 print.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What does continue do?",
        options: [
          "Stops the whole loop",
          "Skips to the next round of the loop",
          "Restarts the program",
          "Prints continue",
        ],
        correctIndex: 1,
        explanation: "continue skips the rest of this round and moves on.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What is the last thing printed?",
        code: "n = 3\nwhile n > 0:\n    print(n)\n    n -= 1\nprint(\"Go!\")",
        options: ["3", "1", "0", "Go!"],
        correctIndex: 3,
        explanation: "After the countdown ends, Go! prints last.",
      ),
    ],
  ),
];
