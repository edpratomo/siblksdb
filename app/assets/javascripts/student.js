$(document).on('page:change', function() {
  $('.destroy_students_record_tip').poshytip({content: 'Masih dapat dihapus karena belum mempunyai jadwal'});
  $('.dialog_tip').poshytip({content: 'Klik untuk preview data siswa'});
  $('.grade_dialog_tip').poshytip({content: 'Klik untuk lihat nilai'});
});
