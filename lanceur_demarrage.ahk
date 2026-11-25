#Requires AutoHotkey v2.0
; Lanceur de démarrage : ouvre les raccourcis (avec le smiley Regarde) à l'allumage de Windows.
; L'ancienne version sans smiley reste disponible : Versions\raccourcis_version_avant.ahk
Sleep(5000)   ; laisse Windows finir de s'installer
Run('"' A_Desktop '\Raccourcis Claude\raccourcis.ahk"')
ExitApp
