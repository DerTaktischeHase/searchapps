## searchapps

`searchapps` ist ein leichtgewichtiges CLI-Tool für Linux, mit dem du schnell
herausfinden kannst, **welche Befehle in deiner aktuellen Shell verfügbar sind**,
um sie direkt über die Kommandozeile auszuführen.

Die Suche erfolgt **case-insensitive** und basiert auf **Teilstrings**.

---

## Was macht searchapps genau?

`searchapps` durchsucht alle **in der aktuellen Shell bekannten Kommandos** und
filtert sie nach einem Suchbegriff.

Dazu gehören – abhängig von der Umgebung – unter anderem:
- ausführbare Programme im `PATH`
- Shell-Builtins
- Aliases

`searchapps` ist **kein Paketmanager**.  
Es installiert, entfernt oder verwaltet **keine** Software.

---

## Unterstützte Installationsarten

Programme werden gefunden, **sofern sie als ausführbarer Befehl im `PATH` verfügbar sind**.

Das trifft in der Praxis typischerweise auf folgende Installationsarten zu:

- **APT / dpkg** (Debian, Ubuntu, Linux Mint …)
- **snap**  
  (über `/snap/bin`, sofern dieses Verzeichnis im `PATH` liegt)
- **flatpak**
  - CLI-Programme mit Export eines Befehls in den `PATH`
  - GUI-only-Flatpaks ohne Kommando werden **nicht** angezeigt

> Hinweis:  
> `searchapps` sucht nach **Kommandos**, nicht nach grafischen Anwendungen oder
> `.desktop`-Einträgen.

---

## Installation

Installiere `searchapps` mit einem einzigen Befehl:

```sh
curl -fsSL https://raw.githubusercontent.com/DerTaktischeHase/searchapps/main/install.sh | sh
```

---

## Installation (Details)

Der Installer:

- lädt das eigentliche Tool herunter
- erstellt den Befehl `searchapps`
- stellt sicher, dass das Zielverzeichnis im `PATH` verfügbar ist

---

## Benutzung

```sh
searchapps <query>
searchapps --help
searchapps --uninstall
```

## Deinstallation

```sh
searchapps --uninstall
```
