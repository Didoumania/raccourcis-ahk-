#Requires AutoHotkey v2.0
#SingleInstance Force

; Couleurs par rôle (changer une valeur ici change tous les boutons du même rôle).
couleurCapture := "8EC5FC"   ; bleu ciel : captures
couleurEdition := "B5EAD7"   ; vert menthe : copier/annuler/sélectionner
couleurEffacer := "FF9AA2"   ; rose : effacer
couleurNavig   := "D4B8F0"   ; lilas pastel : défilement, Tab, Entrée, Alt+Tab, flèches
couleurZoom    := "FFE29A"   ; jaune pâle : zoom et tout réduire
couleurClavier := "FFC8A2"   ; pêche : clavier
couleursTexte := Map()       ; couleur du texte par bouton (blanc par défaut)

; Bouton coloré : un cadre de texte cliquable (les boutons Windows ne peuvent pas être colorés).
; Un texte sur une ligne est centré tout seul ; sur deux lignes ("A`nB") on ajoute une ligne vide au-dessus.
BoutonCouleur(g, pos, texte, couleur, texteCouleur := "1E1E1E") {
    options := pos " +0x100 +Center Background" couleur
    if (!InStr(texte, "`n"))
        options .= " +0x200"
    else
        texte := "`n" texte
    bouton := g.AddText(options, texte)
    couleursTexte[bouton.Hwnd] := texteCouleur
    bouton.SetFont("c" texteCouleur)
    return bouton
}

flechesH := 188   ; hauteur du bloc ▲▼ (défini ici car utilisé par la barre gauche)

barW := 100
barH := 1028

MonitorGetWorkArea(MonitorGetPrimary(), &zoneGauche, &zoneHaut, &zoneDroite, &zoneBas)
leftX := zoneGauche
leftBarH := 972 ; boutons discussion en haut, puis espace vide avant CAPTURE, jusqu'à la touche Tab
leftY := A_ScreenHeight - leftBarH - 5

rightX := A_ScreenWidth - barW
rightY := A_ScreenHeight - barH - 5


; =========================
; BARRE GAUCHE
; =========================

gauche := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 -DPIScale")
gauche.SetFont("s13", "Segoe UI")

gauche.SetFont("s11 w700 c1E1E1E", "Segoe UI")
btnCapture := BoutonCouleur(gauche, "x4 y226 w92 h92", "CAPTURE`nÉCRAN", couleurCapture)
btnZone := BoutonCouleur(gauche, "x4 y322 w92 h92", "CAPTURE`nZONE", couleurCapture)
btnCaptures := BoutonCouleur(gauche, "x4 y418 w92 h92", "CAPTURE`nCLAUDE", couleurCapture)
btnSupprimer := BoutonCouleur(gauche, "x4 y538 w92 h92", "EFFACER", couleurEffacer)
btnAnnuler := BoutonCouleur(gauche, "x4 y658 w92 h92", "ANNULER", couleurEdition)
btnRetablir := BoutonCouleur(gauche, "x4 y754 w92 h92", "RÉTABLIR", couleurEdition)

gauche.SetFont("s13 w700 c1E1E1E", "Segoe UI")
btnDiscussionHaut := BoutonCouleur(gauche, "x4 y10 w92 h92", "DISC. ↑", couleurNavig)
btnDiscussionBas := BoutonCouleur(gauche, "x4 y106 w92 h92", "DISC. ↓", couleurNavig)

gauche.SetFont("s" Round(34 * 96 / A_ScreenDPI) " w700 c1E1E1E", "Segoe UI Symbol")
btnTab := BoutonCouleur(gauche, "x4 y874 w92 h92", "⇥", couleurNavig)



; =========================
; ACTIONS GAUCHE
; =========================

