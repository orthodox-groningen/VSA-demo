# Contributing to VSA

Bedankt voor je bijdrage aan de VSA-specificaties (Vereenvoudigde Slavische Accentnotatie).

Dit document beschrijft de architectuur-, redactie- en terminologieregels die voor het gehele project gelden.

Deze regels zijn van toepassing op zowel menselijke bijdragers als AI-assistenten.

---

# Uitgangspunten

Het primaire doel van VSA is het ontwikkelen van een heldere, formele, onderhoudbare en toekomstvaste specificatie voor de Vereenvoudigde Slavische Accentnotatie.

Daarbij gelden de volgende ontwerpprincipes:

- eenvoud boven complexiteit;
- semantiek vóór implementatie;
- semantiek vóór rendering;
- implementatie-onafhankelijkheid;
- uitbreidbaarheid;
- duidelijke scheiding van verantwoordelijkheden;
- consistente terminologie;
- reproduceerbare resultaten.

---

# Ontwerpfilosofie

VSA is nadrukkelijk géén beschrijving van een implementatie.

De specificatie beschrijft uitsluitend:

- de taal;
- de betekenis (semantiek);
- de architectuur;
- de validatieregels;
- de abstracte modellen;
- de renderer-onafhankelijke principes.

Implementaties volgen uit de specificatie, niet andersom.

---

# Architectuur

De volgende verantwoordelijkheden blijven gescheiden:

- syntax;
- semantiek;
- parser;
- AST;
- validatie;
- abstract glyph model;
- layout;
- rendering;
- SVG;
- configuratie.

Documenten mogen deze verantwoordelijkheden toelichten, maar niet vermengen.

---

# Specificatie

De specificatie is de primaire bron van waarheid.

Nieuwe functionaliteit wordt uitsluitend toegevoegd na expliciete ontwerpbeslissingen.

Bestaande semantiek wordt uitsluitend gewijzigd na expliciete toestemming van de projecteigenaar.

---

# Terminologie

De terminologie ondersteunt de specificatie.

De terminologie vervangt de specificatie niet.

Belangrijke concepten en relaties worden volgens TEv2 vastgelegd.

Normatieve referentie:

https://tno-terminology-design.github.io/tev2-specifications/

Terminologiebestanden:

- bevatten een zo volledig mogelijke TEv2-frontmatter;
- bevatten de formele criteria;
- mogen daarnaast achtergrond, voorbeelden, motivatie en toelichting bevatten;
- mogen organisch groeien;
- wijzigen hun formele definitie uitsluitend na toestemming van de projecteigenaar.

---

# TermRefs

Wanneer voor een concept een terminologiebestand bestaat:

- gebruik overal een TEv2 TermRef;
- gebruik de standaard TEv2-syntax;
- geef waar mogelijk de voorkeur aan Form Phrases;
- onderhoud Form Phrases actief.

---

# Documentstructuur

Ieder document heeft één primaire verantwoordelijkheid.

Voorkom overlap.

Wanneer overlap bewust wordt gebruikt ter verduidelijking of als terminologische toelichting, moet dit duidelijk herkenbaar zijn.

---

# Schrijfstijl

Schrijf:

- technisch;
- precies;
- objectief;
- compact;
- consistent.

Schrijf een referentiespecificatie.

Schrijf geen tutorial.

---

# Normatieve taal

Maak duidelijk onderscheid tussen:

- normatieve tekst;
- informatieve tekst;
- voorbeelden;
- toelichtingen.

Gebruik normatieve taal uitsluitend waar dat werkelijk normatief bedoeld is.

---

# Markdown

Markdown moet zowel goed leesbaar zijn op GitHub als in platte teksteditors (zoals VS Code).

Tabellen:

- hebben vaste kolombreedtes;
- gebruiken minimaal één spatie rond iedere `|`;
- blijven in platte tekst netjes uitgelijnd.

---

# Wijzigingen

Iedere wijziging moet:

- de semantiek behouden;
- de consistentie verbeteren of behouden;
- de onderhoudbaarheid verbeteren;
- de uitbreidbaarheid behouden;
- objectief verdedigbaar zijn.

---

# Wat niet is toegestaan

Niet:

- semantiek wijzigen zonder toestemming;
- architectuur vereenvoudigen ten koste van uitbreidbaarheid;
- ontwerpbeslissingen vervangen door persoonlijke voorkeur;
- informatie verwijderen omdat zij dubbel lijkt;
- documenten herstructureren zonder aantoonbaar voordeel.

---

# Controle

Controleer vóór iedere commit:

- interne consistentie;
- terminologie;
- kruisverwijzingen;
- voorbeelden;
- Markdown-opmaak;
- TEv2 TermRefs;
- TEv2 frontmatter;
- spelling;
- grammatica.

---

# AI-assistenten

AI-assistenten zijn welkom als hulpmiddel.

De uitgebreide instructies voor AI-revisies zijn vastgelegd in:

```
docs/AI-REVIEW-PROMPT.md
```

Wanneer dit document en de AI-reviewprompt strijdig lijken:

- bepaalt dit document de projectregels;
- bepaalt de AI-reviewprompt de werkwijze voor de betreffende revisie.

---

# Projectfilosofie

Een wijziging is alleen een verbetering wanneer zij:

- de specificatie objectiever maakt;
- de specificatie eenduidiger maakt;
- de onderhoudbaarheid verbetert;
- de uitbreidbaarheid behoudt;
- zonder semantische wijziging wordt bereikt.

Bij twijfel geldt altijd:

> Behoud van de bestaande betekenis is belangrijker dan verbetering van de formulering.

## Wijzigingen aan de specificatie

Iedere inhoudelijke wijziging aan de specificatie begint met een Wijzigingsanalyse zoals beschreven in AI-INSTRUCTIONS.md.

Pas nadat deze analyse is voltooid, wordt de daadwerkelijke wijziging voorgesteld.