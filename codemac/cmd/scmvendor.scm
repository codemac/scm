#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd scmvendor) main)" -s "$0" "$@"
!#
(define-module (codemac cmd scmvendor)
  #:use-module (srfi srfi-2)
  #:use-module (ice-9 pretty-print)
  #:export (vendor-load-path))

(define (cp-r src dst)
  (cpo "-r" src dst))

(define (cp src dst)
  (equal? 0 (status:exit-val
	     (system* "cp" src dst))))

(define (cpo opts src dst)
  (equal? 0 (status:exit-val
	     (system* "cp" opts src dst))))

(define (mkdir-p dir)
  (equal? 0 (status:exit-val
	     (system* "mkdir" "-p" dir))))

(define-macro (define-debug args . rest)
  (let ((result-val (gensym)))
    `(define ,args
       (let ((,result-val (begin ,@rest)))
	 (pretty-print ,result-val)))))

;; reimplement in raw guile
(define-debug (rmdir* dir)
  (display (string-append  "rmdir* " dir))
  (newline)
  (equal? 0 (status:exit-val
	     (system* "rm" "-rf" dir))))

(define (sed fn sep pat repl)
  (let ((cmdlist (list "sed" "-i" (string-append "s" sep pat sep repl sep) fn)))
    (format #t "sedcmd: ~s~%" cmdlist)
    (equal? 0 (status:exit-val
	       (apply system* cmdlist)))))

(define (mv src dst)
      (equal? 0 (status:exit-val
	       (system* "mv" src dst))))

(define (with-dir dir cmd)
  (equal? 0 (status:exit-val
	     (system* "sh" "-c" (string-append "cd " dir " && " cmd)))))

(define (runvendor dir vcs url ref)
  (case vcs
    ((git)
     (and
      (equal? 0 (status:exit-val (system* "git" "clone" url dir)))
      (with-dir dir (string-append "git checkout " ref))
      (with-dir dir "rm -rf .git")))
    (else
     (error "Not implemented"))))

(define (vendor-abs-path)
  (string-append (getenv "HOME") "/scm/" (vendor-load-path)))

(define (vendor-load-path) "codemac/vendor")

(define (scm-path)
  (string-append (getenv "HOME") "/scm"))

(define* (vendor #:key
		 (dir #f)
		 (vcs #f)
		 (url #f)
		 (ref #f)
		 (install (lambda (src) #t))
		 (patches '()))
  (format #t "~%Vendoring ~a...~%" dir)
  (if (or (not dir) (not vcs) (not url) (not ref))
      (format #t "Vendor not fully specified: ~s~%" (list dir vcs url ref))
      (let ((srcdir (string-append (vendor-abs-path) "/src/" dir)))
	(rmdir* srcdir)
	(runvendor srcdir vcs url ref)
	(install srcdir))))

;; here I codify vendored installs, as guile vendoring isn't really
;; that sensible when combined with gnu tools. I hard hack it to keep
;; track of my vendored tools.
(define (install-irregex src)
  (and-let* ((dst (string-append (scm-path) "/rx"))
	     ((mkdir-p dst))
	     (df (string-append dst "/irregex.scm"))
	     ((cp (string-append src "/irregex-guile.scm") df))
	     ((sed df "#"
		   "load-from-path \"rx/source/irregex.scm\""
		   "load-from-path \"codemac/vendor/src/irregex/irregex.scm\"")))
    #t))

(define (install-shepherd src)
  (and-let* ((dst (string-append (scm-path) "/shepherd"))
	     ((cp (string-append src "/modules/shepherd.scm") (scm-path)))
	     ((cp-r (string-append src "/modules/shepherd") (scm-path)))
	     (cf (string-append (scm-path) "/shepherd/config.scm"))
	     ((mv (string-append (scm-path) "/shepherd/config.scm.in")
		  cf))
	     ((sed cf "#" "%VERSION%" "0.3.1"))
	     ((sed cf "#" "%PREFIX%" "/usr"))
	     ((sed cf "#" "%localstatedir%" "/usr/var"))
	     ((sed cf "#" "%sysconfdir%" "/etc"))
	     ((sed cf "#" "%PACKAGE_BUGREPORT%" "bug-guix@gnu.org"))
	     ((sed cf "#" "%PACKAGE_NAME%" "GNU Shepherd"))
	     ((sed cf "#" "%PACKAGE_URL%" "http://www.gnu.org/software/shepherd"))
	     (sf (string-append (scm-path) "/shepherd/system.scm"))
	     ((mv (string-append (scm-path) "/shepherd/system.scm.in")
		  sf))
	     ((sed sf "#" "@RB_AUTOBOOT@" "19088743"))
	     ((sed sf "#" "@RB_HALT_SYSTEM@" "3454992675"))
	     ((sed sf "#" "@RB_POWER_OFF@" "1126301404"))
	     ((sed sf "#" "@_SC_OPEN_MAX@" "4")))
    #t))

;; will probably need to update these file locations to be run as a
;; user, to something like XDG_DIR spec declares.
(define (install-mcron src)
  (and-let* ((dst (string-append (scm-path) "/mcron"))
	     ((cp-r (string-append src "/scm/mcron") (scm-path)))
	     (cf (string-append (scm-path) "/mcron/config.scm"))
	     ((mv (string-append (scm-path) "/mcron/config.scm.in") cf))
	     ((sed cf "/" "@CONFIG_DEBUG@" "#t"))
	     ((sed cf "#" "@PACKAGE_NAME@" "GNU Mcron"))
	     ((sed cf "#" "@PACKAGE_VERSION@" "1.0.8"))
	     ((sed cf "#" "@PACKAGE_STRING@" "package string"))
	     ((sed cf "#" "@PACKAGE_BUGREPORT@" "bug-mcron@gnu.org"))
	     ((sed cf "#" "@PACKAGE_URL@" "https://www.gnu.org/software/mcron"))
	     ((sed cf "#" "@SENDMAIL@" "sendmail"))
	     ((sed cf "#" "@CONFIG_SPOOL_DIR@" "/var/cron/tabs"))
	     ((sed cf "#" "@CONFIG_SOCKET_FILE@" "/var/cron/socket"))
	     ((sed cf "#" "@CONFIG_ALLOW_FILE@" "/var/cron/allow"))
	     ((sed cf "#" "@CONFIG_DENY_FILE@" "/var/cron/deny"))
	     ((sed cf "#" "@CONFIG_PID_FILE@" "/var/run/cron.pid"))
	     ((sed cf "#" "@CONFIG_TMP_DIR@" "/tmp")))
    #t))

(define (install-lips src)
  (and-let* ((dst (scm-path))
	     ((cp-r (string-append src "/modules/lips") dst)))
    #t))

(define (install-megacut src)
  (and-let* ((dst (string-append (scm-path) "/megacut.scm"))
	     ((cp-r (string-append src "/megacut.scm") dst)))
    #t))

(define (install-scsh src)
  (and-let* ((dst (string-append (scm-path) "/scsh"))
	     ((cp-r (string-append src "/scsh") dst)))
    #t))

(define (main args)
  ;; irregex is life
  (vendor
   #:dir "irregex"
   #:vcs 'git
   #:url "https://github.com/ashinn/irregex"
   #:ref "2d14c53653629ca33b0adf033d2ef5642d3e9caa"
   #:install install-irregex)

  ;; shepherd, manages my services (maybe download tarfile instead? no
  ;; need for autoconf)
  (vendor
   #:dir "shepherd"
   #:vcs 'git
   #:url "git://git.sv.gnu.org/shepherd.git"
   #:ref "v0.3.2"
   #:install install-shepherd)
  
  ;; mcron, used as my cron replacement
  (vendor
   #:dir "mcron"
   #:vcs 'git
   #:url "git://git.sv.gnu.org/mcron.git"
   #:ref "c0a6eb14c257a47e9573631e5ac09e6528fba377"
   #:install install-mcron)

  (vendor
   #:dir "lips"
   #:vcs 'git
   #:url "https://github.com/rbryan/guile-lips"
   #:ref "9e253a873f7eb842095859eef6f55611458b618f"
   #:install install-lips)

  (vendor
   #:dir "megacut"
   #:vcs 'git
   #:url "https://bitbucket.org/bjoli/megacut"
   #:ref "4695b7fa3847fc6d6ed3bc3f9cf07604bc86cc72"
   #:install install-megacut)

  (vendor
   #:dir "scsh"
   #:vcs 'git
   #:url "https://github.com/ChaosEternal/guile-scsh"
   #:ref "1a76e006e193a6a8c9f93d23bacb9e51a1ff6c4c"
   #:install install-scsh))