btnCapture.OnEvent("Click", CaptureEcran)
btnZone.OnEvent("Click", CaptureZone)
btnCaptures.OnEvent("Click", CaptureVersClaude)
; EFFACER : retour arrière ; en maintenant le clic, ça efface en continu (voir SurveillerEffacer).
btnAnnuler.OnEvent("Click", (*) => Send("^z"))
btnRetablir.OnEvent("Click", (*) => Send("^y"))


btnTab.OnEvent("Click", (*) => Send("{Tab}"))
btnDiscussionHaut.OnEvent("Click", (*) => DefilerDiscussion("WheelUp"))
btnDiscussionBas.OnEvent("Click", (*) => DefilerDiscussion("WheelDown"))



; =========================
; BARRE DROITE
; =========================

droite := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 -DPIScale")
droite.SetFont("s13", "Segoe UI")

droite.SetFont("s11 w700 c1E1E1E", "Segoe UI")
btnToutReduire := BoutonCouleur(droite, "x4 y10 w92 h92", "TOUT`nRÉDUIRE", couleurZoom, "1E1E1E")
btnZoomPlus := BoutonCouleur(droite, "x4 y106 w92 h92", "ZOOM +", couleurZoom, "1E1E1E")
btnZoomMoins := BoutonCouleur(droite, "x4 y202 w92 h92", "ZOOM -", couleurZoom, "1E1E1E")
btnZoomNormal := BoutonCouleur(droite, "x4 y298 w92 h92", "ZOOM`n100 %", couleurZoom, "1E1E1E")
btnSelectionner := BoutonCouleur(droite, "x4 y418 w92 h92", "TOUT`nSÉLECT.", couleurEdition)
btnCopier := BoutonCouleur(droite, "x4 y514 w92 h92", "COPIER", couleurEdition)
btnColler := BoutonCouleur(droite, "x4 y610 w92 h92", "COLLER", couleurEdition)

btnClavier := BoutonCouleur(droite, "x4 y730 w92 h92", "CLAVIER", couleurClavier)

droite.SetFont("s" Round(34 * 96 / A_ScreenDPI) " w700 c1E1E1E", "Segoe UI Symbol")

btnEntree := BoutonCouleur(droite, "x4 y850 w92 h92", "⏎", couleurNavig)
btnAltTab := BoutonCouleur(droite, "x4 y946 w92 h92", "⇆", couleurNavig)


; =========================
; ACTIONS DROITE
; =========================

btnSelectionner.OnEvent("Click", (*) => Send("^a"))
btnCopier.OnEvent("Click", (*) => Send("^c"))
btnColler.OnEvent("Click", (*) => Send("^v"))

btnToutReduire.OnEvent("Click", (*) => Send("#d"))   ; Windows + D : affiche le Bureau, un second clic remet tout
btnZoomPlus.OnEvent("Click", (*) => Send("^+{=}"))
btnZoomMoins.OnEvent("Click", ZoomMoinsAction)
btnZoomNormal.OnEvent("Click", ZoomNormalAction)

btnClavier.OnEvent("Click", ClavierVisuel)
btnEntree.OnEvent("Click", (*) => Send("{Enter}"))
btnAltTab.OnEvent("Click", (*) => Send("!{Tab}"))


; =========================
; EFFACER (retour arrière, avec répétition)
; =========================

SetTimer(SurveillerEffacer, 25)

; Un appui efface un caractère à gauche du curseur ; si on maintient le clic, après 0,4 s
; ça répète rapidement, comme une vraie touche de clavier.
SurveillerEffacer() {
    static enBas := false, debut := 0, dernier := 0
    MouseGetPos(, , , &controleSous, 2)
    appui := GetKeyState("LButton", "P") && (controleSous = btnSupprimer.Hwnd)
    if (appui && !enBas) {
        enBas := true
        debut := A_TickCount
        dernier := A_TickCount
        Send("{BackSpace}")
    } else if (appui && enBas) {
        if (A_TickCount - debut > 400 && A_TickCount - dernier > 45) {
            Send("{BackSpace}")
            dernier := A_TickCount
        }
    } else if (!appui) {
        enBas := false
    }
}


