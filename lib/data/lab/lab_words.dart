import '../models/localized_text.dart';
import '../models/regional_language.dart';

// ─── Lab display words ────────────────────────────────────────────────────────
//
// Controls, observations and predictions are saved as English keys; these are
// only their on-screen words.

/// The display word for a lab key such as `bright`, `red` or `lemon`. Unknown
/// keys are returned unchanged.
String labWord(String key, RegionalLanguage lang) =>
    labWords[key]?.of(lang) ?? key;

const labWords = <String, LocalizedText>{
  // Circuit
  'off': LocalizedText(en: 'Off', or: 'ବନ୍ଦ', hi: 'बंद'),
  'dim': LocalizedText(en: 'Dim', or: 'କ୍ଷୀଣ', hi: 'मंद'),
  'bright': LocalizedText(en: 'Bright', or: 'ଉଜ୍ଜ୍ୱଳ', hi: 'तेज़'),
  // Pendulum
  'fast': LocalizedText(en: 'Fast', or: 'ଦ୍ରୁତ', hi: 'तेज़'),
  'medium': LocalizedText(en: 'Medium', or: 'ମଧ୍ୟମ', hi: 'मध्यम'),
  'slow': LocalizedText(en: 'Slow', or: 'ଧୀର', hi: 'धीमा'),
  // Mirror
  'high': LocalizedText(en: 'High', or: 'ଉପର', hi: 'ऊपर'),
  'middle': LocalizedText(en: 'Middle', or: 'ମଝି', hi: 'बीच'),
  'low': LocalizedText(en: 'Low', or: 'ତଳ', hi: 'नीचे'),
  // Sink or float
  'float': LocalizedText(en: 'Floats', or: 'ଭାସେ', hi: 'तैरता है'),
  'sink': LocalizedText(en: 'Sinks', or: 'ବୁଡ଼େ', hi: 'डूबता है'),
  'wood': LocalizedText(en: 'Wood', or: 'କାଠ', hi: 'लकड़ी'),
  'ice': LocalizedText(en: 'Ice', or: 'ବରଫ', hi: 'बर्फ़'),
  'egg': LocalizedText(en: 'Egg', or: 'ଅଣ୍ଡା', hi: 'अंडा'),
  'stone': LocalizedText(en: 'Stone', or: 'ପଥର', hi: 'पत्थर'),
  'iron': LocalizedText(en: 'Iron', or: 'ଲୁହା', hi: 'लोहा'),
  'water': LocalizedText(en: 'Water', or: 'ପାଣି', hi: 'पानी'),
  'salt_water': LocalizedText(
    en: 'Salt water',
    or: 'ଲୁଣ ପାଣି',
    hi: 'नमक का पानी',
  ),
  // Indicator
  'lemon': LocalizedText(en: 'Lemon juice', or: 'ଲେମ୍ବୁ ରସ', hi: 'नींबू का रस'),
  'tomato': LocalizedText(
    en: 'Tomato juice',
    or: 'ଟମାଟୋ ରସ',
    hi: 'टमाटर का रस',
  ),
  'baking_soda': LocalizedText(
    en: 'Baking soda',
    or: 'ଖାଇବା ସୋଡା',
    hi: 'बेकिंग सोडा',
  ),
  'soap': LocalizedText(
    en: 'Soap solution',
    or: 'ସାବୁନ ଦ୍ରବଣ',
    hi: 'साबुन का घोल',
  ),
  'limewater': LocalizedText(
    en: 'Lime water',
    or: 'ଚୂନ ପାଣି',
    hi: 'चूने का पानी',
  ),
  'red': LocalizedText(en: 'Red', or: 'ଲାଲ', hi: 'लाल'),
  'orange': LocalizedText(en: 'Orange', or: 'କମଳା', hi: 'नारंगी'),
  'green': LocalizedText(en: 'Green', or: 'ସବୁଜ', hi: 'हरा'),
  'blue': LocalizedText(en: 'Blue', or: 'ନୀଳ', hi: 'नीला'),
  'violet': LocalizedText(en: 'Violet', or: 'ବାଇଗଣୀ', hi: 'बैंगनी'),
  'acidic': LocalizedText(en: 'Acidic', or: 'ଅମ୍ଳୀୟ', hi: 'अम्लीय'),
  'neutral': LocalizedText(en: 'Neutral', or: 'ନିରପେକ୍ଷ', hi: 'उदासीन'),
  'basic': LocalizedText(en: 'Basic', or: 'କ୍ଷାରୀୟ', hi: 'क्षारीय'),
  // Fizz
  'vinegar': LocalizedText(en: 'Vinegar', or: 'ଭିନେଗାର', hi: 'सिरका'),
  'small': LocalizedText(en: 'Small', or: 'ଛୋଟ', hi: 'छोटा'),
  'big': LocalizedText(en: 'Big', or: 'ବଡ଼', hi: 'बड़ा'),
  'none': LocalizedText(
    en: 'Nothing left',
    or: 'କିଛି ବଳିନାହିଁ',
    hi: 'कुछ नहीं बचा',
  ),
};
