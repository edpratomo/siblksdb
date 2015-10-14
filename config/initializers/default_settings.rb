Setting.defaults[:change_log_archive_interval] = '4_week'
Setting.defaults[:director] = 'P. Tri Prasetyo, SDB'
Setting.defaults[:kasie_ppk_name] = 'Dadang Natsir Jayadiwangsa'
Setting.defaults[:kasie_ppk_nip] = '19580517 198102 1003'
# use perl CPAN module Calendar::Indonesia::Holiday to get indonesian holidays
# run: list-id-holidays --json --year-min=2014 --fields=date --fields=ind_name
#
# perl -MJSON=to_json -MCalendar::Indonesia::Holiday=list_id_holidays \
# -le'print to_json(list_id_holidays(year => 2015, detail => 1)->[2], {utf8 => 1, pretty => 1})'
Setting.defaults[:holidays] = {} 
Setting.defaults[:anypkg_grade_component] = {}
