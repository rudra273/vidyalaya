import 'python_models.dart';

// ─── Advanced chapters (A1–A3) ────────────────────────────────────────────────
// Every CodeBlock's expectedOutput is verified against the real interpreter by
// test/data/python_course_test.dart.

const pythonAdvancedChapters = <PythonChapter>[
  // ── A1: Lists ───────────────────────────────────────────────────────────────
  PythonChapter(
    id: 'a1_lists',
    level: PythonLevel.advanced,
    title: 'Lists',
    subtitle: 'Store many things together',
    emoji: '📋',
    lessons: [
      PythonLesson(
        id: 'a1_l1',
        title: 'Making a list',
        blocks: [
          TextBlock(
            "A **list** holds many values in order, inside square brackets "
            "`[ ]`. Great for a team, a shopping list, or scores.",
          ),
          CodeBlock(
            code: "team = [\"Rohit\", \"Virat\", \"Bumrah\"]\nprint(team)",
            expectedOutput: "['Rohit', 'Virat', 'Bumrah']\n",
          ),
          TextBlock(
            "**len()** tells you how many items are in the list.",
          ),
          CodeBlock(
            code: "team = [\"Rohit\", \"Virat\", \"Bumrah\"]\nprint(len(team))",
            expectedOutput: "3\n",
          ),
        ],
      ),
      PythonLesson(
        id: 'a1_l2',
        title: 'Picking items (indexing)',
        blocks: [
          TextBlock(
            "Each item has a **position** (index). Counting starts at **0**! "
            "So the first item is `[0]`.",
          ),
          CodeBlock(
            code: "fruits = [\"mango\", \"apple\", \"banana\"]\n"
                "print(fruits[0])\n"
                "print(fruits[2])",
            expectedOutput: "mango\nbanana\n",
          ),
          TextBlock(
            "A negative index counts from the end: `[-1]` is the last item.",
          ),
          CodeBlock(
            code: "fruits = [\"mango\", \"apple\", \"banana\"]\nprint(fruits[-1])",
            expectedOutput: "banana\n",
          ),
          ChallengeBlock(
            prompt: "Print the second fruit (apple) using its index.",
            starterCode: "fruits = [\"mango\", \"apple\", \"banana\"]\nprint(fruits[0])",
            expectedOutput: "apple\n",
            hint: "The second item is at index 1 (counting starts at 0).",
          ),
        ],
      ),
      PythonLesson(
        id: 'a1_l3',
        title: 'Growing a list',
        blocks: [
          TextBlock(
            "**.append()** adds a new item to the end of a list.",
          ),
          CodeBlock(
            code: "scores = [10, 20]\nscores.append(30)\nprint(scores)",
            expectedOutput: "[10, 20, 30]\n",
          ),
          ChallengeBlock(
            prompt: "Add your favourite number to the list.",
            starterCode: "nums = [1, 2, 3]\nnums.append(7)\nprint(nums)",
            hint: "Change the value inside append().",
          ),
        ],
      ),
      PythonLesson(
        id: 'a1_l4',
        title: 'Looping over a list',
        blocks: [
          TextBlock(
            "A **for loop** can go through every item in a list — no numbers "
            "needed!",
          ),
          CodeBlock(
            code: "marks = [80, 95, 60]\nfor m in marks:\n    print(m)",
            expectedOutput: "80\n95\n60\n",
          ),
          TextBlock(
            "Combine looping with a running total to add everything up.",
          ),
          CodeBlock(
            code: "marks = [80, 95, 60]\n"
                "total = 0\n"
                "for m in marks:\n"
                "    total += m\n"
                "print(f\"Total: {total}\")",
            expectedOutput: "Total: 235\n",
          ),
          ChallengeBlock(
            prompt: "Count how many students are in this list.",
            starterCode: "students = [\"Asha\", \"Ravi\", \"Meera\", \"Dev\"]\nprint(len(students))",
            expectedOutput: "4\n",
            hint: "len() gives the count.",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What symbols make a list?",
        options: ["( )", "{ }", "[ ]", "< >"],
        correctIndex: 2,
        explanation: "Lists use square brackets [ ].",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "a = [10, 20, 30]\nprint(a[1])",
        options: ["10", "20", "30", "1"],
        correctIndex: 1,
        explanation: "Index 1 is the second item (counting starts at 0): 20.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "The first item of a list is at index…",
        options: ["1", "0", "-1", "first"],
        correctIndex: 1,
        explanation: "List positions start counting at 0.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which adds an item to the end of a list?",
        options: [".add()", ".append()", ".push()", ".insert()"],
        correctIndex: 1,
        explanation: "In our course, .append() adds to the end.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "nums = [2, 4, 6]\ntotal = 0\nfor n in nums:\n    total += n\nprint(total)",
        options: ["6", "12", "246", "3"],
        correctIndex: 1,
        explanation: "2 + 4 + 6 = 12.",
      ),
    ],
  ),

  // ── A2: Functions ───────────────────────────────────────────────────────────
  PythonChapter(
    id: 'a2_functions',
    level: PythonLevel.advanced,
    title: 'Functions',
    subtitle: 'Build your own commands',
    emoji: '🛠️',
    lessons: [
      PythonLesson(
        id: 'a2_l1',
        title: 'Defining a function',
        blocks: [
          TextBlock(
            "A **function** is a reusable machine 🛠️ — you build it once with "
            "**def**, then use it as many times as you like.",
          ),
          CodeBlock(
            code: "def greet():\n    print(\"Namaste! 🙏\")\n\ngreet()\ngreet()",
            expectedOutput: "Namaste! 🙏\nNamaste! 🙏\n",
          ),
          TextBlock(
            "Writing `greet()` **calls** the function — it runs the indented "
            "code inside.",
          ),
        ],
      ),
      PythonLesson(
        id: 'a2_l2',
        title: 'Inputs (parameters)',
        blocks: [
          TextBlock(
            "Functions can take **inputs**, called parameters, so they work "
            "differently each time.",
          ),
          CodeBlock(
            code: "def greet(name):\n    print(f\"Hello, {name}!\")\n\ngreet(\"Asha\")\ngreet(\"Ravi\")",
            expectedOutput: "Hello, Asha!\nHello, Ravi!\n",
          ),
          ChallengeBlock(
            prompt: "Call greet with your own name.",
            starterCode: "def greet(name):\n    print(f\"Hello, {name}!\")\n\ngreet(\"Friend\")",
            hint: "Change \"Friend\" to any name.",
          ),
        ],
      ),
      PythonLesson(
        id: 'a2_l3',
        title: 'Giving back with return',
        blocks: [
          TextBlock(
            "**return** sends a value back out of the function, so you can use "
            "the answer later.",
          ),
          CodeBlock(
            code: "def area(width, height):\n    return width * height\n\nprint(area(4, 5))",
            expectedOutput: "20\n",
          ),
          CodeBlock(
            code: "def is_even(n):\n    return n % 2 == 0\n\nprint(is_even(10))\nprint(is_even(7))",
            expectedOutput: "True\nFalse\n",
          ),
          ChallengeBlock(
            prompt: "Write area for a 6 by 3 rectangle.",
            starterCode: "def area(width, height):\n    return width * height\n\nprint(area(4, 5))",
            expectedOutput: "18\n",
            hint: "Call area(6, 3).",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which keyword creates a function?",
        options: ["func", "def", "function", "make"],
        correctIndex: 1,
        explanation: "Python uses def to define a function.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "How do you run a function called greet?",
        options: ["run greet", "greet()", "call greet", "def greet"],
        correctIndex: 1,
        explanation: "You call it by writing its name with () — greet().",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "def double(x):\n    return x * 2\n\nprint(double(5))",
        options: ["5", "10", "x * 2", "25"],
        correctIndex: 1,
        explanation: "double(5) returns 5 * 2 = 10.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What does return do?",
        options: [
          "Prints a value",
          "Sends a value back out of the function",
          "Stops the program",
          "Makes a loop",
        ],
        correctIndex: 1,
        explanation: "return hands a value back to whoever called the function.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "def add(a, b):\n    return a + b\n\nprint(add(3, 4))",
        options: ["34", "7", "a + b", "12"],
        correctIndex: 1,
        explanation: "add(3, 4) returns 3 + 4 = 7.",
      ),
    ],
  ),

  // ── A3: Mini Projects ───────────────────────────────────────────────────────
  PythonChapter(
    id: 'a3_projects',
    level: PythonLevel.advanced,
    title: 'Mini Projects',
    subtitle: 'Put it all together',
    emoji: '🏗️',
    lessons: [
      PythonLesson(
        id: 'a3_l1',
        title: 'Chai-stall billing',
        blocks: [
          TextBlock(
            "Time to combine everything! A tiny shop program: it asks how many "
            "chais, then prints the bill. Each chai is ₹10. ☕",
          ),
          CodeBlock(
            code: "cups = int(input(\"How many chais? \"))\n"
                "bill = cups * 10\n"
                "print(f\"That's ₹{bill}. Thank you! ☕\")",
            expectedOutput: "How many chais? 4\nThat's ₹40. Thank you! ☕\n",
            presetInputs: ["4"],
          ),
          ChallengeBlock(
            prompt: "Add a ₹5 service charge to the total bill.",
            starterCode: "cups = int(input(\"How many chais? \"))\n"
                "bill = cups * 10 + 5\n"
                "print(f\"That's ₹{bill}. Thank you! ☕\")",
            expectedOutput: "How many chais? 3\nThat's ₹35. Thank you! ☕\n",
            hint: "Add 5 to the bill total.",
            presetInputs: ["3"],
          ),
        ],
      ),
      PythonLesson(
        id: 'a3_l2',
        title: 'Number pyramid',
        blocks: [
          TextBlock(
            "Loops and f-strings can draw a number pyramid. Each row shows the "
            "row number, repeated.",
          ),
          CodeBlock(
            code: "for i in range(1, 5):\n    print(f\"{i}\" * i)",
            expectedOutput: "1\n22\n333\n4444\n",
          ),
          ChallengeBlock(
            prompt: "Make the pyramid 6 rows tall.",
            starterCode: "for i in range(1, 5):\n    print(f\"{i}\" * i)",
            expectedOutput: "1\n22\n333\n4444\n55555\n666666\n",
            hint: "Change range(1, 5) to range(1, 7).",
          ),
        ],
      ),
      PythonLesson(
        id: 'a3_l3',
        title: 'Grade helper',
        blocks: [
          TextBlock(
            "Let's write a **function** that turns a score into a grade — then "
            "reuse it for a whole list of students. 🎓",
          ),
          CodeBlock(
            code: "def grade(score):\n"
                "    if score >= 90:\n"
                "        return \"A\"\n"
                "    elif score >= 70:\n"
                "        return \"B\"\n"
                "    else:\n"
                "        return \"C\"\n"
                "\n"
                "for s in [95, 72, 40]:\n"
                "    print(grade(s))",
            expectedOutput: "A\nB\nC\n",
          ),
          ChallengeBlock(
            prompt: "Add a student with score 88 to the list.",
            starterCode: "def grade(score):\n"
                "    if score >= 90:\n"
                "        return \"A\"\n"
                "    elif score >= 70:\n"
                "        return \"B\"\n"
                "    else:\n"
                "        return \"C\"\n"
                "\n"
                "for s in [95, 88, 72, 40]:\n"
                "    print(grade(s))",
            expectedOutput: "A\nB\nB\nC\n",
            hint: "88 is ≥70 but not ≥90, so it should be a B.",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "In the billing program, why use int(input())?",
        options: [
          "To make the text bold",
          "So we can multiply the count by the price",
          "To print faster",
          "It is optional and useless",
        ],
        correctIndex: 1,
        explanation: "input() gives text; int() makes it a number so maths works.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What is the last line printed?",
        code: "for i in range(1, 4):\n    print(f\"{i}\" * i)",
        options: ["1", "22", "333", "3333"],
        correctIndex: 2,
        explanation: "The last i is 3, so \"3\" repeated 3 times is 333.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "With this grade function, what does grade(85) return?",
        code: "def grade(s):\n    if s >= 90:\n        return \"A\"\n    elif s >= 70:\n        return \"B\"\n    else:\n        return \"C\"",
        options: ["A", "B", "C", "85"],
        correctIndex: 1,
        explanation: "85 is ≥70 but not ≥90, so it returns B.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Why is a function useful in the grade program?",
        options: [
          "It makes the code colourful",
          "We can reuse the same logic for every student",
          "Functions run faster than loops always",
          "It is required by law",
        ],
        correctIndex: 1,
        explanation: "Define the logic once, reuse it for each student in the loop.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which ideas did the mini projects combine?",
        options: [
          "Only printing",
          "input, maths, loops and functions",
          "Only functions",
          "Nothing new",
        ],
        correctIndex: 1,
        explanation: "The projects bring together everything from the course.",
      ),
    ],
  ),
];
