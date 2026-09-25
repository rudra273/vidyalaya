part of 'interactive_diagrams_data.dart';

const remainingInteractiveDiagrams = [
  InteractiveDiagram(
    id: 'human_ear',
    section: DiagramSection.biology,
    title: DiagramText(en: 'Human Ear', hi: 'मानव कान', or: 'ମାନବ କାନ'),
    description: DiagramText(
      en: 'Follow sound from the outer ear to the inner ear.',
      hi: 'बाहरी कान से भीतरी कान तक ध्वनि की यात्रा को समझें।',
      or: 'ବାହ୍ୟ କାନରୁ ଅନ୍ତଃକର୍ଣ୍ଣ ପର୍ଯ୍ୟନ୍ତ ଶବ୍ଦର ଯାତ୍ରାକୁ ବୁଝନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/human_ear.png',
    aspectRatio: 1.5,
    labels: [
      InteractiveDiagramLabel(
        id: 'pinna',
        title: DiagramText(en: 'Pinna', hi: 'कर्णपल्लव', or: 'କର୍ଣ୍ଣପାଳି'),
        explanation: DiagramText(
          en: 'The visible outer ear that collects sound waves.',
          hi: 'कान का दिखाई देने वाला बाहरी भाग जो ध्वनि तरंगों को एकत्र करता है।',
          or: 'କାନର ଦୃଶ୍ୟମାନ ବାହ୍ୟ ଅଂଶ ଯାହା ଶବ୍ଦ ତରଙ୍ଗ ସଂଗ୍ରହ କରେ।',
        ),
        position: Offset(0.08, 0.47),
      ),
      InteractiveDiagramLabel(
        id: 'ear_canal',
        title: DiagramText(en: 'Ear canal', hi: 'कर्ण नलिका', or: 'କର୍ଣ୍ଣନଳୀ'),
        explanation: DiagramText(
          en: 'Carries sound waves from the pinna to the eardrum.',
          hi: 'ध्वनि तरंगों को कर्णपल्लव से कान के पर्दे तक पहुँचाती है।',
          or: 'ଶବ୍ଦ ତରଙ୍ଗକୁ କର୍ଣ୍ଣପାଳିରୁ କାନପରଦା ପର୍ଯ୍ୟନ୍ତ ନେଇଯାଏ।',
        ),
        position: Offset(0.35, 0.47),
      ),
      InteractiveDiagramLabel(
        id: 'eardrum',
        title: DiagramText(en: 'Eardrum', hi: 'कान का पर्दा', or: 'କାନପରଦା'),
        explanation: DiagramText(
          en: 'A thin membrane that vibrates when sound waves reach it.',
          hi: 'पतली झिल्ली जो ध्वनि तरंगों के पहुँचने पर कंपन करती है।',
          or: 'ପତଳା ଝିଲ୍ଲୀ ଯାହା ଶବ୍ଦ ତରଙ୍ଗ ପହଞ୍ଚିଲେ କମ୍ପିତ ହୁଏ।',
        ),
        position: Offset(0.51, 0.47),
      ),
      InteractiveDiagramLabel(
        id: 'ossicles',
        title: DiagramText(
          en: 'Ossicles',
          hi: 'कर्ण अस्थिकाएँ',
          or: 'କର୍ଣ୍ଣ ଅସ୍ଥିକା',
        ),
        explanation: DiagramText(
          en: 'Three tiny bones that amplify and pass vibrations to the inner ear.',
          hi: 'तीन छोटी हड्डियाँ जो कंपन को बढ़ाकर भीतरी कान तक पहुँचाती हैं।',
          or: 'ତିନିଟି କ୍ଷୁଦ୍ର ଅସ୍ଥି ଯାହା କମ୍ପନକୁ ବଢ଼ାଇ ଅନ୍ତଃକର୍ଣ୍ଣକୁ ପଠାଏ।',
        ),
        position: Offset(0.62, 0.36),
      ),
      InteractiveDiagramLabel(
        id: 'cochlea',
        title: DiagramText(en: 'Cochlea', hi: 'कर्णावर्त', or: 'କର୍ଣ୍ଣାବର୍ତ୍ତ'),
        explanation: DiagramText(
          en: 'A spiral inner-ear structure that changes vibrations into nerve signals.',
          hi: 'सर्पिल भीतरी संरचना जो कंपन को तंत्रिका संकेतों में बदलती है।',
          or: 'ସର୍ପିଳ ଅନ୍ତଃକର୍ଣ୍ଣ ଗଠନ ଯାହା କମ୍ପନକୁ ସ୍ନାୟୁ ସଙ୍କେତରେ ପରିଣତ କରେ।',
        ),
        position: Offset(0.78, 0.51),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'human_brain',
    section: DiagramSection.biology,
    title: DiagramText(
      en: 'Human Brain',
      hi: 'मानव मस्तिष्क',
      or: 'ମାନବ ମସ୍ତିଷ୍କ',
    ),
    description: DiagramText(
      en: 'Explore three major regions of the human brain.',
      hi: 'मानव मस्तिष्क के तीन प्रमुख भागों को जानें।',
      or: 'ମାନବ ମସ୍ତିଷ୍କର ତିନିଟି ପ୍ରମୁଖ ଅଂଶକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/human_brain.png',
    aspectRatio: 1,
    labels: [
      InteractiveDiagramLabel(
        id: 'cerebrum',
        title: DiagramText(
          en: 'Cerebrum',
          hi: 'प्रमस्तिष्क',
          or: 'ଗୁରୁମସ୍ତିଷ୍କ',
        ),
        explanation: DiagramText(
          en: 'Controls thinking, memory, senses and voluntary movement.',
          hi: 'सोच, स्मृति, संवेदनाओं और ऐच्छिक गति को नियंत्रित करता है।',
          or: 'ଚିନ୍ତା, ସ୍ମୃତି, ଇନ୍ଦ୍ରିୟ ଓ ଇଚ୍ଛାଧୀନ ଗତିକୁ ନିୟନ୍ତ୍ରଣ କରେ।',
        ),
        position: Offset(0.20, 0.40),
      ),
      InteractiveDiagramLabel(
        id: 'cerebellum',
        title: DiagramText(
          en: 'Cerebellum',
          hi: 'अनुमस्तिष्क',
          or: 'ଅନୁମସ୍ତିଷ୍କ',
        ),
        explanation: DiagramText(
          en: 'Coordinates balance, posture and smooth muscle movements.',
          hi: 'संतुलन, मुद्रा और सुचारु पेशीय गतियों का समन्वय करता है।',
          or: 'ସନ୍ତୁଳନ, ଶରୀରଭଙ୍ଗୀ ଓ ସୁଗମ ପେଶୀ ଗତିର ସମନ୍ୱୟ କରେ।',
        ),
        position: Offset(0.76, 0.69),
      ),
      InteractiveDiagramLabel(
        id: 'medulla',
        title: DiagramText(en: 'Medulla', hi: 'मेडुला', or: 'ସୁଷୁମ୍ନାଶୀର୍ଷ'),
        explanation: DiagramText(
          en: 'Controls automatic actions such as breathing and heartbeat.',
          hi: 'श्वसन और हृदय गति जैसी अनैच्छिक क्रियाओं को नियंत्रित करता है।',
          or: 'ଶ୍ୱାସକ୍ରିୟା ଓ ହୃଦ୍‌ସ୍ପନ୍ଦନ ପରି ଅନିଚ୍ଛାକୃତ କାର୍ଯ୍ୟକୁ ନିୟନ୍ତ୍ରଣ କରେ।',
        ),
        position: Offset(0.57, 0.82),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'excretory_system',
    section: DiagramSection.biology,
    title: DiagramText(
      en: 'Excretory System',
      hi: 'उत्सर्जन तंत्र',
      or: 'ରେଚନ ତନ୍ତ୍ର',
    ),
    description: DiagramText(
      en: 'Follow urine formation and removal through the urinary system.',
      hi: 'मूत्र तंत्र में मूत्र बनने और बाहर निकलने की प्रक्रिया को समझें।',
      or: 'ମୂତ୍ରତନ୍ତ୍ରରେ ମୂତ୍ର ଗଠନ ଓ ନିଷ୍କାସନ ପ୍ରକ୍ରିୟାକୁ ବୁଝନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/excretory_system.png',
    aspectRatio: 2 / 3,
    labels: [
      InteractiveDiagramLabel(
        id: 'kidney',
        title: DiagramText(en: 'Kidney', hi: 'वृक्क', or: 'ବୃକ୍କ'),
        explanation: DiagramText(
          en: 'Filters the blood, removes wastes and helps balance water and salts.',
          hi: 'रक्त को छानता, अपशिष्ट हटाता और जल व लवण का संतुलन बनाए रखता है।',
          or: 'ରକ୍ତକୁ ଛାଣେ, ବର୍ଜ୍ୟ ବାହାର କରେ ଓ ଜଳ-ଲବଣ ସନ୍ତୁଳନ ରଖେ।',
        ),
        position: Offset(0.20, 0.43),
      ),
      InteractiveDiagramLabel(
        id: 'ureter',
        title: DiagramText(en: 'Ureter', hi: 'मूत्रवाहिनी', or: 'ମୂତ୍ରବାହିନୀ'),
        explanation: DiagramText(
          en: 'A tube that carries urine from a kidney to the bladder.',
          hi: 'नली जो वृक्क से मूत्राशय तक मूत्र पहुँचाती है।',
          or: 'ନଳୀ ଯାହା ବୃକ୍କରୁ ମୂତ୍ରାଶୟକୁ ମୂତ୍ର ନେଇଯାଏ।',
        ),
        position: Offset(0.31, 0.65),
      ),
      InteractiveDiagramLabel(
        id: 'bladder',
        title: DiagramText(en: 'Bladder', hi: 'मूत्राशय', or: 'ମୂତ୍ରାଶୟ'),
        explanation: DiagramText(
          en: 'A muscular sac that stores urine before it leaves the body.',
          hi: 'पेशीय थैली जो शरीर से बाहर निकलने से पहले मूत्र को जमा करती है।',
          or: 'ପେଶୀଯୁକ୍ତ ଥଳି ଯାହା ଶରୀରରୁ ବାହାରିବା ପୂର୍ବରୁ ମୂତ୍ର ସଞ୍ଚୟ କରେ।',
        ),
        position: Offset(0.37, 0.82),
      ),
      InteractiveDiagramLabel(
        id: 'urethra',
        title: DiagramText(en: 'Urethra', hi: 'मूत्रमार्ग', or: 'ମୂତ୍ରମାର୍ଗ'),
        explanation: DiagramText(
          en: 'Carries urine from the bladder out of the body.',
          hi: 'मूत्राशय से मूत्र को शरीर के बाहर ले जाता है।',
          or: 'ମୂତ୍ରାଶୟରୁ ମୂତ୍ରକୁ ଶରୀର ବାହାରକୁ ନେଇଯାଏ।',
        ),
        position: Offset(0.36, 0.94),
      ),
      InteractiveDiagramLabel(
        id: 'nephron',
        title: DiagramText(en: 'Nephron', hi: 'नेफ्रॉन', or: 'ନେଫ୍ରନ୍'),
        explanation: DiagramText(
          en: 'The microscopic filtering unit of a kidney where urine begins to form.',
          hi: 'वृक्क की सूक्ष्म छनन इकाई जहाँ मूत्र बनना शुरू होता है।',
          or: 'ବୃକ୍କର ସୂକ୍ଷ୍ମ ଛାଣନ ଏକକ ଯେଉଁଠାରେ ମୂତ୍ର ଗଠନ ଆରମ୍ଭ ହୁଏ।',
        ),
        position: Offset(0.82, 0.28),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'odisha_districts',
    section: DiagramSection.geography,
    title: DiagramText(
      en: 'Odisha Districts',
      hi: 'ओडिशा के जिले',
      or: 'ଓଡ଼ିଶାର ଜିଲ୍ଲା',
    ),
    description: DiagramText(
      en: 'Explore Odisha’s 30 districts and two major water features.',
      hi: 'ओडिशा के 30 जिलों और दो प्रमुख जल विशेषताओं को जानें।',
      or: 'ଓଡ଼ିଶାର ୩୦ଟି ଜିଲ୍ଲା ଓ ଦୁଇଟି ପ୍ରମୁଖ ଜଳ ବୈଶିଷ୍ଟ୍ୟକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/odisha_districts.png',
    aspectRatio: 1.5,
    labels: [
      InteractiveDiagramLabel(
        id: 'district_boundaries',
        title: DiagramText(
          en: '30 districts',
          hi: '30 जिले',
          or: '୩୦ଟି ଜିଲ୍ଲା',
        ),
        explanation: DiagramText(
          en: 'Odisha is administratively divided into 30 districts.',
          hi: 'ओडिशा प्रशासनिक रूप से 30 जिलों में विभाजित है।',
          or: 'ଓଡ଼ିଶା ପ୍ରଶାସନିକ ଭାବେ ୩୦ଟି ଜିଲ୍ଲାରେ ବିଭକ୍ତ।',
        ),
        position: Offset(0.18, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'district_headquarters',
        title: DiagramText(
          en: 'District headquarters',
          hi: 'जिला मुख्यालय',
          or: 'ଜିଲ୍ଲା ମୁଖ୍ୟାଳୟ',
        ),
        explanation: DiagramText(
          en: 'Each dot marks the administrative headquarters of a district.',
          hi: 'हर बिंदु एक जिले के प्रशासनिक मुख्यालय को दिखाता है।',
          or: 'ପ୍ରତ୍ୟେକ ବିନ୍ଦୁ ଗୋଟିଏ ଜିଲ୍ଲାର ପ୍ରଶାସନିକ ମୁଖ୍ୟାଳୟକୁ ଦର୍ଶାଏ।',
        ),
        position: Offset(0.83, 0.35),
      ),
      InteractiveDiagramLabel(
        id: 'mahanadi',
        title: DiagramText(en: 'Mahanadi', hi: 'महानदी', or: 'ମହାନଦୀ'),
        explanation: DiagramText(
          en: 'A major river that crosses Odisha and forms a large delta near the coast.',
          hi: 'प्रमुख नदी जो ओडिशा से होकर बहती है और तट के पास बड़ा डेल्टा बनाती है।',
          or: 'ପ୍ରମୁଖ ନଦୀ ଯାହା ଓଡ଼ିଶା ଦେଇ ବହି ଉପକୂଳ ନିକଟରେ ବଡ଼ ତ୍ରିକୋଣଭୂମି ଗଠନ କରେ।',
        ),
        position: Offset(0.47, 0.42),
      ),
      InteractiveDiagramLabel(
        id: 'chilika',
        title: DiagramText(
          en: 'Chilika Lake',
          hi: 'चिलिका झील',
          or: 'ଚିଲିକା ହ୍ରଦ',
        ),
        explanation: DiagramText(
          en: 'A large brackish-water lagoon on Odisha’s coast.',
          hi: 'ओडिशा तट पर स्थित विशाल खारे पानी की झील।',
          or: 'ଓଡ଼ିଶା ଉପକୂଳରେ ଥିବା ବିଶାଳ ଲୁଣାପାଣି ହ୍ରଦ।',
        ),
        position: Offset(0.53, 0.70),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'latitudes_longitudes',
    section: DiagramSection.geography,
    title: DiagramText(
      en: 'Latitudes and Longitudes',
      hi: 'अक्षांश और देशांतर',
      or: 'ଅକ୍ଷାଂଶ ଓ ଦ୍ରାଘିମା',
    ),
    description: DiagramText(
      en: 'Explore the imaginary lines used to locate places on Earth.',
      hi: 'पृथ्वी पर स्थान खोजने के लिए उपयोग की जाने वाली काल्पनिक रेखाओं को जानें।',
      or: 'ପୃଥିବୀରେ ସ୍ଥାନ ନିର୍ଣ୍ଣୟ ପାଇଁ ବ୍ୟବହୃତ କାଳ୍ପନିକ ରେଖାଗୁଡ଼ିକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/latitudes_longitudes.png',
    aspectRatio: 1,
    labels: [
      InteractiveDiagramLabel(
        id: 'equator',
        title: DiagramText(en: 'Equator', hi: 'भूमध्य रेखा', or: 'ବିଷୁବ ରେଖା'),
        explanation: DiagramText(
          en: 'The 0° latitude that divides Earth into northern and southern hemispheres.',
          hi: '0° अक्षांश जो पृथ्वी को उत्तरी और दक्षिणी गोलार्ध में बाँटता है।',
          or: '୦° ଅକ୍ଷାଂଶ ଯାହା ପୃଥିବୀକୁ ଉତ୍ତର ଓ ଦକ୍ଷିଣ ଗୋଲାର୍ଦ୍ଧରେ ବିଭକ୍ତ କରେ।',
        ),
        position: Offset(0.08, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'tropic_cancer',
        title: DiagramText(
          en: 'Tropic of Cancer',
          hi: 'कर्क रेखा',
          or: 'କର୍କଟ କ୍ରାନ୍ତି',
        ),
        explanation: DiagramText(
          en: 'A latitude about 23.5° north of the Equator.',
          hi: 'भूमध्य रेखा से लगभग 23.5° उत्तर का अक्षांश।',
          or: 'ବିଷୁବ ରେଖାର ପ୍ରାୟ ୨୩.୫° ଉତ୍ତରରେ ଥିବା ଅକ୍ଷାଂଶ।',
        ),
        position: Offset(0.17, 0.36),
      ),
      InteractiveDiagramLabel(
        id: 'tropic_capricorn',
        title: DiagramText(
          en: 'Tropic of Capricorn',
          hi: 'मकर रेखा',
          or: 'ମକର କ୍ରାନ୍ତି',
        ),
        explanation: DiagramText(
          en: 'A latitude about 23.5° south of the Equator.',
          hi: 'भूमध्य रेखा से लगभग 23.5° दक्षिण का अक्षांश।',
          or: 'ବିଷୁବ ରେଖାର ପ୍ରାୟ ୨୩.୫° ଦକ୍ଷିଣରେ ଥିବା ଅକ୍ଷାଂଶ।',
        ),
        position: Offset(0.82, 0.66),
      ),
      InteractiveDiagramLabel(
        id: 'prime_meridian',
        title: DiagramText(
          en: 'Prime meridian',
          hi: 'प्रधान मध्यान्ह रेखा',
          or: 'ମୂଳ ମଧ୍ୟାହ୍ନ ରେଖା',
        ),
        explanation: DiagramText(
          en: 'The 0° longitude used as the starting line for measuring longitude.',
          hi: '0° देशांतर जिससे देशांतर मापना शुरू किया जाता है।',
          or: '୦° ଦ୍ରାଘିମା ଯାହାଠାରୁ ଦ୍ରାଘିମା ମାପ ଆରମ୍ଭ ହୁଏ।',
        ),
        position: Offset(0.50, 0.20),
      ),
      InteractiveDiagramLabel(
        id: 'north_pole',
        title: DiagramText(
          en: 'North Pole',
          hi: 'उत्तरी ध्रुव',
          or: 'ଉତ୍ତର ମେରୁ',
        ),
        explanation: DiagramText(
          en: 'The northern end of Earth’s axis at 90° north latitude.',
          hi: '90° उत्तरी अक्षांश पर पृथ्वी की धुरी का उत्तरी सिरा।',
          or: '୯୦° ଉତ୍ତର ଅକ୍ଷାଂଶରେ ପୃଥିବୀ ଅକ୍ଷର ଉତ୍ତର ପ୍ରାନ୍ତ।',
        ),
        position: Offset(0.50, 0.03),
      ),
      InteractiveDiagramLabel(
        id: 'south_pole',
        title: DiagramText(
          en: 'South Pole',
          hi: 'दक्षिणी ध्रुव',
          or: 'ଦକ୍ଷିଣ ମେରୁ',
        ),
        explanation: DiagramText(
          en: 'The southern end of Earth’s axis at 90° south latitude.',
          hi: '90° दक्षिणी अक्षांश पर पृथ्वी की धुरी का दक्षिणी सिरा।',
          or: '୯୦° ଦକ୍ଷିଣ ଅକ୍ଷାଂଶରେ ପୃଥିବୀ ଅକ୍ଷର ଦକ୍ଷିଣ ପ୍ରାନ୍ତ।',
        ),
        position: Offset(0.50, 0.95),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'solar_system',
    section: DiagramSection.geography,
    title: DiagramText(en: 'Solar System', hi: 'सौर मंडल', or: 'ସୌରଜଗତ'),
    description: DiagramText(
      en: 'Meet the Sun, eight planets and the asteroid belt in order.',
      hi: 'सूर्य, आठ ग्रहों और क्षुद्रग्रह पट्टी को क्रम से जानें।',
      or: 'ସୂର୍ଯ୍ୟ, ଆଠଟି ଗ୍ରହ ଓ ଗ୍ରହାଣୁ ବଳୟକୁ କ୍ରମରେ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/solar_system.png',
    aspectRatio: 3,
    labels: [
      InteractiveDiagramLabel(
        id: 'sun',
        title: DiagramText(en: 'Sun', hi: 'सूर्य', or: 'ସୂର୍ଯ୍ୟ'),
        explanation: DiagramText(
          en: 'The star at the centre of the Solar System and its main source of energy.',
          hi: 'सौर मंडल के केंद्र का तारा और उसकी ऊर्जा का मुख्य स्रोत।',
          or: 'ସୌରଜଗତର କେନ୍ଦ୍ରରେ ଥିବା ତାରା ଓ ଏହାର ମୁଖ୍ୟ ଶକ୍ତି ଉତ୍ସ।',
        ),
        position: Offset(0.03, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'mercury',
        title: DiagramText(en: 'Mercury', hi: 'बुध', or: 'ବୁଧ'),
        explanation: DiagramText(
          en: 'The smallest planet and the closest planet to the Sun.',
          hi: 'सबसे छोटा और सूर्य के सबसे निकट ग्रह।',
          or: 'ସବୁଠାରୁ ଛୋଟ ଓ ସୂର୍ଯ୍ୟର ନିକଟତମ ଗ୍ରହ।',
        ),
        position: Offset(0.14, 0.47),
      ),
      InteractiveDiagramLabel(
        id: 'venus',
        title: DiagramText(en: 'Venus', hi: 'शुक्र', or: 'ଶୁକ୍ର'),
        explanation: DiagramText(
          en: 'A rocky planet wrapped in a thick, hot atmosphere.',
          hi: 'घने, गर्म वायुमंडल से घिरा चट्टानी ग्रह।',
          or: 'ଘନ ଓ ଉତ୍ତପ୍ତ ବାୟୁମଣ୍ଡଳରେ ଘେରା ପଥରିଆ ଗ୍ରହ।',
        ),
        position: Offset(0.22, 0.47),
      ),
      InteractiveDiagramLabel(
        id: 'earth',
        title: DiagramText(en: 'Earth', hi: 'पृथ्वी', or: 'ପୃଥିବୀ'),
        explanation: DiagramText(
          en: 'Our home planet, with liquid water and known life.',
          hi: 'हमारा गृह ग्रह, जहाँ तरल जल और ज्ञात जीवन है।',
          or: 'ଆମ ଗୃହ ଗ୍ରହ, ଯେଉଁଠାରେ ତରଳ ଜଳ ଓ ଜୀବନ ରହିଛି।',
        ),
        position: Offset(0.30, 0.46),
      ),
      InteractiveDiagramLabel(
        id: 'mars',
        title: DiagramText(en: 'Mars', hi: 'मंगल', or: 'ମଙ୍ଗଳ'),
        explanation: DiagramText(
          en: 'A cold rocky planet often called the Red Planet.',
          hi: 'ठंडा चट्टानी ग्रह जिसे लाल ग्रह कहा जाता है।',
          or: 'ଶୀତଳ ପଥରିଆ ଗ୍ରହ ଯାହାକୁ ଲାଲ ଗ୍ରହ କୁହାଯାଏ।',
        ),
        position: Offset(0.39, 0.48),
      ),
      InteractiveDiagramLabel(
        id: 'asteroid_belt',
        title: DiagramText(
          en: 'Asteroid belt',
          hi: 'क्षुद्रग्रह पट्टी',
          or: 'ଗ୍ରହାଣୁ ବଳୟ',
        ),
        explanation: DiagramText(
          en: 'A broad region of rocky objects between Mars and Jupiter.',
          hi: 'मंगल और बृहस्पति के बीच चट्टानी पिंडों का विस्तृत क्षेत्र।',
          or: 'ମଙ୍ଗଳ ଓ ବୃହସ୍ପତି ମଧ୍ୟରେ ପଥରିଆ ବସ୍ତୁର ବିସ୍ତୃତ ଅଞ୍ଚଳ।',
        ),
        position: Offset(0.46, 0.43),
      ),
      InteractiveDiagramLabel(
        id: 'jupiter',
        title: DiagramText(en: 'Jupiter', hi: 'बृहस्पति', or: 'ବୃହସ୍ପତି'),
        explanation: DiagramText(
          en: 'The largest planet, a gas giant with a great storm.',
          hi: 'सबसे बड़ा ग्रह, एक गैसीय दानव जिसमें विशाल तूफान है।',
          or: 'ସବୁଠାରୁ ବଡ଼ ଗ୍ରହ, ଏକ ଗ୍ୟାସୀୟ ଦାନବ ଯେଉଁଥିରେ ବିଶାଳ ଝଡ଼ ରହିଛି।',
        ),
        position: Offset(0.57, 0.47),
      ),
      InteractiveDiagramLabel(
        id: 'saturn',
        title: DiagramText(en: 'Saturn', hi: 'शनि', or: 'ଶନି'),
        explanation: DiagramText(
          en: 'A gas giant surrounded by a prominent system of rings.',
          hi: 'स्पष्ट वलयों से घिरा गैसीय दानव ग्रह।',
          or: 'ସ୍ପଷ୍ଟ ବଳୟ ପ୍ରଣାଳୀରେ ଘେରା ଗ୍ୟାସୀୟ ଦାନବ ଗ୍ରହ।',
        ),
        position: Offset(0.72, 0.47),
      ),
      InteractiveDiagramLabel(
        id: 'uranus',
        title: DiagramText(en: 'Uranus', hi: 'अरुण', or: 'ୟୁରେନସ୍'),
        explanation: DiagramText(
          en: 'An ice giant that rotates on a strongly tilted axis.',
          hi: 'एक हिम दानव जो बहुत झुकी धुरी पर घूमता है।',
          or: 'ଏକ ବରଫ ଦାନବ ଗ୍ରହ ଯାହା ଅତ୍ୟଧିକ ଢଳିଥିବା ଅକ୍ଷରେ ଘୂରେ।',
        ),
        position: Offset(0.85, 0.47),
      ),
      InteractiveDiagramLabel(
        id: 'neptune',
        title: DiagramText(en: 'Neptune', hi: 'वरुण', or: 'ନେପଚ୍ୟୁନ୍'),
        explanation: DiagramText(
          en: 'The farthest major planet from the Sun, known for powerful winds.',
          hi: 'सूर्य से सबसे दूर प्रमुख ग्रह, जो तेज हवाओं के लिए जाना जाता है।',
          or: 'ସୂର୍ଯ୍ୟରୁ ସବୁଠାରୁ ଦୂର ପ୍ରମୁଖ ଗ୍ରହ, ଯାହା ଶକ୍ତିଶାଳୀ ପବନ ପାଇଁ ପରିଚିତ।',
        ),
        position: Offset(0.95, 0.47),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'soil_profile',
    section: DiagramSection.geography,
    title: DiagramText(
      en: 'Soil Profile',
      hi: 'मृदा परिच्छेदिका',
      or: 'ମୃତ୍ତିକା ସ୍ତର',
    ),
    description: DiagramText(
      en: 'Explore the layers found from the soil surface down to bedrock.',
      hi: 'मिट्टी की सतह से आधार शैल तक की परतों को जानें।',
      or: 'ମାଟି ପୃଷ୍ଠରୁ ଶିଳାସ୍ତର ପର୍ଯ୍ୟନ୍ତ ଥିବା ସ୍ତରଗୁଡ଼ିକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/soil_profile.png',
    aspectRatio: 2 / 3,
    labels: [
      InteractiveDiagramLabel(
        id: 'humus',
        title: DiagramText(en: 'Humus', hi: 'ह्यूमस', or: 'ହ୍ୟୁମସ୍'),
        explanation: DiagramText(
          en: 'Dark organic matter formed from decayed plants and animals.',
          hi: 'सड़े-गले पौधों और जीवों से बना गहरा जैविक पदार्थ।',
          or: 'ପଚିଥିବା ଉଦ୍ଭିଦ ଓ ପ୍ରାଣୀରୁ ତିଆରି ଗାଢ଼ ଜୈବ ପଦାର୍ଥ।',
        ),
        position: Offset(0.20, 0.15),
      ),
      InteractiveDiagramLabel(
        id: 'topsoil',
        title: DiagramText(en: 'Topsoil', hi: 'ऊपरी मिट्टी', or: 'ଉପର ମାଟି'),
        explanation: DiagramText(
          en: 'The fertile upper layer where most roots and soil organisms live.',
          hi: 'उपजाऊ ऊपरी परत जहाँ अधिकांश जड़ें और मृदा जीव रहते हैं।',
          or: 'ଉର୍ବର ଉପର ସ୍ତର ଯେଉଁଠାରେ ଅଧିକାଂଶ ଚେର ଓ ମୃତ୍ତିକା ଜୀବ ରହନ୍ତି।',
        ),
        position: Offset(0.80, 0.31),
      ),
      InteractiveDiagramLabel(
        id: 'subsoil',
        title: DiagramText(en: 'Subsoil', hi: 'अधोमृदा', or: 'ତଳ ମାଟି'),
        explanation: DiagramText(
          en: 'A lighter layer with fewer roots and more accumulated minerals.',
          hi: 'हल्की परत जिसमें कम जड़ें और अधिक संचित खनिज होते हैं।',
          or: 'ହାଲୁକା ସ୍ତର ଯେଉଁଥିରେ କମ୍ ଚେର ଓ ଅଧିକ ସଞ୍ଚିତ ଖଣିଜ ଥାଏ।',
        ),
        position: Offset(0.20, 0.57),
      ),
      InteractiveDiagramLabel(
        id: 'bedrock',
        title: DiagramText(en: 'Bedrock', hi: 'आधार शैल', or: 'ମୂଳ ଶିଳା'),
        explanation: DiagramText(
          en: 'The solid rock layer beneath the soil from which soil can slowly form.',
          hi: 'मिट्टी के नीचे की ठोस चट्टान जिससे धीरे-धीरे मिट्टी बन सकती है।',
          or: 'ମାଟି ତଳର ଦୃଢ଼ ଶିଳାସ୍ତର ଯାହାଠାରୁ ଧୀରେ ଧୀରେ ମାଟି ତିଆରି ହୋଇପାରେ।',
        ),
        position: Offset(0.80, 0.82),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'lens_refraction',
    section: DiagramSection.science,
    title: DiagramText(
      en: 'Refraction Through Lenses',
      hi: 'लेंस से अपवर्तन',
      or: 'ଲେନ୍ସ ଦ୍ୱାରା ପ୍ରତିସରଣ',
    ),
    description: DiagramText(
      en: 'Compare how convex and concave lenses bend parallel light rays.',
      hi: 'उत्तल और अवतल लेंस समानांतर प्रकाश किरणों को कैसे मोड़ते हैं, इसकी तुलना करें।',
      or: 'ଉତ୍ତଳ ଓ ଅବତଳ ଲେନ୍ସ ସମାନ୍ତର ଆଲୋକ ରଶ୍ମିକୁ କିପରି ବଙ୍କା କରେ ତାହା ତୁଳନା କରନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/lens_refraction.png',
    aspectRatio: 2.5,
    labels: [
      InteractiveDiagramLabel(
        id: 'convex_lens',
        title: DiagramText(
          en: 'Convex lens',
          hi: 'उत्तल लेंस',
          or: 'ଉତ୍ତଳ ଲେନ୍ସ',
        ),
        explanation: DiagramText(
          en: 'Thicker at the centre and converges parallel light rays.',
          hi: 'केंद्र में मोटा होता है और समानांतर प्रकाश किरणों को अभिसरित करता है।',
          or: 'ମଝିରେ ମୋଟା ଓ ସମାନ୍ତର ଆଲୋକ ରଶ୍ମିକୁ ଅଭିସାରୀ କରେ।',
        ),
        position: Offset(0.22, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'concave_lens',
        title: DiagramText(
          en: 'Concave lens',
          hi: 'अवतल लेंस',
          or: 'ଅବତଳ ଲେନ୍ସ',
        ),
        explanation: DiagramText(
          en: 'Thinner at the centre and diverges parallel light rays.',
          hi: 'केंद्र में पतला होता है और समानांतर प्रकाश किरणों को अपसरित करता है।',
          or: 'ମଝିରେ ପତଳା ଓ ସମାନ୍ତର ଆଲୋକ ରଶ୍ମିକୁ ଅପସାରୀ କରେ।',
        ),
        position: Offset(0.75, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'focus',
        title: DiagramText(
          en: 'Principal focus',
          hi: 'मुख्य फोकस',
          or: 'ମୁଖ୍ୟ ଫୋକସ୍',
        ),
        explanation: DiagramText(
          en: 'The point where parallel rays meet, or appear to spread from, after refraction.',
          hi: 'वह बिंदु जहाँ अपवर्तन के बाद समानांतर किरणें मिलती या फैलती हुई प्रतीत होती हैं।',
          or: 'ପ୍ରତିସରଣ ପରେ ସମାନ୍ତର ରଶ୍ମି ଯେଉଁଠାରେ ମିଳେ କିମ୍ବା ଯେଉଁଠାରୁ ବିସ୍ତାରିତ ହେବା ପରି ଦିଶେ।',
        ),
        position: Offset(0.38, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'principal_axis',
        title: DiagramText(
          en: 'Principal axis',
          hi: 'मुख्य अक्ष',
          or: 'ମୁଖ୍ୟ ଅକ୍ଷ',
        ),
        explanation: DiagramText(
          en: 'The straight reference line through the optical centre of a lens.',
          hi: 'लेंस के प्रकाशिक केंद्र से गुजरने वाली सीधी संदर्भ रेखा।',
          or: 'ଲେନ୍ସର ଆଲୋକୀୟ କେନ୍ଦ୍ର ଦେଇ ଯାଇଥିବା ସିଧା ସନ୍ଦର୍ଭ ରେଖା।',
        ),
        position: Offset(0.50, 0.50),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'magnetic_field',
    section: DiagramSection.science,
    title: DiagramText(
      en: 'Magnet and Field Lines',
      hi: 'चुंबक और क्षेत्र रेखाएँ',
      or: 'ଚୁମ୍ବକ ଓ କ୍ଷେତ୍ର ରେଖା',
    ),
    description: DiagramText(
      en: 'Explore the magnetic field around a bar magnet.',
      hi: 'दंड चुंबक के चारों ओर चुंबकीय क्षेत्र को जानें।',
      or: 'ଦଣ୍ଡ ଚୁମ୍ବକ ଚାରିପାଖର ଚୁମ୍ବକୀୟ କ୍ଷେତ୍ରକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/magnetic_field.png',
    aspectRatio: 1.5,
    labels: [
      InteractiveDiagramLabel(
        id: 'north_pole',
        title: DiagramText(
          en: 'North pole',
          hi: 'उत्तरी ध्रुव',
          or: 'ଉତ୍ତର ମେରୁ',
        ),
        explanation: DiagramText(
          en: 'The pole from which field lines emerge outside the magnet.',
          hi: 'वह ध्रुव जिससे चुंबक के बाहर क्षेत्र रेखाएँ निकलती हैं।',
          or: 'ଯେଉଁ ମେରୁରୁ ଚୁମ୍ବକ ବାହାରେ କ୍ଷେତ୍ର ରେଖା ବାହାରେ।',
        ),
        position: Offset(0.33, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'south_pole',
        title: DiagramText(
          en: 'South pole',
          hi: 'दक्षिणी ध्रुव',
          or: 'ଦକ୍ଷିଣ ମେରୁ',
        ),
        explanation: DiagramText(
          en: 'The pole into which field lines enter outside the magnet.',
          hi: 'वह ध्रुव जिसमें चुंबक के बाहर क्षेत्र रेखाएँ प्रवेश करती हैं।',
          or: 'ଯେଉଁ ମେରୁରେ ଚୁମ୍ବକ ବାହାରର କ୍ଷେତ୍ର ରେଖା ପ୍ରବେଶ କରେ।',
        ),
        position: Offset(0.65, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'field_lines',
        title: DiagramText(
          en: 'Magnetic field lines',
          hi: 'चुंबकीय क्षेत्र रेखाएँ',
          or: 'ଚୁମ୍ବକୀୟ କ୍ଷେତ୍ର ରେଖା',
        ),
        explanation: DiagramText(
          en: 'Curved closed paths showing the direction and shape of the magnetic field.',
          hi: 'बंद वक्र पथ जो चुंबकीय क्षेत्र की दिशा और आकार दिखाते हैं।',
          or: 'ବନ୍ଦ ବକ୍ର ପଥ ଯାହା ଚୁମ୍ବକୀୟ କ୍ଷେତ୍ରର ଦିଗ ଓ ଆକାର ଦର୍ଶାଏ।',
        ),
        position: Offset(0.50, 0.20),
      ),
      InteractiveDiagramLabel(
        id: 'compass',
        title: DiagramText(en: 'Compass', hi: 'दिशा-सूचक', or: 'ଦିଗସୂଚକ'),
        explanation: DiagramText(
          en: 'Its needle turns to align with the local magnetic field.',
          hi: 'इसकी सुई स्थानीय चुंबकीय क्षेत्र की दिशा में घूम जाती है।',
          or: 'ଏହାର କଣ୍ଟା ସ୍ଥାନୀୟ ଚୁମ୍ବକୀୟ କ୍ଷେତ୍ର ଦିଗରେ ଘୂରିଯାଏ।',
        ),
        position: Offset(0.78, 0.15),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'simple_machines',
    section: DiagramSection.science,
    title: DiagramText(
      en: 'Simple Machines',
      hi: 'सरल मशीनें',
      or: 'ସରଳ ଯନ୍ତ୍ର',
    ),
    description: DiagramText(
      en: 'Compare a lever, pulley and inclined plane.',
      hi: 'उत्तोलक, चरखी और नत तल की तुलना करें।',
      or: 'ଲିଭର୍, ପୁଲି ଓ ଆନତ ତଳକୁ ତୁଳନା କରନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/simple_machines.png',
    aspectRatio: 2.4,
    labels: [
      InteractiveDiagramLabel(
        id: 'lever',
        title: DiagramText(en: 'Lever', hi: 'उत्तोलक', or: 'ଲିଭର୍'),
        explanation: DiagramText(
          en: 'A rigid bar that turns around a fixed point to move a load.',
          hi: 'कठोर छड़ जो भार को चलाने के लिए एक स्थिर बिंदु के चारों ओर घूमती है।',
          or: 'କଠିନ ଦଣ୍ଡ ଯାହା ଭାର ଚଳାଇବା ପାଇଁ ଏକ ସ୍ଥିର ବିନ୍ଦୁ ଚାରିପାଖେ ଘୂରେ।',
        ),
        position: Offset(0.18, 0.55),
      ),
      InteractiveDiagramLabel(
        id: 'fulcrum',
        title: DiagramText(en: 'Fulcrum', hi: 'आलंब', or: 'ଆଲମ୍ବ'),
        explanation: DiagramText(
          en: 'The fixed support about which a lever turns.',
          hi: 'स्थिर सहारा जिसके चारों ओर उत्तोलक घूमता है।',
          or: 'ସ୍ଥିର ଆଧାର ଯାହା ଚାରିପାଖେ ଲିଭର୍ ଘୂରେ।',
        ),
        position: Offset(0.18, 0.75),
      ),
      InteractiveDiagramLabel(
        id: 'load',
        title: DiagramText(en: 'Load', hi: 'भार', or: 'ଭାର'),
        explanation: DiagramText(
          en: 'The object or resistance that the machine moves.',
          hi: 'वह वस्तु या प्रतिरोध जिसे मशीन चलाती है।',
          or: 'ବସ୍ତୁ କିମ୍ବା ପ୍ରତିରୋଧ ଯାହାକୁ ଯନ୍ତ୍ର ଚଳାଏ।',
        ),
        position: Offset(0.06, 0.45),
      ),
      InteractiveDiagramLabel(
        id: 'effort',
        title: DiagramText(en: 'Effort', hi: 'प्रयास', or: 'ପ୍ରୟାସ'),
        explanation: DiagramText(
          en: 'The force applied to make a simple machine work.',
          hi: 'सरल मशीन को चलाने के लिए लगाया गया बल।',
          or: 'ସରଳ ଯନ୍ତ୍ରକୁ କାମ କରାଇବା ପାଇଁ ପ୍ରୟୋଗ କରାଯାଇଥିବା ବଳ।',
        ),
        position: Offset(0.33, 0.42),
      ),
      InteractiveDiagramLabel(
        id: 'pulley',
        title: DiagramText(en: 'Pulley', hi: 'चरखी', or: 'ପୁଲି'),
        explanation: DiagramText(
          en: 'A grooved wheel and rope that can change the direction of effort.',
          hi: 'खाँचेदार पहिया और रस्सी जो प्रयास की दिशा बदल सकते हैं।',
          or: 'ଖାଞ୍ଚାଯୁକ୍ତ ଚକ ଓ ଦଉଡ଼ି ଯାହା ପ୍ରୟାସର ଦିଗ ବଦଳାଇପାରେ।',
        ),
        position: Offset(0.50, 0.25),
      ),
      InteractiveDiagramLabel(
        id: 'inclined_plane',
        title: DiagramText(en: 'Inclined plane', hi: 'नत तल', or: 'ଆନତ ତଳ'),
        explanation: DiagramText(
          en: 'A sloping surface that reduces the force needed to raise a load.',
          hi: 'ढलानदार सतह जो भार उठाने के लिए आवश्यक बल कम करती है।',
          or: 'ଢାଲୁ ପୃଷ୍ଠ ଯାହା ଭାର ଉଠାଇବା ପାଇଁ ଆବଶ୍ୟକ ବଳ କମାଏ।',
        ),
        position: Offset(0.80, 0.58),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'angles_triangles',
    section: DiagramSection.math,
    title: DiagramText(
      en: 'Angles and Triangles',
      hi: 'कोण और त्रिभुज',
      or: 'କୋଣ ଓ ତ୍ରିଭୁଜ',
    ),
    description: DiagramText(
      en: 'Compare common angle types and triangles classified by their sides.',
      hi: 'सामान्य कोणों और भुजाओं के आधार पर त्रिभुजों की तुलना करें।',
      or: 'ସାଧାରଣ କୋଣ ଓ ବାହୁ ଅନୁଯାୟୀ ତ୍ରିଭୁଜଗୁଡ଼ିକୁ ତୁଳନା କରନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/angles_triangles.png',
    aspectRatio: 1.5,
    labels: [
      InteractiveDiagramLabel(
        id: 'acute_angle',
        title: DiagramText(
          en: 'Acute angle',
          hi: 'न्यून कोण',
          or: 'ସୂକ୍ଷ୍ମ କୋଣ',
        ),
        explanation: DiagramText(
          en: 'An angle greater than 0° but less than 90°.',
          hi: '0° से बड़ा लेकिन 90° से छोटा कोण।',
          or: '୦° ଠାରୁ ବଡ଼ କିନ୍ତୁ ୯୦° ଠାରୁ ଛୋଟ କୋଣ।',
        ),
        position: Offset(0.18, 0.27),
      ),
      InteractiveDiagramLabel(
        id: 'right_angle',
        title: DiagramText(en: 'Right angle', hi: 'समकोण', or: 'ସମକୋଣ'),
        explanation: DiagramText(
          en: 'An angle measuring exactly 90°.',
          hi: 'ठीक 90° का कोण।',
          or: 'ଠିକ୍ ୯୦° ମାପର କୋଣ।',
        ),
        position: Offset(0.50, 0.27),
      ),
      InteractiveDiagramLabel(
        id: 'obtuse_angle',
        title: DiagramText(en: 'Obtuse angle', hi: 'अधिक कोण', or: 'ସ୍ଥୂଳ କୋଣ'),
        explanation: DiagramText(
          en: 'An angle greater than 90° but less than 180°.',
          hi: '90° से बड़ा लेकिन 180° से छोटा कोण।',
          or: '୯୦° ଠାରୁ ବଡ଼ କିନ୍ତୁ ୧୮୦° ଠାରୁ ଛୋଟ କୋଣ।',
        ),
        position: Offset(0.82, 0.27),
      ),
      InteractiveDiagramLabel(
        id: 'equilateral_triangle',
        title: DiagramText(
          en: 'Equilateral triangle',
          hi: 'समबाहु त्रिभुज',
          or: 'ସମବାହୁ ତ୍ରିଭୁଜ',
        ),
        explanation: DiagramText(
          en: 'A triangle with three equal sides and three equal angles.',
          hi: 'तीन समान भुजाओं और तीन समान कोणों वाला त्रिभुज।',
          or: 'ତିନି ସମାନ ବାହୁ ଓ ତିନି ସମାନ କୋଣ ଥିବା ତ୍ରିଭୁଜ।',
        ),
        position: Offset(0.17, 0.70),
      ),
      InteractiveDiagramLabel(
        id: 'isosceles_triangle',
        title: DiagramText(
          en: 'Isosceles triangle',
          hi: 'समद्विबाहु त्रिभुज',
          or: 'ସମଦ୍ୱିବାହୁ ତ୍ରିଭୁଜ',
        ),
        explanation: DiagramText(
          en: 'A triangle with two equal sides and two equal angles.',
          hi: 'दो समान भुजाओं और दो समान कोणों वाला त्रिभुज।',
          or: 'ଦୁଇ ସମାନ ବାହୁ ଓ ଦୁଇ ସମାନ କୋଣ ଥିବା ତ୍ରିଭୁଜ।',
        ),
        position: Offset(0.50, 0.70),
      ),
      InteractiveDiagramLabel(
        id: 'scalene_triangle',
        title: DiagramText(
          en: 'Scalene triangle',
          hi: 'विषमबाहु त्रिभुज',
          or: 'ବିଷମବାହୁ ତ୍ରିଭୁଜ',
        ),
        explanation: DiagramText(
          en: 'A triangle whose three sides have different lengths.',
          hi: 'ऐसा त्रिभुज जिसकी तीनों भुजाओं की लंबाई अलग हो।',
          or: 'ଯେଉଁ ତ୍ରିଭୁଜର ତିନୋଟି ବାହୁର ଲମ୍ବ ଭିନ୍ନ।',
        ),
        position: Offset(0.83, 0.70),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'circle_parts',
    section: DiagramSection.math,
    title: DiagramText(
      en: 'Parts of a Circle',
      hi: 'वृत्त के भाग',
      or: 'ବୃତ୍ତର ଅଂଶ',
    ),
    description: DiagramText(
      en: 'Explore the lines, regions and points used to describe a circle.',
      hi: 'वृत्त का वर्णन करने वाली रेखाओं, क्षेत्रों और बिंदुओं को जानें।',
      or: 'ବୃତ୍ତକୁ ବର୍ଣ୍ଣନା କରୁଥିବା ରେଖା, କ୍ଷେତ୍ର ଓ ବିନ୍ଦୁଗୁଡ଼ିକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/circle_parts.png',
    aspectRatio: 1,
    labels: [
      InteractiveDiagramLabel(
        id: 'centre',
        title: DiagramText(en: 'Centre', hi: 'केंद्र', or: 'କେନ୍ଦ୍ର'),
        explanation: DiagramText(
          en: 'The point equally distant from every point on the circle.',
          hi: 'वह बिंदु जो वृत्त के प्रत्येक बिंदु से समान दूरी पर होता है।',
          or: 'ବୃତ୍ତର ପ୍ରତ୍ୟେକ ବିନ୍ଦୁଠାରୁ ସମାନ ଦୂରତାରେ ଥିବା ବିନ୍ଦୁ।',
        ),
        position: Offset(0.49, 0.49),
      ),
      InteractiveDiagramLabel(
        id: 'radius',
        title: DiagramText(en: 'Radius', hi: 'त्रिज्या', or: 'ବ୍ୟାସାର୍ଦ୍ଧ'),
        explanation: DiagramText(
          en: 'A line segment from the centre to the circle.',
          hi: 'केंद्र से वृत्त तक का रेखाखंड।',
          or: 'କେନ୍ଦ୍ରରୁ ବୃତ୍ତ ପର୍ଯ୍ୟନ୍ତ ରେଖାଖଣ୍ଡ।',
        ),
        position: Offset(0.62, 0.31),
      ),
      InteractiveDiagramLabel(
        id: 'diameter',
        title: DiagramText(en: 'Diameter', hi: 'व्यास', or: 'ବ୍ୟାସ'),
        explanation: DiagramText(
          en: 'A chord through the centre; it equals two radii.',
          hi: 'केंद्र से गुजरने वाली जीवा; यह दो त्रिज्याओं के बराबर होती है।',
          or: 'କେନ୍ଦ୍ର ଦେଇ ଯାଇଥିବା ଜ୍ୟା; ଏହା ଦୁଇ ବ୍ୟାସାର୍ଦ୍ଧ ସହ ସମାନ।',
        ),
        position: Offset(0.18, 0.49),
      ),
      InteractiveDiagramLabel(
        id: 'chord',
        title: DiagramText(en: 'Chord', hi: 'जीवा', or: 'ଜ୍ୟା'),
        explanation: DiagramText(
          en: 'A line segment joining any two points on the circle.',
          hi: 'वृत्त के किन्हीं दो बिंदुओं को जोड़ने वाला रेखाखंड।',
          or: 'ବୃତ୍ତର ଯେକୌଣସି ଦୁଇ ବିନ୍ଦୁକୁ ଯୋଡ଼ୁଥିବା ରେଖାଖଣ୍ଡ।',
        ),
        position: Offset(0.36, 0.18),
      ),
      InteractiveDiagramLabel(
        id: 'arc',
        title: DiagramText(en: 'Arc', hi: 'चाप', or: 'ଚାପ'),
        explanation: DiagramText(
          en: 'A curved portion of the circumference between two points.',
          hi: 'परिधि का दो बिंदुओं के बीच का घुमावदार भाग।',
          or: 'ପରିଧିର ଦୁଇ ବିନ୍ଦୁ ମଧ୍ୟରେ ଥିବା ବକ୍ର ଅଂଶ।',
        ),
        position: Offset(0.81, 0.32),
      ),
      InteractiveDiagramLabel(
        id: 'sector',
        title: DiagramText(en: 'Sector', hi: 'त्रिज्यखंड', or: 'ବୃତ୍ତଖଣ୍ଡ'),
        explanation: DiagramText(
          en: 'A region bounded by two radii and the arc between them.',
          hi: 'दो त्रिज्याओं और उनके बीच के चाप से घिरा क्षेत्र।',
          or: 'ଦୁଇ ବ୍ୟାସାର୍ଦ୍ଧ ଓ ସେମାନଙ୍କ ମଧ୍ୟର ଚାପରେ ଘେରା କ୍ଷେତ୍ର।',
        ),
        position: Offset(0.72, 0.40),
      ),
      InteractiveDiagramLabel(
        id: 'tangent',
        title: DiagramText(en: 'Tangent', hi: 'स्पर्शरेखा', or: 'ସ୍ପର୍ଶକ'),
        explanation: DiagramText(
          en: 'A straight line that touches the circle at exactly one point.',
          hi: 'सीधी रेखा जो वृत्त को ठीक एक बिंदु पर छूती है।',
          or: 'ସିଧା ରେଖା ଯାହା ବୃତ୍ତକୁ ଠିକ୍ ଗୋଟିଏ ବିନ୍ଦୁରେ ସ୍ପର୍ଶ କରେ।',
        ),
        position: Offset(0.92, 0.49),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'solid_shapes',
    section: DiagramSection.math,
    title: DiagramText(
      en: '3D Solids',
      hi: 'त्रिविमीय ठोस',
      or: 'ତ୍ରିମାତ୍ରିକ ଘନବସ୍ତୁ',
    ),
    description: DiagramText(
      en: 'Compare common solids and identify their faces, edges and vertices.',
      hi: 'सामान्य ठोसों की तुलना करें और उनके फलक, किनारे व शीर्ष पहचानें।',
      or: 'ସାଧାରଣ ଘନବସ୍ତୁକୁ ତୁଳନା କରି ସେମାନଙ୍କ ପୃଷ୍ଠ, ଧାର ଓ ଶୀର୍ଷ ଚିହ୍ନନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/solid_shapes.png',
    aspectRatio: 3,
    labels: [
      InteractiveDiagramLabel(
        id: 'cube',
        title: DiagramText(en: 'Cube', hi: 'घन', or: 'ଘନ'),
        explanation: DiagramText(
          en: 'Has 6 square faces, 12 edges and 8 vertices.',
          hi: 'इसके 6 वर्गाकार फलक, 12 किनारे और 8 शीर्ष होते हैं।',
          or: 'ଏହାର ୬ଟି ବର୍ଗାକାର ପୃଷ୍ଠ, ୧୨ଟି ଧାର ଓ ୮ଟି ଶୀର୍ଷ ଅଛି।',
        ),
        position: Offset(0.08, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'cuboid',
        title: DiagramText(en: 'Cuboid', hi: 'घनाभ', or: 'ଆୟତଘନ'),
        explanation: DiagramText(
          en: 'Has 6 rectangular faces, 12 edges and 8 vertices.',
          hi: 'इसके 6 आयताकार फलक, 12 किनारे और 8 शीर्ष होते हैं।',
          or: 'ଏହାର ୬ଟି ଆୟତାକାର ପୃଷ୍ଠ, ୧୨ଟି ଧାର ଓ ୮ଟି ଶୀର୍ଷ ଅଛି।',
        ),
        position: Offset(0.30, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'cylinder',
        title: DiagramText(en: 'Cylinder', hi: 'बेलन', or: 'ବେଲନ'),
        explanation: DiagramText(
          en: 'Has 2 flat circular faces, 1 curved face, 2 curved edges and no vertices.',
          hi: 'इसके 2 समतल वृत्ताकार फलक, 1 वक्र फलक, 2 वक्र किनारे और कोई शीर्ष नहीं होता।',
          or: 'ଏହାର ୨ଟି ସମତଳ ବୃତ୍ତାକାର ପୃଷ୍ଠ, ୧ଟି ବକ୍ର ପୃଷ୍ଠ, ୨ଟି ବକ୍ର ଧାର ଓ କୌଣସି ଶୀର୍ଷ ନାହିଁ।',
        ),
        position: Offset(0.52, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'cone',
        title: DiagramText(en: 'Cone', hi: 'शंकु', or: 'ଶଙ୍କୁ'),
        explanation: DiagramText(
          en: 'Has 1 flat circular face, 1 curved face, 1 curved edge and 1 vertex.',
          hi: 'इसके 1 समतल वृत्ताकार फलक, 1 वक्र फलक, 1 वक्र किनारा और 1 शीर्ष होता है।',
          or: 'ଏହାର ୧ଟି ସମତଳ ବୃତ୍ତାକାର ପୃଷ୍ଠ, ୧ଟି ବକ୍ର ପୃଷ୍ଠ, ୧ଟି ବକ୍ର ଧାର ଓ ୧ଟି ଶୀର୍ଷ ଅଛି।',
        ),
        position: Offset(0.72, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'sphere',
        title: DiagramText(en: 'Sphere', hi: 'गोला', or: 'ଗୋଲକ'),
        explanation: DiagramText(
          en: 'Has 1 curved face and has no edges or vertices.',
          hi: 'इसका 1 वक्र फलक होता है और कोई किनारा या शीर्ष नहीं होता।',
          or: 'ଏହାର ୧ଟି ବକ୍ର ପୃଷ୍ଠ ଅଛି ଏବଂ କୌଣସି ଧାର କିମ୍ବା ଶୀର୍ଷ ନାହିଁ।',
        ),
        position: Offset(0.90, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'face',
        title: DiagramText(en: 'Face', hi: 'फलक', or: 'ପୃଷ୍ଠ'),
        explanation: DiagramText(
          en: 'A flat or curved surface of a solid.',
          hi: 'ठोस की समतल या वक्र सतह।',
          or: 'ଘନବସ୍ତୁର ସମତଳ କିମ୍ବା ବକ୍ର ପୃଷ୍ଠ।',
        ),
        position: Offset(0.26, 0.43),
      ),
      InteractiveDiagramLabel(
        id: 'edge',
        title: DiagramText(en: 'Edge', hi: 'किनारा', or: 'ଧାର'),
        explanation: DiagramText(
          en: 'A line where two faces meet.',
          hi: 'वह रेखा जहाँ दो फलक मिलते हैं।',
          or: 'ଯେଉଁ ରେଖାରେ ଦୁଇଟି ପୃଷ୍ଠ ମିଳେ।',
        ),
        position: Offset(0.18, 0.35),
      ),
      InteractiveDiagramLabel(
        id: 'vertex',
        title: DiagramText(en: 'Vertex', hi: 'शीर्ष', or: 'ଶୀର୍ଷ'),
        explanation: DiagramText(
          en: 'A corner point where edges meet.',
          hi: 'कोने का बिंदु जहाँ किनारे मिलते हैं।',
          or: 'କୋଣର ବିନ୍ଦୁ ଯେଉଁଠାରେ ଧାରଗୁଡ଼ିକ ମିଳେ।',
        ),
        position: Offset(0.05, 0.36),
      ),
    ],
  ),
];
