(require 'request)
(require 'esxml-query)

(defvar GEO-URL "http://www.geoplugin.com/")
(defvar LOCATION-URL "http://www.geoplugin.net/json.gp")
(defvar FORECAST-URL "https://api.open-meteo.com/v1/forecast")



(defvar output-fields
  '(temperature_2m
    relative_humidity_2m
    rain
    showers
    snowfall
    cloud_cover
    wind_speed_10m))

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

;; ;; https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current=temperature_2m,relative_humidity_2m,rain,showers,snowfall,cloud_cover,wind_speed_10m&wind_speed_unit=ms&forecast_days=1

(defun get-forecast-data (lat lon tz)
  (request-response-data
   (request FORECAST-URL
     :params '(("latitude" . lat)
	       ("longitude" . lon)
	       ("timezone" . tz)
	       ("wind_speed_unit" . "ms")
	       ("forecast_days" . 1)
	       ("current" . (mapconcat 'symbol-name output-fields ","))))))

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
	 (lon (cdr (assoc 'geoplugin_longitude location-data)))
	 (tz (cdr (assoc 'geoplugin_timezone location-data)))
	 (forecast-data (get-forecast-data lat lon tz)))
    forecast-data
    ))

