    $(document).on('page:change', function () {

         var table = $('#components').DataTable({
             "ajax": {
                 "url": "/components/course/" + $('#course_id').val() + ".json",
                 "dataSrc": ""
             },
             "paging": false,
             "info": false,
             "searching": false,
             "ordering": false,
             select:"single",
             "columns": [
                 {
                     "className": 'details-control',
                     "orderable": false,
                     "data": null,
                     "defaultContent": '',
                     "render": function () {
                         return '<i class="fa fa-plus-square" aria-hidden="true"></i>';
                     },
                     width:"15px"
                 },
                 { "data": "id" },
                 { "data": "created_at" },
                 { "data": "modified_by" }
             ],
             "order": [[1, 'asc']]
         });

         // Add event listener for opening and closing details
         $('#components tbody').on('click', 'td.details-control', function () {
             var tr = $(this).closest('tr');
             var tdi = tr.find("i.fa");
             var row = table.row(tr);

             if (row.child.isShown()) {
                 // This row is already open - close it
                 row.child.hide();
                 tr.removeClass('shown');
                 tdi.first().removeClass('fa-minus-square');
                 tdi.first().addClass('fa-plus-square');
             }
             else {
                 // Open this row
                 row.child(format(row.data())).show();
                 tr.addClass('shown');
                 tdi.first().removeClass('fa-plus-square');
                 tdi.first().addClass('fa-minus-square');
             }
         });

         table.on("user-select", function (e, dt, type, cell, originalEvent) {
             if ($(cell.node()).hasClass("details-control")) {
                 e.preventDefault();
             }
         });
     });

    function format(d){
        
         // `d` is the original data object for the row
         return '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">' +
             '<tr>' +
                 '<td><pre>' + d.content + '</pre></td>' +
             '</tr>' +
         '</table>';  
    }

    