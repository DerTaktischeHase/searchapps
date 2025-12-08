### searchapps

#`searchapps` ist ein leichtgewichtiges CLI-Tool für Linux, mit dem du installierte Programme schnell durchsuchen kannst.  
Unterstützt werden:

- **APT / dpkg** (Debian, Ubuntu, Linux Mint …)  
- **snap**  
- **flatpak** 

Die Suche erfolgt **case-insensitive** und beruht auf **Teilstrings**.

---
## Wie benutzt man searchapps?

```sh
Usage:
  searchapps               # list all installed apps (apt/snap/flatpak)
  searchapps <pattern>     # search installed apps by name
  searchapps --all <pat>   # search ALL executables in your PATH
  searchapps --help        # show this help
  searchapps --uninstall   # uninstall searchapps
```

---

## Installation

Installiere `searchapps` mit einem einzigen Befehl:

```sh
curl -fsSL https://raw.githubusercontent.com/DerTaktischeHase/searchapps/main/install.sh | sh
```
