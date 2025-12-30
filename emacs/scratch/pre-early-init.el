;;; pre-early-init.el --- DESCRIPTION -*- no-byte-compile: t; lexical-binding: t; -*-

;; Enable debug on error
;; only enable when debugging configs
(setq debug-on-error t)

;;; Reducing clutter in ~/.config/emacs/scratch/ by redirecting files to ~/.config/emacs/scratch/var
(setq user-emacs-directory (expand-file-name "var/" minimal-emacs-user-directory))
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))
