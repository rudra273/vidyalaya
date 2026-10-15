import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/programming/interpreter/py_runner.dart';

// ─── Differential tests ───────────────────────────────────────────────────────
//
// Each program was run through real CPython 3 when this file was written; the
// expected output below is what CPython printed. The course interpreter must
// print exactly the same, including seeded `random` values.

const _cases = <(String, String)>[
  (
    "name = \"  hello World  \"\nprint(name.strip())\nprint(name.upper())\nprint(name.lower())\nprint(name.strip().title())\nprint(name.replace(\"l\", \"L\"))\nprint(len(name))",
    "hello World\n  HELLO WORLD  \n  hello world  \nHello World\n  heLLo WorLd  \n15\n",
  ),
  (
    "w = \"banana\"\nprint(w.count(\"a\"))\nprint(w.find(\"n\"))\nprint(w.find(\"z\"))\nprint(w.startswith(\"ba\"))\nprint(w.endswith(\"x\"))\nprint(w[1:4])\nprint(w[:2])\nprint(w[3:])\nprint(w[-3:])",
    "3\n2\n-1\nTrue\nFalse\nana\nba\nana\nana\n",
  ),
  (
    "words = \"the quick brown fox\".split()\nprint(words)\nprint(\"-\".join(words))\nprint(\"a,b,c\".split(\",\"))\nprint(\" \".join([\"x\",\"y\"]))",
    "['the', 'quick', 'brown', 'fox']\nthe-quick-brown-fox\n['a', 'b', 'c']\nx y\n",
  ),
  (
    "print(\"42\".isdigit())\nprint(\"4x\".isdigit())\nprint(\"abc\".isalpha())\nprint(\"hello\".capitalize())\nprint(\"ABC\".islower())",
    "True\nFalse\nTrue\nHello\nFalse\n",
  ),
  (
    "marks = {\"Asha\": 80, \"Ravi\": 72}\nprint(marks)\nprint(marks[\"Asha\"])\nmarks[\"Meera\"] = 91\nprint(len(marks))\nprint(\"Ravi\" in marks)\nprint(\"Zoya\" in marks)\nprint(\"Zoya\" not in marks)",
    "{'Asha': 80, 'Ravi': 72}\n80\n3\nTrue\nFalse\nTrue\n",
  ),
  (
    "d = {\"a\": 1, \"b\": 2, \"c\": 3}\nfor k in d:\n    print(k, d[k])\nfor k, v in d.items():\n    print(f\"{k}={v}\")\nprint(list(d.keys()))\nprint(list(d.values()))\nprint(d.get(\"z\"))\nprint(d.get(\"z\", 0))",
    "a 1\nb 2\nc 3\na=1\nb=2\nc=3\n['a', 'b', 'c']\n[1, 2, 3]\nNone\n0\n",
  ),
  (
    "d = {\"x\": 1}\nd[\"x\"] += 5\nd[\"y\"] = 2\nprint(d)\nprint(d.pop(\"x\"))\nprint(d)\nprint(d.keys())\nprint(d.items())",
    "{'x': 6, 'y': 2}\n6\n{'y': 2}\ndict_keys(['y'])\ndict_items([('y', 2)])\n",
  ),
  (
    "count = {}\nfor ch in \"hello\":\n    if ch in count:\n        count[ch] += 1\n    else:\n        count[ch] = 1\nprint(count)",
    "{'h': 1, 'e': 1, 'l': 2, 'o': 1}\n",
  ),
  (
    "p = (3, 4)\nprint(p)\nprint(p[0])\nprint(len(p))\nx, y = p\nprint(x + y)\nprint((1,))\nprint(())\nt = (1, 2) + (3,)\nprint(t)",
    "(3, 4)\n3\n2\n7\n(1,)\n()\n(1, 2, 3)\n",
  ),
  (
    "a, b = 1, 2\na, b = b, a\nprint(a, b)\ndef minmax(xs):\n    return min(xs), max(xs)\nlo, hi = minmax([4, 9, 2])\nprint(lo, hi)\nprint(minmax([1, 5]))",
    "2 1\n2 9\n(1, 5)\n",
  ),
  (
    "for i, name in enumerate([\"a\", \"b\", \"c\"]):\n    print(i, name)\nfor x, y in zip([1,2,3], [\"p\",\"q\",\"r\"]):\n    print(x, y)",
    "0 a\n1 b\n2 c\n1 p\n2 q\n3 r\n",
  ),
  (
    "try:\n    print(10 / 0)\nexcept ZeroDivisionError:\n    print(\"no zero\")\nprint(\"after\")",
    "no zero\nafter\n",
  ),
  (
    "try:\n    n = int(\"abc\")\nexcept ValueError:\n    print(\"not a number\")",
    "not a number\n",
  ),
  (
    "try:\n    n = int(\"abc\")\nexcept ValueError as e:\n    print(e)\ntry:\n    x = 1 / 0\nexcept ZeroDivisionError as e:\n    print(e)",
    "invalid literal for int() with base 10: 'abc'\ndivision by zero\n",
  ),
  (
    "items = [1, 2]\ntry:\n    print(items[5])\nexcept IndexError as e:\n    print(\"oops\", e)\nd = {\"a\": 1}\ntry:\n    print(d[\"b\"])\nexcept KeyError as e:\n    print(\"missing\", e)",
    "oops list index out of range\nmissing 'b'\n",
  ),
  (
    "try:\n    print(undefined_name)\nexcept NameError as e:\n    print(e)",
    "name 'undefined_name' is not defined\n",
  ),
  (
    "try:\n    x = 5\n    print(x)\nexcept:\n    print(\"bad\")\nelse:\n    print(\"fine\")\nfinally:\n    print(\"done\")",
    "5\nfine\ndone\n",
  ),
  (
    "try:\n    1 / 0\nexcept (ValueError, ZeroDivisionError):\n    print(\"caught\")\nfinally:\n    print(\"cleanup\")",
    "caught\ncleanup\n",
  ),
  ("try:\n    1 / 0\nexcept Exception:\n    print(\"any\")", "any\n"),
  (
    "def check(age):\n    if age < 0:\n        raise ValueError(\"age cannot be negative\")\n    return age\ntry:\n    check(-1)\nexcept ValueError as e:\n    print(\"Error:\", e)\nprint(check(5))",
    "Error: age cannot be negative\n5\n",
  ),
  (
    "def safe_div(a, b):\n    try:\n        return a / b\n    except ZeroDivisionError:\n        return None\nprint(safe_div(6, 3))\nprint(safe_div(1, 0))",
    "2.0\nNone\n",
  ),
  (
    "while True:\n    try:\n        n = int(\"7\")\n        break\n    except ValueError:\n        print(\"again\")\nprint(n)",
    "7\n",
  ),
  (
    "import random\nrandom.seed(42)\nprint(random.randint(1, 10))\nprint(random.randint(1, 6))\nprint(random.random())",
    "2\n1\n0.7415504997598329\n",
  ),
  (
    "import random\nrandom.seed(1)\nprint(random.random())\nrandom.seed(0)\nprint(random.random())\nrandom.seed(123456789)\nprint(random.random())",
    "0.13436424411240122\n0.8444218515250481\n0.6414006161858726\n",
  ),
  (
    "import random\nrandom.seed(7)\nfor i in range(8):\n    print(random.randint(1, 100), end=\" \")\nprint()",
    "42 20 51 84 7 10 69 13 \n",
  ),
  (
    "import random\nrandom.seed(5)\nprint(random.choice([\"rock\", \"paper\", \"scissors\"]))\nprint(random.choice([\"rock\", \"paper\", \"scissors\"]))\nprint(random.choice(\"abcdef\"))",
    "scissors\npaper\nf\n",
  ),
  (
    "import random\nrandom.seed(3)\ncards = [1, 2, 3, 4, 5, 6]\nrandom.shuffle(cards)\nprint(cards)",
    "[1, 3, 4, 6, 5, 2]\n",
  ),
  (
    "import random\nrandom.seed(9)\nprint(random.randrange(10))\nprint(random.randrange(5, 15))\nprint(random.uniform(1, 2))",
    "7\n14\n1.3733119313950422\n",
  ),
  (
    "import random\nrandom.seed(2**40)\nprint(random.random())",
    "0.1036394562812375\n",
  ),
  (
    "print(\"a\", \"b\", sep=\"-\")\nprint(\"x\", end=\"\")\nprint(\"y\")\nprint(\"one\", \"two\", \"three\", sep=\"\")\nprint(1, 2, 3, sep=\", \", end=\"!\\n\")",
    "a-b\nxy\nonetwothree\n1, 2, 3!\n",
  ),
  (
    "x = 7\nprint(1 < x < 10)\nprint(1 < x < 5)\nprint(0 <= x <= 7)",
    "True\nFalse\nTrue\n",
  ),
  (
    "pi = 3.14159\nprint(f\"{pi:.2f}\")\nprint(f\"{pi:.0f}\")\nprint(f\"{42:5d}|\")\nprint(f\"{42:<5}|\")\nprint(f\"{42:>5}|\")\nprint(f\"{'hi':^6}|\")\nprint(f\"{1234567:,}\")\nprint(f\"{3.5:.1f}\")\nprint(f\"{7:03d}\")\nprint(f\"{0.256:.1%}\")",
    "3.14\n3\n   42|\n42   |\n   42|\n  hi  |\n1,234,567\n3.5\n007\n25.6%\n",
  ),
  (
    "nums = [5, 3, 8, 1]\nnums.sort()\nprint(nums)\nnums.reverse()\nprint(nums)\nprint(sorted([3, 1, 2]))\nprint(sorted([\"b\", \"a\"]))\nprint(sorted([3,1,2], reverse=True))\nnums.insert(1, 99)\nprint(nums)\nprint(nums.pop())\nprint(nums.pop(0))\nnums.remove(99)\nprint(nums)\nprint(nums.index(3))\nprint(nums.count(3))\nnums.extend([7, 7])\nprint(nums)",
    "[1, 3, 5, 8]\n[8, 5, 3, 1]\n[1, 2, 3]\n['a', 'b']\n[3, 2, 1]\n[8, 99, 5, 3, 1]\n1\n8\n[5, 3]\n1\n1\n[5, 3, 7, 7]\n",
  ),
  (
    "for i in range(3):\n    for j in range(3):\n        print(i * j, end=\" \")\n    print()",
    "0 0 0 \n0 1 2 \n0 2 4 \n",
  ),
  (
    "for i in range(1, 4):\n    for j in range(i):\n        print(\"*\", end=\"\")\n    print()",
    "*\n**\n***\n",
  ),
  (
    "table = {}\nfor i in range(1, 4):\n    table[i] = i * i\nprint(table)\ntotal = 0\nfor k in table:\n    total += table[k]\nprint(total)",
    "{1: 1, 2: 4, 3: 9}\n14\n",
  ),
  (
    "fruits = [\"apple\", \"mango\"]\nprint(\"mango\" in fruits)\nprint(\"kiwi\" not in fruits)\nprint(\"an\" in \"banana\")",
    "True\nTrue\nTrue\n",
  ),
  (
    "student = {\"name\": \"Asha\", \"marks\": [80, 90]}\nprint(student[\"marks\"][1])\nstudent[\"marks\"].append(70)\nprint(sum(student[\"marks\"]) / len(student[\"marks\"]))\nprint(student)",
    "90\n80.0\n{'name': 'Asha', 'marks': [80, 90, 70]}\n",
  ),
  ("def f(n):\n    pass\nf(1)\nprint(\"ok\")", "ok\n"),
  (
    "pairs = [(\"a\", 1), (\"b\", 2)]\nfor name, num in pairs:\n    print(name, num)\nprint(dict(pairs))\nprint(tuple([1, 2]))\nprint(list((1, 2)))\nprint(list(\"abc\"))",
    "a 1\nb 2\n{'a': 1, 'b': 2}\n(1, 2)\n[1, 2]\n['a', 'b', 'c']\n",
  ),
  (
    "print(max([1, 5, 3]), min((4, 2, 8)), sum((1, 2, 3)))\nprint(len({\"a\": 1}))\nprint(bool(0), bool(\"x\"), bool([]))",
    "5 2 6\n1\nFalse True False\n",
  ),
  (
    "a = \"5\"\nb = 3\ntry:\n    print(a + b)\nexcept TypeError:\n    print(\"type error\")",
    "type error\n",
  ),
  (
    "x = None\nr = {}\nprint(r == {}, [1,2] == [1,2], (1,2) == (1,2))\nprint({\"a\": 1} == {\"a\": 1})",
    "True True True\nTrue\n",
  ),
  (
    "menu = {\"tea\": 10, \"coffee\": 20}\ntotal = 0\nfor item in [\"tea\", \"tea\", \"coffee\"]:\n    total = total + menu[item]\nprint(f\"Total: Rs {total:.2f}\")",
    "Total: Rs 40.00\n",
  ),
  (
    "name = \"Asha\"\nprint(f\"{name:>8}|{name:<8}|{name:^8}|\")\nprint(f\"{'x' * 3}\")",
    "    Asha|Asha    |  Asha  |\nxxx\n",
  ),
];

void main() {
  for (var i = 0; i < _cases.length; i++) {
    final (src, expected) = _cases[i];
    test('program $i matches CPython', () async {
      final r = await PyRunner.run(src);
      expect(r.error, isNull, reason: 'errored: ${r.error}\n$src');
      expect(r.output, expected, reason: src);
    });
  }
}