; =========================
; CLAVIER VISUEL
; =========================

; Clavier visuel de Windows : le bouton l'ouvre, ou le fait remonter tout de suite s'il est minimisé.
ClavierVisuel(*) {
    h := WinExist("ahk_class OSKMainClass")
    if (!h)
        h := WinExist("ahk_exe osk.exe")
    if (!h) {
        Run("osk.exe")
        return
    }
    try PostMessage(0x112, 0xF120, 0, , "ahk_id " h)   ; WM_SYSCOMMAND + SC_RESTORE : restaure sans attendre
    try WinShow("ahk_id " h)
}


; =========================
; ZOOM
; =========================

ZoomMoinsAction(*) {
    SendEvent("{Ctrl down}{vk6D down}{vk6D up}{Ctrl up}")
}

ZoomNormalAction(*) {
    SendEvent("{Ctrl down}{vk30 down}{vk30 up}{Ctrl up}")
}


; =========================
; AFFICHAGE
; =========================

; Les tailles des contrôles sont logiques ; WinMove utilise les coordonnées écran.
AdapterBarre(gauche, leftBarH, zoneGauche, false, 0, ReserveFleches())
AdapterBarre(droite, barH + 20, zoneDroite, true, 0)

; Les barres réservent leur place sur les côtés de l'écran, comme la barre des tâches :
; les fenêtres s'arrêtent à leur bord et ne passent plus dessous.
barreAppGauche := ReserverPlace(gauche, 0)   ; 0 = bord gauche
barreAppDroite := ReserverPlace(droite, 2)   ; 2 = bord droit
OnExit(LibererPlace)

; Déclare la fenêtre à Windows comme « barre d'application » (SHAppBarMessage) sur un bord
; de l'écran principal. Renvoie la structure à réutiliser pour libérer la place.
ReserverPlace(barre, bord) {
    global barW
    static message := DllCall("RegisterWindowMessage", "Str", "BarreRaccourcisAppBar", "UInt")
    MonitorGet(MonitorGetPrimary(), &mg, &mh, &md, &mb)
    abd := Buffer(48, 0)                       ; structure APPBARDATA (64 bits)
    NumPut("UInt", 48, abd, 0)                 ; cbSize
    NumPut("Ptr", barre.Hwnd, abd, 8)          ; hWnd
    NumPut("UInt", message, abd, 16)           ; uCallbackMessage
    NumPut("UInt", bord, abd, 20)              ; uEdge
    DllCall("shell32\SHAppBarMessage", "UInt", 0, "Ptr", abd)     ; ABM_NEW
    NumPut("Int", bord = 0 ? mg : md - barW, abd, 24)             ; rc.left
    NumPut("Int", mh, abd, 28)                                    ; rc.top
    NumPut("Int", bord = 0 ? mg + barW : md, abd, 32)             ; rc.right
    NumPut("Int", mb, abd, 36)                                    ; rc.bottom
    DllCall("shell32\SHAppBarMessage", "UInt", 2, "Ptr", abd)     ; ABM_QUERYPOS
    if (bord = 0)
        NumPut("Int", NumGet(abd, 24, "Int") + barW, abd, 32)
    else
        NumPut("Int", NumGet(abd, 32, "Int") - barW, abd, 24)
    DllCall("shell32\SHAppBarMessage", "UInt", 3, "Ptr", abd)     ; ABM_SETPOS
    return abd
}

; À la fermeture du script, rend la place à Windows.
LibererPlace(*) {
    global barreAppGauche, barreAppDroite
    DllCall("shell32\SHAppBarMessage", "UInt", 1, "Ptr", barreAppGauche)   ; ABM_REMOVE
    DllCall("shell32\SHAppBarMessage", "UInt", 1, "Ptr", barreAppDroite)
}

