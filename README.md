Educational Processing Unit (EPU)
=================================
Eine 16-Bit CPU, geschrieben in VHDL, welche dazu dient, den Arbeitsablauf einer CPU zu lehren.

Struktur
--------
```
├── doc (Dokumentation)
│   ├── img/ (Bilddateien der Dokumentation)
│   ├── *.tex (LaTeX-Dateien)
│   └── master.pdf (Dokumentation im PDF-Format)
├── easm (Assembler)
│   ├── easm.py (Assemblerskript, mehr Info mit folgender Befehl: ./easm.py --help)
│   └── testfiles/ (Beispielprogramme)
├── ise (Dateien für die Entwicklungsumgebung)
│   ├── ipcore_dir/ (Speicherblöcke)
│   └── WaxwingSpartan6DevBoard.ucf (Pinbelegung des FPGA)
├── numato-loader (Tool zum Flashen des FPGA)
├── serial_communication.py (Serielle Kommunikation mit dem FPGA)
├── uart_log.txt (Logdatei der letzten seriellen Kommunikation)
└── vhdl (Projektdateien)
    ├── core (Der "Kern" der EPU)
    ├── dependencies (Externe Abhängigkeiten)
    ├── mem (Speichercontroller & am Speicher angeschlossene Module)
    ├── sim (Für die Simulation notwendige Dateien)
    ├── test (Dateien für Testzwecke)
    └── top (Oberste Ebene der EPU & Frequenzteiler)
```
