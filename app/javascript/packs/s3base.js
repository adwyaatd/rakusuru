$(document).on('turbolinks:load', function(){
	$('#check_all').on('click', function() {
		$("input[type=checkbox],[id^=shop_ids_]").prop('checked', this.checked);
	});

	$("input[type=checkbox],[id^=shop_ids_]").on('click',function(){
		var $count_checked = $("input[id^=shop_ids_]").filter(":checked").length;
		var $count_input = $("input[id^=shop_ids_]").length;

		if ($count_checked == $count_input){
			$("#check_all").prop('checked', 'checked');
		}else{
			$('#check_all').prop('checked', false);
		}
	});
});

$(document).on('turbolinks:load', function(){
	$('#bulk_submit_test').on('click',function(){
		$('#logout-modal').fadeIn();
	});

	$('#logout-no,.close-modal').on('click',function(){
		$('#logout-modal').fadeOut();
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