; La barre occupe toute la hauteur de la zone de travail (du haut de l'écran jusqu'à la barre
; des tâches). Les boutons dont la position d'origine est >= seuil descendent en bas de la barre ;
; les autres restent en haut. L'espace en trop se retrouve entre les deux groupes.
AdapterBarre(barre, hauteurOriginale, bord, alignerDroite, seuil, reserveBas := 0) {
    global barW
    static positions := Map()
    MonitorGetWorkArea(MonitorGetPrimary(), &g, &h, &d, &b)
    hauteurZone := b - h - reserveBas
    facteur := Min(1.0, (hauteurZone - 10) / hauteurOriginale)
    decalage := Max(0, hauteurZone - 5 - Round(hauteurOriginale * facteur))
    for controle in barre {
        if (!positions.Has(controle.Hwnd)) {
            controle.GetPos(&x, &y, &w, &hc)
            positions[controle.Hwnd] := [x, y, w, hc]
        }
        p := positions[controle.Hwnd]
        yFinal := Round(p[2] * facteur) + (p[2] >= seuil ? decalage : 0)
        controle.Move(p[1], yFinal, p[3], Max(1, Round(p[4] * facteur)))
        symbole := InStr("⇥⏎⇆", controle.Text)
        taillePolice := symbole ? 34 : (InStr(controle.Text, "DISC.") ? 13 : 11)
        controle.SetFont("s" Max(8, Round(taillePolice * facteur * 96 / A_ScreenDPI)) " w700 c" couleursTexte.Get(controle.Hwnd, "1E1E1E"), symbole ? "Segoe UI Symbol" : "Segoe UI")
    }
    barre.Show("NoActivate w" barW " h" (hauteurZone - 5))
    barre.GetPos(, , &largeurReelle, &hauteurReelle)
    WinMove(alignerDroite ? d - largeurReelle : g, h, , , "ahk_id " barre.Hwnd)
}

; Placement calculé une seule fois au lancement pour conserver une taille stable.
; =========================
; TOUJOURS DEVANT
; =========================

; =========================
; FLÈCHES ▲ ▼ (bas gauche, par-dessus la barre des tâches)
; =========================

; Deux flèches l'une au-dessus de l'autre, collées en bas à gauche de l'écran : elles
; descendent par-dessus la barre des tâches (et son widget). Symboles deux fois plus gros qu'avant.
fleches := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 -DPIScale")
fleches.MarginX := 0
fleches.MarginY := 0
fleches.SetFont("s" Round(44 * 96 / A_ScreenDPI) " w700 c1E1E1E", "Segoe UI Symbol")
btnMonter := BoutonCouleur(fleches, "x4 y0 w92 h92", "▲", couleurNavig)
btnMonter.OnEvent("Click", (*) => Send("{Up}"))
btnDescendre := BoutonCouleur(fleches, "x4 y96 w92 h92", "▼", couleurNavig)
btnDescendre.OnEvent("Click", (*) => Send("{Down}"))
MonitorGet(MonitorGetPrimary(), &ecranG)   ; bord gauche de l'écran (la zone de travail commence après la barre gauche)
MonitorGetWorkArea(MonitorGetPrimary(), , , , &zoneBasF)   ; bas de la zone de travail = haut de la barre des tâches
fleches.Show("NoActivate x" ecranG " y" (zoneBasF - flechesH) " w100 h" flechesH)

; Place à garder libre au-dessus de la barre des tâches pour que la barre gauche s'arrête avant les flèches.
ReserveFleches() {
    global flechesH
    return flechesH + 5   ; les flèches sont au-dessus de la barre des tâches : la barre gauche s'arrête avant
}

; =========================
; RECHARGEMENT AUTOMATIQUE
; =========================

; Quand ce fichier est remplacé par une nouvelle version, le script se relance tout seul.
dernierChangement := FileGetTime(A_ScriptFullPath, "M")
SetTimer(VerifierMiseAJour, 2000)

