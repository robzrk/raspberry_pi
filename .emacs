;;
;; File .emacs - These commands are executed when GNU emacs starts up.
;;
;; $Id: .emacs,v 1.8 1995/11/07 20:12:07 dewell Exp $
;; revised 8/15/2009
;;
;; Now, it resides as .emacs.d/init.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RJZ CHANGES HERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Alt key to meta
(setq x-alt-keysym 'meta)

(set-frame-position (selected-frame) 0 0)
(set-face-foreground 'default "white")
(set-face-background 'default "black")
(set-face-foreground 'font-lock-comment-face "red")
(set-face-foreground 'font-lock-constant-face "cyan")
(set-face-foreground 'font-lock-string-face "yellow")
(set-face-foreground 'font-lock-type-face "green")
(set-face-foreground 'font-lock-function-name-face "magenta")
(set-face-foreground 'font-lock-variable-name-face "yellow")

;; (set-face-foreground 'default "dark blue")
;; (set-face-background 'default "white")

;; add the dir to load path
(add-to-list 'load-path "~/.emacs.d/load")

;; autoload powershell interactive shell
(autoload 'powershell "powershell" "Start a interactive shell of PowerShell." t)

;; OCaml
;; (load "/home/rzirkel/.opam/system/share/emacs/site-lisp/tuareg-site-file")
;; (autoload 'tuareg-mode "tuareg-mode" "OCaml mode" t)
;; (add-to-list 'auto-mode-alist '("\\.ml\\'" . tuareg-mode))

;; powershell-mode
(autoload 'powershell-mode "powershell-mode" "A editing mode for Microsoft PowerShell." t)
(add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode)) ; PowerShell script
(add-to-list 'auto-mode-alist '("\\.psm1\\'" . powershell-mode)) ; PowerShell script

;; verilog-mode
;; Load verilog mode only when needed
(autoload 'verilog-mode "verilog-mode" "Verilog mode" t )
;; Any files that end in .v, .dv or .sv should be in verilog mode
(add-to-list 'auto-mode-alist '("\\.[ds]?v\\'" . verilog-mode))
;; Any files in verilog mode should have their keywords colorized
(add-hook 'verilog-mode-hook '(lambda () (font-lock-mode 1)))

;; RJZ Changes below
(require 'grep)

(defun rjz_load_dual ()
  (interactive)
  (set-face-font 'default "-DAMA-Ubuntu Mono-normal-normal-normal-*-13-*-*-*-m-0-iso10646-1")

  ;; RJZ dual monitors
  (set-frame-size (selected-frame) 252 70)
  (split-window-horizontally)
  (shrink-window-horizontally -43)
  (split-window-horizontally)

  )

(defun rjz_load_laptop ()
  (interactive)
  (set-face-font 'default "-DAMA-Ubuntu Mono-normal-normal-normal-*-18-*-*-*-m-0-iso10646-1")

  ;; RJZ dual monitors
  (set-frame-size (selected-frame) 164 65)
  (split-window-horizontally)
  )
(defun rjz_load_med ()
  (interactive)
  ;; (set-face-font 'default "-sony-fixed-medium-r-normal--24-*-100-100-c-120-fontset-auto2")

  ;; RJZ dual monitors
  (set-frame-size (selected-frame) 164 66)
  (split-window-horizontally)

  ;; RJZ no external monitor
  ;;   (set-frame-size (selected-frame) 80 58)

  )

(defun rjz_load_large ()
  (interactive)
  (set-face-font 'default "-DAMA-Ubuntu Mono-normal-normal-normal-*-24-*-*-*-m-0-iso10646-1")

  ;; RJZ dual monitors
  (set-frame-size (selected-frame) 80 40)


  ;; RJZ no external monitor
  ;;   (set-frame-size (selected-frame) 80 40)
  )


(defun rjz_load_yuuuge ()
  (interactive)
  (set-face-font 'default "-DAMA-Ubuntu Mono-normal-normal-normal-*-30-*-*-*-m-0-iso10646-1")

  ;; RJZ dual monitors
  (set-frame-size (selected-frame) 80 40)


  ;; RJZ no external monitor
  ;;   (set-frame-size (selected-frame) 80 40)
  )


;; (eval-after-load "grep"
;;   '(grep-compute-defaults))

(menu-bar-mode -1)
;; (tool-bar-mode -1)

					;  (set-face-background 'font-lock-comment-face "black")
					;  (set-face-foreground 'font-lock-comment-face "hotpink")
					;  (set-face-foreground 'font-lock-comment-delimiter-face "yellow")
					;  (set-face-foreground 'default "purple")
					;  (set-face-background 'default "black")
					;  (set-face-foreground 'font-lock-warning-face "red")
					;  (set-face-background 'font-lock-warning-face "black")
					;  (set-face-background 'font-lock-comment-face "black")
					;  (set-face-foreground 'font-lock-comment-face "chocolate1")
					;  (set-face-foreground 'font-lock-comment-delimiter-face "Firebrick")
					;  (set-face-foreground 'font-lock-warning-face "green")
					;  (set-face-background 'font-lock-warning-face "black")

;; (custom-set-variables
;;  '(grep-find-command "find . -type f -not -name \".*\" -and -not -name \"master\" -and -not -name \"HEAD\" -and -not -name \"*.tmp\" -and -not -name \"TAGS\" -and -not -name \"entries\" -and -not -name \"all-wcprops\" -and -not -name \"*~\" -and -not -name \"*.svn-base\" -and -not -name \"svn-*\" -and -not -name \"*.html\" -print0 | xargs -0 -e grep -n -s -F -I "
;;                      ))

(defun current_word_grep ()
  "setting up grep-command using current word under cursor as a search string"
  (interactive)
  (let* ((cur-word (thing-at-point 'symbol))
	 (cmd (concat "find . -type f -not -name \".*\" -and -not -name \"master\" -and -not -name \"HEAD\" -and -not -name \"*.tmp\" -and -not -name \"TAGS\" -and -not -name \"entries\" -and -not -name \"all-wcprops\" -and -not -name \"*~\" -and -not -name \"*.svn-base\" -and -not -name \"svn-*\" -and -not -name \"*.html\" -print0 | xargs -0 -e grep -n -s -F -I " cur-word )))
    ;; (setq grep-find-template 'grep-command cmd)
    (grep-apply-setting 'grep-command cmd)
    (grep cmd)))

(defun current_word_edit_grep ()
  "setting up grep-command using current word under cursor as a search string"
  (interactive)
  (let ((dir (read-from-minibuffer "Enter search directory: " "."))
	(term (read-from-minibuffer "Enter search term: " (thing-at-point 'symbol))))
    (message "Searching for [%s] in [%s]" term dir)
    (let* ((cur-word (thing-at-point 'word))
	   (cmd (concat "find " dir " -type f -not -name \".*\" -and -not -name \"master\" -and -not -name \"HEAD\" -and -not -name \"*.tmp\" -and -not -name \"TAGS\" -and -not -name \"entries\" -and -not -name \"all-wcprops\" -and -not -name \"*~\" -and -not -name \"*.svn-base\" -and -not -name \"svn-*\" -and -not -name \"*.html\" -print0 | xargs -0 -e grep -n -s -F -I " term )))
      (grep-apply-setting 'grep-command cmd)
      (grep cmd))))

;; key bindings
(global-set-key (kbd "<f2>") 'rjz_load_dual)
(global-set-key (kbd "C-<f2>") 'rjz_load_laptop)
(global-set-key (kbd "C-x C-<f2>") 'rjz_load_large)
(global-set-key (kbd "C-x C-<f3>") 'rjz_load_yuuuge)
;; (global-set-key (kbd "C-<f2>") 'rjz_load_med)
(global-set-key (kbd "<f3>") 'ansi-term)
(global-set-key (kbd "C-<f3>") 'vc-annotate)
(global-set-key (kbd "<f4>") 'grep-find)
(global-set-key (kbd "<f4>") 'current_word_edit_grep)
(global-set-key (kbd "C-<f4>") 'current_word_grep)
(global-set-key (kbd "<f5>") 'compile)
(global-set-key (kbd "C-<f5>") 'refresh-file)
(global-set-key (kbd "<f6>") (kbd "C-x 0"))
(global-set-key (kbd "<f7>") 'split-window-vertically)
(global-set-key (kbd "<f8>") 'split-window-horizontally)
(global-set-key (kbd "<f9>") 'windmove-left)
(global-set-key (kbd "<f10>") 'windmove-down)
(global-set-key (kbd "<f11>") 'windmove-up)
(global-set-key (kbd "<f12>") 'windmove-right)
(global-set-key (kbd "C-x b") 'iswitchb-buffer )
(global-set-key (kbd "C-x C-b") 'iswitchb-buffer )

(global-set-key '[\M-down] 'next-error)
(global-set-key '[\M-up] 'previous-error)


;; SIMICS
(setq load-path (cons "/nfs/site/home/rjzirkel/work_root/simics/simics-4.6/simics-model-builder-4.6.23/scripts" load-path))
(autoload 'dml-mode "dml-mode" "DML mode" t)
(add-to-list 'auto-mode-alist '("\\.dml\\'" . dml-mode))
(add-to-list 'auto-mode-alist '("\\.simics\\'" . dml-mode))
(add-to-list 'auto-mode-alist '("\\.txt\\'" . default-generic-mode))

;; word wrap
(setq-default fill-column 2000)
(add-hook 'text-mode-hook 'turn-on-auto-fill)

(setq truncate-partial-width-windows nil)

(setq term-buffer-maximum-size 0)

(iswitchb-mode 1)
;; (iswitchb-default-keybindings)
(setq iswitchb-default-method 'samewindow)

(setq default-tab-width 4)

(when (display-graphic-p)
  (shell-command "find /home/rzirkel/xc/hss-nightly -name \"*.[chCH]\" -print | etags -o ~/xc/tags/TAGS_AUTO -")
  (shell-command "find /home/rzirkel/shasta/hms-controllers -name \"*.[chCH]\" -print | etags -o ~/shasta/tags/TAGS_HMS_CONTROLLERS -")
  (shell-command "find /home/rzirkel/shasta/hms-cray-jtag-interface -name \"*.[chCH]\" -print | etags -o ~/shasta/tags/TAGS_HMS_CJI -")
  (shell-command "find /home/rzirkel/xc/scout_firmware -name \"*.[chCH]\" -print | etags -o ~/xc/tags/TAGS_SCOUT -")
  (shell-command "find /home/rzirkel/shasta/rosetta_drivers -name \"*.[chCH]\" -print | etags -o ~/shasta/tags/TAGS_ROSETTA_DRIVERS -")

  (visit-tags-table "~/xc/tags/TAGS_AUTO")
  (visit-tags-table "~/shasta/tags/TAGS_HMS_CONTROLLERS")
  (visit-tags-table "~/shasta/tags/TAGS_HMS_CJI")
  (visit-tags-table "~/xc/tags/TAGS_SCOUT")
  (visit-tags-table "~/shasta/tags/TAGS_ROSETTA_DRIVERS")
  )

(defun refresh-file ()
  (interactive)
  (revert-buffer t t t)
  )

(defun iswitchb-local-keys ()
  (mapc (lambda (K)
	  (let* ((key (car K)) (fun (cdr K)))
	    (define-key iswitchb-mode-map (edmacro-parse-keys key) fun)))
	'(("<right>" . iswitchb-next-match)
	  ("<left>"  . iswitchb-prev-match)
	  ("<up>"    . ignore             )
	  ("<down>"  . ignore             ))))    (add-hook 'iswitchb-define-mode-map-hook 'iswitchb-local-keys)

;; fonts
(set-face-font 'default "-DAMA-Ubuntu Mono-normal-normal-normal-*-13-*-*-*-m-0-iso10646-1")

					; frame width and height and position
(when (display-graphic-p)   ;; Return non-nil if emacs is running in a graphic display.
  (rjz_load_dual)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; END RJZ CHANGES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Keep Emacs from executing file local variables.
;; (this is also in the site-init.el file loaded at emacs dump time.)
(setq inhibit-local-variables t  ; v18
      enable-local-variables nil ; v19
      enable-local-eval nil)     ; v19

;; Swap Backspace and Delete keys, except for v19 running under X.  This works
;; on both HPs and Suns.
(or (and (eq window-system 'x)
	 (string-match "\\`19\\." emacs-version))
    (load "term/bobcat"))

;; Cause the region to be highlighted and prevent region-based commands
;; from running when the mark isn't active.

(pending-delete-mode t)
(setq transient-mark-mode t)

(setq kill-emacs-query-functions
      (list (function (lambda ()
			(ding)
			(y-or-n-p "Really quit? ")))))

;; Fonts are automatically highlighted.  For more information
;; type M-x describe-mode font-lock-mode

(global-font-lock-mode t)

;; "rmail" is the standard Emacs mail reading mode if you want try a
;; different one then "vm" works well
;;
;; VM mail reading mode
(autoload 'vm "vm" "Start VM on your primary inbox." t)
(autoload 'vm-visit-folder "vm" "Start VM on an arbitrary folder." t)
(autoload 'vm-visit-virtual-folder "vm" "Visit a VM virtual folder." t)
(autoload 'vm-mode "vm" "Run VM major mode on a buffer" t)
(autoload 'vm-mail "vm" "Send a mail message using VM." t)
;;
;; win-vm window+menus for VM (Use the above 5 autoloads or the following,
;;                             but not both.)
;;(let ((my-vm-pkg
;;       (if (not window-system)
;;   "vm"
;; (define-key menu-bar-file-menu [rmail] '("Read Mail" . vm))
;; (define-key-after menu-bar-file-menu [smail]
;;   '("Send Mail" . vm-mail) 'rmail)
;; "win-vm")))
;;  (autoload 'vm my-vm-pkg "Read and send mail with View Mail." t)
;;  (autoload 'vm-mode my-vm-pkg "Read and send mail with View Mail." t)
;;  (autoload 'vm-mail my-vm-pkg "Send mail with View Mail." t)
;;  (autoload 'vm-visit-folder my-vm-pkg))

;; Some color stuff if you want it.
;; (cond (window-system
;;        (setq hilit-mode-enable-list  '(not text-mode)
;;              hilit-background-mode   'light
;;              hilit-inhibit-hooks     nil
;;              hilit-inhibit-rebinding nil)
;;
;;        (require 'hilit19)
;;        ))
;;
;; Example of how to set the highlighting of color defaults.
;; (if (fboundp 'set-face-background)
;;     (progn
;;      (set-face-background (quote highlight) "yellow")
;;      (set-face-foreground (quote highlight) "black")))


;; Below are changes taken from the tutor .emacs file
;; Added by Craig Ruefenacht

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; This provides customized support for writing programs in different kinds
;;;; of programming languages.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Load the C++ and C editing modes and specify which file extensions
;; correspond to which modes.
;; (autoload 'python-mode "python-mode" "Python editing mode." t)
;;     (setq auto-mode-alist
;;            (cons '("\\.py$" . python-mode) auto-mode-alist))
;;      (setq interpreter-mode-alist
;;            (cons '("python" . python-mode) interpreter-mode-alist))

(setq load-path (cons "/home/rzirkel/.emacs.d/cc-mode-5.33" load-path))
(autoload 'cc-mode "cc-mode" "C Editing Mode"   t)
;;(autoload 'c++-mode "cc-mode" "C++ Editing Mode" t)
;;(autoload 'c-mode "c-mode" "C Editing Mode"   t)
;; (setq auto-mode-alist
;;       (append '(("\\.C\\'" . c++-mode)
;;                 ("\\.cc\\'" . c++-mode)
;; ("\\.c\\'" . c-mode)
;;                 ("\\.h\\'"  . c++-mode))
;;       auto-mode-alist))
(setq auto-mode-alist
      (append '(("\\.C\\'" . cc-mode)
		("\\.cc\\'" . cc-mode)
		("\\.c\\'" . cc-mode)
		("\\.h\\'"  . cc-mode))
	      auto-mode-alist))

;;;; This snippet enables lua-mode
;; This line is not necessary, if lua-mode.el is already on your load-path
(add-to-list 'load-path "~/.emacs.d/lua")

(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))

;; set tab distance to something, so it doesn't change randomly and confuse people
(setq c-basic-offset 4)

;; This function is used in various programming language mode hooks below.  It
;; does indentation after every newline when writing a program.

(defun newline-indents ()
  "Bind Return to `newline-and-indent' in the local keymap."
  (local-set-key "\C-m" 'newline-and-indent))


;; Tell Emacs to use the function above in certain editing modes.

(add-hook 'lisp-mode-hook             (function newline-indents))
(add-hook 'emacs-lisp-mode-hook       (function newline-indents))
(add-hook 'lisp-interaction-mode-hook (function newline-indents))
(add-hook 'scheme-mode-hook           (function newline-indents))
(add-hook 'c-mode-hook                (function newline-indents))
(add-hook 'c++-mode-hook              (function newline-indents))
(add-hook 'java-mode-hook             (function newline-indents))


;; Fortran mode provides a special newline-and-indent function.

(add-hook 'fortran-mode-hook
	  (function (lambda ()
		      (local-set-key "\C-m" 'fortran-indent-new-line))))


;; Text-based modes (including mail, TeX, and LaTeX modes) are auto-filled.

(add-hook 'text-mode-hook (function turn-on-auto-fill))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; This makes "M-x compile" smarter by trying to guess what the compilation
;;;; command should be for the C, C++, and Fortran language modes.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; By requiring `compile' at this point, we help to ensure that the global
;; value of compile-command is set properly.  If `compile' is autoloaded when
;; the current buffer has a buffer-local copy of compile-command, then the
;; global value doesn't get set properly.

(require 'compile)

;; This gives the form of the default compilation command for C++, C, and
;; Fortran programs.  Specifying the "-lm" option for C and C++  eliminates a
;; lot of potential confusion.

(defvar compile-guess-command-table
  '((c-mode       . "gcc -Wall -g %s -o %s -lm"); Doesn't work for ".h" files.
    (c++-mode     . "g++ -g %s -o %s -lm"); Doesn't work for ".h" files.
    (fortran-mode . "f77 -C %s -o %s")
    )
    "*Association list of major modes to compilation command descriptions, used
by the function `compile-guess-command'.  For each major mode, the compilation
command may be described by either:

  + A string, which is used as a format string.  The format string must accept
    two arguments: the simple (non-directory) name of the file to be compiled,
    and the name of the program to be produced.

  + A function.  In this case, the function is called with the two arguments
    described above and must return the compilation command.")


;; This code guesses the right compilation command when Emacs is asked
;; to compile the contents of a buffer.  It bases this guess upon the
;; filename extension of the file in the buffer.

(defun compile-guess-command ()

  (let ((command-for-mode (cdr (assq major-mode
				     compile-guess-command-table))))
    (if (and command-for-mode
	     (stringp buffer-file-name))
	(let* ((file-name (file-name-nondirectory buffer-file-name))
	       (file-name-sans-suffix (if (and (string-match "\\.[^.]*\\'"
							     file-name)
					       (> (match-beginning 0) 0))
					  (substring file-name
						     0 (match-beginning 0))
					nil)))
	  (if file-name-sans-suffix
	      (progn
		(make-local-variable 'compile-command)
		(setq compile-command
		      (if (stringp command-for-mode)
			  ;; Optimize the common case.
			  (format command-for-mode
				  file-name file-name-sans-suffix)
			(funcall command-for-mode
				 file-name file-name-sans-suffix)))
		compile-command)
	    nil))
      nil)))


;; Add the appropriate mode hooks.

(add-hook 'c-mode-hook       (function compile-guess-command))
(add-hook 'c++-mode-hook     (function compile-guess-command))
(add-hook 'fortran-mode-hook (function compile-guess-command))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; This creates and adds a "Compile" menu to the compiled language modes.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar compile-menu nil
  "The \"Compile\" menu keymap.")

(defvar check-option-modes nil
    "The list of major modes in which the \"Check\" option in the \"Compile\"
menu should be used.")

(defvar compile-menu-modes nil
    "The list of major modes in which the \"Compile\" menu has been installed.
This list used by the function `add-compile-menu-to-mode', which is called by
various major mode hooks.")


;; Create the "Compile" menu.

(if compile-menu
    nil
  (setq compile-menu (make-sparse-keymap "Compile"))
  ;; Define the menu from the bottom up.
  (define-key compile-menu [first-error] '("    First Compilation Error" .
					   first-compilation-error))
  (define-key compile-menu [prev-error]  '("    Previous Compilation Error" .
					   previous-compilation-error))
  (define-key compile-menu [next-error]  '("    Next Compilation Error" .
					   next-error))
  (define-key compile-menu [goto-line]   '("    Line Number..." .
					   goto-line))

  (define-key compile-menu [goto]        '("Goto:" . nil))
  ;;
  (define-key compile-menu [indent-region] '("Indent Selection" .
					     indent-region))

  (define-key compile-menu [make]         '("Make..." . make))

  (define-key compile-menu [check-file]   '("Check This File..." .
					    check-file))

  (define-key compile-menu [compile]     '("Compile This File..." . compile))
  )


;;; Enable check-file only in Fortran mode buffers

(put 'check-file 'menu-enable '(eq major-mode 'fortran-mode))


;;; Here are the new commands that are invoked by the "Compile" menu.

(defun previous-compilation-error ()
    "Visit previous compilation error message and corresponding source code.
See the documentation for the command `next-error' for more information."
    (interactive)
    (next-error -1))

(defun first-compilation-error ()
    "Visit the first compilation error message and corresponding source code.
See the documentation for the command `next-error' for more information."
    (interactive)
    (next-error '(4)))

(defvar check-history nil)

(defun check-file ()
  "Run ftnchek on the file contained in the current buffer"
  (interactive)
  (let* ((file-name (file-name-nondirectory buffer-file-name))
	 (check-command (read-from-minibuffer
			 "Check command: "
			 (format "ftnchek %s" file-name) nil nil
			 '(check-history . 1))))
    (save-some-buffers nil nil)
    (compile-internal check-command "Can't find next/previous error"
		      "Checking" nil nil nil)))

(defun make ()
  "Run make in the directory of the file contained in the current buffer"
  (interactive)
  (save-some-buffers nil nil)
  (compile-internal (read-from-minibuffer "Make command: " "make ")
		    "Can't find next/previous error" "Make"
		    nil nil nil))


;;; Define a function to be called by the compiled language mode hooks.

(defun add-compile-menu-to-mode ()
    "If the current major mode doesn't already have access to the \"Compile\"
menu, add it to the menu bar."
    (if (memq major-mode compile-menu-modes)
	nil
      (local-set-key [menu-bar compile] (cons "Compile" compile-menu))
      (setq compile-menu-modes (cons major-mode compile-menu-modes))
      ))


;; And finally, make sure that the "Compile" menu is available in C, C++, and
;; Fortran modes.
(add-hook 'c-mode-hook       (function add-compile-menu-to-mode))
(add-hook 'c++-c-mode-hook   (function add-compile-menu-to-mode))
(add-hook 'c++-mode-hook     (function add-compile-menu-to-mode))
(add-hook 'fortran-mode-hook (function add-compile-menu-to-mode))

;; To make emacs use spaces instead of tabs (Added by Art Lee on 2/19/2008)
(setq-default indent-tabs-mode nil)

;; This is how emacs tells the file type by the file suffix.
(setq auto-mode-alist
      (append '(("\\.mss$" . scribe-mode))
	      '(("\\.bib$" . bibtex-mode))
	      '(("\\.tex$" . latex-mode))
	      '(("\\.obj$" . lisp-mode))
	      '(("\\.st$"  . smalltalk-mode))
	      '(("\\.Z$"   . uncompress-while-visiting))
	      '(("\\.cs$"  . indented-text-mode))
	      '(("\\.C$"   . c++-mode))
	      '(("\\.cc$"  . c++-mode))
	      '(("\\.icc$" . c++-mode))
	      '(("\\.c$"   . c-mode))
	      '(("\\.y$"   . c-mode))
	      '(("\\.h$"   . c++-mode))
	      auto-mode-alist))
;;
;; Finally look for .customs.emacs file and load it if found

(if "~/.customs.emacs"
    (load "~/.customs.emacs" t t))

;; Art: added with v. 23.1 to make spacebar complete filenames (8/17/2009)
;; (progn
;;  (define-key minibuffer-local-completion-map " " 'minibuffer-complete-word)
;;  (define-key minibuffer-local-filename-completion-map " " 'minibuffer-complete-word)
;;  (define-key minibuffer-local-must-match-filename-map " " 'minibuffer-complete-word))

;; Art: added with v. 23.1
;; Set env variable this way?  I used the traditional way instead
					;(info "(emacs) Windows HOME")

;; End of file.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(put 'downcase-region 'disabled nil)

(put 'upcase-region 'disabled nil)

(require 'tramp)
(setq tramp-default-method "ssh")

(setq ring-bell-function 'ignore)

;; RJZ Changes here
;; Open some buffers
(when (display-graphic-p)
  (find-file "/home/rzirkel/xc/hss-nightly/workspace/controllers/bcsysd/bcsysd.c")
  (find-file "/home/rzirkel/xc/hss-nightly/workspace/commands/xtppr/xtppr.c")
  (find-file "/home/rzirkel/scripts/hms_go.sh")
  (windmove-right)
  )
;; (find-file "/rjzirkel@sv24.ec.intel.com:/home/rjzirkel/work/svos_svfdo/apps/fabric/wfr/test/rcv/wfr_rcv_egr.cpp")
;; (find-file "/rjzirkel@sv24.ec.intel.com:/home/rjzirkel/work/slxbuild/pvesv-sim/wfr_prr/simics-workspace/modules/spc_top/test/s-rxe.py")
(put 'scroll-left 'disabled nil)
