;; config.scm.in -- Making information accessible in -*- scheme -*- code.

(define-module (shepherd config)
  #:export (Version
            Prefix-dir
            %localstatedir
            %sysconfdir
            copyright
            bug-address
            package-name
            package-url))

(define Version "0.3.1")
(define Prefix-dir "/usr/local")
(define %localstatedir "/usr/local/var")
(define %sysconfdir "/usr/local/etc")

(define copyright "Copyright (C) 2002, 2003 Wolfgang Jährling")
(define bug-address "bug-guix@gnu.org")
(define package-name "GNU Shepherd")
(define package-url "http://www.gnu.org/software/shepherd/")
