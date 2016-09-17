#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd scmvendor) main)" -s "$0" "$@"
!#

(define-module (codemac cmd scmvendor))

;; reimplement in raw guile
(define (rmdir* dir)
  (equal? 0 (status:exit-val
	     (system* "rm" "-r" dir))))

(define (with-dir dir cmd)
  (equal? 0 (status:exit-val
	     (system* "sh" "-c" (string-append "cd " dir " && " cmd)))))

(define (runvendor dir vcs url ref)
  (case vcs
    ((git)
     (and
      (equal? 0 (status:exit-val (system* "git" "clone" url dir)))
      (with-dir dir (string-append "git checkout " ref))
      (with-dir dir "rm -r .git")))))

(define (hashdir dir)
  (if (file-exists? (string-append dir "/.VENDORSHA1"))
      (if (with-dir dir "sha1sum -c .VENDORSHA1 > .HASHOUT")
	  (begin (delete-file ".HASHOUT") #t)
	  #f)
      (rehashdir dir ".VENDORSHA1")))

(define (rehashdir dir file)
  (with-dir dir (string-append "find . -type f -exec sha1sum '{}' ';' | grep -v .VENDORSHA1 | sort -k2 > " file)))

(define-syntax vendor
  (syntax-rules (dir vcs url ref)
    ((_ (dir d1)
	(vcs v1)
	(url u1)
	(ref r1))
     (let ((dir (string-append (getenv "HOME") "/scm/codemac/vendor/" d1)))
       (rmdir* dir)
       (runvendor dir v1 u1 r1)
       (if (not (hashdir dir))
	   (rehashdir dir ".NEWHASH"))))))

(define (main args)
  ;; irregex is life
  (vendor
   (dir "irregex")
   (vcs 'git)
   (url "https://github.com/ashinn/irregex")
   (ref "2d14c53653629ca33b0adf033d2ef5642d3e9caa"))

  ;; shepherd, manages my services
  (vendor
   (dir "shepherd")
   (vcs 'git)
   (url "git://git.sv.gnu.org/shepherd.git")
   (ref "v0.3.1"))
  
  ;; mcron, used as my cron replacement
  (vendor
   (dir "mcron")
   (vcs 'git)
   (url "git://git.sv.gnu.org/mcron.git")
   (ref "c0a6eb14c257a47e9573631e5ac09e6528fba377")))
