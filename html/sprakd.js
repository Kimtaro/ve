var Sprakd = (function() {
  return({
    'parse': function(text, language, func, callback) {
      var url = 'http://127.0.0.1:4567/' + language + '/' + func;
      $.ajax({
        url: url,
        data: {'text': text},
        dataType: 'jsonp',
        success: function(data){
          callback(data);
       }
      });
    }
  });
})();