VerifierMiseAJour() {
    global dernierChangement
    if (FileGetTime(A_ScriptFullPath, "M") != dernierChangement) {
        Sleep(800)   ; laisse finir l'écriture du fichier
        Reload()
    }
}

SetTimer(GarderDevant, 1000)

GarderDevant() {
    try WinSetAlwaysOnTop(1, "ahk_id " gauche.Hwnd)
    try WinSetAlwaysOnTop(1, "ahk_id " droite.Hwnd)
    try WinSetAlwaysOnTop(1, "ahk_id " fleches.Hwnd)
}

; Défilement au centre du contenu de la fenêtre active, sans cliquer ni saisir de texte.
; Le pointeur revient à son emplacement initial après les quatre crans de molette.
DefilerDiscussion(direction) {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&ancienX, &ancienY)
    try {
        cible := WinExist("A")
        if (!cible || cible = gauche.Hwnd || cible = droite.Hwnd)
            return
        WinGetClientPos(&x, &y, &largeur, &hauteur, "ahk_id " cible)
        if (largeur < 200 || hauteur < 200)
            return
        MouseMove(x + Round(largeur * 0.60), y + Round(hauteur * 0.45), 0)
        Sleep(60)
        SendEvent("{" direction " 4}")
        Sleep(60)
    } finally {
        MouseMove(ancienX, ancienY, 0)
    }
}

; CAPTURE CLAUDE : capture tout l'écran tel qu'il est (n'importe quelle application), puis
; envoie l'image dans Claude : la fenêtre est retrouvée, restaurée si elle est minimisée,
; mise au premier plan, et l'image y est collée. Valide ensuite avec Entrée.
CaptureVersClaude(*) {
    static occupe := false
    if (occupe)
        return
    occupe := true
    btnCaptures.Enabled := false
    btnCaptures.Text := "EN COURS"
    CoordMode("Mouse", "Screen")
    MouseGetPos(&ancienX, &ancienY)
    try {
        courante := WinExist("A")
        gauche.Hide()
        droite.Hide()
        Sleep(150)
        if (!CapturerEcran()) {
            MsgBox("La capture a échoué. Aucune image n'a été copiée.", "CAPTURE CLAUDE")
            return
        }
        claude := TrouverFenetreClaude(courante)
        if (!claude) {
            MsgBox("Capture prête dans le presse-papiers, mais aucune fenêtre Claude trouvée. Ouvre Claude puis COLLER.", "CAPTURE CLAUDE")
            return
        }
        if (WinGetMinMax("ahk_id " claude) = -1)
            WinRestore("ahk_id " claude)
        WinActivate("ahk_id " claude)
        if (!WinWaitActive("ahk_id " claude, , 3)) {
            MsgBox("Capture prête dans le presse-papiers. Va dans Claude puis COLLER.", "CAPTURE CLAUDE")
            return
        }
        Sleep(500)
        SendEvent(ToucheCollage(claude))
        Sleep(700)
        ToolTip("Capture collée dans Claude : attends la miniature, puis Entrée.")
        SetTimer(() => ToolTip(), -3500)
    } catch as erreur {
        MsgBox("Capture non collée : " erreur.Message, "CAPTURE CLAUDE")
    } finally {
        btnCaptures.Text := "CAPTURE CLAUDE"
        btnCaptures.Enabled := true
        gauche.Show("NoActivate")
        droite.Show("NoActivate")
        MouseMove(ancienX, ancienY, 0)
        occupe := false
    }
}

; Cherche la fenêtre Claude : 1) la fenêtre active si c'est déjà Claude, 2) l'appli Claude,
; 3) un terminal ou un navigateur dont le titre contient « Claude » (Claude Code, claude.ai).
TrouverFenetreClaude(courante) {
    if (courante && EstFenetreClaude(courante))
        return courante
    if (h := WinExist("ahk_exe Claude.exe"))
        return h
    for h in WinGetList() {
        if (h = gauche.Hwnd || h = droite.Hwnd)
            continue
        if (EstFenetreClaude(h))
            return h
    }
    return 0
}

