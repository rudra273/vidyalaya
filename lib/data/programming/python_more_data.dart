import 'python_models.dart';

// ─── More advanced chapters (A4–A9) ───────────────────────────────────────────
// Text methods, dictionaries & tuples, nested loops, errors, random games and
// a second set of mini projects. Every CodeBlock's expectedOutput was produced
// by real Python and is re-checked against the course interpreter by
// test/data/python_course_test.dart.

const pythonMoreChapters = <PythonChapter>[
  PythonChapter(
    id: "a4_text_methods",
    level: PythonLevel.advanced,
    title: "Text Magic",
    subtitle: "String methods that do the work",
    emoji: "✂️",
    lessons: [
      PythonLesson(
        id: "a4_l1",
        title: "Changing the case",
        blocks: [
          TextBlock(
            "Text (a **string**) comes with built-in helpers called **methods**. You call them with a dot: `text.upper()`. The original text never changes — the method gives you a new one.",
          ),
          CodeBlock(
            code:
                "city = \"bhubaneswar\"\nprint(city.upper())\nprint(city.title())\nprint(city)",
            expectedOutput: "BHUBANESWAR\nBhubaneswar\nbhubaneswar\n",
          ),
          TextBlock(
            "**.lower()** makes everything small, **.capitalize()** only the first letter big, and **.title()** every word.",
          ),
          CodeBlock(
            code:
                "s = \"hELLO wORLD\"\nprint(s.lower())\nprint(s.capitalize())\nprint(s.title())",
            expectedOutput: "hello world\nHello world\nHello World\n",
          ),
          ChallengeBlock(
            prompt: "Print your name in capital letters.",
            starterCode: "name = \"asha\"\nprint(name)",
            expectedOutput: "ASHA\n",
            hint: "Add .upper() after the variable name.",
          ),
        ],
      ),
      PythonLesson(
        id: "a4_l2",
        title: "Cleaning text",
        blocks: [
          TextBlock(
            "**.strip()** removes extra spaces from both ends — perfect for cleaning what a user types. **.replace(old, new)** swaps one piece of text for another.",
          ),
          CodeBlock(
            code:
                "raw = \"   Odisha   \"\nprint(\"[\" + raw + \"]\")\nprint(\"[\" + raw.strip() + \"]\")",
            expectedOutput: "[   Odisha   ]\n[Odisha]\n",
          ),
          CodeBlock(
            code:
                "line = \"I like cats\"\nprint(line.replace(\"cats\", \"dogs\"))\nprint(\"banana\".replace(\"a\", \"o\"))",
            expectedOutput: "I like dogs\nbonono\n",
          ),
          ChallengeBlock(
            prompt: "Replace every space in the sentence with a dash (-).",
            starterCode: "sentence = \"learn python today\"\nprint(sentence)",
            expectedOutput: "learn-python-today\n",
            hint: "Use .replace(\" \", \"-\").",
          ),
        ],
      ),
      PythonLesson(
        id: "a4_l3",
        title: "Split and join",
        blocks: [
          TextBlock(
            "**.split()** cuts text into a list of words. **\" \".join(list)** does the opposite: it glues a list of words back into text, with the text before the dot placed between them.",
          ),
          CodeBlock(
            code:
                "sentence = \"red green blue\"\ncolours = sentence.split()\nprint(colours)\nprint(len(colours))",
            expectedOutput: "['red', 'green', 'blue']\n3\n",
          ),
          CodeBlock(
            code:
                "print(\"10,20,30\".split(\",\"))\nwords = [\"Jai\", \"Hind\"]\nprint(\" \".join(words))\nprint(\"-\".join(words))",
            expectedOutput: "['10', '20', '30']\nJai Hind\nJai-Hind\n",
          ),
          TextBlock(
            "**.join()** only works on a list of text. If you have numbers, turn them into text with `str()` first.",
          ),
          ChallengeBlock(
            prompt: "Count how many words are in the sentence.",
            starterCode:
                "sentence = \"we love learning python\"\nprint(sentence)",
            expectedOutput: "4\n",
            hint: "Split the sentence, then use len().",
          ),
        ],
      ),
      PythonLesson(
        id: "a4_l4",
        title: "Searching and slicing",
        blocks: [
          TextBlock(
            "**.find()** tells you where some text starts (or `-1` if it is missing). **.count()** counts how many times it appears. **.startswith()** and **.endswith()** answer True or False.",
          ),
          CodeBlock(
            code:
                "w = \"banana\"\nprint(w.find(\"nan\"))\nprint(w.find(\"z\"))\nprint(w.count(\"a\"))\nprint(w.startswith(\"ban\"))\nprint(w.endswith(\"x\"))",
            expectedOutput: "2\n-1\n3\nTrue\nFalse\n",
          ),
          TextBlock(
            "A **slice** `text[a:b]` picks letters from position `a` up to (but not including) `b`. Leave one out to go to the start or end.",
          ),
          CodeBlock(
            code:
                "word = \"Vidyakalp\"\nprint(word[0:4])\nprint(word[:4])\nprint(word[4:])\nprint(word[-2:])",
            expectedOutput: "Vidy\nVidy\nakalp\nlp\n",
          ),
          ChallengeBlock(
            prompt: "Print the first three letters of the word.",
            starterCode: "word = \"Odisha\"\nprint(word)",
            expectedOutput: "Odi\n",
            hint: "Slice from the start up to position 3: word[:3].",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which method makes text all capital letters?",
        options: [".big()", ".upper()", ".title()", ".caps()"],
        correctIndex: 1,
        explanation: ".upper() returns the text in capitals.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "print(\"hello\".upper())",
        options: ["hello", "HELLO", "Hello", "HELLO!"],
        correctIndex: 1,
        explanation: "upper() makes every letter a capital.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "print(\"a-b-c\".split(\"-\"))",
        options: ["['a-b-c']", "a b c", "['a', 'b', 'c']", "['a', 'b']"],
        correctIndex: 2,
        explanation:
            "split(\"-\") cuts the text at every dash and returns a list.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What does \"  hi  \".strip() give?",
        options: ["\"hi\"", "\"  hi\"", "\"hi  \"", "\"  hi  \""],
        correctIndex: 0,
        explanation: "strip() removes spaces from both ends.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "word = \"python\"\nprint(word[1:4])",
        options: ["pyt", "ytho", "yth", "tho"],
        correctIndex: 2,
        explanation:
            "Positions 1, 2 and 3: y, t, h. The slice stops before position 4.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "print(\", \".join([\"a\", \"b\", \"c\"]))",
        options: ["abc", "a b c", "a,b,c", "a, b, c"],
        correctIndex: 3,
        explanation: "join() puts the text before the dot between the items.",
      ),
    ],
  ),

  PythonChapter(
    id: "a5_dicts",
    level: PythonLevel.advanced,
    title: "Dictionaries & Tuples",
    subtitle: "Look things up by name",
    emoji: "📖",
    lessons: [
      PythonLesson(
        id: "a5_l1",
        title: "What is a dictionary?",
        blocks: [
          TextBlock(
            "A **dictionary** stores **key: value** pairs inside curly brackets `{ }`. Like a real dictionary, you look something up by its key and get back its value.",
          ),
          CodeBlock(
            code:
                "marks = {\"Asha\": 82, \"Ravi\": 74, \"Meera\": 91}\nprint(marks)\nprint(marks[\"Meera\"])\nprint(len(marks))",
            expectedOutput: "{'Asha': 82, 'Ravi': 74, 'Meera': 91}\n91\n3\n",
          ),
          TextBlock(
            "Add or change a pair by assigning to a key. Check whether a key exists with `in`.",
          ),
          CodeBlock(
            code:
                "marks = {\"Asha\": 82}\nmarks[\"Ravi\"] = 74\nmarks[\"Asha\"] = 85\nprint(marks)\nprint(\"Ravi\" in marks)\nprint(\"Zoya\" in marks)",
            expectedOutput: "{'Asha': 85, 'Ravi': 74}\nTrue\nFalse\n",
          ),
          ChallengeBlock(
            prompt: "Add a new student, Dev, with 68 marks.",
            starterCode: "marks = {\"Asha\": 82, \"Ravi\": 74}\nprint(marks)",
            expectedOutput: "{'Asha': 82, 'Ravi': 74, 'Dev': 68}\n",
            hint: "Write marks[\"Dev\"] = 68 before the print.",
          ),
        ],
      ),
      PythonLesson(
        id: "a5_l2",
        title: "Looping over a dictionary",
        blocks: [
          TextBlock(
            "A `for` loop over a dictionary goes through its **keys**. `.items()` gives you the key *and* the value together.",
          ),
          CodeBlock(
            code:
                "prices = {\"tea\": 10, \"samosa\": 15}\nfor item in prices:\n    print(item)\nfor item, cost in prices.items():\n    print(f\"{item} costs Rs {cost}\")",
            expectedOutput:
                "tea\nsamosa\ntea costs Rs 10\nsamosa costs Rs 15\n",
          ),
          TextBlock(
            "`.get(key, fallback)` is a safe lookup: it gives the fallback instead of an error when the key is missing. `.keys()` and `.values()` list just one side.",
          ),
          CodeBlock(
            code:
                "prices = {\"tea\": 10, \"samosa\": 15}\nprint(prices.get(\"tea\", 0))\nprint(prices.get(\"juice\", 0))\nprint(list(prices.keys()))\nprint(list(prices.values()))\nprint(sum(prices.values()))",
            expectedOutput: "10\n0\n['tea', 'samosa']\n[10, 15]\n25\n",
          ),
          ChallengeBlock(
            prompt: "Print the total of all prices.",
            starterCode:
                "prices = {\"pen\": 5, \"book\": 40, \"bag\": 300}\nprint(prices)",
            expectedOutput: "345\n",
            hint: "Add up the values with sum(prices.values()).",
          ),
        ],
      ),
      PythonLesson(
        id: "a5_l3",
        title: "Counting with dictionaries",
        blocks: [
          TextBlock(
            "Dictionaries are great at **counting**. Keep a counter for each thing you see: add 1 if you have seen it, or start it at 1 if not.",
          ),
          CodeBlock(
            code:
                "text = \"mississippi\"\ncount = {}\nfor letter in text:\n    if letter in count:\n        count[letter] += 1\n    else:\n        count[letter] = 1\nprint(count)",
            expectedOutput: "{'m': 1, 'i': 4, 's': 4, 'p': 2}\n",
          ),
          TextBlock(
            "A shortcut with `.get()`: `count.get(letter, 0) + 1` means *the old count, or 0 if new, plus one*.",
          ),
          CodeBlock(
            code:
                "votes = [\"red\", \"blue\", \"red\", \"red\", \"blue\"]\ntally = {}\nfor v in votes:\n    tally[v] = tally.get(v, 0) + 1\nprint(tally)",
            expectedOutput: "{'red': 3, 'blue': 2}\n",
          ),
          ChallengeBlock(
            prompt: "Count how many times each fruit appears.",
            starterCode:
                "fruits = [\"mango\", \"apple\", \"mango\", \"kiwi\", \"mango\"]\ncount = {}\nprint(count)",
            expectedOutput: "{'mango': 3, 'apple': 1, 'kiwi': 1}\n",
            hint: "Loop over fruits and use count[f] = count.get(f, 0) + 1.",
          ),
        ],
      ),
      PythonLesson(
        id: "a5_l4",
        title: "Tuples",
        blocks: [
          TextBlock(
            "A **tuple** is like a list that can never change. It uses round brackets `( )`. Use one for things that belong together, like a point on a map.",
          ),
          CodeBlock(
            code:
                "point = (3, 7)\nprint(point)\nprint(point[0])\nprint(len(point))",
            expectedOutput: "(3, 7)\n3\n2\n",
          ),
          TextBlock(
            "You can **unpack** a tuple into separate names. A function can also *return* several values as a tuple.",
          ),
          CodeBlock(
            code:
                "x, y = (3, 7)\nprint(x + y)\n\ndef min_max(nums):\n    return min(nums), max(nums)\n\nlow, high = min_max([4, 9, 2, 7])\nprint(low, high)",
            expectedOutput: "10\n2 9\n",
          ),
          ChallengeBlock(
            prompt: "Swap the two values so a is 2 and b is 1.",
            starterCode: "a = 1\nb = 2\nprint(a, b)",
            expectedOutput: "2 1\n",
            hint: "Try a, b = b, a before the print.",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which brackets make a dictionary?",
        options: ["[ ]", "( )", "{ }", "< >"],
        correctIndex: 2,
        explanation: "Dictionaries use curly brackets: {key: value}.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "d = {\"a\": 1, \"b\": 2}\nprint(d[\"b\"])",
        options: ["1", "2", "a", "b"],
        correctIndex: 1,
        explanation: "Looking up the key \"b\" gives its value, 2.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "d = {\"x\": 5}\nprint(d.get(\"y\", 0))",
        options: ["0", "5", "None", "y"],
        correctIndex: 0,
        explanation: "The key y is missing, so get() returns the fallback 0.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "d = {}\nd[\"k\"] = 1\nd[\"k\"] += 4\nprint(d[\"k\"])",
        options: ["5", "1", "4", "14"],
        correctIndex: 0,
        explanation: "k starts at 1, then 4 is added: 5.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "t = (10, 20, 30)\nprint(t[1])",
        options: ["10", "20", "30", "0"],
        correctIndex: 1,
        explanation: "Positions start at 0, so t[1] is the second item, 20.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What is the difference between a tuple and a list?",
        options: [
          "Tuples are faster to type",
          "A tuple cannot be changed after it is made",
          "Tuples hold only numbers",
          "There is no difference",
        ],
        correctIndex: 1,
        explanation: "Tuples are fixed; lists can grow and change.",
      ),
    ],
  ),

  PythonChapter(
    id: "a6_nested_loops",
    level: PythonLevel.advanced,
    title: "Loops Inside Loops",
    subtitle: "Grids, patterns and tables",
    emoji: "🔁",
    lessons: [
      PythonLesson(
        id: "a6_l1",
        title: "A loop in a loop",
        blocks: [
          TextBlock(
            "You can put one loop **inside** another. For every step of the outer loop, the inner loop runs all the way through.",
          ),
          CodeBlock(
            code:
                "for i in range(3):\n    for j in range(2):\n        print(i, j)",
            expectedOutput: "0 0\n0 1\n1 0\n1 1\n2 0\n2 1\n",
          ),
          TextBlock(
            "Think of a clock: the minute hand (inner) goes all the way round before the hour hand (outer) moves one step.",
          ),
          ChallengeBlock(
            prompt: "Print every pair (row, col) for 2 rows and 3 columns.",
            starterCode: "for row in range(2):\n    print(row)",
            expectedOutput: "0 0\n0 1\n0 2\n1 0\n1 1\n1 2\n",
            hint: "Add a second loop for col inside the first one.",
          ),
        ],
      ),
      PythonLesson(
        id: "a6_l2",
        title: "Drawing grids",
        blocks: [
          TextBlock(
            "`print(..., end=\"\")` stays on the same line. Use it in the inner loop, then a plain `print()` after it to move to the next row.",
          ),
          CodeBlock(
            code:
                "for row in range(3):\n    for col in range(4):\n        print(\"*\", end=\" \")\n    print()",
            expectedOutput: "* * * * \n* * * * \n* * * * \n",
          ),
          ChallengeBlock(
            prompt: "Draw a grid of 4 rows and 5 columns using #.",
            starterCode:
                "for row in range(2):\n    for col in range(2):\n        print(\"#\", end=\" \")\n    print()",
            expectedOutput: "# # # # # \n# # # # # \n# # # # # \n# # # # # \n",
            hint: "Change the two range() numbers to 4 and 5.",
          ),
        ],
      ),
      PythonLesson(
        id: "a6_l3",
        title: "Triangles",
        blocks: [
          TextBlock(
            "Let the inner loop depend on the outer one, and the shape changes. Here row 1 gets 1 star, row 2 gets 2 stars, and so on.",
          ),
          CodeBlock(
            code:
                "for i in range(1, 5):\n    for j in range(i):\n        print(\"*\", end=\"\")\n    print()",
            expectedOutput: "*\n**\n***\n****\n",
          ),
          CodeBlock(
            code:
                "for i in range(1, 5):\n    print(\" \" * (4 - i) + \"*\" * i)",
            expectedOutput: "   *\n  **\n ***\n****\n",
          ),
          ChallengeBlock(
            prompt:
                "Print a triangle that starts with 5 stars and gets shorter.",
            starterCode:
                "for i in range(1, 6):\n    for j in range(i):\n        print(\"*\", end=\"\")\n    print()",
            expectedOutput: "*****\n****\n***\n**\n*\n",
            hint: "Count the rows down: range(5, 0, -1).",
          ),
        ],
      ),
      PythonLesson(
        id: "a6_l4",
        title: "Tables and lists of lists",
        blocks: [
          TextBlock(
            "Nested loops build a whole multiplication table in a few lines.",
          ),
          CodeBlock(
            code:
                "for i in range(1, 4):\n    for j in range(1, 4):\n        print(i * j, end=\"\\t\")\n    print()",
            expectedOutput: "1\t2\t3\t\n2\t4\t6\t\n3\t6\t9\t\n",
          ),
          TextBlock(
            "A list can hold other lists. The outer loop picks each inner list, the inner loop picks each item.",
          ),
          CodeBlock(
            code:
                "classes = [[\"Asha\", \"Ravi\"], [\"Meera\", \"Dev\", \"Isha\"]]\nfor group in classes:\n    for name in group:\n        print(name)\n    print(\"--\")",
            expectedOutput: "Asha\nRavi\n--\nMeera\nDev\nIsha\n--\n",
          ),
          ChallengeBlock(
            prompt: "Print the total number of students in all groups.",
            starterCode:
                "classes = [[\"Asha\", \"Ravi\"], [\"Meera\", \"Dev\", \"Isha\"]]\ntotal = 0\nprint(total)",
            expectedOutput: "5\n",
            hint: "Add len(group) to total inside one loop.",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "In nested loops, which loop runs faster (more times)?",
        options: [
          "The outer loop",
          "The inner loop",
          "Both the same",
          "Neither",
        ],
        correctIndex: 1,
        explanation:
            "The inner loop restarts for every step of the outer loop.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code:
            "count = 0\nfor i in range(3):\n    for j in range(4):\n        count += 1\nprint(count)",
        options: ["7", "12", "3", "0"],
        correctIndex: 1,
        explanation: "3 outer steps x 4 inner steps = 12.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "s = \"\"\nfor i in range(1, 4):\n    s += str(i) * i\nprint(s)",
        options: ["122333", "123", "111222333", "0"],
        correctIndex: 0,
        explanation: "1 once, 2 twice, 3 three times: 122333.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What does print(\"x\", end=\"\") do?",
        options: [
          "Prints x and moves to a new line",
          "Prints x and stays on the same line",
          "Prints nothing",
          "Raises an error",
        ],
        correctIndex: 1,
        explanation: "end=\"\" replaces the new line with nothing.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code:
            "total = 0\nfor a in range(1, 3):\n    for b in range(1, 3):\n        total += a * b\nprint(total)",
        options: ["4", "6", "0", "9"],
        correctIndex: 3,
        explanation: "1+2+2+4 = 9.",
      ),
    ],
  ),

  PythonChapter(
    id: "a7_errors",
    level: PythonLevel.advanced,
    title: "Oops! Handling Errors",
    subtitle: "try, except and staying calm",
    emoji: "🛟",
    lessons: [
      PythonLesson(
        id: "a7_l1",
        title: "When things go wrong",
        blocks: [
          TextBlock(
            "Sometimes a program hits a problem, like dividing by zero. Without help it **stops with an error**. With **try / except** you catch the problem and carry on.",
          ),
          CodeBlock(
            code:
                "try:\n    print(10 / 0)\nexcept ZeroDivisionError:\n    print(\"You cannot divide by zero!\")\nprint(\"The program keeps going.\")",
            expectedOutput:
                "You cannot divide by zero!\nThe program keeps going.\n",
          ),
          TextBlock(
            "Python runs the `try` block. If an error of the named type happens, it jumps to `except`. If nothing goes wrong, `except` is skipped.",
          ),
          ChallengeBlock(
            prompt:
                "Make the program print a friendly message instead of crashing.",
            starterCode:
                "try:\n    print(8 / 0)\nexcept ZeroDivisionError:\n    print(\"oops\")",
            hint: "Change the message inside the except block.",
          ),
        ],
      ),
      PythonLesson(
        id: "a7_l2",
        title: "Bad input",
        blocks: [
          TextBlock(
            "`int(\"abc\")` raises a **ValueError** — the text is not a number. This is the most common problem when asking users for numbers.",
          ),
          CodeBlock(
            code:
                "text = input(\"Enter your age: \")\ntry:\n    age = int(text)\n    print(\"Next year you will be\", age + 1)\nexcept ValueError:\n    print(\"That is not a number!\")",
            expectedOutput: "Enter your age: twelve\nThat is not a number!\n",
            presetInputs: ["twelve"],
          ),
          CodeBlock(
            code:
                "text = input(\"Enter your age: \")\ntry:\n    age = int(text)\n    print(\"Next year you will be\", age + 1)\nexcept ValueError:\n    print(\"That is not a number!\")",
            expectedOutput: "Enter your age: 12\nNext year you will be 13\n",
            presetInputs: ["12"],
          ),
          TextBlock(
            "Put a `try` inside a `while True:` loop to keep asking until the answer is valid, then `break`.",
          ),
          CodeBlock(
            code:
                "while True:\n    answer = input(\"Enter a number: \")\n    try:\n        n = int(answer)\n        break\n    except ValueError:\n        print(\"Try again.\")\nprint(\"Thanks, you typed\", n)",
            expectedOutput:
                "Enter a number: abc\nTry again.\nEnter a number: 4x\nTry again.\nEnter a number: 25\nThanks, you typed 25\n",
            presetInputs: ["abc", "4x", "25"],
          ),
          ChallengeBlock(
            prompt:
                "Ask for a number and print its double, or a message if it is not a number.",
            starterCode: "text = input(\"Number: \")\nprint(text)",
            expectedOutput: "Number: 8\n16\n",
            hint: "Wrap int(text) in try and catch ValueError.",
            presetInputs: ["8"],
          ),
        ],
      ),
      PythonLesson(
        id: "a7_l3",
        title: "Different errors",
        blocks: [
          TextBlock(
            "Different mistakes have different names: **ZeroDivisionError**, **ValueError**, **IndexError** (a list position that does not exist) and **KeyError** (a dictionary key that is missing).",
          ),
          CodeBlock(
            code:
                "fruits = [\"apple\", \"mango\"]\ntry:\n    print(fruits[5])\nexcept IndexError:\n    print(\"No fruit at that position\")",
            expectedOutput: "No fruit at that position\n",
          ),
          CodeBlock(
            code:
                "marks = {\"Asha\": 80}\ntry:\n    print(marks[\"Ravi\"])\nexcept KeyError:\n    print(\"Ravi is not in the list\")",
            expectedOutput: "Ravi is not in the list\n",
          ),
          TextBlock(
            "You can have several `except` blocks, or put two error names in brackets. `except Exception:` catches any ordinary error.",
          ),
          CodeBlock(
            code:
                "def safe_divide(a, b):\n    try:\n        return a / b\n    except ZeroDivisionError:\n        return \"cannot divide by zero\"\n    except TypeError:\n        return \"numbers only\"\n\nprint(safe_divide(10, 4))\nprint(safe_divide(1, 0))\nprint(safe_divide(\"a\", 2))",
            expectedOutput: "2.5\ncannot divide by zero\nnumbers only\n",
          ),
          ChallengeBlock(
            prompt:
                "Return \"no such student\" when the name is not in the dictionary.",
            starterCode:
                "marks = {\"Asha\": 80, \"Ravi\": 72}\nname = \"Dev\"\nprint(marks[\"Asha\"])",
            expectedOutput: "no such student\n",
            hint: "Use try with marks[name] and catch KeyError.",
          ),
        ],
      ),
      PythonLesson(
        id: "a7_l4",
        title: "raise, as and finally",
        blocks: [
          TextBlock(
            "Use **raise** to make your own error when something is not allowed. `except ... as e` gives you the error message so you can show it.",
          ),
          CodeBlock(
            code:
                "def set_age(age):\n    if age < 0:\n        raise ValueError(\"age cannot be negative\")\n    return age\n\ntry:\n    set_age(-5)\nexcept ValueError as e:\n    print(\"Problem:\", e)",
            expectedOutput: "Problem: age cannot be negative\n",
          ),
          TextBlock(
            "A **finally** block always runs at the end, whether or not an error happened — good for tidying up.",
          ),
          CodeBlock(
            code:
                "try:\n    print(int(\"7\") + 1)\nexcept ValueError:\n    print(\"bad\")\nfinally:\n    print(\"done\")",
            expectedOutput: "8\ndone\n",
          ),
          ChallengeBlock(
            prompt: "Print the error message when you divide by zero.",
            starterCode:
                "try:\n    print(5 / 0)\nexcept ZeroDivisionError:\n    print(\"error\")",
            expectedOutput: "division by zero\n",
            hint: "Catch it with `as e` and print(e).",
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which keyword starts a block that might fail?",
        options: ["catch", "try", "except", "test"],
        correctIndex: 1,
        explanation: "Code that might fail goes under try.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code:
            "try:\n    print(int(\"x\"))\nexcept ValueError:\n    print(\"bad\")",
        options: ["bad", "x", "0", "error"],
        correctIndex: 0,
        explanation:
            "int(\"x\") raises ValueError, so the except block prints bad.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code:
            "try:\n    n = 4 / 2\nexcept ZeroDivisionError:\n    n = 0\nprint(n)",
        options: ["0", "2", "2.0", "None"],
        correctIndex: 2,
        explanation: "No error happens, so n is 4 / 2 = 2.0.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which error happens for a list position that does not exist?",
        options: ["ValueError", "KeyError", "IndexError", "NameError"],
        correctIndex: 2,
        explanation: "IndexError is for positions outside a list.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code:
            "try:\n    d = {\"a\": 1}\n    print(d[\"b\"])\nexcept KeyError:\n    print(\"missing\")",
        options: ["missing", "1", "b", "error"],
        correctIndex: 0,
        explanation:
            "The key b is missing, so the except block prints missing.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "When does a finally block run?",
        options: [
          "Only when there is an error",
          "Only when there is no error",
          "Always, error or not",
          "Never",
        ],
        correctIndex: 2,
        explanation: "finally runs at the end whatever happened.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code:
            "items = [1, 2, 3]\ntry:\n    print(items[3])\nexcept IndexError as e:\n    print(e)",
        options: ["3", "index error", "list index out of range", "0"],
        correctIndex: 2,
        explanation:
            "Position 3 does not exist, and the message is: list index out of range.",
      ),
    ],
  ),

  PythonChapter(
    id: "a8_random",
    level: PythonLevel.advanced,
    title: "Random Games",
    subtitle: "Dice, coins and surprises",
    emoji: "🎲",
    lessons: [
      PythonLesson(
        id: "a8_l1",
        title: "Rolling a dice",
        blocks: [
          TextBlock(
            "The **random** module lets your program make surprises. Start with `import random`. **random.randint(a, b)** picks a whole number from a to b — both included.",
          ),
          CodeBlock(
            code:
                "import random\nrandom.seed(7)\nroll = random.randint(1, 6)\nprint(\"You rolled\", roll)",
            expectedOutput: "You rolled 3\n",
          ),
          TextBlock(
            "**random.seed(n)** makes the \"random\" numbers repeat in the same order every time — useful when you test your game. Remove it and each run is different.",
          ),
          CodeBlock(
            code:
                "import random\nrandom.seed(7)\nfor i in range(5):\n    print(random.randint(1, 6), end=\" \")\nprint()",
            expectedOutput: "3 2 4 6 1 \n",
          ),
          ChallengeBlock(
            prompt: "Roll the dice 3 times and print each roll.",
            starterCode:
                "import random\nrandom.seed(3)\nprint(random.randint(1, 6))",
            expectedOutput: "2\n5\n5\n",
            hint: "Use a for loop with range(3).",
          ),
        ],
      ),
      PythonLesson(
        id: "a8_l2",
        title: "Choosing and shuffling",
        blocks: [
          TextBlock(
            "**random.choice(list)** picks one item from a list. **random.shuffle(list)** mixes the list up in place.",
          ),
          CodeBlock(
            code:
                "import random\nrandom.seed(5)\nsnacks = [\"samosa\", \"jalebi\", \"chaat\"]\nprint(random.choice(snacks))\ncards = [1, 2, 3, 4, 5]\nrandom.shuffle(cards)\nprint(cards)",
            expectedOutput: "chaat\n[2, 1, 4, 5, 3]\n",
          ),
          TextBlock(
            "**random.random()** gives a decimal between 0 and 1. A coin flip is just a check on it.",
          ),
          CodeBlock(
            code:
                "import random\nrandom.seed(11)\nif random.random() < 0.5:\n    print(\"Heads\")\nelse:\n    print(\"Tails\")",
            expectedOutput: "Heads\n",
          ),
          ChallengeBlock(
            prompt: "Pick a random colour from the list.",
            starterCode:
                "import random\ncolours = [\"red\", \"green\", \"blue\"]\nprint(colours[0])",
            expectedOutput: "red\n",
            hint: "Use random.choice(colours).",
          ),
        ],
      ),
      PythonLesson(
        id: "a8_l3",
        title: "Guess the number",
        blocks: [
          TextBlock(
            "Now put it together: the computer thinks of a secret number and you guess. A loop keeps going until you get it right.",
          ),
          CodeBlock(
            code:
                "import random\nrandom.seed(4)\nsecret = random.randint(1, 10)\nattempts = 0\nwhile True:\n    guess = int(input(\"Guess (1-10): \"))\n    attempts += 1\n    if guess < secret:\n        print(\"Too low\")\n    elif guess > secret:\n        print(\"Too high\")\n    else:\n        print(f\"Correct! It took {attempts} tries.\")\n        break",
            expectedOutput:
                "Guess (1-10): 6\nToo high\nGuess (1-10): 2\nToo low\nGuess (1-10): 4\nCorrect! It took 3 tries.\n",
            presetInputs: ["6", "2", "4"],
          ),
          ChallengeBlock(
            prompt: "Make the game say \"Great!\" when the guess is correct.",
            starterCode:
                "import random\nrandom.seed(4)\nsecret = random.randint(1, 10)\nguess = int(input(\"Guess: \"))\nif guess == secret:\n    print(\"Correct!\")\nelse:\n    print(\"Wrong\")",
            hint: "Change the text inside the print for the correct case.",
            presetInputs: ["3"],
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which line must come before using random?",
        options: ["include random", "import random", "use random", "random()"],
        correctIndex: 1,
        explanation: "You must import random first.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code:
            "import random\nrandom.seed(1)\nn = random.randint(5, 5)\nprint(n)",
        options: ["1", "5", "0", "10"],
        correctIndex: 1,
        explanation: "randint(5, 5) can only pick 5.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "What does random.seed(10) do?",
        options: [
          "Picks the number 10",
          "Makes the random numbers repeat in the same order",
          "Stops the program",
          "Shuffles a list",
        ],
        correctIndex: 1,
        explanation: "A seed makes the sequence repeatable.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code: "import random\nitems = [\"a\"]\nprint(random.choice(items))",
        options: ["b", "items", "['a']", "a"],
        correctIndex: 3,
        explanation: "A list with one item can only give that item: a.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Which call gives a decimal between 0 and 1?",
        options: [
          "random.randint(0, 1)",
          "random.random()",
          "random.choice(1)",
          "random.seed()",
        ],
        correctIndex: 1,
        explanation: "random.random() returns a float from 0 up to 1.",
      ),
    ],
  ),

  PythonChapter(
    id: "a9_projects2",
    level: PythonLevel.advanced,
    title: "Mini Projects 2",
    subtitle: "Quiz, report card, calculator, rock-paper-scissors",
    emoji: "🏆",
    lessons: [
      PythonLesson(
        id: "a9_l1",
        title: "Quiz game",
        blocks: [
          TextBlock(
            "A dictionary of questions and answers, a loop to ask them, and a score to keep. `.lower().strip()` makes answers forgiving about capitals and spaces.",
          ),
          CodeBlock(
            code:
                "questions = {\n    \"Capital of Odisha?\": \"bhubaneswar\",\n    \"How many days in a week?\": \"7\",\n    \"Which planet is red?\": \"mars\",\n}\nscore = 0\nfor question, answer in questions.items():\n    reply = input(question + \" \").lower().strip()\n    if reply == answer:\n        print(\"Correct!\")\n        score += 1\n    else:\n        print(\"Wrong. It is\", answer)\nprint(f\"Score: {score}/{len(questions)}\")",
            expectedOutput:
                "Capital of Odisha? Bhubaneswar\nCorrect!\nHow many days in a week? 7\nCorrect!\nWhich planet is red? venus\nWrong. It is mars\nScore: 2/3\n",
            presetInputs: ["Bhubaneswar", "7", "venus"],
          ),
          ChallengeBlock(
            prompt: "Add one more question of your own to the dictionary.",
            starterCode:
                "questions = {\n    \"Capital of Odisha?\": \"bhubaneswar\",\n    \"How many days in a week?\": \"7\",\n    \"Which planet is red?\": \"mars\",\n    # add your question here\n}\nscore = 0\nfor question, answer in questions.items():\n    reply = input(question + \" \").lower().strip()\n    if reply == answer:\n        print(\"Correct!\")\n        score += 1\n    else:\n        print(\"Wrong. It is\", answer)\nprint(f\"Score: {score}/{len(questions)}\")",
            hint: "Add a line like \"2 + 2?\": \"4\", to the dictionary.",
            presetInputs: ["Bhubaneswar", "7", "mars"],
          ),
        ],
      ),
      PythonLesson(
        id: "a9_l2",
        title: "Report card",
        blocks: [
          TextBlock(
            "Loop over subjects to collect marks into a dictionary, then use `sum()`, an average, and `if / elif / else` for the grade. The format `:.1f` shows one decimal; `:<10` and `:>5` line up columns.",
          ),
          CodeBlock(
            code:
                "subjects = [\"Maths\", \"Science\", \"English\"]\nmarks = {}\nfor subject in subjects:\n    marks[subject] = int(input(subject + \" marks: \"))\n\ntotal = sum(marks.values())\naverage = total / len(marks)\nprint(\"--- Report Card ---\")\nfor subject, m in marks.items():\n    print(f\"{subject:<10}{m:>5}\")\nprint(f\"Total: {total}\")\nprint(f\"Average: {average:.1f}\")\nif average >= 75:\n    print(\"Grade: A\")\nelif average >= 50:\n    print(\"Grade: B\")\nelse:\n    print(\"Grade: C\")",
            expectedOutput:
                "Maths marks: 82\nScience marks: 74\nEnglish marks: 91\n--- Report Card ---\nMaths        82\nScience      74\nEnglish      91\nTotal: 247\nAverage: 82.3\nGrade: A\n",
            presetInputs: ["82", "74", "91"],
          ),
          ChallengeBlock(
            prompt:
                "Change the program so a pass mark of 40 is used for a C grade and below 40 prints \"Fail\".",
            starterCode:
                "subjects = [\"Maths\", \"Science\", \"English\"]\nmarks = {}\nfor subject in subjects:\n    marks[subject] = int(input(subject + \" marks: \"))\n\ntotal = sum(marks.values())\naverage = total / len(marks)\nprint(\"--- Report Card ---\")\nfor subject, m in marks.items():\n    print(f\"{subject:<10}{m:>5}\")\nprint(f\"Total: {total}\")\nprint(f\"Average: {average:.1f}\")\nif average >= 75:\n    print(\"Grade: A\")\nelif average >= 50:\n    print(\"Grade: B\")\nelse:\n    print(\"Grade: C\")",
            hint: "Add one more elif and an else that prints Fail.",
            presetInputs: ["35", "30", "42"],
          ),
        ],
      ),
      PythonLesson(
        id: "a9_l3",
        title: "Calculator",
        blocks: [
          TextBlock(
            "A function does the maths and **try / except** protects against bad input and dividing by zero. Run it with different inputs to see each branch.",
          ),
          CodeBlock(
            code:
                "def calculate(a, op, b):\n    if op == \"+\":\n        return a + b\n    elif op == \"-\":\n        return a - b\n    elif op == \"*\":\n        return a * b\n    elif op == \"/\":\n        return a / b\n    return \"unknown operator\"\n\ntry:\n    x = float(input(\"First number: \"))\n    op = input(\"Operator (+ - * /): \")\n    y = float(input(\"Second number: \"))\n    print(\"Answer:\", calculate(x, op, y))\nexcept ValueError:\n    print(\"Please type numbers only.\")\nexcept ZeroDivisionError:\n    print(\"Cannot divide by zero.\")",
            expectedOutput:
                "First number: 12\nOperator (+ - * /): *\nSecond number: 4\nAnswer: 48.0\n",
            presetInputs: ["12", "*", "4"],
          ),
          CodeBlock(
            code:
                "def calculate(a, op, b):\n    if op == \"+\":\n        return a + b\n    elif op == \"-\":\n        return a - b\n    elif op == \"*\":\n        return a * b\n    elif op == \"/\":\n        return a / b\n    return \"unknown operator\"\n\ntry:\n    x = float(input(\"First number: \"))\n    op = input(\"Operator (+ - * /): \")\n    y = float(input(\"Second number: \"))\n    print(\"Answer:\", calculate(x, op, y))\nexcept ValueError:\n    print(\"Please type numbers only.\")\nexcept ZeroDivisionError:\n    print(\"Cannot divide by zero.\")",
            expectedOutput:
                "First number: 5\nOperator (+ - * /): /\nSecond number: 0\nCannot divide by zero.\n",
            presetInputs: ["5", "/", "0"],
          ),
          CodeBlock(
            code:
                "def calculate(a, op, b):\n    if op == \"+\":\n        return a + b\n    elif op == \"-\":\n        return a - b\n    elif op == \"*\":\n        return a * b\n    elif op == \"/\":\n        return a / b\n    return \"unknown operator\"\n\ntry:\n    x = float(input(\"First number: \"))\n    op = input(\"Operator (+ - * /): \")\n    y = float(input(\"Second number: \"))\n    print(\"Answer:\", calculate(x, op, y))\nexcept ValueError:\n    print(\"Please type numbers only.\")\nexcept ZeroDivisionError:\n    print(\"Cannot divide by zero.\")",
            expectedOutput: "First number: five\nPlease type numbers only.\n",
            presetInputs: ["five", "+", "2"],
          ),
          ChallengeBlock(
            prompt:
                "Add a new operator ** for powers to the calculate() function.",
            starterCode:
                "def calculate(a, op, b):\n    if op == \"+\":\n        return a + b\n    elif op == \"-\":\n        return a - b\n    elif op == \"*\":\n        return a * b\n    elif op == \"/\":\n        return a / b\n    return \"unknown operator\"\n\ntry:\n    x = float(input(\"First number: \"))\n    op = input(\"Operator (+ - * /): \")\n    y = float(input(\"Second number: \"))\n    print(\"Answer:\", calculate(x, op, y))\nexcept ValueError:\n    print(\"Please type numbers only.\")\nexcept ZeroDivisionError:\n    print(\"Cannot divide by zero.\")",
            hint: "Add another elif op == \"**\": return a ** b.",
            presetInputs: ["2", "**", "3"],
          ),
        ],
      ),
      PythonLesson(
        id: "a9_l4",
        title: "Rock, paper, scissors",
        blocks: [
          TextBlock(
            "A dictionary (`beats`) says what each choice defeats, so no long chains of `if` are needed. The seed makes the computer pick the same thing while you test.",
          ),
          CodeBlock(
            code:
                "import random\nrandom.seed(8)\nchoices = [\"rock\", \"paper\", \"scissors\"]\nbeats = {\"rock\": \"scissors\", \"paper\": \"rock\", \"scissors\": \"paper\"}\nyou = input(\"rock, paper or scissors? \").lower()\ncomputer = random.choice(choices)\nprint(\"Computer chose\", computer)\nif you not in choices:\n    print(\"That is not a valid choice.\")\nelif you == computer:\n    print(\"It is a tie!\")\nelif beats[you] == computer:\n    print(\"You win!\")\nelse:\n    print(\"Computer wins!\")",
            expectedOutput:
                "rock, paper or scissors? rock\nComputer chose rock\nIt is a tie!\n",
            presetInputs: ["rock"],
          ),
          CodeBlock(
            code:
                "import random\nrandom.seed(8)\nchoices = [\"rock\", \"paper\", \"scissors\"]\nbeats = {\"rock\": \"scissors\", \"paper\": \"rock\", \"scissors\": \"paper\"}\nyou = input(\"rock, paper or scissors? \").lower()\ncomputer = random.choice(choices)\nprint(\"Computer chose\", computer)\nif you not in choices:\n    print(\"That is not a valid choice.\")\nelif you == computer:\n    print(\"It is a tie!\")\nelif beats[you] == computer:\n    print(\"You win!\")\nelse:\n    print(\"Computer wins!\")",
            expectedOutput:
                "rock, paper or scissors? paper\nComputer chose rock\nYou win!\n",
            presetInputs: ["paper"],
          ),
          ChallengeBlock(
            prompt: "Count the player's wins over three rounds.",
            starterCode:
                "import random\nrandom.seed(8)\nchoices = [\"rock\", \"paper\", \"scissors\"]\nbeats = {\"rock\": \"scissors\", \"paper\": \"rock\", \"scissors\": \"paper\"}\nyou = input(\"rock, paper or scissors? \").lower()\ncomputer = random.choice(choices)\nprint(\"Computer chose\", computer)\nif you not in choices:\n    print(\"That is not a valid choice.\")\nelif you == computer:\n    print(\"It is a tie!\")\nelif beats[you] == computer:\n    print(\"You win!\")\nelse:\n    print(\"Computer wins!\")",
            hint:
                "Wrap the game in a for loop and add 1 to a wins variable when you win.",
            presetInputs: ["rock"],
          ),
        ],
      ),
    ],
    quiz: [
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "Why does the quiz game call .lower() on the reply?",
        options: [
          "To make it shorter",
          "So capital letters do not matter",
          "To translate it",
          "To save it",
        ],
        correctIndex: 1,
        explanation: "lower() makes the comparison ignore capitals.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code:
            "answers = {\"a\": 1, \"b\": 2}\ntotal = 0\nfor k in answers:\n    total += answers[k]\nprint(total)",
        options: ["1", "3", "2", "0"],
        correctIndex: 1,
        explanation: "1 + 2 = 3.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code:
            "beats = {\"rock\": \"scissors\"}\nprint(beats[\"rock\"] == \"scissors\")",
        options: ["False", "rock", "scissors", "True"],
        correctIndex: 3,
        explanation: "rock beats scissors, so the comparison is True.",
      ),
      PyQuizQuestion(
        type: PyQuizType.mcq,
        prompt: "In the calculator, why use try / except?",
        options: [
          "To make it faster",
          "To handle bad input and divide-by-zero",
          "To add colours",
          "To import random",
        ],
        correctIndex: 1,
        explanation:
            "try / except catches errors like ValueError and ZeroDivisionError.",
      ),
      PyQuizQuestion(
        type: PyQuizType.predictOutput,
        prompt: "What prints?",
        code:
            "marks = {\"m\": 80, \"s\": 70}\nprint(sum(marks.values()) / len(marks))",
        options: ["150", "75", "75.0", "70.0"],
        correctIndex: 2,
        explanation: "150 / 2 = 75.0, so the answer is 75.0.",
      ),
    ],
  ),
];
