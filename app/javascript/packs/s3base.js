$(document).on('turbolinks:load', function(){
	$('#check_all').on('click', function() {
		$("input[type=checkbox],[id^=ids_]").prop('checked', this.checked);
	});

	$("input[type=checkbox],[id^=ids_]").on('click',function(){
		var $count_checked = $("input[id^=ids_]").filter(":checked").length;
		var $count_input = $("input[id^=ids_]").length;

		if ($count_checked == $count_input){
			$("#check_all").prop('checked', 'checked');
		}else{
			$('#check_all').prop('checked', false);
		}
	});
});


// $(document).on('turbolinks:load', function(){
//   $('p').on('click', function() {
//     $(this).css('color', 'blue');
//   });
// });


// $('p').on('click', function() {
// 	$(this).css('color', 'blue');
// });

