;; -*-scheme-*-

;;   Copyright (C) 2015 Mathieu Lirzin
;;   Copyright (C) 2003 Dale Mellor
;; 
;;   This file is part of GNU mcron.
;;
;;   GNU mcron is free software: you can redistribute it and/or modify it under
;;   the terms of the GNU General Public License as published by the Free
;;   Software Foundation, either version 3 of the License, or (at your option)
;;   any later version.
;;
;;   GNU mcron is distributed in the hope that it will be useful, but WITHOUT
;;   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;;   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;;   more details.
;;
;;   You should have received a copy of the GNU General Public License along
;;   with GNU mcron.  If not, see <http://www.gnu.org/licenses/>.


;; Some constants set by the configuration process.

(define-module (mcron config))

(define-public config-debug #t)
(define-public config-package-name "GNU Mcron")
(define-public config-package-version "1.0.8")
(define-public config-package-string "package string")
(define-public config-package-bugreport "bug-mcron@gnu.org")
(define-public config-package-url "https://www.gnu.org/software/mcron")
(define-public config-sendmail "sendmail")

(define-public config-spool-dir "/var/cron/tabs")
(define-public config-socket-file "/var/cron/socket")
(define-public config-allow-file "/var/cron/allow")
(define-public config-deny-file "/var/cron/deny")
(define-public config-pid-file "/var/run/cron.pid")
(define-public config-tmp-dir "/tmp")
