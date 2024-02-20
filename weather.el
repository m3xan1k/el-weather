;;; el-weather.el --- Current weather in emacs  -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Sergey Shevtsov

;; Version: 0.1

;; Author: Sergey Shevtsov <m3xan1k at duck.com>
;; Created: 20 Feb 2024

;; Keywords: weather
;; URL: https://codeberg.org/m3xan1k/el-weather.el

;; Package-Requires: ((esxml "0.3.7") (request "0.3.3"))

;; This file is not part of GNU Emacs.

;; This file is free software see <https://www.gnu.org/licenses/>.

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
  "Get html to know ip address."
  (request-response-data
   (request GEO-URL
     :sync t)))

(defun get-location-data (ip)
  "Get location coordinates by ip address."
  (request-response-data
   (request LOCATION-URL
     :params '(("ip" . ip))
     :parser 'json-read
     :sync t)))

(defun get-forecast-data (lat lon tz)
  "Get only necessery fields from weather api."
  (request-response-data
   (request FORECAST-URL
     :parser 'json-read
     :sync t
     :params `(("latitude" . ,lat)
	       ("longitude" . ,lon)
	       ("timezone" . ,tz)
	       ("wind_speed_unit" . "ms")
	       ("forecast_days" . 1)
	       ("current" . ,(mapconcat 'symbol-name output-fields ","))))))

(defun get-ext-ip ()
  "Parse html to get external ip."
  (let* ((html (with-temp-buffer
		 (insert (get-geo-html))
		 (libxml-parse-html-region (point-min) (point-max))))
	 (input (esxml-query "input#entered_ip" html)))
    (cdr (assoc 'value (cadr input)))))

(defun m3xan1k-show-weather ()
  "Entry point."
  (interactive)
  (let* ((ip (get-ext-ip))
	 (location-data (get-location-data ip))
	 (lat (cdr (assoc 'geoplugin_latitude location-data)))
	 (lon (cdr (assoc 'geoplugin_longitude location-data)))
	 (tz (cdr (assoc 'geoplugin_timezone location-data)))
	 (forecast-data (get-forecast-data lat lon tz)))
    (print (mapconcat
	    #'(lambda (x) (format "%s: %s%s"
				  x
				  (cdr (assoc x (cdr (assoc 'current forecast-data))))
				  (cdr (assoc x (cdr (assoc 'current_units forecast-data))))))
	    output-fields
	    "\n"))))

;;; el-weather.el ends here
