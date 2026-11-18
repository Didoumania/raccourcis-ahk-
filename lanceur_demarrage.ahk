#Requires AutoHotkey v2.0
; Lanceur de démarrage : ouvre la version « avant » des raccourcis à l'allumage de Windows.
; Mets une copie de ce fichier (ou un raccourci vers lui) dans le dossier de démarrage (Win+R, puis shell:startup).
Sleep(5000)   ; laisse Windows finir de s'installer
Run('"' A_Desktop '\Raccourcis Claude\Versions\raccourcis_version_avant.ahk"')
ExitApp
