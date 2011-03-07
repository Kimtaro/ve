Ve = function(language) {
  return({
    'words': function(text, callback) {
      var url = 'http://sprak.kimtaro.com:4567/' + language + '/words';
      //var url = 'http://localhost:4567/' + language + '/' + func;
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
