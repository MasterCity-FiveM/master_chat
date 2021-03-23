﻿var AutoCompleteOptions = {
	data: [],
	getValue: "name",

	template: {
		type: "description",
		fields: {
			description: "help"
		}
	},
	minCharNumber: 3,
	list: {
		match: {
			enabled: true
		},
		maxNumberOfElements: 2,
		sort: {
			enabled: true
		},
		showAnimation: {
			type: "fade",
			time: 400,
			callback: function() {}
		},	

		hideAnimation: {
			type: "slide",
			time: 400,
			callback: function() {}
		}
	}
};

$(document).ready(function () {
	window.addEventListener("message", function (event) {
		if (event.data.action == "show") {
			$(".ui").fadeIn();
			$("#message").focus();
			$('.box100').scrollTop($('.box100')[0].scrollHeight);
			if (AutoCompleteOptions.data.length <= 0) {
				$.post("https://master_chat/GetSuggestions", JSON.stringify({}));
			}
			window.scrollTo(0,document.body.scrollHeight);
		} else if (event.data.action == "hide") {
			closeUI();
		} else if (event.data.action == "suggestions") {
			Sugs = event.data.suggestions;
			for (var prop in Sugs) {
				AutoCompleteOptions.data.push({name: Sugs[prop].name, help: Sugs[prop].help});
			}
		} else if (event.data.action == "sent_message") {
			$(".box100").append('<div class="sent amessage"><p class="name">' + htmlEntities(event.data.name) + ':</p><p>' + htmlEntities(event.data.message) + '</p></div><div style="clear:both;"></div>');
			
			
			
			///CLEANUP
			$('.box100').scrollTop($('.box100')[0].scrollHeight);
		} else if (event.data.action == "receive_message") {
			if (event.data.message_type == 'local') {
				$(".box100").append('<div class="chat amessage"><p class="name">' + htmlEntities(event.data.name) + ':</p><p>' + htmlEntities(event.data.message) + '</p></div><div style="clear:both;"></div>');
			}else if (event.data.message_type == 'error') {
				$(".box100").append('<div class="chat error amessage"><p class="name">' + htmlEntities(event.data.name) + ':</p><p>' + htmlEntities(event.data.message) + '</p></div><div style="clear:both;"></div>');
			}
			
			///CLEANUP
			$('.box100').scrollTop($('.box100')[0].scrollHeight);
		}
	});
	
	function closeUI() {
		$(".ui").fadeOut();
	}
	
	document.onkeydown = function(evt) {
		evt = evt || window.event;
		var isEscape = false;
		if ("key" in evt) {
			isEscape = (evt.key === "Escape" || evt.key === "Esc");
		} else {
			isEscape = (evt.keyCode === 27);
		}
		if (isEscape) {
			$.post("https://master_chat/closeUI", JSON.stringify({}));
		}
	};
	
	$(".message").on('keypress', function (e) {
		if (e.key === 'Enter' || e.keyCode === 13) {
			msg = $(this).val();
			if(msg == "" || msg == " ") {
				return;
			}				
			$(this).val("");
			$.post("https://master_chat/sentMessage", JSON.stringify({message:msg}));
		}
	});

	function htmlEntities(str) {
		return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
	}
	
	$(".basicAutoComplete").easyAutocomplete(AutoCompleteOptions);
});