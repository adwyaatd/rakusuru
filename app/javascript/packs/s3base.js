$(document).on('turbolinks:load', function(){
	$('#check_all').on('click', function() {
		$("input[type=checkbox],[id^=s3base_shop_ids_]").prop('checked', this.checked);
	});

	$("input[type=checkbox],[id^=s3base_shop_ids_]").on('click',function(){
		var $count_checked = $("input[id^=s3base_shop_ids_]").filter(":checked").length;
		var $count_input = $("input[id^=s3base_shop_ids_]").length;

		if ($count_checked == $count_input){
			$("#check_all").prop('checked', 'checked');
		}else{
			$('#check_all').prop('checked', false);
		}
	});
});

$(document).on('turbolinks:load', function(){
	$('#bulk_submit_test').on('click',function(){
		$('#submit_modal').fadeIn();
	});

	$('#select_no,.close_modal').on('click',function(){
		$('#submit_modal').fadeOut();
	});
});

$(document).on('turbolinks:load', function(){
	$('#collect').on('click',function(){
		$('#collect_modal').fadeIn();
	});

	$('#select_no,.close_modal').on('click',function(){
		$('#collect_modal').fadeOut();
	});
});

$(document).on('turbolinks:load', function(){
	$('#collect_search_word').on('click',function(){
		$('#collect_search_word_modal').fadeIn();
	});

	$('#select_no,.close_modal').on('click',function(){
		$('#collect_search_word_modal').fadeOut();
	});
});

$(document).on('turbolinks:load', function(){
	$('[id^=delete_sender_info_]').on('click',function(){
		const i = $(this).data("i")
		$('#delete_modal_'+i).fadeIn();
	});

	$('[id^=select_no_]').on('click',function(){
		const i = $(this).data("i")
		$('#delete_modal_'+i).fadeOut();
	});
});

$(document).on('turbolinks:load', function(){
	$('#confirm_submission').on('click',function(){
		$('#confirm_modal').fadeIn();
	});

	$('#select_no,.close_modal').on('click',function(){
		$('#confirm_modal').fadeOut();
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

