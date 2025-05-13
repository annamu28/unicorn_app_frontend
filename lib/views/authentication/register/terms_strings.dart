class TermsStrings {
  // Content strings
  static const String title = 'Privaatsustingimused ja kasutusreeglid';
  
  static const String section1Title = '1. Rakenduse sihtrühm ja ligipääs';
  static const String section1Content = 'Käesolev rakendus on mõeldud kasutamiseks ainult MTÜ HK Unicorn Squad liikmetele, sealhulgas juhendajatele, abijuhendajatele ja õpilastele. Avalikku registreerimist ei toimu — kõik kasutajad kinnitatakse juhendaja või administraatori poolt.';

  static const String section2Title = '2. Isikuandmete töötlemine';
  static const String section2Subtitle = 'Rakenduses kogutakse järgmisi andmeid:';
  static const List<String> section2Data = [
    'Eesnimi',
    'Perekonnanimi (või pseudonüüm)',
    'Sünnikuupäev',
    'E-posti aadress',
  ];
  static const String section2UsageTitle = 'Isikuandmeid kasutatakse:';
  static const List<String> section2Usage = [
    'kasutajakonto loomiseks ja grupipõhiseks autentimiseks;',
    'suhtluse korraldamiseks kindlates jututubades (chatboard);',
    'kohaloleku jälgimiseks ja tagasiside kogumiseks;',
    'Koos.io tokenite seostamiseks e-maili kaudu;',
    'statistilisteks ja analüütilisteks eesmärkideks (nt sünnikuupäeva põhjal demograafiline jaotus, vanuseline statistika jmt).',
  ];

  static const String section3Title = '3. Alaealiste andmed ja vanemlik nõusolek';
  static const String section3Content = 'Kuna suur osa kasutajatest on alla 16-aastased, toimub nende isikuandmete töötlemine üksnes vanema või eestkostja selgesõnalise nõusoleku alusel. Selle nõusoleku olemasolu eest vastutab lapse registreerimisel vastav juhendaja või administraator, kes kinnitab, et vajalik nõusolek on saadud.';

  static const String section4Title = '4. Turvalisus ja privaatsus';
  static const List<String> section4Content = [
    'Kõik isikuandmed hoitakse turvaliselt ning nendele pääseb ligi ainult volitatud isik (nt juhendaja või administraator).',
    'Rakenduses ei ole võimalik saata privaatsõnumeid ega jagada fotosid.',
    'Jututuba on piiratud grupisisese suhtlusega ning juhendajatel on õigus eemaldada sobimatu sisu või kasutajad.',
  ];

  static const String section5Title = '5. Õigused andmesubjektina';
  static const String section5Subtitle = 'Igal kasutajal (või tema seaduslikul esindajal) on õigus:';
  static const List<String> section5Rights = [
    'küsida, milliseid andmeid tema kohta säilitatakse;',
    'taotleda andmete parandamist või kustutamist;',
    'võtta tagasi nõusolek andmete töötlemiseks (millega kaasneb konto deaktiveerimine).',
  ];
  static const String section5Contact = 'Andmete töötlejaks on MTÜ HK Unicorn Squad. Küsimuste korral palume pöörduda e-posti teel: [sisesta MTÜ kontaktmeil].';

  static const String agreementText = 'Registreerides konto, nõustute käesolevate tingimustega.';

  // Style-related strings
  static const double titleFontSize = 20.0;
  static const double sectionTitleFontSize = 18.0;
  static const double sectionSubtitleFontSize = 16.0;
  static const double contentFontSize = 16.0;
  static const double agreementFontSize = 16.0;
  
  static const double sheetInitialSize = 0.7;
  static const double sheetMinSize = 0.5;
  static const double sheetMaxSize = 0.95;
  
  static const double padding = 20.0;
  static const double bottomPadding = 8.0;
  static const double spacing = 20.0;
  static const double smallSpacing = 10.0;
} 