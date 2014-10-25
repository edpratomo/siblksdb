Setting.defaults[:change_log_archive_interval] = '4_week'
Setting.defaults[:director] = 'P. Tri Prasetyo, SDB'
# use perl CPAN module Calendar::Indonesia::Holiday to get indonesian holidays
# run: list-id-holidays --json --year-min=2014 --fields=date --fields=ind_name
Setting.defaults[:holidays] = {} 
