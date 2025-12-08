## searchapps

 `searchapps` ist ein leichtgewichtiges CLI-Tool für Linux, mit dem du die namen installierter Programme schnell finden kannst um sie direkt in CLI auszuführen.  

---


## Unterstützt werden:
- **APT / dpkg** (Debian, Ubuntu, Linux Mint …)  
- **snap**  
- **flatpak** 

Die Suche erfolgt **case-insensitive** und beruht auf **Teilstrings**.

---

## Installation

Installiere `searchapps` mit einem einzigen Befehl:

```sh
curl -fsSL https://raw.githubusercontent.com/DerTaktischeHase/searchapps/main/install.sh | sh
```

## Wie benutzt man searchapps?

```sh
searchapps               # list all installed apps (apt/snap/flatpak)
searchapps <pattern>     # search installed apps by name
searchapps --all <pat>   # search ALL executables in your PATH
searchapps --help        # show this help
searchapps --uninstall   # uninstall searchapps
```
