/**
 *	ve.js
 *
 *	Communicates with a Sinatra-server to facilitate linguistic
 *	parsing tech in JS.
 *
 *	@Author: Kim Ahlstrom
 *	@Author: Ryan McGrath <ryan@venodesigns.net>
 *	@Requires: Nothing
 */

;(function(w, d, undefined) {
	var Ve = w.Ve = function Ve(language) {
		this.language = language;
		this.url = 'http://localhost:4567/';
		return this;
	};
	
	Ve.prototype = {
		words: function(text, callbackfn) {
			// Need to utf8-encode stuff at this point...
			jsonp(this.url + this.language + '/words?text=' + text, callbackfn);
			return this;
		}
	};

	var jsonp = function jsonp(src, callbackfn) {
		var newScript = document.createElement("script"),
			callback = 've_callback_' + +new Date();
		
	    newScript.type = "text/javascript";
	    newScript.setAttribute("async", "true");
	    newScript.setAttribute("src", src + '&callback=' + callback);
		window[callback] = callbackfn;

	    /**
	     *  Automagically handle cleanup of injected script tags, so we don't litter someone's DOM
	     *  with our stuff. This branches for various reasons - could be a bit cleaner.
	     */
	    if(newScript.readyState) {
	        newScript.onreadystatechange = function() {
	            if(/loaded|complete/.test(newScript.readyState)) {
	                newScript.onreadystatechange = null;
	                document.documentElement.firstChild.removeChild(newScript);
					window[callback] = null;
	            }
	        }
	    } else {
	        newScript.addEventListener("load", function() {
	            document.documentElement.firstChild.removeChild(newScript);
				window[callback] = null;
	        }, false);
	    }

	    document.documentElement.firstChild.appendChild(newScript);
	}
})(window, document, 'undefined');