EstFenetreClaude(h) {
    exe := StrLower(WinGetProcessName("ahk_id " h))
    if (exe = "claude.exe")
        return true
    candidats := "|windowsterminal.exe|cmd.exe|powershell.exe|pwsh.exe|conhost.exe|wezterm-gui.exe|alacritty.exe|mintty.exe|chrome.exe|msedge.exe|firefox.exe|opera.exe|brave.exe|"
    return InStr(candidats, "|" exe "|") && InStr(WinGetTitle("ahk_id " h), "Claude")
}

; Claude Code dans un terminal Windows colle les images avec Alt+V ; ailleurs c'est Ctrl+V.
ToucheCollage(fenetre) {
    exe := StrLower(WinGetProcessName("ahk_id " fenetre))
    terminaux := "|windowsterminal.exe|cmd.exe|powershell.exe|pwsh.exe|conhost.exe|wezterm-gui.exe|alacritty.exe|mintty.exe|"
    return InStr(terminaux, "|" exe "|") ? "!v" : "^v"
}

; ===== Capture d'écran : fonctions communes =====

; Crée une image de l'écran principal entier (bitmap compatible écran). Renvoie son handle, ou 0.
CreerBitmapEcran() {
    largeur := A_ScreenWidth
    hauteur := A_ScreenHeight
    hdcEcran := DllCall("GetDC", "Ptr", 0, "Ptr")
    hdcMem := DllCall("CreateCompatibleDC", "Ptr", hdcEcran, "Ptr")
    hbm := DllCall("CreateCompatibleBitmap", "Ptr", hdcEcran, "Int", largeur, "Int", hauteur, "Ptr")
    if (hbm) {
        ancien := DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hbm, "Ptr")
        DllCall("BitBlt", "Ptr", hdcMem, "Int", 0, "Int", 0, "Int", largeur, "Int", hauteur
            , "Ptr", hdcEcran, "Int", 0, "Int", 0, "UInt", 0x00CC0020 | 0x40000000)
        DllCall("SelectObject", "Ptr", hdcMem, "Ptr", ancien)
    }
    DllCall("DeleteDC", "Ptr", hdcMem)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdcEcran)
    return hbm
}

; Met l'image dans le presse-papiers (le système en devient propriétaire). Renvoie vrai/faux.
MettreSurPressePapiers(hbm) {
    ok := false
    if (DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)) {
        DllCall("EmptyClipboard")
        ok := DllCall("SetClipboardData", "UInt", 2, "Ptr", hbm, "Ptr") != 0
        DllCall("CloseClipboard")
    }
    if (!ok)
        DllCall("DeleteObject", "Ptr", hbm)
    return ok
}

; Copie l'écran dans le presse-papiers (utilisé par CAPTURE CLAUDE).
CapturerEcran() {
    hbm := CreerBitmapEcran()
    return hbm ? MettreSurPressePapiers(hbm) : false
}

; ===== Boutons =====

; CAPTURE ÉCRAN : tout l'écran, copié dans le presse-papiers (Ctrl+V pour le coller où tu veux).
; Les barres sont cachées le temps de la prise.
CaptureEcran(*) {
    static occupe := false
    if (occupe)
        return
    occupe := true
    ok := false
    try {
        gauche.Hide()
        droite.Hide()
        Sleep(250)
        ok := CapturerEcran()
    } finally {
        gauche.Show("NoActivate")
        droite.Show("NoActivate")
        occupe := false
    }
    ToolTip(ok ? "Capture copiée dans le presse-papiers." : "La capture a échoué.")
    SetTimer(() => ToolTip(), -2500)
}

; CAPTURE ZONE : tu sélectionnes une zone (outil de capture Windows) ; elle est copiée dans le presse-papiers.
CaptureZone(*) {
    Send("#+s")
}
