Ve = function(language) {
  return({
    'words': function(text, callback) {
      var url = 'http://ve.kimtaro.com:4567/' + language + '/words';
      // var url = 'http://localhost:4567/' + language + '/words';
      Ve.cb = callback;
      
      $.ajax({
        url: url,
        data: {'text': text, 'callback': 'Ve.cb'},
        dataType: 'jsonp',
		    type: 'POST',
        success: function(data){
          callback(data);
       }
      });
    }
  });
};
