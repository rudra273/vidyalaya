# vidyalaya


## 🔥 High Impact (build soon)

| Feature | Why it matters |
|---------|---------------|
| **Reading Progress Tracker** | Show % completed per book, page bookmarks, "Continue from page 47" — students know where they left off |
| **Download Manager** | Show download status for each book (✓ Downloaded / ⬇ Download / 🔄 Downloading), let users delete downloaded PDFs to free space |
| **Offline Mode Banner** | Detect no internet → show "You're offline — only downloaded books available" with visual indicator |
| **Add more classes (1-10)** | Seed all Class 1–10 books from OSEPA — the data is available on their website, just needs scraping. This instantly makes the app useful to 10x more students |
| **Bookmarks** | Let students bookmark specific pages in a PDF — saves to local DB, shows in a bookmarks list |

## ⭐ Medium Impact (nice to have)

| Feature | Why it matters |
|---------|---------------|
| **Daily Study Reminder** | Local notification: "Time to study! You were reading Bigyan" — helps build habits |
| **Reading Streak** | "🔥 5 day streak!" — gamification keeps students engaged. Track days where they opened a book for >5 min |
| **Dark Mode** | Students study at night — reduces eye strain. You already have the colour system, just need a dark variant |
| **Search Books** | As more classes/boards are added, searching by title/subject becomes essential |
| **Notes & Highlights** | Take notes per book per page — "Write your doubt here". Very useful for exam prep |
| **Subject-wise Study Time** | Show weekly bar chart: "Maths - 2hrs, Science - 1.5hrs, Odia - 45min" — parents love this data |
| **Exam Countdown** | "BSE Board Exam in 47 days" — configurable countdown timer on home screen |

## 🚀 Future Vision (longer term)

| Feature | Why it matters |
|---------|---------------|
| **Multi-board Support** | Add CBSE, ICSE books — same architecture, new seed data. Your schema already supports this |
| **English Medium** | Same classes, English medium textbooks — just another `Medium` entry + books |
| **Chapter Index** | Parse PDF table of contents → show chapter list → tap to jump to page. Huge UX improvement |
| **Parent Dashboard** | Separate "Parent" mode: see child's reading time, streak, which subjects they're ignoring |
| **Share with Friends** | "Share Vidyālaya with classmates" — WhatsApp share link for organic growth |
| **Multiple Languages** | App UI in Odia, Hindi, English — very important for parent accessibility |
| **Question Papers** | Past year board exam papers as PDFs — students always search for these |
| **Study Planner** | "You have 45 days before exams, here's a daily reading plan" — AI-generated schedule |

## 💡 My top 3 recommendations for right now:

1. **Reading Progress + Bookmarks** — makes the app actually useful daily
2. **Download Manager UI** — books are big PDFs, students need control over storage
3. **Add all classes (1-10) seed data** — multiplies your user base instantly



----- 
Future plan------


---

**The Vector DB idea — how it works:**

```
PDF pages → OCR (ML Kit) → text chunks → 
embed (Gemini embeddings) → store in vector DB → 
student asks question / uploads photo → 
OCR photo → embed query → similarity search → 
retrieve relevant chunks → Gemini answers with context
```

Basically RAG — same concept as OrbitAI's Spaces but for textbooks. Answer is always grounded in the actual book content, not hallucinated.

---

**Full Feature Plan — Vidyalaya AI**

---



---

**2. Reading Habit System**
- Reading session timer (auto start/stop)
- Daily reading goal (user sets X minutes)
- Streak tracker
- Weekly reading time graph
- Per-book reading time stats

---

**3. AI Reader Features (Per Page)**
Triggered from floating AI button on reader screen:
- **Explain** — simple explanation of page content
- **Step by step** — for maths/science
- **Quiz me** — 3 MCQs from page
- **Simplify** — explain like I'm 12
- **Translate to Odia** — for complex English pages

Flow: screenshot current page → base64 → Gemini Vision API → bottom sheet response

---

**4. Homework Helper (RAG feature)**
- Student types a question OR uploads a photo of their assignment
- Photo → ML Kit OCR → extract question text
- Query → Gemini embeddings → vector search → retrieve top 3-5 relevant book chunks
- Gemini answers using retrieved context + cites which page/book
- Works across all 10 Class 8 books simultaneously

Vector DB options:
- **Local** — SQLite + cosine similarity (simple, offline, good for single class)
- **Cloud** — Pinecone / Supabase pgvector (better for multi-class, multi-year scale)

For v1, local SQLite vector store is fine. Same pattern as OrbitAI RAG.

---

**5. Subscription / Monetization**

Free tier:
- All reader features free
- 5 AI page explanations per day
- 3 homework questions per day

Premium (₹79-99/month):
- Unlimited AI explanations
- Unlimited homework helper
- Quiz generation
- Priority response

Stack: Google Play Billing + RevenueCat for subscription management

---

**Tech Stack Summary**

| Feature | Tech |
|---|---|
| PDF Viewer | `syncfusion_flutter_pdfviewer` |
| Page screenshot | `flutter/rendering` RenderRepaintBoundary |
| OCR | Google ML Kit Text Recognition |
| AI (page features) | Gemini Flash Vision API |
| Embeddings | Gemini Embedding API |
| Vector DB (v1) | SQLite + cosine similarity |
| Vector DB (v2) | Supabase pgvector |
| Subscriptions | RevenueCat + Google Play Billing |
| Local storage | Room / SharedPreferences |

---

**Build order I'd suggest:**

2. Reading habit system (progress, streak)
3. AI page features (explain, quiz) — this is your subscription hook
4. RAG / homework helper — this is your wow feature, build after AI is stable


AI reader as loud.

Create Time table
add notes by clicking photo..

