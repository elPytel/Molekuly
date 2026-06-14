# Molekuly
Karetní hra ve stylu Rummikup či Žolíků, která je o stavbě molekul

## Pravidla hry

Viz [DOC/rules.md](DOC/rules.md)

## Sestavení balíčku

Pro sestavení základního balíčku stačí spusti příkaz:

```bash
make
```

Ten spustí pipeline: `xml` -> `xslt` -> `html` -> `pdf` a vytvoří soubory ve složkách `out` a `pages`.

## DLC

Ve složce `cards` jsou jednotlivé balíčky (DLC) s kartami. Každý balíček má vlastní složku a obsahuje soubory `atoms.xml` a `molecules.xml`.

Pro sestavení balíčku s vybranými DLC je možné spustit příkaz:

```bash
make clean
make DLC_NAMES="vitamins"
```

### Jednotlivé DLC

- [DLC: Vitamíny](DOC/vitam%C3%ADny.md)
- [DLC: Metalurgie](DOC/metallurgy.md)