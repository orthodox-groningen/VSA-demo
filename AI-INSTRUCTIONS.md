# Wijzigen van de VSA-specificatie

## Doel

Dit document bevat de bindende werkinstructies voor AI-assistenten die bijdragen aan de VSA-specificaties.

AI-assistenten behoren deze instructies te volgen voordat wijzigingen worden voorgesteld of uitgevoerd.

Bij strijdigheid geldt de volgende prioriteit:

1. de VSA-specificatie;
2. CONTRIBUTING.md;
3. dit document;
4. revisiespecifieke prompts.

## Wijzigingen

Voordat een wijziging wordt voorgesteld moet altijd worden bepaald:

- Is dit een normatieve wijziging?
- Is dit een redactionele wijziging?
- Is dit een uitbreiding?
- Is dit een breaking change?

Breaking changes mogen nooit zonder expliciete toestemming worden uitgevoerd.

Nieuwe taalconstructies mogen bestaande documenten niet ongeldig maken.

Verwijder bestaande taalconstructies nooit zonder expliciete toestemming.

Bij twijfel moet de wijziging als breaking worden beschouwd.

Iedere wijziging moet aangeven:

- welke documenten gewijzigd zijn;
- waarom de wijziging nodig is;
- welke versie hierdoor verandert;
- welke implementaties hierdoor geraakt kunnen worden.

## Wijzigingsanalyse

Type wijziging:
- [ ] Redactioneel
- [ ] Verduidelijking
- [ ] Nieuwe functionaliteit
- [ ] Deprecated
- [ ] Breaking change

Normatief?
Ja/Nee

Compatibel met huidige versie?
Ja/Nee

Benodigde versie:
1.x / 2.0

Documenten geraakt:

Risico's:

Motivatie:

## Uitvoering

Voer inhoudelijke wijzigingen nooit direct uit.

Begin altijd met een Wijzigingsanalyse.

Voer de wijziging pas uit nadat de gevolgen voor compatibiliteit en versie zijn vastgesteld.