var Sprakd = (function() {
  return({
    'parse': function(text, language, func, callback) {
      var url = 'http://sprak.kimtaro.com:4567/' + language + '/' + func;
      $.ajax({
        url: url,
        data: {'text': text},
        dataType: 'json',
		type: 'POST',
        success: function(data){
          callback(data);
       }
      });
    }
  });
})();

