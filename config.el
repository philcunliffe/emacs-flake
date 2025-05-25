;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory (getenv "ORG_HOME"))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
(use-package obsidian
  :config
  (global-obsidian-mode t)
  (obsidian-backlinks-mode t)
  :custom
  ;; location of obsidian vault
  (obsidian-directory (file-truename (getenv "GARDEN_HOME")))
  ;; Default location for new notes from `obsidian-capture'
  (obsidian-inbox-directory "Inbox")
  ;; Useful if you're going to be using wiki links
  (markdown-enable-wiki-links t)

  ;; These bindings are only suggestions; it's okay to use other bindings
  :bind (:map obsidian-mode-map
              ;; Create note
              ("C-c C-n" . obsidian-capture)
              ;; If you prefer you can use `obsidian-insert-wikilink'
              ("C-c C-l" . obsidian-insert-link)
              ;; Open file pointed to by link at point
              ("C-c C-o" . obsidian-follow-link-at-point)
              ;; Open a different note from vault
              ("C-c C-p" . obsidian-jump)
              ;; Follow a backlink for the current file
              ("C-c C-b" . obsidian-backlink-jump)))

(use-package! org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename (getenv "ORG_HOME")))
  (setq org-roam-file-extensions '("org"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template (concat "${hierarchy}:${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol)
  )

(use-package consult-org-roam
   :ensure t
   :after org-roam
   :init
   (require 'consult-org-roam)
   ;; Activate the minor mode
   (consult-org-roam-mode 1)
   :custom
   ;; Use `ripgrep' for searching with `consult-org-roam-search'
   (consult-org-roam-grep-func #'consult-ripgrep)
   ;; Configure a custom narrow key for `consult-buffer'
   (consult-org-roam-buffer-narrow-key ?r)
   ;; Display org-roam buffers right after non-org-roam buffers
   ;; in consult-buffer (and not down at the bottom)
   (consult-org-roam-buffer-after-buffers t)
   :config
   ;; Eventually suppress previewing for certain functions
   (consult-customize
    consult-org-roam-forward-links
    :preview-key "M-.")
(setq org-roam-capture-templates
      '(("c" "Contact" plain
         "%?"
         :if-new (file+head "${slug}.org"
                            "#+title: ${hierarchy-title}\n:PROPERTIES:\n:ROAM_TAGS: contact\n:EMAIL:\n:PHONE:\n:ORGANIZATION:\n:END:\n\n")
         :unnarrowed t)

        ("n" "Note" plain
         "%?"
         :if-new (file+head "${slug}.org"
                            "#+title: ${hierarchy-title}\n:PROPERTIES:\n:ROAM_TAGS: note\n:END:\n\n")
         :unnarrowed t)

        ("t" "Todo" plain
         "%?"
         :if-new (file+head "${slug}.org"
                            "#+title: TODO ${hierarchy-title}")
         :unnarrowed t)

        ("p" "Project" plain
         "%?"
         :if-new (file+head "${slug}.org"
                            "#+title: ${hierarchy-title}\n:PROPERTIES:\n:ROAM_TAGS: project\n:END:\n\n")
         :unnarrowed t)
        ("d" "default" plain
         "%?"
         :if-new (file+head "${slug}.org"
                            "#+title: ${hierarchy-title}\n")
         :immediate-finish t
         :unnarrowed t)
        ))
   :bind (("C-c n e" . consult-org-roam-file-find)
          ("C-c n b" . consult-org-roam-backlinks)
          ("C-c n B" . consult-org-roam-backlinks-recursive)
          ("C-c n l" . consult-org-roam-forward-links)
          ("C-c n r" . consult-org-roam-search))
   )

(use-package org-recur
  :hook ((org-mode . org-recur-mode)
         (org-agenda-mode . org-recur-agenda-mode))
  :demand t
  :config
  (define-key org-recur-mode-map (kbd "C-c d") 'org-recur-finish)

  ;; Rebind the 'd' key in org-agenda (default: `org-agenda-day-view').
  (define-key org-recur-agenda-mode-map (kbd "d") 'org-recur-finish)
  (define-key org-recur-agenda-mode-map (kbd "C-c d") 'org-recur-finish)

  (setq org-recur-finish-done t
        org-recur-finish-archive t))
;; 
;; (use-package! md-roam
;;   :after org-roam
;;   :init
;;   (setq org-roam-file-extensions '("org" "md")) ; enable Org-roam for a markdown extension
;;   :config
;;   (md-roam-mode 1)
;;   (setq md-roam-file-extension "md")    ; default "md". Specify an extension such as "markdown"
;;   ;; remove @ citation
;;   (setq org-roam-capture-templates
;;         '(("m" "Markdown" plain "" :target
;;            (file+head "${title}.md"
;;                       "---\ntitle: ${title}\nid: %<%Y-%m-%dT%H%M%S>\ncategory: \n---\n")
;;            :unnarrowed t)
;;           ;; ("d" "default" plain "%?" :target
;;           ;;  (file+head "${slug}.org" "#+title: ${title}\n")
;;           ;;  :unnarrowed t)
;;           )
;;         )
;;   )

;;  Mermaid diagram config
(setq ob-mermaid-cli-path "/Users/phil/.nvm/versions/node/v22.15.0/bin/mmdc")

;; Tags config
(setq org-tag-alist '(("XS")
                      ("S")
                      ("M")
                      ("L")
                      ("XL")
                      ("computer" . ?c) ; 'c' for computer
                      ("errands" . ?e)  ; 'e' for errands
                      ("lifeorg" . ?o)  ; 'o' for lifeorg (assuming 'l' might be for L)
                      ("niceday" . ?n)
                      ("needhelp" . ?h) ; 'h' for needhelp
                      ("rainyday" . ?r) ; 'r' for rainyday
                      ))

(use-package! dendroam
  :after org-roam)
