(require 'request)
(require 'esxml-query)

(defvar GEO-URL "http://www.geoplugin.com/")
(defvar LOCATION-URL "http://www.geoplugin.net/json.gp")

(defun get-geo-html ()
  (request-response-data
   (request GEO-URL
     :sync t)))

(defun get-location-data (ip)
  (request-response-data
   (request LOCATION-URL
     :params '(("ip" . ip))
     :parser 'json-read
     :sync t)))

(defun get-ext-ip ()
  (let* ((html (with-temp-buffer
		 (insert (get-geo-html))
		 (libxml-parse-html-region (point-min) (point-max))))
	 (input (esxml-query "input#entered_ip" html)))
    (cdr (assoc 'value (cadr input)))))

(defun main ()
  (let* ((ip (get-ext-ip))
	 (location-data (get-location-data ip))
	 (lat (cdr (assoc 'geoplugin_latitude location-data)))
	 (lon (cdr (assoc 'geoplugin_longitude location-data))))
    ))

(main)
