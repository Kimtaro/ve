Ve = function(language) {
  return({
    'words': function(text, callback) {
      //var url = 'http://ve.kimtaro.com:4567/' + language + '/words';
      var url = 'http://localhost:4567/' + language + '/words';
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
};
