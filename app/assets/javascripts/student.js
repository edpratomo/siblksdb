$(document).on('page:change', function() {
  $('.destroy_students_record_tip').poshytip({content: 'Masih dapat dihapus karena belum mempunyai jadwal'});
  $('.dialog_tip').poshytip({content: 'Klik untuk preview data siswa'});
  $('.grade_dialog_tip').poshytip({content: 'Klik untuk lihat nilai'});
});

function show_grade_dialog() {
  var my_id = $(this).attr("id");
  BootstrapDialog.show({
    size: BootstrapDialog.SIZE_NORMAL,
    buttons: [
      {
        label: 'Tutup',
        cssClass: 'btn-warning',
        icon: 'glyphicon glyphicon-ban-circle',
        action: function(dialogItself) {
                  dialogItself.setData("button", "Tutup")
                  dialogItself.close();
                }
      }
    ],
    message: my_id == '' ? 'Belum ada nilai' : $('<div></div>').load('/grades/' + my_id + '?brief=1')
  });
}

$(function() {
  $("body").on("click", ".open_grade_dialog", show_grade_dialog);
});
