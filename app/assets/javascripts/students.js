$(function(){
  $('.trigger').poshytip({
    content: function(updateCallback) {
      var student_id = $(this).attr('id').split('_').pop();
      window.setTimeout(function() {
        updateCallback('Tooltip content updated! ' + student_id);
      }, 1000);
      return 'Loading...';
    }
  });
});
