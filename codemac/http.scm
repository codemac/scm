;;; HTTP helpers, because I don't like the main guile http
;;; library. Things this library will tend to do:
;;;
;;; - extend rather than replace (web http)
;;; - never call (error "poop") because exceptions are the devil
;;; - Trend towards not decoding anything off the wire until the
;;;   client asks (i.e. headers are kept as strings)

(define-module (codemac http)
  #:use-module
  #:export (http-req))

(define* (http-req uri #:key
		   (method 'GET)
		   (port (open-socket-for-uri uri))
		   (version '(1 . 1))
		   (keep-alive? #f)
		   (headers '())
		   (streaming #f)
		   (body #f))
  (let ((request
	 (make-requset method uri version
		       (if (not (assq-ref headers 'host))
			   (acons 'host (cons (uri-host uri) (uri-port uri)))
			   headers)
		       meta port)))
    (call)
    ))
(define (https-call https-proc)
  (lambda* (uri #:key (headers '()) (body #f))
    (let* ((socket (open-socket-for-uri uri))
           (session (make-session connection-end/client)))
      ;; (set-log-level! 9)
      ;; (set-log-procedure!
      ;;  (lambda (level msg) (format #t "|<~d>| ~a" level msg)))

      ;; Use the file descriptor that underlies SOCKET.
      (set-session-transport-fd! session (fileno socket))

      ;; Use the default settings.
      (set-session-priorities! session "NORMAL")

      ;; Create anonymous credentials.
      (set-session-credentials! session
                                (make-anonymous-client-credentials))
      (set-session-credentials! session
                                (make-certificate-credentials))

      ;; Perform the TLS handshake with the server.
      (handshake session)

      (receive (response recvbody)
          (https-proc uri
		      #:body body
		      #:port (session-record-port session)
		      #:keep-alive? #t
		      #:headers headers)
        (bye session close-request/rdwr)
        (values response recvbody)))))

(define https-get (https-call http-get))
(define https-post (https-call http-post))
